local Server = {}

local CommandPrefix

--[[ Client Functions ]]--
local function GenerateClient(clientID, secret, ip)
    local client

    if clientID == GConsoleID then
        GClients[GConsoleID] = {}
        GClients[GConsoleID].udata = {}

        client = GClients[GConsoleID]

        function client.udata:sendLua(lua, message)
            if message ~= nil then GILog('Lua: %s', message) end
            if message == nil and string.find(lua, 'guihooks.trigger') then
                local type = lua:match("type='(.-)'")
                local message = lua:match("title='(.-)'")
                GILog('Lua: [%s]: %s', type, message)
            end
        end
        function client.udata:getName() return 'Console' end
        function client.udata:getSecret() return 'Console' end
        function client.udata:getID() return GConsoleID end
        function client.udata:getIpAddr() return '127.0.0.1' end
        function client.udata:getCurrentVehicle() return nil end

        for extension, _ in pairs(GExtensions) do
            if GExtensions[extension].GenerateClient then
                GExtensions[extension].GenerateClient(GClients[GConsoleID])
            end
        end
    else
        client = GClients[clientID]
        client.udata = connections[clientID]
    end

    --[[ Offline ]]--
    if secret then
        client.GetKey = function(key) return Utilities.FileToJSON('Addons/VK/Server/Clients.json')[secret .. ':' .. ip][key] end

        client.udata = {
            getSecret = function() return secret end,
            getIP = function() return ip end,
            getCurrentVehicle = function() return nil end,
            getName = function() return client.GetKey('Aliases')[TableLength(client.GetKey('Aliases'))] end,
            kick = function() end
        }

        client.offline = true
    end

    client.GetSecret = function() if clientID == GConsoleID then return 'Console' end return client.udata:getSecret() end
    client.GetIP = function() if GBeamMPCompat then return MP.GetPlayerIdentifiers(clientID)['ip'] else return client.udata:getIpAddr(client.udata:getID()) end end
    client.GetName = function() if clientID == GConsoleID then return 'Console' end return client.udata:getName() end
    client.SendLua = function(lua, message) if GBeamMPCompat then MP.TriggerLocalEvent('SendLua', lua) else client.udata:sendLua(lua, message) end end
    client.GetID = function() return clientID end
    client.GetVehicle = function() return client.udata:getCurrentVehicle() or nil end
    client.GetIdentifier = function()
        if GBeamMPCompat then
            return MP.GetPlayerHWID() .. ':' .. MP.GetPlayerIdentifiers(client.GetID())['ip']
        else
            if clientID == GConsoleID then
                return 'Console'
            end

            return connections[clientID]:getSecret() .. ':' .. connections[clientID]:getIpAddr()
        end
    end

    --[[ Offline ]]--
    if secret then
        client.GetIdentifier = function() return secret .. ':' .. ip end
    end

    client.Kick = function(reason) if GBeamMPCompat then MP.DropPlayer(client.GetID(), reason) else if not client.offline then client.udata:kick(reason) return true else return false end end end

    client.GetKey = function(key) return Utilities.FileToJSON('Addons/VK/Server/Clients.json')[client.GetIdentifier()][key] end
    client.EditKey = function(key, value) local jsonData = Utilities.FileToJSON('Addons/VK/Server/Clients.json'); jsonData[client.GetIdentifier()][key] = value; Utilities.JSONToFile('Addons/VK/Server/Clients.json', jsonData) end
    
    --[[ Offline ]]--
    if secret then
        client.GetKey = function(key) return Utilities.FileToJSON('Addons/VK/Server/Clients.json')[secret .. ':' .. ip][key] end
        client.GetName = function() return client.GetKey('Aliases')[TableLength(client.GetKey('Aliases'))] end

        for extension, _ in pairs(GExtensions) do
            if GExtensions[extension].GenerateClient then
                GExtensions[extension].GenerateClient(GClients[-5])
            end
        end
    end

    client.mid = GClientCount

    client.vehicles = {}
    client.vehicles.total = 0

    return client
end

local function Initialize()
    local ServerConfig = Utilities.FileToJSON('Addons/VK/Settings/Server.json')
    Server.SetCommandPrefix(ServerConfig['CommandPrefix'])
    GenerateClient(GConsoleID)
end

