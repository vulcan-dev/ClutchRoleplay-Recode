local Callbacks = {}

require('Addons.VK.Globals')

local function OnPlayerConnected(clientID)

end

local function OnPlayerDisconnected(clientID)

end

local function OnChat(clientID, message)
    GDLog('VK-AntiCheat : OnChat')
end

Callbacks.Callbacks = {
    ['OnPlayerConnected'] = OnPlayerConnected,
    ['OnPlayerDisconnected'] = OnPlayerDisconnected,
    ['OnChat'] = OnChat,
}

return Callbacks