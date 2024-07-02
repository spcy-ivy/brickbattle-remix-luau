local module = {}
--Module for how to pass user input to the chickynoid system
--It's not really an example (you need a version of this to play!) But you'll need to clone/remove/edit this to do your own input functionality

module.client = nil
module.useInbuiltDebugCheats = false
module.shiftLock = 0
local UserInputService = game:GetService("UserInputService")

--For access to control vectors
local ControlModule = nil --require(PlayerModule:WaitForChild("ControlModule"))

local function GetControlModule()
	if ControlModule == nil then
		local LocalPlayer = game.Players.LocalPlayer
		local scripts = LocalPlayer:FindFirstChild("PlayerScripts")
		if scripts == nil then
			return nil
		end

		local playerModule = scripts:FindFirstChild("PlayerModule")
		if playerModule == nil then
			return nil
		end

		local controlModule =
			playerModule:FindFirstChild("ControlModule")
		if controlModule == nil then
			return nil
		end

		ControlModule = require(
			LocalPlayer:WaitForChild("PlayerScripts")
				:WaitForChild("PlayerModule")
				:WaitForChild("ControlModule")
		)
	end

	return ControlModule
end

local coreCall
do
	local MAX_RETRIES = 8

	local StarterGui = game:GetService("StarterGui")
	local RunService = game:GetService("RunService")

	function coreCall(method, ...)
		local result = {}
		for retries = 1, MAX_RETRIES do
			result = { pcall(StarterGui[method], StarterGui, ...) }
			if result[1] then
				break
			end
			RunService.Stepped:Wait()
		end
		return unpack(result)
	end
end

function module:Setup(_client)
	self.client = _client

	UserInputService:GetPropertyChangedSignal("MouseBehavior")
		:Connect(function()
			if
				UserInputService.MouseBehavior
				== Enum.MouseBehavior.LockCenter
			then
				self.shiftLock = 1
			end
			if
				UserInputService.MouseBehavior
				== Enum.MouseBehavior.Default
			then
				self.shiftLock = 0
			end
		end)

	local resetBindable = Instance.new("BindableEvent")
	resetBindable.Event:Connect(function()
		self.resetRequested = true
	end)

	coreCall("SetCore", "ResetButtonCallback", resetBindable)
end

function module:Step(_client, _deltaTime) end

function module:GenerateCommand(command, serverTime: number, dt: number)
	command.x = 0
	command.y = 0
	command.z = 0

	GetControlModule()
	if ControlModule ~= nil then
		local moveVector = ControlModule:GetMoveVector() :: Vector3
		if moveVector.Magnitude > 0 then
			moveVector = moveVector.Unit
			command.x = moveVector.X
			command.y = moveVector.Y
			command.z = moveVector.Z
		end
	end

	-- This approach isn't ideal but it's the easiest right now
	if not UserInputService:GetFocusedTextBox() then
		local jump = UserInputService:IsKeyDown(Enum.KeyCode.Space)
		local crouch =
			UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
		command.y = 0
		if jump then
			command.y = 1
		else
			if crouch then
				command.y = -1
			end
		end
	end

	--Shiftlock
	command.shiftLock = self.shiftLock

	--Translate the move vector relative to the camera
	local rawMoveVector = self:CalculateRawMoveVector(
		Vector3.new(command.x, 0, command.z)
	)
	command.x = rawMoveVector.X
	command.z = rawMoveVector.Z

	--reset requested?
	if self.resetRequested == true then
		command.reset = true
		self.resetRequested = false
	end

	return command
end

function module:CalculateRawMoveVector(cameraRelativeMoveVector: Vector3)
	local Camera = workspace.CurrentCamera
	local _, yaw = Camera.CFrame:ToEulerAnglesYXZ()
	return CFrame.fromEulerAnglesYXZ(0, yaw, 0)
		* Vector3.new(
			cameraRelativeMoveVector.X,
			0,
			cameraRelativeMoveVector.Z
		)
end

function module:GetIsJumping()
	if ControlModule == nil then
		return false
	end
	if ControlModule.activeController == nil then
		return false
	end

	return ControlModule.activeController:GetIsJumping()
		or (
			ControlModule.touchJumpController
			and ControlModule.touchJumpController:GetIsJumping()
		)
end

return module
