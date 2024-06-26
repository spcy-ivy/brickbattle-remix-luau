local benchmarking = require("../development/benchmarking.luau")
local fs = require("@lune/fs")
local process = require("@lune/process")
local stdio = require("@lune/stdio")

local benchmarking_files: { string } = {}

local development_dir = fs.isDir("./development")

if not development_dir then
	warn("you are not at the project directory!")
	process.exit(1)
end

local benchmarks_dir = fs.isDir("./development/benchmarks")

if not benchmarks_dir then
	warn("the development directory does not have a `benchmarks` folder!")
	process.exit(1)
end

for _, entryName in fs.readDir("./development/benchmarks") do
	if not fs.isFile("./development/benchmarks/" .. entryName) then
		warn(`why in tarnation is {entryName} not a file`)
		return
	end

	table.insert(benchmarking_files, entryName)
end

local chosen_file = stdio.prompt(
	"select",
	"select the benchmarking environment",
	benchmarking_files
)

local script_name = benchmarking_files[chosen_file]
local benchmark = require("../development/benchmarks/" .. script_name)

if typeof(benchmark) ~= "function" then
	warn(`The script {script_name} doesn't return a function!`)
	process.exit(1)
end

local results = benchmark(benchmarking)

if typeof(results) ~= "table" then
	warn(
		`The function in {script_name} doesn't return a dictionary of benchmarking results!`
	)
	process.exit(1)
end

for name, result in pairs(results) do
	if typeof(name) ~= "string" then
		warn(`Please make the index of {name} a string`)
		continue
	end

	-- TODO implement [guard]()
end
