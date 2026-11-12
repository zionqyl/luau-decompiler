local dependency = require(script.Parent.ModuleDependency)
return function(seed: number)
    local squared = dependency(seed)
    return squared + 1, nil
end
