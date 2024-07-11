local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local Types = require(ReplicatedStorage.global_shared.chickynoid.Types)

-- just so that i dont have to cast to any :(
type TouchJumpController = {
	GetIsJumping: (self: TouchJumpController) -> boolean,
}

type ActiveController = {
	GetIsJumping: (self: ActiveController) -> boolean,
}

type ControlModuleOverride = {
	GetMoveVector: (self: ControlModuleOverride) -> Vector3,
	activeController: ActiveController,
	touchJumpController: TouchJumpController,
}

--Module for how to pass user input to the chickynoid system
--It's not really an example (you need a version of this to play!) But you'll need to clone/remove/edit this to do your own input functionality

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local shift_lock = 0
local reset_requested = false

local control_module = require(
	player:WaitForChild("PlayerScripts")
		:WaitForChild("PlayerModule")
		:WaitForChild("ControlModule")
) :: ControlModuleOverride

local function setup(_self: Types.ClientMod, _client: Types.ClientModule)
	UserInputService:GetPropertyChangedSignal("MouseBehavior")
		:Connect(function()
			shift_lock = if UserInputService.MouseBehavior
					== Enum.MouseBehavior.LockCenter
				then 1
				else 0
		end)

	local reset_bindable = Instance.new("BindableEvent")

	reset_bindable.Event:Connect(function()
		reset_requested = true
	end)

	for _retries = 0, 8 do
		local result, _error_message = pcall(
			StarterGui.SetCore,
			StarterGui,
			"ResetButtonCallback",
			reset_bindable
		)

		if result then
			break
		end

		task.wait()
	end
end

local function step(_self: Types.ClientMod, _deltaTime: number) end

local function get_is_jumping()
	local activeController = control_module.activeController
	if not activeController then
		return false
	end

	return activeController:GetIsJumping()
		or (
			control_module.touchJumpController
			and control_module.touchJumpController:GetIsJumping()
		)
end

local function calculate_raw_move_vector(cameraRelativeMoveVector: Vector3)
	local _, yaw = camera.CFrame:ToEulerAnglesYXZ()
	return CFrame.fromEulerAnglesYXZ(0, yaw, 0)
		* Vector3.new(
			cameraRelativeMoveVector.X,
			0,
			cameraRelativeMoveVector.Z
		)
end

local function generate_command(
	_self: Types.ClientMod,
	command: Types.Command,
	_serverTime: number,
	_dt: number
)
	command.x = 0
	command.y = 0
	command.z = 0

	local moveVector = control_module:GetMoveVector() :: Vector3
	if moveVector.Magnitude > 0 then
		moveVector = moveVector.Unit
		command.x = moveVector.X
		command.y = moveVector.Y
		command.z = moveVector.Z
	end

	-- This approach isn't ideal but it's the easiest right now
	if not UserInputService:GetFocusedTextBox() then
		local jump = UserInputService:IsKeyDown(Enum.KeyCode.Space)
		command.y = if jump then 1 else 0
	end

	if get_is_jumping() then
		command.y = 1
	end

	--Shiftlock
	command.shiftLock = shift_lock

	--Translate the move vector relative to the camera
	local rawMoveVector =
		calculate_raw_move_vector(Vector3.new(command.x, 0, command.z))
	command.x = rawMoveVector.X
	command.z = rawMoveVector.Z

	--reset requested?
	if reset_requested == true then
		command.reset = true
		reset_requested = false
	end

	return command
end

local controls: Types.ClientMod = {
	Setup = setup,
	Step = step,
	GenerateCommand = generate_command,
}

return controls
