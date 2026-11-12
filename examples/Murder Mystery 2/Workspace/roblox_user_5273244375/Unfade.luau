--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local require_value = require
local game_value = game
game_value = game_value.ReplicatedStorage
game_value = game_value.Modules
game_value = game_value.FadeModule
local require_result = require_value(game_value)
game_value = false
spawn(
    function(): ()
        while true do
            local wait_value = wait
            wait_value()
            local value_1 = game_value
            if value_1 == true then
                break
            end
        end
        wait(1)
        _G.ShowResults()

        return
    end
)
require_result.SpawnFade()
game_value = true

return
