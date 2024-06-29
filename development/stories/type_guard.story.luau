local ReplicatedStorage = game:GetService("ReplicatedStorage")
local type_guard = require(ReplicatedStorage.global_shared.library.type_guard)

local lemon_guard = type_guard.interface({
	size = type_guard.number,
	sour = type_guard.number,
})

local lemon = {
	size = 1,
	sour = 1,
}

local watermelon = {
	size = 2,
	sour = 0,
	sweet = 1,
}

local confused_lemon = {
	size = 1,
	sour = true,
}

local none = nil

return function()
	print("lemon (should be true)")
	print(lemon_guard(lemon))

	print("watermelon (should be false)")
	print(lemon_guard(watermelon))

	print("confused_lemon (should be false)")
	print(lemon_guard(confused_lemon))

	print("none (should be false)")
	print(lemon_guard(none))
end
