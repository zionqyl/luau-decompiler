local seed = ...
repeatCount = (repeatCount or 0) + 1
print("entry", repeatCount, seed)
return repeatCount, seed, nil
