--[[
	signal.luau

	credits to [lemonsignal](https://data-oriented-house.github.io/LemonSignal/) for most of the optimization
	i like to use custom signals because theyre fast and theyre a good way for some reactive stuff to go down

	why not LemonSignal itself?
	1. from my benchmarks theyre essentially neck and neck just tied
	2. i just like an unordered array implementation becuase i dont need the `reconnect` function and because i think its simpler and easier to grasp
]]

--!optimize 2
--!native

type SignalModule = {
	disconnect: (connection: Connection) -> (),

	new: () -> Signal,
	connect: (signal: Signal, callback: (...any) -> ()) -> Connection,
	once: (signal: Signal, callback: (...any) -> ()) -> Connection,
	wait: (signal: Signal) -> (),
	fire: (signal: Signal, ...any) -> (),
	destroy: (signal: Signal) -> (),
}

export type Signal = {
	_connections: { Connection },
}

type Connection = {
	connected: boolean,
	_signal: Signal,
	_index: number,
	_callback: (...any) -> (),
}

local free_threads: { thread } = {}

local function run_callback(callback: () -> (), thread: thread, ...: unknown)
	callback(...)
	table.insert(free_threads, thread)
end

local function yielder()
	while true do
		run_callback(coroutine.yield())
	end
end

local function disconnect(connection: Connection)
	if not connection.connected then
		return
	end

	connection.connected = false

	local connections = connection._signal._connections
	connections[connection._index] = connections[#connections]
	connections[#connections] = nil
end

local function new(): Signal
	return { _connections = {} }
end

local function connect(signal: Signal, callback: (...any) -> ()): Connection
	local index = #signal._connections + 1
	local connection: Connection = {
		connected = true,
		_signal = signal,
		_index = index,
		_callback = callback,
	}

	signal._connections[index] = connection
	return connection
end

local function once(signal: Signal, callback: (...any) -> ()): Connection
	local connection: Connection

	connection = connect(signal, function(...)
		disconnect(connection)
		callback(...)
	end)

	return connection
end

local function wait(signal: Signal)
	local thread = coroutine.running()
	local connection: Connection

	connection = connect(signal, function(...)
		disconnect(connection)
		task.spawn(thread, ...)
	end)

	return coroutine.yield()
end

local function fire(signal: Signal, ...: any)
	local thread: thread
	if #free_threads > 0 then
		thread = free_threads[#free_threads]
		free_threads[#free_threads] = nil
	else
		thread = coroutine.create(yielder)
		coroutine.resume(thread)
	end

	for _, connection in signal._connections do
		task.spawn(thread, connection._callback, thread, ...)
	end
end

local function destroy(signal: Signal)
	for _, connection in signal._connections do
		disconnect(connection)
	end
end

local signal_module: SignalModule = {
	disconnect = disconnect,

	new = new,
	connect = connect,
	once = once,
	wait = wait,
	fire = fire,
	destroy = destroy,
}

return signal_module
