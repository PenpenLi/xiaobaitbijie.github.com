local class = require('middleclass')
local HasSignals = require('HasSignals')
local ZJHDesk = class("Desk"):include(HasSignals)
local ShowWaiting = require('app.helpers.ShowWaiting')
local cardHelper = require('app.helpers.card')
local tools = require('app.helpers.tools')
local EventCenter = require("EventCenter")
local Agent = require('app.libs.zhajinhua.ZJHAgent')
local Gameplay = require('app.libs.zhajinhua.ZJHGameplay')
local app = require("app.App"):instance()


function ZJHDesk:initialize()
    HasSignals.initialize(self)

    -- 桌子
    self.gameIdx = 35
    self.DeskName = 'zhajinhua'


    -- 服务器数据
    self.tabBaseInfo = false        --pdesk:packbaseinfo()
    self.tabPlayer = false          --agent instance
    self.gameplay = false           --gameplay instance
    self.maxPut = 0 

    -- playback 
    self.tabDeskRecord = {}      --pdesk:packageDeskRecord()
    self.tabDeskTempRecord = {}
    -- watcherlist
    self.tabWatcher = {}
    -- xychat
    self.tabChatList = {} 

    -- viewInfo
    self.tabViewKey = {}
    
    -- overgame
    self.overSuggest = false
    self.overTickInfo = false

    -- is desk summary
    self.isdeskSummary = false

    -- 消息
    self:listen()
end

function ZJHDesk:resetDesk()
    -- 服务器数据
    self.tabBaseInfo = false        --pdesk:packbaseinfo()
    self.tabPlayer = false          --agent instance
    self.gameplay = false           --gameplay instance
    self.maxPut = 0

    -- playback 
    self.tabDeskRecord = {}      --pdesk:packageDeskRecord()
    self.tabDeskTempRecord = {}
    -- watcherlist
    self.tabWatcher = {}
    -- xychat
    self.tabChatList = {} 

    -- viewInfo
    self.tabViewKey = {}

    -- overgame
    self.overSuggest = false
    self.overTickInfo = false

    -- is desk summary
    self.isdeskSummary = false
end

-- ///////////////////////////////////////////////////////////////////////////////////////////////////
-- 


function ZJHDesk:listen()
    local app = require("app.App"):instance()

    if self.onSynDeskHandle then
        self.onSynDeskHandle:dispose()
        self.onSynDeskHandle = nil
    end

    self.onSynDeskHandle = app.conn:on(self.DeskName .. ".synDeskData", function(msg)
        -- 服务端发送消息情景:
        -- 1.进入桌子
        -- 2.请求坐下成功
        -- 3.重连请求成功
        self:onSynDeskData(msg)
    end)
end


function ZJHDesk:disposeListens()
    if self.listens then
        for i = 1, #self.listens do
            self.listens[i]:dispose()
        end

        self.listens = nil
    end

    -- 注销 切换事件监听
    -- EventCenter.clear("app")
end

