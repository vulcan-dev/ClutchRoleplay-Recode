require('Addons.VK.Globals')

local _Extensions = {}

local function Setup()
    Hooks = Include('Addons.VK.Server.Hooks')
    Utilities = Include('Addons.VK.Utilities')
    Callbacks = Include('Addons.VK.Callbacks')

    --[[ Setup Server Settings ]]--
    local Server = Utilities.FileToJSON('Addons\\VK\\Settings\\Server.json')
    GLevel = GLevels[Server['Logging']['DefaultLogLevel']]
    GFileLogging = Server['Logging']['FileLogging']
    GLogFileLevel = GLevels[Server['Logging']['DefaultFileLogLevel']]

    --[[ Check if not running debug ]]--
    GProduction = Server['Production']
    if GProduction then GLogFilePath = 'Production' else GLogFilePath = 'Development' end
    if GFileLogging then GLogFile = string.format('Development (%s).log', GStartupTime) end

    --[[ Load Extensions ]]--
    GExtensions = Utilities.FileToJSON('Addons\\VK\\Settings\\Extensions.json')['Extensions']
    for _, extension in ipairs(GExtensions) do
        GExtensions[extension] = 1
        _Extensions[extension] = Utilities.LoadExtension(extension)
        GILog('Loaded Extension: %s', extension)
    end

    --[[ Setup Callbacks ]]--
    for name, _ in pairs(_Extensions) do
        for callbackName, callback in pairs(_Extensions[name].Callbacks) do
            Hooks.Register(callbackName, name, callback)
        end
    end

    --[[ Shared Callbacks ]]--
    Hooks.Register('OnChat', 'OnChatCallback', Callbacks.OnChat)
    Hooks.Register('OnPlayerConnected', 'OnPlayerConnectedCallback', Callbacks.OnPlayerConnected)
    Hooks.Register('OnPlayerDisconnected', 'OnPlayerDisconnectedCallback', Callbacks.OnPlayerDisconnected)
end

--[[ Local Functions ]]--
local function Initialise()
    GStartupTime = DateTime('%d-%m-%Y %H-%M-%S')
    Setup()

    -- Setup ReloadModules --
    hooks.register('OnStdIn', 'ReloadModules', function()
        GILog('Reloading Modules')
        Setup()
    end)

    AddPath('Addons/VK')
    AddPath('Addons/VK/Server')
end

Initialise()

--[[ TODO ]]--
-- /set <option> <value>
--   example: /set prefix !
--   example: /set cmod 155:255:255 (RGB)