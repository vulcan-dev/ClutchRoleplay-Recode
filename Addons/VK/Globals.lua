--[[ Logging Utilities ]]--
function GLog(message, ...) print(string.format('[%s]  [kissmp_server:vk] %s', DateTime(), string.format(message, ...))) end
function GDLog(message, ...) message = tostring(string.format('[ DEBUG]: %s', message)) GLog(message, ...) end
function GILog(message, ...) message = tostring(string.format('[ INFO]: %s', message)) GLog(message, ...) end
function GWLog(message, ...) message = tostring(string.format('[ WARN]: %s', message)) GLog(message, ...) end
function GELog(message, ...) message = tostring(string.format('[ ERROR]: %s', message)) GLog(message, ...) end
function GFLog(message, ...) message = tostring(string.format('[ FATAL]: %s', message)) GLog(message, ...) end

--[[ Utility Functions ]]--
function DeepCopy(orig)
    local origType = type(orig)
    local copy

    if origType == 'table' then
        copy = {}
        for origKey, origValue in next, orig, nil do
            copy[DeepCopy(origKey)] = DeepCopy(origValue)
        end

        setmetatable(copy, DeepCopy(getmetatable(orig)))
    else copy = orig end
    return copy
end

function AddPath(path)
    package.path = ';' .. path .. '/?.lua;' .. package.path
end

function DateTime(format, time) return os.date(format or '%H:%M:%S', time) end
function Include(include)
    if type(include) == 'string' then
        if package.loaded[include] then package.loaded[include] = nil end
        package.loaded[include] = require(include)
        return package.loaded[include]
    end

    for includeName, _ in pairs(include) do
        if package.loaded[includeName] then package.loaded[includeName] = nil end
        include[includeName] = require(includeName)
    end

    return include
end

--[[ Variables ]]--
GClients = {}
GCommands = {}