function ZJHDesk:bindMsgHandles()
    local app = require("app.App"):instance()
    self:disposeListens()

    -- 注册 切换事件监听
    -- EventCenter.register("app", function(event)
    --     if event then 
    --         self.emitter:emit(event)
    --     end
    -- end)

    self.listens = {
        -- ============================ state ============================
        --Ready
        app.conn:on(self.DeskName .. '.StateReady', function(msg)
            self.tabBaseInfo.isPlaying = false
            local played = self:isGamePlayed()
            if played then
                for k,v in pairs(self.tabPlayer) do
                    v:setPrepare(false)
                end
            end

            self.tabBaseInfo.number = msg.round

            self.gameplay:setState('Ready', msg.tick)
            self.emitter:emit('StateReady', msg)
        end),

        app.conn:on(self.DeskName .. '.StateStarting', function(msg)
            self.gameplay:initGamePack(msg.data)
            -- 设置玩家比赛状态
            
            local gameplay = self:getGameplayIdx()

            local info = self:getBankerInfo()
            if info then
                info.player:setFlagBanker(true)
            end

            for k,v in pairs(self.tabPlayer) do
                v:setInMatch(true)
                v:initHand()
                v:setPrepare(not played)
            end 

            self.tabBaseInfo.isPlaying = true
            self.tabBaseInfo.played = true

            self.gameplay:setState('Starting', 0)
            self.emitter:emit('StateStarting', msg)
        end),

        --Compare
        app.conn:on(self.DeskName .. '.StateCompare', function(msg)
            self.gameplay:setState('Compare', msg.tick)
            self.emitter:emit('StateCompare', msg)
        end),

        app.conn:on(self.DeskName .. '.compareResult', function(msg)
            --msg.putInfo
            local leftInfo = self:getPlayerInfo(msg.left)
            local rightInfo = self:getPlayerInfo(msg.right)
            if not leftInfo or not rightInfo then return end

            leftInfo.player:setHasCompare()
            rightInfo.player:setHasCompare()

            if msg.left == msg.winner then
                rightInfo.player:setCompareLose(true)
            else
                leftInfo.player:setCompareLose(true)
            end
            local cMsg = {
                msgID = 'compareResult',
                leftInfo = leftInfo.player,
                rightInfo = rightInfo.player,
                isLeftWin = msg.left == msg.winner
            }
            self.emitter:emit('compareResult', cMsg)
        end),

        --PutMoney
        app.conn:on(self.DeskName .. '.StatePutMoney', function(msg)
            self.gameplay:setState('PutMoney', msg.tick)
            self.emitter:emit('StatePutMoney', msg)
        end),

        app.conn:on(self.DeskName .. '.putMoney', function(msg)
            --msg.putInfo
            local info = self:getPlayerInfo(msg.uid)
            if not info then return end
            info.player:setThisPutOpt(msg.putInfo)
            local cMsg = {
                msgID = 'putMoney',
                info = info,
            }
            self.gameplay:setMaxPut(msg.maxPut)
            self.gameplay:setTick(msg.tick)
            self.emitter:emit('putMoney', cMsg)
        end),

        app.conn:on(self.DeskName .. '.somebodySeeCard', function(msg)
            -- 有人看牌
            local info = self:getPlayerInfo(msg.uid)
            if not info then return end
            info.player:setSeeCard(true)
            local cMsg = {
                msgID = 'somebodySeeCard',
                info = info,
            }
            self.emitter:emit('somebodySeeCard', cMsg)
        end),

        app.conn:on(self.DeskName .. '.somebodyPutMoney', function(msg)
            -- 押注
            local info = self:getPlayerInfo(msg.uid)
            if not info then return end
            local comparePlayer = nil
            self.gameplay:setTick(msg.tick)
            self.gameplay:setJackpot(msg.jackpot)
            if msg.mode == 1 or msg.mode == 2 then
                info.player:setPutscore(msg.putScore)
                info.player:setThisPut(msg.number)
            elseif msg.mode == 4 then
                info.player:setAbandons(true)
            elseif msg.mode == 5 then
                info.player:setPutscore(msg.putScore)
                info.player:setThisPut(msg.number)
                comparePlayer = self:getPlayerInfo(msg.compareUid)

                info.player:setHasCompare()
                comparePlayer.player:setHasCompare()

                if msg.compareResult then
                    if comparePlayer then 
                        comparePlayer.player:setCompareLose(true)
                    end
                else
                    info.player:setCompareLose(true)
                end
            end
            local cMsg = {
                msgID = 'somebodyPutMoney',
                info = info,
                score = msg.putScore,
                mode = msg.mode,
                compareInfo = comparePlayer,
                compareResult = msg.compareResult,
            }
            self.emitter:emit('somebodyPutMoney', cMsg)
        end),

        app.conn:on(self.DeskName .. '.nextPlayer', function(msg)
            --msg.putInfo
            if self.gameplay then
                self.gameplay:setCurrentPlayer(msg.uid)
                self.gameplay:setCompareRound(msg.currentPutScoreRound)
            end
            local cMsg = {
                msgID = 'nextPlayer',
            }
            self.emitter:emit('nextPlayer', cMsg)
        end),

        --Dealing
        app.conn:on(self.DeskName .. '.StateDealing', function(msg)
            self.gameplay:setState('Dealing', msg.tick)
            self.emitter:emit('StateDealing', msg)
        end),

        app.conn:on(self.DeskName .. '.dealt', function(msg)
            local cMsg = {
                msgID = 'dealt',
            }
            self.gameplay:setFlagDealAllPlayer(true)
            if msg.uid and msg.handData and msg.dealList then
                -- 有扑克数据
                local info = self:getPlayerInfo(msg.uid)
                if info then
                    -- info.player:setHandCardData(msg.handData)
                    info.player:setHandCardData(msg.dealList)
                end
            end

            self.emitter:emit('dealt', cMsg)
        end),

        --End
        app.conn:on(self.DeskName .. '.Ending', function(msg)
            self.gameplay:setState('Ending')
            self.emitter:emit('Ending', msg)
        end),

        -- ============================ agent ============================



        app.conn:on(self.DeskName .. ".somebodySitdown", function(msg)
            -- 初始化玩家
            self:initPlayer(msg.uid, msg.userData, not self:isMePlayer())
            local info = self:getPlayerInfo(msg.uid)
            if not info then return end
            local sitCID = info.player:getChairID()
            self.emitter:emit('somebodySitdown', info)
            if not self:isMePlayer() then
                local playerCnt = self:getPlayerCnt()
                if playerCnt == self:getMaxPlayerCnt() then
                    self:reloadData()
                end
            end
        end),

        app.conn:on(self.DeskName .. ".somebodyLeave", function(msg)
            -- 玩家离开
            if self.isdeskSummary then return end
            local info = self:getPlayerInfo(msg.uid)
            if not info then return end

            -- local leaveFreeCID = self:getLastFreeChairID()

            -- 清除玩家数据
            self.tabPlayer[msg.uid] = nil
            self.emitter:emit('somebodyLeave', info)

            --刷新视角
            -- if not self:isMePlayer() then
            --     if leaveFreeCID ~= self:getLastFreeChairID() then
            --         self:reloadData()
            --     end
            -- end
        end),

        app.conn:on(self.DeskName .. ".leaveResult", function(msg)
            -- 初始化玩家
            self.emitter:emit('leaveResult', {})
        end),


        app.conn:on(self.DeskName .. ".somebodyPrepare", function(msg)
            -- 玩家准备
            local info = self:getPlayerInfo(msg.uid)
            if not info then return end
            info.player:setPrepare(true)

            local cMsg = {
                msgID = 'somebodyPrepare',
                info = info,
            }
            self.emitter:emit('somebodyPrepare', cMsg)
        end),

        app.conn:on(self.DeskName .. '.dropLine', function(msg)
            -- 玩家掉线
            local info = self:getPlayerInfo(msg.uid)
            if not info then return end
            info.player:setDropLine(true)
            self.emitter:emit('dropLine', info)
        end),

        app.conn:on(self.DeskName .. ".somebodyCancelTrusteeship", function(msg)
           -- 取消托管
           local info = self:getPlayerInfo(msg.uid)
           if not info then return end
           info.player:setTrusteeship(false)
           self.emitter:emit('somebodyCancelTrusteeship', info)
        end),

        app.conn:on(self.DeskName .. ".somebodyTrusteeship", function(msg)
            -- 托管
            local info = self:getPlayerInfo(msg.uid)
            if not info then return end
            info.player:setTrusteeship(true)
            self.emitter:emit('somebodyTrusteeship', info)
        end),

        app.conn:on(self.DeskName .. ".somebodyEnterBackground", function(msg)
            -- 离开
            local info = self:getPlayerInfo(msg.uid)
            if not info then return end
            info.player:setEnterBackground(msg.flag)
            self.emitter:emit('somebodyEnterBackground', info, msg)
        end),

        -- ============================ cheat ============================
        -- 作弊信息
        app.conn:on(self.DeskName .. '.cheat', function(msg)
            self.emitter:emit('cheatInfo', msg.cheatInfo)
        end),

        -- 作弊信息1
        app.conn:on(self.DeskName .. '.cheat1', function(msg)
            self.emitter:emit('cheat1', msg.flag)
        end),

        app.conn:on(self.DeskName .. '.setCheatDataResult', function(msg)
            self.emitter:emit('cheat1Result', msg.mode)
        end),



        -- ============================ desk ============================
        
        app.conn:on(self.DeskName .. '.summary', function(msg)
            -- 单局结算 | 总结算
            self:onSummary(msg)
            local cMsg = {
                msgID = 'summary',
            }
            self.emitter:emit('summary', cMsg)
        end),

        app.conn:on(self.DeskName .. '.freshGroupScore', function(msg)
            -- 抽水后刷新分数
            self:freshGroupScore(msg.msg)
            local cMsg = {
                msgID = 'freshGroupScore',
            }
            self.emitter:emit('freshGroupScore', cMsg)
        end),

        app.conn:on(self.DeskName .. ".deskSummary", function(msg)
            -- 总结算
            self.isdeskSummary = true
            local owner = self:getOwnerInfo()
            local cMsg = {
                deskInfo = self:getDeskInfo(),
                ownerName = owner.name,
                fsummay = msg.fsummay,
                records = msg.record,
                deskId = self:getDeskId(),
            }
            self.emitter:emit('deskSummary', cMsg)
        end),

        app.conn:on(self.DeskName .. ".payNextFail", function(msg)
            -- 扣除每局房卡结果
            self.emitter:emit('payNextFail', msg)
        end),
        
        app.conn:on(self.DeskName .. ".canStart", function(msg)
            -- 客户端可以开始游戏了
            local cMsg = {
                msgID = 'canStart',
                canStart = msg.canStart,
            }
            self.emitter:emit('canStart', cMsg)
        end),

        app.conn:on(self.DeskName .. ".waitStart", function(msg)
            -- 等待 xx 开始游戏
            self.emitter:emit('waitStart', msg)
        end),

        app.conn:on(self.DeskName .. ".autoLeave", function(msg)
            -- 要被离开的玩家
            self.emitter:emit('autoLeave', msg)
        end),

        app.conn:on(self.DeskName .. ".responseSitdown", function(msg)
            -- 请求坐下结果
            local cMsg = {
                msgID = 'responseSitdown',
                errCode = msg.errCode,
            }
            self.emitter:emit('responseSitdown', cMsg)
        end),

        app.conn:on(self.DeskName .. '.overgame', function(msg)
            -- 解散房间信息
            if msg.code and msg.code == -1 then
                self.emitter:emit('overgame', msg)
                return 
            end
            self:onOvergame(msg) -- 设置解散数据
            self.emitter:emit('overgame', msg)
        end),

        app.conn:on(self.DeskName .. '.overgameResult', function(msg)
            -- 解散房间结果
            self.emitter:emit('overgameResult', msg)
        end),

        
        app.conn:on(self.DeskName .. ".deskRecord", function(msg)
            -- 上局回顾战绩
            self:onDeskRecord(msg)
            self.emitter:emit('deskRecord', msg)
        end),

        app.conn:on(self.DeskName .. ".watcherList", function(msg)
            -- 旁观者列表
            self:onWatcherList(msg)
            self.emitter:emit('watcherList', msg)
        end),

        app.conn:on('chatInGame', function(msg)
            -- 游戏中聊天
            self:onChatInGame(msg)
            self.emitter:emit('chatInGame', msg)
        end),

        app.conn:on(self.DeskName .. '.getLastVoiceResult', function(msg)
            -- 获取玩家上一条语音
            self.emitter:emit('getLastVoiceResult', msg)
        end),

        app.conn:on(self.DeskName .. '.chatList', function(msg)
            -- 聊天列表(不包含语音)
            self:onChatList(msg.data)        
            self.emitter:emit('chatList', msg)
        end),

        --[[
        app.conn:on(self.DeskName .. '.playVoice', function(msg)
            -- 语音消息, 放入controller处理
        end),
        ]]

        app.conn:on(self.DeskName .. '.smartTrusteeshipResult', function (msg)
            --智能托管返回结果
            self.emitter:emit('smartTrusteeshipResult', msg)
        end),

        app.conn:on(self.DeskName .. '.smartOpt', function (msg)
            --托管状态返回结果
            self.emitter:emit('smartOpt', msg)
        end),

        app.conn:on(self.DeskName .. '.autoOperationrResult', function (msg)
            --自动操作返回结果
            self:onAutoOperation(msg)
        end),

        app.conn:on(self.DeskName .. '.SomebodyShowCards', function (msg)
            --有人亮牌
            self.emitter:emit('SomebodyShowCards', msg)
        end),
    }
