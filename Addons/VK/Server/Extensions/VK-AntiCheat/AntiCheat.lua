local AntiCheat = {}

require('Addons.VK.Globals')

local Callbacks = Include('Addons.VK.Server.Extensions.VK-AntiCheat.Callbacks')

local function Initialize()
    GDLog('VK-AntiCheat Initialized')
    AntiCheat.Config = Utilities.FileToJSON('Addons/VK/Server/Extensions/VK-AntiCheat/Settings/Config.json')

    --[[ Initialize all Commmands ]]--
    AntiCheat.Commands = Utilities.GetCommands('VK-AntiCheat')
    Utilities.AddCommandTable(AntiCheat.Commands)
end

local function CreateClientData(client)
    GDLog('VK-AntiCheat : Creating Client Data')

    client['Detections'] = {}

    return client
end

AntiCheat.Initialize = Initialize
AntiCheat.CreateClientData = CreateClientData
AntiCheat.Callbacks = Callbacks

return AntiCheat