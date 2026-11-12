local Adapter = require("./decompile")
assert(Adapter.encode_base64("") == "")
assert(Adapter.encode_base64("f") == "Zg==")
assert(Adapter.encode_base64("fo") == "Zm8=")
assert(Adapter.encode_base64("foo") == "Zm9v")
assert(Adapter.encode_base64(string.char(0, 1, 255)) == "AAH/")
assert(Adapter.encode_base64(string.rep("foo", 2049)) == string.rep("Zm9v", 2049))
assert(Adapter.encode_base64(string.rep("foo", 1024) .. "f") == string.rep("Zm9v", 1024) .. "Zg==")

local old = function() return "original" end
local environment = { decompile = old }
local request_count = 0
local controller = Adapter.install({
    environment = environment,
    handshake = false,
    classify_target = function() return "script" end, token = string.rep("t", 32),
    get_bytecode = function(target)
        assert(target == "script")
        return string.char(6, 0, 255)
    end,
    request = function(request)
        request_count += 1
        assert(request.Url == "http://127.0.0.1:7879/v1/decompile")
        assert(request.Method == "POST")
        assert(request.Headers.Authorization == "Bearer " .. string.rep("t", 32))
        assert(request.Body == "encoded:BgD/")
        return { StatusCode = 200, Body = "success" }
    end,
    json_encode = function(value) return "encoded:" .. value.bytecode_base64 end,
    json_decode = function(value)
        assert(value == "success")
        return { source = "return 1\n", complete = true, quality = "structured" }
    end,
    spawn = function(callback) callback() end,
    wait = function() error("immediate mock should not yield") end,
})
assert(controller.capabilities.request == "custom")
assert(environment.decompile("script") == "return 1\n")
assert(controller.decompile_bytecode(string.char(6, 0, 255)) == "return 1\n")
assert(request_count == 2)
assert(controller.restore())
assert(environment.decompile == old)
assert(not controller.restore())
assert(not pcall(controller.decompile, "script"))

