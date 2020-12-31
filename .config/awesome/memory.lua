local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local naughty = require("naughty")
local util = require("widgetutil")

local module = {}

module.icon = wibox.widget.textbox()
module.widget = wibox.widget.textbox()
module.memwidget = wibox.widget {
    module.icon,
    module.widget,
    layout = wibox.layout.align.horizontal,
}

function module.mem_status()
    local fd = io.open("/proc/meminfo", "r")
    if not fd then
        return "", ""
    end
    local data = fd:read("*all")
    fd:close()
    local memtotal = tonumber(string.match(data, "MemTotal:[ ]+(%d+)"))
    local memavail = tonumber(string.match(data, "MemAvailable:[ ]+(%d+)"))
    local swptotal = tonumber(string.match(data, "SwapTotal:[ ]+(%d+)"))
    local swpavail = tonumber(string.match(data, "SwapFree:[ ]+(%d+)"))
    local total = 0
    local avail = 0
    if memtotal > 0 and swptotal == 0 then
        total = memtotal
        avail = memavail
    elseif memtotal > 0 and swptotal > 0 then
        total = memtotal + swptotal
        avail = memavail + swpavail
    end
    if total == 0 then
       return "", ""
    else
       return "  ", util.percentToBar(math.floor(avail * 100 / total + 0.5), true)
    end
end

function module.getWidget()
    return module.memwidget
end

function module.updateWidget()
    local ico, val = module.mem_status()
    module.icon:set_markup(ico)
    module.widget:set_markup(val)
end

module.memwidget:buttons(gears.table.join(awful.button({}, 1, function(t)
    awful.spawn.easy_async_with_shell("ps -e --sort=-pmem -o pid,pmem,comm | head -n 11",
        function(stdout, stderr, reason, exit_code)
            naughty.notify({
                title = "Most MEM% consuming processes",
                text = stdout:sub(1, #stdout - 1)
            })
        end)
end)))

module.updateWidget()

return module
