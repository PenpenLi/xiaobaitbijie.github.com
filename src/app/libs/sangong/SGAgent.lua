local class = require('middleclass')
local SGAgent = class("SGAgent")
local GameLogic = require('app.libs.sangong.SGGameLogic')

function SGAgent:initialize(pack)
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
    self.actor.shopRight = pack.actor.shopRight

    -- SGAgent data
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

function SGAgent:initHandWithPack(pack)
    if not pack then
        self.hand = false
        return
    end
    self.hand = pack        
    
    if pack.dealList and next(pack.dealList) ~= nil then
        self:setHandCardData(pack.dealList)
    elseif pack.hand and next(pack.hand) ~= nil then
        local hand = pack.hand
        self:setHandCardData(hand)
    end

    if pack.summaryHand then
        local hand = pack.summaryHand
        self:setSummaryCardData(hand)
    end
end

function SGAgent:initHand()
    local hand = {}
    hand.hand = false
    hand.dealList = false 
  
    hand.qiangCnt = false
    hand.putScore = false
    hand.putFlag = false
    hand.thisPutOpt = self.thisPutOpt or false
    

    hand.choosed = false
    hand.niuCnt = false
    hand.specialType = false
    hand.summaryHand = false

    hand.oneScore = false
    hand.isBanker = false
    hand.canPutMoney = false

    hand.lastcard = false

    self.hand = hand
end

function SGAgent:setHand(pack)
    local hand = {}
    hand.hand = false 
    
    if pack.hand then
      hand.hand = pack.hand
    end

    hand.dealList = false
    if pack.dealList then
        hand.dealList = pack.dealList
    end
  
    hand.qiangCnt = pack.qiangCnt
    hand.putScore = pack.putScore
    hand.putFlag = pack.putFlag
    hand.thisPutOpt = pack.thisPutOpt

    hand.choosed = pack.choosed
    hand.niuCnt = pack.niuCnt
    hand.specialType = pack.specialType
    hand.summaryHand = pack.summaryHand
    
    hand.oneScore = pack.oneScore
    hand.isBanker = pack.isBanker
    hand.canPutMoney = false

    self.hand = hand
end

--////////////////////////////////////////////////////////////////////////////////////////////////////////
--!xydesk
function SGAgent:setViewInfo(key, pos)
    self.viewKey = key
    self.viewPos = pos
end

function SGAgent:getViewInfo()
    return self.viewKey, self.viewPos
end
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--!hand

function SGAgent:setCanPutMoney(bool)
    if not self.hand then return end
    self.hand.canPutMoney = bool or false
end

function SGAgent:getCanPutMoney()
    if not self.hand then return end
    return self.hand.canPutMoney
end


function SGAgent:setFlagBanker(bool)
    if not self.hand then return end
    self.hand.isBanker = bool
end

function SGAgent:getFlagBanker()
    if not self.hand then return end
    return self.hand.isBanker
end

function SGAgent:setQiang(qiangNum)
    if not self.hand then return end
    self.hand.qiangCnt = qiangNum or 0
end

function SGAgent:setThisPutOpt(tabOpt)
    if not self.hand then return end
    self.hand.thisPutOpt = tabOpt
end

function SGAgent:getThisPutOpt()
    if not self.hand then return end
    return self.hand.thisPutOpt
end

function SGAgent:setHandCardData(data)
    if not self.hand then return end
    if #data > 0 then
        self.hand.dealList = data
        self:setLastCard(data[3])
        return
    end
    local arr = GameLogic.hashCountsToArray(data)
    self.hand.dealList = arr
    self:setLastCard(arr[3])
end

function SGAgent:getHandCardData()
    if not self.hand then return end
    return self.hand.dealList
end

function SGAgent:setChoosed(bool, niuCnt, spcialType)
    if not self.hand then return end
    self.hand.choosed = bool
    if niuCnt then
        self.hand.niuCnt = niuCnt
    end
    if spcialType then
        self.hand.specialType = spcialType
    end
end

function SGAgent:getChoosed()
    if not self.hand then return end
    local choose = false
    if self.hand.choosed then
        choose = true
    end
    return choose, self.hand.niuCnt, self.hand.specialType
end

function SGAgent:getQiang()
    if not self.hand then return end
    return self.hand.qiangCnt 
end

function SGAgent:setPutscore(score)
    if not self.hand then return end
    self.hand.putScore = score
end

function SGAgent:getPutscore()
    if not self.hand then return end
    return self.hand.putScore
end

function SGAgent:setPutFlag(bool)
    if not self.hand then return end
    self.hand.putFlag = bool
end

function SGAgent:setSummaryCardData(data)
    if not self.hand then return end
    if #data > 0 then
        self.hand.summaryHand = data
        return
    end
    local arr = GameLogic.hashCountsToArray(data)
    self.hand.summaryHand = arr
end

function SGAgent:getSummaryCardData()
    if not self.hand then return end
    return self.hand.summaryHand
end

function SGAgent:setLastCard(data)
    if not self.hand then return end
    self.hand.lastcard = GameLogic.transformCards(data)
end

function SGAgent:getLastCard()
    if not self.hand then return end
    return self.hand.lastcard
end

function SGAgent:setScore(score)
    if not self.hand then return end
    self.hand.score = score
end

function SGAgent:getScore()
    if not self.hand then return end
    return self.hand.score
end

--////////////////////////////////////////////////////////////////////////////////////////////////////////
--!SGAgent

function SGAgent:getActor()
    return self.actor
end

function SGAgent:getAvatar()
    return self.actor.avatar
end

function SGAgent:getNickname()
    return self.actor.nickName
end

function SGAgent:getUID()
    return self.actor.uid
end

function SGAgent:getChairID()
    return self.chairIdx
end

function SGAgent:setPrepare(bool)
    self.isPrepare = bool
end

function SGAgent:isReady()
    return self.isPrepare
end

function SGAgent:setDropLine(bool)
    self.isLeaved = bool
end

function SGAgent:isDropLine()
    return self.isLeaved
end

function SGAgent:setEnterBackground(bool)
    self.isAway = bool
end

function SGAgent:isEnterBackground()
    return self.isAway
end

function SGAgent:setTrusteeship(bool)
    self.isTrusteeship = bool
end

function SGAgent:getTrusteeship()
    return self.isTrusteeship
end

function SGAgent:setautoOperation(bool)
    self.autoOperation = bool
end

function SGAgent:getautoOperation()
    return self.autoOperation
end

function SGAgent:setMoney(money)
    self.money = money
end

function SGAgent:getMoney()
    return self.money
end

function SGAgent:setGroupScore(groupScore)
    self.groupScore = groupScore
end

function SGAgent:getGroupScore()
    return self.groupScore
end

function SGAgent:getSmartTrusteeship()
    return self.isSmartTrusteeship
end

function SGAgent:getSex()
    return self.actor.sex
end

function SGAgent:setInMatch(bool)
    self.isInMatch = bool
end

function SGAgent:getInMatch()
    return self.isInMatch
end

function SGAgent:getLocationInfo()
    return self.location
end

return SGAgent