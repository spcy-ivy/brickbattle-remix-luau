--[[
	errors.luau

	i like zig's error handling better than `pcall`

	why not	`pcall`?
	1. theres no indicator that something can error
	2. thats like my only problem with it lmao

	why not rust's `result`?
	1. thats cool too :^), my unconscious likes zig's error handling better tho
	2. thats it i really like results too

	why zig's error handling?
	1. you know IF theres an error
	2. types make it explicit HOW the program can error
	3. heheheheh cool error convenience functions

	largely going to be inspied by this:
	https://www.aolium.com/karlseguin/4013ac14-2457-479b-e59b-e603c04673c8
	
	thank you blog :)

	- we wont add try, because... you can just do `if Error.type`
	- we dont add catch.. for the same reason
]]

export type Error<T> = { type: "ok", value: T } | { type: "error", value: string }

-- LMAO we dont have any utility functions yet
-- might not have any for a while... lol
-- the type itself is just that good i guess
type ErrorsModule = {}

local errors_module: ErrorsModule = {}

return errors_module
