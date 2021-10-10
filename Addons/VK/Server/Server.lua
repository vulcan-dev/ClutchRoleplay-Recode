local Server = {}

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

local function SetCommandPrefix(prefix)
    Server.CommandPrefix = prefix
end

local function DestroyClient(clientID)
    GClientCount = GClientCount - 1
    GClients[clientID] = nil
end

Server.Initialize = Initialize
Server.ValidateClientData = ValidateClientData
Server.RegisterClient = RegisterClient
Server.DestroyClient = DestroyClient
Server.SetCommandPrefix = SetCommandPrefix

return Server