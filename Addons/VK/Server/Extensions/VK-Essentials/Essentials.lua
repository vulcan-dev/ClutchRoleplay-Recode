local Essentials = {}

require('Addons.VK.Globals')

local Callbacks = Include('Addons.VK.Server.Extensions.VK-Essentials.Callbacks')
Essentials.Utilities = Include('Addons.VK.Server.Extensions.VK-Essentials.Utilities')

local function Initialize()
    --[[ Initialize all Commmands ]]--
    local commands = Utilities.GetCommands('VK-Essentials')
    Utilities.AddCommandTable(commands)
    GDLog('VK-Essentials Initialized')
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
    client.AddMute = function(executor, reason, length) client.EditKey('Mutes', function()
        local mutes = client.GetKey('Mutes')
        local muteCount = TableLength(mutes)

        mutes[tostring(muteCount+1)] = {
            MutedBy = executor.GetName(),
            Reason = reason,
            Length = length,
            ExpireryDate = os.date('%Y-%m-%d %H:%M:%S', length),
            MuteDate = os.date('%Y-%m-%d %H:%M:%S')
        }

        return mutes
    end) end

    client.AddBan = function(executor, reason, length) client.EditKey('Bans', function()
        local bans = client.GetKey('Bans')
        local banCount = TableLength(bans)

        bans[tostring(banCount+1)] = {
            BannedBy = executor.GetName(),
            Reason = reason,
            Length = length,
            ExpireryDate = os.date('%Y-%m-%d %H:%M:%S', length),
            BanDate = os.date('%Y-%m-%d %H:%M:%S')
        }

        return bans
    end) end

    client.AddAlias = function(name) client.EditKey('Aliases', function()
        local aliases = client.GetKey('Aliases')

        table.insert(aliases, name)
        return aliases
    end) end

    client.AddWarn = function(executor, reason) client.EditKey('Warnings', function()
        local warns = client.GetKey('Warnings')
        local warnCount = TableLength(warns)

        warns[tostring(warnCount+1)] = {
            WarnedBy = executor.GetName(),
            Reason = reason,
        }

        return warns
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