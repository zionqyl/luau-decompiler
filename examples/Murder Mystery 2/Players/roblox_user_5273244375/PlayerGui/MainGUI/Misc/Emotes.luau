--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local parent_value_2 = script.Parent.Parent
local value_3: string = "Game"
local game_child = parent_value_2:WaitForChild(value_3)
local require_value = require
local game_value: DataModel = game
local value_5: string = "ReplicatedStorage"
local replicated_storage_service: Instance = game_value:GetService(value_5)
local value_5_2: string = "Modules"
local modules_child: Instance? = replicated_storage_service:WaitForChild(value_5_2)
local value_5_3: string = "ProfileData"
local require_result = require_value(modules_child:WaitForChild(value_5_3))
local emotes_value = game_child.Emotes
local g_value = _G
g_value.EmoteFrame = emotes_value
local value_1_2 = (require(game.ReplicatedStorage.Modules.EmoteModule))
value_1_2.EmoteGUI = emotes_value
value_1_2.GenerateEmotes(require_result.Emotes.Owned, emotes_value)
value_1_2.SetupPageButtons()
_G.UpdateEmotes()

return
