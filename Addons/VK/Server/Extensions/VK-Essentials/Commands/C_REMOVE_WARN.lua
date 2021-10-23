local Command = {}

local VKUtilities = Include('Addons.VK.Server.Extensions.VK-Essentials.Utilities')

Command.Rank = VKUtilities.RankModerator
Command.Category = VKUtilities.CategoryModeration
Command.Description = 'Remove a warn from a client'
Command.Usage = 'remove_warn <user> <id>'
Command.Execute = function(executor, arguments)
    local client = Server.GetUser(arguments[1])
    local id = arguments[2]
    
    if not client then return GErrorInvalidUser end

    if executor.GetRank() <= client.GetRank() then return GErrorCannotPerformUser end

    local warns = client.GetKey('Warnings')
    if warns[id] then
        warns[id] = nil
        client.EditKey('Warnings', warns)
    end

    Server.DisplayDialogSuccess(executor, string.format('Successfully Removed Warn From: %s', client.GetName()))
end

return Command