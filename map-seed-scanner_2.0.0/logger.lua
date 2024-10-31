
local filepath = "MapSeedScanner/_scans.log"

local function path(filename)
	if filename then
		filepath = "MapSeedScanner/" .. filename
	end
	return filepath
end

local function empty()
	game.write_file(filepath, "", false)
end

local function append(str)
	game.get_player(1).print(filepath .. " : " .. str)
	helpers.write_file(filepath, str, true)
end

local function dump(str, path)
    helpers.write_file(path, str, false)
    game.get_player(1).print(path)
end

return {
	path = path,
	append = append,
	empty = empty,
    dump = dump
}