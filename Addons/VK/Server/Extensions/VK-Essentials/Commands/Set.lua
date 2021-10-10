local Command = {}

local VKUtilities = Include('Addons.VK.Server.Extensions.VK-Essentials.Utilities')

Command.Rank = VKUtilities.RankDeveloper
Command.Category = VKUtilities.CategoryUtilities
Command.Description = 'Set a key in settings'
Command.Execute = function(executor, arguments)
    local type = arguments[1]
    if not type then return GErrorInvalidArguments end

    local TypeColour = 0
    local TypeExtension = 1
    local TypeServer = 2

    local Types = {
        [TypeColour] = 'Colour',
        [TypeExtension] = 'Extension',
        [TypeServer] = 'Server'
    }

    local found = false

    for num, typeStr in pairs(Types) do
        if tonumber(type) == num and VKUtilities.StrRanks[tonumber(type)] then
            found = true
            break
        else if string.lower(type) == string.lower(typeStr) then
            type = num
            found = true
            break
        end end
    end

    if not found then return 'Invalid Type (Types: 0: Colour | 1: Extension | 2: Server' end

    if type == TypeColour then
        local category = arguments[2]
        local rank = arguments[3]
        local colour = arguments[4]

        local colours = Utilities.ParseCommand(colour, ':')
        colours = Utilities.ConvertColour(colours)

        local colourJson = Utilities.FileToJSON('Addons\\VK\\Settings\\Colours.json')
        if colourJson['Ranks'][rank] then
            colourJson['Ranks'][rank].r = colours.r

            Utilities.JSONToFile('Addons\\VK\\Settings\\Colours.json', colourJson)
        end
    else if type == TypeExtension then

    else if type == TypeServer then

    end end end
end

return Command