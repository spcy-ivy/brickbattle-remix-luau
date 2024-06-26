--[[
	benchmarking.luau

	because i need speed
]]
-- TODO: add a parameter generator thingy like the boatbomber plugin :)

export type BenchmarkingResults = {
	tenth_percentile: number,
	fiftieth_percentile: number,
	ninetieth_percentile: number,
	minimum: number,
	maximum: number,
	average: number,
	total: number,
}

type BenchmarkingLibrary = {
	run: (callback: () -> (), repetitions: number?) -> BenchmarkingResults,
	pretty_print: (results: BenchmarkingResults) -> (),
	subtract: (
		first: BenchmarkingResults,
		second: BenchmarkingResults
	) -> BenchmarkingResults,
}

local k_default_repetitions = 500

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

	for _, length in ipairs(times) do
		results.total += length
	end

	results.average = (results.total / #times)

	return results
end

local function pretty_print(results: BenchmarkingResults)
	local function process_string(length: number): string
		local microseconds = math.ceil((length :: number) * 1000000)

		if math.abs(microseconds) > 1000 then
			local milliseconds =
				math.ceil((length :: number) * 1000)
			return `~{milliseconds} **milliseconds**`
		end

		return `~{microseconds} microseconds`
	end

	print("| category | time |")
	print("|----------|------|=>")
	print(`| 10th %   | {process_string(results.tenth_percentile)}`)
	print(`| 50th %   | {process_string(results.fiftieth_percentile)}`)
	print(`| 90th %   | {process_string(results.ninetieth_percentile)}`)
	print(`| min      | {process_string(results.minimum)}`)
	print(`| max      | {process_string(results.maximum)}`)
	print(`| avg      | {process_string(results.average)}`)
	print(`| total    | {process_string(results.total)}`)
end

local function subtract(
	first: BenchmarkingResults,
	second: BenchmarkingResults
): BenchmarkingResults
	local result = {} :: BenchmarkingResults

	for index, _ in pairs(first) do
		-- the fact that this entire thing doesnt piss off the type system is just fucking hilarious to me
		result[index] = first[index] - second[index]
	end

	return result
end

local benchmarking_library: BenchmarkingLibrary = {
	run = run,
	pretty_print = pretty_print,
	subtract = subtract,
}

return benchmarking_library
