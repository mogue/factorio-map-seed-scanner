local logger = require("logger")

-- Initialize any positions used by the analyzer
local spawn_position = {x=0,y=6}
local crash_site_position = {x=-5,y=-6}

local settings = {
	force_generate = false, -- Faster processing
	chunk_radius = 3
}

local scan_count = 0
local match_count = 0

local function iterate(map_gen_settings)
	map_gen_settings.seed = map_gen_settings.seed + 1
	return map_gen_settings
end

local function validate(surface)
	scan_count = scan_count + 1

	-- 1+ coal rock 10 tiles from spawn
	if surface.count_entities_filtered({ 
		position = spawn_position,
		radius   = 8,
		name	 = "rock-huge",
	}) < 1 then
		return false
	end

	-- 5+ coal rocks 40 tiles from spawn
	if surface.count_entities_filtered({
		position = spawn_position,
		radius   = 60,
		name	 = "rock-huge",
	}) < 5 then
		return false
	end

--[[
	-- Iron patch in 10 tiles from spawn
	if surface.count_entities_filtered({
		position = spawn_position,
		radius 	 = 20,
		name 	 = "iron-ore",
		limit	 = 1,
	}) < 1 then
		return false
	end

	-- Copper patch in 30 tiles from spawn
	if surface.count_entities_filtered({
		position = spawn_position,
		radius 	 = 30,
		name 	 = "copper-ore",
		limit	 = 1,
	}) < 1 then
		return false
	end


	-- Coal patch in 40 tiles from spawn
	if surface.count_entities_filtered({ 
		position = spawn_position,
		radius 	 = 40,
		name 	 = "coal",
		limit	 = 1,
	}) < 1 then
		return false
	end

	-- Stone patch in 60 tiles from spawn
	if surface.count_entities_filtered({ 
		position = spawn_position,
		radius 	 = 60,
		name 	 = "stone",
		limit	 = 1,
	}) < 1 then
		return false
	end
]]--

    match_count = match_count + 1

	logger.append(
		"(" .. scan_count .. ") Seed: " .. surface.map_gen_settings.seed .. "\n" ..
		"Exchange string:\n" .. surface.get_map_exchange_string() .. "\n\n"

	)
	return true
end

local analyzer = {
	settings = settings,
	iterate  = iterate,
	validate = validate,
}

return analyzer