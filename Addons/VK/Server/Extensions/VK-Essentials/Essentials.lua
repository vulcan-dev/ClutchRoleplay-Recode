local Essentials = {}

require('Addons.VK.Globals')

local Callbacks = Include('Addons.VK.Server.Extensions.VK-Essentials.Callbacks')
Essentials.Utilities = Include('Addons.VK.Server.Extensions.VK-Essentials.Utilities')

local function Initialize()
    --[[ Initialize all Commmands ]]--
    Essentials.Commands = Utilities.GetCommands('VK-Essentials')
    Utilities.AddCommandTable(Essentials.Commands)
    GDLog('VK-Essentials Initialized')
end

local function GenerateClient(client)
    --[[ Accessors ]]--
    client.GetRank = function() return client.GetKey('Rank') end
    client.GetPlaytime = function() return client.GetKey('Playtime') end
    client.GetVehicleLimit = function() return client.GetKey('VehicleLimit') end
    client.GetBanned = function() for k, v in pairs(client.GetKey('Bans')) do if v.Length > 0 then return v end end return nil end
    client.GetMuted = function() for k, v in pairs(client.GetKey('Mutes')) do if v.Length > 0 then return v end end return nil end
    client.GetAliases = function() return client.GetKey('Aliases') end
    client.GetWarnings = function() return client.GetKey('Warnings') end

    --[[ Modifiers ]]--
    client.SetRank = function(rank) return client.EditKey('Rank', rank) end
    client.SetPlaytime = function(playtime) client.EditKey('Playtime', playtime) end
    client.SetVehicleLimit = function(limit) client.EditKey('VehicleLimit', limit) end
    client.AddMute = function(executor, reason, length) 
        local mutes = client.GetKey('Mutes')
        local muteCount = TableLength(mutes)
        muteCount = muteCount + 1

        mutes[tostring(muteCount)] = {
            MutedBy = executor.GetName(),
            Reason = reason,
            Length = length,
            ExpireryDate = os.date('%Y-%m-%d %H:%M:%S', length),
            MuteDate = os.date('%Y-%m-%d %H:%M:%S'),
            ID = tonumber(muteCount)
        }

        client.EditKey('Mutes', mutes)
    end

    client.AddBan = function(executor, reason, length)
        local bans = client.GetKey('Bans')
        local banCount = TableLength(bans)
        banCount = banCount + 1

        bans[tostring(banCount)] = {
            BannedBy = executor.GetName(),
            Reason = reason,
            Length = length,
            ExpireryDate = os.date('%Y-%m-%d %H:%M:%S', length),
            BanDate = os.date('%Y-%m-%d %H:%M:%S'),
            ID = tonumber(banCount)
        }

        client.EditKey('Bans', bans)
    end

    client.AddAlias = function(name) local aliases = client.GetKey('Aliases') table.insert(aliases, name) client.EditKey('Aliases', aliases) end

    client.AddKick = function(executor, reason)
        local kicks = client.GetKey('Kicks')
        local kickCount = TableLength(kicks)
        kickCount = kickCount + 1

        kicks[tostring(kickCount)] = {
            KickedBy = executor.GetName(),
            Date = os.date('%Y-%m-%d %H:%M:%S'),
            Reason = reason,
            ID = kickCount
        }
    end

    client.AddWarn = function(executor, reason)
        local warns = client.GetKey('Warnings')
        local warnCount = TableLength(warns)
        warnCount = warnCount + 1

        warns[tostring(warnCount)] = {
            WarnedBy = executor.GetName(),
            Date = os.date('%Y-%m-%d %H:%M:%S'),
            Reason = reason,
            ID = warnCount
        }
        client.EditKey('Warnings', warns)
    end

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