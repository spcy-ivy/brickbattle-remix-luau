--[=[
    @class Types
    All types used by Chickynoid.
]=]

-- TODO: might need to partition these types into their individual modules later :)

-- NOTE: the casing here will be inconsistent with the rest of our codebase's standards (most apparent is the deviation from snake_case), so just watch out for that pleaz
-- These types will mostly be based off of the typescript types in the original chickynoid codebase

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
	@interface State
	@within Types
	.pos Vector3 -- The position of the character
	.vel Vector3 -- The velocity of the character
	.pushDir Vector2 -- Two axis direction where the player is being pushed
	.jump number -- Whether the character is jumping
	.angle number -- The rotation of the player
	.targetAngle number -- idfk lol
	.stepUp number -- idfk lol
	.inAir number -- Whether the character is airborne
	.jumpThrust number -- idfk lol
	.pushing number -- idfk lol
	.characterData unknown -- idfk lol
]=]
export type State = {
	pos: Vector3,
	vel: Vector3,
	pushDir: Vector2,
	jump: number,
	angle: number,
	targetAngle: number,
	stepUp: number,
	inAir: number,
	jumpThrust: number,
	pushing: number,
	characterData: unknown, -- WIP
}

--[=[
	@interface Constants
	@within Types
	.maxSpeed number -- Units per second
	.airSpeed number -- Units per second
	.accel number -- Units per second 
	.airAccel number -- Uses a different function than ground accel!
	.jumpPunch number -- Raw velocity, just barely enough to climb on a 7 unit tall block
	.turnSpeedFrac number -- Seems about right? Very fast.
	.runFriction number -- Friction applied after max speed
	.brakeFriction number -- Lower is brake harder, dont use 0
	.maxGroundSlope number -- About 45 degrees
	.jumpThrustPower number --  If you keep holding jump, how much extra vel per second is there?  (turn this off for no variable height jumps)
	.jumpThrustDecay number -- Smaller is faster
	.crashLandBehavior number -- Documentation WIP
	.stepSize number -- Documentation WIP
	.gravity number -- Documentation WIP
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

--[=[
	@interface Constants
	@within Types
]=]
export type CollisionData = {
	startPos: Vector3,
	endPos: Vector3,
	fraction: number,
	startSolid: boolean,
	allSolid: boolean,
	planeNum: number,
	planeD: number,
	normal: Vector3,
	checks: number,
	hullRecord: nil,
}

--[=[
	NOTE: `updateState` in `RegisterMoveState` is absolutely required if you plan on using `:SetMoveState` for the simulation modifier
]=]
export type Simulation<C = {}, S = {}, CMD = {}> = {
	constants: Constants & C,
	state: State & S,
	userId: number,
	lastGround: unknown, -- WIP
	characterData: unknown, -- WIP

	RegisterMoveState: (
		self: Simulation<C, S, CMD>,
		name: string,
		updateState: ((
			simulation: Simulation<C, S, CMD>,
			command: Command<CMD>
		) -> ())?,
		alwaysThink: ((
			simulation: Simulation<C, S, CMD>,
			command: Command<CMD>
		) -> ())?,
		startState: ((
			simulation: Simulation<C, S, CMD>,
			command: Command<CMD>
		) -> ())?,
		endState: ((
			simulation: Simulation<C, S, CMD>,
			command: Command<CMD>
		) -> ())?,
		alwaysThinkLate: ((
			simulation: Simulation<C, S, CMD>,
			command: Command<CMD>
		) -> ())?,
		executionOrder: number?
	) -> (),

	GetMoveState: (self: Simulation<C, S, CMD>) -> { name: string }, -- WIP
	SetMoveState: (self: Simulation<C, S, CMD>, moveState: string) -> (),

	SetPosition: (position: Vector3, teleport: boolean) -> (),
	SetAngle: (angle: number, teleport: boolean) -> (),

	ProjectVelocity: (
		startPos: Vector3,
		startVel: Vector3,
		deltaTime: number
	) -> (Vector3, Vector3, boolean),

	DoGroundCheck: (position: Vector3) -> unknown, -- WIP
}

--[=[
	@interface CharacterMod
	@within Types
	.Setup (self: CharacterMod, simulation: Simulation) -> () -- Mostly for setting simulation constants and state alongside setting up some move types
	.GetCharacterModel (self: CharacterMod, user_id: number) -> Model? -- Return a model to set a custom rig for a specific character!
]=]
export type CharacterMod = {
	Setup: (self: CharacterMod, simulation: Simulation) -> (),
	GetCharacterModel: (self: CharacterMod, user_id: number) -> Model?,
}

--[=[
	@interface Command
	@within Types
	.serverTime number -- dunno this lol
	.deltaTime number -- dunno what this is either
	.snapshotServerFrame number -- still dunno
	.playerStateFrame number -- uhhhhhhhh
	.x number -- X directional run input
	.y number -- Y directional run input
	.z number -- Z directional run input
]=]
export type Command<C = {}> = {
	serverTime: number,
	deltaTime: number,
	snapshotServerFrame: number,
	playerStateFrame: number,

	x: number,
	y: number,
	z: number,
} & C

export type ClientChickynoid = {
	simulation: Simulation,
}

--- EXTREME WIP
export type ClientModule = {
	localChickynoid: ClientChickynoid?,
}

--[=[
	@interface ClientMod
	@within Types

	.GetPriority (() -> number)? -- Decides which function goes first
	.Step (self: ClientMod, deltaTime: number) -> () -- Runs every frame i think
	.Setup (self: ClientMod) -> () -- Initial setup i think
	.GenerateCommand (self ClientMod, command Command, serverTime number, deltaTime number) -> unknown)? -- no idea what this does LMAOOO
]=]
export type ClientMod<C = {}> = {
	Setup: (self: ClientMod<C>, client: ClientModule) -> (),
	GetPriority: (() -> number)?,
	Step: (self: ClientMod<C>, deltaTime: number) -> (),
	GenerateCommand: ((
		self: ClientMod<C>,
		command: Command<C>,
		serverTime: number,
		deltaTime: number
	) -> Command<C>)?,
}

--[=[
	@interface SimulationModifier
	@within Types
	.ModifySimulation (self: SimulationModifier, simulation: Simulation) -> () -- The main function to call `Simulation:RegisterMoveState`in
	.ActiveThink ((simulation: Simulation, command: Command) -> ())? -- Runs while the state is activated
	.AlwaysThink ((simulation: Simulation, command: Command) -> ())? -- Always runs regardless of activation
	.StartState ((simulation: Simulation, command: Command) -> ())? -- Runs when the state is activated
	.EndState ((simulation: Simulation, command: Command) -> ())? -- Runs when state is deactivated
	.AlwaysThinkLate ((simulation: Simulation, command: Command) -> ())? -- idk but i think it *always* runs last
]=]
export type SimulationModifier<C = {}, S = {}, CMD = {}> = {
	ModifySimulation: (
		self: SimulationModifier<C, S, CMD>,
		simulation: Simulation<C, S, CMD>
	) -> (),
	ActiveThink: (
		simulation: Simulation<C, S, CMD>,
		command: Command<CMD>
	) -> ()?,
	AlwaysThink: (
		simulation: Simulation<C, S, CMD>,
		command: Command<CMD>
	) -> ()?,
	StartState: (
		simulation: Simulation<C, S, CMD>,
		command: Command<CMD>
	) -> ()?,
	EndState: (
		simulation: Simulation<C, S, CMD>,
		command: Command<CMD>
	) -> ()?,
	AlwaysThinkLate: (
		simulation: Simulation<C, S, CMD>,
		command: Command<CMD>
	) -> ()?,
}

return nil
