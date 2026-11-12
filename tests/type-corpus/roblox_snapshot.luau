local function getPlayerSnapshot(player: Player)
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
