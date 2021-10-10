local Server = {}

local CommandPrefix

--[[ Functions ]]--
local function Initialize()
    local ServerConfig = Utilities.FileToJSON('Addons\\VK\\Settings\\Server.json')
    Server.SetCommandPrefix(ServerConfig['CommandPrefix'])
end

local function GenerateClient(clientID)
    --[[ Get Key ]]--
    local client = GClients[clientID]

    client.udata = connections[clientID]

    client.GetKey = function(key) return Utilities.FileToJSON('Addons\\VK\\Server\\Clients.json')[client.udata:getSecret()][key] end
    client.EditKey = function(key, value) local jsonData = Utilities.FileToJSON('Addons\\VK\\Server\\Clients.json'); jsonData[client.udata:getSecret()][key] = value; Utilities.JSONToFile('Addons\\VK\\Server\\Clients.json', jsonData) end

    client.mid = GClientCount

    client.vehicles = {}
    client.vehicles.total = 0

    return client
end

local function ValidateClientData(clientID)
    local client = connections[clientID]
    local clientData = Utilities.FileToJSON('Addons\\VK\\Server\\Clients.json')
    local clientDataTemp = DeepCopy(clientData)
    for extension, _ in pairs(GExtensions) do
        if GExtensions[extension].CreateClientData then clientDataTemp = GExtensions[extension].CreateClientData(GClients[clientID]) end
    end

    local valid = true

    for key, _ in pairs(clientDataTemp) do
        if not clientData[client:getSecret()][key] then
            GWLog('Data [%s] missing from client: %s', key, client:getName())
            valid = false
        end
    end

    clientData[client:getSecret()] = clientDataTemp

    if not valid then
        local file = io.open('Addons\\VK\\Server\\Clients.json', 'w+')
        file:write(encode_json_pretty(clientData))
        file:close()

        GILog('Fixed Database For: [%s] - %s', client:getName(), client:getSecret())
    end
end

local function RegisterClient(clientID)
    GClientCount = GClientCount + 1
    GClients[clientID] = {}

    local clientSecret = connections[clientID]:getSecret()

    --[[ Add New User to Database ]]--
    local clientData = Utilities.FileToJSON('Addons\\VK\\Server\\Clients.json')
    if not clientData[clientSecret] then
        clientData[clientSecret] = {}

        for extension, _ in pairs(GExtensions) do
            if GExtensions[extension].CreateClientData then clientData[clientSecret] = GExtensions[extension].CreateClientData(GClients[clientID]) end
        end

        local file = io.open('Addons\\VK\\Server\\Clients.json', 'w+')
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
    if not client.udata then
        colour = message
        message = client
    end

    --[[ Check if Colour is Valid ]]--
    if type(colour) ~= 'table' then colour = {} end
    colour.r = colour.r or 1
    colour.g = colour.g or 1
    colour.b = colour.b or 1

    if not client.udata then
        for _, client in pairs(GClients) do
            client.udata:sendLua('kissui.add_message(' .. Utilities.LuaStringEscape(message) .. ', {r=' ..
            tostring(colour.r) .. ",g=" .. tostring(colour.g) .. ",b=" ..
            tostring(colour.b) .. ",a=1})")
        end
    else
        client.udata:sendLua('kissui.add_message(' .. Utilities.LuaStringEscape(message) .. ', {r=' ..
        tostring(colour.r) .. ",g=" .. tostring(colour.g) .. ",b=" ..
        tostring(colour.b) .. ",a=1})")
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
        client.udata:sendLua(string.format("guihooks.trigger('toastrMsg', {type='error', title='%s', config = {timeOut = 3000}})", GErrors[message]))
    else
        if type(client) ~= 'table' then message = client end
        for _, client in pairs(GClients) do
            client.udata:sendLua(string.format("guihooks.trigger('toastrMsg', {type='error', title='%s', config = {timeOut = 3000}})", tostring(message)))
        end
    end
end

local function DisplayDialogWarning(client, message)
    if client and GErrors[message] then
        client.udata:sendLua(string.format("guihooks.trigger('toastrMsg', {type='warning', title='%s', config = {timeOut = 3000}})", GErrors[message]))
    else
        if type(client) ~= 'table' then message = client end
        for _, client in pairs(GClients) do
            client.udata:sendLua(string.format("guihooks.trigger('toastrMsg', {type='warning', title='%s', config = {timeOut = 3000}})", tostring(message)))
        end
    end
end

local function DisplayDialogSuccess(client, message)
    if client and GErrors[message] then
        client.udata:sendLua(string.format("guihooks.trigger('toastrMsg', {type='success', title='%s', config = {timeOut = 3000}})", GErrors[message]))
    else
        if type(client) ~= 'table' then message = client end
        for _, client in pairs(GClients) do
            client.udata:sendLua(string.format("guihooks.trigger('toastrMsg', {type='success', title='%s', config = {timeOut = 3000}})", tostring(message)))
        end
    end
end

--[[ Modifiers ]]--
local function SetCommandPrefix(prefix) CommandPrefix = prefix end

--[[ Accessors ]]--
local function GetCommandPrefix() return CommandPrefix end
local function GetPlayerCount() return GClientCount end
local function GetStatusColour(colour) return Utilities.FileToJSON('Addons\\VK\\Settings\\Colours.json')['Status'][colour] end
local function GetRankColour(colour) return Utilities.FileToJSON('Addons\\VK\\Settings\\Colours.json')['Rank'][colour] end
local function GetRoleplayColour(colour) return Utilities.FileToJSON('Addons\\VK\\Settings\\Colours.json')['Roleplay'][colour] end

local function DestroyClient(clientID)
    GClientCount = GClientCount - 1
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

Server.SetCommandPrefix = SetCommandPrefix
Server.GetCommandPrefix = GetCommandPrefix
Server.GetPlayerCount = GetPlayerCount
Server.GetStatusColour = GetStatusColour
Server.GetRankColour = GetRankColour
Server.GetRoleplayColour = GetRoleplayColour

return Server