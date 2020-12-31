local awful = require("awful")
local wibox = require("wibox")
local naughty = require("naughty")
local util = require("widgetutil")

local module = {}

module.discharging = { "  ", "  ", "  ", "  ", "  " }
module.charging = "  " -- plug
module.icon = wibox.widget.textbox()
module.widget = wibox.widget.textbox()
module.batterywidget = wibox.widget {
    module.icon,
    module.widget,
    layout = wibox.layout.align.horizontal,
}
module.warnonce = false
module.critonce = false

function module.battery_status()
    local fd = io.open("/sys/class/power_supply/BAT0/capacity", "r")
    if not fd then
        return "", ""
    end
    local capacity = tonumber(fd:read())
    fd:close()
    local status = ""
    local fd = io.open("/sys/class/power_supply/BAT0/status", "r")
    if fd then
        local data = fd:read()
        fd:close()
        if data == "Charging" or data == "Full" then
            status = module.charging
            module.warnonce = false
            module.critonce = false
        else
            local pick = math.ceil(capacity / 25) + 1
            if pick < 1 then
                pick = 1
            elseif pick > 5 then
                pick = 5
            end
            status = module.discharging[pick]
            if not module.warnonce and capacity <= 15 then
                module.warnonce = true
                naughty.notify({
                    preset = naughty.config.presets.critical,
                    title = "Battery warning!",
                    text = "Less than 15% charge remaining!"
                })
            end
            if not module.critonce and capacity <= 5 then
                module.critonce = true
                awful.spawn({"systemctl", "hibernate"})
            end
        end
    end
    return status, util.percentToBar(capacity, true)
end

function module.getWidget()
    return module.batterywidget
end

function module.updateWidget()
    local ico, val = module.battery_status()
    module.icon:set_markup(ico)
    module.widget:set_markup(val)
end

module.updateWidget()

return module