end

function ZJHDesk:onCustomSwitch() 
    app:switch('ZJHDeskController', self.DeskName)
end

function ZJHDesk:onPutMoney(msg)
    self.emitter:emit('freshBettingBar', msg)
    self.emitter:emit('bettingTimerStart')
end

-- ============ view key ============

function ZJHDesk:initViewKey() -- virtual 
    
    local maxCnt = self:getMaxPlayerCnt()

    if maxCnt == 8 then
        self.tabViewKey = {
            'bottom',
            'left',
            'leftmid',
            'lefttop',
            'top',
            'righttop',
            'rightmid',
            'right',
        }
    elseif maxCnt == 10 then
        self.tabViewKey = {
            'bottom',
            'left',
            'leftmid',
            'lefttop',
            'topleft',
            'top',
            'topright',
            'righttop',
            'rightmid',
            'right',
        }
    else
        self.tabViewKey = {
            'bottom',
            'left',
            'lefttop',
            'top',
            'righttop',
            'right',
        }
    end
end


function ZJHDesk:getViewKey(pos) -- virtual 
    return self.tabViewKey[pos]
end

function ZJHDesk:getViewKeyData() 
    return self.tabViewKey
end

-- ============ onnetmsg ============

function ZJHDesk:onSynDeskData(msg)
    self:resetDesk()

    -- 同步数据
    self.tabBaseInfo = msg.base

    self:initViewKey()

    -- gameplay
    self.gameplay = Gameplay(msg.state) 

    -- 解散信息
    if msg.dismissInfo and msg.dismissInfo.hasOverSuggest then
        self:setDismissInfo(
        msg.dismissInfo.data,
        msg.dismissInfo.dataEx
        )
    end
    

    -- bottom 座位
    local app = require("app.App"):instance()
    local meUid = app.session.user.uid
    local isPlayer = false
    local fPlayer = nil
    local mPlayer = nil
    local bottomPlayer = nil

    local tabValid = {}
    local validCnt = 0
    for i = 1, self:getMaxPlayerCnt() do
        table.insert(tabValid, false)
    end

    for k,v in pairs(msg.agent) do
        tabValid[v.chairIdx] = true
        validCnt = validCnt + 1
        if k == meUid then
            -- 自己
            mPlayer = {k, v} 
            isPlayer = true 
            break 
        end
    end

    local lastFreeCID = 0
    for k,v in pairs(tabValid) do
        if v == false and k > lastFreeCID then
            lastFreeCID = k
        end
    end

    if validCnt == self:getMaxPlayerCnt() then
        lastFreeCID = self:getMaxPlayerCnt()
    end

    if isPlayer then
        -- 自己是玩家
        self:initPlayer(mPlayer[1], mPlayer[2], nil, nil, true)
    end

    -- 初始化玩家
    for k,v in pairs(msg.agent) do
        if (mPlayer and k == mPlayer[1]) then
            --跳过自己
        else
            self:initPlayer(k, v, (not isPlayer), lastFreeCID)  
        end
    end


    if msg.reload then
        self.emitter:emit('reloadData')
    else
		self:onCustomSwitch()
        self:bindMsgHandles()
    end
