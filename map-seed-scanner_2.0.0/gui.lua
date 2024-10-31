local cmd = require("commandline")

local function show_message(title, msg, size)
	local frame = game.get_player(1).gui.center.container
	if frame then
		frame.destroy()
	end

	local flow  = game.get_player(1).gui.center
	frame = flow.add { type="frame", name = "container", direction ="vertical" }
	frame.add { type="label", caption=title, name="title", style="frame_title" } 

	local tbox = frame.add { type="text-box", text=msg, name="text_message" }
	tbox.style.horizontally_stretchable = true
	tbox.style.width  = size.width
	tbox.style.height = size.height
	tbox.read_only    = true
	tbox.selectable   = true
	tbox.word_wrap    = true
	tbox:select_all()

	local button = frame.add { type="button", caption="Close", name="close_message" }
end

local function exchange_string()
	show_message(
		"Map Exchange String", 
		game.surfaces[2].get_map_exchange_string(),
		{ width=420, height=240 }
	)
end

cmd["exchange_string"] = function (command)
	exchange_string()
end

cmd["seed"] = function (command)
	show_message(
		"Map Seed", 
		game.surfaces[2].map_gen_settings.seed,
		{ width=300, height=60 }
	)
end


script.on_event(defines.events.on_gui_click, function (e)
	local frame = game.get_player(1).gui.center.container
	if frame and (e.element.name == 'close_message') then
		frame.destroy()
	end
end)

return {
	show_message = show_message,
	exchange_string = exchange_string,
}