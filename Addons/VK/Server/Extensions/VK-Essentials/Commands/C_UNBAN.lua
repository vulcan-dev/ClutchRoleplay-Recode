local Command = {}

local VKUtilities = Include('Addons.VK.Server.Extensions.VK-Essentials.Utilities')

Command.Rank = VKUtilities.RankModerator
Command.Category = VKUtilities.CategoryModeration
Command.Description = 'Unbans a user'
Command.Usage = 'unban <user>'
Command.Execute = function(executor, arguments)
    local client = Server.GetUser(arguments[1])
    local time = arguments[2]
    local reason = VKUtilities.GetMessage(arguments, 3)
    
    if not client then return GErrorInvalidUser end

    if executor.GetRank() <= client.GetRank() then return GErrorCannotPerformUser end

    local ban = client.GetBanned()
    if not ban then return client.GetName() .. ' is not banned' end

    local bans = client.GetKey('Bans')
    bans[tostring(ban.ID)].Length = 0
    client.EditKey('Bans', bans)

    Server.DisplayDialogSuccess(executor, string.format('Successfully Banned %s', client.GetName()))
end

return Command