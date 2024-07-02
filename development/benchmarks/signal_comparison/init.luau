local ReplicatedStorage = game:GetService("ReplicatedStorage")
local benchmarking = require(ReplicatedStorage.development.benchmarking)
local lemonsignal = require(script.lemonsignal)
local signal = require(ReplicatedStorage.global_shared.library.signal)

local signal_comparison: benchmarking.BenchmarkingScript = function()
	local my_results = benchmarking.run(function()
		local my_signal: signal.Signal<nil> = {}

		local connection = signal.connect(my_signal, function() end)

		signal.fire(my_signal)

		signal.disconnect(connection)
	end)

	local lemon_results = benchmarking.run(function()
		local lemon_signal = lemonsignal.new()

		local connection = lemon_signal:Connect(function() end)

		lemon_signal:Fire()

		connection:Disconnect()
	end)

	return {
		["my daughter"] = my_results,
		["the enemy"] = lemon_results,
		["lemon - my daughter"] = benchmarking.subtract(
			lemon_results,
			my_results
		),
	}
end

return signal_comparison
