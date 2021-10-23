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

local function OnPlayerDisconnected(clientID)
    
end

local function OnChat(clientID, message)
    local client = GClients[clientID]

    --[[ Check if Command ]]--
    if string.sub(message, 1, 1) == Server.GetCommandPrefix() then
        local arguments = Utilities.ParseCommand(message, ' ')
        arguments[1] = string.lower(arguments[1]:sub(1))
        
        local command = GCommands[arguments[1]]

        --[[ Check for Command Alias Instead ]]--
        if not command then
            for _, cmd in pairs(GCommands) do
                if cmd.Alias and type(cmd.Alias) == 'string' then
                    if arguments[1] == cmd.Alias then
                        command = cmd
                        break
                    end
                else if cmd.Alias then
                    for _, alias in pairs(cmd.Alias) do
                        if arguments[1] == alias then
                            command = cmd
                            break
                        end
                    end
                end end
            end
        end

        local canExecuteWithRole = false
        if GExtensions['VK-Roleplay'] then
            --[[ Check for Valid Roles ]]--
            canExecuteWithRole = GExtensions['VK-Roleplay'].Utilities.CanExecute(client)
        else
            if command then
                if client.GetRank() >= command.Rank then
                    table.remove(arguments, 1)
                    local retValue = command.Execute(client, arguments)
                    if retValue then
                        Server.DisplayDialogError(client, retValue)
                    end
                else
                    Server.DisplayDialogError(client, GErrorInsufficentPermissions)
                end
            else
                Server.DisplayDialogError(client, 'Invalid Command Supplied')
            end
        end
    else
        local mute
        if client.GetID() ~= GConsoleID then mute = client.GetMuted() else mute = false end
        if mute then
            if mute.Length > 0 then
                if mute.Length <= os.time() then
                    local mutes = client.GetKey('Mutes')
                    mutes[tostring(mute.ID)].Length = 0
                    client.EditKey('Mutes', mutes)
                else
                    return ''
                end
            end
        else
            GExtensions['VK-Essentials'].Utilities.SendUserMessage(client, message)
        end
    end

    return ''
end

local function OnTick()
    GExtensions['VK-Essentials'].UpdateClientPlaytime()
    GExtensions['VK-Essentials'].UpdateClientMute()
end

Callbacks['OnPlayerConnected'] = OnPlayerConnected
Callbacks['OnPlayerDisconnected'] = OnPlayerDisconnected
Callbacks['OnChat'] = OnChat
Callbacks['Tick'] = OnTick

return Callbacks