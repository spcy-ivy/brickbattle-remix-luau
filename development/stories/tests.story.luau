local EngineAPICloudProcessingService =
	game:GetService("EngineAPICloudProcessingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local colorscheme = require(ReplicatedStorage.global_client.ui.colorscheme)
local signal = require(ReplicatedStorage.global_shared.library.signal)
local testing = require(ReplicatedStorage.development.testing)
local type_guard = require(ReplicatedStorage.global_shared.library.type_guard)

export type Tests = { [string]: { [string]: () -> boolean } }

export type TestingScript = () -> Tests

local tests_guard = type_guard.map(
	type_guard.string,
	type_guard.map(type_guard.string, type_guard.lambda)
)

local test_picked: signal.Signal<Tests> = {}

local active_index = 1
local script_buttons: { [number]: { button: TextButton, testing_script: ModuleScript } } =
	{}

local function script_button(testing_script: ModuleScript)
	local button = Instance.new("TextButton")

	button.Size = UDim2.fromScale(1, 0.05)
	button.TextScaled = true
	button.FontFace = colorscheme.font
	button.TextColor3 = colorscheme.scheme.text
	button.BackgroundColor3 = colorscheme.scheme.selection_background
	button.Text = testing_script.Name

	local index = #script_buttons + 1

	script_buttons[index] = {
		button = button,
		testing_script = testing_script,
	}

	button.Activated:Connect(function()
		script_buttons[active_index].button.BackgroundColor3 =
			colorscheme.scheme.selection_background

		active_index = index

		script_buttons[active_index].button.BackgroundColor3 =
			colorscheme.scheme.background

		local tests = require(testing_script :: ModuleScript)()

		if not tests_guard(tests) then
			warn(
				`The script {testing_script.Name} doesn't return tests!`
			)
		end

		signal.fire(test_picked, tests)
	end)

	return button
end

local function result_row()
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 0.05)
	label.BackgroundTransparency = 1
	label.TextScaled = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextColor3 = colorscheme.scheme.text
	label.FontFace = colorscheme.font

	return label
end

return function(parent: Instance)
	local root = Instance.new("Frame")
	root.Size = UDim2.fromScale(1, 1)
	root.BackgroundTransparency = 1

	local test_selector = Instance.new("ScrollingFrame")
	test_selector.Size = UDim2.fromScale(0.2, 1)
	test_selector.BackgroundColor3 = colorscheme.scheme.lighter_background
	test_selector.ScrollBarThickness = 0
	test_selector.Parent = root

	local selector_list_layout = Instance.new("UIListLayout")
	selector_list_layout.Parent = test_selector

	for _, testing_script in
		ReplicatedStorage.development.tests:GetChildren()
	do
		if not testing_script:IsA("ModuleScript") then
			warn(`The child {testing_script} is not a ModuleScript`)
			continue
		end

		script_button(testing_script).Parent = test_selector
	end

	test_selector.CanvasSize = UDim2.fromOffset(
		selector_list_layout.AbsoluteContentSize.X,
		selector_list_layout.AbsoluteContentSize.Y + 20
	)

	local result_display = Instance.new("ScrollingFrame")
	result_display.ScrollBarThickness = 0
	result_display.Position = UDim2.fromScale(0.2, 0)
	result_display.Size = UDim2.fromScale(0.8, 1)
	result_display.BackgroundColor3 = colorscheme.scheme.background
	result_display.Parent = root

	signal.connect(test_picked, function(tests: Tests)
		result_display.CanvasSize = UDim2.fromOffset(0, 0)
		result_display:ClearAllChildren()

		local result_list_layout = Instance.new("UIListLayout")
		result_list_layout.Parent = result_display

		for title, test in tests do
			local title_label = result_row()
			title_label.Text = title
			title_label.Parent = result_display

			for scope, baby_test in test do
				local start_time = os.clock()
				local result = baby_test()
				local end_time = os.clock() - start_time

				if typeof(result) ~= "boolean" then
					warn(
						`The test under the scope of {scope} doesn't return a boolean!`
					)
					continue
				end

				local icon = if result then "✓" else "𐄂"
				local microseconds = end_time * 1000000
				local milliseconds = end_time * 1000

				local time_taken = if microseconds
						> 1000
					then milliseconds .. "ms"
					else microseconds .. "μs"

				local scope_label = result_row()
				scope_label.Text =
					`	{icon}  {scope}  ({time_taken})`
				scope_label.Parent = result_display
			end
		end

		result_display.CanvasSize = UDim2.fromOffset(
			result_list_layout.AbsoluteContentSize.X,
			result_list_layout.AbsoluteContentSize.Y + 20
		)

		print(#result_display:GetChildren())
	end)

	root.Parent = parent

	return function()
		root:Destroy()
	end
end
