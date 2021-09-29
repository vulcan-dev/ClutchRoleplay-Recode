local Essentials = {}

require('Addons.VK.Globals')

local Callbacks = require('Addons.VK.Server.Extensions.VK-Essentials.Callbacks')

local function CreateClientData(clientID, client)


    return client
end

Essentials.CreateClientData = CreateClientData
Essentials.Callbacks = Callbacks

return Essentials