local function ValidateClientData(clientID)
    local client = connections[clientID]
    local database = Utilities.FileToJSON('Addons/VK/Server/Clients.json')
    for extension, _ in pairs(GExtensions) do
        if GExtensions[extension].CreateClientData then clientDataTemp = GExtensions[extension].CreateClientData(GClients[clientID]) end
    end

    local valid = true
    local exists = false

    local clientSecret
    local clientIP

    if GBeamMPCompat then
        clientSecret = MP.GetPlayerHWID()
        clientIP = MP.GetPlayerIdentifiers(clientID)['ip']
    else
        clientSecret = connections[clientID]:getSecret()
        clientIP = connections[clientID]:getIpAddr()
    end

    for key, _ in pairs(database) do
        if not database[clientSecret .. ':' .. clientIP][key] then
            GWLog('Data [%s] missing from client: %s', key, client:getName())
            valid = false
        end

        exists = true
    end

    database[clientSecret .. ':' .. clientIP] = {}

    if not valid then
        local file = io.open('Addons/VK/Server/Clients.json', 'w+')
        file:write(JSON.encode(database))
        file:close()

        GILog('Fixed Database For: [%s] - %s', client:getName(), client:getSecret()) else GILog('Added "%s" to Database', client:getName())
    end
end

local function RegisterClient(clientID)
    GClientCount = GClientCount + 1
    GClients[clientID] = {}

    local clientSecret
    local clientIP

    if GBeamMPCompat then
        clientSecret = MP.GetPlayerHWID()
        clientIP = MP.GetPlayerIdentifiers(clientID)['ip']
        clientName = 0
    else
        clientSecret = connections[clientID]:getSecret()
        clientIP = connections[clientID]:getIpAddr()
        clientName = connections[clientID]:getName()
    end

    --[[ Add New User to Database ]]--
    local clientData = Utilities.FileToJSON('Addons/VK/Server/Clients.json')
    if not clientData[clientSecret .. ':' .. clientIP] then
        clientData[clientSecret .. ':' .. clientIP] = {}

        for extension, _ in pairs(GExtensions) do
            if GExtensions[extension].CreateClientData then clientData[clientSecret .. ':' .. clientIP] = GExtensions[extension].CreateClientData(GClients[clientID]) end
        end

        local file = io.open('Addons/VK/Server/Clients.json', 'w+')
        file:write(JSON.encode(clientData))
        file:close()

        GILog('Added "%s" to Database', clientName)
    else
        ValidateClientData(clientID)
    end

    --[[ Generate Client Table ]]--
    GenerateClient(clientID)
    for extension, _ in pairs(GExtensions) do
        if GExtensions[extension].GenerateClient then
            GExtensions[extension].GenerateClient(GClients[clientID])
        end
    end
end

local function WhenConnected(client, callback)
    client.vehicles[client.GetVehicle()] = { vehicle = vehicles[client.GetVehicle()] }

    Events.Add(function()
        if client.vehicles[client.GetVehicle()] then callback() Events.Remove('CON_' .. client.GetID()) end
        client.vehicles[client.GetVehicle()] = { vehicle = vehicles[client.GetVehicle()] }
    end, 'CON_' .. client.GetID(), 2)
end

--[[ Server Functions ]]--
local function SendChatMessage(client, message, colour)
    --[[ Optional: If client is not valid then it will send a message to everyone ]]--
    if type(client) == 'string' then
        colour = message
        message = client
    end

    --[[ Check if Colour is Valid ]]--
    if type(colour) ~= 'table' then colour = {} end
    colour.r = colour.r or 1
    colour.g = colour.g or 1
    colour.b = colour.b or 1

    if type(client) == 'string' then
        for _, client in pairs(GClients) do
            if client.GetID() ~= GConsoleID then
                client.SendLua('kissui.add_message(' .. Utilities.LuaStringEscape(message) .. ', {r=' ..
                tostring(colour.r) .. ",g=" .. tostring(colour.g) .. ",b=" ..
                tostring(colour.b) .. ",a=1})", message)
            end
        end
    else
        client.SendLua('kissui.add_message(' .. Utilities.LuaStringEscape(message) .. ', {r=' ..
        tostring(colour.r) .. ",g=" .. tostring(colour.g) .. ",b=" ..
        tostring(colour.b) .. ",a=1})", message)
    end
end

