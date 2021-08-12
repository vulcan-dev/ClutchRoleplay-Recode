local Callbacks = {}

require('Addons.VK.Globals')

local _Includes = {
    Utilities = require('Addons.VK.Utilities'),
    Hooks = require('Addons.VK.Server.Hooks')
}

local function OnPlayerConnected(clientID)

end

local function OnPlayerDisconnected(clientID)

end

local function OnChat(clientID, message)

end

local function OnStdIn()
    for name, reload in pairs(_Includes.Hooks.CustomHooks) do
        if name:find('ReloadModules') then reload() end
    end
end

local function ReloadModules()
    GILog('Reloading Modules Essentials')
end

Callbacks.Callbacks = {
    ['OnPlayerConnected'] = OnPlayerConnected,
    ['OnPlayerDisconnected'] = OnPlayerDisconnected,
    ['OnChat'] = OnChat,
    ['OnStdIn'] = OnStdIn,
    ['[Essentials] ReloadModules'] = ReloadModules
}

return Callbacks