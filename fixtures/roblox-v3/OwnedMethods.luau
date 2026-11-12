return function(seed: number)
    local owned = Instance.new("Folder")
    owned.Name = "DecompilerV3OwnedProbe"
    owned:SetAttribute("Seed", seed)
    local value = owned:GetAttribute("Seed")
    local isFolder = owned:IsA("Folder")
    owned:Destroy()
    return value, isFolder, nil
end
