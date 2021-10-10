local Command = {}

local VKUtilities = Include('Addons.VK.Server.Extensions.VK-Essentials.Utilities')

Command.Rank = VKUtilities.RankUser
Command.Category = VKUtilities.CategoryUtilities
Command.Description = 'Lists all commands'
Command.Execute = function(executor, arguments)
    
end

return Command