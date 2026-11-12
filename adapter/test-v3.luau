local Adapter=require("./decompile")
local bytes=string.char(14,3,0,255,128,0)
local script_target={class="ModuleScript"}
local fn_target=function(...) return ... end
local original_error={message="getter failure identity"}
local script_calls,function_calls=0,0
local captured
local function options(profile)
    return {environment={},executor_profile=profile or "generic",handshake=false,token=string.rep("t",32),
        classify_target=function(value)
            if value==script_target then return "script" end
            if type(value)=="string" then return "bytecode" end
            if type(value)=="function" then return "func" end
            error("invalid target")
        end,
        get_bytecode=function(value) assert(value==script_target);script_calls+=1;return bytes end,
        get_function_bytecode=function(value) assert(value==fn_target);function_calls+=1;return bytes end,
        request=function()return {StatusCode=200,Body="ok"}end,
        json_encode=function(value)captured=value;return "json"end,
        json_decode=function()return {source="return 1",complete=true,quality="structured",validation={required_passed=true}}end,
        spawn=function(callback)callback()end,wait=function()error("immediate mock yielded")end,
    }
end
local generic=Adapter.install(options())
assert(generic.decompile(script_target)=="return 1")
assert(script_calls==1 and function_calls==0)
assert(generic.decompile(bytes)=="return 1")
assert(script_calls==1 and function_calls==0 and captured.bytecode_base64==Adapter.encode_base64(bytes))
assert(generic.decompile(fn_target)=="return 1")
assert(function_calls==1)
assert(not pcall(generic.decompile,script_target,4))
assert(not pcall(generic.decompile,script_target,{timeout=4}))
assert(generic.decompile(script_target,{naming="camelCase",typing={verbosity="extensive"},formatting={line_width=88}})=="return 1")
assert(captured.reconstruction_config.naming=="camelCase" and captured.reconstruction_config.formatting.line_width==88)
assert(generic.decompile_with_timeout(script_target,{indent="\t"},1)=="return 1")
assert(captured.reconstruction_config.indent=="\t")
assert(generic.restore())

local mapped=Adapter.map_options({SmartVariableRenamer=false,UseDebugSymbols=false,FunctionDeclarations=true,
    RestoreTypeHints=true,SeparateLogicalSections=true,Formatter={IndentWidth=2,ColumnLimit=90}},"volt")
assert(mapped.naming_options.infer_descriptive_names==false and mapped.naming_options.use_debug_names==false)
assert(mapped.formatting.local_functions and mapped.formatting.blank_lines and mapped.formatting.line_width==90)
assert(mapped.typing.mode=="annotated" and mapped.indent=="  ")
assert(not pcall(Adapter.map_options,{ConstantFolding=false},"volt"))
assert(not pcall(Adapter.map_options,{SmartVariableRenamer="yes"},"volt"))
assert(not pcall(Adapter.map_options,{IndentSize=1,IndentWidth=2},"lynx"))
local nested=Adapter.map_options({indentsize=2,DecompilerOptions={Formatter={IndentWidth=4},restoretypehints=false}},"lynx")
assert(nested.indent=="    " and nested.typing.mode=="off")
assert(not pcall(Adapter.map_options,{Formatter={IndentWidth=0/0}},"lynx"))
assert(not pcall(Adapter.map_options,{timeout=1},"lynx"))

local volt=Adapter.install(options("volt"))
assert(volt.decompile(bytes,{Formatter={IndentWidth=2}})=="return 1")
assert(not pcall(volt.decompile,fn_target))
assert(volt.restore())
local lynx=Adapter.install(options("lynx"))
assert(lynx.decompile(fn_target,{RestoreTypeHints=true})=="return 1")
assert(lynx.restore())
local madium=Adapter.install(options("madium"))
assert(madium.decompile(script_target)=="return 1")
assert(not pcall(madium.decompile,bytes))
assert(not pcall(madium.decompile,script_target,{}))
assert(madium.decompile_bytecode(bytes)=="return 1")
assert(madium.restore())

local bad=options();bad.get_bytecode=function()error(original_error,0)end
local fail=Adapter.install(bad)
local ok,err=pcall(fail.decompile,script_target)
assert(not ok and err==original_error)
assert(fail.restore())
local failed_quality=options()
failed_quality.json_decode=function()return {source="return 1",baseline_source="return 1",complete=true,quality="structured",validation={required_passed=false,strict_analysis="failed"}}end
local strict=Adapter.install(failed_quality)
local passed,diagnostic=pcall(strict.decompile,bytes,{validation={mode="strict_required"}})
assert(not passed and diagnostic.stage=="quality" and diagnostic.source=="return 1")
assert(strict.decompile_detailed(bytes).validation.required_passed==false)
assert(strict.restore())
local settings_supported=false
local handshake_options=options()
handshake_options.handshake=true
handshake_options.json_decode=function()
    return {protocol_version=2,implementation={profiles={{id="luau-v14",bytecode_version=14}}},encodings={"auto","upstream"},
        features={per_request_settings=settings_supported},source="return 1",complete=true,quality="structured"}
end
local old_server=Adapter.install(handshake_options)
local accepted,rejection=pcall(old_server.decompile,bytes,{naming="camelCase"})
assert(not accepted and rejection.stage=="compatibility")
assert(old_server.restore())
settings_supported=true
local compatible_server=Adapter.install(handshake_options)
assert(compatible_server.decompile(bytes,{naming="camelCase"})=="return 1")
assert(compatible_server.restore())
print("v3 adapter target/options/quality contracts passed")
