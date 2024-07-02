local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientMods = require(script.ClientMods)
local ClientModule = require(script.ClientModule)

ClientMods:RegisterMods("clientmods", script.clientmods)
ClientMods:RegisterMods(
	"characters",
	ReplicatedStorage.global_shared.chickynoid.characters
)

ClientModule:Setup()
