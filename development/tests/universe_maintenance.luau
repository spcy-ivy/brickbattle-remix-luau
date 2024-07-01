local ReplicatedStorage = game:GetService("ReplicatedStorage")
local testing = require(ReplicatedStorage.development.testing)

local universe_maintenance: testing.TestingScript = function()
	local comparisons = {
		["1 should equal 1"] = function()
			return 1 == 1
		end,

		["2 should be greater than 1"] = function()
			return 2 > 1
		end,

		["1 should be less than 2"] = function()
			return 1 < 2
		end,
	}

	return {
		["comparisons"] = comparisons,
	}
end

return universe_maintenance
