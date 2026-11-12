local Test = {}

local function hex(bytes)
    return (bytes:gsub(".", function(byte) return string.format("%02x", string.byte(byte)) end))
end

function Test.run(Observer, cases)
    local report = {oracle=Observer.oracle_conformance(),cases={},comparisons=0,transport="manual MCP host exchange; native HTTP adapter is tested separately"}
    for _, case in cases do
        local original = assert(loadstring(case.source))()
        local packet = getfunctionbytecode(original)
        assert(type(packet)=="string" and hex(packet)==case.packet_hex,"native getter packet changed")
        local row = {id=case.id,packet_bytes=#packet,inputs={},verified=false}
        if case.rejected then
            assert(case.id=="captured" and case.recovered==nil,"unsupported dump unexpectedly has source")
            row.rejected=true
            row.reason="host reconstruction rejected absent live upvalue values"
        else
            local recovered = assert(loadstring(case.recovered))()
            assert(type(recovered)=="function","function-entry output did not return a function")
            local inputs
            if case.id=="fixed" then
                inputs={table.pack(-3),table.pack(0),table.pack(7),table.pack(-0.0),table.pack(math.huge)}
            elseif case.id=="varargs" then
                inputs={table.pack(),table.pack(7,nil,"tail",nil),table.pack("\000\255",nil,true),table.pack(false),table.pack("7")}
            elseif case.id=="guarded" then
                inputs={table.pack(-1),table.pack(0),table.pack(7),table.pack(-3),table.pack(2)}
            elseif case.id=="stateful" then
                inputs={1,-2,7,0,-3}
            else
                error("unknown controlled function family",0)
            end
            local expected_state,actual_state={value=0},{value=0}
            for index,args in inputs do
                local expected,actual
                if case.id=="stateful" then
                    expected=Observer.observe(function()return original(expected_state,args)end)
                    actual=Observer.observe(function()return recovered(actual_state,args)end)
                else
                    expected=Observer.observe(function()return original(table.unpack(args,1,args.n))end)
                    actual=Observer.observe(function()return recovered(table.unpack(args,1,args.n))end)
                end
                assert(expected==actual,"typed native function observation differs")
                row.inputs[index]={verified=true,expected_hex=hex(expected),actual_hex=hex(actual)}
                report.comparisons+=1
            end
            assert(expected_state.value==actual_state.value)
            row.verified=true
        end
        report.cases[#report.cases+1]=row
    end
    return report
end

return Test
