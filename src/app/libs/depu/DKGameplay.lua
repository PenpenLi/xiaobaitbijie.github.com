local class = require('middleclass')
local DKGameplay = class("DKGameplay")

function DKGameplay:initialize(pack)
    self:initWithPack(pack)
end

function DKGameplay:initWithPack(pack)
    self.played = pack.played
    self.isPlaying = pack.isPlaying
    self.state = pack.state
    self.tick = pack.tick
    
    self.gamePack = pack.gamePack
    self.currentPlayer = pack.gamePack and pack.gamePack.currentPlayer or false
    self.lastPlayer = pack.gamePack and pack.gamePack.lastPlayer or false
    self.publicCard = pack.gamePack and pack.gamePack.publicCard or false
    self.maxPut = pack.gamePack and pack.gamePack.maxPut or 0
    self.jackpot = pack.gamePack and pack.gamePack.jackpot or 0

    self.qiangData = false -- 抢庄数据
end

-- //////////////////////////////////////////////////////////////
-- gamePack
function DKGameplay:initGamePack(pack)
    self.gamePack = pack
end

function DKGameplay:setBankerUID(bankerUID)
    if not self.gamePack then return end
    self.gamePack.banker = bankerUID
end

function DKGameplay:getBankerUID()
    if not self.gamePack then return end
    return self.gamePack.banker
end

function DKGameplay:setFlagFindBanker(bool)
    bool = bool or false
    if not self.gamePack then return end
    self.gamePack.isFindBanker = bool
end

function DKGameplay:getFlagFindBanker()
    if not self.gamePack then return end
    return self.gamePack.isFindBanker
end

function DKGameplay:setFlagDealAllPlayer(bool)
    bool = bool or false
    if not self.gamePack then return end
    self.gamePack.isDealAllPlayer = bool
end

function DKGameplay:getFlagDealAllPlayer()
    if not self.gamePack then return end
    return self.gamePack.isDealAllPlayer
end

function DKGameplay:setPublicCard(publicCard)
    self.publicCard = publicCard
end

function DKGameplay:getPublicCard()
    return self.publicCard
end

function DKGameplay:setCurrentPlayer(currentPlayer)
    self.currentPlayer = currentPlayer
end

function DKGameplay:getCurrentPlayer()
    return self.currentPlayer
end

function DKGameplay:setLastPlayer(lastPlayer)
    self.lastPlayer = lastPlayer
end

function DKGameplay:getLastPlayer()
    return self.lastPlayer
end

function DKGameplay:setMaxPut(maxPut)
    self.maxPut = maxPut
end

function DKGameplay:getMaxPut()
    return self.maxPut
end

function DKGameplay:getJackpot()
    return self.jackpot
end

function DKGameplay:setJackpot(jackpot)
    self.jackpot = jackpot
end

-- //////////////////////////////////////////////////////////////
-- gameplay

function DKGameplay:setState(state, tick)
    tick = tick or 0
    self.state = state
    self.tick = tick
end

function DKGameplay:setTick(tick)
    self.tick = tick
end

function DKGameplay:getState()
    return self.state
end

function DKGameplay:getTick()
    self.tick = self.tick or 0
    local second = math.floor(self.tick/1000)
    local millisecond = self.tick
    return second, millisecond
end

function DKGameplay:setQiangData(data)
    self.qiangData = data
end


return DKGameplay