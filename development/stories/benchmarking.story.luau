local ReplicatedStorage = game:GetService("ReplicatedStorage")
local benchmarking = require(ReplicatedStorage.development.benchmarking)
local colorscheme = require(ReplicatedStorage.global_client.ui.colorscheme)
local signal = require(ReplicatedStorage.global_shared.library.signal)

local function result_label()
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(0.5, 1)
	label.FontFace = colorscheme.font
	label.TextScaled = true
	label.TextColor3 = colorscheme.scheme.text
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.BackgroundTransparency = 1

	return label
end

local function result_row(name: string, data: number)
	local row = Instance.new("Frame")
	row.Size = UDim2.fromScale(1, 0.1)
	row.BackgroundTransparency = 1

	local name_label = result_label()
	name_label.Text = name
	name_label.Parent = row

	local data_label = result_label()
	data_label.Position = UDim2.fromScale(0.5, 0)

	local microseconds = data * 1000000

	if math.abs(microseconds) > 1000 then
		local milliseconds = data * 1000
		data_label.Text = `{milliseconds} ms`
	else
		data_label.Text = `{microseconds} μs`
	end

	data_label.Parent = row

	return row
end

local function result_tile(
	title: string,
	result: benchmarking.BenchmarkingResults
)
	local tile = Instance.new("Frame")
	tile.BackgroundColor3 = colorscheme.scheme.background

	local tile_list_layout = Instance.new("UIListLayout")
	tile_list_layout.Parent = tile

	local title_row = Instance.new("Frame")
	title_row.Size = UDim2.fromScale(1, 0.1)
	title_row.BackgroundTransparency = 1
	title_row.Parent = tile

	local title_placeholder = result_label()
	title_placeholder.Text = "title"
	title_placeholder.Parent = title_row

	local title_label = result_label()
	title_label.Position = UDim2.fromScale(0.5, 0)
	title_label.Text = title
	title_label.Parent = title_row

	-- not a loop bc i need this shit in order
	-- lord have mercy
	local tenth = result_row("10th %", result.tenth_percentile)
	tenth.LayoutOrder = 1
	tenth.Parent = tile

	local fiftieth = result_row("50th %", result.fiftieth_percentile)
	fiftieth.LayoutOrder = 2
	fiftieth.Parent = tile

	local ninetieth = result_row("90th %", result.ninetieth_percentile)
	ninetieth.LayoutOrder = 3
	ninetieth.Parent = tile

	local min = result_row("min", result.minimum)
	min.LayoutOrder = 4
	min.Parent = tile

	local max = result_row("max", result.maximum)
	max.LayoutOrder = 5
	max.Parent = tile

	local avg = result_row("avg", result.average)
	avg.LayoutOrder = 6
	avg.Parent = tile

	local total = result_row("total", result.total)
	total.LayoutOrder = 7
	total.Parent = tile

	return tile
end

return function(parent: Instance)
	local root = Instance.new("Frame")
	root.Size = UDim2.fromScale(1, 1)
	root.BackgroundTransparency = 1

	local benchmark_selector = Instance.new("ScrollingFrame")
	benchmark_selector.Size = UDim2.fromScale(0.2, 1)
	benchmark_selector.BackgroundColor3 =
		colorscheme.scheme.lighter_background
	benchmark_selector.ScrollBarThickness = 0
	benchmark_selector.Parent = root

	local selector_list_layout = Instance.new("UIListLayout")
	selector_list_layout.Parent = benchmark_selector

	local benchmark_picked: signal.Signal<{ [string]: benchmarking.BenchmarkingResults }> =
		{}
	local currently_activated = 1
	local script_buttons: { [number]: { button: TextButton, benchmarking_script: ModuleScript } } =
		{}

	for _, benchmarking_script in
		ReplicatedStorage.development.benchmarks:GetChildren()
	do
		if not benchmarking_script:IsA("ModuleScript") then
			warn(
				`The child {benchmarking_script.Name} is not a ModuleScript!!`
			)
			continue
		end

		local script_button = Instance.new("TextButton")
		script_button.Size = UDim2.fromScale(1, 0.05)
		script_button.TextScaled = true
		script_button.FontFace = colorscheme.font
		script_button.TextColor3 = colorscheme.scheme.text
		script_button.BackgroundColor3 =
			colorscheme.scheme.selection_background
		script_button.Text = benchmarking_script.Name
		script_button.Parent = benchmark_selector

		local index = #script_buttons + 1

		script_buttons[index] = {
			button = script_button,
			benchmarking_script = benchmarking_script,
		}

		script_button.Activated:Connect(function()
			script_buttons[currently_activated].button.BackgroundColor3 =
				colorscheme.scheme.selection_background

			currently_activated = index
			script_buttons[currently_activated].button.BackgroundColor3 =
				colorscheme.scheme.background

			local results =
				require(benchmarking_script :: ModuleScript)()

			if
				not benchmarking.benchmarking_script_guard(
					results
				)
			then
				warn(
					`The script {benchmarking_script.Name} doesn't return benchmarking results!`
				)
				return
			end

			signal.fire(benchmark_picked, results)
		end)
	end

	benchmark_selector.CanvasSize = UDim2.fromOffset(
		selector_list_layout.AbsoluteContentSize.X,
		selector_list_layout.AbsoluteContentSize.Y + 20
	)

	local result_display = Instance.new("ScrollingFrame")
	result_display.ScrollBarThickness = 0
	result_display.Position = UDim2.fromScale(0.2, 0)
	result_display.Size = UDim2.fromScale(0.8, 1)
	result_display.BackgroundColor3 = colorscheme.scheme.background
	result_display.Parent = root

	signal.connect(
		benchmark_picked,
		function(
			results: { [string]: benchmarking.BenchmarkingResults }
		)
			result_display.CanvasSize = UDim2.fromOffset(0, 0)
			result_display:ClearAllChildren()

			local result_grid_layout = Instance.new("UIGridLayout")
			result_grid_layout.CellSize = UDim2.fromScale(0.5, 0.5)
			result_grid_layout.CellPadding = UDim2.fromScale(0, 0)
			result_grid_layout.Parent = result_display

			for title, result: benchmarking.BenchmarkingResults in
				results
			do
				result_tile(title, result).Parent =
					result_display
			end

			result_display.CanvasSize = UDim2.fromOffset(
				result_grid_layout.AbsoluteContentSize.X,
				result_grid_layout.AbsoluteContentSize.Y + 20
			)
		end
	)

	root.Parent = parent

	return function()
		root:Destroy()
	end
end
