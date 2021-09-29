local Callbacks = {}

local function OnPlayerConnected(clientID)

end

local function OnPlayerDisconnected(clientID)

end

local function OnChat(clientID, message)
    
end

Callbacks['OnPlayerConnected'] = OnPlayerConnected
Callbacks['OnPlayerDisconnected'] = OnPlayerDisconnected
Callbacks['OnChat'] = OnChat

return Callbacks