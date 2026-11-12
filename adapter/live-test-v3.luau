

local Test = {}

local function u32(value)
    local bytes = buffer.create(4)
    buffer.writeu32(bytes, 0, value)
    return buffer.tostring(bytes)
end

local function primitive(value, unsupported)
    local kind = type(value)
    if kind == "nil" then return string.char(0) end
    if kind == "boolean" then return string.char(1, if value then 1 else 0) end
    if kind == "number" then
        local bytes = buffer.create(8)
        buffer.writef64(bytes, 0, value)
        return string.char(2) .. buffer.tostring(bytes)
    end
    if kind == "string" then return string.char(3) .. u32(#value) .. value end
    if unsupported then unsupported() end
    error("live probe requires an explicit observation for " .. kind, 0)
end

local function tuple(values, unsupported)
    local parts = table.create(values.n + 1)
    parts[1] = u32(values.n)
    for index = 1, values.n do parts[index + 1] = primitive(values[index], unsupported) end
    return table.concat(parts)
end

local function observe(fn, seed)
    local effects = {}
    local supported = true
    local function unsupported() supported = false end
    local environment = setmetatable({}, { __index = getfenv(fn) })
    for name, kind in { print = 1, warn = 2 } do
        environment[name] = function(...)
            effects[#effects + 1] = string.char(kind) .. tuple(table.pack(...), unsupported)
            for index = 1, select("#", ...) do tostring(select(index, ...)) end
        end
    end
    setfenv(fn, environment)
    local result = table.pack(pcall(fn, seed))
    assert(supported, "live oracle cannot verify an unsupported effect value")
    local values = table.create(math.max(0, result.n - 1))
    values.n = result.n - 1
    for index = 2, result.n do values[index - 1] = result[index] end
    return "LOBS" .. string.char(1, 1) .. u32(#effects) .. table.concat(effects)
        .. string.char(if result[1] then 0 else 1) .. tuple(values)
end

local function oracle_conformance()
    local function frame(source) return observe(assert(loadstring(source))) end
    assert(frame("return 1") ~= frame('return "1"'))
    assert(frame("return nil") ~= frame('return "nil"'))
    assert(frame('return "a", "b"') ~= frame('return "a\\tb"'))
    assert(frame('return string.char(255)') ~= frame('return string.char(254)'))
    assert(frame('error(false, 0)') ~= frame('error("false", 0)'))
    assert(frame("print(1)") ~= frame('print("1")'))
    assert(frame('print("a"); warn("b")') ~= frame('warn("a"); print("b")'))
    assert(not pcall(frame, "print({}); return 1"), "unsupported print was counted as an ordinary error")
    assert(not pcall(frame, "pcall(print, {}); return 1"), "caught unsupported print was counted as complete")
    assert(not pcall(frame, "return {}"), "opaque result was counted as complete")
    return { negative_collision_pairs = 7, unsupported_observations_rejected = 3, passed = true }
end
Test.oracle_conformance = oracle_conformance
Test.observe = observe

local function observe_empty(fn)
    local values = table.pack(fn())
    assert(values.n == 1 and type(values[1]) == "table", "native model return shape differs")
    local result = table.pack(values.n, type(values[1]), next(values[1]) == nil,
        getmetatable(values[1]) == nil, rawequal(values[1], fn()))
    return "LOBS" .. string.char(1, 1) .. u32(0) .. string.char(0) .. tuple(result)
end

function Test.run(Adapter, options, native_module, fixtures, repetitions)
    repetitions = repetitions or 32
    assert(repetitions >= 1 and repetitions <= 1000 and repetitions % 1 == 0)
    local environment = options.environment or getgenv()
    local original = rawget(environment, "decompile")
    assert(rawget(environment, "_LUAU_DECOMPILER_ADAPTER_CHAIN_V2") == nil,
        "restore preexisting test adapters before running this fixture")
    local installed = {}
    local function install(encoding)
        local config = table.clone(options)
        config.environment, config.bytecode_encoding = environment, encoding
        config.executor_profile = "madium"
        local controller = Adapter.install(config)
        installed[#installed + 1] = controller
        return controller
    end
    local report = { schema = 3, decompiler_version = "0.3.0", runtime = version(), executor = { identifyexecutor() },
        validation_id = options.validation_id, oracle_conformance = oracle_conformance(),
        oracle_protocol = "LOBS/1", comparisons = {}, settings_comparisons = {}, latency_repetitions = repetitions,
        distinct_known_source_native_programs = 0, distinct_unknown_source_native_models = 1,
        distinct_supplied_bytecode_programs = #fixtures, controlled_place_native_programs = 0 }
    local ok, failure = pcall(function()
        assert(native_module and native_module:IsA("ModuleScript") and native_module:GetFullName() == "ReplicatedStorage.SocketTypes", "explicit native target changed")
        local raw = assert(getscriptbytecode(native_module))
        local raw_hex = (string.gsub(raw, ".", function(c) return string.format("%02x", string.byte(c)) end))
        assert(options.expected_native_hex == "0e0300000128010000010a0004a3000000ff0000000000000082000200000001000118005a00000100000000000a00")
        assert(raw_hex == options.expected_native_hex and #raw == 47, "native packet differs; stop before getscriptclosure or execution")

        local original_fn = assert(getscriptclosure(native_module))
        local native = install("roblox_opcode227")
        report.native_api = {}
        for id, invoke in {
            numeric_second_argument = function() return native.decompile(native_module, 4) end,
            native_options_table = function() return native.decompile(native_module, {}) end,
            function_target = function() return native.decompile(function() return 1 end) end,
            raw_native_target = function() return native.decompile(raw) end,
        } do
            local accepted, diagnostic = pcall(invoke)
            assert(not accepted, "unsupported Madium native contract was accepted: " .. id)
            report.native_api[id] = { rejected = true, error = tostring(diagnostic) }
        end
        local expected = observe_empty(original_fn)
        local latencies = buffer.create(repetitions * 8)
        local first_source, first_result
        local native_observations = {}
        for index = 0, repetitions do
            local started = os.clock()
            local result = native.decompile_detailed(native_module)
            assert(result.complete == true)
            assert(result.validation and result.validation.syntax == "passed" and result.validation.compilation == "passed" and result.validation.required_passed)
            local elapsed = (os.clock() - started) * 1000
            if index == 0 then
                report.cold_adapter_ms = elapsed
                first_source, first_result = result.source, result
            else
                buffer.writef64(latencies, (index - 1) * 8, elapsed)
                assert(result.source == first_source, "native output changed across repetitions")
            end
            local actual = observe_empty(assert(loadstring(result.source, "live-native-rebuilt")))
            assert(expected == actual, "typed native observation mismatch")
            native_observations[#native_observations + 1] = Adapter.encode_base64(actual)
        end
        report.native = { input_hex = (string.gsub(raw, ".", function(c) return string.format("%02x", string.byte(c)) end)),
            source = first_source, complete = first_result.complete, quality = first_result.quality,
            profile = first_result.profile, cpu_pool_threads = first_result.stats.cpu_pool_threads,
            validation = first_result.validation, type_report = first_result.type_report,
            source_provenance = "unknown original source; independently reviewed exact serialized empty-table model",
            path = native_module:GetFullName(), representation = "getscriptbytecode exact47; explicit opcode227 normalization",
            typed_comparisons = repetitions + 1, expected = Adapter.encode_base64(expected),
            observations = native_observations }
        report.warm_adapter_ms_f64_le_base64 = Adapter.encode_base64(buffer.tostring(latencies))
        report.capabilities = native.capabilities.server
        local provided = install("upstream")
        local first_provided
        for _, fixture in fixtures do
            local result = provided.decompile_canonical_detailed(fixture.bytecode)
            assert(result.complete == true)
            assert(result.validation and result.validation.syntax == "passed" and result.validation.compilation == "passed" and result.validation.required_passed)
            if not first_provided then first_provided = result end
            for _, seed in { -3, 0, 1, 7, 29 } do
                local expected_frame = observe(assert(loadstring(fixture.source, "live-original")), seed)
                local actual_frame = observe(assert(loadstring(result.source, "live-rebuilt")), seed)
                assert(expected_frame == actual_frame, "typed fixture mismatch: " .. fixture.id .. "/" .. seed)
                report.comparisons[#report.comparisons + 1] = { id = fixture.id, seed = seed,
                    source_sha256 = fixture.source_sha256, bytecode_sha256 = fixture.bytecode_sha256,
                    expected = Adapter.encode_base64(expected_frame), actual = Adapter.encode_base64(actual_frame),
                    quality = result.quality, complete = result.complete, validation = result.validation }
            end
        end
        local settings = {indent="  ",naming="camelCase",typing={mode="off"},validation={mode="off"}}
        local fixture = assert(fixtures[1])
        local variant = provided.decompile_canonical_detailed(fixture.bytecode, settings)
        assert(variant.complete and variant.source ~= first_provided.source and variant.validation.strict_analysis == "not_run")
        assert(variant.type_report.emitted_annotations == 0)
        report.settings = {fixture_id=fixture.id,configuration=settings,source_changed=true,source=variant.source,
            baseline_source=first_provided.source,validation=variant.validation,type_report=variant.type_report}
        for _, seed in {-3,0,1,7,29} do
            local expected_frame = observe(assert(loadstring(fixture.source,"live-settings-original")),seed)
            local actual_frame = observe(assert(loadstring(variant.source,"live-settings-rebuilt")),seed)
            assert(expected_frame == actual_frame,"settings altered typed behavior")
            report.settings_comparisons[#report.settings_comparisons+1]={id=fixture.id,seed=seed,source_sha256=fixture.source_sha256,
                bytecode_sha256=fixture.bytecode_sha256,expected=Adapter.encode_base64(expected_frame),actual=Adapter.encode_base64(actual_frame),complete=true,quality=variant.quality}
        end
        local accepted, diagnostic = pcall(provided.decompile_canonical_detailed,fixture.bytecode..string.char(0))
        assert(not accepted and type(diagnostic)=="table" and diagnostic.stage=="decode" and diagnostic.status==422
            and diagnostic.offset==#fixture.bytecode and type(diagnostic.request_id)=="string","structured malformed-bytecode diagnostic was lost")
        report.malformed_diagnostic=diagnostic
        local newer = install("upstream")
        assert(provided.restore() and rawget(environment, "decompile") == newer.decompile)
        assert(newer.restore() and rawget(environment, "decompile") == native.decompile)
        report.out_of_order_restore = true
    end)
    for index = #installed, 1, -1 do installed[index].restore() end
    report.raw_restored = rawget(environment, "decompile") == original
    report.registry_cleared = rawget(environment, "_LUAU_DECOMPILER_ADAPTER_CHAIN_V2") == nil
    report.ok = ok and report.raw_restored and report.registry_cleared
    if not ok then
        report.error = if type(failure) == "table" then { stage = failure.stage, message = failure.message,
            proto = failure.proto, pc = failure.pc, offset=failure.offset,status = failure.status } else tostring(failure)
    end
    return report
end

return Test
