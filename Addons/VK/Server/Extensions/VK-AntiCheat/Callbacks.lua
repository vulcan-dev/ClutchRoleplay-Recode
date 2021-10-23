local Callbacks = {}

require('Addons.VK.Globals')

local function OnPlayerConnected(clientID)
    
end

local function OnPlayerDisconnected(clientID)
    
end

local function OnChat(clientID, message)
    
end

local function OnTick()
    
end

Callbacks['OnPlayerConnected'] = OnPlayerConnected
Callbacks['OnPlayerDisconnected'] = OnPlayerDisconnected
Callbacks['OnChat'] = OnChat
Callbacks['Tick'] = OnTick

return Callbacks