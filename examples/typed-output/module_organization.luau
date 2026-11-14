--!strict
--[=[
    Luau Decompiler 0.4.0-rc.5
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

export type Options = {
    enabled: boolean,
    speed: number,
}

local RunService = game:GetService("RunService")
local Modules: string = "Modules"
local Signal = require("./signal")
local Debug = require("./debug")

export type Changed = Signal.Signal<number>
export type DebugState = typeof(Debug.new())
export type Shared = {
    changed: Changed,
    debug: DebugState,
}

local helperPrefix: string = "helper:"
local function makeName(value: string): string
    return helperPrefix .. value
end

local Module = { }
Module.Name = makeName("Module")
Module.Options = {
    enabled = true,
    speed = 16
}
print("configured", Module.Name, RunService.ClassName, Modules)

function Module.new(options: Options): Shared
    print("construct", options.enabled, options.speed)
    return {
        changed = Signal.new(),
        debug = Debug.new(),
    }
end

return Module
