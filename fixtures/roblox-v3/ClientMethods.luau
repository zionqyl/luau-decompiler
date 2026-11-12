return function(seed: number)
    local owned = Instance.new("Part")
    owned.Name = "DecompilerV3UnparentedPart"
    owned.Position = Vector3.new(seed, 2, 3)
    local position = owned:GetPivot().Position
    local class = owned.ClassName
    owned:Destroy()
    return position, class, nil
end
