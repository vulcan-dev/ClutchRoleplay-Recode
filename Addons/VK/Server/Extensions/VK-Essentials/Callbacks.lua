local Callbacks = {}

require('Addons.VK.Globals')

local function OnPlayerConnected(client)
    --[[ Check for Name Change ]]--
    local aliasLength = TableLength(client.GetAliases())
    local aliasExists = false
    for _, alias in pairs(client.GetAliases()) do
        if alias == client.GetName() then aliasExists = true end
    end

    if not aliasExists then
        client.AddAlias(client.GetName())

        if aliasLength > 0 then
            local previousName = client.GetAliases()[TableLength(client.GetAliases()) - 1]
            Server.SendChatMessage(client, string.format('Notification: You changed your name from: %s to %s', previousName, client.GetName()), Server.GetStatusColour('Information'))
        
            for _, client in pairs(GClients) do
                Server.SendChatMessage(client, string.format('Notification: %s changed their name from: %s to: %s', client.GetName(), previousName, client.GetName()), Server.GetStatusColour('Information'))
            end
        end
    end

    --[[ Check if Banned ]]--
    local ban = client.GetBanned()
    if ban then
        if ban.Length > 0 then
            if ban.Length <= os.time() then
                local bans = client.GetKey('Bans')
                bans[tostring(ban.ID)].Length = 0
                client.EditKey('Bans', bans)
            else
                client.Kick(string.format('You are banned from this server. Unban date: %s. Reason: %s', os.date('%Y-%m-%d %H:%M:%S', ban.Length), ban.Reason))
            end
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