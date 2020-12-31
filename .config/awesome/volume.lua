local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local util = require("widgetutil")

local module = {}

module.on = "  "
module.off = "  "
module.icon = wibox.widget.textbox()
module.widget = wibox.widget.textbox()
module.volwidget = wibox.widget {
    module.icon,
    module.widget,
    layout = wibox.layout.align.horizontal
}

function module.inc_vol(d)
    awful.spawn.easy_async_with_shell("pamixer -i " .. d, function(stdout, stderr, reason, exit_code)
        module.vol_setmarkup()
    end)
end

function module.dec_vol(d)
    awful.spawn.easy_async_with_shell("pamixer -d " .. d, function(stdout, stderr, reason, exit_code)
        module.vol_setmarkup()
    end)
end

function module.mute_vol()
    awful.spawn.easy_async_with_shell("pamixer -t", function(stdout, stderr, reason, exit_code)
        module.vol_setmarkup()
    end)
end

function module.ctrl_vol()
    awful.spawn.easy_async("pavucontrol", function(stdout, stderr, reason, exit_code)
        module.vol_setmarkup()
    end)
end

function module.vol_setmarkup()
    awful.spawn.easy_async("pamixer --get-volume-human", function(stdout, stderr, reason, exit_code)
        if not stdout then
            module.icon:set_markup("")
            module.widget:set_markup("")
            goto continue
        end
        local data = stdout
        if data == "muted\n" then
            module.icon:set_markup(module.off)
            module.widget:set_markup("")
            goto continue
        end
        module.icon:set_markup(module.on)
        module.widget:set_markup(util.percentToBar(data:gsub("%%", ""), false))
        ::continue::
    end)
end

function module.getWidget()
    return module.volwidget
end

function module.updateWidget()
    module.vol_setmarkup()
end

module.volwidget:buttons(gears.table.join(awful.button({}, 1, function(t)
    module.mute_vol()
end), awful.button({}, 3, function(t)
    module.ctrl_vol()
end), awful.button({}, 4, function(t)
    module.inc_vol(5)
end), awful.button({}, 5, function(t)
    module.dec_vol(5)
end)))

module.updateWidget()

return module
