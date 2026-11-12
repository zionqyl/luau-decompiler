local function getPlayerIdentity(player: Player)
    return player.UserId, player.DisplayName
end
return getPlayerIdentity
