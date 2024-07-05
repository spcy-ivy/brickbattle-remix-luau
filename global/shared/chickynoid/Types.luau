--[=[
    @class Types
    All types used by Chickynoid.
]=]

--[=[
    @interface ISimulationConfig
    @within Types
    .raycastWhitelist {BasePart} -- Raycast whitelist used for collision checks.
    .feetHeight number -- Players feet height. Height goes from -2.5 to +2.5 so any point below this number is considered the players feet. The distance between middle and feetHeight is "ledge".
    .stepSize number -- How big an object we can step over?

    The config passed to the Chickynoid [Simulation] class.
]=]
export type ISimulationConfig = {
	raycastWhitelist: { BasePart },
	feetHeight: number,
	stepSize: number,
}

--[=[
    @interface IServerConfig
    @within Types
    .simulationConfig ISimulationConfig -- The config passed to the Chickynoid [Simulation] class.
]=]
export type IServerConfig = {
	simulationConfig: ISimulationConfig,
}

--[=[
    @interface IClientConfig
    @within Types
    .simulationConfig ISimulationConfig -- The config passed to the Chickynoid [Simulation] class.
]=]
export type IClientConfig = {
	simulationConfig: ISimulationConfig,
}

--[=[
	@interface Constants
	@within Types
	.maxSpeed -- Units per second
	.airSpeed -- Units per second
	.accel -- Units per second 
	.airAccel -- Uses a different function than ground accel!
	.jumpPunch -- Raw velocity, just barely enough to climb on a 7 unit tall block
	.turnSpeedFrac -- Seems about right? Very fast.
	.runFriction -- Friction applied after max speed
	.brakeFriction -- Lower is brake harder, dont use 0
	.maxGroundSlope -- About 45 degrees
	.jumpThrustPower --  If you keep holding jump, how much extra vel per second is there?  (turn this off for no variable height jumps)
	.jumpThrustDecay -- Smaller is faster
	.crashLandBehavior -- Documentation WIP
	.stepSize -- Documentation WIP
	.gravity -- Documentation WIP
]=]
export type Constants = {
	maxSpeed: number,
	airSpeed: number,
	accel: number,
	airAccel: number,
	jumpPunch: number,
	turnSpeedFrac: number,
	runFriction: number,
	brakeFriction: number,
	maxGroundSlope: number,
	jumpThrustPower: number,
	jumpThrustDecay: number,
	crashLandBehavior: number,
	stepSize: number,
	gravity: number,
}

--- MASSIVE WIP
export type Simulation = {
	constants: Constants,
}

--[=[
	@interface CharacterMod
	@within Types
	.Setup -- Mostly for setting simulation constants and state alongside setting up some move types
	.GetCharacterModel -- Return a model to set a custom rig for a specific character!
]=]
export type CharacterMod = {
	Setup: (self: CharacterMod, simulation: Simulation) -> (),
	GetCharacterModel: (self: CharacterMod, user_id: number) -> Model?,
}

return nil
