local Callbacks = {}

require('Addons.VK.Globals')

Server = Include('Addons.VK.Server.Server')

local function OnPlayerConnected(clientID)
    --[[ Shared OnChat ]]--
    Server.RegisterClient(clientID)
    local client = GClients[clientID]
    
    Server.WhenConnected(client, function()
        Server.DisplayDialog(client.GetName() .. ' has Connected!')

        for _, extension in pairs(GExtensions) do
            GExtensions[_].Callbacks['OnPlayerConnected'](client)
        end
    end)
end

local function OnPlayerDisconnected(clientID)
    --[[ Shared OnChat ]]--
    local client = GClients[clientID]

    Server.DisplayDialog(client.GetName() .. ' has Left.')
    Server.DestroyClient(clientID)
end

local function OnChat(clientID, message)
    --[[ Shared OnChat ]]--
    local client = GClients[clientID]
    -- if GExtensions['VK-Essentials'] then GExtensions['VK-Essentials'].Callbacks.OnChat(client, message) end

    if not GExtensions['VK-Essentials'] then return message end
end

local function OnStdIn(message)
    if GExtensions['VK-Essentials'] then GExtensions['VK-Essentials'].Callbacks.OnChat(GConsoleID, message) end
end

local function Tick()
    Events.Update()

    -- TODO: Collect Garbage
end

Callbacks.OnChat = OnChat
Callbacks.OnPlayerConnected = OnPlayerConnected
Callbacks.OnPlayerDisconnected = OnPlayerDisconnected
Callbacks.OnStdIn = OnStdIn
Callbacks.Tick = Tick

return Callbacks