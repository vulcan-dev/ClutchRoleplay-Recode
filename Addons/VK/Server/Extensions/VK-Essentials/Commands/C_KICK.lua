local Command = {}

local VKUtilities = Include('Addons.VK.Server.Extensions.VK-Essentials.Utilities')

Command.Rank = VKUtilities.RankModerator
Command.Category = VKUtilities.CategoryModeration
Command.Description = 'Kick a User'
Command.Usage = 'kick <user> (reason)'
Command.Execute = function(executor, arguments)
    local client = Server.GetUser(arguments[1])
    local reason = VKUtilities.GetMessage(arguments, 2)
    
    if not client then return GErrorInvalidUser end
    if not reason then reason = 'No reason specified' end

    if client.offline then return client.GetName() .. ' is offline' end
    
    local reason = 'Kicked by ' .. executor.GetName() .. ': ' .. VKUtilities.GetMessage(arguments, 2)

    if executor.GetRank() <= client.GetRank() then return GErrorCannotPerformUser end

    if client.mid == GConsoleID then GWLog('%s tried to kick you.', executor.GetName()) return 'You cannot kick console' end

    client.Kick(reason)
    Server.DisplayDialogSuccess(executor, string.format('You kicked: %s', client.GetName()))
end

return Command