


local Normalization = {}

function Normalization.upstream_identity(bytecode)
    assert(type(bytecode) == "string" and #bytecode > 0, "expected serialized upstream bytecode")


    return bytecode
end

function Normalization.madium_processed_options()



    return {profile="auto",bytecode_encoding="roblox_opcode227",normalizer_name="madium_processed_opcode227"}
end

return Normalization
