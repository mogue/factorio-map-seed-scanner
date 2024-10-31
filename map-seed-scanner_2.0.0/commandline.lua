
local command_table = {}

commands.add_command("scanner", "Map seed scanner controls.", function (command)
	local subcommand = string.match(command.parameter, "([^%s]+)")
	command.parameter = string.match(command.parameter, "(%s.+)" )
	if command_table[subcommand] then
		command_table[subcommand](command)
	else
		game.player.print("Scanner: Unknown sub command (" .. subcommand ..")")
	end
end)

return command_table