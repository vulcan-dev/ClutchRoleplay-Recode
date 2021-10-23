local Command = {}

local VKUtilities = Include('Addons.VK.Server.Extensions.VK-Essentials.Utilities')

Command.Rank = VKUtilities.RankUser
Command.Category = VKUtilities.CategoryUtilities
Command.Description = 'Get a clients playtime'
Command.Usage = 'playtime (user)'
Command.Execute = function(executor, arguments)
    local client = Server.GetUser(arguments[1])

    if client then
        Server.SendChatMessage(executor, client.GetName() .. '\'s Playtime: ' .. DateTime('%H:%M:%S', client.GetPlaytime()), Server.GetStatusColour('Information'))
    else
        Server.SendChatMessage(executor, 'Your Playtime: ' .. DateTime('%H:%M:%S', executor.GetPlaytime()), Server.GetStatusColour('Information'))
    end
end

return Command