require('Addons.VK.Globals')
local Hooks = require('Addons.VK.Server.Hooks')
local Essentials = require('Addons.VK.Server.Extensions.VK-Essentials.Callbacks')
local Utilities = require('Addons.VK.Utilities')

local _Extensions = {}

local function ReloadModules()
    GILog('Reloading Modules Main')
end

--[[ Local Functions ]]--
local function Initialise()
    Extensions = Utilities.FileToJSON('Addons\\VK\\Settings\\Extensions.json')['Extensions']
    for _, extension in ipairs(Extensions) do
        GDLog('Extension Found: %s', extension)
        _Extensions[extension] = Utilities.LoadExtension(extension)
    end

    for name, extension in pairs(_Extensions) do
        for callbackName, callback in pairs(_Extensions[name].Callbacks) do
            Hooks.Register(callbackName, name, callback)
        end
    end

    Hooks.Register('ReloadModules', 'ReloadModules', ReloadModules)
end

Initialise()