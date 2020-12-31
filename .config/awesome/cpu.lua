local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local naughty = require("naughty")
local util = require("widgetutil")

local module = {}

module.icon = wibox.widget.textbox()
module.widget = wibox.widget.textbox()
module.cpuwidget = wibox.widget {
    module.icon,
    module.widget,
    layout = wibox.layout.align.horizontal
}
module.previdle = 0
module.prevtotal = 0

function module.cpu_status()
    local fd = io.open("/proc/stat", "r")
    if not fd then
        return "", ""
    end
    local data = fd:read()
    fd:close()
    local total = 0
    local idle = 0
    local diff = 0
    local i = 0
    for match in string.gmatch(data, "%d+") do
        total = total + tonumber(match)
        i = i + 1
        if i == 4 then
            idle = tonumber(match)
        end
    end
    diff = math.floor((idle - module.previdle) * 100 / (total - module.prevtotal) + 0.5)
    module.previdle = idle
    module.prevtotal = total
    return "  ", util.percentToBar(diff, true)
end

function module.getWidget()
    return module.cpuwidget
end

function module.updateWidget()
    local ico, val = module.cpu_status()
    module.icon:set_markup(ico)
    module.widget:set_markup(val)
end

module.cpuwidget:buttons(gears.table.join(awful.button({}, 1, function(t)
    awful.spawn.easy_async_with_shell("ps -e --sort=-pcpu -o pid,pcpu,comm | head -n 11",
        function(stdout, stderr, reason, exit_code)
            naughty.notify({
                title = "Most CPU% consuming processes",
                text = stdout:sub(1, #stdout - 1)
            })
        end)
end)))

module.updateWidget()

return module
