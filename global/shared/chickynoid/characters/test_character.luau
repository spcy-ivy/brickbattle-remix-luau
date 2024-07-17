local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.global_shared.chickynoid.Types)
local dash = require(script.Parent.addons.dash)
local double_jump = require(script.Parent.addons.double_jump)

local function setup(_self: Types.CharacterMod, simulation: Types.Simulation)
	simulation.constants.maxSpeed = 48
	simulation.constants.airSpeed = 48
	simulation.constants.accel = 100
	simulation.constants.airAccel = 5
	simulation.constants.jumpPunch = 50
	simulation.constants.turnSpeedFrac = 10
	simulation.constants.runFriction = 0.01
	simulation.constants.brakeFriction = 0.01
	simulation.constants.maxGroundSlope = 0.55
	simulation.constants.jumpThrustPower = 400
	simulation.constants.jumpThrustDecay = 0.1
	simulation.constants.gravity = -300

	double_jump:ModifySimulation(simulation :: any);
	(simulation.constants :: any).double_jump_punch = 100

	dash:ModifySimulation(simulation :: any);
	(simulation.constants :: any).dash_cooldown = 0.5;
	(simulation.constants :: any).dash_punch = 50
end

local function get_character_model(_self: Types.CharacterMod, _user_id: number)
	return ReplicatedStorage.global_shared_assets.characters.target_dummy
end

local test_character: Types.CharacterMod = {
	Setup = setup,
	GetCharacterModel = get_character_model,
}

return test_character
