local wibox = require("wibox")
local util = require("widgetutil")

local module = {}

module.icon = wibox.widget.textbox()
module.widget = wibox.widget.textbox()
module.tempwidget = wibox.widget {
    module.icon,
    module.widget,
    layout = wibox.layout.align.horizontal,
}

function module.temp_status()
    local min = 100
    for i = 0,9,1 do
        local dir = "/sys/class/hwmon/hwmon" .. i
        local dd = io.open(dir, "r")
        if not dd then
            goto next
        end
        dd:close()
        for j = 0,4,1 do
            local file = dir .. "/temp" .. j .. "_crit"
            local fd = io.open(file, "r")
            if not fd then
                goto continue
            end
            local crit = fd:read()
            fd:close()
            fd = io.open(file:gsub("_crit", "_input"), "r")
            if not fd then
                goto continue
            end
            local temp = fd:read()
            if tonumber(temp) < 0 then
                temp = "0"
            end
            fd:close()
            -- with 0°C as best possible temperature
            local perc = math.floor((1 - (temp / crit)) * 100 + 0.5)
            if perc < min then
                min = perc
            end
            ::continue::
        end
        ::next::
    end
    if min < 100 then
        return "  ", util.percentToBar(min, true)
    else
        return "", ""
    end
end

function module.getWidget()
    return module.tempwidget
end

function module.updateWidget()
    local ico, val = module.temp_status()
    module.icon:set_markup(ico)
    module.widget:set_markup(val)
end

module.updateWidget()

return module
