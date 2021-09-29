local Callbacks = {}

require('Addons.VK.Globals')

Server = Include('Addons.VK.Server.Server')

local function OnPlayerConnected(clientID)
    Server.RegisterClient(clientID)
end

local function OnPlayerDisconnected(clientID)
    Server.DestroyClient(clientID)
end

local function OnChat(clientID, message)
    if GExtensions['VK-Essentials'] then
        return ''
    end

    return message
end

Callbacks.OnChat = OnChat
Callbacks.OnPlayerConnected = OnPlayerConnected
Callbacks.OnPlayerDisconnected = OnPlayerDisconnected

return Callbacks