local Callbacks = {}

require('Addons.VK.Globals')

local function OnPlayerConnected(client)
    local aliasExists = false
    for _, alias in pairs(client.GetAliases()) do
        if alias == client.GetName() then aliasExists = true end
    end

    if not aliasExists then
        client.AddAlias(client.GetName())
        local previousName = client.GetAliases()[TableLength(client.GetAliases()) - 1]
        Server.SendChatMessage(client, string.format('Notification: You changed your name from: %s to %s', previousName, client.GetName()), Server.GetStatusColour('Information'))
    
        for _, client in pairs(GClients) do
            Server.SendChatMessage(client, string.format('Notification: %s changed their name from: %s to: %s', client.GetName(), previousName, client.GetName()), Server.GetStatusColour('Information'))
        end
    end
end

local function OnPlayerDisconnected(client)
    
end

local function OnChat(client, message)
    
end

Callbacks['OnPlayerConnected'] = OnPlayerConnected
Callbacks['OnPlayerDisconnected'] = OnPlayerDisconnected
Callbacks['OnChat'] = OnChat

return Callbacks