local Collector = {}

function Collector.start(options)
    assert(type(options) == "table", "collector options required")
    assert(type(options.snapshot) == "string" and #options.snapshot <= 96, "bounded snapshot identity required")
    assert(type(options.endpoint) == "string" and options.endpoint:match("^http://127%.0%.0%.1:%d+$"), "numeric loopback receiver required")
    assert(type(options.token) == "string" and #options.token >= 32, "receiver token required")
    assert(type(options.encode_base64) == "function", "binary-safe encoder required")
    assert(type(getscriptbytecode) == "function", "script bytecode getter unavailable")
    assert(type(request) == "function", "HTTP request API unavailable")
    assert(game.PlaceId == options.place_id, "connected place does not match capture authorization")
    local http = game:GetService("HttpService")
    local encode = options.encode_base64
    local getter = getscriptbytecode
    local transport = request
    local maximumInventory = options.max_inventory or 50000
    local maximumBlob = options.max_blob_bytes or 8 * 1024 * 1024
    local maximumTotal = options.max_total_bytes or 512 * 1024 * 1024
    local maximumSeconds = options.max_seconds or 900
    assert(maximumInventory >= 1 and maximumInventory <= 100000, "invalid inventory bound")
    assert(maximumBlob >= 1 and maximumBlob <= 8 * 1024 * 1024, "invalid bytecode bound")
    assert(maximumTotal >= maximumBlob and maximumTotal <= 1024 * 1024 * 1024, "invalid aggregate bound")
    assert(maximumSeconds >= 1 and maximumSeconds <= 1800, "invalid capture deadline")
    local state = {
        snapshot = options.snapshot,
        phase = "created",
        running = false,
        cancelled = false,
        inventory_cursor = 1,
        capture_cursor = 1,
        captured_bytes = 0,
        counts = {},
        object_ids = {},
        next_object_id = 0,
        items = {},
        order_buckets = {},
        capture_order = {},
    }
    local function identity(item)
        local value = state.object_ids[item]
        if value == nil then
            state.next_object_id += 1
            value = state.next_object_id
            state.object_ids[item] = value
        end
        return value
    end
    local function segments(item)
        local reverse = {}
        local current = item
        while current and current ~= game do
            if #reverse >= 128 then
                return nil
            end
            reverse[#reverse + 1] = {
                identity = identity(current),
                name_base64 = encode(current.Name),
                class = current.ClassName,
            }
            current = current.Parent
        end
        if current ~= game then
            return nil
        end
        local result = {}
        for index = #reverse, 1, -1 do
            result[#result + 1] = reverse[index]
        end
        return result
    end
    local function acknowledged(path, cursor)
        if path == "/inventory" then
            state.inventory_cursor = cursor
        elseif path == "/capture" then
            state.capture_cursor = cursor
        end
    end
    local function send(path, payload, cursor)
        local body = http:JSONEncode(payload)
        assert(#body <= 16 * 1024 * 1024, "collector wire body exceeds bound")
        state.pending = {path = path, body = body, cursor = cursor}
        local response = transport({
            Url = options.endpoint .. path,
            Method = "POST",
            Headers = {Authorization = "Bearer " .. options.token, ["Content-Type"] = "application/json"},
            Body = body,
        })
        assert(type(response) == "table" and response.StatusCode == 200, "capture receiver rejected a batch")
        acknowledged(path, cursor)
        state.pending = nil
    end
    local function retry_pending()
        if state.pending then
            local response = transport({
                Url = options.endpoint .. state.pending.path,
                Method = "POST",
                Headers = {Authorization = "Bearer " .. options.token, ["Content-Type"] = "application/json"},
                Body = state.pending.body,
            })
            assert(type(response) == "table" and response.StatusCode == 200, "capture receiver still unavailable")
            acknowledged(state.pending.path, state.pending.cursor)
            state.pending = nil
        end
    end
    local function capture_one(index, item)
        local row = {id = index, captured_at = DateTime.now().UnixTimestampMillis}
        local path = segments(item)
        if path == nil then
            row.status = "disappeared"
            return row
        end
        row.segments = path
        if item.ClassName == "Script" then
            local ok, context = pcall(function()
                return item.RunContext
            end)
            if not ok or context ~= Enum.RunContext.Client then
                row.status = "unsupported_target_context"
                return row
            end
        end
        if state.cancelled then
            row.status = "cancelled"
            return row
        end
        if state.captured_bytes >= maximumTotal or os.clock() - state.started > maximumSeconds then
            row.status = "aggregate_limit"
            return row
        end
        local ok, bytes = pcall(getter, item)
        if not ok or type(bytes) ~= "string" then
            row.status = "getter_error"
            row.error_base64 = encode(type(bytes) == "string" and bytes:sub(1, 4096) or "non-string getter error or return")
        elseif #bytes == 0 then
            row.status = "empty_bytecode"
            row.returned_bytes = 0
        elseif #bytes > maximumBlob then
            row.status = "input_limit"
            row.returned_bytes = #bytes
        elseif state.captured_bytes + #bytes > maximumTotal then
            row.status = "aggregate_limit"
            row.returned_bytes = #bytes
        else
            row.status = "captured"
            row.returned_bytes = #bytes
            row.bytecode_base64 = encode(bytes)
            state.captured_bytes += #bytes
        end
        return row
    end
    local function run()
        retry_pending()
        if state.phase == "created" then
            local probe = string.char(0, 255, 128, 65, 10)
            local response = transport({Url = options.endpoint .. "/probe", Method = "POST", Headers = {Authorization = "Bearer " .. options.token}, Body = probe})
            assert(response.StatusCode == 200 and http:JSONDecode(response.Body).base64 == encode(probe), "native binary transfer probe failed")
            state.binary_probe = true
            state.started = os.clock()
            state.items = game:QueryDescendants("LocalScript, ModuleScript, Script")
            state.query_matches = #state.items
            state.selected = math.min(#state.items, maximumInventory)
            state.client = {place_id = game.PlaceId, place_version = game.PlaceVersion, game_id = game.GameId, roblox_build = version(), executor = identifyexecutor(), capture_started = DateTime.now().UnixTimestampMillis, query_matches = #state.items, inventory_limit = maximumInventory}
            state.phase = "inventory"
            if state.selected == 0 then
                send("/inventory", {snapshot = state.snapshot, client = state.client, rows = {}, complete = true}, 1)
            end
        end
        while state.phase == "inventory" and state.inventory_cursor <= state.selected do
            local rows = {}
            local last = state.inventory_cursor - 1
            local wireBytes = 0
            for index = state.inventory_cursor, math.min(state.inventory_cursor + 499, state.selected) do
                local item = state.items[index]
                local path = segments(item)
                local row = {id = index, class = item.ClassName, segments = path or {{identity = identity(item), name_base64 = encode(item.Name), class = item.ClassName}}, path_status = path and "parented" or "disappeared"}
                local priorities = {Workspace = 1, Players = 2, ReplicatedFirst = 3, ReplicatedStorage = 4, StarterGui = 5, StarterPlayer = 6, CoreGui = 8, CorePackages = 9}
                local priority = path and (priorities[path[1].class] or 7) or 7
                state.order_buckets[priority] = state.order_buckets[priority] or {}
                table.insert(state.order_buckets[priority], index)
                local debugOk, debugId = pcall(function()
                    return item:GetDebugId(16)
                end)
                row.debug_id = debugOk and debugId or nil
                if item.ClassName == "Script" then
                    local ok, context = pcall(function()
                        return item.RunContext.Name
                    end)
                    row.run_context = ok and context or "unavailable"
                end
                rows[#rows + 1] = row
                last = index
                wireBytes += #http:JSONEncode(row)
                if wireBytes >= 2 * 1024 * 1024 then
                    break
                end
            end
            send("/inventory", {snapshot = state.snapshot, client = state.client, rows = rows, complete = last == state.selected}, last + 1)
            state.inventory_cursor = last + 1
            task.wait()
        end
        if state.phase == "inventory" then
            for priority = 1, 9 do
                for _, index in state.order_buckets[priority] or {} do
                    state.capture_order[#state.capture_order + 1] = index
                end
            end
            state.phase = "capture"
        end
        while state.phase == "capture" and state.capture_cursor <= state.selected do
            assert(game.PlaceId == options.place_id, "place changed during capture")
            local rows = {}
            local bytes = 0
            local last = state.capture_cursor - 1
            for index = state.capture_cursor, math.min(state.capture_cursor + 63, state.selected) do
                local itemIndex = state.capture_order[index]
                local row = capture_one(itemIndex, state.items[itemIndex])
                rows[#rows + 1] = row
                state.counts[row.status] = (state.counts[row.status] or 0) + 1
                bytes += #http:JSONEncode(row)
                last = index
                if bytes >= 2 * 1024 * 1024 then
                    break
                end
            end
            send("/capture", {snapshot = state.snapshot, rows = rows}, last + 1)
            state.capture_cursor = last + 1
            task.wait()
        end
        if state.phase == "capture" then
            send("/complete", {snapshot = state.snapshot})
            state.phase = "complete"
            state.items = {}
            state.object_ids = {}
        end
    end
    function state.resume()
        assert(not state.running, "capture already running")
        state.running = true
        state.error = nil
        task.spawn(function()
            local ok, message = pcall(run)
            state.running = false
            if not ok then
                state.error = type(message) == "string" and message:sub(1, 512) or "collector operation failed"
            end
        end)
    end
    function state.cancel()
        state.cancelled = true
    end
    function state.summary()
        return {snapshot = state.snapshot, phase = state.phase, running = state.running, error = state.error, binary_probe = state.binary_probe, query_matches = state.query_matches, selected = state.selected, inventory_cursor = state.inventory_cursor, capture_cursor = state.capture_cursor, captured_bytes = state.captured_bytes, counts = state.counts}
    end
    state.resume()
    return state
end

return Collector