local ticks = 0
local pending = {}
local timeout_environment = {}
local timed = Adapter.install({
    environment = timeout_environment,
    handshake = false,
    cancel_on_timeout = false,
    classify_target = function() return "script" end, token = string.rep("t", 32),
    timeout = 0.1,
    max_in_flight = 1,
    get_bytecode = function() return string.char(6) end,
    request = function() return { StatusCode = 200, Body = "success" } end,
    json_encode = function() return "{}" end,
    json_decode = function() return { source = "return 2", complete = true, quality = "structured" } end,
    spawn = function(callback) pending[#pending + 1] = callback end,
    wait = function(seconds) ticks += seconds end,
    clock = function() return ticks end,
})
local ok, message = pcall(timeout_environment.decompile, "script")
assert(not ok and type(message) == "table" and message.stage == "deadline")
assert(not pcall(timeout_environment.decompile, "script"))
assert(#pending == 1)
pending[1]()
assert(timed.restore())
assert(timeout_environment.decompile == nil)

local invalid = table.clone({
    classify_target = function() return "script" end, token = string.rep("t", 32),
    request = function() end,
    get_bytecode = function() end,
    endpoint = "http://example.com:7879/v1/decompile",
})
assert(not pcall(Adapter.install, invalid))

local function mock_options(target_environment)
    return {
        environment = target_environment, classify_target = function() return "script" end, token = string.rep("t", 32), handshake = false,
        get_bytecode = function() return string.char(6) end,
        request = function() return { StatusCode = 200, Body = "ok" } end,
        json_encode = function() return "{}" end,
        json_decode = function() return { source = "return 6", complete = true, quality = "structured" } end,
        spawn = function(callback) callback() end, wait = function() end,
    }
end
local stacked = { decompile = old }
local first = Adapter.install(mock_options(stacked))
local second = Adapter.install(mock_options(stacked))
assert(first.restore())
assert(stacked.decompile == second.decompile)
assert(second.restore())
assert(stacked.decompile == old)
assert(rawget(stacked, "_LUAU_DECOMPILER_ADAPTER_CHAIN_V2") == nil)
local third = Adapter.install(mock_options(stacked))
local fourth = Adapter.install(mock_options(stacked))
assert(fourth.restore() and stacked.decompile == third.decompile)
assert(third.restore() and stacked.decompile == old)
local fifth = Adapter.install(mock_options(stacked))
local external = function() return "external" end
stacked.decompile = external
assert(fifth.restore() and stacked.decompile == external)

local strict_options = mock_options({})
strict_options.handshake = true
strict_options.json_decode = function(value)
    if value == "capabilities" then return { protocol_version = 2, implementation = {profiles = {{id="luau-v6",bytecode_version=6}}}, encodings={"auto","upstream"} } end
    return { error = {stage="structure", message="exact diagnostic", proto=3, pc=17, offset=99} }
end
local methods = {}
strict_options.request = function(request)
    methods[#methods+1] = request.Method
    if request.Method == "GET" then return {StatusCode=200,Body="capabilities"} end
    assert(type(request.Headers["X-Request-Id"]) == "string")
    return {StatusCode=422,Body="failure"}
end
local strict = Adapter.install(strict_options)
local strict_ok, diagnostic = pcall(strict.decompile_bytecode, string.char(6))
assert(not strict_ok and type(diagnostic)=="table")
assert(diagnostic.stage=="structure" and diagnostic.proto==3 and diagnostic.pc==17 and diagnostic.offset==99 and diagnostic.status==422)
assert(methods[1]=="GET" and methods[2]=="POST")
assert(strict.capabilities.server.protocol_version==2)
assert(strict.restore())

local incomplete_options = mock_options({})
incomplete_options.json_decode = function() return {source="-- missing logic",complete=false,quality="structured"} end
local incomplete = Adapter.install(incomplete_options)
local incomplete_ok, incomplete_error = pcall(incomplete.decompile_bytecode,string.char(6))
assert(not incomplete_ok and type(incomplete_error)=="table" and incomplete_error.stage=="incomplete")
assert(incomplete.restore())

local cancellation_options = mock_options({})
local cancellation_pending, cancelled_id = {}, nil
local cancellation_ticks = 0
cancellation_options.timeout = 0.1
cancellation_options.cancel_on_restore = false
cancellation_options.spawn = function(callback) cancellation_pending[#cancellation_pending+1]=callback end
cancellation_options.clock = function() return cancellation_ticks end
cancellation_options.wait = function(value) cancellation_ticks += value end
cancellation_options.request = function(request)
    if request.Method=="DELETE" then cancelled_id=string.match(request.Url,"/requests/(.+)$") end
    return {StatusCode=200,Body="ok"}
end
local cancellation = Adapter.install(cancellation_options)
local cancellation_ok, cancellation_error = pcall(cancellation.decompile_bytecode,string.char(6))
assert(not cancellation_ok and cancellation_error.stage=="deadline" and #cancellation_pending==2)
cancellation_pending[2]()
assert(cancelled_id==cancellation_error.request_id)
cancellation_pending[1]()
assert(cancellation.restore())

local restore_during_get
local restore_options = mock_options({decompile=old})
restore_options.handshake=true
local restore_methods={}
restore_options.json_decode=function(value)
    if value=="caps" then return {protocol_version=2,implementation={profiles={{id="luau-v6",bytecode_version=6}}},encodings={"auto","upstream"}} end
    return {cancelled=true}
end
restore_options.request=function(request)
    restore_methods[#restore_methods+1]=request.Method
    if request.Method=="GET" then assert(restore_during_get.restore());return {StatusCode=200,Body="caps"} end
    assert(request.Method=="DELETE","restored request must never start POST")
    return {StatusCode=200,Body="cancel"}
end
restore_during_get=Adapter.install(restore_options)
local restored_ok,restored_error=pcall(restore_during_get.decompile_bytecode,string.char(6))
assert(not restored_ok and restored_error.stage=="cancelled")
assert(restore_options.environment.decompile==old)
for _,method in restore_methods do assert(method~="POST") end

local deadline_options=mock_options({})
deadline_options.handshake=true
local deadline_ticks,deadline_posts=0,0
deadline_options.clock=function() return deadline_ticks end
deadline_options.json_decode=restore_options.json_decode
deadline_options.request=function(request)
    if request.Method=="GET" then deadline_ticks=2;return {StatusCode=200,Body="caps"} end
    if request.Method=="POST" then deadline_posts+=1 end
    return {StatusCode=200,Body="cancel"}
end
local deadline_adapter=Adapter.install(deadline_options)
local deadline_ok,deadline_error=pcall(deadline_adapter.decompile_bytecode,string.char(6),1)
assert(not deadline_ok and deadline_error.stage=="deadline" and deadline_posts==0)
assert(deadline_adapter.restore())
print("adapter mock tests passed")
