local Hooks = {}

require('Addons.VK.Globals')

local validHooks = {
    ['OnPlayerConnected'] = 0,
    ['OnPlayerDisconnected'] = 0,
    ['OnVehicleSpawned'] = 0,
    ['OnVehicleResetted'] = 0,
    ['OnVehicleRemoved'] = 0,
    ['OnStdIn'] = 0,
    ['OnChat'] = 0,
    ['Tick'] = 0
}

Hooks.CustomHooks = {}

local function Register(hook, subname, callback)
    if validHooks[hook] then
        hooks.register(hook, subname, callback)
        if string.find(subname, 'VK-') then
            GILog('Registered Callback { ' .. hook .. ' } : Extension { ' .. subname .. ' }')
        end
    else
        Hooks.CustomHooks[hook] = callback
        GILog('Registered Custom Callback { ' .. hook .. ' } : Extension { ' .. subname .. ' }')
    end
end

local function Call(hook, ...)
    if Hooks.CustomHooks[hook] then
        Hooks.CustomHooks[hook](...)
    end
end

Hooks.Register = Register
Hooks.Call = Call

return Hooks