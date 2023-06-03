-- Factorio Utils
local util = require("util")
local crash_site = require("crash-site")

-- Basic Utils
local cmd = require("commandline")
local logger = require("logger")
local gui = require("gui")

-- Modify the analyzer to change the search
local analyzer = require("analyzer")

local default_match_results = require("matches_dump")

local profiler = nil
local gs = nil -- global.settings

local scan_count     = 0
local watch          = false

-- Teleporter

local teleport_index = 0
local teleport_on_surface_deleted = function (e)
    game.create_surface("probe_surface", game.parse_map_exchange_string( global.match_results[teleport_index] ).map_gen_settings)
    game.get_player(1).teleport({ x=0, y=0 }, "probe_surface")
    crash_site.create_crash_site(game.get_surface("probe_surface"), {-5,-6}, {}, {}, crash_site.default_ship_parts())
    gui.exchange_string()
    game.get_player(1).print("Teleported to match result " .. teleport_index)
    script.on_event(defines.events.on_surface_deleted, nil)
end

local function teleport_to_map(match_index)
    if (match_index < 1 or match_index > #global.match_results) then
        game.get_player(1).print("Match index " .. match_index .. " not found.")
        return false
    end
    teleport_index = match_index
    if not game.get_surface("probe_surface") then
	    teleport_on_surface_deleted()
    else
        script.on_event(defines.events.on_surface_deleted, teleport_on_surface_deleted)
		game.delete_surface("probe_surface")
    end
end

-- Stop the Scanner

local function stop()
	game.get_player(1).print("Scanner stopped.")
	profiler.stop()
	game.tick_paused = false
    script.on_event(defines.events.on_surface_deleted, nil)
    script.on_event(defines.events.on_surface_created, nil)
    script.on_event(defines.events.on_chunk_generated, nil)
    script.on_event(defines.events.on_tick, nil)
    teleport_to_map(#global.match_results)
end

-- Scan Events

local scan_on_surface_deleted = function(e)
    if ( analyzer.iterate(global.map_gen_settings) ) then
        game.create_surface("probe_surface", global.map_gen_settings)
    else
        stop()
    end
end

local scan_on_surface_created = function(e)
--	game.get_player(1).print("Scanning surface " .. e.surface_index .. " seed: " ..  global.map_gen_settings.seed)
    game.surfaces[e.surface_index].request_to_generate_chunks ({ x=0, y=0 }, gs.chunk_radius)
    if gs.force_generate then
        game.surfaces[e.surface_index].force_generate_chunk_requests()
    end
    if watch then
        game.get_player(1).teleport({ x=0, y=0 }, "probe_surface")
    end
end

local scan_on_chunk_generated = function(e)
--	game.get_player(1).print("Chunk " .. e.surface.name .. " - " .. e.position.x .. "x" .. e.position.y )
    if e.surface.name ~= "probe_surface" then
        return false
    end
    if e.position.x == gs.chunk_radius and e.position.y == gs.chunk_radius then
        local match_found = analyzer.validate(e.surface)
        scan_count = scan_count + 1
        if match_found then
            table.insert(global.match_results, e.surface:get_map_exchange_string() )
        end

        game.ticks_to_run = 1
    end
end

local scan_on_tick = function (e)
    game.delete_surface("probe_surface")
end

-- Start the Scanner

local function start()
	game.get_player(1).print("Scanner started.")
	profiler.reset()
	game.tick_paused = true
    script.on_event(defines.events.on_surface_deleted, scan_on_surface_deleted)
    script.on_event(defines.events.on_surface_created, scan_on_surface_created)
    script.on_event(defines.events.on_chunk_generated, scan_on_chunk_generated)
    script.on_event(defines.events.on_tick, scan_on_tick)
	if game.get_surface("probe_surface") then
		game.delete_surface("probe_surface")
    else
        game.create_surface("probe_surface", global.map_gen_settings)
    end
end

-- Init Events

script.on_init(function ()
	local surf = game.surfaces[1]

	profiler = game.create_profiler()
	gs = analyzer.settings

	global.settings = gs
    global.match_results = default_match_results
	global.map_gen_settings = util.copy(surf.map_gen_settings)

	logger.path("seed_" .. surf.map_gen_settings.seed .. ".log")
	remote.call("freeplay", "set_disable_crashsite", true)
	remote.call("freeplay", "set_skip_intro", true)
end)

script.on_event(defines.events.on_player_created, function (e)
	game.surfaces[1].generate_with_lab_tiles    = true
	game.surfaces[1].freeze_daytime 	        = true
	game.surfaces[1].show_clouds 		        = false
	game.surfaces[1].clear(true)
end)

-- Command line hooks

cmd["watch"] = function(command)
	watch = not watch
end

cmd["start"] = function(command)
	start()
end

cmd["stop"] = function(command)
	stop()
end

cmd["log"] = function(command)
	logger.append(command.parameter)
end

cmd["matches_dump"] = function(command)
    logger.dump(
        "return " .. serpent.block(global.match_results),
        "MapSeedScanner/matches_dump.lua"
    )
end

cmd["reset"] = function(command)
	global.map_gen_settings = util.copy(surf.map_gen_settings)
end

cmd["goto"] = function(command)
    if game.tick_paused then
        game.get_player(1).print("Stop the scanner before using goto.")
        return false
    end
    if command.parameter == nil or type( tonumber(command.parameter) ) ~= "number" then
        game.get_player(1).print("Please use a number.")
        return false
    end
    teleport_to_map(tonumber(command.parameter))
end

cmd["status"] = function(command)
	local average = game.create_profiler(true)
	average.add(profiler)
    if scan_count > 0 then
        average.divide(scan_count)
    end

	game.get_player(1).print({"",
		"Scanner is ", (game.tick_paused and 'ON' or 'OFF'), "\n",
		"Matches found: ", #global.match_results, "\n",
		"Scans done: ", scan_count, "\n",
		"Average Scan ", average, "\n",
	})
end