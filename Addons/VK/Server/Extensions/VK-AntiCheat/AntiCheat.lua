local AntiCheat = {}

require('Addons.VK.Globals')

local Callbacks = require('Addons.VK.Server.Extensions.VK-Essentials.Callbacks')

local function CreateClientData(clientID, client)


    return client
end

AntiCheat.CreateClientData = CreateClientData
AntiCheat.Callbacks = Callbacks

return AntiCheat