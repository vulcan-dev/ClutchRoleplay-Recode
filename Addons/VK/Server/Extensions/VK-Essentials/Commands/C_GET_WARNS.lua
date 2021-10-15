local Command = {}

local VKUtilities = Include('Addons.VK.Server.Extensions.VK-Essentials.Utilities')

Command.Rank = VKUtilities.RankModerator
Command.Category = VKUtilities.CategoryModeration
Command.Description = 'Get all previous warnings from client'
Command.Usage = '/get_warns <user>'
Command.Alias = 'warns'
Command.Execute = function(executor, arguments)
    local client = Server.GetUser(arguments[1])

    if not client then return GErrorInvalidUser end

    local output = string.format('===== Warns for %s =====', client.GetName())
    for _, warn in pairs(client.GetWarnings()) do
        output = output .. '\n  [ID]: ' .. warn.ID
        output = output .. '\n    Reason: ' .. warn.Reason
        output = output .. '\n    Warned By: ' .. warn.WarnedBy
    end

    Server.SendChatMessage(executor, output, Server.GetStatusColour('Information'))
end

return Command