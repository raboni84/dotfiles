local module = {}

module.percs = { " ", "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" }

function module.percentToBar(c, colorful)
    local n = tonumber(c)
    local pick = math.ceil(n / 12.5) + 1
    if pick < 1 then
        pick = 1
    elseif pick > 9 then
        pick = 9
    end
    local val = module.percs[pick]
    if colorful and pick == 1 then
        val = "<span foreground=\"red\"></span>"
    elseif colorful and pick == 2 then
        val = "<span foreground=\"red\">" .. val .. "</span>"
    elseif colorful and pick == 3 then
        val = "<span foreground=\"orange\">" .. val .. "</span>"
    end
    return val
end

return module