--!strict

local function calculateTotal(unitPrice: number, quantity: number)
    local total = unitPrice * quantity
    return total
end

local formatLabel = function(total: number)
    return "Total: " .. total
end

return {
    calculateTotal = calculateTotal,
    formatLabel = formatLabel,
}
