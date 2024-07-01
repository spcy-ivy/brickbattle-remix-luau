--!optimize 2
--!native

--[[
	signal.luau

	optimizations stolen from [lemonsignal](https://data-oriented-house.github.io/LemonSignal/)

	why an unordered array and not lemonsignal's doubly linked list?
	1. from my speed tests they match in speed
	2. i dont need ordered firing
	3. i like the simpler implementation from an unordered array

	wheres my `new` and `disconnect_all`?
	1. since signals are just tables, you can create a signal just by creating an empty table! make sure to explicitly type it to `Signal` so that you know its a signal
	2. since signals are just tables, all you need to do to clear the table to disconnect everything!
]]

export type Signal<T...> = { Connection<T...> }

export type Connection<T...> = {
	connected: boolean,
	_signal: Signal<T...>,
	_index: number,
	_callback: (T...) -> (),
}

type SignalModule<T...> = {
	disconnect: <T...>(connection: Connection<T...>) -> (),

	connect: <T...>(
		signal: Signal<T...>,
		callback: (T...) -> ()
	) -> Connection<T...>,

	once: <T...>(
		signal: Signal<T...>,
		callback: (T...) -> ()
	) -> Connection<T...>,

	wait: <T...>(signal: Signal<T...>) -> (),
	fire: <T...>(signal: Signal<T...>, T...) -> (),
}

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

local function disconnect<T...>(connection: Connection<T...>)
	if not connection.connected then
		return
	end

	connection.connected = false

	local signal = connection._signal
	signal[connection._index], signal[#signal] = signal[#signal], nil
end

local function connect<T...>(
	signal: Signal<T...>,
	callback: (T...) -> ()
): Connection<T...>
	local index = #signal + 1
	local connection: Connection<T...> = {
		connected = true,
		_signal = signal,
		_index = index,
		_callback = callback,
	}

	signal[index] = connection

	return connection
end

local function once<T...>(
	signal: Signal<T...>,
	callback: (T...) -> ()
): Connection<T...>
	local connection: Connection<T...>

	connection = connect(signal, function(...)
		disconnect(connection)
		callback(...)
	end)

	return connection
end

local function wait<T...>(signal: Signal<T...>)
	local thread = coroutine.running()

	local connection: Connection<T...>

	connection = connect(signal, function(...)
		disconnect(connection)
		task.spawn(thread, ...)
	end)

	return coroutine.yield()
end

local function fire<T...>(signal: Signal<T...>, ...: T...)
	for _, connection in signal do
		local thread: thread

		if #free_threads > 0 then
			thread, free_threads[#free_threads] =
				free_threads[#free_threads], nil
		else
			thread = coroutine.create(yielder)
			coroutine.resume(thread)
		end

		task.spawn(thread, connection._callback, thread, ...)
	end
end

local signal_module: SignalModule<> = {
	disconnect = disconnect,

	connect = connect,
	once = once,
	wait = wait,
	fire = fire,
}

return signal_module
