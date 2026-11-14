--!strict
--[=[
    Luau Decompiler 0.4.0-rc.5
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local function getPlayerIdentity(player: Player): (number, string)
    return player.UserId, player.DisplayName
end

return getPlayerIdentity
