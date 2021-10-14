local Command = {}

local VKUtilities = Include('Addons.VK.Server.Extensions.VK-Essentials.Utilities')

Command.Rank = VKUtilities.RankModerator
Command.Category = VKUtilities.CategoryModeration
Command.Description = 'Ban a user'
Command.Usage = 'ban <user> <time> (reason)'
Command.Execute = function(executor, arguments)
    local client = Server.GetUser(arguments[1])

    if GClientCount == 0 then return 'No one is on the server' end

    if client then
        Server.SendChatMessage(executor, string.format('%s\'s ID: %s', client.GetName(), tonumber(client.mid)))
    else
        for _, client in pairs(GClients) do
            Server.SendChatMessage(executor, string.format('%s\'s ID: %s', client.GetName(), tonumber(client.mid)))
        end
    end
end

return Command