local ReplicatedStorage = game:GetService("ReplicatedStorage")
local type_guard = require(ReplicatedStorage.global_shared.library.type_guard)

local guard = type_guard.includes({
	meow = type_guard.number,
	mrow = type_guard.boolean,
})

return function()
	print(guard({
		arf = 10,
		bark = true,
	}))

	print(guard({
		meow = 10,
		bark = true,
	}))

	print(guard({
		mrow = 10,
		bark = true,
	}))

	print(guard({
		meow = 10,
		mrow = true,
		bark = false,
		other = 123981238,
	}))
end
