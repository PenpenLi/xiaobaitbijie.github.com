local class = require('middleclass')
local PJGameplay = class("PJGameplay")

function PJGameplay:initialize(pack)
    self:initWithPack(pack)
end

function PJGameplay:initWithPack(pack)
    self.played = pack.played
    self.isPlaying = pack.isPlaying
    self.state = pack.state
    self.tick = pack.tick

    self.gamePack = pack.gamePack

    self.qiangData = false -- 抢庄数据
end

-- //////////////////////////////////////////////////////////////
-- gamePack
function PJGameplay:initGamePack(pack)
    self.gamePack = pack
end

function PJGameplay:setBankerUID(bankerUID)
    if not self.gamePack then return end
    self.gamePack.banker = bankerUID
end

function PJGameplay:getBankerUID()
    if not self.gamePack then return end
    return self.gamePack.banker
end

function PJGameplay:setFlagFindBanker(bool)
    bool = bool or false
    if not self.gamePack then return end
    self.gamePack.isFindBanker = bool
end

function PJGameplay:getFlagFindBanker()
    if not self.gamePack then return end
    return self.gamePack.isFindBanker
end

function PJGameplay:setFlagDealAllPlayer(bool)
    bool = bool or false
    if not self.gamePack then return end
    self.gamePack.isDealAllPlayer = bool
end

function PJGameplay:getFlagDealAllPlayer()
    if not self.gamePack then return end
    return self.gamePack.isDealAllPlayer
end


-- //////////////////////////////////////////////////////////////
-- gameplay

function PJGameplay:setState(state, tick)
    tick = tick or 0
    self.state = state
    self.tick = tick
end

function PJGameplay:getState()
    return self.state
end

function PJGameplay:getTick()
    self.tick = self.tick or 0
    local second = math.floor(self.tick/1000)
    local millisecond = self.tick
    return second, millisecond
end

function PJGameplay:setQiangData(data)
    self.qiangData = data
end


return PJGameplay