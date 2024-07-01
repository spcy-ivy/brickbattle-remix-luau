local ReplicatedStorage = game:GetService("ReplicatedStorage")
--[[
	benchmarking.luau

	because i need speed
]]
-- TODO: ok.. so the first benchmark run is always the slowest... might be cache and shit... so fix that... please
-- TODO: add a parameter generator thingy like the boatbomber plugin :)

local type_guard = require(ReplicatedStorage.global_shared.library.type_guard)

export type BenchmarkingResults = {
	tenth_percentile: number,
	fiftieth_percentile: number,
	ninetieth_percentile: number,
	minimum: number,
	maximum: number,
	average: number,
	total: number,
}

export type BenchmarkingScript = () -> { [string]: BenchmarkingResults }

type BenchmarkingLibrary = {
	benchmarking_results_guard: type_guard.Check,
	benchmarking_script_guard: type_guard.Check,
	run: (callback: () -> (), repetitions: number?) -> BenchmarkingResults,
	subtract: (
		first: BenchmarkingResults,
		second: BenchmarkingResults
	) -> BenchmarkingResults,
}

local k_default_repetitions = 500

local benchmarking_results_guard = type_guard.interface({
	tenth_percentile = type_guard.number,
	fiftieth_percentile = type_guard.number,
	ninetieth_percentile = type_guard.number,
	minimum = type_guard.number,
	maximum = type_guard.number,
	average = type_guard.number,
	total = type_guard.number,
})

local benchmarking_script_guard =
	type_guard.map(type_guard.string, benchmarking_results_guard)

local function run(
	callback: () -> (),
	input_repetitions: number?
): BenchmarkingResults
	local repetitions = input_repetitions or k_default_repetitions
	local times: { number } = {}

	local results = {
		tenth_percentile = 0,
		fiftieth_percentile = 0,
		ninetieth_percentile = 0,

		-- preposterously big
		minimum = math.huge,

		-- preposterously small
		maximum = -math.huge,

		average = 0,
		total = 0,
	}

	for _ = 1, repetitions do
		local start_time = os.clock()
		callback()
		table.insert(times, os.clock() - start_time)
	end

	table.sort(times)

	results.minimum = times[1]
	results.maximum = times[#times]

	results.tenth_percentile = times[math.round(#times / 10)]
	results.fiftieth_percentile = times[math.round(#times / 2)]
	results.ninetieth_percentile = times[math.round(#times * (9 / 10))]

	for _, length in times do
		results.total += length
	end

	results.average = (results.total / #times)

	return results
end

local function subtract(
	first: BenchmarkingResults,
	second: BenchmarkingResults
): BenchmarkingResults
	local result = {} :: BenchmarkingResults

	for index, _ in first do
		-- the fact that this entire thing doesnt piss off the type system is just fucking hilarious to me
		result[index] = first[index] - second[index]
	end

	return result
end

local benchmarking_library: BenchmarkingLibrary = {
	benchmarking_results_guard = benchmarking_results_guard,
	benchmarking_script_guard = benchmarking_script_guard,
	run = run,
	subtract = subtract,
}

return benchmarking_library
