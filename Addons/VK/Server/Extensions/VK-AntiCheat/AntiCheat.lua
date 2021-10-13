local AntiCheat = {}

require('Addons.VK.Globals')

local Callbacks = Include('Addons.VK.Server.Extensions.VK-Essentials.Callbacks')

local function CreateClientData(client)
    GDLog('VK-AntiCheat : Creating Client Data')

    client['Detections'] = {}

    return client
end

AntiCheat.CreateClientData = CreateClientData
AntiCheat.Callbacks = Callbacks

return AntiCheat