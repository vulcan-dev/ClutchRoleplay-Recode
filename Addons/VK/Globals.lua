--[[ Utility Functions ]]--
function DateTime(format, time) return os.date(format or '%H:%M:%S', time) end

--[[ Logging Utilities ]]--
function GLog(message, ...) print(string.format('[%s]  [kissmp_server:vk] %s', DateTime(), string.format(message, ...))) end
function GDLog(message, ...) message = tostring(string.format('[ DEBUG]: %s', message)) GLog(message, ...) end
function GILog(message, ...) message = tostring(string.format('[ INFO]: %s', message)) GLog(message, ...) end
function GWLog(message, ...) message = tostring(string.format('[ WARN]: %s', message)) GLog(message, ...) end
function GELog(message, ...) message = tostring(string.format('[ ERROR]: %s', message)) GLog(message, ...) end
function GFLog(message, ...) message = tostring(string.format('[ FATAL]: %s', message)) GLog(message, ...) end

--[[ Client ]]--
GClients = {}