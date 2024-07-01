--[[
	testing.luau

	im too lazy to test myself and debug
]]

export type Tests = { [string]: { [string]: () -> boolean } }

export type TestingScript = () -> Tests

type TestingModule = {}

local testing_module: TestingModule = {}

return testing_module
