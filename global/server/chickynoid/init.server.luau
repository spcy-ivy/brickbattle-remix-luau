local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerMods =
	require(ServerScriptService.global_server.chickynoid.ServerMods)
local ServerModule =
	require(ServerScriptService.global_server.chickynoid.ServerModule)

Players.CharacterAutoLoads = false

ServerModule:RecreateCollisions(workspace:FindFirstChild("GameArea") :: any)

ServerMods:RegisterMods("servermods", script.servermods)
ServerMods:RegisterMods(
	"characters",
	ReplicatedStorage.global_shared.chickynoid.characters
)

ServerModule:Setup()
