--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

export type PlayerSnapshot = {
    displayName: string,
    position: Vector3?,
    userId: number,
}

local function getPlayerSnapshot(player: Player): PlayerSnapshot
    local character: Model? = player.Character
    local position: Vector3? = nil
    if character ~= nil then
        position = character:GetPivot().Position
    end

    return {
        userId = player.UserId,
        displayName = player.DisplayName,
        position = position,
    }
end

return getPlayerSnapshot
