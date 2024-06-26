--[[
	signal.luau

	credits to [lemonsignal](https://data-oriented-house.github.io/LemonSignal/) for most of the optimizations
	i like to use custom signals because theyre fast and theyre a good way for some reactive stuff to go down

	why use an unordered array instead of LemonSignal itself?
		1. its a simpler implementation
		2. it did pretty well on the benchmarks
		3. if you remove :Reconnect (a feature i largely do not need) an unordered array implementation is faster overall
]]

--!optimize 2
--!native

type SignalModule = {
	disconnect: (connection: Connection) -> (),

	new: () -> Signal,
	connect: (signal: Signal, callback: (...any) -> ()) -> Connection,
	fire: (signal: Signal, ...any) -> (),
}

type Signal = {
	_connections: { Connection },
}

type Connection = {
	connected: boolean,
	_signal: Signal,
	_index: number,
	_callback: (...any) -> (),
}

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

local function fire(signal: Signal, ...: any)
	for _, connection in signal._connections do
		connection._callback(...)
	end
end

return {
	disconnect = disconnect,

	new = new,
	connect = connect,
	fire = fire,
} :: SignalModule
