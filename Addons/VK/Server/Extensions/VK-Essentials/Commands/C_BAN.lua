local Command = {}

local VKUtilities = Include('Addons.VK.Server.Extensions.VK-Essentials.Utilities')

Command.Rank = VKUtilities.RankModerator
Command.Category = VKUtilities.CategoryModeration
Command.Description = 'Ban a user'
Command.Usage = 'ban <user> <time> (reason)\nExample: /ban dan 1d get rekt lad'
Command.Execute = function(executor, arguments)
    local client = Server.GetUser(arguments[1])
    local time = arguments[2]
    local bannedByWarn = arguments[4] or nil

    if bannedByWarn then table.remove(arguments, 4) end
    local reason = VKUtilities.GetMessage(arguments, 3)
    
    if not client then return GErrorInvalidUser end
    
    if executor.GetRank() <= client.GetRank() then return GErrorCannotPerformUser end
    
    if not time then return 'No Time Specified' end
    if not reason then reason = 'No reason specified' end
    
    time = VKUtilities.ParseTime(time)
    if not time then return 'Invalid Time Specified' end

    local ban = client.GetBanned()
    if ban then return client.GetName() .. ' is already banned' end

    client.AddBan(executor, reason, time)

    if not client.offline then
        client.Kick(string.format('Banned by: %s until %s. Reason: %s', executor.GetName(), os.date('%Y-%m-%d %H:%M:%S', time), reason))
    end

    if not bannedByWarn then
        Server.DisplayDialogSuccess(executor, string.format('Successfully Banned %s until %s', client.GetName(), os.date('%Y-%m-%d %H:%M:%S', time)))
    end
end

return Command