local Command = {}

local VKUtilities = Include('Addons.VK.Server.Extensions.VK-Essentials.Utilities')

Command.Rank = VKUtilities.RankUser
Command.Category = VKUtilities.CategoryUtilities
Command.Description = 'Return a User\'s ID'
Command.Usage = '/getmid (user)'
Command.Alias = { 'mid', 'get_mid' }
Command.Execute = function(executor, arguments)
    local client = VKUtilities.GetUser(arguments[1])

    if client then
        Server.SendChatMessage(executor, string.format('%s\'s ID: %s', client.udata:getName(), tonumber(client.mid)))
    else
        for _, client in pairs(GClients) do
            Server.SendChatMessage(executor, string.format('%s\'s ID: %s', client.udata:getName(), tonumber(client.mid)))
        end
    end
end

return Command