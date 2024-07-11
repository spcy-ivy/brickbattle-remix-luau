--[[
	fast_spawn.luau

	plagiarized from [red-blox/utils spawn implementation](https://github.com/red-blox/Util/blob/main/libs/Spawn/Spawn.luau)

	reusing threads is faster than creating new ones
]]

local free_threads: { thread } = {}

local function run_callback(callback: () -> (), thread: thread, ...)
	callback(...)

	-- manual insertion is EVER SO SLIGHTLY faster than table.insert
	free_threads[#free_threads + 1] = thread
end

local function yielder()
	while true do
		run_callback(coroutine.yield())
	end
end

return function<T...>(callback: (T...) -> (), ...: T...)
	local thread: thread

	if #free_threads > 0 then
		thread, free_threads[#free_threads] =
			free_threads[#free_threads], nil
	else
		thread = coroutine.create(yielder)
		coroutine.resume(thread)
	end

	task.spawn(thread, callback, thread, ...)
end
