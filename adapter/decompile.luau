local Adapter = {}
local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local registry_key = "_LUAU_DECOMPILER_ADAPTER_CHAIN_V2"

local profiles = {
    generic = {script=true,bytecode=true,func=true,options="canonical"},
    volt = {script=true,bytecode=true,func=false,options="native"},
    lynx = {script=true,bytecode=true,func=true,options="native"},
    madium = {script=true,bytecode=false,func=false,options="none"},
}
local function argument(message)
    error("decompile argument error: " .. message, 3)
end
local function copy_config(value, depth, seen, budget)
    if type(value) ~= "table" then return value end
    depth = depth or 0; seen = seen or {}; budget = budget or {entries=0,bytes=0}
    assert(depth < 12 and not seen[value], "configuration is cyclic or too deeply nested")
    seen[value] = true
    local result = {}
    for key, child in next, value do
        budget.entries += 1
        assert(budget.entries <= 8192 and type(key)=="string" and #key<=256, "configuration keys must be bounded strings within 8192 entries")
        budget.bytes += #key + (if type(child)=="string" then #child else 0)
        assert(budget.bytes<=2*1024*1024,"configuration string data exceeds 2 MiB")
        assert(type(child)=="table" or type(child)=="string" or type(child)=="boolean" or (type(child)=="number" and child==child and math.abs(child)~=math.huge),"configuration values must be JSON-compatible")
        result[key] = copy_config(child, depth+1, seen, budget)
    end
    seen[value] = nil
    return result
end
local canonical_keys = {profile=true,bytecode_encoding=true,control_flow=true,vector_constructor=true,naming=true,indent=true,output_policy=true,meaningful_typing=true,entry_output=true,
    name_overrides=true,naming_options=true,typing=true,formatting=true,validation=true,closures=true,limits=true}
local native_aliases = {
    smartvariablerenamer="infer_names",inferdescriptivelocals="infer_names",usedebugsymbols="debug_names",
    functiondeclarations="local_functions",prefernamedfunctionsyntax="local_functions",
    restoretypehints="typing",separatelogicalsections="blank_lines",
    indentwidth="indent_width",indentsize="indent_width",columnlimit="line_width",preferredlinewidth="line_width",
    usetabs="tabs",styleusetabs="tabs",argumentlayout="argument_layout",tablelayout="table_layout",
    naming="naming",namingconvention="naming",annotationverbosity="annotation_verbosity",
}
local function merge_config(target, patch)
    for key, value in next, patch do
        if type(value)=="table" and type(target[key])=="table" then merge_config(target[key],value)
        else target[key]=copy_config(value) end
    end
end

function Adapter.map_options(native, profile_name, base)
    profile_name = profile_name or "generic"
    local profile = assert(profiles[profile_name], "unknown executor profile")
    local config = copy_config(base or {})
    if native == nil then return config end
    if type(native) ~= "table" then argument("second argument must be an options table; set deadlines in Adapter.install or decompile_with_timeout") end
    if profile.options == "none" then argument("this executor profile has no documented native options argument; use a canonical controller helper") end
    native = copy_config(native)
    if profile.options == "canonical" then
        for key in next, native do if not canonical_keys[key] then argument("unsupported canonical option "..tostring(key)) end end
        merge_config(config,native)
        return config
    end
    local flat = {}
    local function apply(layer)
        if type(layer) ~= "table" then argument("options/Formatter must be tables") end
        local aliases_seen = {}
        local formatter, wrapped
        for raw_name, value in next, layer do
            if type(raw_name) ~= "string" then argument("option names must be strings") end
            local name = string.lower(raw_name)
            if name == "formatter" then
                if formatter~=nil then argument("multiple aliases for Formatter") end
                formatter=value
            elseif name == "decompileroptions" then
                if wrapped~=nil then argument("multiple aliases for DecompilerOptions") end
                wrapped=value
            else
                local key = native_aliases[name]
                if not key then argument("unsupported native option "..raw_name) end
                if aliases_seen[key] then argument("multiple aliases for native setting "..key) end
                aliases_seen[key]=true;flat[key]=value
            end
        end
        if formatter~=nil then apply(formatter) end
        if wrapped~=nil then apply(wrapped) end
    end
    apply(native)
    local function boolean(key)
        local value=flat[key]
        if value~=nil and type(value)~="boolean" then argument(key.." must be boolean") end
        return value
    end
    local function integer(key, minimum, maximum)
        local value=flat[key]
        if value~=nil and (type(value)~="number" or value~=value or value%1~=0 or value<minimum or value>maximum) then argument(key.." is outside its documented integer range") end
        return value
    end
    config.naming_options=config.naming_options or {};config.formatting=config.formatting or {};config.typing=config.typing or {}
    if flat.infer_names~=nil then config.naming_options.infer_descriptive_names=boolean("infer_names") end
    if flat.debug_names~=nil then config.naming_options.use_debug_names=boolean("debug_names") end
    if flat.local_functions~=nil then config.formatting.local_functions=boolean("local_functions") end
    if flat.blank_lines~=nil then config.formatting.blank_lines=boolean("blank_lines") end
    if flat.typing~=nil then config.typing.mode=if boolean("typing") then "annotated" else "off" end
    local width=integer("indent_width",0,16)
    if flat.tabs~=nil then config.indent=if boolean("tabs") then "\t" else string.rep(" ",width or 4)
    elseif width~=nil then config.indent=string.rep(" ",width) end
    if flat.line_width~=nil then config.formatting.line_width=integer("line_width",20,1000) end
    for _,pair in {{"argument_layout","multiline_calls"},{"table_layout","multiline_tables"}} do
        if flat[pair[1]]~=nil then
            local value=integer(pair[1],0,2)
            if value==1 then argument("compact layout is not implemented; automatic layout still obeys line width") end
            config.formatting[pair[2]]=value==2
        end
    end
    if flat.naming~=nil then
        if flat.naming~="snake_case" and flat.naming~="camelCase" and flat.naming~="PascalCase" and flat.naming~="roblox" then argument("unknown naming convention") end
        config.naming=flat.naming
    end
    if flat.annotation_verbosity~=nil then
        if flat.annotation_verbosity~="useful" and flat.annotation_verbosity~="extensive" then argument("unknown annotation verbosity") end
        config.typing.verbosity=flat.annotation_verbosity
    end
    return config
end

local diagnostic_metatable = {
    __tostring = function(value)
        local result = (value.stage or "bridge") .. ": " .. (value.message or "request failed")
        if value.proto ~= nil then result ..= " [proto " .. tostring(value.proto) .. "]" end
        if value.pc ~= nil then result ..= " [pc " .. tostring(value.pc) .. "]" end
        return result
    end,
}
local function raise(stage, message, fields)
    local value = fields or {}
    value.kind, value.stage, value.message = "luau_decompiler_error", stage, message
    error(setmetatable(value, diagnostic_metatable), 0)
end

function Adapter.encode_base64(bytes)
    assert(type(bytes) == "string", "base64 input must be a string")
    local output = table.create(math.ceil(#bytes / 3072))
    local block = table.create(1024)
    for chunk = 1, #bytes, 3072 do
        table.clear(block)
        for offset = chunk, math.min(chunk + 3071, #bytes), 3 do
            local a, b, c = string.byte(bytes, offset, offset + 2)
            local count = math.min(3, #bytes - offset + 1)
            b, c = b or 0, c or 0
            local first = math.floor(a / 4)
            local second = (a % 4) * 16 + math.floor(b / 16)
            local third = (b % 16) * 4 + math.floor(c / 64)
            local fourth = c % 64
            block[#block + 1] = string.sub(alphabet, first + 1, first + 1)
                .. string.sub(alphabet, second + 1, second + 1)
                .. (if count >= 2 then string.sub(alphabet, third + 1, third + 1) else "=")
                .. (if count >= 3 then string.sub(alphabet, fourth + 1, fourth + 1) else "=")
        end
        output[#output + 1] = table.concat(block)
    end
    return table.concat(output)
end

local function default_environment()
    if type(getgenv) == "function" then
        local ok, value = pcall(getgenv)
        if ok and type(value) == "table" then
            return value
        end
    end
    return _G
end

local function find_capabilities(options)
    local environment = options.environment or default_environment()
    assert(type(environment) == "table", "adapter environment must be a table")
    local function lookup(name)
        local value = rawget(environment, name)
        if value ~= nil then
            return value
        end
        return rawget(_G, name)
    end
    local request_function = options.request
    local request_name = if request_function then "custom" else nil
    if not request_function then
        local candidates = {
            { "request", lookup("request") or request },
            { "http_request", lookup("http_request") or http_request },
        }
        for _, name in { "syn", "http", "fluxus" } do
            local container = lookup(name)
            if type(container) == "table" then
                candidates[#candidates + 1] = { name .. ".request", rawget(container, "request") }
            end
        end
        for _, candidate in candidates do
            if type(candidate[2]) == "function" then
                request_name, request_function = candidate[1], candidate[2]
                break
            end
        end
    end
    local getter = options.get_bytecode
    local getter_name = if getter then "custom" else nil
    if not getter then
        local preferred = lookup("getscriptbytecode") or getscriptbytecode
        local fallback = lookup("dumpstring") or dumpstring
        if type(preferred) == "function" then
            getter, getter_name = preferred, "getscriptbytecode"
        elseif type(fallback) == "function" then
            getter, getter_name = fallback, "dumpstring"
        end
    end
    local function_getter=options.get_function_bytecode
    local function_getter_name=if function_getter then "custom" else nil
    if not function_getter then
        for _,candidate in {{"getfunctionbytecode",lookup("getfunctionbytecode") or getfunctionbytecode},{"dumpbytecode",lookup("dumpbytecode") or dumpbytecode}} do
            if type(candidate[2])=="function" then function_getter,function_getter_name=candidate[2],candidate[1];break end
        end
    end
    return environment, request_function, getter, {
        request = request_name,
        bytecode = getter_name,
        original_decompile = type(rawget(environment, "decompile")) == "function",
        normalization = options.normalizer_name or "upstream_identity",
        transport = "base64_json_v1",
        function_bytecode=function_getter_name,
        target_dispatch={script=type(getter)=="function",bytecode=true,func=type(function_getter)=="function"},
    },function_getter
end

function Adapter.capabilities(options)
    local _, _, _, capabilities = find_capabilities(options or {})
    return capabilities
end

local function check_endpoint(endpoint, allow_remote)
    assert(type(endpoint) == "string", "endpoint must be a string")
    local port = string.match(endpoint, "^http://127%.0%.0%.1:(%d+)/v1/decompile$")
        or string.match(endpoint, "^http://%[::1%]:(%d+)/v1/decompile$")
    if port and tonumber(port) >= 1 and tonumber(port) <= 65535 then return end
    if allow_remote then
        local host, remote_port = string.match(endpoint,"^https://([%w%.%-]+):(%d+)/v1/decompile$")
        if not host then host=string.match(endpoint,"^https://([%w%.%-]+)/v1/decompile$");remote_port="443" end
        local valid=host~=nil and #host<=253 and not string.find(host,"%.%.")
            and not string.find(host,"^%.") and not string.find(host,"%.$")
        if valid then
            for label in string.gmatch(host,"[^%.]+") do
                if #label>63 or not string.match(label,"^[%w]") or not string.match(label,"[%w]$") then valid=false end
            end
        end
        if valid and tonumber(remote_port)>=1 and tonumber(remote_port)<=65535 then return end
    end
    error("endpoint requires HTTP numeric loopback, or allow_remote=true with an HTTPS hostname and /v1/decompile path",2)
end

function Adapter.install(options)
    options = options or {}
    local environment, request_function, getter, capabilities, function_getter = find_capabilities(options)
    assert(type(request_function) == "function", "no supported executor HTTP request API is available")
    local profile_name=options.executor_profile or "generic"
    local profile=assert(profiles[profile_name],"unknown executor profile")
    capabilities.executor_profile=profile_name
    local base_config=copy_config(options.reconstruction_config or {})
    local token = options.token
    assert(type(token) == "string" and #token >= 32 and #token <= 256
        and not string.find(token, "[^!-~]"), "token must contain 32..256 printable ASCII bytes without spaces")
    local endpoint = options.endpoint or "http://127.0.0.1:7879/v1/decompile"
    check_endpoint(endpoint, options.allow_remote == true)
    local timeout = options.timeout or 10
    assert(type(timeout) == "number" and timeout >= 0.1 and timeout <= 120, "timeout must be 0.1..120 seconds")
    local max_bytes = options.max_bytes or 16 * 1024 * 1024
    assert(type(max_bytes) == "number" and max_bytes % 1 == 0 and max_bytes >= 1 and max_bytes <= 256 * 1024 * 1024,
        "max_bytes must be 1..268435456")
    local max_in_flight = options.max_in_flight or 2
    assert(type(max_in_flight) == "number" and max_in_flight % 1 == 0 and max_in_flight >= 1 and max_in_flight <= 16,
        "max_in_flight must be an integer in 1..16")
    local normalizer = options.normalizer
    if normalizer ~= nil then
        assert(type(normalizer) == "function" and type(options.normalizer_name) == "string"
            and #options.normalizer_name > 0, "custom normalization requires a function and explicit normalizer_name")
    end
    local spawn = options.spawn or (task and task.spawn)
    local wait = options.wait or (task and task.wait)
    local clock = options.clock or os.clock
    assert(type(spawn) == "function" and type(wait) == "function" and type(clock) == "function",
        "a yielding task scheduler is required for request deadlines")
    local encode, decode = options.json_encode, options.json_decode
    if not encode or not decode then
        local ok, http_service = pcall(function()
            return game:GetService("HttpService")
        end)
        assert(ok, "HttpService JSON support is unavailable; supply json_encode and json_decode")
        encode = encode or function(value) return http_service:JSONEncode(value) end
        decode = decode or function(value) return http_service:JSONDecode(value) end
    end
    assert(type(encode) == "function" and type(decode) == "function", "JSON codecs must be functions")

    local registry = rawget(environment, registry_key)
    if registry == nil then
        registry = { version = 2, records = {}, active = 0, serial = 0 }
        rawset(environment, registry_key, registry)
    end
    assert(type(registry) == "table" and registry.version == 2, "incompatible adapter registry")
    registry.serial += 1
    local record = { active = true, predecessor = rawget(environment, "decompile"), serial = registry.serial, pending = {} }
    local in_flight, sequence = 0, 0
    local nonce = {}
    local request_prefix = string.gsub(tostring(nonce), "[^%w]", "") .. "-" .. tostring(record.serial)
    local server_capabilities, handshake_at = nil, 0
    local capabilities_url = string.gsub(endpoint, "/decompile$", "/capabilities")
    local cancellation_url = string.gsub(endpoint, "/decompile$", "/requests/")

    local function request_json(method, url, body, request_timeout, request_id)
        local headers = { ["Authorization"] = "Bearer " .. token }
        if body ~= nil then headers["Content-Type"] = "application/json" end
        if request_id then headers["X-Request-Id"] = request_id end
        headers["X-Timeout-Ms"] = tostring(math.max(1, math.floor(request_timeout * 1000)))
        local ok, response = pcall(request_function, { Url = url, Method = method, Headers = headers, Body = body, Timeout = request_timeout })
        if not ok then raise("transport", "localhost bridge transport failed", { request_id = request_id }) end
        if type(response) ~= "table" then raise("transport", "executor HTTP API returned a non-table response") end
        local status = response.StatusCode or response.Status
        if type(status) ~= "number" or type(response.Body) ~= "string" then raise("transport", "response lacks StatusCode or Body") end
        local decoded_ok, decoded = pcall(decode, response.Body)
        if not decoded_ok or type(decoded) ~= "table" then raise("protocol", "bridge returned invalid JSON", { status = status }) end
        if status == 422 and decoded.complete==true and type(decoded.source)=="string" and type(decoded.validation)=="table" then
            decoded.http_status=status
            return decoded
        end
        if status ~= 200 then
            local value = if type(decoded.error) == "table" then decoded.error else {}
            value.status, value.request_id = status, request_id
            raise(value.stage or "http", value.message or "bridge request failed", value)
        end
        return decoded
    end

    local function handshake(request_timeout)
        if options.handshake == false then return nil end
        if server_capabilities and clock() - handshake_at < 60 then return server_capabilities end
        local value = request_json("GET", capabilities_url, nil, request_timeout, nil)
        if value.protocol_version ~= 2 or type(value.implementation) ~= "table" or type(value.implementation.profiles) ~= "table" then
            raise("compatibility", "bridge does not support protocol version 2")
        end
        server_capabilities, handshake_at = value, clock()
        capabilities.server = value
        return value
    end

    local function cancel(request_id)
        pcall(spawn, function()
            pcall(request_json, "DELETE", cancellation_url .. request_id, nil, math.min(timeout, 1), nil)
        end)
    end

    local function request_checkpoint(request_state, request_id)
        if not record.active or request_state.cancelled then
            raise("cancelled", "request was cancelled or its adapter was restored", {request_id=request_id})
        end
        if clock() >= request_state.deadline then
            request_state.cancelled = true
            raise("deadline", "adapter request deadline exceeded", {request_id=request_id})
        end
    end

    local function fetch(bytecode, target, request_timeout, request_id, request_state, reconstruction_config)
        request_checkpoint(request_state, request_id)
        assert(record.active, "decompile adapter has been restored")
        assert(type(bytecode) == "string", "bytecode getter returned a non-string value")
        assert(#bytecode > 0 and #bytecode <= max_bytes, "bytecode is empty or exceeds max_bytes")
        if normalizer then
            bytecode = normalizer(bytecode, target)
            assert(type(bytecode) == "string" and #bytecode > 0 and #bytecode <= max_bytes,
                "normalizer returned invalid or oversized bytecode")
        end
        local version = string.byte(bytecode, 1)
        local server = handshake(request_timeout)
        local selected = (reconstruction_config and reconstruction_config.profile) or options.profile or "auto"
        local selected_encoding=(reconstruction_config and reconstruction_config.bytecode_encoding) or options.bytecode_encoding or "auto"
        if server then
            if reconstruction_config and next(reconstruction_config)~=nil and not (server.features and server.features.per_request_settings==true) then
                raise("compatibility", "service does not advertise per-request reconstruction settings")
            end
            local matched = false
            for _, profile in server.implementation.profiles do
                if profile.bytecode_version == version and (selected == "auto" or selected == profile.id) then matched = true; break end
            end
            if not matched then raise("compatibility", "bytecode version/profile is not advertised by the service", { bytecode_version = version, profile = selected }) end
            local encoding_found = false
            for _, encoding in server.encodings or {} do if encoding == selected_encoding then encoding_found = true end end
            if not encoding_found then raise("compatibility", "bytecode encoding is not advertised by the service") end
        end
        request_checkpoint(request_state, request_id)
        local body = encode({ bytecode_base64 = Adapter.encode_base64(bytecode), profile = selected,
            bytecode_encoding = selected_encoding, control_flow = options.control_flow,
            vector_constructor = options.vector_constructor, reconstruction_config=if reconstruction_config and next(reconstruction_config)~=nil then reconstruction_config else nil })
        request_checkpoint(request_state, request_id)
        local remaining_timeout = math.max(0.001, math.min(request_timeout, request_state.deadline-clock()))
        local decoded = request_json("POST", endpoint, body, remaining_timeout, request_id)
        assert(type(decoded.source) == "string", "bridge response lacks source")
        if decoded.complete ~= true or (decoded.quality ~= "structured" and decoded.quality ~= "dispatcher") then
            raise("incomplete", "bridge did not report complete reconstruction", { quality = decoded.quality })
        end
        if options.allow_dispatcher == false and decoded.quality == "dispatcher" then raise("quality", "dispatcher output was disabled", { quality = decoded.quality }) end
        decoded.adapter_requested_policy = reconstruction_config and reconstruction_config.output_policy
        return decoded
    end

    local function run(operation, requested_timeout)
        assert(record.active, "decompile adapter has been restored")
        local deadline_seconds = requested_timeout or timeout
        assert(type(deadline_seconds) == "number" and deadline_seconds >= 0.1 and deadline_seconds <= 120,
            "timeout must be 0.1..120 seconds")
        assert(in_flight < max_in_flight, "decompile adapter has reached its in-flight request limit")
        sequence += 1
        local request_id = request_prefix .. "-" .. tostring(sequence)
        local started = clock()
        local request_state = {cancelled=false, deadline=started+deadline_seconds}
        record.pending[request_id] = request_state
        in_flight += 1
        local done, success, value = false, false, nil
        local spawned, spawn_error = pcall(spawn, function()
            success, value = pcall(operation, deadline_seconds, request_id, request_state)
            record.pending[request_id] = nil
            in_flight -= 1
            done = true
        end)
        if not spawned then
            if not done then
                in_flight -= 1
                record.pending[request_id] = nil
            end
            error("decompile scheduler failed: " .. tostring(spawn_error), 2)
        end
        while not done and clock() - started < deadline_seconds do
            wait(math.min(0.01, deadline_seconds))
        end
        if not done or clock() >= request_state.deadline then
            request_state.cancelled = true
            local cancel_requested = options.cancel_on_timeout ~= false
            if cancel_requested then cancel(request_id) end
            raise("deadline", "bridge deadline exceeded", { request_id = request_id, cancellation_requested=cancel_requested })
        end
        if request_state.cancelled or not record.active then raise("cancelled", "adapter was restored before completion", {request_id=request_id}) end
        if not success then
            error(value, 0)
        end
        return value
    end

    local function classify(target)
        if options.classify_target then return options.classify_target(target) end
        if type(target)=="string" then return "bytecode" end
        if type(target)=="function" then return "func" end
        if type(typeof)=="function" and typeof(target)=="Instance" then
            if not target:IsA("LuaSourceContainer") then argument("target must be a script, raw bytecode, or supported Luau function") end
            if target.ClassName=="Script" and target.RunContext~=Enum.RunContext.Client then argument("server-running Script bytecode is not a client decompilation target") end
            return "script"
        end
        argument("unsupported target type "..type(target))
    end
    local function detailed(target, native_options, requested_timeout, canonical)
        local kind=classify(target)
        if not canonical and not profile[kind] then argument("target type is not documented by executor profile "..profile_name) end
        local settings=Adapter.map_options(native_options,if canonical then "generic" else profile_name,base_config)
        if kind=="func" then settings.entry_output="function" end
        return run(function(request_timeout, request_id, request_state)
            assert(record.active, "decompile adapter has been restored")
            local bytecode=target
            if kind~="bytecode" then
                local selected_getter=if kind=="func" then function_getter else getter
                if type(selected_getter)~="function" then argument("no documented bytecode getter is available for "..kind) end
                local ok,value=pcall(selected_getter,target)
                if not ok then error(value,0) end
                bytecode=value
            end
            return fetch(bytecode, target, request_timeout, request_id, request_state,settings)
        end, requested_timeout)
    end
    local function source_of(result)
        local validation=result.validation
        local verified=result.adapter_requested_policy=="verified_typed" or (validation and validation.output_policy=="verified_typed")
        local verified_passed=validation and validation.required_passed==true and validation.syntax=="passed"
            and validation.compilation=="passed" and validation.strict_analysis=="passed"
            and validation.meaningful_typing and validation.meaningful_typing.passed==true
        if result.http_status==422 or (verified and not verified_passed) or (validation and (validation.required_passed==false or validation.syntax=="failed" or validation.compilation=="failed")) then
            raise("quality","required source/strict-analysis quality gate failed",{source=result.source,baseline_source=result.baseline_source,validation=result.validation})
        end
        return result.source
    end
    local function override(target, native_options) return source_of(detailed(target,native_options)) end
    record.override = override
    record.nonce = nonce
    registry.records[override] = record
    registry.active += 1
    rawset(environment, "decompile", override)
    assert(rawget(environment, "decompile") == override, "executor environment rejected the decompile override")

    return {
        capabilities = capabilities,
        decompile = override,
        decompile_detailed = detailed,
        decompile_with_timeout=function(target,canonical_options,seconds) return source_of(detailed(target,canonical_options,seconds,true)) end,
        decompile_detailed_with_timeout=function(target,canonical_options,seconds) return detailed(target,canonical_options,seconds,true) end,
        decompile_canonical=function(target,canonical_options) return source_of(detailed(target,canonical_options,nil,true)) end,
        decompile_canonical_detailed=function(target,canonical_options) return detailed(target,canonical_options,nil,true) end,
        handshake = function() return run(function(request_timeout) return handshake(request_timeout) end, timeout) end,
        decompile_bytecode = function(bytecode, requested_timeout)
            return source_of(run(function(request_timeout, request_id, request_state) return fetch(bytecode, nil, request_timeout, request_id, request_state,base_config) end, requested_timeout))
        end,
        decompile_bytecode_detailed = function(bytecode, requested_timeout)
            return run(function(request_timeout, request_id, request_state) return fetch(bytecode, nil, request_timeout, request_id, request_state,base_config) end, requested_timeout)
        end,
        restore = function()
            if not record.active then
                return false, "adapter is already restored"
            end
            record.active = false
            registry.active -= 1
            for request_id, request_state in record.pending do
                request_state.cancelled = true
                if options.cancel_on_restore ~= false then cancel(request_id) end
            end
            local restored = rawget(environment, "decompile") == override
            if restored then
                local previous = record.predecessor
                while type(previous) == "function" and registry.records[previous] and not registry.records[previous].active do
                    previous = registry.records[previous].predecessor
                end
                rawset(environment, "decompile", previous)
            end
            if registry.active == 0 and rawget(environment, registry_key) == registry then rawset(environment, registry_key, nil) end
            return true, if restored then "restored" else "deactivated underneath a later replacement"
        end,
    }
end

return Adapter