end


function ZJHDesk:onSomebodyTrusteeship(msg)
    if self:isMe(msg.uid) then
        local me = self:getMe()
        me.hand.trusteeship = true

        self.emitter:emit('trusteeship')
    end
end

function ZJHDesk:onDeskRecord(msg)
    self.tabDeskRecord = msg.data or {}
end

function ZJHDesk:onWatcherList(msg)
    self.tabWatcher = msg.data or {}
end

function ZJHDesk:onChatInGame(msg)  
    if msg and (msg.type == 0 or msg.type == 1 or msg.type == 2) then
        local newChat = {type = msg.type, 
            uid = msg.uid,
            msg = msg.msg
        }
        table.insert(self.tabChatList, newChat)
    end
end

function ZJHDesk:onChatList(msg)
    self.tabChatList = msg or {}
end

function ZJHDesk:onSummary(msg)
    -- 单局结算
    for k,v in pairs(msg.data) do
        local info = self:getPlayerInfo(k)
        if info then
            info.player:setSummaryCardData(v.hand)
            info.player:setChoosed(true, v.niuCnt, v.specialType, v.maxCard)
            info.player:setScore(v.score)
            info.player:setMoney(v.money)
            info.player:setGroupScore(v.groupScore)
        end
    end
end

function ZJHDesk:freshGroupScore(msg)
    local info = self:getPlayerInfo(msg.uid)
    if info then
        local groupScore = info.player:getGroupScore()
        info.player:setGroupScore(groupScore - msg.score)
    end
