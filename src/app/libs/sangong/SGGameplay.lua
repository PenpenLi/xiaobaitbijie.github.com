local class = require('middleclass')
local SGGameplay = class("SGGameplay")

function SGGameplay:initialize(pack)
    self:initWithPack(pack)
end

function SGGameplay:initWithPack(pack)
    self.played = pack.played
    self.isPlaying = pack.isPlaying
    self.state = pack.state
    self.tick = pack.tick

    self.gamePack = pack.gamePack

    self.qiangData = false -- 抢庄数据
end

-- //////////////////////////////////////////////////////////////
-- gamePack
function SGGameplay:initGamePack(pack)
    self.gamePack = pack
end

function SGGameplay:setBankerUID(bankerUID)
    if not self.gamePack then return end
    self.gamePack.banker = bankerUID
end

function SGGameplay:getBankerUID()
    if not self.gamePack then return end
    return self.gamePack.banker
end

function SGGameplay:setFlagFindBanker(bool)
    bool = bool or false
    if not self.gamePack then return end
    self.gamePack.isFindBanker = bool
end

function SGGameplay:getFlagFindBanker()
    if not self.gamePack then return end
    return self.gamePack.isFindBanker
end

function SGGameplay:setFlagDealAllPlayer(bool)
    bool = bool or false
    if not self.gamePack then return end
    self.gamePack.isDealAllPlayer = bool
end

function SGGameplay:getFlagDealAllPlayer()
    if not self.gamePack then return end
    return self.gamePack.isDealAllPlayer
end


-- //////////////////////////////////////////////////////////////
-- SGGameplay

function SGGameplay:setState(state, tick)
    tick = tick or 0
    self.state = state
    self.tick = tick
end

function SGGameplay:getState()
    return self.state
end

function SGGameplay:getTick()
    self.tick = self.tick or 0
    local second = math.floor(self.tick/1000)
    local millisecond = self.tick
    return second, millisecond
end

function SGGameplay:setQiangData(data)
    self.qiangData = data
end


return SGGameplay