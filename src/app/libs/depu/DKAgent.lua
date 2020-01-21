local class = require('middleclass')
local DKAgent = class("DKAgent")
local GameLogic = require('app.libs.depu.DKGameLogic')

function DKAgent:initialize(pack)
    -- actor data
    self.actor = {}
    self.actor.uid = pack.actor.uid
    self.actor.avatar = pack.actor.avatar
    self.actor.sex = pack.actor.sex
    self.actor.nickName = pack.actor.nickName
    self.actor.diamond = pack.actor.diamond
    self.actor.playerId = pack.actor.playerId
    self.actor.ip = pack.actor.ip

    self.actor.win = pack.actor.win
    self.actor.lose = pack.actor.lose
    self.actor.cacheMsg = pack.actor.cacheMsg
    self.actor.x = pack.actor.x
    self.actor.y = pack.actor.y
    self.actor.vip = pack.actor.vip

    -- agent data
    self.chairIdx = pack.chairIdx
    self.isInMatch = pack.isInMatch 
    self.isPrepare = pack.isPrepare
    self.money = pack.money
    self.groupScore = pack.groupScore
    self.isLeaved = pack.isLeaved
    self.isTrusteeship = pack.isTrusteeship
    self.isAway = pack.isEnterBackground
    self.isSmartTrusteeship = pack.isSmartTrusteeship

    self.location = pack.location

    -- hand
    self:initHandWithPack(pack.hand)
end

function DKAgent:initHandWithPack(pack)
    if not pack then
        self.hand = false
        return
    end
    self.hand = pack        
    
    if pack.dealList then
        self:setHandCardData(pack.dealList)
    elseif pack.hand then
        local hand = pack.hand
        self:setHandCardData(hand)
    end

    if pack.summaryHand then
        local hand = pack.summaryHand
        self:setSummaryCardData(hand)
    end
end

function DKAgent:initHand()
    local hand = {}
    hand.hand = false 
  
    hand.blinds = false
    hand.putScore = false
    hand.allIn = false

    hand.putFirst = 0
    hand.putSecond = 0
    hand.putThird = 0
    hand.putForth = 0

    hand.choosed = false
    hand.niuCnt = false
    hand.specialType = false
    hand.maxCard = false
    hand.summaryHand = false

    hand.abandons = false

    hand.oneScore = false
    hand.isBanker = false
    hand.canPutMoney = false

    hand.maxCardsComb = {}

    self.hand = hand
end

function DKAgent:setHand(pack)
    local hand = {}
    hand.hand = false 
    
    if pack.hand then
      hand.hand = pack.hand
    end
  
    hand.blinds = pack.blinds
    hand.putScore = pack.putScore
    hand.allIn = pack.allIn

    hand.putFirst = pack.putFirst
    hand.putSecond = pack.putSecond
    hand.putThird = pack.putThird
    hand.putForth = pack.putForth

    hand.choosed = pack.choosed
    hand.niuCnt = pack.niuCnt
    hand.specialType = pack.specialType
    hand.maxCard = pack.maxCard
    hand.summaryHand = pack.summaryHand

    hand.abandons = pack.abandons

    hand.maxCardsComb = pack.maxCardsComb
    
    hand.oneScore = pack.oneScore
    hand.isBanker = pack.isBanker
    hand.canPutMoney = false

    self.hand = hand
end

--////////////////////////////////////////////////////////////////////////////////////////////////////////
--!xydesk
function DKAgent:setViewInfo(key, pos)
    self.viewKey = key
    self.viewPos = pos
end

function DKAgent:getViewInfo()
    return self.viewKey, self.viewPos
end
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--!hand

function DKAgent:setCanPutMoney(bool)
    if not self.hand then return end
    self.hand.canPutMoney = bool or false
end

function DKAgent:getCanPutMoney()
    if not self.hand then return end
    return self.hand.canPutMoney
end


function DKAgent:setFlagBanker(bool)
    if not self.hand then return end
    self.hand.isBanker = bool
end

function DKAgent:getFlagBanker()
    if not self.hand then return end
    return self.hand.isBanker
end

function DKAgent:setBlinds(putInfo)
    if not self.hand then return end
    self.hand.blinds = putInfo or 0
    self:setFirstPut(putInfo)
    self:setPutscore(putInfo)
end

function DKAgent:setAbandons(bool)
    self.hand.abandons = bool
end

function DKAgent:getAbandons()
    if not self.hand then return end
    return self.hand.abandons
end

function DKAgent:setAllIn()
    if not self.hand then return end
    self.hand.allIn = true
end

function DKAgent:getAllIn()
    return self.hand.allIn
end

