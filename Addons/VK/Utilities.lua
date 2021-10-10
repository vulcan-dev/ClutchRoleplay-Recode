local Utilities = {}

require('Addons.VK.Globals')

local function GetColour(colour)
    for k, v in pairs(colour) do
        colour[k] = v / 255
    end

    return colour
end

local function FileToJSON(path)
    local file = io.open(path, 'r')
    local data = decode_json(file:read('*a'))
    file:close()
    return data
end

local function JSONToFile(path, jsonData)
    local file = io.open(path, 'w+')
    file:write(encode_json_pretty(jsonData))
    file:close()
end

local function LoadExtension(name)
    return Include(string.format('Addons.VK.Server.Extensions.%s.%s', name, name:sub(4)))
end

Utilities.GetColour = GetColour
Utilities.FileToJSON = FileToJSON
Utilities.JSONToFile = JSONToFile
Utilities.LoadExtension = LoadExtension

return Utilities