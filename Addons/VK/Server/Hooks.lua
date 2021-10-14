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

local Hooked = {}

local function Register(hook, subname, callback)
    if validHooks[hook] then
        if Hooked[string.format('%s:%s', hook, subname)] then
            GDLog('Already hooked') --fix
        else
            table.insert(Hooked, string.format('%s:%s', hook, subname))
            hooks.register(hook, subname, callback)
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