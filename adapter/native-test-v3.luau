

local NativeTest = {}

local function u32(value)
    local data = buffer.create(4)
    buffer.writeu32(data, 0, value)
    return buffer.tostring(data)
end

local function observer(entry, target, descriptor, state, seed)
    local supported = true
    local events = {}
    local identities, retained = {}, {}
    local function unsupported(message)
        supported = false
        error(message, 0)
    end
    local function value(item)
        local kind = type(item)
        if kind == "nil" then return string.char(0) end
        if kind == "boolean" then return string.char(1, if item then 1 else 0) end
        if kind == "number" then
            local data = buffer.create(8)
            buffer.writef64(data, 0, item)
            return string.char(2) .. buffer.tostring(data)
        end
        if kind == "string" then return string.char(3) .. u32(#item) .. item end
        if typeof(item) == "Vector3" then
            local data = buffer.create(12)
            buffer.writef32(data, 0, item.X)
            buffer.writef32(data, 4, item.Y)
            buffer.writef32(data, 8, item.Z)
            return string.char(4, 3) .. buffer.tostring(data)
        end
        if typeof(item) == "buffer" then
            local identity = identities[item]
            if not identity then
                identity = #retained + 1
                identities[item], retained[identity] = identity, item
            end
            return string.char(5) .. u32(identity) .. u32(buffer.len(item)) .. buffer.tostring(item)
        end
        return unsupported("native observation requires an explicit probe for " .. typeof(item))
    end
    local function tuple(items)
        local pieces = table.create(items.n + 1)
        pieces[1] = u32(items.n)
        for index = 1, items.n do pieces[index + 1] = value(items[index]) end
        return table.concat(pieces)
    end
    local original_environment = getfenv(entry)



    if not state.environment then
        state.environment = setmetatable({ script = target }, { __index = original_environment })
    end
    local environment = state.environment
    for name, kind in { print = 1, warn = 2 } do
        environment[name] = function(...)
            events[#events + 1] = string.char(kind) .. tuple(table.pack(...))
            for index = 1, select("#", ...) do tostring(select(index, ...)) end
        end
    end


    local environment_ok, environment_error = pcall(setfenv, entry, environment)
    if not environment_ok then return nil, "executor cannot set isolated test environment: " .. tostring(environment_error) end
    local function probe()
        local output = table.pack(entry())
        if output.n ~= 1 then return unsupported("fixture entry return count differs from its known-source probe") end
        if descriptor.probe == "module_interface" then
            local module = output[1]
            if type(module) ~= "table" or type(module.update) ~= "function" or type(module.snapshot) ~= "function" then
                return unsupported("module interface differs from the explicit fixture contract")
            end
            local first = table.pack(module.update(seed))
            local second = table.pack(module.update(2))
            local a, b = module.snapshot(), module.snapshot()
            return tuple(first), tuple(second), a.count, a.version, b.count, b.version, rawequal(a, b)
        end
        if descriptor.probe == "large_module" then
            if type(output[1]) ~= "table" then return unsupported("large-module result is not a table") end
            local total = 0
            for index = 1, 128 do
                local fn = output[1]["operation" .. index]
                if type(fn) ~= "function" then return unsupported("large-module export is missing") end
                local values = table.pack(fn(seed))
                if values.n ~= 2 or values[2] ~= nil then return unsupported("large-module return pack changed") end
                total += values[1]
            end
            return total, 128
        end
        local fn = output[1]
        if type(fn) ~= "function" then return unsupported("fixture result is not the expected function") end
        local function invoke(...)
            local previous = getfenv(fn)
            local changed, failure = pcall(setfenv, fn, environment)
            if not changed then return unsupported("cannot isolate returned fixture function: " .. tostring(failure)) end
            local called = table.pack(pcall(fn, ...))
            pcall(setfenv, fn, previous)
            if not called[1] then error(called[2], 0) end
            return table.unpack(called, 2, called.n)
        end
        local same_as_previous_entry = state.previous_function ~= nil and rawequal(state.previous_function, fn)
        state.previous_function = fn
        if descriptor.probe == "stateful_function" then
            local first = table.pack(invoke(seed))
            local second = table.pack(invoke(2))
            local third = table.pack(invoke(seed))
            return same_as_previous_entry, tuple(first), tuple(second), tuple(third)
        end
        local results = table.pack(invoke(seed))
        return same_as_previous_entry, results.n, table.unpack(results, 1, results.n)
    end
    local result = table.pack(pcall(probe))
    pcall(setfenv, entry, original_environment)
    if not supported then return nil, "observation/probe unsupported; equal errors cannot count as success" end
    local terminal = { n = result.n - 1 }
    for index = 2, result.n do terminal[index - 1] = result[index] end
    local encoded_ok, encoded = pcall(function()
        return "LOBS" .. string.char(1, 1) .. u32(#events) .. table.concat(events)
            .. string.char(if result[1] then 0 else 1) .. tuple(terminal)
    end)
    if not encoded_ok or not supported then return nil, "terminal observation unsupported" end
    return encoded
end

local function resolve(descriptor)
    if descriptor.class == "LocalScript" then
        local player = game:GetService("Players").LocalPlayer
        local scripts = player and player:FindFirstChild("PlayerScripts")
        local folder = scripts and scripts:FindFirstChild("DecompilerV3Fixtures")
        return folder and folder:FindFirstChild(descriptor.id)
    end
    local folder = game:GetService("ReplicatedStorage"):FindFirstChild("DecompilerV3Fixtures")
    return folder and folder:FindFirstChild(descriptor.id)
end

function NativeTest.run(Adapter, manifest, options)
    options = options or {}
    assert(type(options.expected_place_id) == "number" and options.expected_place_id > 0,
        "an explicit published controlled test PlaceId is required")
    assert(game.PlaceId == options.expected_place_id, "controlled-place identity mismatch; no fixtures executed")
    assert(manifest.fixture_package == "luau-decompiler-v0.3.0-native-r1" and manifest.distinct_native_programs_planned == 14)
    local required = {
        CaptureCounter = true, ClientMethods = true, LargeFunction = true, LargeModule = true,
        LocalBinary = true, LocalLoop = true, LoopMutation = true, ModuleDependency = true,
        ModuleInterface = true, OwnedMethods = true, ProtectedCalls = true,
        RequireDependency = true, ScalarBinary = true, VectorValues = true,
    }
    assert(#manifest.cases == 14 and manifest.behavioral_comparisons_planned == 42)
    for _, descriptor in manifest.cases do
        assert(required[descriptor.id], "unknown or duplicate native fixture identity")
        required[descriptor.id] = nil
        assert(#descriptor.inputs == 3 and descriptor.inputs[1] == -3 and descriptor.inputs[2] == 0 and descriptor.inputs[3] == 7)
        assert(type(descriptor.source_sha256) == "string" and #descriptor.source_sha256 == 64)
    end
    assert(next(required) == nil, "native fixture family omitted")
    local folder = game:GetService("ReplicatedStorage"):FindFirstChild("DecompilerV3Fixtures")
    local marker = folder and folder:FindFirstChild("FixturePlan")
    assert(marker and marker:IsA("StringValue") and marker.Value == manifest.fixture_plan_sha256,
        "fixture manifest marker mismatch; no fixtures executed")
    local native_closure = options.get_closure or getscriptclosure
    local native_bytecode = options.get_bytecode or (options.adapter_options and options.adapter_options.get_bytecode) or getscriptbytecode or dumpstring
    assert(type(native_closure) == "function", "a verified native script-closure getter is required for these controlled probes")
    assert(type(native_bytecode) == "function", "a documented binary-safe native bytecode getter is required")
    assert(type(loadstring) == "function" and type(getfenv) == "function" and type(setfenv) == "function")
    local environment = options.environment or getgenv()
    local original = rawget(environment, "decompile")
    local original_registry = rawget(environment, "_LUAU_DECOMPILER_ADAPTER_CHAIN_V2")
    local config = table.clone(options.adapter_options or {})
    config.environment = environment
    config.reconstruction_config = table.clone(config.reconstruction_config or {})
    config.reconstruction_config.closures = table.clone(config.reconstruction_config.closures or {
        entry_invocation = "repeated", compiler_closure_sharing = false,
    })
    assert(config.reconstruction_config.closures.entry_invocation == "repeated",
        "these probes reuse each loaded entry; single-entry reconstruction cannot count as repeated-entry evidence")
    local controller = Adapter.install(config)
    local report = { schema = 1, oracle_protocol = "LOBS/1", fixture_package = manifest.fixture_package,
        fixture_plan_sha256 = manifest.fixture_plan_sha256, expected_place_id = options.expected_place_id,
        actual_place_id = game.PlaceId, runtime = version(), executor = { identifyexecutor() },
        native_programs_attempted = 0, native_programs_verified = 0, typed_comparisons = 0,
        supplied_bytecode_fixtures = 0, timing_repetitions = 0, cases = {} }
    local platform_ok, platform = pcall(function() return game:GetService("UserInputService"):GetPlatform().Name end)
    report.platform = options.platform or (if platform_ok then platform else "unverified")
    report.architecture = options.architecture or "unverified"
    report.architecture_evidence = if options.architecture then "operator supplied" else "not available in portable executor API"
    local ok, failure = pcall(function()
        report.capabilities = controller.handshake()
        for _, descriptor in manifest.cases do
            local item = { id = descriptor.id, class = descriptor.class, probe = descriptor.probe,
                expected_source_sha256 = descriptor.source_sha256, status = "not_run", comparisons = {} }
            report.cases[#report.cases + 1] = item
            local target = resolve(descriptor)
            if not target or target.ClassName ~= descriptor.class then
                item.reason = "known fixture is not client-visible; engine replication/extraction unverified"
                continue
            end
            report.native_programs_attempted += 1
            local succeeded, error_value = pcall(function()
                local raw = native_bytecode(target)
                assert(type(raw) == "string" and #raw > 0 and #raw <= (options.max_bytecode_bytes or 16 * 1024 * 1024), "native getter returned unsupported or oversized representation")
                item.native_bytecode_base64, item.native_bytecode_bytes = Adapter.encode_base64(raw), #raw
                item.encoding = config.bytecode_encoding or "upstream"
                local original_entry = native_closure(target)
                assert(type(original_entry) == "function", "native closure getter returned no callable entry")
                local rebuilt = controller.decompile_detailed(target)
                assert(native_bytecode(target) == raw, "getter bytes changed during the controlled test; extraction provenance is unstable")
                assert(rebuilt.complete == true, "reconstruction incomplete")
                local rebuilt_entry = assert(loadstring(rebuilt.source, "controlled-native-rebuilt"))
                item.reconstruction_complete, item.quality, item.strict_validation = rebuilt.complete, rebuilt.quality, rebuilt.validation
                item.reconstructed_source = rebuilt.source
                item.profile, item.type_report = rebuilt.profile, rebuilt.type_report
                item.closure_scope, item.assumptions = rebuilt.closure_scope, rebuilt.assumptions
                local original_state, rebuilt_state = {}, {}
                for _, seed in descriptor.inputs do
                    local expected, expected_error = observer(original_entry, target, descriptor, original_state, seed)
                    local actual, actual_error = observer(rebuilt_entry, target, descriptor, rebuilt_state, seed)
                    if not expected or not actual then error(expected_error or actual_error, 0) end
                    local matched = expected == actual
                    item.comparisons[#item.comparisons + 1] = { seed = seed,
                        expected_base64 = Adapter.encode_base64(expected), actual_base64 = Adapter.encode_base64(actual), matched = matched }
                    if not matched then error("typed observation mismatch; do not normalize errors or discard the case", 0) end
                    report.typed_comparisons += 1
                end
                item.status = "verified"
                report.native_programs_verified += 1
            end)
            if not succeeded then
                item.status = "failed"
                item.reason = if type(error_value) == "table" then { stage = error_value.stage, message = error_value.message,
                    proto = error_value.proto, pc = error_value.pc, status = error_value.status } else tostring(error_value)
            end
        end
    end)
    controller.restore()
    report.original_function_restored = rawget(environment, "decompile") == original
    report.registry_cleared = rawget(environment, "_LUAU_DECOMPILER_ADAPTER_CHAIN_V2") == nil
    report.registry_restored = rawget(environment, "_LUAU_DECOMPILER_ADAPTER_CHAIN_V2") == original_registry
    report.completed = ok and report.original_function_restored and report.registry_restored
        and report.native_programs_verified == manifest.distinct_native_programs_planned
        and report.typed_comparisons == manifest.behavioral_comparisons_planned
    if not ok then report.failure = tostring(failure) end
    return report
end


NativeTest._observe_for_tests = observer

return NativeTest
