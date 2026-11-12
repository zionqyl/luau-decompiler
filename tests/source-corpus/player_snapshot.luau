--!strict

export type PlayerSnapshot = {
    userId: number,
    displayName: string,
    position: Vector3?,
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
