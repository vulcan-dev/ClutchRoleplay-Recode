require('Addons.VK.Globals')

local Hooks = require('Addons.VK.Server.Hooks')
local Utilities = require('Addons.VK.Utilities')

local _Extensions = {}

local function ReloadModules()
    GILog('Reloading Modules Main')

    --[[ Reloading Includes
        1. Create a global function (Include(x))
            -> If it's already loaded then reload and return that module
        2. Call: _Includes = Include(_Includes)

        Note: The function can take in a path (string) or a list of modules (table)
    ]]

    --[[ Reload Extensions ]]--

    --[[ Setup Callbacks ]]--
end

--[[ Local Functions ]]--
local function Initialise()
    --[[ Load Extensions ]]--
    Extensions = Utilities.FileToJSON('Addons\\VK\\Settings\\Extensions.json')['Extensions']
    for _, extension in ipairs(Extensions) do
        _Extensions[extension] = Utilities.LoadExtension(extension)
        GILog('Loaded Extension: %s', extension)
    end

    --[[ Setup Callbacks ]]--
    for name, extension in pairs(_Extensions) do
        for callbackName, callback in pairs(_Extensions[name].Callbacks) do
            Hooks.Register(callbackName, name, callback)
        end
    end

    --[[ Setup Commands ]]--
    --[[ Setup Steps
        1. Load command files
        2. Get the module from that file
        3. Load it into GCommands [Table]
    ]]

    Hooks.Register('ReloadModules', 'ReloadModules', ReloadModules)
end

Initialise()