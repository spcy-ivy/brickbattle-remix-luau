local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Types = require(ReplicatedStorage.global_shared.chickynoid.Types)

export type JumpsState = {
	jumps_left: number,
	jumping: boolean,
}

local function modify_simulation(
	self: Types.SimulationModifier,
	simulation: Types.Simulation
)
	-- cannot name this jumping because if i remember correctly chickynoid already takes it
	simulation:RegisterMoveState(
		"Jumps",
		nil,
		nil,
		nil,
		nil,
		self.AlwaysThinkLate
	)
end

local function always_think_late(
	_simulation: Types.Simulation,
	_command: Types.Command
)
end

local jumps: Types.SimulationModifier = {
	ModifySimulation = modify_simulation,
	AlwaysThinkLate = always_think_late,
}

return jumps
