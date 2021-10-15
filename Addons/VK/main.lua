require('Addons.VK.Globals')

local _Extensions = {}

--[[ BeamMP Helpers ]] --
local function onPlayerConnected(clientID)
    Callbacks.OnPlayerDisconnected(clientID)
end
local function onPlayerDisonnect(clientID)
    Callbacks.OnPlayerDisconnected(clientID)
end
local function onChatMessage(clientID, _, message)
    Callbacks.OnChat(clientID, message)
end
--[[ BeamMP Helpers End ]]

local function Setup()
    JSON = Include('Addons.VK.JSON')
    Hooks = Include('Addons.VK.Server.Hooks')
    Utilities = Include('Addons.VK.Utilities')
    Callbacks = Include('Addons.VK.Callbacks')
    Events = Include('Addons.VK.Server.Events')

    --[[ Setup Server Settings ]] --
    local ServerConfig = Utilities.FileToJSON('Addons/VK/Settings/Server.json')
    GLevel = GLevels[ServerConfig['Logging']['DefaultLogLevel']]
    GFileLogging = ServerConfig['Logging']['FileLogging']
    GLogFileLevel = GLevels[ServerConfig['Logging']['DefaultFileLogLevel']]

    --[[ Check if not running debug ]] --
    GProduction = ServerConfig['Production']
    if GProduction then
        GLogFilePath = 'Production'
    else
        GLogFilePath = 'Development'
    end

    if GFileLogging then
        GLogFile = string.format('Development (%s).log', GStartupTime)
    end

    --[[ Check if we should run for BeamMP ]] --
    GBeamMPCompat = ServerConfig['BeamMP']

    --[[ Load Extensions ]] --
    GExtensions = Utilities.FileToJSON('./Addons/VK/Settings/Extensions.json')['Extensions']
    for _, extension in pairs(GExtensions) do
        _Extensions[extension] = Utilities.LoadExtension(extension)
        GILog('Loaded Extension: %s', extension)
    end

    --[[ Setup Callbacks ]] --
    for name, _ in pairs(_Extensions) do
        for callbackName, callback in pairs(_Extensions[name].Callbacks) do
            if callbackName ~= 'OnPlayerConnected' then
                Hooks.Register(callbackName, name, callback)
            end
        end
    end

    GExtensions = _Extensions

    --[[ Shared Callbacks ]] --
    if not GBeamMPCompat then
        Hooks.Register('OnChat', 'OnChat', Callbacks.OnChat)
        Hooks.Register('OnPlayerConnected', 'OnPlayerConnected', Callbacks.OnPlayerConnected)
        Hooks.Register('OnPlayerDisconnected', 'OnPlayerDisconnected', Callbacks.OnPlayerDisconnected)
        Hooks.Register('Tick', 'Tick', Callbacks.Tick)
    else
        Hooks.Register('onChatMessage', 'onChatMessage')
        Hooks.Register('onPlayerConnected', 'onPlayerConnected')
        Hooks.Register('onPlayerDisconnected', 'onPlayerDisconnected')
    end
end

--[[ Local Functions ]] --
local function Initialise()
    GStartupTime = DateTime('%d-%m-%Y %H-%M-%S')
    Setup()

    --[[ Set Include Paths ]] --
    AddPath('Addons/VK')
    AddPath('Addons/VK/Server')
    AddPath('Addons/VK/Server/Extensions/VK-Essentials/Commands')

    --[[ Initialize Everything Else ]] --
    if not GServerInitialized then Server.Initialize() GServerInitialized = true end
    for extension, _ in pairs(GExtensions) do
        if GExtensions[extension].Initialize then
            GExtensions[extension].Initialize()
        end
    end

    -- Setup ReloadModules --
    hooks.register('OnStdIn', 'ReloadModules', function(message)
        if message == '/rl' then
            GILog('Reloading Modules')
            Setup()

            Server.Initialize()
            for extension, _ in pairs(GExtensions) do
                if GExtensions[extension].Initialize then
                    GExtensions[extension].Initialize()
                end
            end
        else
            Callbacks.OnStdIn(message)
        end
    end)
end

Initialise()

--[[ TODO ]] --
-- /set <option> <value>
--   example: /set prefix !
--   example: /set cmod 155:255:255 (RGB)
