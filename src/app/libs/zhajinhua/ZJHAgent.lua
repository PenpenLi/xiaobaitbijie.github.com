local class = require('middleclass')
local ZJHAgent = class("ZJHAgent")
local GameLogic = require('app.libs.zhajinhua.ZJHGameLogic')

function ZJHAgent:initialize(pack)
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
    self.autoOperation = pack.autoOperation

    self.location = pack.location

    -- hand
    self:initHandWithPack(pack.hand)
end

function ZJHAgent:initHandWithPack(pack)
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

function ZJHAgent:initHand()
    local hand = {}
    hand.hand = false

    hand.blinds = false
    hand.putScore = false
    hand.thisPutScore = false
    hand.seeCard = false
    hand.thisPutOpt = self.thisPutOpt or false

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
    hand.compareLose = false
    hand.hasCompare = false

    hand.oneScore = false
    hand.isBanker = false
    hand.canPutMoney = false

    hand.maxCardsComb = {}

    self.hand = hand
end

function ZJHAgent:setHand(pack)
    local hand = {}
    hand.hand = false

    if pack.hand then
        hand.hand = pack.hand
    end

    hand.blinds = pack.blinds
    hand.putScore = pack.putScore
    hand.seeCard = pack.seeCard
    hand.thisPutOpt = pack.thisPutOpt

    hand.choosed = pack.choosed
    hand.niuCnt = pack.niuCnt
    hand.specialType = pack.specialType
    hand.summaryHand = pack.summaryHand

    hand.abandons = pack.abandons
    hand.compareLose = pack.compareLose
    hand.hasCompare = pack.hasCompare

    hand.oneScore = pack.oneScore
    hand.isBanker = pack.isBanker
    hand.canPutMoney = false

    self.hand = hand
end

--////////////////////////////////////////////////////////////////////////////////////////////////////////
--!xydesk
function ZJHAgent:setViewInfo(key, pos)
    self.viewKey = key
    self.viewPos = pos
end

function ZJHAgent:getViewInfo()
    return self.viewKey, self.viewPos
end
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--!hand
function ZJHAgent:setFlagBanker(bool)
    if not self.hand then return end
    self.hand.isBanker = bool
end

function ZJHAgent:getFlagBanker()
    if not self.hand then return end
    return self.hand.isBanker
end

function ZJHAgent:setThisPutOpt(tabOpt)
    if not self.hand then return end
    self.hand.thisPutOpt = tabOpt
end

function ZJHAgent:getThisPutOpt()
    if not self.hand then return end
    return self.hand.thisPutOpt
end

function ZJHAgent:setAbandons(bool)
    self.hand.abandons = bool
end

function ZJHAgent:getAbandons()
    if not self.hand then return end
    return self.hand.abandons
end

function ZJHAgent:setCompareLose(bool)
    self.hand.compareLose = bool
end

function ZJHAgent:getCompareLose()
    if not self.hand then return end
    return self.hand.compareLose
end

function ZJHAgent:setHasCompare(bool)
    self.hand.hasCompare = bool
end

function ZJHAgent:getHasCompare()
    if not self.hand then return end
    return self.hand.hasCompare
end

function ZJHAgent:setSeeCard()
    if not self.hand then return end
    self.hand.seeCard = true
end

function ZJHAgent:getSeeCard()
    return self.hand.seeCard
end

function ZJHAgent:setHandCardData(data)
    if not self.hand then return end
    if #data > 0 then
        self.hand.hand = data
        return
    end
    local arr = GameLogic.hashCountsToArray(data)
    self.hand.hand = arr
end

function ZJHAgent:getHandCardData()
    if not self.hand then return end
    return self.hand.hand
end

function ZJHAgent:setChoosed(bool, niuCnt, spcialType, maxCard)
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

function ZJHAgent:getChoosed()
    if not self.hand then return end
    local choose = false
    if self.hand.choosed then
        choose = true
    end
    return choose, self.hand.niuCnt, self.hand.specialType
end

function ZJHAgent:setPutscore(score)
    if not self.hand then return end
    self.hand.putScore = score
end

function ZJHAgent:getPutscore()
    if not self.hand then return end
    return self.hand.putScore
end

function ZJHAgent:setThisPut(score)
    if not self.hand then return end
    self.hand.thisPutScore = score
end

function ZJHAgent:getThisPut()
    if not self.hand then return end
    return self.hand.thisPutScore or 0
end

function ZJHAgent:setSummaryCardData(data)
    if not self.hand then return end
    if #data > 0 then
        self.hand.summaryHand = data
        return
    end
    local arr = GameLogic.hashCountsToArray(data)
    self.hand.summaryHand = arr
end

function ZJHAgent:getSummaryCardData()
    if not self.hand then return end
    return self.hand.summaryHand
end

function ZJHAgent:setScore(score)
    if not self.hand then return end
    self.hand.score = score
end

function ZJHAgent:getScore()
    if not self.hand then return end
    return self.hand.score
end

--////////////////////////////////////////////////////////////////////////////////////////////////////////
--!agent
function ZJHAgent:getActor()
    return self.actor
end

function ZJHAgent:getAvatar()
    return self.actor.avatar
end

function ZJHAgent:getNickname()
    return self.actor.nickName
end

function ZJHAgent:getUID()
    return self.actor.uid
end

function ZJHAgent:getChairID()
    return self.chairIdx
end

function ZJHAgent:setPrepare(bool)
    self.isPrepare = bool
end

function ZJHAgent:isReady()
    return self.isPrepare
end

function ZJHAgent:setDropLine(bool)
    self.isLeaved = bool
end

function ZJHAgent:isDropLine()
    return self.isLeaved
end

function ZJHAgent:setEnterBackground(bool)
    self.isAway = bool
end

function ZJHAgent:isEnterBackground()
    return self.isAway
end

function ZJHAgent:setTrusteeship(bool)
    self.isTrusteeship = bool
end

function ZJHAgent:getTrusteeship(bool)
    return self.isTrusteeship
end

function ZJHAgent:setAutoOperation(bool)
    self.autoOperation = bool
end

function ZJHAgent:getAutoOperation()
    return self.autoOperation
end

function ZJHAgent:setMoney(money)
    self.money = money
end

function ZJHAgent:getMoney()
    return self.money
end

function ZJHAgent:setGroupScore(groupScore)
    self.groupScore = groupScore
end

function ZJHAgent:getGroupScore()
    return self.groupScore
end

function ZJHAgent:getSmartTrusteeship()
    return self.isSmartTrusteeship
end

function ZJHAgent:getSex()
    return self.actor.sex
end

function ZJHAgent:setInMatch(bool)
    self.isInMatch = bool
end

function ZJHAgent:getInMatch()
    return self.isInMatch
end

function ZJHAgent:getLocationInfo()
    return self.location
end

return ZJHAgent