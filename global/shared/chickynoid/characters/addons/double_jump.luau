local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.global_shared.chickynoid.Types)

export type DoubleJumpConstants = {
	double_jump_punch: number,
}

export type DoubleJumpState = {
	can_double_jump: boolean,

	-- since AlwaysThinkLate is run every frame, if we don't have this then the playwer can double jump without letting go of their previous jump input
	can_input_double_jump: boolean,
}

export type DoubleJumpCommand = {}

export type SimulationModifier = Types.SimulationModifier<
	DoubleJumpConstants,
	DoubleJumpState,
	DoubleJumpCommand
>

export type Simulation = Types.Simulation<DoubleJumpConstants, DoubleJumpState>
export type Command = Types.Command<DoubleJumpCommand>

local function modify_simulation(
	self: SimulationModifier,
	simulation: Simulation
)
	simulation:RegisterMoveState(
		"DoubleJump",
		nil,
		nil,
		nil,
		nil,
		self.AlwaysThinkLate
	)

	simulation.state.can_double_jump = true
	simulation.state.can_input_double_jump = false
	simulation.constants.double_jump_punch = 100
end

-- i dont know why this works
-- so i wont touch it
local function always_think_late(simulation: Simulation, command: Command)
	if simulation.lastGround then
		simulation.state.can_double_jump = true
		simulation.state.can_input_double_jump = false
		return
	end

	if command.y <= 0 and not simulation.state.can_input_double_jump then
		simulation.state.can_input_double_jump = true
		return
	end

	if
		not simulation.state.can_double_jump
		or not simulation.state.can_input_double_jump
		or command.y <= 0
	then
		return
	end

	simulation.state.can_double_jump = false
	simulation.state.can_input_double_jump = false

	simulation.state.vel =
		Vector3.new(0, simulation.constants.double_jump_punch, 0)
end

local double_jump: SimulationModifier = {
	ModifySimulation = modify_simulation,
	AlwaysThinkLate = always_think_late,
}

return double_jump
