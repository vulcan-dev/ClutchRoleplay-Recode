local VKUtilities = {}

--[[ Ranks ]]--
local RankUser = 0
local RankTrusted = 1
local RankVIP = 2
local RankModerator = 3
local RankAdmin = 4
local RankOwner = 5
local RankDeveloper = 6
local RankConsole = 7

local StrRanks = {
    [RankUser] = 'User',
    [RankTrusted] = 'Trusted',
    [RankVIP] = 'VIP',
    [RankModerator] = 'Moderator',
    [RankAdmin] = 'Admin',
    [RankOwner] = 'Owner',
    [RankDeveloper] = 'Developer',
    [RankConsole] = 'Console'
}

--[[ Categories ]]--
local CategoryUtilities = 0
local CategoryModeration = 1

local StrCategories = {
    [CategoryUtilities] = 'Utilities',
    [CategoryModeration] = 'Moderation',
}

--[[ Helper Functions ]]--
local function SendUserMessage(executor, message, prefix)
    prefix = prefix or ''

    local rankString = StrRanks[executor.GetRank()]
    local rankColour = Utilities.FileToJSON('Addons/VK/Settings/Colours.json')['Ranks'][rankString]
    local output = string.format('[%s] %s: %s', rankString, executor.GetName(), message)

    Server.SendChatMessage(output, Utilities.ConvertColour(rankColour))
end

local function GetMessage(arguments, start)
    local pos = 0
    local message = ''
    for _, msg in pairs(arguments) do
        pos = pos + 1
        if pos >= start then
            message = message .. msg .. ' '
        end
    end

    if message == '' then return nil end

    return message
end

local function ParseTime(time)
    local time_fmt = time:sub(-1)
    time = time:sub(1, -2)

    local year, month, day, hour, min, sec = os.date('%Y-%m-%d %H:%M:%S'):match('(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)')
    local date = {
        year = year,
        month = month,
        day = day,
        hour = hour,
        min = min,
        sec = sec
    }

    if time_fmt == 'y' then
        date.year = date.year + time
    elseif time_fmt == 'mo' then
        date.month = date.month + time
    elseif time_fmt == 'd' then
        date.day = date.day + time
    elseif time_fmt == 'h' then
        date.hour = date.hour + time
    elseif time_fmt == 'm' then
        date.min = date.min + time
    elseif time_fmt == 's' then
        date.sec = date.sec + time
    else
        return nil
    end

    local exp_sec = os.time{ year = date.year, month = date.month, day = date.day, hour = date.hour, min = date.min, sec = date.sec }
    return exp_sec
end

--[[ Ranks ]]--
VKUtilities.RankUser = RankUser
VKUtilities.RankTrusted = RankTrusted
VKUtilities.RankVIP = RankVIP
VKUtilities.RankModerator = RankModerator
VKUtilities.RankAdmin = RankAdmin
VKUtilities.RankOwner = RankOwner
VKUtilities.RankDeveloper = RankDeveloper
VKUtilities.RankConsole = RankConsole
VKUtilities.StrRanks = StrRanks

VKUtilities.StrCategories = StrCategories
VKUtilities.CategoryUtilities = CategoryUtilities
VKUtilities.CategoryModeration = CategoryModeration
VKUtilities.SendUserMessage = SendUserMessage
VKUtilities.GetMessage = GetMessage
VKUtilities.ParseTime = ParseTime

return VKUtilities