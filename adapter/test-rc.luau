local Adapter=require("./decompile")
local bytes=string.char(14,3,0,255)
local function options()
    return {environment={},handshake=false,token=string.rep("t",32),
        request=function() return {StatusCode=200,Body="ok"} end,
        json_encode=function() return "json" end,
        json_decode=function() return {source="return 42",complete=true,quality="structured",validation={required_passed=true}} end,
        spawn=function(callback) callback() end,
        wait=function() error("synchronous mock yielded") end}
end

local original_install_environment=getfenv(Adapter.install)
local original_typeof=typeof
local local_target={ClassName="LocalScript",RunContext="Legacy"}
local server_target={ClassName="Script",RunContext="Legacy"}
local client_target={ClassName="Script",RunContext="Client"}
for _,target in {local_target,server_target,client_target} do
    target.IsA=function(self,name)
        return name==self.ClassName or name=="LuaSourceContainer" or name=="BaseScript" or name=="Script"
    end
end
local install_environment=setmetatable({Enum={RunContext={Client="Client"}},typeof=function(value)
    if value==local_target or value==server_target or value==client_target then return "Instance" end
    return original_typeof(value)
end},{__index=original_install_environment})
setfenv(Adapter.install,install_environment)
local instance_controller
local instance_ok,instance_failure=pcall(function()
    local config=options()
    config.executor_profile="madium"
    local getter_calls=0
    config.get_bytecode=function(target)
        assert(target==local_target or target==client_target)
        getter_calls+=1
        return bytes
    end
    instance_controller=Adapter.install(config)
    assert(type(instance_controller.decompile(local_target))=="string")
    assert(not pcall(instance_controller.decompile,server_target))
    assert(type(instance_controller.decompile(client_target))=="string")
    assert(getter_calls==2)
end)
if instance_controller then instance_controller.restore() end
setfenv(Adapter.install,original_install_environment)
assert(instance_ok,instance_failure)

for _,encoding in {"auto","upstream"} do
    local config=options()
    local encoded
    config.bytecode_encoding=if encoding=="auto" then nil else encoding
    config.json_encode=function(value)encoded=value;return "json"end
    local controller=Adapter.install(config)
    controller.decompile_bytecode(bytes)
    assert(encoded.bytecode_encoding==encoding)
    assert(controller.restore())
end

local cyclic={}
cyclic.Formatter=cyclic
assert(not pcall(Adapter.map_options,cyclic,"volt"))
local a,b={},{}
a.Formatter=b;b.DecompilerOptions=a
assert(not pcall(Adapter.map_options,a,"lynx"))
local deep={IndentWidth=2}
for _=1,20 do deep={Formatter=deep} end
assert(not pcall(Adapter.map_options,deep,"volt"))
local wide={}
for n=1,8200 do wide["name"..n]=true end
assert(not pcall(Adapter.map_options,wide,"generic"))
assert(not pcall(Adapter.map_options,{Formatter={IndentWidth=2},FORMATTER={IndentWidth=4}},"volt"))
assert(not pcall(Adapter.map_options,{Formatter={[1]=true}},"volt"))
assert(not pcall(Adapter.map_options,{typing={mode=string.rep("x",2*1024*1024)}},"generic"))
assert(not pcall(Adapter.map_options,{typing={mode=function()end}},"generic"))
local shared={IndentWidth=3}
assert(Adapter.map_options({Formatter=shared,DecompilerOptions={Formatter=shared}},"lynx").indent=="   ")

for _,pair in {{false,true},{true,false},{false,false},{true,true}} do
    local config=options()
    local ticks,pending,deletes=0,{},0
    config.timeout=0.1
    config.cancel_on_timeout=pair[1]
    config.cancel_on_restore=pair[2]
    config.spawn=function(callback) pending[#pending+1]=callback end
    config.clock=function()return ticks end
    config.wait=function(seconds)ticks+=seconds end
    config.request=function(request)
        assert(request.Method=="DELETE")
        deletes+=1
        return {StatusCode=200,Body="ok"}
    end
    local controller=Adapter.install(config)
    local ok,diagnostic=pcall(controller.decompile_bytecode,bytes)
    assert(not ok and diagnostic.stage=="deadline" and diagnostic.cancellation_requested==pair[1])
    assert(#pending==1+(if pair[1] then 1 else 0))
    assert(controller.restore())
    assert(#pending==1+(if pair[1] then 1 else 0)+(if pair[2] then 1 else 0))
    for _,callback in pending do callback() end
    assert(deletes==(if pair[1] then 1 else 0)+(if pair[2] then 1 else 0))
    assert(config.environment.decompile==nil)
end

local report={source="local value: any = 42\nreturn value",baseline_source="return 42",complete=true,quality="structured",
    validation={output_policy="verified_typed",required_passed=false,syntax="passed",compilation="passed",strict_analysis="passed",meaningful_typing={passed=false}}}
local quality_options=options()
quality_options.request=function()return {StatusCode=422,Body="quality"}end
quality_options.json_decode=function()return report end
local quality=Adapter.install(quality_options)
local ok,failure=pcall(quality.decompile,bytes,{output_policy="verified_typed"})
assert(not ok and failure.stage=="quality" and failure.source==report.source and failure.baseline_source==report.baseline_source)
assert(quality.decompile_detailed(bytes,{output_policy="verified_typed"}).http_status==422)
assert(quality.restore())

local inconsistent_options=options()
inconsistent_options.request=function()return {StatusCode=422,Body="quality"}end
local inconsistent=Adapter.install(inconsistent_options)
assert(inconsistent.decompile_detailed(bytes).http_status==422)
assert(not pcall(inconsistent.decompile,bytes))
assert(inconsistent.restore())

local missing=options()
missing.json_decode=function()return {source="return 42",complete=true,quality="structured"}end
local no_gate=Adapter.install(missing)
assert(not pcall(no_gate.decompile,bytes,{output_policy="verified_typed"}))
assert(no_gate.restore())

local verified_options=options()
verified_options.json_decode=function()return {source="local value: number = 42\nreturn value",complete=true,quality="structured",
    validation={output_policy="verified_typed",required_passed=true,syntax="passed",compilation="passed",strict_analysis="passed",meaningful_typing={passed=true}}}end
local verified=Adapter.install(verified_options)
assert(type(verified.decompile(bytes,{output_policy="verified_typed"}))=="string")
assert(verified.restore())

local function_options=options()
local captured
function_options.get_function_bytecode=function(target)assert(type(target)=="function");return bytes end
function_options.json_encode=function(value)captured=value;return "json"end
local function_adapter=Adapter.install(function_options)
assert(function_adapter.decompile(function(a,...)return a,...end)=="return 42")
assert(captured.reconstruction_config.entry_output=="function")
assert(function_adapter.restore())

for _,endpoint in {"http://192.0.2.1:7879/v1/decompile","https://user@example.test/v1/decompile","https://example.test/v1/decompile?token=x","https://example..test/v1/decompile","https://example.test:70000/v1/decompile"} do
    local remote=options();remote.endpoint=endpoint;remote.allow_remote=true
    assert(not pcall(Adapter.install,remote))
end
local unapproved=options();unapproved.endpoint="https://example.test/v1/decompile"
assert(not pcall(Adapter.install,unapproved))
for _,endpoint in {"https://example.test/v1/decompile","https://example.test:8443/v1/decompile"} do
    local remote=options();remote.endpoint=endpoint;remote.allow_remote=true
    assert(Adapter.install(remote).restore())
end

print("release-candidate adapter boundary mock regressions passed")
