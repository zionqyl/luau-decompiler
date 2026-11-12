local environment = getfenv(0)
local originalPrint = environment.print
local value = "environment\000\255"
environment.decompilerEnvironmentProbe = value
originalPrint(environment.math == math, environment.decompilerEnvironmentProbe)
return environment.math == math, environment.decompilerEnvironmentProbe, environment.print == print
