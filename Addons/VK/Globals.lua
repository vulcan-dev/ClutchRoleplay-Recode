--[[ Logging Utilities ]]--
function GWriteToFile(path, ...)
    local file = io.open(path, 'a')
    if file then
        file:write(...)
        file:close()
    else
        GELog('Failed Writing to File: %s', path)
    end
end

function GLog(message, level, ...)
    local output = string.format('[%s]  [kissmp_server:vk] %s', DateTime(), string.format(message, ...))
    if level >= GLevel then print(output) end
    output = output .. '\n'

    if GFileLogging and level >= GLogFileLevel then GWriteToFile(string.format('Addons/VK/Server/Logs/%s/%s', GLogFilePath, GLogFile), output) end
end

function GDLog(message, ...) message = tostring(string.format('[ DEBUG]: %s', message)) GLog(message, GLevels['Debug'], ...) end
function GILog(message, ...) message = tostring(string.format('[ INFO]: %s', message)) GLog(message, GLevels['Info'], ...) end
function GWLog(message, ...) message = tostring(string.format('[ WARN]: %s', message)) GLog(message, GLevels['Warn'], ...) end
function GELog(message, ...) message = tostring(string.format('[ ERROR]: %s', message)) GLog(message, GLevels['Error'], ...) end
function GFLog(message, ...) message = tostring(string.format('[ FATAL]: %s', message)) GLog(message, GLevels['Fatal'], ...) os.execute('pause') os.exit(1) end

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
    if string.find(package.path, path) then return end
    package.path = ';' .. path .. '/?.lua;' .. package.path
end

function DateTime(format, time) return os.date(format or '%H:%M:%S', time) end
function TableDebug(tbl) for k, v in pairs(tbl) do GDLog('Table: %s = %s', k, tostring(v)) end end
function TableLength(tbl) local i = 0 for k, v in pairs(tbl) do i = i + 1 end return i end

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
GClientCount = 0
GCommands = {}
GExtensions = {}
GProduction = nil
GBeamMPCompat = nil

GLevels = {
    Debug = 0,
    Info = 1,
    Warn = 2,
    Error = 3,
    Fatal = 4
}

GErrorInvalidUser = 0
GErrorInvalidArguments = 1
GErrorInvalidMessage = 2
GErrorVehicleBlacklisted = 3
GErrorInvalidVehiclePermissions = 4
GErrorInsufficentPermissions = 5
GErrorCannotPerformUser = 6
GErrorNotInVehicle = 7

GErrors = {
    [GErrorInvalidUser] = 'Invalid user specified',
    [GErrorInvalidArguments] = 'Invalid arguments',
    [GErrorInvalidMessage] = 'Invalid message specified',
    [GErrorVehicleBlacklisted] = 'This vehicle is blacklisted',
    [GErrorInvalidVehiclePermissions] = 'You do not have the required permissions to drive this vehicle',
    [GErrorInsufficentPermissions] = 'You do not have the required permissions to perform this action',
    [GErrorCannotPerformUser] = 'You do not have the required permissions to perform this action on this user',
    [GErrorNotInVehicle] = 'User is not in a vehicle'
}

GLevel = nil
GLogLevel = nil
GLogFileLevel = nil
GLogFilePath = nil
GLogFile = nil
GStartupTime = nil

GConsoleID = -1
GServerInitialized = false