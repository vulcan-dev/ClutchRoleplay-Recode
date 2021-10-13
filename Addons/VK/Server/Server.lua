local Server = {}

local CommandPrefix

--[[ Functions ]]--
local function GenerateClient(clientID)
    local client

    if clientID == 0 then
        GClients[GConsoleID] = {}
        GClients[GConsoleID].udata = {}

        client = GClients[GConsoleID]

        function client.udata:sendLua(lua, message)
            if message ~= nil then GILog('Lua: %s', message) end
            if message == nil and string.find(lua, 'guihooks.trigger') then
                local type = lua:match("type='(.-)'")
                local message = lua:match("title='(.-)'")
                GDLog('Lua: [%s]: %s', type, message)
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

    client.GetSecret = function() if clientID == GConsoleID then return 'Console' end return client.udata:getSecret() end
    client.GetIP = function() if GBeamMPCompat then return MP.GetPlayerIdentifiers(clientID)['ip'] else return client.udata:getIpAddr(client.udata:getID()) end end
    client.GetName = function() if clientID == GConsoleID then return 'Console' end return client.udata:getName() end
    client.SendLua = function(lua, message) if GBeamMPCompat then MP.TriggerLocalEvent('SendLua', lua) else client.udata:sendLua(lua, message) end end
    client.GetID = function() return clientID end
    client.GetIdentifier = function() if GBeamMPCompat then return MP.GetPlayerHWID() .. ':' .. MP.GetPlayerIdentifiers(client.GetID())['ip'] else return connections[clientID]:getSecret() .. ':' .. connections[clientID]:getIpAddr() end end
    client.Kick = function(reason) if GBeamMPCompat then MP.DropPlayer(client.GetID(), reason) else client.udata:kick(reason) end end

    client.GetKey = function(key) return Utilities.FileToJSON('Addons/VK/Server/Clients.json')[client.GetSecret()][key] end
    client.EditKey = function(key, value) local jsonData = Utilities.FileToJSON('Addons/VK/Server/Clients.json'); jsonData[client.GetSecret()][key] = value; Utilities.JSONToFile('Addons/VK/Server/Clients.json', jsonData) end
    
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
    local clientData = Utilities.FileToJSON('Addons/VK/Server/Clients.json')
    local clientDataTemp = DeepCopy(clientData)
    for extension, _ in pairs(GExtensions) do
        if GExtensions[extension].CreateClientData then clientDataTemp = GExtensions[extension].CreateClientData(GClients[clientID]) end
    end

    local valid = true

    local clientSecret
    local clientIP

    if GBeamMPCompat then
        clientSecret = MP.GetPlayerHWID()
        clientIP = MP.GetPlayerIdentifiers(clientID)['ip']
    else
        clientSecret = connections[clientID]:getSecret()
        clientIP = connections[clientID]:getIpAddr()
    end

    for key, _ in pairs(clientDataTemp) do
        if not clientData[clientSecret .. ':' .. clientIP][key] then
            GWLog('Data [%s] missing from client: %s', key, client:getName())
            valid = false
        end
    end

    clientData[clientSecret .. ':' .. clientIP] = clientDataTemp

    if not valid then
        local file = io.open('Addons/VK/Server/Clients.json', 'w+')
        file:write(encode_json_pretty(clientData))
        file:close()

        GILog('Fixed Database For: [%s] - %s', client:getName(), client:getSecret())
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
    else
        clientSecret = connections[clientID]:getSecret()
        clientIP = connections[clientID]:getIpAddr()
    end

    GDLog(clientIP)

    --[[ Add New User to Database ]]--
    local clientData = Utilities.FileToJSON('Addons/VK/Server/Clients.json')
    if not clientData[clientSecret .. ':' .. clientIP] then
        clientData[clientSecret .. ':' .. clientIP] = {}

        for extension, _ in pairs(GExtensions) do
            if GExtensions[extension].CreateClientData then clientData[clientSecret .. ':' .. clientIP] = GExtensions[extension].CreateClientData(GClients[clientID]) end
        end

        local file = io.open('Addons/VK/Server/Clients.json', 'w+')
        file:write(encode_json_pretty(clientData))
        file:close()
    end

    --[[ Generate Client Table ]]--
    ValidateClientData(clientID)
    GenerateClient(clientID)
    for extension, _ in pairs(GExtensions) do
        if GExtensions[extension].GenerateClient then
            GExtensions[extension].GenerateClient(GClients[clientID])
        end
    end
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
            client.SendLua('kissui.add_message(' .. Utilities.LuaStringEscape(message) .. ', {r=' ..
            tostring(colour.r) .. ",g=" .. tostring(colour.g) .. ",b=" ..
            tostring(colour.b) .. ",a=1})", message)
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
        client.udata:sendLua(string.format("ui_message('%s', %s)", message, time))
    else
        --[[ Send to All Clients ]]--
        for _, c in pairs(GClients) do
            c.udata:sendLua(string.format("ui_message('%s', %s)", message, time))
        end
    end
