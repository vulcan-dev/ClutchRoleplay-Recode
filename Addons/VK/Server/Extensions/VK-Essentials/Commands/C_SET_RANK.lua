local Command = {}

local VKUtilities = Include('Addons.VK.Server.Extensions.VK-Essentials.Utilities')

Command.Rank = VKUtilities.RankAdmin
Command.Category = VKUtilities.CategoryUtilities
Command.Description = 'Set a User\'s Rank'
Command.Usage = 'set_rank <client> <rank (user, trusted, vip, moderator, admin)>'
Command.Alias = 'set_rank'
Command.Execute = function(executor, arguments)
    local client = Server.GetUser(arguments[1])
    local rank = arguments[2]

    if not client then return GErrorInvalidUser end
    if not rank then return GErrorInvalidArguments end

    --[[ Check if Executor is able to perform this action ]]--
    if tonumber(executor.GetRank()) <= tonumber(client.GetRank()) then return GErrorCannotPerformUser end

    local found = false
    local outStr = ''

    --[[ Check if Rank is Valid as a String ]]--
    for num, rankStr in pairs(VKUtilities.StrRanks) do
        if tonumber(rank) == num and VKUtilities.StrRanks[tonumber(rank)] then
            outStr = rankStr
            found = true
            break
        else if string.lower(rank) == string.lower(rankStr) then
            outStr = rankStr
            rank = num
            found = true
            break
        else if string.find(string.lower(rankStr), string.lower(rank)) then
            outStr = rankStr
            rank = num
            found = true
        end end end
    end

    if not found then return 'Invalid Rank Specified' end

    if tonumber(rank) == VKUtilities.RankConsole or string.lower(rank) == 'console' then return 'You cannot set this user\'s rank to Console' end

    Server.DisplayDialogSuccess(client, string.format('[Moderation] %s has set your rank to %s', executor.udata:getName(), outStr), Server.GetStatusColour('Success'))
    Server.DisplayDialogSuccess(executor, string.format('Successfully set %s role to: %s', client.GetName(), outStr))
    client.EditKey('Rank', tonumber(rank))
end

return Command