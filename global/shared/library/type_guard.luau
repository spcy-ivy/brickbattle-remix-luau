--[=[
	type_guard.luau

	because we dont have `typeof` for table types and that makes me sad :(
	i know it seems inconvenient to basically define the type twice but i promise its a lot better than doing super long if statements

	basically just rips off https://github.com/red-blox/Util/blob/main/libs/Guard/Guard.luau

	this should only be used for relatively complex types! you should just use `typeof` if you want to check basic types

	the cast function from [ty](https://github.com/dphfox/ty) is in here, but its commented since i dont know if its necessary or not

	i dont want to delete my code though!!!! my baby!!!
]=]

-- local errors = require(script.Parent.errors)

export type Check = (value: unknown) -> boolean
export type Interface = { [string]: Check }

-- we use typescript terminology here
type TypeGuardModule = {
	any: Check,
	boolean: Check,
	thread: Check,
	undefined: Check,
	number: Check,
	string: Check,
	lambda: Check,
	intersection: (first: Check, second: Check) -> Check,
	union: (first: Check, second: Check) -> Check,
	nullable: (check: Check) -> Check,
	map: (key_check: Check, value_check: Check) -> Check,
	list: (check: Check) -> Check,
	interface: (definition: Interface) -> Check,
	includes: (definition: Interface) -> Check,
	-- cast: <T>(value: unknown, check: Check) -> errors.Error<T, string>,
}

--- go crazy
local any: Check = function(_value: unknown)
	return true
end

--- checks if something is a boolean
local boolean: Check = function(value: unknown)
	return type(value) == "boolean"
end

--- checks if something is a thread
local thread: Check = function(value: unknown)
	return type(value) == "thread"
end

--- checks if something is a undefined
local undefined: Check = function(value: unknown)
	return value == nil
end

--- checks if something is a number
local number: Check = function(value: unknown)
	return type(value) == "number"
end

--- checks if something is a string
local string: Check = function(value: unknown)
	return type(value) == "string"
end

--- checks if something is a lambda
local lambda: Check = function(value: unknown)
	return type(value) == "function"
end

--- the `or` for two types
local function intersection(first: Check, second: Check): Check
	return function(value: unknown)
		return first(value) or second(value)
	end
end

--- the `and` for two types
local function union(first: Check, second: Check): Check
	return function(value: unknown)
		return first(value) and second(value)
	end
end

--- the `?` for a type
local function nullable(check: Check): Check
	return function(value: unknown)
		return if value == nil then true else check(value)
	end
end

--- 1:1 check for a dictionary
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

--- 1:1 check for a table
local function list(check: Check): Check
	return function(value: unknown)
		if type(value) == "table" then
			return false
		end

		--[=[
			we use maxn instead of # becuase if you have a list like this:
			thingies = ["hi!", "hello!", nil, "bye!"]
			
			`#thingies` would end at nil, returning 3
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

--- map but you actually have to make it a dictionary
local function interface(definition: Interface): Check
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

--- interface but missing keys are forgiven
-- really shitty counting solution but im too lazy to do anything clever
local function includes(definition: Interface): Check
	local indexes = 0

	for _, _ in definition do
		indexes += 1
	end

	return function(value: unknown)
		if type(value) ~= "table" then
			return false
		end

		local matching_indexes = 0

		for key, v in value :: any do
			local check = definition[key]

			if check == nil then
				continue
			end

			if not check(v) then
				return false
			end

			matching_indexes += 1
		end

		return matching_indexes == indexes
	end
end

--[=[
	i may need this function, i may not
	will uncomment and let free if i decide its not bloat

	this is mainly to just replace manual type casting, but i dont know the viability yet!

	local function cast<T>(value: unknown, check: Check): errors.Error<T, string>
		if check(value) then
			return {
				type = "ok",
				value = value :: T,
			}
		end

		return {
			type = "error",
			value = "Type check was not successful",
		}
	end
]=]

local type_guard_module: TypeGuardModule = {
	any = any,
	boolean = boolean,
	thread = thread,
	undefined = undefined,
	number = number,
	string = string,
	lambda = lambda,
	intersection = intersection,
	union = union,
	nullable = nullable,
	map = map,
	list = list,
	interface = interface,
	includes = includes,
	-- cast = cast,
}

return type_guard_module
