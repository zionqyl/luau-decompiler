local playerScore = 10
local HTTPServer = {playerScore = "property", ["Player Score"] = "key"}
local printValue = print
local print = 4
local binaryString = "zero\0009\255\n\"\\"
printValue(playerScore, HTTPServer.playerScore, HTTPServer["Player Score"], print, #binaryString, string.byte(binaryString, 5, 7))
return playerScore, HTTPServer.playerScore, #binaryString
