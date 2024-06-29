--[=[
	type_guard.luau

	because we dont have `typeof` for table types and that makes me sad :(
	i know it seems inconvenient to basically define the type twice but i promise its a lot better than doing super long if statements

	basically just rips off https://github.com/red-blox/Util/blob/main/libs/Guard/Guard.luau

	this should only be used for relatively complex types! you should just use `typeof` if you want to check basic types
]=]

export type Check = (value: unknown) -> boolean

-- we use typescript terminology here
type TypeGuardModule = {
	any: Check,
	boolean: Check,
	thread: Check,
	undefined: Check,
	number: Check,
	string: Check,
	intersection: (first: Check, second: Check) -> Check,
	union: (first: Check, second: Check) -> Check,
	nullable: (check: Check) -> Check,
	map: (key_check: Check, value_check: Check) -> Check,
	list: (check: Check) -> Check,
	interface: (definition: { [string]: Check }) -> Check,
}

local any: Check = function(_value: unknown)
	return true
end

local boolean: Check = function(value: unknown)
	return type(value) == "boolean"
end

local thread: Check = function(value: unknown)
	return type(value) == "thread"
end

local undefined: Check = function(value: unknown)
	return value == nil
end

local number: Check = function(value: unknown)
	return type(value) == "number"
end

local string: Check = function(value: unknown)
	return type(value) == "string"
end

local function intersection(first: Check, second: Check): Check
	return function(value: unknown)
		return first(value) or second(value)
	end
end

local function union(first: Check, second: Check): Check
	return function(value: unknown)
		return first(value) and second(value)
	end
end

local function nullable(check: Check): Check
	return function(value: unknown)
		return if value == nil then true else check(value)
	end
end

local function map(key_check: Check, value_check: Check): Check
	return function(value: unknown)
		if type(value) ~= "table" then
			return false
		end

		-- have to use shorthand names... im so sorry...
		for key, map_value in value :: any do
			if not key_check(key) or not value_check(map_value) then
				return false
			end
		end

		return true
	end
end

local function list(check: Check): Check
	return function(value: unknown)
		if type(value) == "table" then
			return false
		end

		--[=[
			we use maxn instead of # becuase if you have a list like this:
			["hi!", "hello!", nil, "bye!"]
			
			`#` would end at nil, returning 3
			table.maxn is smarter, and doesnt end at the nil, returning 4
		]=]
		for index = 1, table.maxn(value :: any) do
			if not check((value :: any)[index]) then
				return false
			end
		end

		return true
	end
end

local function interface(definition: { [string]: Check }): Check
	return function(value: unknown)
		if type(value) ~= "table" then
			return false
		end

		-- sorry for the single letter variable im too lazy to come up with something clever
		for key, v in value :: any do
			local check = definition[key]

			if check == nil then
				return false
			end

			if not check(v) then
				return false
			end
		end

		return true
	end
end

local type_guard_module: TypeGuardModule = {
	any = any,
	boolean = boolean,
	thread = thread,
	undefined = undefined,
	number = number,
	string = string,
	intersection = intersection,
	union = union,
	nullable = nullable,
	map = map,
	list = list,
	interface = interface,
}

return type_guard_module
