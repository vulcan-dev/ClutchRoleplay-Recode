local Command = {}

local VKUtilities = Include('Addons.VK.Server.Extensions.VK-Essentials.Utilities')

Command.Rank = VKUtilities.RankAdmin
Command.Category = VKUtilities.CategoryAntiCheat
Command.Description = 'Enable/Disable Teleporting'
Command.Usage = '/set_teleport <1:0>'
Command.Alias = 'set_tp'
Command.Execute = function(executor, arguments)
    local value, err = Utilities.ToBoolean(arguments[1])
    if err then return err end

    local configFile = Utilities.FileToJSON('Addons/VK/Server/Extensions/VK-AntiCheat/Settings/Config.json')
    configFile['DisableTeleport'] = value

    Utilities.JSONToFile('Addons/VK/Server/Extensions/VK-AntiCheat/Settings/Config.json', configFile)

    Server.DisplayDialogSuccess(executor, 'AntiCheat: Set Disable Teleportation: ' .. tostring(value))
end

return Command