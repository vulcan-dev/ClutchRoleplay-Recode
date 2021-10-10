local Command = {}

local VKUtilities = Include('Addons.VK.Server.Extensions.VK-Essentials.Utilities')

Command.Rank = VKUtilities.RankModerator
Command.Category = VKUtilities.CategoryModeration
Command.Description = 'Kick a User'
Command.Execute = function(executor, arguments)
    local client = VKUtilities.GetUser(arguments[1])
    local reason = VKUtilities.GetMessage(arguments, 2)

    if not client then return GErrorInvalidUser end
    if not reason then return GErrorInvalidArguments end
end

return Command