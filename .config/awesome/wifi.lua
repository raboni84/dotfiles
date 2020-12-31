local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local naughty = require("naughty")
local util = require("widgetutil")

local module = {}

module.icon = wibox.widget.textbox()
module.widget = wibox.widget.textbox()
module.wifiwidget = wibox.widget {
    module.icon,
    module.widget,
    layout = wibox.layout.align.horizontal,
}

function module.wifi_status()
    local fd = io.open("/proc/net/wireless", "r")
    if not fd then
        return "", ""
    end
    local data = fd:read("*all")
    fd:close()
    local card, wifi = string.match(data, "([a-z0-9]+:)[ ]+%d+[ ]+(%d+)")
    if not card then
        return "", ""
    end
    module.wificard = card:gsub(":", "")
    return "  ", util.percentToBar(math.floor(wifi * 100 / 70 + 0.5), true)
end

function module.getWidget()
    return module.wifiwidget
end

function module.updateWidget()
    local ico, val = module.wifi_status()
    module.icon:set_markup(ico)
    module.widget:set_markup(val)
end

module.wifiwidget:buttons(gears.table.join(awful.button({}, 1, function(t)
    if module.wificard then
        awful.spawn.easy_async_with_shell("iwctl station " .. module.wificard .. " scan && sleep 1",
            function(stdout, stderr, reason, exit_code)
                awful.spawn.easy_async_with_shell("iwctl station " .. module.wificard .. " get-networks",
                    function(stdout, stderr, reason, exit_code)
                        naughty.notify({
                            title = "SSIDs",
                            text = stdout:gsub(string.char(0x1b) .. "%[[%d;]+m", ""):gsub("\n\n", "\n"),
                            timeout = 0
                        })
                    end)
            end)
    end
end)))

module.updateWidget()

return module
