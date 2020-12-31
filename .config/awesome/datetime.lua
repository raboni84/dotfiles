local awful = require("awful")
local wibox = require("wibox")
local util = require("widgetutil")

local module = {}

module.icon = wibox.widget.textbox()
module.icon:set_markup("  ")
module.widget = wibox.widget.textclock("KW %V %a %d %b %H:%M %Z %Y ")
module.datetimewidget = wibox.widget {
    module.icon,
    module.widget,
    layout = wibox.layout.align.horizontal,
}
module.calendar = awful.widget.calendar_popup.month({
    week_numbers = true
})
module.calendar:attach(module.datetimewidget, "tr", {
    on_hover = false
})

function module.getWidget()
    return module.datetimewidget
end

return module
