local Essentials = {}

require('Addons.VK.Globals')

local Callbacks = Include('Addons.VK.Server.Extensions.VK-Essentials.Callbacks')
Essentials.Utilities = Include('Addons.VK.Server.Extensions.VK-Essentials.Utilities')

local function Initialize()
    --[[ Initialize all Commmands ]]--
    local commands = Utilities.GetCommands('VK-Essentials')
    Utilities.AddCommandTable(commands)
end

local function GenerateClient(client)
    --[[ Accessors ]]--
    client.GetRank = function() return client.GetKey('Rank') end
    client.GetPlaytime = function() end
    client.GetVehicleLimit = function() end
    client.GetBans = function() end
    client.GetMuted = function() end
    client.GetAliases = function() end
    client.GetWarnings = function() end

    --[[ Modifiers ]]--
    client.SetRank = function(rank) return client.EditKey('Rank', rank) end
    client.SetPlaytime = function(playtime) client.EditKey('Playtime', playtime) end
    client.SetVehicleLimit = function(limit) client.EditKey('VehicleLimit', limit) end
    client.SetMuted = function(executor, muted) client.EditKey('Mutes', function()
        return 'something'
    end) end

    client.AddBan = function(executor, reason, length) client.EditKey('Bans', function()
        return 'something'
    end) end

    client.AddAlias = function(name) client.EditKey('Aliases', function()
        return 'something'
    end) end

    client.AddWarn = function(executor, reason) client.EditKey('Warnings', function()
        return 'something'
    end) end

    return client
end

local function CreateClientData(client)
    GDLog('VK-Essentials : Creating Client Data')

    client['Rank'] = 0
    client['Playtime'] = 0
    client['VehicleLimit'] = 2

    client['Bans'] = {}
    client['Mutes'] = {}
    client['Kicks'] = {}
    client['Aliases'] = {}
    client['Warnings'] = {}

    return client
end

Essentials.Initialize = Initialize
Essentials.GenerateClient = GenerateClient
Essentials.CreateClientData = CreateClientData
Essentials.Callbacks = Callbacks

return Essentials