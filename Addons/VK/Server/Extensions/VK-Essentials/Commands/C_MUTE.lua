local Command = {}

local VKUtilities = Include('Addons.VK.Server.Extensions.VK-Essentials.Utilities')

Command.Rank = VKUtilities.RankModerator
Command.Category = VKUtilities.CategoryModeration
Command.Description = 'Mute a user'
Command.Usage = 'mute <user> (time : default = 5m) (reason)\nExample: /mute dan 30m spamming'
Command.Execute = function(executor, arguments)
    local client = Server.GetUser(arguments[1])
    local time = arguments[2] or '5m'
    local reason = VKUtilities.GetMessage(arguments, 3)

    if not client then return GErrorInvalidUser end
    
    if executor.GetRank() <= client.GetRank() then return GErrorCannotPerformUser end

    if not time then return 'No Time Specified' end
    if not reason then reason = 'No reason specified' end

    time = VKUtilities.ParseTime(time)
    if not time then return 'Invalid Time Specified' end

    local mute = client.GetMuted()
    if mute then return client.GetName() .. ' is already muted until ' .. os.date('%Y-%m-%d %H:%M:%S', mute.Length) end

    client.AddMute(executor, reason, time)

    Server.DisplayDialogWarning(client, string.format('You have been muted by %s until %s. Reason: %s', executor.GetName(), os.date('%Y-%m-%d %H:%M:%S', time), reason))
    Server.DisplayDialogSuccess(executor, string.format('Successfully Muted %s until %s', client.GetName(), os.date('%Y-%m-%d %H:%M:%S', time)))
end

return Command