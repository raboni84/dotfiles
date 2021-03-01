local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local naughty = require("naughty")
local util = require("widgetutil")

local module = {}

module.icon = wibox.widget.textbox()
module.widget = wibox.widget.textbox()
module.location = ""
module.weatherwidget = wibox.widget {
    module.icon,
    module.widget,
    layout = wibox.layout.align.horizontal
}

local fd = io.open(gears.filesystem.get_xdg_config_home() .. "weather.loc", "r")
if fd ~= nil then
    module.location = fd:read():gsub("[\":/.]","")
    fd:close()
end

function module.weather_status()
    awful.spawn.easy_async_with_shell("curl -H \"Accept-Language: ${LANG%_*}\" \"wttr.in/" .. module.location .. "?M&format=%f %w %p\"",
        function(stdout, stderr, reason, exit_code)
            if not stdout then
                module.icon:set_markup("")
                module.widget:set_markup("")
                goto continue
            end
            module.icon:set_markup("  ") -- umbrella
            module.widget:set_markup(stdout:gsub("+", ""):gsub("°C","℃"):gsub("m/s","㎧"):gsub("mm","㎜"))
            ::continue::
        end)
end

function module.getWidget()
    return module.weatherwidget
end

function module.updateWidget()
    module.weather_status()
end

module.weatherwidget:buttons(gears.table.join(awful.button({}, 1, function(t)
    awful.spawn.easy_async_with_shell("curl -H \"Accept-Language: ${LANG%_*}\" \"http://wttr.in/" .. module.location .. "?2MFT\"",
        function(stdout, stderr, reason, exit_code)
            if not stdout then
                module.icon:set_markup("")
                module.widget:set_markup("")
                goto continue
            end
            naughty.notify({
                text = stdout:sub(1, -2),
                font = "DejaVu Sans Mono 9",
                timeout = 0
            })
            ::continue::
        end)
end)))

module.updateWidget()

return module
