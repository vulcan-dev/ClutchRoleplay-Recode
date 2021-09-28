local Utilities = {}

require('Addons.VK.Globals')

local function GetColour(colour)
    for k, v in pairs(colour) do
        colour[k] = v / 255
    end

    return colour
end

local function FileToJSON(path)
    return decode_json(io.open(path, 'r'):read('*a'))
end

local function LoadExtension(name)
    return Include(string.format('Addons.VK.Server.Extensions.%s.Callbacks', name))
end

Utilities.GetColour = GetColour
Utilities.FileToJSON = FileToJSON
Utilities.LoadExtension = LoadExtension

return Utilities