end

function ZJHDesk:onAutoOperation(msg)
    local info = self:getPlayerInfo(msg.uid)
    if info then
        info.player:setAutoOperation(msg.flag)
    end
end

function ZJHDesk:onOvergame(msg)
    self.overSuggest = msg.data
    self.overTickInfo = msg.dataEx
end

-- ============ sendnetmassage ============
function ZJHDesk:setPutData(putData)
    local app = require("app.App"):instance()
    local conn = app.conn
	local msg = {
		msgID = self.DeskName .. '.puts_new',
		putData = putData
	}
	app.conn:send(msg)
end

function ZJHDesk:watcherList()
    local app = require("app.App"):instance()
    local conn = app.conn
    local msg = {
      msgID = 'watcherList',
    }
    conn:send(msg)
end


function ZJHDesk:sitDown(deskId, buyHorse) -- luacheck:ignore
    local app = require("app.App"):instance()
    local conn = app.conn
    local msg = {
        msgID = self.DeskName .. '.sitdown',
        gameIdx = self.gameIdx,
        deskId = deskId,
        buyHorse = buyHorse,
    }
    conn:send(msg)
end

function ZJHDesk:getLastVoice(msg) -- luacheck:ignore
    local app = require("app.App"):instance()
    local conn = app.conn
    local tmsg = {
        msgID = self.DeskName .. '.getLastVoice',
        uid = msg.uid
    }
    conn:send(tmsg)
