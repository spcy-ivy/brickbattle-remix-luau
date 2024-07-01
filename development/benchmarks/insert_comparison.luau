local ReplicatedStorage = game:GetService("ReplicatedStorage")
local benchmarking = require(ReplicatedStorage.development.benchmarking)

local insert_comparison: benchmarking.BenchmarkingScript = function()
	local test1 = {}
	local insert_results = benchmarking.run(function()
		table.insert(test1, "gerald")
	end)

	local test2 = {}
	local manual_results = benchmarking.run(function()
		test2[#test2 + 1] = "gerald"
	end)

	return {
		["table.insert()"] = insert_results,
		["manual"] = manual_results,
		["insert - manual"] = benchmarking.subtract(
			insert_results,
			manual_results
		),
	}
end

return insert_comparison
