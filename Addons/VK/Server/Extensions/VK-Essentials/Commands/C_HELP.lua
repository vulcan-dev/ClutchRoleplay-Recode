local Command = {}

local VKUtilities = Include('Addons.VK.Server.Extensions.VK-Essentials.Utilities')

Command.Rank = VKUtilities.RankUser
Command.Category = VKUtilities.CategoryUtilities
Command.Usage = 'help | help (command) | help <extension> <category>'
Command.Description = 'Lists all commands and displays info'
Command.Execute = function(executor, arguments)
    local search = tostring(arguments[1])
    local extension = tostring(arguments[2])
    local category = tostring(arguments[3])
    local extensions = {}
    local command = nil

    local index = 0
    for category, _ in pairs(GExtensions) do
        extensions[index] = category
        index = index + 1
    end

    --[[ /help ]]--
    if search == 'nil' and extension == 'nil' and category == 'nil' then
        local output = 'Usage: help | help (command) | help <extension> <category>\nExtensions:\n'
        table.sort(extensions, function(a, b) return a > b end)
        for index, category in pairs(extensions) do
            output = output .. string.format('  %d: %s\n', index, category)
        end

        Server.SendChatMessage(executor, output, Server.GetStatusColour('Information'))
        return
    end

    --[[ /help (command) ]]--
    if search ~= 'nil' and extension == 'nil' then -- /help command
        command = GCommands[search]

        --[[ Check for Command Alias Instead ]]--
        if not command then
            for _, cmd in pairs(GCommands) do
                if cmd.Alias and type(cmd.Alias) == 'string' then
                    if search == cmd.Alias then
                        command = cmd
                        break
                    end
                else if cmd.Alias then
                    for _, alias in pairs(cmd.Alias) do
                        if search == alias then
                            command = cmd
                            break
                        end
                    end
                end end
            end
        end
    end

    --[[ help <extension> ]]
    if (not command and search ~= 'nil' or extension ~= 'nil') and category == 'nil' then
        extension = tostring(arguments[1])
        category = tostring(arguments[2])

        --[[ Look for Extension ]]--
        if not extensions[tonumber(extension)] then return 'Invalid Extension Provided (Do /help)' end
    end

    local categories = {}
    for _, command in pairs(GExtensions[extensions[tonumber(extension)]].Commands) do
        if VKUtilities.StrCategories[command.Category] then
            if not categories[command.Category] then
                categories[command.Category] = VKUtilities.StrCategories[command.Category]
            end
        end
    end
    --table.sort(categories, function(a, b) return a > b end)

    --[[ help <extension> <category> ]]
    if (not command and extension ~= 'nil') and categories[tonumber(category)] then
        local output = 'Commands for Category: ' .. VKUtilities.StrCategories[tonumber(category)] .. '\n'
        for commandName, command in pairs(GExtensions[extensions[tonumber(extension)]].Commands) do
            if command.Category == tonumber(category) and executor.GetRank() >= command.Rank then
                output = output .. '\nCommand: ' .. commandName
                output = output .. '\nDescription: ' .. command.Description
                if command.Usage then output = output .. '\nUsage: ' .. command.Usage .. '\n' end
            end
        end

        Server.SendChatMessage(executor, output, Server.GetStatusColour('Information'))
        return
    elseif (not command and extension ~= 'nil') and category == 'nil' then --[[ help <extension> ]]--
        --[[ Display Categories ]]--
        local output = 'Categories:\n'
        for index, category in pairs(categories) do
            output = output .. string.format('  %d: %s\n', index, category)
        end

        Server.SendChatMessage(executor, output, Server.GetStatusColour('Information'))
        return
    end

    if command and command.Description and command.Usage and executor.GetRank() >= command.Rank then
        local output = 'Category: ' .. VKUtilities.StrCategories[command.Category]
        output = output .. '\nDescription: ' .. command.Description
        output = output .. '\nUsage: ' .. command.Usage

        if command.Alias then
            if type(command.Alias) == 'table' then
                output = output .. '\nAliases: '
                for count, alias in pairs(command.Alias) do
                    output = output .. alias
                    if count ~= TableLength(command.Alias) then
                        output = output .. ', '
                    end
                end
            else
                output = output .. '\nAlias: ' .. command.Alias
            end
        end

        Server.SendChatMessage(executor, output, Server.GetStatusColour('Information'))
        return
    end
end

return Command
