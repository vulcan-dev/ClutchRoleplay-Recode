local Command = {}

local VKUtilities = Include('Addons.VK.Server.Extensions.VK-Essentials.Utilities')

Command.Rank = VKUtilities.RankModerator
Command.Category = VKUtilities.CategoryModeration
Command.Description = 'Kick a User'
Command.Execute = function(executor, arguments)
    local client = Server.GetUser(arguments[1])
    local reason = VKUtilities.GetMessage(arguments, 2)

    if not client then return GErrorInvalidUser end
    if not reason then return 'No Reason Specified' end

    if executor.GetRank() <= client.GetRank() then return 'You cannot kick someone who is above you' end

    if client.mid == GConsoleID then GWLog('%s tried to kick you.', executor.GetName()) return 'You cannot kick console' end

    client.Kick(reason)
    Server.DisplayDialogSuccess(executor, string.format('You kicked: %s', client.GetName()))
end

return Command