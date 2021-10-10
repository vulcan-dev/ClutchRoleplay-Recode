local Moderation = {}

local RankUser = 0
local RankTrusted = 1
local RankVIP = 2
local RankModerator = 3
local RankAdmin = 4
local RankOwner = 5
local RankDeveloper = 6
local RankConsole = 7

local StrRanks = {
    [RankUser] = 'user',
    [RankTrusted] = 'trusted',
    [RankVIP] = 'vip',
    [RankModerator] = 'moderator',
    [RankAdmin] = 'admin',
    [RankOwner] = 'owner',
    [RankDeveloper] = 'developer',
    [RankConsole] = 'console'
}

local function SendUserMessage(executor, message, prefix)
    prefix = prefix or ''
end

return Moderation