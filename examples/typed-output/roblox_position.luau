--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local function getPlayerPosition(player: Player): Vector3?
    local character: Model? = player.Character
    local position: Vector3? = nil
    if character ~= nil then
        position = character:GetPivot().Position
    end

    return position
end

return getPlayerPosition
