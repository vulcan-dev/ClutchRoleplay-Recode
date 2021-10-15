local Command = {}

local VKUtilities = Include('Addons.VK.Server.Extensions.VK-Essentials.Utilities')

Command.Rank = VKUtilities.RankModerator
Command.Category = VKUtilities.CategoryModeration
Command.Description = 'Unmute a user'
Command.Usage = 'unmute <user>'
Command.Execute = function(executor, arguments)
    local client = Server.GetUser(arguments[1])
    local time = arguments[2]
    local reason = VKUtilities.GetMessage(arguments, 3)

    if not client then return GErrorInvalidUser end

    if executor.GetRank() <= client.GetRank() then return GErrorCannotPerformUser end

    local mute = client.GetMuted()
    if not mute then return client.GetName() .. ' is not muted' end

    local mutes = client.GetKey('Mutes')
    mutes[tostring(mute.ID)].Length = 0
    client.EditKey('Mutes', mutes)

    Server.DisplayDialogWarning(client, string.format('You have been unmuted by %s', executor.GetName()))
    Server.DisplayDialogSuccess(executor, string.format('Successfully Unmuted %s', client.GetName()))
end

return Command