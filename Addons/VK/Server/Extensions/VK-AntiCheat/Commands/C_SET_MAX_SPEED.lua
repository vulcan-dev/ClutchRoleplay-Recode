local Command = {}

local VKUtilities = Include('Addons.VK.Server.Extensions.VK-Essentials.Utilities')

Command.Rank = VKUtilities.RankAdmin
Command.Category = VKUtilities.CategoryUtilities
Command.Description = 'Set vehicle max speed'
Command.Usage = '/set_max_speed <mph>'
Command.Alias = 'sms'
Command.Execute = function(executor, arguments)
    local speed = arguments[1]

    if not speed then return 'Invalid Speed Supplied' end

    local configFile = Utilities.FileToJSON('Addons/VK/Server/Extensions/VK-AntiCheat/Settings/Config.json')
    configFile['VehicleMaxSpeedMPH'] = speed

    Utilities.JSONToFile('Addons/VK/Server/Extensions/VK-AntiCheat/Settings/Config.json', configFile)

    Server.DisplayDialogSuccess(executor, 'AntiCheat: Set Max Vehicle Speed to: ' .. speed)
end

return Command