end

local function DisplayDialogError(client, message)
    if client and GErrors[message] then
        client.SendLua(string.format("guihooks.trigger('toastrMsg', {type='error', title='%s', config = {timeOut = 3000}})", GErrors[message]))
    else
        if type(client) ~= 'table' then message = client end
        for _, client in pairs(GClients) do
            client.SendLua(string.format("guihooks.trigger('toastrMsg', {type='error', title='%s', config = {timeOut = 3000}})", tostring(message)))
        end
    end
end

local function DisplayDialogWarning(client, message)
    if client and GErrors[message] then
        client.SendLua(string.format("guihooks.trigger('toastrMsg', {type='warning', title='%s', config = {timeOut = 3000}})", GErrors[message]))
    else
        if type(client) ~= 'table' then message = client end
        for _, client in pairs(GClients) do
            client.SendLua(string.format("guihooks.trigger('toastrMsg', {type='warning', title='%s', config = {timeOut = 3000}})", tostring(message)))
        end
    end
end

local function DisplayDialogSuccess(client, message)
    if client and GErrors[message] then
        client.SendLua(string.format("guihooks.trigger('toastrMsg', {type='success', title='%s', config = {timeOut = 3000}})", GErrors[message]))
    else
        if type(client) ~= 'table' then message = client end
        for _, client in pairs(GClients) do
            client.SendLua(string.format("guihooks.trigger('toastrMsg', {type='success', title='%s', config = {timeOut = 3000}})", tostring(message)))
        end
    end
end

local function GetUser(identifier)
    if not identifier then return nil end

    for _, client in pairs(GClients) do
        if identifier == client.GetName() then
            return client
        else if tonumber(identifier) == client.GetID() then
            return client
        else if identifier == client.GetSecret() then
            return client
        else if tonumber(identifier) == client.mid then
            return client
        else if string.find(client.GetName(), identifier) then
            return client
        else if string.find(string.lower(client.GetName()), identifier) then
            return client
        end end end end end end
    end

    return nil
end

--[[ Modifiers ]]--
local function SetCommandPrefix(prefix) CommandPrefix = prefix end

--[[ Accessors ]]--
local function GetCommandPrefix() return CommandPrefix end
local function GetPlayerCount() return GClientCount end
local function GetStatusColour(colour) return Utilities.FileToJSON('Addons/VK/Settings/Colours.json')['Status'][colour] end
local function GetRankColour(colour) return Utilities.FileToJSON('Addons/VK/Settings/Colours.json')['Rank'][colour] end
local function GetRoleplayColour(colour) return Utilities.FileToJSON('Addons/VK/Settings/Colours.json')['Roleplay'][colour] end

local function DestroyClient(clientID)
    if GClientCount - 1 > 0 then
        GClientCount = GClientCount - 1
    end
    GClients[clientID] = nil
end

Server.Initialize = Initialize
Server.ValidateClientData = ValidateClientData
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