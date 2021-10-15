local Command = {}

local VKUtilities = Include('Addons.VK.Server.Extensions.VK-Essentials.Utilities')

Command.Rank = VKUtilities.RankModerator
Command.Category = VKUtilities.CategoryModeration
Command.Description = 'Warn a user'
Command.Usage = 'warn <user> <reason>'
Command.Execute = function(executor, arguments)
    local client = Server.GetUser(arguments[1])
    local reason = VKUtilities.GetMessage(arguments, 2)

    if not client then return GErrorInvalidUser end

    if executor.GetRank() <= client.GetRank() then return GErrorCannotPerformUser end

    client.AddWarn(executor, reason)
    if TableLength(client.GetWarnings()) >= 3 then -- should be == 3
        GCommands['ban'].Execute(GClients[GConsoleID], {client.GetSecret(), '1d', 'Exceeded warn amount', true})
    end

    Server.DisplayDialogSuccess(executor, string.format('Successfully Warned %s for: %s', client.GetName(), reason))
end

return Command