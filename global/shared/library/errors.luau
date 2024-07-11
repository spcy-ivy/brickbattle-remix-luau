--[[
	errors.luau

	why have this type and wrapper for it in the first place?
	1. i dont like runtime errors :(
	2. i like when a type tells me something will error
	3. i like when the LSP whines at me like a little baby when i dont handle an error (annoying fucking LSP... shut the fuck up)
]]

export type Error<T, E> = { type: "ok", value: T } | { type: "error", value: E }

-- LMAO we dont have any utility functions yet
-- might not have any for a while... lol
-- the type itself is just that good i guess
type ErrorsModule = {}

local errors_module: ErrorsModule = {}

return errors_module
