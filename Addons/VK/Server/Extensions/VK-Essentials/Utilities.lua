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
    [CategoryModeration] = 'Moderation'
}

--[[ Helper Functions ]]--
local function SendUserMessage(executor, message, prefix)
    prefix = prefix or ''

    local rankString = StrRanks[executor.GetRank()]
    local rankColour = Utilities.FileToJSON('Addons\\VK\\Settings\\Colours.json')['Ranks'][rankString]
    local output = string.format('[%s] %s: %s', rankString, executor.udata:getName(), message)

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

local function GetUser(identifier)
    if not identifier then return nil end

    for _, client in pairs(GClients) do
        if identifier == client.udata:getName() then
            return client
        else if identifier == client.udata:getID() then
            return client
        else if identifier == client.udata:getSecret() then
            return client
        else if identifier == client.mid then
            return client
        else if string.find(client.udata:getName(), identifier) then
            return client
        else if string.find(string.lower(client.udata:getName()), identifier) then
            return client
        end end end end end end
    end

    return nil
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
VKUtilities.SendUserMessage = SendUserMessage
VKUtilities.GetMessage = GetMessage
VKUtilities.GetUser = GetUser

return VKUtilities