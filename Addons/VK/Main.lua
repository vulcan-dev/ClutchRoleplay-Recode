require('Addons.VK.Globals')

local _Extensions = {}

local function Setup()
    Hooks = Include('Addons.VK.Server.Hooks')
    Utilities = Include('Addons.VK.Utilities')
    Callbacks = Include('Addons.VK.Callbacks')

    --[[ Setup Server Settings ]]--
    local ServerConfig = Utilities.FileToJSON('Addons\\VK\\Settings\\Server.json')
    GLevel = GLevels[ServerConfig['Logging']['DefaultLogLevel']]
    GFileLogging = ServerConfig['Logging']['FileLogging']
    GLogFileLevel = GLevels[ServerConfig['Logging']['DefaultFileLogLevel']]

    --[[ Check if not running debug ]]--
    GProduction = ServerConfig['Production']
    if GProduction then GLogFilePath = 'Production' else GLogFilePath = 'Development' end
    if GFileLogging then GLogFile = string.format('Development (%s).log', GStartupTime) end

    --[[ Load Extensions ]]--
    GExtensions = Utilities.FileToJSON('Addons\\VK\\Settings\\Extensions.json')['Extensions']
    for _, extension in ipairs(GExtensions) do
        _Extensions[extension] = Utilities.LoadExtension(extension)
        GILog('Loaded Extension: %s', extension)
    end

    --[[ Setup Callbacks ]]--
    for name, _ in pairs(_Extensions) do
        for callbackName, callback in pairs(_Extensions[name].Callbacks) do
            Hooks.Register(callbackName, name, callback)
        end
    end

    GExtensions = _Extensions

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

        Server.Initialize()
        for extension, _ in pairs(GExtensions) do
            if GExtensions[extension].Initialize then GExtensions[extension].Initialize() end
        end
    end)

    --[[ Set Include Paths ]]--
    AddPath('Addons/VK')
    AddPath('Addons/VK/Server')
    AddPath('Addons/VK/Server/Extensions/VK-Essentials/Commands')

    --[[ Initialize Everything Else ]]--
    Server.Initialize()
    for extension, _ in pairs(GExtensions) do
        if GExtensions[extension].Initialize then GExtensions[extension].Initialize() end
    end
end

Initialise()

--[[ TODO ]]--
-- /set <option> <value>
--   example: /set prefix !
--   example: /set cmod 155:255:255 (RGB)