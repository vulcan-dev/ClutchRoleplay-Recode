local Callbacks = {}

require('Addons.VK.Globals')

Server = Include('Addons.VK.Server.Server')

local function OnPlayerConnected(clientID)
    --[[ Shared OnChat ]]--
    Server.RegisterClient(clientID)
    local client = GClients[clientID]
    
    Server.DisplayDialog(client.udata:getName() .. ' has Connected!')
end

local function OnPlayerDisconnected(clientID)
    --[[ Shared OnChat ]]--
    local client = GClients[clientID]

    Server.DisplayDialog(client.udata:getName() .. ' has Left.')
    Server.DestroyClient(clientID)
end

local function OnChat(clientID, message)
    --[[ Shared OnChat ]]--
    local client = GClients[clientID]
    if GExtensions['VK-Essentials'] then
        --[[ Check if Command ]]--
        if string.sub(message, 1, 1) == Server.GetCommandPrefix() then
            local arguments = Utilities.ParseCommand(message, ' ')
            arguments[1] = string.lower(arguments[1]:sub(2))

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
            GExtensions['VK-Essentials'].Utilities.SendUserMessage(client, message)
        end

        return ''
    end

    return message
end

Callbacks.OnChat = OnChat
Callbacks.OnPlayerConnected = OnPlayerConnected
Callbacks.OnPlayerDisconnected = OnPlayerDisconnected

return Callbacks