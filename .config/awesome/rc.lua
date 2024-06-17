-- If Luuncher/lauaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
	naughty.notify({
		preset = naughty.config.presets.critical,
		title = "Oops, there were errors during startup!",
		text = awesome.startup_errors,
	})
end

-- Handle runtime errors after startup
do
	local in_error = false
	awesome.connect_signal("debug::error", function(err)
		-- Make sure we don't go into an endless error loop
		if in_error then
			return
		end
		in_error = true

		naughty.notify({
			preset = naughty.config.presets.critical,
			title = "Oops, an error happened!",
			text = tostring(err),
		})
		in_error = false
	end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init("/home/cauri/.config/awesome/theme.lua")
gears.wallpaper.set("#000000")

-- This is used later as the default terminal and editor to run.
local terminal = "alacritty"
local launcher = "rofi -show drun -theme ~/.config/rofi/launchers/type-4/style-6.rasi"
local editor = os.getenv("nvim") or "editor"
local editor_cmd = terminal .. " -e " .. editor

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
	awful.layout.suit.tile,
	--awful.layout.suit.floating,
	--awful.layout.suit.tile.left,
	--awful.layout.suit.tile.bottom,
	--awful.layout.suit.tile.top,
	--awful.layout.suit.fair,
	--awful.layout.suit.fair.horizontal,
	--awful.layout.suit.spiral,
	--awful.layout.suit.spiral.dwindle,
	awful.layout.suit.max,
	--awful.layout.suit.max.fullscreen,
	--awful.layout.suit.magnifier,
	--awful.layout.suit.corner.nw,
	--awful.layout.suit.corner.ne,
	--awful.layout.suit.corner.sw,
	--awful.layout.suit.corner.se,
}
-- }}}

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibar
-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(awful.button({}, 1, function(t)
	t:view_only()
end))

local tasklist_buttons = gears.table.join(
	awful.button({}, 1, function(c)
		c:emit_signal("request::activate", "tasklist", { raise = true })
	end),
	awful.button({}, 3, function(c)
		c:kill()
	end)
)

awful.screen.connect_for_each_screen(function(s)
	-- Each screen has its own tag table.
	awful.tag({ "0", "1", "2", "3", "4", "5" }, s, awful.layout.layouts[1])

	-- Create an imagebox widget which will contain an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	s.layoutbox = awful.widget.layoutbox(s)
	s.layoutbox:buttons(gears.table.join(
		awful.button({}, 1, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 3, function()
			awful.layout.inc(-1)
		end)
	))
	-- Create a taglist widget
	s.taglist = awful.widget.taglist({
		screen = s,
		filter = awful.widget.taglist.filter.all,
		buttons = taglist_buttons,
	})

	-- Create a tasklist widget
	s.tasklist = awful.widget.tasklist({
		screen = s,
		filter = awful.widget.tasklist.filter.currenttags,
		buttons = tasklist_buttons,
		widget_template = {
			{
				{
					id = "text_role",
					widget = wibox.widget.textbox,
				},
				layout = wibox.layout.fixed.horizontal,
			},
			left = 20,
			right = 20,
			widget = wibox.container.margin,
		},
	})

	-- Create the wibox
	s.wibox = awful.wibar({ position = "top", screen = s, border_width = 5 })

	-- Add widgets to the wibox
	s.wibox:setup({
		layout = wibox.layout.align.horizontal,
		{
			layout = wibox.layout.fixed.horizontal,
			spacing = 12,
			s.layoutbox,
			s.taglist,
		},
		s.tasklist,
		{
			layout = wibox.layout.fixed.horizontal,
			awful.widget.keyboardlayout(),
			wibox.widget.systray(),
			wibox.widget.textclock(),
		},
	})
end)

for s in screen do
	s.tags[2]:view_only()
end
-- }}}

