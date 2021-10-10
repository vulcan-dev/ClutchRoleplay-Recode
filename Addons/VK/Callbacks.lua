local Callbacks = {}

require('Addons.VK.Globals')

Server = Include('Addons.VK.Server.Server')

local function OnPlayerConnected(clientID)
    --[[ Shared OnPlayerConnected ]]--
    Server.RegisterClient(clientID)
end

local function OnPlayerDisconnected(clientID)
    --[[ Shared OnPlayerDisconnected ]]--
    Server.DestroyClient(clientID)
end

local function OnChat(clientID, message)
    --[[ Shared OnChat ]]--
    

    return message
end

Callbacks.OnChat = OnChat
Callbacks.OnPlayerConnected = OnPlayerConnected
Callbacks.OnPlayerDisconnected = OnPlayerDisconnected

return Callbacks