end


function ZJHDesk:quit() -- luacheck:ignore
    local app = require("app.App"):instance()
    local conn = app.conn
    local msg = {
        msgID = self.DeskName .. '.leaveRoom'
    }
    conn:send(msg)
end

function ZJHDesk:answer(answer)--luacheck:ignore
    local app = require("app.App"):instance()
    local conn = app.conn
    local msg = {
      msgID = self.DeskName..'.overAction',
      result = answer
    }
    conn:send(msg)
end

function ZJHDesk:cancelTrusteeship()
    local app = require("app.App"):instance()
    local conn = app.conn
    local msg = {
        msgID = self.DeskName..'.cancelTrusteeship',
    }
    conn:send(msg)
end

function ZJHDesk:requestTrusteeship()
    local app = require("app.App"):instance()
    local conn = app.conn
    local msg = {
        msgID = self.DeskName..'.requestTrusteeship',
    }
    conn:send(msg)
end

--智能托管
function ZJHDesk:sendTrusteeshipMsg(bool, msg)
    local app = require("app.App"):instance()
    local conn = app.conn
    local rmsg = {
        msgID = self.DeskName..'.smartTrusteeship',
        flag = bool
    }
    if bool then
        rmsg.data = msg
    end
    conn:send(rmsg)
end

--请求获取托管状态
function ZJHDesk:requestTrusteeshipMsg()
    local app = require("app.App"):instance()
    local conn = app.conn
    local msg = {
        msgID = self.DeskName..'.getSmartOpt',
    }
    conn:send(msg)
end


function ZJHDesk:deskRecord()
    local app = require("app.App"):instance()
    local conn = app.conn
    local msg = {
      msgID = self.DeskName..'.deskRecord',
    }
    conn:send(msg)
end

function ZJHDesk:deskChatList()
    local app = require("app.App"):instance()
    local conn = app.conn
    local msg = {
      msgID = 'chatList',
    }
    conn:send(msg)
end

function ZJHDesk:requestSitdown(chairId)
    local app = require("app.App"):instance()
    local conn = app.conn
    local msg = {
        msgID = self.DeskName .. '.requestSitdown',
        chairId = chairId,
    }
    app.conn:send(msg)
end

function ZJHDesk:prepare()
    local app = require("app.App"):instance()
    local conn = app.conn
    local msg = {
        msgID = self.DeskName .. '.prepare'
    }
    app.conn:send(msg)
end

function ZJHDesk:autoOperation(msg)
    local app = require("app.App"):instance()
    local conn = app.conn
    local tmsg = {
        msgID = self.DeskName .. '.autoOperation',
        msg = msg
    }
    app.conn:send(tmsg)
end

function ZJHDesk:startGame()
    local app = require("app.App"):instance()
    local conn = app.conn
    local msg = {
        msgID = self.DeskName .. '.bankerStart'
    }
    app.conn:send(msg)
end

function ZJHDesk:uploadVoiceSuccess(filename, total) --luacheck
    local app = require("app.App"):instance()
    local conn = app.conn
    local msg = {
        msgID = 'playVoice',
        filename = filename,
        total = total
    }
    app.conn:send(msg)
end


function ZJHDesk:leaveRoom_quit() --luacheck

    local app = require("app.App"):instance()
    local conn = app.conn
    local msg = {
        msgID = self.DeskName .. '.leaveRoom',
        dropLine = false,
        noScore = true
    }
    app.conn:send(msg)
end

function ZJHDesk:leaveRoom() --luacheck

    local app = require("app.App"):instance()
    local conn = app.conn
    local msg = {
        msgID = self.DeskName .. '.leaveRoom'
    }
    app.conn:send(msg)
end

function ZJHDesk:dismiss() --luacheck
    local app = require("app.App"):instance()
    local conn = app.conn
    local msg = {
        msgID = self.DeskName .. '.overgame'
    }
    app.conn:send(msg)
end

function ZJHDesk:reloadData() --luacheck
    local app = require("app.App"):instance()
    local conn = app.conn
    local msg = {
        msgID = self.DeskName .. '.reloadData'
    }
    app.conn:send(msg)
end

function ZJHDesk:showCard() --luacheck
    local app = require("app.App"):instance()
    local conn = app.conn
    local msg = {
        -- msgID = self.DeskName .. '.choosed',
        msgID = self.DeskName .. '.showCards',
    }
    app.conn:send(msg)
