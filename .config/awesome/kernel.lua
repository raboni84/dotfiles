local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local naughty = require("naughty")
local util = require("widgetutil")

local module = {}

module.icon = wibox.widget.textbox()
module.widget = wibox.widget.textbox()
module.kernelwidget = wibox.widget {
    module.icon,
    module.widget,
    layout = wibox.layout.align.horizontal,
}

function module.kernel_status()
    awful.spawn.easy_async_with_shell("uname -r", function(stdout, stderr, reason, exit_code)
        if not stdout then
            module.icon:set_markup("")
            module.widget:set_markup("")
            goto continue
        end
        module.icon:set_markup("  ")
        module.widget:set_markup(stdout:gsub("([^-]*).*$","%1"))
        ::continue::
    end)
end

function module.getWidget()
    return module.kernelwidget
end

function module.updateWidget()
    local ico, val = module.kernel_status()
    module.icon:set_markup(ico)
    module.widget:set_markup(val)
end

module.kernelwidget:buttons(gears.table.join(awful.button({}, 1, function(t)
    awful.spawn.easy_async_with_shell("uname -a", function(stdout, stderr, reason, exit_code)
        naughty.notify({
            title = "Kernel info",
            text = stdout:gsub("[\r\n]", ",")
        })
    end)
end)))

module.updateWidget()

return module