-- {{{ Key bindings

local ctrl = "Control"
local meta = "Mod4"
local alt = "Mod1"
local shift = "Shift"

local globalkeys = gears.table.join(
	awful.key({ meta, ctrl }, "s", hotkeys_popup.show_help, { description = "show help", group = "awesome" }),

	awful.key({ meta, ctrl }, "r", awesome.restart, { description = "reload awesome", group = "awesome" }),

	awful.key({ meta, ctrl }, "q", awesome.quit, { description = "quit awesome", group = "awesome" }),

	awful.key({ meta }, "f", function()
		awful.client.focus.byidx(1)
	end, { description = "focus next window", group = "awesome: focus" }),

	awful.key({ meta }, "d", function()
		awful.client.focus.byidx(-1)
	end, { description = "focus previous window", group = "awesome: focus" }),

	awful.key({ ctrl }, "Tab", function()
		awful.screen.focus_relative(1)
	end, { description = "focus next screen", group = "awesome: focus" }),

	-- Layout manipulation
	awful.key({ meta, ctrl }, "f", function()
		awful.client.swap.byidx(1)
	end, { description = "swap with next window", group = "awesome: focused window" }),

	awful.key({ meta, ctrl }, "d", function()
		awful.client.swap.byidx(-1)
	end, { description = "swap with previous window", group = "awesome: focused window" }),

	awful.key({ meta }, "g", function()
		awful.tag.incmwfact(0.05)
	end, { description = "increase main column width", group = "awesome: layout" }),

	awful.key({ meta }, "s", function()
		awful.tag.incmwfact(-0.05)
	end, { description = "decrease main column width", group = "awesome: layout" }),

	awful.key({ meta, shift }, "d", function()
		awful.tag.incnmaster(1, nil, true)
	end, { description = "increase the number of main windows", group = "awesome: layout" }),

	awful.key({ meta, shift }, "f", function()
		awful.tag.incnmaster(-1, nil, true)
	end, { description = "decrease the number of main windows", group = "awesome: layout" }),

	awful.key({ meta, shift }, "g", function()
		awful.tag.incncol(1, nil, true)
	end, { description = "increase the number of columns", group = "awesome: layout" }),

	awful.key({ meta, shift }, "s", function()
		awful.tag.incncol(-1, nil, true)
	end, { description = "decrease the number of columns", group = "awesome: layout" }),

	awful.key({ meta }, "a", function()
		awful.layout.inc(1)
	end, { description = "select next layout", group = "awesome: layout" }),

	-- Applications
	awful.key({ ctrl }, "Return", function()
		awful.util.spawn(launcher)
	end, { description = "application launcher", group = "awesome: applications" }),

	awful.key({ meta }, "t", function()
		awful.spawn(terminal)
	end, { description = "open terminal", group = "awesome: applications" })
)

local clientkeys = gears.table.join(
	awful.key({ ctrl, meta }, "Tab", function(c)
		c:move_to_screen()
	end, { description = "move to next screen", group = "awesome: focused window" }),

	awful.key({ ctrl }, "q", function(c)
		c:kill()
	end, { description = "close window", group = "awesome: focused window" }),

	awful.key({ meta }, "m", function(c)
		c.maximized = not c.maximized
		c:raise()
	end, { description = "(un)maximize", group = "awesome: focused window" })
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 0, 5 do
	local hotkey

	if i == 0 then
		hotkey = "Escape"
	else
		hotkey = i
	end

	globalkeys = gears.table.join(
		globalkeys,

		-- View tag only.
		awful.key({ ctrl }, hotkey, function()
			local screen = awful.screen.focused()
			local tag = screen.tags[i + 1]
			if tag then
				tag:view_only()
			end
		end, { description = "view workspace #" .. i, group = "awesome: workspaces" }),

		-- Move client to tag.
		awful.key({ ctrl, meta }, hotkey, function()
			if client.focus then
				local tag = client.focus.screen.tags[i + 1]
				if tag then
					client.focus:move_to_tag(tag)
				end
			end
		end, { description = "move focused window to workspace #" .. i, group = "awesome: workspaces" })
	)
end

local clientbuttons = gears.table.join(
	awful.button({}, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
	end),
	awful.button({ meta }, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.move(c)
	end),
	awful.button({ meta }, 3, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.resize(c)
	end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
	-- All clients will match this rule.
	{
		rule = {},
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = awful.client.focus.filter,
			raise = true,
			keys = clientkeys,
			buttons = clientbuttons,
			screen = awful.screen.preferred,
			placement = awful.placement.no_overlap + awful.placement.no_offscreen,
		},
	},

	-- Set Firefox to always map on the tag named "2" on screen 1.
	-- { rule = { class = "Firefox" },
	--   properties = { screen = 1, tag = "2" } },
	{
		rule_any = {
			class = {
				"discord",
			},
		},
		properties = {
			screen = awful.screen.primary,
			tag = "0",
		},
	},
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
	c.shape = gears.shape.rounded_rect

	-- Set the windows at the slave,
	-- i.e. put it at the end of others instead of setting it master.
	if not awesome.startup then
		awful.client.setslave(c)
	end

	if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
		-- Prevent clients from being unreachable after screen count changes.
		awful.placement.no_offscreen(c)
	end
end)

client.connect_signal("focus", function(c)
	c.border_color = beautiful.border_focus
end)
client.connect_signal("unfocus", function(c)
	c.border_color = beautiful.border_normal
end)

-- Autostart applications
awful.spawn.with_shell("~/.config/awesome/autorun.sh")