end

--切到后台
function ZJHDesk:enterBackground() --luacheck
    local app = require("app.App"):instance()
    local conn = app.conn
    local msg = {
        msgID = self.DeskName .. '.enterBackground'
    }
    app.conn:send(msg)
end

--设置作弊信息
function ZJHDesk:setCheatData(mode)
    local app = require("app.App"):instance()
    local conn = app.conn
    local msg = {
      msgID = self.DeskName..'.setCheatData',
      mode = mode,
    }
    conn:send(msg)
end

--下注
function ZJHDesk:putmoney(mode, score, compareUid)
    local app = require("app.App"):instance()
    local conn = app.conn
    local msg = {
      msgID = self.DeskName..'.puts',
      mode = mode,
      score = score,
      compareUid = compareUid,
    }
    conn:send(msg)
end

--设置定位信息
function ZJHDesk:setLocationInfo(info)
    local app = require("app.App"):instance()
    local conn = app.conn
    local msg = {
      msgID = self.DeskName..'.setLocationInfo',
      info = info,
    }
    conn:send(msg)
end

--/////////////////////////////////////////////////////////////////////////////////////////////////////
--!public

--@baseInfo
function ZJHDesk:getMaxPlayerCnt() --virtual
    local deskInfo = self.tabBaseInfo.deskInfo 
    return deskInfo.maxPeople
end

function ZJHDesk:getDeskInfo()
    -- 游戏规则
    return self.tabBaseInfo.deskInfo 
end

function ZJHDesk:getgroupInfo()
    -- 俱乐部信息
    return self.tabBaseInfo.groupInfo 
end

function ZJHDesk:getGameplayIdx()
    return self.tabBaseInfo.deskInfo.gameplay 
end

function ZJHDesk:getWanfa()
    return self.tabBaseInfo.deskInfo.wanfa 
end

function ZJHDesk:getWanglai()
    return self.tabBaseInfo.deskInfo.advanced[5] or 0 
end

function ZJHDesk:getDismissInfo()
    -- 解散信息
    return self.overSuggest, self.overTickInfo
end

function ZJHDesk:setDismissInfo(overSuggest, overTickInfo)
    self.overSuggest = overSuggest
    self.overTickInfo = overTickInfo
end

function ZJHDesk:getOwnerInfo()
    -- 房主信息
    return {
        uid = self.tabBaseInfo.ownerUID,
        name = self.tabBaseInfo.ownerName,
    }
end

function ZJHDesk:getDeskId()
    return self.tabBaseInfo.deskId
end

function ZJHDesk:getCurRound()
    return self.tabBaseInfo.number
end

function ZJHDesk:isGamePlaying()
    return self.tabBaseInfo.isPlaying
end

function ZJHDesk:isGamePlayed()
    return self.tabBaseInfo.played
end

function ZJHDesk:isMeOwner()
    local ownerInfo = self:getOwnerInfo()
    local meUid = app.session.user.uid
    return meUid == ownerInfo.uid
end

function ZJHDesk:isMeBanker()
    local bankerUid = self.gameplay:getBankerUID()
    if bankerUid then
        local meUid = self:getMeUID()
        if meUid == bankerUid then
            return true
        end
    end
    return false
end

function ZJHDesk:getMeUID()
    return app.session.user.uid
end

function ZJHDesk:getBankerInfo()
    local uid = self.gameplay:getBankerUID()
    if not uid then return end

    local info = self:getPlayerInfo(uid)
    if not info then return end

    return info
end

function ZJHDesk:isGroupDesk()
    if not self.tabBaseInfo then return end
    return self.tabBaseInfo.isGroupDesk
end


function ZJHDesk:getCanStartPlayer()
    if not self.tabPlayer then return end
    local cnt = 0
    local player
    for k,v in pairs(self.tabPlayer) do
        cnt = cnt + 1
        if player == nil or player:getChairID()>v:getChairID() then
            player = v
        end
    end
    return player
end

function ZJHDesk:canStartGame()
    -- 房主
    if (not self:isMeOwner()) then return false end
    -- 没有玩家
    if not self.tabPlayer then return false end

    local cnt = 0
    for k,v in pairs(self.tabPlayer) do
        cnt = cnt + 1
        if not v:isReady() then
            return false
        end
    end
    if cnt >= 2 then
        return true
    end
    return false
end

function ZJHDesk:getReadyPlayerCnt()
    local cnt = 0
    if not self.tabPlayer then return cnt end
    for k,v in pairs(self.tabPlayer) do
        if v:isReady() then
            cnt = cnt + 1
        end
    end
    return cnt
