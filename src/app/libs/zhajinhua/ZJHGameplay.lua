local class = require('middleclass')
local ZJHGameplay = class("ZJHGameplay")

function ZJHGameplay:initialize(pack)
    self:initWithPack(pack)
end

function ZJHGameplay:initWithPack(pack)
    self.played = pack.played
    self.isPlaying = pack.isPlaying
    self.state = pack.state
    self.tick = pack.tick

    self.gamePack = pack.gamePack
    self.currentPlayer = pack.gamePack and pack.gamePack.currentPlayer or false
    self.maxPut = pack.gamePack and pack.gamePack.maxPut or 0
    self.jackpot = pack.gamePack and pack.gamePack.jackpot or 0
    self.compareRound = pack.gamePack and pack.gamePack.currentPutScoreRound or 0

    self.qiangData = false -- 抢庄数据
end

-- //////////////////////////////////////////////////////////////
-- gamePack
function ZJHGameplay:initGamePack(pack)
    self.gamePack = pack
end

function ZJHGameplay:setBankerUID(bankerUID)
    if not self.gamePack then return end
    self.gamePack.banker = bankerUID
end

function ZJHGameplay:getBankerUID()
    if not self.gamePack then return end
    return self.gamePack.banker
end

function ZJHGameplay:setFlagFindBanker(bool)
    bool = bool or false
    if not self.gamePack then return end
    self.gamePack.isFindBanker = bool
end

function ZJHGameplay:getFlagFindBanker()
    if not self.gamePack then return end
    return self.gamePack.isFindBanker
end

function ZJHGameplay:setFlagDealAllPlayer(bool)
    bool = bool or false
    if not self.gamePack then return end
    self.gamePack.isDealAllPlayer = bool
end

function ZJHGameplay:getFlagDealAllPlayer()
    if not self.gamePack then return end
    return self.gamePack.isDealAllPlayer
end

function ZJHGameplay:setCurrentPlayer(currentPlayer)
    self.currentPlayer = currentPlayer
end

function ZJHGameplay:getCurrentPlayer()
    return self.currentPlayer
end

function ZJHGameplay:setMaxPut(maxPut)
    self.maxPut = maxPut
end

function ZJHGameplay:getMaxPut()
    return self.maxPut
end

function ZJHGameplay:getJackpot()
    return self.jackpot
end

function ZJHGameplay:setJackpot(jackpot)
    self.jackpot = jackpot
end

function ZJHGameplay:getCompareRound()
    return self.compareRound
end

function ZJHGameplay:setCompareRound(compareRound)
    self.compareRound = compareRound
end

-- //////////////////////////////////////////////////////////////
-- gameplay
function ZJHGameplay:setState(state, tick)
    tick = tick or 0
    self.state = state
    self.tick = tick
end

function ZJHGameplay:setTick(tick)
    self.tick = tick
end

function ZJHGameplay:getState()
    return self.state
end

function ZJHGameplay:getTick()
    self.tick = self.tick or 0
    local second = math.floor(self.tick / 1000)
    local millisecond = self.tick
    return second, millisecond
end

function ZJHGameplay:setQiangData(data)
    self.qiangData = data
end


return ZJHGameplay