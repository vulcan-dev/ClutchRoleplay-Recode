local Events = {}

Events.Current = {}

local function Add(callback, name, time, runOnce)
    Events.Current[name] = {
        callback = callback,
        name = name,
        time = time,
        runOnce = runOnce,
        ran = false,
        firstPass = true,
        nextUpdate = 0
    }

    GDLog('Added Event: %s', name)
end

local function Remove(name)
    if Events.Current[name] then
        GDLog('Removed Event: %s', name)
        Events.Current[name] = nil
    end
end

local function Update()
    for _, event in pairs(Events.Current) do
        if not event.ran then
            if os.time() >= event.nextUpdate then
                event.nextUpdate = os.time() + event.time

                if event.runOnce then
                    if not event.firstPass then
                        event.ran = true
                        event.callback()
                    else
                        event.firstPass = false
                    end

                    event.firstPass = false
                else
                    if not event.firstPass then
                        event.callback()
                        Events.Remove(event.name)
                    else
                        event.firstPass = false
                    end
                end
            end
        end
    end
end

Events.Add = Add
Events.Remove = Remove
Events.Update = Update

return Events