local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local naughty = require("naughty")
local util = require("widgetutil")

local module = {}

module.icon = wibox.widget.textbox()
module.widget = wibox.widget.textbox()
module.weatherwidget = wibox.widget {
    module.icon,
    module.widget,
    layout = wibox.layout.align.horizontal
}

function module.weather_status()
    awful.spawn.easy_async_with_shell("curl --compressed http://ip-api.com/line/?fields=192",
        function(stdout, stderr, reason, exit_code)
            if not stdout then
                module.icon:set_markup("")
                module.widget:set_markup("")
                goto continue
            end
            local region = stdout:gsub("[\r\n]", ","):sub(1, -2)
            local url = "curl --compressed wttr.in/" .. region .. "?format=\"%f\""
            awful.spawn.easy_async_with_shell(url, function(stdout, stderr, reason, exit_code)
                if not stdout then
                    module.icon:set_markup("")
                    module.widget:set_markup("")
                    goto continue2
                end
                module.icon:set_markup("  ")
                module.widget:set_markup(stdout:gsub("+", ""))
                ::continue2::
            end)
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
    awful.spawn.easy_async_with_shell("curl --compressed http://ip-api.com/line/?fields=192",
        function(stdout, stderr, reason, exit_code)
            if not stdout then
                module.icon:set_markup("")
                module.widget:set_markup("")
                goto continue
            end
            local region = stdout:gsub("[\r\n]", ","):sub(1, -2)
            local url = "curl -H \"Accept-Language: ${LANG%_*}\" --compressed wttr.in/" .. region .. "?2FT"
            awful.spawn.easy_async_with_shell(url, function(stdout, stderr, reason, exit_code)
                    naughty.notify({
                        text = stdout:sub(1, -2),
                        font = "DejaVu Sans Mono 9",
                        timeout = 0
                    })
                end)
            ::continue::
        end)
end)))

module.updateWidget()

return module
