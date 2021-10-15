local Command = {}

local VKUtilities = Include('Addons.VK.Server.Extensions.VK-Essentials.Utilities')

Command.Rank = VKUtilities.RankUser
Command.Category = VKUtilities.CategoryUtilities
Command.Description = 'Return a Users ID'
Command.Usage = 'get_mid (user)'
Command.Alias = { 'mid', 'getmid' }
Command.Execute = function(executor, arguments)
    local client = Server.GetUser(arguments[1])

    if GClientCount == 0 then return 'No one is on the server' end

    if client then
        Server.SendChatMessage(executor, string.format('%s\'s ID: %s', client.GetName(), tonumber(client.mid)), Server.GetStatusColour('Information'))
    else
        for _, client in pairs(GClients) do
            Server.SendChatMessage(executor, string.format('%s\'s ID: %s', client.GetName(), tonumber(client.mid)), Server.GetStatusColour('Information'))
        end
    end
end

return Command