local function DisplayDialog(error, client, message, time)
    --[[ Check if we're using normal Modules.Server.DisplayDialog() or Modules.Server.DisplayDialogError() ]]--
    if not GErrors[error] then
        time = message
        message = client
        client = error
        error = nil
    end

    if type(client) == 'string' then
        message = client
    end

    time = time or 3

    if client.udata then
        --[[ Send to One Client ]]--
        client.SendLua(string.format("ui_message('%s', %s)", message, time), message)
    else
        --[[ Send to All Clients ]]--
        for _, c in pairs(GClients) do
            c.SendLua(string.format("ui_message('%s', %s)", message, time), message)
        end
    end
end

local function DisplayDialogError(client, message)
    if client then
        client.SendLua(string.format("guihooks.trigger('toastrMsg', {type='error', title='%s', config = {timeOut = 3000}})", GErrors[message] or message))
    else
        if type(client) ~= 'table' then message = client end
        for _, client in pairs(GClients) do
            client.SendLua(string.format("guihooks.trigger('toastrMsg', {type='error', title='%s', config = {timeOut = 3000}})", GErrors[message] or message))
        end
    end
end

local function DisplayDialogWarning(client, message)
    if client then
        client.SendLua(string.format("guihooks.trigger('toastrMsg', {type='warning', title='%s', config = {timeOut = 3000}})", GErrors[message] or message))
    else
        if type(client) ~= 'table' then message = client end
        for _, client in pairs(GClients) do
            client.SendLua(string.format("guihooks.trigger('toastrMsg', {type='warning', title='%s', config = {timeOut = 3000}})", GErrors[message] or message))
        end
    end
end

local function DisplayDialogSuccess(client, message)
    if client then
        client.SendLua(string.format("guihooks.trigger('toastrMsg', {type='success', title='%s', config = {timeOut = 3000}})", GErrors[message] or message))
    else
        if type(client) ~= 'table' then message = client end
        for _, client in pairs(GClients) do
            client.SendLua(string.format("guihooks.trigger('toastrMsg', {type='success', title='%s', config = {timeOut = 3000}})", GErrors[message] or message))
        end
    end
end

local function GetUser(identifier)
    if not identifier then return nil end

    --[[ Check Online Clients ]]--
    GClients[-5] = nil
    for _, client in pairs(GClients) do
        if identifier == client.GetName() then
            return client
        elseif tonumber(identifier) == client.GetID() then
            return client
        elseif identifier == client.GetSecret() then
            return client
        elseif tonumber(identifier) == client.mid then
            return client
        elseif string.find(client.GetName(), identifier) then
            return client
        elseif string.find(string.lower(client.GetName()), identifier) then
            return client
        end
    end

    --[[ Check Offline Clients ]]--
    GClients[-5] = {}
    GClients[-5].udata = {}

    local client = GClients[-5]

    function client.udata:sendLua(lua, message)
        if message ~= nil then GILog('Lua: %s', message) end
        if message == nil and string.find(lua, 'guihooks.trigger') then
            local type = lua:match("type='(.-)'")
            local message = lua:match("title='(.-)'")
            GILog('Lua: [%s]: %s', type, message)
        end
    end
    function client.udata:getName() return 'Console' end
    function client.udata:getSecret() return 'Console' end
    function client.udata:getID() return -5 end
    function client.udata:getIpAddr() return '127.0.0.1' end
    function client.udata:getCurrentVehicle() return nil end

    local clients = Utilities.FileToJSON('Addons/VK/Server/Clients.json')
    
    --[[ Check by IP or Secret ]]--
    for id, v in pairs(clients) do
        if id ~= 'Console' then
            local secret, ip = id:match("(.+):(.+)")
            if identifier == secret or identifier == ip then
                return GenerateClient(-5, secret, ip)
            end
        end
    end

    --[[ Check by Name ]]--
    for id, c in pairs(clients) do
        if id ~= 'Console' then
            if string.find(string.lower(c.Aliases[TableLength(c.Aliases)]), string.lower(identifier)) then
                local secret, ip = id:match("(.+):(.+)")
                return GenerateClient(-5, secret, ip)
            end
        end
    end

    return nil
end

--[[ Modifiers ]]--
local function SetCommandPrefix(prefix) CommandPrefix = prefix end

--[[ Accessors ]]--
local function GetCommandPrefix() return CommandPrefix end
local function GetPlayerCount() return GClientCount end
local function GetStatusColour(colour) return Utilities.ConvertColour(Utilities.FileToJSON('Addons/VK/Settings/Colours.json')['Status'][colour]) end
local function GetRankColour(colour) return Utilities.ConvertColour(Utilities.FileToJSON('Addons/VK/Settings/Colours.json')['Rank'][colour]) end
local function GetRoleplayColour(colour) return Utilities.ConvertColour(Utilities.FileToJSON('Addons/VK/Settings/Colours.json')['Roleplay'][colour]) end

local function DestroyClient(clientID)
    GClients[clientID] = nil
end

Server.Initialize = Initialize
Server.ValidateClientData = ValidateClientData
Server.WhenConnected = WhenConnected
Server.RegisterClient = RegisterClient
Server.DestroyClient = DestroyClient

Server.SendChatMessage = SendChatMessage
Server.DisplayDialog = DisplayDialog
Server.DisplayDialogError = DisplayDialogError
Server.DisplayDialogWarning = DisplayDialogWarning
Server.DisplayDialogSuccess = DisplayDialogSuccess
Server.GetUser = GetUser

Server.SetCommandPrefix = SetCommandPrefix
Server.GetCommandPrefix = GetCommandPrefix
Server.GetPlayerCount = GetPlayerCount
Server.GetStatusColour = GetStatusColour
Server.GetRankColour = GetRankColour
Server.GetRoleplayColour = GetRoleplayColour

return Server