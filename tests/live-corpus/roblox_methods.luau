local seed = ...
local instance = Instance.new("Folder")
instance.Name = "DecompilerOwnedProbe"
instance:SetAttribute("Seed", seed)
local value = instance:GetAttribute("Seed")
local class = instance:IsA("Folder")
local vector = Vector3.new(seed, 2, 3)
instance:Destroy()
print("owned probe destroyed", value)
return value, class, vector.X, vector.Y, vector.Z
