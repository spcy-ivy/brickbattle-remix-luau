local module = {}

function module:Setup(server)
	server.OnPlayerConnected:Connect(function(serv, playerRecord)
		playerRecord:SetCharacterMod("test_character")
	end)
end

return module
