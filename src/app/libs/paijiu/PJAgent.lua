local class = require('middleclass')
local PJAgent = class("PJAgent")
local GameLogic = require('app.libs.paijiu.PJGameLogic')

function PJAgent:initialize(pack)
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

    -- hand
    self:initHandWithPack(pack.hand)
end

function PJAgent:initHandWithPack(pack)
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

function PJAgent:initHand()
    local hand = {}
    hand.hand = false 
  
    hand.qiangCnt = false
    hand.putScore = false
    hand.putFlag = false
    hand.thisPutOpt = self.thisPutOpt or false
    

    hand.choosed = false
    hand.niuCnt = false
    hand.specialType = false
    hand.maxCard = false
    hand.summaryHand = false

    hand.oneScore = false
    hand.isBanker = false
    hand.canPutMoney = false

    hand.niuCnt_4 = {}
    hand.specialType_4 = {}
    hand.maxCard_4 = {}

    hand.cardComb = {}

    self.hand = hand
end

function PJAgent:setHand(pack)
    local hand = {}
    hand.hand = false 
    
    if pack.hand then
      hand.hand = pack.hand
    end
  
    hand.qiangCnt = pack.qiangCnt
    hand.putScore = pack.putScore
    hand.putFlag = pack.putFlag
    hand.thisPutOpt = pack.thisPutOpt

    hand.choosed = pack.choosed
    hand.niuCnt = pack.niuCnt
    hand.specialType = pack.specialType
    hand.maxCard = pack.maxCard
    hand.summaryHand = pack.summaryHand

    hand.niuCnt_4 = pack.niuCnt_4
    hand.specialType_4 = pack.specialType_4
    hand.maxCard_4 = pack.maxCard_4

    hand.cardComb = pack.cardComb
    
    hand.oneScore = pack.oneScore
    hand.isBanker = pack.isBanker
    hand.canPutMoney = false

    self.hand = hand
end

--////////////////////////////////////////////////////////////////////////////////////////////////////////
--!xydesk
function PJAgent:setViewInfo(key, pos)
    self.viewKey = key
    self.viewPos = pos
end

function PJAgent:getViewInfo()
    return self.viewKey, self.viewPos
end
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--!hand

function PJAgent:setCanPutMoney(bool)
    if not self.hand then return end
    self.hand.canPutMoney = bool or false
end

function PJAgent:getCanPutMoney()
    if not self.hand then return end
    return self.hand.canPutMoney
end


function PJAgent:setFlagBanker(bool)
    if not self.hand then return end
    self.hand.isBanker = bool
end

function PJAgent:getFlagBanker()
    if not self.hand then return end
    return self.hand.isBanker
end

function PJAgent:setQiang(qiangNum)
    if not self.hand then return end
    self.hand.qiangCnt = qiangNum or 0
end

function PJAgent:setThisPutOpt(tabOpt)
    if not self.hand then return end
    self.hand.thisPutOpt = tabOpt
end

function PJAgent:getThisPutOpt()
    if not self.hand then return end
    return self.hand.thisPutOpt
end

function PJAgent:setHandCardData(data)
    if not self.hand then return end
    if #data > 0 then
        self.hand.hand = data
        return
    end
    local arr = GameLogic.hashCountsToArray(data)
    self.hand.hand = arr
end

function PJAgent:getHandCardData()
    if not self.hand then return end
    return self.hand.hand
end

function PJAgent:setChoosed(bool, niuCnt, spcialType, maxCard)
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

function PJAgent:getChoosed()
    if not self.hand then return end
    local choose = false
    if self.hand.choosed then
        choose = true
    end
    return choose, self.hand.niuCnt, self.hand.specialType, self.hand.maxCard
end

function PJAgent:setChoosed_4(bool, niuCnt, spcialType, maxCard)
    if not self.hand then return end
    self.hand.choosed = bool
    if niuCnt then
        self.hand.niuCnt_4 = niuCnt
    end
    if spcialType then
        self.hand.specialType_4 = spcialType
    end
    if maxCard then
        self.hand.maxCard_4 = maxCard
    end
end

function PJAgent:getChoosed_4()
    if not self.hand then return end
    local choose = false
    if self.hand.choosed then
        choose = true
    end
    return choose, self.hand.niuCnt_4, self.hand.specialType_4, self.hand.maxCard_4
end

function PJAgent:setCardComb(cardComb)
    if not self.hand then return end
    if next(cardComb) ~= nil then
        self.hand.cardComb = cardComb
    end
end

function PJAgent:getCardComb()
    if not self.hand then return end
    return self.hand.cardComb or false
end

function PJAgent:getQiang()
    if not self.hand then return end
    return self.hand.qiangCnt 
end

function PJAgent:setPutscore(score)
    if not self.hand then return end
    self.hand.putScore = score
end

function PJAgent:getPutscore()
    if not self.hand then return end
    return self.hand.putScore
end

function PJAgent:setPutFlag(bool)
    if not self.hand then return end
    self.hand.putFlag = bool
end

function PJAgent:setSummaryCardData(data)
    if not self.hand then return end
    if #data > 0 then
        self.hand.summaryHand = data
        return
    end
    local arr = GameLogic.hashCountsToArray(data)
    self.hand.summaryHand = arr
end

function PJAgent:getSummaryCardData()
    if not self.hand then return end
    return self.hand.summaryHand
end

function PJAgent:setScore(score)
    if not self.hand then return end
    self.hand.score = score
end

function PJAgent:getScore()
    if not self.hand then return end
    return self.hand.score
end

--////////////////////////////////////////////////////////////////////////////////////////////////////////
--!agent

function PJAgent:getActor()
    return self.actor
end

function PJAgent:getAvatar()
    return self.actor.avatar
end

function PJAgent:getNickname()
    return self.actor.nickName
end

function PJAgent:getUID()
    return self.actor.uid
end

function PJAgent:getChairID()
    return self.chairIdx
end

function PJAgent:setPrepare(bool)
    self.isPrepare = bool
end

function PJAgent:isReady()
    return self.isPrepare
end

function PJAgent:setDropLine(bool)
    self.isLeaved = bool
end

function PJAgent:isDropLine()
    return self.isLeaved
end

function PJAgent:setEnterBackground(bool)
    self.isAway = bool
end

function PJAgent:isEnterBackground()
    return self.isAway
end

function PJAgent:setTrusteeship(bool)
    self.isTrusteeship = bool
end

function PJAgent:getTrusteeship(bool)
    return self.isTrusteeship
end

function PJAgent:setMoney(money)
    self.money = money
end

function PJAgent:getMoney()
    return self.money
end

function PJAgent:setGroupScore(groupScore)
    self.groupScore = groupScore
end

function PJAgent:getGroupScore()
    return self.groupScore
end

function PJAgent:getSmartTrusteeship()
    return self.isSmartTrusteeship
end

function PJAgent:getSex()
    return self.actor.sex
end

function PJAgent:setInMatch(bool)
    self.isInMatch = bool
end

function PJAgent:getInMatch()
    return self.isInMatch
end

return PJAgent