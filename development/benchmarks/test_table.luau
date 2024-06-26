return function(benchmarking)
	local create_results = benchmarking.run(function()
		table.create(5000, 1)
	end)

	local instantiate_results = benchmarking.run(function()
		local t = {}

		for i = 1, 5000 do
			t[i] = 1
		end
	end)

	return {
		["results for table.create()"] = create_results,
		["results for t = {}"] = instantiate_results,
		["table.create() subtracted by t = {}"] = benchmarking.subtract(
			create_results,
			instantiate_results
		),
	}
end