end


--@player
function ZJHDesk:getPlayerInfo(uid, viewKey) --virtual
    local player
    if not self.tabPlayer then return end

    if viewKey then
        for k,v in pairs(self.tabPlayer) do
            local vkey, vPos = v:getViewInfo()
            if viewKey == vkey then 
                player = v
                break
            end
        end
    elseif uid then
        player = self.tabPlayer[uid]
    end

    if not player then return false end
    
    local info = {}
    info.viewKey, info.chairIdx = player:getViewInfo()
    info.player = player
    info.uid = uid
    return info
end

function ZJHDesk:getPlayerCnt()
    if not self.tabPlayer then return 0 end
    return table.nums(self.tabPlayer) or 0
end

function ZJHDesk:isMePlayer()
    -- 自己是否在比赛中
    if not self.tabPlayer then return false end
    local app = require("app.App"):instance()    
    local meUid = app.session.user.uid
    for k,v in pairs(self.tabPlayer) do
        local uid = v:getUID()
        if meUid == uid then 
            return true, v
        end
    end
    return false
end


function ZJHDesk:isMeInMatch()
    -- 自己是否在比赛中
    if not self.tabPlayer then return false end
    local app = require("app.App"):instance()
    local meUid = app.session.user.uid
    for k,v in pairs(self.tabPlayer) do
        local uid = v:getUID()
        if meUid == uid and v:getInMatch() then 
            return true
        end
    end
    return false
end

function ZJHDesk:getMeAgent()
    -- 主视角玩家
    if not self.tabPlayer then return false end
    local app = require("app.App"):instance()
    local meUid = app.session.user.uid
    for k,v in pairs(self.tabPlayer) do
        local uid = v:getUID()
        if meUid == uid then 
            return v
        end
    end
    return false
end

--@gameplay


function ZJHDesk:getTick()
    return self.gameplay:getTick()
end

--@deskRecord
function ZJHDesk:getDeskRecord(msg)
    return self.tabDeskRecord
end

--@watchList
function ZJHDesk:getWatcherList()
    return self.tabWatcher
end

--@chatList
function ZJHDesk:getChatList()
    return self.tabChatList
end



--////////////////////////////////////////////////////////////////////////////////////////////////
-- !private
function ZJHDesk:initPlayer(uid, agentPack, lookupFlag, lookupCID, initSelf) 
    -- 初始化tabPlayer
    if not self.tabPlayer then self.tabPlayer = {} end
    
    local agent = Agent(agentPack)
    local bottomPos = 1
    
    -- 自己是玩家初始化自己
    if initSelf then
        local key = self:getViewKey(bottomPos)
        agent:setViewInfo(key, bottomPos)
        self.tabPlayer[uid] = agent 
        return
    end

    -- 其他座位
    local bottomCID = 1
    

    if lookupFlag then
        -- 旁观者
        -- if lookupCID then           
        --     -- syndeskdata
        --     bottomCID = lookupCID
        -- else    
        --     -- somebodySitdown
        --     bottomCID = self:getLastFreeChairID()
        -- end
    else
        -- 玩家
        local bool, meAgent = self:isMePlayer()
        if bool then
            bottomCID = meAgent:getChairID()
        end
    end

    
    local agentCID = agent:getChairID()
    local maxPlayerCnt = self:getMaxPlayerCnt()

    local pos = ((bottomPos + agentCID - bottomCID - 1 + maxPlayerCnt) % maxPlayerCnt) + 1
    -- local pos = bottomPos + (agentCID - bottomCID)

    print("initPlayer pos:", pos, "bottomCID:", bottomCID, "agentCID:", agentCID, "maxPlayer:", maxPlayerCnt, "bottomPos", bottomPos)
    local key = self:getViewKey(pos)
    agent:setViewInfo(key, pos)
    self.tabPlayer[uid] = agent 
end

function ZJHDesk:getLastFreeChairID()
    --最后的空位
    local tabValidCID = {}
    local validCnt = 0
    for i = 1, self:getMaxPlayerCnt() do tabValidCID[i] = false end
    for k,v in pairs(self.tabPlayer) do
        tabValidCID[v.chairIdx] = true
        validCnt = validCnt + 1
    end
    local cID = 1
    for k,v in pairs(tabValidCID) do
        if v == false and k > cID then
            cID = k
        end
    end
    if validCnt == self:getMaxPlayerCnt() then
        cID = self:getMaxPlayerCnt()
    end
    return cID
end

return ZJHDesk
