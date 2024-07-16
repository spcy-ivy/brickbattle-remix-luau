local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.global_shared.chickynoid.Types)

export type DashConstants = {
	dash_cooldown: number,
}

export type DashState = {
	can_dash: boolean,
	dash_debounce: number,
}

export type DashCommand = {
	dashing: boolean,
}

export type SimulationModifier = Types.SimulationModifier<
	DashConstants,
	DashState,
	DashCommand
>

export type Simulation = Types.Simulation<DashConstants, DashState>

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
	simulation.state.can_dash = true
	simulation.state.dash_debounce = 0
end

local function always_think_late(simulation: Simulation, command: Command)
	if simulation.state.dash_debounce > 0 then
	end

	if not command.dashing then
		return
	end
end

local dashing: SimulationModifier = {
	ModifySimulation = modify_simulation,
	AlwaysThinkLate = always_think_late,
}

return dashing
