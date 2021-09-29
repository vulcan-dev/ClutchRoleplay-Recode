local Server = {}

local function RegisterClient(clientID)
    GClientCount = GClientCount + 1
    GClients[clientID] = {}
    local client = connections[clientID]

    local clients = Utilities.FileToJSON('Addons\\VK\\Server\\Clients.json')
    if not clients[client:getSecret()] then
        clients[client:getSecret()] = {}
        local clientData = clients[client:getSecret()]

        if GExtensions['VK-Essentials'] then GExtensions['VK-Essentials'].CreateClientData(clientID, clientData) end
        if GExtensions['VK-Roleplay'] then GExtensions['VK-Roleplay'].CreateClientData(clientID, clientData) end
        if GExtensions['VK-AntiCheat'] then GExtensions['VK-AntiCheat'].CreateClientData(clientID, clientData) end

        local file = io.open('Addons\\VK\\Server\\Clients.json', 'w+')
        file:write(encode_json_pretty(clients))
        file:close()
    end

    client = GClients[clientID]
end

local function DestroyClient(clientID)
    GClientCount = GClientCount - 1
    GClients[clientID] = nil
end

Server.RegisterClient = RegisterClient
Server.DestroyClient = DestroyClient

return Server