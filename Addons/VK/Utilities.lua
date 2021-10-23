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
    local data = JSON.decode(file:read('*a'))
    file:close()
    return data
end

local function JSONToFile(path, jsonData)
    local file = io.open(path, 'w+')
    file:write(JSON.encode(jsonData))
    file:close()
end

local function EditKey(path, key, value)
    local data = FileToJSON(path)
    data[key] = value
    JSONToFile(path, data)
end

local function LoadExtension(name)
    return Include(string.format('Addons.VK.Server.Extensions.%s.%s', name, name:sub(4)))
end

local function LuaStringEscape(str, q)
    local escapeMap = {
        ["\n"] = [[\n]],
        ["/"] = [[\]]
    }

    local qOther = nil
    if not q then
        q = "'"
    end
    if q == "'" then
        qOther = '"'
    end

    local serializedStr = q
    for i = 1, str:len(), 1 do
        local c = str:sub(i, i)
        if c == q then
            serializedStr = serializedStr .. q .. " .. " .. qOther .. c .. qOther .. " .. " .. q
        elseif escapeMap[c] then
            serializedStr = serializedStr .. escapeMap[c]
        else
            serializedStr = serializedStr .. c
        end
    end
    serializedStr = serializedStr .. q
    return serializedStr
end

local function ConvertColour(colour)
    local colour = DeepCopy(colour)
    for key, value in pairs(colour) do -- Convert RGB 0-255 to 0-1
        colour[key] = value / 255
    end

    return colour
end

local function ParseCommand(cmd, sep)
    local parts = {}
    local len = cmd:len()
    local escape_sequence_stack = 0
    local in_quotes = false

    local cur_part = ""
    for i = 1, len, 1 do
        local char = cmd:sub(i, i)
        if escape_sequence_stack > 0 then
            escape_sequence_stack = escape_sequence_stack + 1
        end
        local in_escape_sequence = escape_sequence_stack > 0
        if char == "/" then
            escape_sequence_stack = 1
        elseif char == sep and not in_quotes then
            table.insert(parts, cur_part)
            cur_part = ""
        elseif char == '"' and not in_escape_sequence then
            in_quotes = not in_quotes
        else
            cur_part = cur_part .. char
        end
        if escape_sequence_stack > 1 then
            escape_sequence_stack = 0
        end
    end
    if cur_part:len() > 0 then
        table.insert(parts, cur_part)
    end
    return parts
end

local function GetCommands(extensionName)
    local last
    local commands = {}

    --[[ Get all Files ]]--
    local files = io.popen(string.format('dir ./Addons/VK/Server/Extensions/%s/Commands/*.lua', extensionName))
    for file in files:lines() do
        --[[ Get Lua File ]]
        -- last = string.match(file, "%s(%S+).lua$")
        local include = string.match(file, "Commands/(%S+).lua")
        last = string.match(file, "/(%S+).lua$"):gsub('/', '.')
        if last ~= nil then
            commands[string.lower(string.sub(include, 3, #include))] = Include(last)
        end
    end

    return commands
end

local function AddCommandTable(command)
    for key, value in pairs(command) do
        GCommands[key] = value
    end
end

local function ToBoolean(str)
    if type(str) == 'number' then str = tostring(str) end
    str = string.lower(str)

    local boolTables = {
        ['1'] = true,
        ['true'] = true,

        ['0'] = false,
        ['false'] = false,
    }

    if boolTables[str] ~= nil then
        return boolTables[str], nil
    else
        return false, GErrorInvalidArguments
    end
end

Utilities.GetColour = GetColour
Utilities.FileToJSON = FileToJSON
Utilities.JSONToFile = JSONToFile
Utilities.EditKey = EditKey
Utilities.LoadExtension = LoadExtension
Utilities.LuaStringEscape = LuaStringEscape
Utilities.ConvertColour = ConvertColour
Utilities.ParseCommand = ParseCommand
Utilities.GetCommands = GetCommands
Utilities.AddCommandTable = AddCommandTable
Utilities.ToBoolean = ToBoolean

return Utilities