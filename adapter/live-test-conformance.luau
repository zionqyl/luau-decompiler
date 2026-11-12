
local Test = require("./live-test")
local result = Test.oracle_conformance()
assert(result.passed and result.negative_collision_pairs == 7)
assert(result.unsupported_observations_rejected == 3)
print("live oracle conformance passed")
