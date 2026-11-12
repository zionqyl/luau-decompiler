local function getPlayerPosition(player: Player)
    local character: Model? = player.Character
    local position: Vector3? = nil
    if character ~= nil then
        position = character:GetPivot().Position
    end
    return position
end
return getPlayerPosition
