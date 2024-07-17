--[[
	every frame
	check for input
	when: valid
		apply velocity
	not: break

	when: grounded
		apply traction
		apply dash squat

	when: dash squat
		when: jump
			jump velocity
			launch in direction
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.global_shared.chickynoid.Types)

export type DashConstants = {
	dash_cooldown: number,
	dash_punch: number,
}

export type DashState = {
	can_dash: boolean,
	dash_debounce: number,

	-- explanation in double_jump.luau
	can_input_dash: boolean,
}

export type DashCommand = {
	dashing: boolean,
	dash_direction: Vector3,
}

export type SimulationModifier = Types.SimulationModifier<
	DashConstants,
	DashState,
	DashCommand
>

export type Simulation = Types.Simulation<DashConstants, DashState, DashCommand>

export type Command = Types.Command<DashCommand>

local k_move_state_name = "Dashing"

local function modify_simulation(
	self: SimulationModifier,
	simulation: Simulation
)
	simulation:RegisterMoveState(
		k_move_state_name,
		nil,
		nil,
		nil,
		nil,
		self.AlwaysThinkLate
	)

	simulation.constants.dash_cooldown = 0.5
	simulation.constants.dash_punch = 50

	simulation.state.can_dash = true
	simulation.state.can_input_dash = false
	simulation.state.dash_debounce = 0
end

local function always_think_late(simulation: Simulation, command: Command)
	if simulation.state.dash_debounce > 0 then
		simulation.state.dash_debounce = math.max(
			simulation.state.dash_debounce - command.deltaTime,
			0
		)

		simulation.state.can_dash = false
	else
		simulation.state.can_dash = true
	end

	if not command.dashing and not simulation.state.can_input_dash then
		simulation.state.can_input_dash = true
		return
	end

	if
		not command.dashing
		or not simulation.state.can_dash
		or not simulation.state.can_input_dash
	then
		return
	end

	simulation.state.can_dash = false
	simulation.state.can_input_dash = false

	simulation.state.dash_debounce = simulation.constants.dash_cooldown
	simulation.state.vel = command.dash_direction
		* simulation.constants.dash_punch
end

local dashing: SimulationModifier = {
	ModifySimulation = modify_simulation,
	AlwaysThinkLate = always_think_late,
}

return dashing
