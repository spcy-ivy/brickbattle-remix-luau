--[[
	bin.luau

	plagiarized from [red-blox/utils bin implementation]

	because i need to clean up my shit and maid is too bloated

	usage:
	```luau
	local bin = require([bin])

	local test: bin.Bin = {}

	table.add(bin, Instance.new("Part"))

	bin.empty(test)
	```
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local fast_spawn = require(ReplicatedStorage.global_shared.library.fast_spawn)

type BinItem = Instance | RBXScriptConnection | { [any]: any } | () -> ...any
type Bin = { BinItem }

type BinModule = {
	empty: (bin: Bin) -> (),
}

local function empty(bin: Bin)
	for _, item in bin do
		if typeof(item) == "Instance" then
			item:Destroy()
		elseif typeof(item) == "RBXScriptConnection" then
			item:Disconnect()
		elseif typeof(item) == "table" then
			table.clear(item)
		elseif typeof(item) == "function" then
			fast_spawn(item)
		end
	end

	table.clear(bin)
end

local bin_module: BinModule = {
	empty = empty,
}

return bin_module
