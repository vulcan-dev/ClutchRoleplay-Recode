require('Addons.VK.Globals')

Hooks = require('Addons.VK.Server.Hooks')
Utilities = require('Addons.VK.Utilities')

local _Extensions = {}

local function Setup()
    --[[ Load Extensions ]]--
    local Extensions = Utilities.FileToJSON('Addons\\VK\\Settings\\Extensions.json')['Extensions']
    for _, extension in ipairs(Extensions) do
        _Extensions[extension] = Utilities.LoadExtension(extension)
        GILog('Loaded Extension: %s', extension)
    end

    --[[ Setup Callbacks ]]--
    for name, _ in pairs(_Extensions) do
        for callbackName, callback in pairs(_Extensions[name].Callbacks) do
            Hooks.Register(callbackName, name, callback)
        end
    end
end

--[[ Local Functions ]]--
local function Initialise()
    Setup()

    -- Setup ReloadModules --
    hooks.register('OnStdIn', 'ReloadModules', function()
        GILog('Reloading Modules')
        Initialise()
    end)

    AddPath('Addons/VK')
    AddPath('Addons/VK/Server')
end

Initialise()