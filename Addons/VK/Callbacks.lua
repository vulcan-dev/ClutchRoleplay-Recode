local Callbacks = {}

require('Addons.VK.Globals')

Server = Include('Addons.VK.Server.Server')

local function OnPlayerConnected(clientID)
    --[[ Shared OnChat ]]--
    Server.RegisterClient(clientID)
end

local function OnPlayerDisconnected(clientID)
    --[[ Shared OnChat ]]--
    Server.DestroyClient(clientID)
end

local function OnChat(clientID, message)
    --[[ Shared OnChat ]]--
    if GExtensions['VK-Essentials'] then
        return ''
    end

    return message
end

Callbacks.OnChat = OnChat
Callbacks.OnPlayerConnected = OnPlayerConnected
Callbacks.OnPlayerDisconnected = OnPlayerDisconnected

return Callbacks