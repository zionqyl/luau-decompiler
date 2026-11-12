--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local function calculateTotal(unitPrice: number, quantity: number): number
    local total: number = unitPrice * quantity
    return total
end

local formatLabel: (number) -> (string) = function(total: number): string
    return "Total: " .. total
end

return {
    calculateTotal = calculateTotal,
    formatLabel = formatLabel,
}