function DKAgent:setHandCardData(data)
    if not self.hand then return end
    if #data > 0 then
        self.hand.hand = data
        return
    end
    local arr = GameLogic.hashCountsToArray(data)
    self.hand.hand = arr
end

function DKAgent:getHandCardData()
    if not self.hand then return end
    return self.hand.hand
end

function DKAgent:setChoosed(bool, niuCnt, spcialType, maxCard)
    if not self.hand then return end
    self.hand.choosed = bool
    if niuCnt then
        self.hand.niuCnt = niuCnt
    end
    if spcialType then
        self.hand.specialType = spcialType
    end
    if maxCard then
        self.hand.maxCard = maxCard
    end
end

function DKAgent:getChoosed()
    if not self.hand then return end
    local choose = false
    if self.hand.choosed then
        choose = true
    end
    return choose, self.hand.niuCnt, self.hand.specialType, self.hand.maxCard
end

function DKAgent:setCardComb(maxCardsComb)
    if not self.hand then return end
    if maxCardsComb and next(maxCardsComb) ~= nil then
        self.hand.maxCardsComb = maxCardsComb
    end
end

function DKAgent:getCardComb()
    if not self.hand then return end
    return self.hand.maxCardsComb or false
end

function DKAgent:setPutscore(score)
    if not self.hand then return end
    self.hand.putScore = score
end

function DKAgent:getPutscore()
    if not self.hand then return end
    return self.hand.putScore
end

function DKAgent:setFirstPut(score)
    if not self.hand then return end
    self.hand.putFirst = score
end

function DKAgent:setSecondPut(score)
    if not self.hand then return end
    self.hand.putSecond = score
    self.hand.putScore = self.hand.putFirst + score
end

function DKAgent:setThirdPut(score)
    if not self.hand then return end
    self.hand.putThird = score
    self.hand.putScore = self.hand.putFirst + self.hand.putSecond + score
end

function DKAgent:setForthPut(score)
    if not self.hand then return end
    self.hand.putForth = score
    self.hand.putScore = self.hand.putFirst + self.hand.putSecond + self.hand.putThird + score
end

function DKAgent:getFirstPut()
    return self.hand.putFirst or 0
end

function DKAgent:getSecondPut()
    return self.hand.putSecond or 0
end

function DKAgent:getThirdPut()
    return self.hand.putThird or 0
end

function DKAgent:getForthPut()
    return self.hand.putForth or 0
end

function DKAgent:getTimesPut(times)
    if self.hand then
        return self.hand['put' .. times] or 0
    end
    return 0
end

function DKAgent:setSummaryCardData(data)
    if not self.hand then return end
    if #data > 0 then
        self.hand.summaryHand = data
        return
    end
    local arr = GameLogic.hashCountsToArray(data)
    self.hand.summaryHand = arr
end

function DKAgent:getSummaryCardData()
    if not self.hand then return end
    return self.hand.summaryHand
end

function DKAgent:setScore(score)
    if not self.hand then return end
    self.hand.score = score
end

function DKAgent:getScore()
    if not self.hand then return end
    return self.hand.score
end

--////////////////////////////////////////////////////////////////////////////////////////////////////////
--!agent

function DKAgent:getActor()
    return self.actor
end

function DKAgent:getAvatar()
    return self.actor.avatar
end

function DKAgent:getNickname()
    return self.actor.nickName
end

function DKAgent:getUID()
    return self.actor.uid
end

function DKAgent:getChairID()
    return self.chairIdx
end

function DKAgent:setPrepare(bool)
    self.isPrepare = bool
end

function DKAgent:isReady()
    return self.isPrepare
end

function DKAgent:setDropLine(bool)
    self.isLeaved = bool
end

function DKAgent:isDropLine()
    return self.isLeaved
end

function DKAgent:setEnterBackground(bool)
    self.isAway = bool
end

function DKAgent:isEnterBackground()
    return self.isAway
end

function DKAgent:setTrusteeship(bool)
    self.isTrusteeship = bool
end

function DKAgent:getTrusteeship(bool)
    return self.isTrusteeship
end

function DKAgent:setMoney(money)
    self.money = money
end

function DKAgent:getMoney()
    return self.money
end

function DKAgent:setGroupScore(groupScore)
    self.groupScore = groupScore
end

function DKAgent:getGroupScore()
    return self.groupScore
end

function DKAgent:getSmartTrusteeship()
    return self.isSmartTrusteeship
end

function DKAgent:getSex()
    return self.actor.sex
end

function DKAgent:setInMatch(bool)
    self.isInMatch = bool
end

function DKAgent:getInMatch()
    return self.isInMatch
end

function DKAgent:getLocationInfo()
    return self.location
end

return DKAgent