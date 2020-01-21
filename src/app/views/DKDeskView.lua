local Scheduler = require('app.helpers.Scheduler')
local SoundMng = require('app.helpers.SoundMng')
local tools = require('app.helpers.tools')
local HeartbeatCheck = require('app.helpers.HeartbeatCheck')
local app = require("app.App"):instance() 
local GameLogic = require('app.libs.depu.DKGameLogic')

local testluaj = nil
if device.platform == 'android' then
    testluaj = require('app.models.luajTest')--引入luajTest类
end

local SUIT_UTF8_LENGTH = 3

local DKDeskView = {}

function DKDeskView:initialize(ctrl) -- luacheck: ignore
    --节点事件
    self:enableNodeEvents()
    
    --心跳包模块
    self.heartbeatCheck = HeartbeatCheck()

    if self.ui then
        self.ui:removeFromParent()
        self.ui = nil
    end

    -- 读取csb
    local View = require('mvc.View')
    local desk = ctrl.desk
    if desk and desk:getMaxPlayerCnt() == 9 then
        self.ui = View.loadUI('views/DKDeskView2.csb')
    else
        self.ui = View.loadUI('views/DKDeskView.csb')
    end
    self:addChild(self.ui)

    --开始,继续,坐下 按钮位置
    self.tabBtnPos = {
        left = cc.p(430.00, 181.4),
        right = cc.p(710.00, 181.4),
        middle = cc.p(565, 181.4),
    }

    self.suit_2_path = {
        ['♠'] = 'h',
        ['♣'] = 'm',
        ['♥'] = 'z',
        ['♦'] = 'f',
        ['★'] = 'j1',
        ['☆'] = 'j2',
    }

    self.kusoArr = {
        { path = 'views/xydesk/kuso/kuso1.plist',
          frame = 24, prefix = 'cjd_' },

        { path = 'views/xydesk/kuso/kuso2.plist',
          frame = 24, prefix = 'dg_' },

        { path = 'views/xydesk/kuso/kuso3.plist',
          frame = 24, prefix = 'fz_' },

        { path = 'views/xydesk/kuso/kuso4.plist',
          frame = 20, prefix = 'hpj_' },

        { path = 'views/xydesk/kuso/kuso5.plist',
          frame = 24, prefix = 'hqc_' },

        { path = 'views/xydesk/kuso/kuso6.plist',
          frame = 17, prefix = 'wen_' },

        { path = 'views/xydesk/kuso/kuso7.plist',
          frame = 20, prefix = 'zhd_' },

        { path = 'views/xydesk/kuso/kuso8.plist',
          frame = 22, prefix = 'zht_' },

        { path = 'views/xydesk/kuso/kuso9.plist',
          frame = 20, prefix = 'zj_' },
    }

    -- state
    self.state = 'none'

    -- 作弊界面 相关状态
    self.cheatViewStatus = {
        startPos = nil, -- cc.p
        endPos = nil,   -- cc.p
        signalCount = 0,
        signalCheck = false,
    }

    self.bankerPlayedSound = false

    -- 显示庄家动画相关
    self.updateBankerFunc = nil

    -- 储存所有扑克节点纹理路径
    self.tabCardsTexture = {}

    -- 所有进行中的动画
    self.tabRuningAnimate = {}

    --tick
    self.stateTick = 0
    self.deviceTick = 0
    -- tips
    self.tipText = ''

    -- 作弊标签
    self.tabCheatLable = {}

    self.updateF = Scheduler.new(function(dt)
        self:update(dt)
    end)
end

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- state

function DKDeskView:reloadState(toState)
    -- if self.state and self['onOut' .. self.state] then
    --     self['onOut' .. self.state](self)
    -- end
    self.next = toState
    self.state = toState
end

function DKDeskView:checkState()
	if self.next ~= self.state then
        if self.state and self['onOut' .. self.state] then
            print(string.format('onOut %s', self.state))
			self['onOut' .. self.state](self)
		end
		self.state = self.next
        if self.state and self['onEnter' .. self.state] then
            print(string.format('onEnter %s', self.state))
			self['onEnter' .. self.state](self)
		end
	end
end

function DKDeskView:setState(state)
    print(string.format('setState %s', self.state))
    self.next = state
    self:checkState()
end

function DKDeskView:updateState(dt)
    if self.state and self['onUpdate' .. self.state] then
        self['onUpdate' .. self.state](self, dt)
    end
end

function DKDeskView:onMessageState(msg)
    if self.state and self['onMessage' .. self.state] then
        self['onMessage' .. self.state](self, msg)
    end
end

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- state: Ready
function DKDeskView:onEnterReady(curState)
    local desk = self.desk
    
    -- tip
    if self.desk:isGamePlayed() then
        local tick = self.desk:getTick()
        self:freshTip(true, '下局游戏开始：', tick)
    end


    self:freshPrepareBtn(false) --坐下自动准备不显示中部准备按钮
    if desk:isMePlayer() then
        -- 自己是玩家
        local bottomAgnet = desk:getMeAgent()
        self:freshWatcherBtn(false)
        if bottomAgnet:isReady() then
            -- 已经准备
            self:freshContinue(false)
            self:freshPrepareBtn(false)
        else
            -- 没有准备
            if desk:isGamePlayed() then
                self:freshContinue(true)
            end
        end
    else
        -- 不是玩家
        local cnt = self.desk:getPlayerCnt()
        if cnt == self.desk:getMaxPlayerCnt() then
            self:freshWatcherBtn(false) -- 显示坐下按钮
        else
            self:freshWatcherBtn(true) -- 显示坐下按钮
        end
    end 


    local ownerInfo = desk:getOwnerInfo()
    local app = require("app.App"):instance()
    local meUid = app.session.user.uid
    if meUid == ownerInfo.uid and not desk:isGamePlayed() then
        -- 自己是房主, 且游戏没开始
        self:freshGameStartBtn(true, false) --显示开始游戏按钮
    else
        self:freshGameStartBtn(false, false)
    end

    if not desk:isGamePlayed() then
        self:freshInviteFriend(true) -- 邀请按钮
    end

    self:freshBtnPos() -- 调整按钮位置

    -- 隐藏界面
    self:freshWatcherSp(false)

end

function DKDeskView:onOutReady(curState)
    self:freshTip(false)

    -- self:freshWatcherBtn(false)
    if not self.desk:isMePlayer() then
        self:freshWatcherSp(true)   
    else
        self:freshWatcherBtn(false)
    end

    self:freshGameStartBtn(false, false)
    self:freshPrepareBtn(false)
    self:freshInviteFriend(false)
    self:freshContinue(false)
    

    -- 隐藏当局得分
    self:freshAllOneRoundScore()
    -- 隐藏所有玩家卡牌
    self:freshAllCards()
    -- 隐藏公共牌
    self:showPublicCard(false)
    -- 隐藏所有 玩家头像的准备
    self:freshAllReady(false)
end

function DKDeskView:onUpdateReady(dt)
    -- 调整界面位置
    self:freshBtnPos()

    -- 刷新提示文本
    local played = self.desk:isGamePlayed()
    local canStart = (self.desk:getReadyPlayerCnt()>=2)
    if not played then
        local name = '房主'
        if self.desk:isGroupDesk() then
            -- 牛友群房间
            local startPlayer = self.desk:getCanStartPlayer()
            if startPlayer then
                name = startPlayer:getNickname() or name
                local meUid = self.desk:getMeUID()
                if meUid == startPlayer:getUID() then
                    self:freshGameStartBtn(true, canStart)
                else
                    self:freshGameStartBtn(false, false)
                end
            else
                self:freshGameStartBtn(false, false)
            end
        else
            -- 普通房间
            if self.desk:isMeOwner() then
                self:freshGameStartBtn(true, canStart)
            else
                self:freshGameStartBtn(false, false)
            end
        end
        
        -- 刷新开始按钮
        if canStart then
            self:freshTip(true, string.format( "等待 %s 开始游戏...", name))
        else
            self:freshTip(true, '请等待其他玩家加入...')
        end
    end
        
    if not self.desk:isMePlayer() then -- 坐下按钮 | 请等待下局开始
        -- self:freshWatcherSp(true) 
        local cnt = self.desk:getPlayerCnt()
        if cnt == self.desk:getMaxPlayerCnt() then
            self:freshWatcherBtn(false) -- 显示坐下按钮
        else
            local flag = false
            if not self.watcherSitdownBtnLayer:isVisible() then
                flag = true
            end
            self:freshWatcherBtn(true,flag) -- 显示坐下按钮
        end
    end
end


function DKDeskView:onMessageReady(msg)
    if msg.msgID == 'canStart' then
        local enable = msg.canStart or false
        if not self.desk:isGroupDesk() then
            if self.desk:isMeOwner() then
                self:freshGameStartBtn(true, enable)
            end
        end

    elseif msg.msgID == 'somebodyPrepare' then 
        local playerInfo = msg.info
        local viewKey = playerInfo.viewKey
        local meAgent = self.desk:getMeAgent()
        if meAgent then
            local meViewkey = meAgent:getViewInfo()
            if viewKey == meViewkey then
                self:freshTipText('等待其他玩家准备')
                self:freshPrepareBtn(false)
                self:freshContinue(false)
            end
        end
        self:freshReadyState(viewKey, true)

    elseif msg.msgID == 'waitStart' then
    

    elseif msg.msgID == 'responseSitdown' then
        local retCode = msg.errCode
        local textTab = {
            [1] = "没有足够的座位",
            [2] = "您已经坐下了",
            [3] = "本房间为AA模式, 您的房卡不足",
            [4] = "您暂时不能加入该牛友群的游戏, 详情请联系该群管理员",
            [5] = "本房间开启了游戏途中禁止加入功能",
            [6] = "您的信誉值不足",
            [7] = "管理员不能进行游戏",
            [8] = "该位置已有玩家",
        }
        if retCode and retCode ~= 0 then
            tools.showRemind(textTab[retCode])
        end
        self:freshWatcherBtn(false)
    else
        self:onMessagePutMoneyForth(msg)
    end
end

function DKDeskView:onReloadReady(curState)
    if self.desk.tabPlayer then 
        for uid, agent in pairs(self.desk.tabPlayer) do
            local viewKey, viewPos = agent:getViewInfo()
            self:freshReadyState(viewKey, agent:isReady())
        end
    end
    self:reloadState('Ready')
    self:onEnterReady()
end

function DKDeskView:freshIsCoin()
    if not self.desk.tabBaseInfo then return end
    local deskInfo = self.desk.tabBaseInfo.deskInfo
    if not deskInfo then return end
    for key, val in pairs(self.viewKey) do
        local seat = self.MainPanel:getChildByName(val)
        local img = seat:getChildByName('avatar'):getChildByName('point'):getChildByName('img')
        img:setVisible(deskInfo.roomMode == 'bisai')
    end
end

function DKDeskView:freshWatcherSp(bShow)
    bShow = bShow or false
    self.watcherStatusSp:setVisible(bShow)
end

function DKDeskView:freshWatcherBtn(bShow, flag)
    bShow = bShow or false
    if flag then
        bShow = false
    end
    self.watcherSitdownBtnLayer:setVisible(bShow)
    -- self.playerViews.msg:setVisible(not bShow)
    self.playerViews.voice:setVisible(not bShow)

    local viewkeyData = self.desk:getViewKeyData()
    for i, v in pairs(viewkeyData) do
        self.watcherSitdownBtnLayer:getChildByName(v):setVisible(false)
    end

    if bShow then
        for i, v in pairs(viewkeyData) do
            self.watcherSitdownBtnLayer:getChildByName(v):setVisible(true)
        end
        if self.desk.tabPlayer then
            for i, v in pairs(self.desk.tabPlayer) do
                local viewkey = v:getViewInfo()
                self.watcherSitdownBtnLayer:getChildByName(viewkey):setVisible(false)
            end
        end
    end
end

function DKDeskView:onResponseSitdown(msg)
    local retCode = msg.errCode
    local textTab = {
        [1] = "没有足够的座位",
        [2] = "您已经坐下了",
        [3] = "本房间为AA模式, 您的房卡不足",
        [4] = "您暂时不能加入该牛友群的游戏, 详情请联系该群管理员",
        [5] = "本房间开启了游戏途中禁止加入功能",
        [6] = "您的信誉值不足",
        [7] = "管理员不能进行游戏",
        [8] = "该位置已有玩家",
    }
    if retCode and retCode ~= 0 then
        tools.showRemind(textTab[retCode])
    else
        self:freshWatcherBtn(false)
    end
end

function DKDeskView:freshContinue(bool)
    local continue = self.MainPanel:getChildByName('continue')
    continue:setVisible(bool)
end

function DKDeskView:freshPrepareBtn(bool)
	local btn = self.MainPanel:getChildByName('prepare')
    self.outerFrameBool = false
	btn:setVisible(bool)
end

function DKDeskView:freshBtnPos()
    -- local btnTab = {
        -- self.prepareBtn,
        -- self.startBtn,
        -- self.watcherSitdownBtn
    -- }
    -- local showCnt = 0
    -- for i, v in pairs(btnTab) do
    --     if v:isVisible() then
    --         showCnt = showCnt + 1
    --     end
    -- end
    -- if showCnt == 1 then
    --     self.startBtn:setPosition(self.tabBtnPos.middle)
    --     self.watcherSitdownBtn:setPosition(self.tabBtnPos.middle)
    --     self.prepareBtn:setPosition(self.tabBtnPos.middle)
    -- elseif showCnt == 2 then
    --     self.startBtn:setPosition(self.tabBtnPos.left)
    --     self.watcherSitdownBtn:setPosition(self.tabBtnPos.right)
    --     self.prepareBtn:setPosition(self.tabBtnPos.right)
    -- elseif showCnt == 0 then
    --     self.startBtn:setPosition(self.tabBtnPos.middle)
    --     self.watcherSitdownBtn:setPosition(self.tabBtnPos.middle)
    --     self.prepareBtn:setPosition(self.tabBtnPos.middle)
    -- end
end

function DKDeskView:freshGameStartBtn(show, enable)
	local btn = self.MainPanel:getChildByName('gameStart')
	btn:setVisible(show)
    btn:setEnabled(enable)
end


function DKDeskView:freshAllReady(bool)
    bool = bool or false
    for _, v in pairs(self.viewKey) do
        self:freshReadyState(v, bool)
    end
end 


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- state:StateStarting
function DKDeskView:onEnterStarting(curState)
    -- 重置座位界面
    for k,v in pairs(self.viewKey) do
        self:clearDesk(v)
    end
    
    self:freshRoomInfo(true)

end

function DKDeskView:onOutStarting(curState)

end

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- state:Dealing
function DKDeskView:onEnterDealing(curState)

end

function DKDeskView:onOutDealing(curState)
   
end

function DKDeskView:onMessageDealing(msg)
    if msg.msgID == 'bettingActionEnd' then 
        -- self:showBettingActionEnd(msg.viewKey)
    end
end

function DKDeskView:onDealMsg(reload)
    if self.desk.tabPlayer then
        for uid, agent in pairs(self.desk.tabPlayer) do
            if agent:getInMatch() then
                local viewKey = agent:getViewInfo()
                local cardData = agent:getHandCardData()
                if cardData then
                    self:freshCards(viewKey, false, cardData, 1, self.CARD_COUNT)
                else
                    self:freshCards(viewKey, false, nil, 1, self.CARD_COUNT)
                end
                if not reload then
                    self:showCardsAction(viewKey, 1, self.CARD_COUNT)
                else
                    self:freshCards(viewKey, true, cardData, 1, self.CARD_COUNT)
                end
            end
        end
    end
end

-- 隐藏所有扑克
function DKDeskView:freshAllCards()
    for k,v in pairs(self.viewKey) do
        self:freshCards(v, false, nil, 1, self.CARD_COUNT)
    end
end

function DKDeskView:freshCards(name, show, data, head, tail, noTexture)
    show = show or false
    noTexture = noTexture or false

    -- 刷新扑克显示
    local component = self.MainPanel:getChildByName(name)
    if not component then return end
    if head > tail then return end
    local cards = component:getChildByName('cards')
 

    for i = 1, self.CARD_COUNT do
        if i >= head and i <= tail then
            local card = cards:getChildByName('card' .. i)
            -- 停止动作
            card:stopAllActions()
            -- 重置坐标
            local oriPos = self.cardsOrgPos[name][i]
            card:setPosition(oriPos.x, oriPos.y)
            -- 缩放
            card:setScale(1)
            -- 显示
            card:setVisible(show)

            if not noTexture then
                -- 纹理
                if data and data[i] then
                    -- 牌面
                    local cardData = data[i]
                    self:freshCardsTexture(name, i, cardData)
                else
                    -- 牌背
                    local idx = self:getCurCuoPai()
                    self:freshCardsTexture(name, i, nil, idx)
                end
            end
        end
    end

    cards:setVisible(show)
end

function DKDeskView:showCardsAction(name, head, tail) -- virtual
    -- 发牌动画 不刷新纹理
    local component = self.MainPanel:getChildByName(name)
    if not component then return end
    if head > tail then return end

    local delay, duration, offset = 0.3, 0.3, 0.15
    local cards = component:getChildByName('cards')
    cards:setVisible(true)

    for i = head, tail do
        local card = cards:getChildByName('card' .. i)

        -- 使用原始坐标
        local oriPos = self.cardsOrgPos[name][i]

        local startPos = cards:convertToNodeSpace(cc.p(display.cx, display.cy))
        card:setPosition(startPos.x, startPos.y)

        delay = delay + offset
        local dtime = cc.DelayTime:create(delay)
        local move = cc.MoveTo:create(duration, oriPos)
        local show = cc.Show:create()
        local eft = cc.CallFunc:create(function()
            SoundMng.playEft('desk/fapai.mp3')
        end)
        local sequence = cc.Sequence:create(dtime, show, eft, move, 
            cc.CallFunc:create(function()
                if i == tail then
                    self:cardsBackToOriginSeat(name)
                    card:setVisible(true)
                    card:setScale(1)
                end
            end
        ))
        card:stopAllActions()
        
        card:runAction(sequence)

        local sc = cc.ScaleTo:create(duration, 1.0)
        local sq = cc.Sequence:create(dtime, sc)
        card:setScale(0.7)
        card:runAction(sq)
        
    end
end

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- state:Blinds
function DKDeskView:onEnterBlinds(curState)
    local tick = self.desk:getTick()
    self:freshTip(true , '下盲注：', tick)
end

function DKDeskView:onOutBlinds(curState)
    self:freshTip(false)
end

function DKDeskView:onUpdateBlinds(dt)

end

function DKDeskView:onReloadBlinds(curState)
    local gameplay = self.desk.gameplay
    if not gameplay then return end

    -- 押注过程
    if self.desk.tabPlayer then
        for uid, agent in pairs(self.desk.tabPlayer) do
            if agent:getInMatch() then
                local viewKey = agent:getViewInfo()
                self:showBettingActionEnd(viewKey)
            end
        end
    end
    
    self:reloadState('Blinds')
    self:onEnterBlinds()
    self:freshAllText()
end

function DKDeskView:onMessageBlinds(msg)
    if msg.msgID == 'somebodyBlinds' then
        -- 有人押盲注
        local name = msg.info.viewKey
        local putInfo = msg.putInfo
        self:showBettingAction(name, true)
        local deskInfo = self.desk:getDeskInfo()
        local minPut = GameLogic.getPutMoneyMinData(deskInfo)

        if msg.flag then
            if putInfo == minPut then
                self.MainPanel:getChildByName(name):getChildByName('avatar'):getChildByName('text'):setString('小盲注')
                self.MainPanel:getChildByName(name):getChildByName('avatar'):getChildByName('text'):setVisible(true)
            elseif putInfo == minPut * 2 then
                self.MainPanel:getChildByName(name):getChildByName('avatar'):getChildByName('text'):setString('大盲注')
                self.MainPanel:getChildByName(name):getChildByName('avatar'):getChildByName('text'):setVisible(true)
            end
        end

    elseif msg.msgID == 'bettingActionEnd' then 
        self:showBettingActionEnd(msg.viewKey)

    end
end

function DKDeskView:freshAllText()
    local viewkeydata = self.desk:getViewKeyData()
    for i, v in pairs(viewkeydata) do
        self.MainPanel:getChildByName(v):getChildByName('avatar'):getChildByName('text'):setString('')
        self.MainPanel:getChildByName(v):getChildByName('avatar'):getChildByName('text'):setVisible(false)
    end
end

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- state:PutMoneyFirst
function DKDeskView:onEnterPutMoneyFirst(reload)
    if reload then
        local gameplay = self.desk.gameplay
        if not gameplay then return end
        local meUid = app.session.user.uid
        self:showOutFrame()
        self:showLastPlayer()
        local currentPlayer = gameplay:getCurrentPlayer()
        if currentPlayer then
            if meUid == currentPlayer then
                self:freshBettingBar(true, 'First')
                local tick = self.desk:getTick()
                self:freshTip(true , '请下注:', tick) 
                return
            end
        end
    end
    local tick = self.desk:getTick()
    self:freshTip(true , '等待其他玩家下注:', tick)
end

function DKDeskView:onOutPutMoneyFirst(curState)
    self:freshBettingBar(false)
    self:hideAllOutFrame()
    self:hideLastPlayer()
    self:freshTip(false)
    -- self:freshAllText()
end

function DKDeskView:onUpdatePutMoneyFirst(dt)
    
end

function DKDeskView:onReloadPutMoneyFirst(reload)
    local gameplay = self.desk.gameplay
    if not gameplay then return end

    -- 押注过程
    if self.desk.tabPlayer then
        for uid, agent in pairs(self.desk.tabPlayer) do
            if agent:getInMatch() then
                local viewKey = agent:getViewInfo()
                self:showBettingActionEnd(viewKey)
            end
            if agent:getAbandons() then
                local viewKey = agent:getViewInfo()
                self:freshQipai(viewKey, true)
            end
        end
    end

    self:reloadState('PutMoneyFirst')
    self:onEnterPutMoneyFirst(reload)
end

function DKDeskView:onMessagePutMoneyFirst(msg)
    if msg.msgID == 'somebodyPutMoneyFirst' then
        local viewKey = msg.info.viewKey
        local meAgent = self.desk:getMeAgent()
        if meAgent then
            local meViewkey = meAgent:getViewInfo()
            if viewKey == meViewkey then
                self:freshBettingBar(false)
            end
        end

        local tick = self.desk:getTick()
        self:freshTip(true , '等待其他玩家下注:', tick)
        if msg.mode == 1 or msg.mode == 2 or msg.mode == 5 then
            self:showBettingAction(viewKey, true)
        elseif msg.mode == 4 then
            self:freshQipai(viewKey, true)
        end
        self:playEftOption(viewKey, msg.mode)

        self:showLastPlayer()

    elseif msg.msgID == 'putMoneyFirst' then 
        local tick = self.desk:getTick()
        self:freshTip(true , '请下注:', tick) 
        self:freshBettingBar(true, 'First')

    elseif msg.msgID == 'nextPlayer' then 
        self:showOutFrame()
        self:showLastPlayer()

    elseif msg.msgID == 'bettingActionEnd' then 
        self:showBettingActionEnd(msg.viewKey)

    elseif msg.msgID == 'showCoinFlayActionEnd' then
        self:showCoinFlayActionEnd(msg.start, msg.dest)

    elseif msg.msgID == 'summary' then
        self:freshTip(false)
        self.flagEftSummary = false
        self:onSummary()
    end
end

-- 下注按钮界面
function DKDeskView:freshBettingBar(bool, times)
    local betting = self.MainPanel:getChildByName('betting')

    if bool then
        betting:getChildByName('3'):setEnabled(true)
        betting:getChildByName('1'):setEnabled(true)
        betting:getChildByName('2'):setEnabled(true)
        local maxPut = self.desk.gameplay:getMaxPut()
        local meAgent = self.desk:getMeAgent()
        if not meAgent then return end
        local timesPut = meAgent:getTimesPut(times) or 0
        local putScore = meAgent:getPutscore() or 0
        local groupScore = meAgent:getGroupScore()
        print("maxPut",maxPut, "timesPut", timesPut, "putScore", putScore, "groupScore", groupScore)
        if timesPut == maxPut or maxPut == 0 then
            -- 下注分数已是最大的不用跟注
            betting:getChildByName('1'):setEnabled(false)
        end
        if groupScore - putScore <= maxPut then
            -- 分数不够跟注的人不能加注 只能全下
            betting:getChildByName('1'):setEnabled(false)
            betting:getChildByName('2'):setEnabled(false)
            betting:getChildByName('6'):setVisible(false)
        end
        if timesPut < maxPut then
            -- 下注不够最大的人不能跳过
            betting:getChildByName('3'):setEnabled(false)
        end
        local deskInfo = self.desk:getDeskInfo()
        local minPut = GameLogic.getPutMoneyMinData(deskInfo)
        if deskInfo.limit == 1 then
            betting:getChildByName('6'):setVisible(false)
            if times == 'Third' or times == 'Forth' then 
                minPut = minPut * 2 
            end
            if maxPut == minPut * 4 then
                -- 只能加注三次
                betting:getChildByName('2'):setEnabled(false)
            end
            if (groupScore - putScore) > maxPut then
                -- 不能随便allIn
                betting:getChildByName('5'):setEnabled(false)
            end
        elseif deskInfo.limit == 3 then
            if (groupScore - putScore) < maxPut * 2 then
                -- 分数不够最大注2倍不能加注 只能跟注或全下
                betting:getChildByName('2'):setEnabled(false)
                betting:getChildByName('6'):setVisible(false)
            else
                betting:getChildByName('6'):setVisible(true)
                self.maxScore = groupScore - putScore
                self.minScore = maxPut ~= 0 and maxPut * 2 or minPut
                self:freshBettingSlider(0)
            end
        else
            if maxPut == 0 then
                betting:getChildByName('6'):setVisible(true)
                self.maxScore = minPut
                self.minScore = minPut
                self:freshBettingSlider(0)
            else
                if (groupScore - putScore) > maxPut then
                    -- 不能随便allIn
                    betting:getChildByName('5'):setEnabled(false)
                end
                if (groupScore - putScore) < maxPut + minPut then
                    -- 分数不够加注 只能跟注或全下
                    betting:getChildByName('2'):setEnabled(false)
                    betting:getChildByName('6'):setVisible(false)
                    betting:getChildByName('5'):setEnabled(true)
                else
                    betting:getChildByName('6'):setVisible(true)
                    local totalOtherScore = 0
                    for _, agent in pairs(self.desk.tabPlayer) do
                        if agent ~= meAgent then
                            local score = agent:getPutscore() or 0
                            totalOtherScore = totalOtherScore + score
                        end
                    end
                    if totalOtherScore > groupScore - putScore then
                        totalOtherScore = groupScore - putScore
                    end
                    self.maxScore = totalOtherScore
                    self.minScore = (minPut + timesPut < maxPut) and (maxPut - timesPut) or minPut
                    self:freshBettingSlider(0)
                end
            end
        end
    end

    betting:setVisible(bool)
end

-- 显示下注动画
function DKDeskView:showBettingAction(name, bool)
    local component = self.MainPanel:getChildByName(name)
    local avatar = component:getChildByName('avatar')
    local multiple = avatar:getChildByName('multiple')
    local num = multiple:getChildByName('num')

    multiple:setVisible(false)

    local function getStartPos(name)
        local frame = avatar:getChildByName('frame')
        local headimg = frame:getChildByName('headimg')
        local pos = frame:convertToWorldSpace(cc.p(headimg:getPosition()))
        return pos
    end

    local function getDestPos(name)
        local coin = multiple:getChildByName('value')
        local pos = multiple:convertToWorldSpace(cc.p(coin:getPosition()))
        return pos
    end

    local dest = getDestPos(name)
    local start = getStartPos(name)

    for i = 1, 3 do
        local sprite = cc.Sprite:create('views/nysdesk/chouma.png')
        sprite:setVisible(false)
        sprite:setScale(1)
        self:addChild(sprite)

        sprite:setPosition(start)

        local delay = cc.DelayTime:create(0.05 * i) 
        local moveTo = cc.MoveTo:create(0.4, dest)
        local show = cc.Show:create()

        local eft = cc.CallFunc:create(function()
            if i == 2 then
                self:playEftBet(bool)
            end
        end)
        local callBack = cc.CallFunc:create(function()
            if i == 3 then
                -- 动画结束
                self.emitter:emit('bettingActionEnd', {
                    msgID = 'bettingActionEnd',
                    viewKey = name,
                })
                -- multiple:setVisible(true)
                -- num:setString(tostring(value))
            end
        end)

        local rmvSelf = cc.RemoveSelf:create()
        local retainTime = cc.DelayTime:create(1) 
        local sequence = cc.Sequence:create(
            delay, 
            show, 
            moveTo, 
            eft, 
            callBack,
            retainTime, 
            rmvSelf
        )   

        sprite:runAction(sequence)
    end
end

function DKDeskView:freshBettingSlider(percent)
    self.bettingSlider:setPercent(percent)
    if not self.maxScore or not self.minScore then return end
    local qujian = self.maxScore - self.minScore
    local score = self.minScore + math.floor(qujian * percent / 100)
    self.bettingSliderText:setString('' .. score)
end

function DKDeskView:getBettingSliderText()
    return tonumber(self.bettingSliderText:getString())
end

function DKDeskView:showOutFrame()
    -- 刷新外框
    self:hideAllOutFrame()
    local gameplay = self.desk.gameplay
    if not gameplay then return end
    local currentPlayer = gameplay:getCurrentPlayer()
    if currentPlayer then
        local info = self.desk:getPlayerInfo(currentPlayer)
        if info then
            local viewkey = info.player:getViewInfo()
            self:freshOutFrame(viewkey, true)
        end
    end
end

function DKDeskView:hideAllOutFrame()
    local viewkeyData = self.desk:getViewKeyData()
    for i, v in pairs(viewkeyData) do
        self:freshOutFrame(v, false)
    end
end

function DKDeskView:freshOutFrame(viewkey, bool)
    local component = self.MainPanel:getChildByName(viewkey)
    local avatar = component:getChildByName('avatar')
    local frame = avatar:getChildByName('frame')
    local outerFrame = frame:getChildByName('outerFrame')
    outerFrame:setVisible(bool)
end

function DKDeskView:showLastPlayer()
    -- 刷新D位
    self:hideLastPlayer()
    local gameplay = self.desk.gameplay
    if not gameplay then return end
    local lastPlayer = gameplay:getLastPlayer()
    if lastPlayer then
        local info = self.desk:getPlayerInfo(lastPlayer)
        if info and not info.player:getAbandons() then
            local viewkey = info.player:getViewInfo()
            self:freshLastPlayer(viewkey, true)
        end
    end
end

function DKDeskView:hideLastPlayer()
    local viewkeyData = self.desk:getViewKeyData()
    for i, v in pairs(viewkeyData) do
        self:freshLastPlayer(v, false)
    end
end

function DKDeskView:freshLastPlayer(viewkey, bool)
    local component = self.MainPanel:getChildByName(viewkey)
    local avatar = component:getChildByName('avatar')
    local text = avatar:getChildByName('text')
    local str = text:getString()
    if str == '大盲注' or str == '小盲注' then return end
    if bool then
        local playerCnt = self.desk:getPlayerCnt()
        local viewkeyData = self.desk:getViewKeyData()
        local abandonsCnt = 0
        for i, v in pairs(viewkeyData) do
            local info = self.desk:getPlayerInfo(nil, v)
            if info and info.player:getAbandons() then
                abandonsCnt = abandonsCnt + 1
            end
        end
        if playerCnt - abandonsCnt > 2 then
            text:setString('D位')
        end
    end
    text:setVisible(bool)
end

function DKDeskView:showBettingActionEnd(name, times)
    local info = self.desk:getPlayerInfo(nil, name)
    if not info then return end

    -- local banker = self.desk:getBankerInfo()
    -- if banker then
    --     if banker.viewKey == info.viewKey then
    --         self:freshBetting(name, false)
    --         return
    --     end
    -- end

    local putScore = info.player:getPutscore()
    local wGroupScore = info.player:getGroupScore()
    local currentPut = nil
    if times then
        if times == 'first' then
            currentPut = info.player:getFirstPut()
        elseif times == 'second' then
            currentPut = info.player:getSecondPut()
        elseif times == 'third' then
            currentPut = info.player:getThirdPut()
        else
            currentPut = info.player:getForthPut()
        end
    end
    if putScore then
        if currentPut then
            if currentPut == 0 then return end
            self:freshBetting(name, true, currentPut)
        else
            self:freshBetting(name, true, putScore)
        end
        self:freshAllRoundScore(name, 0, wGroupScore - putScore)
    else
        self:freshBetting(name, false)
    end
end

-- 刷新下注界面
function DKDeskView:freshBetting(name, bool, value)
    local component = self.MainPanel:getChildByName(name)
    local avatar = component:getChildByName('avatar')
    local multiple = avatar:getChildByName('multiple')
    local num = multiple:getChildByName('num')

    if not bool then
        multiple:setVisible(false)
        return
    end

    if value then
        num:setString(tostring(value))
        multiple:setVisible(true)
    end
end

--隐藏所有弃牌标志
function DKDeskView:hideAllQipai()
    local viewkeyData = self.desk:getViewKeyData()
    for i, v in pairs(viewkeyData) do
        self:freshQipai(v, false)
    end
end

--刷新弃牌标志
function DKDeskView:freshQipai(viewKey, bool)
    self.MainPanel:getChildByName(viewKey):getChildByName('avatar'):getChildByName('qipai'):setVisible(bool)
end

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- state:PutMoneySecond
function DKDeskView:onEnterPutMoneySecond(reload)
    if reload then
        local gameplay = self.desk.gameplay
        if not gameplay then return end
        local meUid = app.session.user.uid
        self:showOutFrame()
        self:showLastPlayer()
        local currentPlayer = gameplay:getCurrentPlayer()
        if currentPlayer then
            if meUid == currentPlayer then
                self:freshBettingBar(true, 'Second')
                local tick = self.desk:getTick()
                self:freshTip(true , '请下注:', tick) 
                return
            end
        end
    end
    local tick = self.desk:getTick()
    self:freshTip(true , '等待其他玩家下注:', tick)
end

function DKDeskView:onOutPutMoneySecond(curState)
    self:freshBettingBar(false)
    self:hideAllOutFrame()
    self:hideLastPlayer()
    self:freshTip(false)
end

function DKDeskView:onUpdatePutMoneySecond(dt)
    
end

function DKDeskView:onReloadPutMoneySecond(reload)
    local gameplay = self.desk.gameplay
    if not gameplay then return end

    -- 押注过程
    if self.desk.tabPlayer then
        for uid, agent in pairs(self.desk.tabPlayer) do
            if agent:getInMatch() then
                local viewKey = agent:getViewInfo()
                self:showBettingActionEnd(viewKey, 'second')
            end
            if agent:getAbandons() then
                local viewKey = agent:getViewInfo()
                self:freshQipai(viewKey, true)
            end
        end
    end

    self:showPublicCard(true, 1, 3)

    self:reloadState('PutMoneySecond')
    self:onEnterPutMoneySecond(reload)
end

function DKDeskView:onMessagePutMoneySecond(msg)
    if msg.msgID == 'somebodyPutMoneySecond' then
        local viewKey = msg.info.viewKey
        local meAgent = self.desk:getMeAgent()
        if meAgent then
            local meViewkey = meAgent:getViewInfo()
            if viewKey == meViewkey then
                self:freshBettingBar(false)
            end
        end
        local tick = self.desk:getTick()
        self:freshTip(true , '等待其他玩家下注', tick)
        if msg.mode == 1 or msg.mode == 2 or msg.mode == 5 then
            self:showBettingAction(viewKey, true)
        elseif msg.mode == 4 then
            self:freshQipai(viewKey, true)
        end

        self:playEftOption(viewKey, msg.mode)

        self:showLastPlayer()

    elseif msg.msgID == 'putMoneySecond' then  
        local tick = self.desk:getTick()
        self:freshTip(true , '请下注:', tick) 
        self:freshBettingBar(true, 'Second')

    elseif msg.msgID == 'nextPlayer' then 
        self:showOutFrame()
        self:showLastPlayer()

    elseif msg.msgID == 'bettingActionEnd' then 
        self:showBettingActionEnd(msg.viewKey, 'second')

    elseif msg.msgID == 'showCoinFlayActionEnd' then
        self:showCoinFlayActionEnd(msg.start, msg.dest)

    elseif msg.msgID == 'summary' then
        self:freshTip(false)
        self.flagEftSummary = false
        self:onSummary()
    end
end
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- state:PutMoneyThird
function DKDeskView:onEnterPutMoneyThird(reload)
    if reload then
        local gameplay = self.desk.gameplay
        if not gameplay then return end
        local meUid = app.session.user.uid
        self:showOutFrame()
        self:showLastPlayer()
        local currentPlayer = gameplay:getCurrentPlayer()
        if currentPlayer then
            if meUid == currentPlayer then
                self:freshBettingBar(true, 'Third')
                local tick = self.desk:getTick()
                self:freshTip(true , '请下注:', tick) 
                return
            end
        end
    end
    local tick = self.desk:getTick()
    self:freshTip(true , '等待其他玩家下注:', tick)
end

function DKDeskView:onOutPutMoneyThird(curState)
    self:freshBettingBar(false)
    self:hideAllOutFrame()
    self:hideLastPlayer()
    self:freshTip(false)
end

function DKDeskView:onUpdatePutMoneyThird(dt)
    
end

function DKDeskView:onReloadPutMoneyThird(reload)
    local gameplay = self.desk.gameplay
    if not gameplay then return end

    -- 押注过程
    if self.desk.tabPlayer then
        for uid, agent in pairs(self.desk.tabPlayer) do
            if agent:getInMatch() then
                local viewKey = agent:getViewInfo()
                self:showBettingActionEnd(viewKey, 'third')
            end
            if agent:getAbandons() then
                local viewKey = agent:getViewInfo()
                self:freshQipai(viewKey, true)
            end
        end
    end

    self:showPublicCard(true, 1, 4)

    self:reloadState('PutMoneyThird')
    self:onEnterPutMoneyThird(reload)
end

function DKDeskView:onMessagePutMoneyThird(msg)
    if msg.msgID == 'somebodyPutMoneyThird' then
        local viewKey = msg.info.viewKey
        local meAgent = self.desk:getMeAgent()
        if meAgent then
            local meViewkey = meAgent:getViewInfo()
            if viewKey == meViewkey then
                self:freshBettingBar(false)
            end
        end
        local tick = self.desk:getTick()
        self:freshTip(true , '等待其他玩家下注:', tick)
        if msg.mode == 1 or msg.mode == 2 or msg.mode == 5 then
            self:showBettingAction(viewKey, true)
        elseif msg.mode == 4 then
            self:freshQipai(viewKey, true)
        end

        self:playEftOption(viewKey, msg.mode)

        self:showLastPlayer()

    elseif msg.msgID == 'putMoneyThird' then  
        self:freshBettingBar(true, 'Third')
        local tick = self.desk:getTick()
        self:freshTip(true , '请下注:', tick) 

    elseif msg.msgID == 'nextPlayer' then 
        self:showOutFrame()
        self:showLastPlayer()

    elseif msg.msgID == 'bettingActionEnd' then 
        self:showBettingActionEnd(msg.viewKey, 'third')

    elseif msg.msgID == 'showCoinFlayActionEnd' then
        self:showCoinFlayActionEnd(msg.start, msg.dest)

    elseif msg.msgID == 'summary' then
        self:freshTip(false)
        self.flagEftSummary = false
        self:onSummary()
    end
end
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- state:PutMoneyForth
function DKDeskView:onEnterPutMoneyForth(reload)
    if reload then
        local gameplay = self.desk.gameplay
        if not gameplay then return end
        local meUid = app.session.user.uid
        self:showOutFrame()
        self:showLastPlayer()
        local currentPlayer = gameplay:getCurrentPlayer()
        if currentPlayer then
            if meUid == currentPlayer then
                self:freshBettingBar(true, 'Forth')
                local tick = self.desk:getTick()
                self:freshTip(true , '请下注:', tick) 
                return
            end
        end
    end
    local tick = self.desk:getTick()
    self:freshTip(true , '等待其他玩家下注:', tick)
end

function DKDeskView:onOutPutMoneyForth(curState)
    self:freshBettingBar(false)
    self:hideAllOutFrame()
    self:hideLastPlayer()
    self:freshTip(false)
end

function DKDeskView:onUpdatePutMoneyForth(dt)
    
end

function DKDeskView:onReloadPutMoneyForth(reload)
    local gameplay = self.desk.gameplay
    if not gameplay then return end

    -- 押注过程
    if self.desk.tabPlayer then
        for uid, agent in pairs(self.desk.tabPlayer) do
            if agent:getInMatch() then
                local viewKey = agent:getViewInfo()
                self:showBettingActionEnd(viewKey, 'forth')
            end
            if agent:getAbandons() then
                local viewKey = agent:getViewInfo()
                self:freshQipai(viewKey, true)
            end
        end
    end

    self:showPublicCard(true, 1, 5)

    self:reloadState('PutMoneyForth')
    self:onEnterPutMoneyForth(reload)
end

function DKDeskView:onMessagePutMoneyForth(msg)
    if msg.msgID == 'somebodyPutMoneyForth' then
        local viewKey = msg.info.viewKey
        local meAgent = self.desk:getMeAgent()
        if meAgent then
            local meViewkey = meAgent:getViewInfo()
            if viewKey == meViewkey then
                self:freshBettingBar(false)
            end
        end
        local tick = self.desk:getTick()
        self:freshTip(true , '等待其他玩家下注:', tick)
        if msg.mode == 1 or msg.mode == 2 or msg.mode == 5 then
            self:showBettingAction(viewKey, true)
        elseif msg.mode == 4 then
            self:freshQipai(viewKey, true)
        end

        self:playEftOption(viewKey, msg.mode)

        self:showLastPlayer()

    elseif msg.msgID == 'putMoneyForth' then  
        self:freshBettingBar(true, 'Forth')
        local tick = self.desk:getTick()
        self:freshTip(true , '请下注:', tick) 

    elseif msg.msgID == 'nextPlayer' then 
        self:showOutFrame()
        self:showLastPlayer()

    elseif msg.msgID == 'bettingActionEnd' then 
        self:showBettingActionEnd(msg.viewKey, 'forth')
    
    elseif msg.msgID == 'showCoinFlayActionEnd' then
        self:showCoinFlayActionEnd(msg.start, msg.dest)    

    elseif msg.msgID == 'summary' then
        self:freshTip(false)
        self.flagEftSummary = false
        self:onSummary()
    end
end

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- state:DealFirst
function DKDeskView:onEnterDealFirst(curState)
    local tick = self.desk:getTick()
    self:freshTip(true , '展示前三张公共牌')

    local viewkeyData = self.desk:getViewKeyData()
    for i, v in pairs(viewkeyData) do
        self:freshBetting(v, false)
    end

    self:showPublicCard(true, 1, 3)
    self:freshJackpot()
end

function DKDeskView:onOutDealFirst(curState)

end

function DKDeskView:onUpdateDealFirst(dt)
    
end

function DKDeskView:onReloadDealFirst(curState)
    local gameplay = self.desk.gameplay
    if not gameplay then return end

    -- 押注过程
    if self.desk.tabPlayer then
        for uid, agent in pairs(self.desk.tabPlayer) do
            if agent:getInMatch() then
                local viewKey = agent:getViewInfo()
                -- self:showBettingActionEnd(viewKey)
            end
        end
    end

    self:reloadState('DealFirst')
    self:onEnterDealFirst()
end

function DKDeskView:onMessageDealFirst(msg)
    if msg.msgID == 'bettingActionEnd' then 
        self:showBettingActionEnd(msg.viewKey, 'first')
    end
end

function DKDeskView:showPublicCard(bool, star, dest)
    local publicCardNode = self.MainPanel:getChildByName('publicCardNode')
    publicCardNode:setVisible(bool)
    
    if bool then
        local gameplay = self.desk.gameplay
        if not gameplay then return end
        local publicCard = gameplay:getPublicCard()
        if not publicCard or next(publicCard) == nil then return end
        for i = star, dest do
            local cardNode = publicCardNode:getChildByName('card' .. i)
            local value = publicCard[i]
            local suit = self.suit_2_path[self:card_suit(value)]
            local rnk = self:card_rank(value)
            local path
            if suit == 'j1' or suit == 'j2' then
                path = 'views/xydesk/cards/' .. suit .. '.png'
            else
                path = 'views/xydesk/cards/' .. suit .. rnk .. '.png'
            end
            cardNode:loadTexture(path)
            cardNode:setVisible(true)
        end
    else
        for i = 1, 5 do
            local cardNode = publicCardNode:getChildByName('card' .. i)
            cardNode:setVisible(false)
            local idx = self:getCurCuoPai()
            local path = 'views/xydesk/cards/xpaibei_' .. idx .. '.png'
            cardNode:loadTexture(path)
        end
    end
end

function DKDeskView:freshJackpot()
    local topbar = self.MainPanel:getChildByName('topbar')
    local info = topbar:getChildByName('info')
    local JackpotNode = info:getChildByName('Jackpot')
    if not self.desk.gameplay then return end
    local jackpot = self.desk.gameplay:getJackpot()
    JackpotNode:setString("奖池:" .. jackpot)
end

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- state:DealSecond
function DKDeskView:onEnterDealSecond(curState)
    local tick = self.desk:getTick()
    self:freshTip(true , '展示前四张公共牌')

    local viewkeyData = self.desk:getViewKeyData()
    for i, v in pairs(viewkeyData) do
        self:freshBetting(v, false)
    end

    self:showPublicCard(true, 1, 4)
    self:freshJackpot()
end

function DKDeskView:onOutDealSecond(curState)

end

function DKDeskView:onUpdateDealSecond(dt)
    
end

function DKDeskView:onReloadDealSecond(curState)
    local gameplay = self.desk.gameplay
    if not gameplay then return end

    -- 押注过程
    if self.desk.tabPlayer then
        for uid, agent in pairs(self.desk.tabPlayer) do
            if agent:getInMatch() then
                local viewKey = agent:getViewInfo()
                -- self:showBettingActionEnd(viewKey)
            end
        end
    end

    self:reloadState('DealSecond')
    self:onEnterDealSecond()
end

function DKDeskView:onMessageDealSecond(msg)
    if msg.msgID == 'bettingActionEnd' then 
        self:showBettingActionEnd(msg.viewKey, 'second')
    end
end

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- state:DealThird
function DKDeskView:onEnterDealThird(curState)
    local tick = self.desk:getTick()
    self:freshTip(true , '展示五张公共牌')

    local viewkeyData = self.desk:getViewKeyData()
    for i, v in pairs(viewkeyData) do
        self:freshBetting(v, false)
    end

    self:showPublicCard(true, 1, 5)
    self:freshJackpot()
end

function DKDeskView:onOutDealThird(curState)

end

function DKDeskView:onUpdateDealThird(dt)
    
end

function DKDeskView:onReloadDealThird(curState)
    local gameplay = self.desk.gameplay
    if not gameplay then return end

    -- 押注过程
    if self.desk.tabPlayer then
        for uid, agent in pairs(self.desk.tabPlayer) do
            if agent:getInMatch() then
                local viewKey = agent:getViewInfo()
                -- self:showBettingActionEnd(viewKey)
            end
        end
    end

    self:reloadState('DealThird')
    self:onEnterDealThird()
end

function DKDeskView:onMessageDealThird(msg)
    if msg.msgID == 'bettingActionEnd' then 
        self:showBettingActionEnd(msg.viewKey, 'third')
    end
end

--------------------------------------------------------------------------------------------

function DKDeskView:showCoinFlayActionEnd(start, dest)
    local winner = self.desk:getPlayerInfo(nil, dest)
    if not winner then return end
    local loser = self.desk:getPlayerInfo(nil, start)
    if not loser then return end 

    local wScore = winner.player:getScore()
    local lScore = loser.player:getScore()
    local wGroupScore = winner.player:getGroupScore()
    local lGroupScore = loser.player:getGroupScore()
    if (not wScore) or (not lScore) then return end

    self:freshOneRoundScore(winner.viewKey, true, wScore)
    self:freshOneRoundScore(loser.viewKey, true, lScore)

    local wMoney = winner.player:getMoney()
    local lMoney = loser.player:getMoney()

    self:freshAllRoundScore(winner.viewKey, wMoney, wGroupScore)
    self:freshAllRoundScore(loser.viewKey, lMoney, lGroupScore)

    self:showWinAction(winner.viewKey)

    if not self.flagEftSummary then
        local meAgent = self.desk:getMeAgent()
        if meAgent then
            local meViewkey = meAgent:getViewInfo()
            if winner.viewKey == meViewkey then
                self.playEftSummary(true)
                self.flagEftSummary = true
            elseif loser.viewKey == meViewkey then
                self.playEftSummary(false)
                self.flagEftSummary = true
            end
        end 
    end
end

-- 隐藏所有单局得分界面
function DKDeskView:freshAllOneRoundScore()
    for k,v in pairs(self.viewKey) do
        self:freshOneRoundScore(v, false)
    end
end

function DKDeskView:onSummary() -- virtual
    local function showCard(agent)
        -- 显示结果
        local viewKey = agent:getViewInfo()
        local cards = agent:getSummaryCardData()
        local sex = agent:getSex()
        self:freshCards(viewKey, true, cards, 1, self.CARD_COUNT)
        local choose, cnt, spType, maxCard = agent:getChoosed()
        if not cnt then return end
        self:freshSeatCardType(viewKey, true, false, cnt, spType, maxCard)
        -- self:freshSeatMul(viewKey, true, cnt, spType, maxCard)
        -- self:playEftCardType(sex,cnt,spType, maxCard)
        self:freshSeatFireworks(viewKey,true, cnt, spType, maxCard)
    end

    local tabScoreData = {}

    if not self.desk.tabPlayer then return end

    local playerCnt, abandonsCnt = 0, 0
    for uid, agent in pairs(self.desk.tabPlayer) do
        if agent:getInMatch() then
            playerCnt = playerCnt + 1
            if agent:getAbandons() then
                abandonsCnt = abandonsCnt + 1
            end
        end
    end
       
    local maxAgent = nil
    for uid, agent in pairs(self.desk.tabPlayer) do
        if agent:getInMatch() then
            -- 显示扑克
            local viewKey = agent:getViewInfo()
            local score = agent:getScore()
            table.insert(tabScoreData, {viewKey, score})
            if not agent:getAbandons() and (playerCnt - abandonsCnt) >= 2 then
                showCard(agent)
            end
            if not maxAgent or maxAgent:getScore() < score then
                maxAgent = agent
            end
        end
    end
    
    -- 组织金币飞行动画
    -- local bankerInfo = self.desk:getBankerInfo()
    local bankerViewKey = maxAgent:getViewInfo()
    local bankerScore = maxAgent:getScore()

    local gameplayIdx = self.desk:getGameplayIdx()
    local actionDelay = 0
    local deskInfo = self.desk:getDeskInfo()
    local gameplay = deskInfo.gameplay

    -- 其他模式
    if bankerScore >= 0 then
        actionDelay = 0.5
    end
    for _, s1 in ipairs(tabScoreData) do
        if s1[1] ~= bankerViewKey then
            if s1[2] and s1[2] < 0 then
                self:showCoinFlayAction(s1[1], bankerViewKey, 0)
            elseif s1[2] > 0 then
                self:showCoinFlayAction(bankerViewKey, s1[1], actionDelay)
            else
                self.emitter:emit('showCoinFlayActionEnd', 
                {
                    msgID = 'showCoinFlayActionEnd',
                    start = bankerViewKey,
                    dest = s1[1],
                })
            end
        end
    end
end

-- 金币飞行动画
function DKDeskView:showCoinFlayAction(start, dest, delay)
    local coinCnt = 15
    delay = delay or 0

    local getPos = function(name)
        local seat = self.MainPanel:getChildByName(name)
        local avatar = seat:getChildByName('avatar')
        local frame = avatar:getChildByName('frame')
        local headimg = frame:getChildByName('headimg')
        local pos = frame:convertToWorldSpace(cc.p(headimg:getPosition()))
        return pos
    end

    math.randomseed(os.time())

    for i = 1, coinCnt do
        local sprite = cc.Sprite:create('views/nysdesk/chouma.png')
        sprite:setVisible(false)
        sprite:setScale(1.0)
        self:addChild(sprite)

        local posStart = getPos(start)
        sprite:setPosition(cc.p(posStart.x + math.random(-30, 30), posStart.y + math.random(-20, 20)))
        
        local d = 0
        if bankerSeat and start == bankerSeat then 
            d = 1
        end 
        
        local destPos = cc.p(getPos(dest))
        destPos = cc.p(destPos.x + math.random(-20, 20), destPos.y + math.random(-20, 20))
        local time = cc.pGetDistance(posStart, destPos)/1500

        local delayAction = cc.DelayTime:create(0.05 * i + d + delay) 
        local moveTo = cc.MoveTo:create(time, destPos)
        local show = cc.Show:create()
        -- local vol = cc.CallFunc:create(function()
        --     SoundMng.playEftEx('desk/jinbi.mp3')
        -- end)

        local bezier ={
            cc.p(getPos(start)),
            {display.cx, display.cy},
            cc.p(getPos(dest))
        }

        --local bezierTo = cc.BezierTo:create(0.8, bezier)
        local eft = cc.CallFunc:create(function()
            if i == 1 then
                SoundMng.playEft('desk/coins_fly.mp3')
            end
        end)
        local call = function()
            self.emitter:emit('showCoinFlayActionEnd', 
            {
                msgID = 'showCoinFlayActionEnd',
                start = start,
                dest = dest,
            })
        end
        local rmvSelf = cc.RemoveSelf:create()
        local retainTime = cc.DelayTime:create(1) 
        local sequence = cc.Sequence:create(delayAction, show, moveTo, eft, cc.CallFunc:create(call), retainTime, rmvSelf)
        sprite:runAction(sequence)
    end
end

function DKDeskView:showWinAction(name)
    local seat = self.MainPanel:getChildByName(name)
    local avatar = seat:getChildByName('avatar')
    local node = avatar:getChildByName('jiaqianAnimation')

    local action = cc.CSLoader:createTimeline("views/animation/Jiaqian.csb")
    action:gotoFrameAndPlay(0, false)
    action:setTimeSpeed(1.3)
    node:stopAllActions()
    node:runAction(action)
end

-- 总得分
function DKDeskView:freshAllRoundScore(name, score, groupScore)
    score = score or 0
    local component = self.MainPanel:getChildByName(name)
    local avatar = component:getChildByName('avatar')

    local point = avatar:getChildByName('point')
    local value = point:getChildByName('value')
    if self.desk.tabBaseInfo and self.desk.tabBaseInfo.deskInfo and self.desk.tabBaseInfo.deskInfo.roomMode == 'bisai' and groupScore then
        value:setString(groupScore)
    else
        value:setString(score)
    end
end

-- 当局得分
function DKDeskView:freshOneRoundScore(name, bool, score)
    score = score or 0
    local component = self.MainPanel:getChildByName(name)
    local avatar = component:getChildByName('avatar')
    local result = avatar:getChildByName('result')

    if not bool then
        result:setVisible(false)
        return
    end

    local zheng = result:getChildByName('zheng')
    local fu = result:getChildByName('fu')
    zheng:setVisible(false)
    fu:setVisible(false)

    if score > 0 then
        zheng:getChildByName('value'):setString(math.abs(score))
        zheng:getChildByName('value'):setVisible(true)
        zheng:setVisible(true)
    else
        fu:getChildByName('value'):setString(math.abs(score))
        fu:getChildByName('value'):setVisible(true)
        fu:setVisible(true)
    end

    result:setVisible(true)
end

-- 牛几 | 特殊牌图片 | 完成
function DKDeskView:freshSeatCardType(name, bool, wcIcon, niuCnt, spcialType, maxCard)
    local component = self.MainPanel:getChildByName(name)
    local check = component:getChildByName('check')
    local valueSp = check:getChildByName('value')
    local valueSp1 = check:getChildByName('value1')
    local wc = check:getChildByName('wc')

    valueSp:setVisible(false)
    if valueSp1 then valueSp1:setVisible(false) end
    wc:setVisible(false)

    if not bool then return end

    if wcIcon then 
        check:setVisible(true)
        wc:setVisible(true) 
        return 
    end

    local path = ''
    if spcialType and spcialType > 0 then
        local idx = self.desk:getGameplayIdx()
        local wanfa = self.desk:getWanfa()
        local specialType = GameLogic.getSpecialTypeByVal(idx, spcialType, wanfa)
        path = 'views/xydesk/result/DK' .. specialType .. '.png'
        valueSp:loadTexture(path)
    else
        path = 'views/xydesk/result/' .. niuCnt .. '.png'
        valueSp:loadTexture(path)
    end

    check:setVisible(true)
    valueSp:setVisible(true)
    if valueSp1 then valueSp1:setVisible(true) end
end

-- 焰火
function DKDeskView:freshSeatFireworks(name, bool, niu, special)
    local component = self.MainPanel:getChildByName(name)
    local check = component:getChildByName('check')
    local yellow = check:getChildByName('teshupaiYellow')
    local red = check:getChildByName('teshupaiRed')
    local xingxing = check:getChildByName('xingxing')

    yellow:stopAllActions()
    red:stopAllActions()
    yellow:setVisible(false)
    red:setVisible(false)
    xingxing:setVisible(false)
    xingxing:stopAllActions()

    if not bool then return end
    -- if niu == 0 and special == 0 then return end

    local node = yellow 
    local action = cc.CSLoader:createTimeline("views/animation/Teshupai.csb")
    if special > 0 then
        node = red
        action = cc.CSLoader:createTimeline("views/animation/Teshupai1.csb")
    end

    local xxAction = cc.CSLoader:createTimeline("views/animation/xingxing.csb")
    xxAction:gotoFrameAndPlay(0, true)
    xingxing:setVisible(true)
    xingxing:runAction(xxAction)

    action:gotoFrameAndPlay(0, false)
    action:setTimeSpeed(0.8)
    
    node:runAction(action)
    node:setVisible(true)
end

-- 倍数图片
function DKDeskView:freshSeatMul(name, show, niuCnt, specialType)
    
    local function getNumNode(name)
        local component = self.MainPanel:getChildByName(name)
        local check = component:getChildByName('check')
        local valueSp = check:getChildByName('value')
        local num = check:getChildByName('num')
        return num
    end

    local node = getNumNode(name)
    if node and not show then
        node:setVisible(false)
        return
    end

    local deskInfo = self.desk:getDeskInfo()
    local gameplay = deskInfo.gameplay
    local set = deskInfo.multiply
    local wanfa = deskInfo.wanfa

    local mul = GameLogic.getMul(gameplay, set, niuCnt, specialType, wanfa)

    if mul and node then
        local path =  string.format("views/xydesk/numbers/yellow/%s.png", mul)
        if specialType > 0 or niuCnt == 10 then
            path =  string.format("views/xydesk/numbers/red/%s.png", mul)
        end
        -- if specialType == 0 and niuCnt == 0 then 
        --     node:setVisible(false)
        --     return 
        -- end
        node:loadTexture(path)
        node:setVisible(true)
    else
        node:setVisible(false)
    end
end

-- ==================== agent =========================

function DKDeskView:freshMoney(name, money, groupScore)
    local component = self.MainPanel:getChildByName(name)
    if not component then
        return
    end
    local avatar = component:getChildByName('avatar')
    local point = avatar:getChildByName('point')
    local value = point:getChildByName('value')
    if money then
        if self.desk.tabBaseInfo and self.desk.tabBaseInfo.deskInfo and self.desk.tabBaseInfo.deskInfo.roomMode == 'bisai' and groupScore then
            value:setString(tostring(groupScore))
        else
            value:setString(tostring(money))
        end
    else
        value:setString('')
    end
end

-- 玩家座位
function DKDeskView:freshSeat(name, bool)
    local component = self.MainPanel:getChildByName(name)
    component:setVisible(bool)
end


-- ==================== private =========================

function DKDeskView:onExit()
    if self.updateF then
        Scheduler.delete(self.updateF)
        self.updateF = nil
    end
    if self.schedulerID2 then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID2)
    end
end

function DKDeskView:update(dt)
    self.stateTick = self.stateTick + dt
    self.deviceTick = self.deviceTick + dt
    if self.stateTick >= 0.1 then
        self:checkState()
        self:updateState()
        self.stateTick = 0
    end
    if self.deviceTick >= 10 then
        self:freshDeviceInfo()
        self.deviceTick = 0
    end
    self:sendHeartbeatMsg(dt)

end

function DKDeskView:onPing()
    self.heartbeatCheck:onPing()
end

function DKDeskView:sendHeartbeatMsg(dt)
    if not self.pauseHeartbeat then
        self.heartbeatCheck:update(dt)
    end
end

function DKDeskView:layout(desk)
    self.desk = desk
    self.viewKey = self.desk:getViewKeyData()

    -- 玩法
    local deskInfo = self.desk:getDeskInfo()
    self.CARD_COUNT = 2

    -- 界面屏幕位置
    local mainPanel = self.ui:getChildByName('MainPanel')
    mainPanel:setPosition(display.cx, display.cy)
    self.MainPanel = mainPanel

    -- 桌面背景
    local desktopIdx = self:getCurDesktop() or 2
    self:setCurDesktop(desktopIdx)
    self:changeDesktop(desktopIdx) 

    -- 搓牌界面
    local cpLayer = self.MainPanel:getChildByName('cpLayer')
    self.cpLayer = cpLayer
    self.rubLayer = nil  

    -- 发送语音按钮回调
    local voice = self.MainPanel:getChildByName('voice')
    voice:addTouchEventListener(function(event, type)
        if type == 0 then
            local scheduler = cc.Director:getInstance():getScheduler()
	        self.schedulerID = scheduler:scheduleScriptFunc(function()
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
                self.emitter:emit('pressVoice')
                self.emitPressvoice = true
            end, 0.8, false)
        elseif type ~= 1 then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
            if self.emitPressvoice then 
                self.emitter:emit('releaseVoice')
                self.emitPressvoice = false
            end
        end
    end)

    -- 作弊界面
    local btn = ccui.Button:create("views/xydesk/setting.png")
    btn:setOpacity(0)
    btn:setContentSize(50, 50)
    btn:setPosition(cc.p(26,569))
    btn:setVisible(false)
    btn:setEnabled(false)
    btn:addTouchEventListener(function(sender, type)
        local checkCount = 1
        if type == 0 then
            -- begin
            self.cheatViewStatus.startPos = sender:getTouchBeganPosition()

            if self.cheatViewStatus.signalCount > checkCount then
                print("cheatview show")
                --self.emitter:emit('cheatview', true) 暂时不走contorller
                self:showCheatView(true)
            end

        elseif type == 1 then
            -- move
            local rPos = sender:getTouchMovePosition()
            local difY = self.cheatViewStatus.startPos.y - rPos.y
            if math.abs(difY) > 150 then
                self.cheatViewStatus.signalCheck = true
            end

        else
            -- end
            if self.cheatViewStatus.signalCount > checkCount then
                self.cheatViewStatus.signalCount = 0
                print("cheatview hide")
                --self.emitter:emit('cheatview', false) 暂时不走contorller
                self:showCheatView(false)
            end

            if self.cheatViewStatus.signalCheck then
                self.cheatViewStatus.signalCount = self.cheatViewStatus.signalCount + 1
                self.cheatViewStatus.signalCheck = false
                print(self.cheatViewStatus.signalCount)
            end
        end
    end)
    self.cheatBtn = btn
    self.MainPanel:addChild(self.cheatBtn, 999)

    --一键输赢----------------------------------------------------------------------
    local setBg = self.MainPanel:getChildByName('gameSetting'):getChildByName('bg')
    self.cheatDa = setBg:getChildByName('1')
    self.cheatXiao = setBg:getChildByName('2')
    self.cheatWu = setBg:getChildByName('3')
    self.cheatDa:setVisible(false)
    self.cheatXiao:setVisible(false)
    self.cheatWu:setVisible(false)
    -- self.cheatState = setBg:getChildByName('state')
    -- self.cheatState:setVisible(false)
    ----------------------------------------------

    -- init watcher view
    local watcherLayout = self.MainPanel:getChildByName('watcherLayout')
    -- self.watcherSitdownBtn = watcherLayout:getChildByName('sitdownBtn')
    self.watcherSitdownBtnLayer = self.MainPanel:getChildByName('sitdownBtnLayer')
    self.watcherStatusSp = watcherLayout:getChildByName('statusSp')
    self.watcherLayout = watcherLayout

    --wanfa view
    self.wanfaLayer = self.MainPanel:getChildByName('wanfa')

    -- init control view
    self.playerViews = {}
    self.playerViews.msg = self.MainPanel:getChildByName('msg')
    self.playerViews.voice = self.MainPanel:getChildByName('voice')
    --self.playerViews.prepare = self.MainPanel:getChildByName('prepare')
    --self.playerViews.gameStart = self.MainPanel:getChildByName('gameStart')
    --self.playerViews.invite = self.MainPanel:getChildByName('invite')
    self.playerViews.continue = self.MainPanel:getChildByName('continue')
    self.playerViews.betting = self.MainPanel:getChildByName('betting')
    self.bettingSliderText = self.playerViews.betting:getChildByName('6'):getChildByName('text')
    self.bettingSlider = self.playerViews.betting:getChildByName('6'):getChildByName('slider')
    self.bettingSlider:addEventListener(function(_, eventType)
        print("eventType", eventType)
        local per = self.bettingSlider:getPercent()
        self:freshBettingSlider(per)
      end)

    -- init status text
    self.statusTextBg = self.MainPanel:getChildByName('statusTextBg')
    self.statusText = self.MainPanel:getChildByName('statusText')

    -- gameSetting
	local gameSetting = self.MainPanel:getChildByName('gameSetting')
	local bg = gameSetting:getChildByName('bg')
	local leave = bg:getChildByName('leave')
    local dismiss = bg:getChildByName('dismiss')

    self.leaveBtn = leave
    self.dismissBtn = dismiss
    self.inviteBtn = self.MainPanel:getChildByName('invite')
    self.startBtn = self.MainPanel:getChildByName('gameStart')
    self.prepareBtn = self.MainPanel:getChildByName('prepare')

    -- if self.desk.isOwner then
    --     self.startBtn:setPosition(self.tabBtnPos.left)
    --     self.prepareBtn:setPosition(self.tabBtnPos.right)
    --     self.watcherSitdownBtn:setPosition(self.tabBtnPos.right)
    -- else
    --     self.startBtn:setPosition(self.tabBtnPos.left)
    --     self.prepareBtn:setPosition(self.tabBtnPos.middle)
    --     self.watcherSitdownBtn:setPosition(self.tabBtnPos.middle)
    -- end
    self.watcherLayout:setVisible(true)

    self.tabCardsPos = {}

    self.trusteeshipLayer = self.MainPanel:getChildByName('trusteeshipLayer')

    -- 记录所有扑克位置
    self.cardsOrgPos = {}
    for key, val in pairs(self.viewKey) do
        local seat = self.MainPanel:getChildByName(val)
        local cardsNode = seat:getChildByName('cards')
        self.cardsOrgPos[val] = {}
        for i = 1, self.CARD_COUNT do
            local card = cardsNode:getChildByName('card' .. i)
            local x, y = 64 + 60*(i - 1) , 88.83
            self.cardsOrgPos[val][i] = cc.p(x, y)
        end
    end

    -- 隐藏界面
    self:freshWatcherBtn(false)
    self:freshWatcherSp(false)
    self:freshPrepareBtn(false)
    self:freshGameStartBtn(false, false)

    -- 是否比赛场(金币场)
    self:freshIsCoin()

    self:freshBtnPos()

    --刷新电量等信息
    self:freshDeviceInfo()

    --牌九看牌中途变量
    self.tempPos = {}

    --下注量
    self.PutmoneyData = {}

    -- local scheduler = cc.Director:getInstance():getScheduler()
    -- self.schedulerID2 = scheduler:scheduleScriptFunc(function()
    --     local time = os.time()
    --     if self.nowtime then
    --         if time - self.nowtime > 30 then
    --             if self.desk:isGamePlaying() and self.desk:isMePlayer() 
    --             and not self:getTrusteeshipLayer() then
    --                 self.desk:requestTrusteeship()
    --                 self:freshTrusteeshipLayer(true)
    --                 print("离开了啊----------------------------------------")
    --             end
    --             self.nowtime = time
    --         end
    --     end
    -- end, 0, false)

    --添加监听层
    local listenpanel = self.MainPanel:getChildByName('Panel')
    listenpanel:setSwallowTouches(false)
    listenpanel:addClickEventListener(function ()
        print("click--------------------------------------------")
        self.nowtime = os.time()
    end)
end

function DKDeskView:changeDesktop(idx)
    idx = idx or 4
    local path = ''
    path = 'views/nysdesk/zhuozi' .. idx .. '.png'
	self.MainPanel:getChildByName('zhuozi'):loadTexture(path)
	self:setCurDesktop(idx)
end

function DKDeskView:setCurDesktop(idx)
	local app = require("app.App"):instance()
	app.localSettings:set('desktop_dk', idx)
end

function DKDeskView:getCurDesktop()
	local app = require("app.App"):instance()
	local idx = app.localSettings:get('desktop_dk')
	return idx or 4
end

function DKDeskView:getCurCuoPai()
	local app = require("app.App"):instance()
	local idx = app.localSettings:get('cuoPai')
	idx = idx or 1
	return idx
end 

function DKDeskView:changeCardBack()
    local backIdx = self:getCurCuoPai()
    for k, v in pairs(self.tabCardsTexture) do
        for n, m in pairs(v) do
            if m == 'back' then
                self:freshCardsTexture(k,n,nil,backIdx)
            end
        end
    end
end 

-- 游戏重连，场景恢复
function DKDeskView:recoveryDesk(desk, reload)

    self.nowtime = os.time()

    --退出当前状态
    if self.state and self['onOut' .. self.state] then
        self['onOut' .. self.state](self)
    end

    -- 桌子信息
    local deskInfo = self.desk:getDeskInfo()
    self:freshRoomInfo(true)

    for k,v in pairs(self.viewKey) do
        self:clearDesk(v)
        self:resetPlayerView(v)
    end

    -- 奖池信息
    self:freshJackpot()

    -- 隐藏大小盲注
    self:freshAllText()

    -- 隐藏弃牌标志
    self:hideAllQipai()

    -- 玩家基本信息
    if self.desk.tabPlayer then
        for uid, agent in pairs(self.desk.tabPlayer) do
            local actor = agent.actor
            local viewKey, viewPos = agent:getViewInfo()
            local groupScore = agent:getGroupScore()
            local putScore = agent:getPutscore() or 0
            self:freshHeadInfo(viewKey, actor)
            if self.state == 'Ready' then
                self:freshMoney(viewKey, agent:getMoney(), groupScore)
            else
                self:freshMoney(viewKey, agent:getMoney(), groupScore - putScore)
            end
            self:freshSeat(viewKey, true)
            self:freshEnterBackground(viewKey,agent:isEnterBackground() or false)
            self:freshDropLine(viewKey,agent:isDropLine() or false)
            self:freshTrusteeshipIcon(viewKey,agent:getTrusteeship() or false)
        end
    end

    -- 坐下按钮 | 请等待下局开始
    if not self.desk:isMePlayer() then
        self:freshWatcherBtn(true) -- 显示坐下按钮
        self:freshWatcherSp(self.desk:isGamePlaying())
    end


    -- 扑克
    local isDeal = self.desk.gameplay:getFlagDealAllPlayer()
    if not isDeal then
        self:freshAllCards()
        self:showPublicCard(false)
    else
        -- 显示自己扑克
        self:onDealMsg(true)
    end

    -- gameplay
    if not self.desk:isGamePlaying() then
        -- 不在游戏中
        self:onReloadReady()
    else
        -- 在游戏中

        if not self.desk:isMePlayer() then -- 坐下按钮 | 请等待下局开始
            self:freshWatcherSp(true) 
            local cnt = self.desk:getPlayerCnt()
            if cnt == self.desk:getMaxPlayerCnt() then
                self:freshWatcherBtn(false) -- 显示坐下按钮
            else
                self:freshWatcherBtn(true) -- 显示坐下按钮
            end

        end

        if self.desk:isMePlayer() then
            local agent = self.desk:getMeAgent()
            local flag = agent:getSmartTrusteeship()
            if flag then
                self:freshTrusteeshipLayer(flag)
            end
        end
        local gameplay = self.desk.gameplay
        if not gameplay then return end

        local curState, curTick = gameplay:getState()

        if curState == 'Blinds' then
            self:onReloadBlinds()
        elseif curState == 'Dealing' then
            self:onEnterDealing()
        elseif curState == 'DealFirst' then
            self:onEnterDealFirst()
        elseif curState == 'DealSecond' then
            self:onEnterDealSecond()
        elseif curState == 'DealThird' then
            self:onEnterDealThird()
        elseif curState == 'PutMoneyFirst' then
            self:onReloadPutMoneyFirst(reload)
        elseif curState == 'PutMoneySecond' then
            self:onReloadPutMoneySecond(reload)
        elseif curState == 'PutMoneyThird' then
            self:onReloadPutMoneyThird(reload)
        elseif curState == 'PutMoneyForth' then
            self:onReloadPutMoneyForth(reload)
        elseif curState == 'Ending' then
            -- self:onReloadPlaying()
        end
    end

    -- 解散信息
    local hasInfo = self.desk:getDismissInfo()
    if hasInfo then
        self.emitter:emit('showDismissView')
    end
end


-- 重置界面(单局结算时)
function DKDeskView:clearDesk(name)
    local component = self.MainPanel:getChildByName(name)
    local avatar = component:getChildByName('avatar')
    local result = avatar:getChildByName('result')
    result:setVisible(false)

    local multiple = avatar:getChildByName('multiple')
    multiple:setVisible(false)

    local check = component:getChildByName('check')
    check:setVisible(false)

    local banker = avatar:getChildByName('banker')
    banker:setVisible(false)

    local numNode = avatar:getChildByName('qzNum')
    numNode:setVisible(false)

    local frame = avatar:getChildByName('frame')
    local outerFrame = frame:getChildByName('outerFrame')
    outerFrame:setVisible(false)

    local cards = component:getChildByName('cards')
    cards:setVisible(false)
    local app = require("app.App"):instance()

    local idx = self:getCurCuoPai()
    for i = 1, 5 do
        self:freshCardsTexture(name, i, nil, idx)
    end
    self.tempPos = {}

    self:freshAllText()
    self:hideAllQipai()  
end


--- 玩家
function DKDeskView:resetPlayerView(name)
    local component = self.MainPanel:getChildByName(name)
    if not component then return end
    local avatar = component:getChildByName('avatar')

    local frame = avatar:getChildByName('frame')
    local headimg = frame:getChildByName('headimg')
    -- headimg:setVisible(false)
    frame:setVisible(false)

    local point = avatar:getChildByName('point')
    local value = point:getChildByName('value')
    value:setString('')

    local playername = avatar:getChildByName('playername')
    local value = playername:getChildByName('value')
    value:setString('')

    avatar.data = nil
    frame:addClickEventListener(function() end)
end

function DKDeskView:freshHeadInfo(name, data)
    local component = self.MainPanel:getChildByName(name)
    if not component then
        return
    end

    local avatar = component:getChildByName('avatar')
    local frame = avatar:getChildByName('frame')
    frame:setVisible(true)
    local headimg = frame:getChildByName('headimg')

    if data then
        headimg:retain()
        local cache = require('app.helpers.cache')
        cache.get(data.avatar, function(ok, path)
            if ok then
                headimg:show()
                headimg:loadTexture(path)
            end
            headimg:release()
        end)
    else
        headimg:loadTexture('views/public/tx.png')
    end

    -- local point = avatar:getChildByName('point')
    -- local value = point:getChildByName('value')
    -- if data then
    --     value:setString(tostring(data.money))
    -- else
    --     value:setString('')
    -- end

    local playername = avatar:getChildByName('playername')
    local value = playername:getChildByName('value')
    if data then
        value:setString(data.nickName)
    else
        value:setString('')
    end

    -- 注册点击回调
    if data then
        local uid = data.uid
        frame:addClickEventListener(function()
            self.emitter:emit('clickHead', uid)
        end)
    end
end

function DKDeskView:freshSeat(name, bool)
    local component = self.MainPanel:getChildByName(name)
    component:setVisible(bool)
end

-- 桌子信息
function DKDeskView:freshRoomInfo(bool)
    local topbar = self.MainPanel:getChildByName('topbar')
    local info = topbar:getChildByName('info')

    local deskInfo = self.desk:getDeskInfo()

    -- 房号
    local strRoomId = self.desk:getDeskId()
    local roomid = info:getChildByName('roomid')
    roomid:setString("房号:" .. strRoomId)

    -- 玩法
    local limit = GameLogic.getLimitText(deskInfo)
    local gameplay = info:getChildByName('gameplay')
    gameplay:setString("限制:" .. limit)

    -- 底分
    local strBase = GameLogic.getBaseText(deskInfo)
    local base = info:getChildByName('base')
    base:setString("底分:" .. strBase)

    -- 局数
    -- local strRound = self.desk:getCurRound()
    -- local round = info:getChildByName('round')
    -- round:setString("局数:" .. strRound .. "/" .. deskInfo.round)

    -- 推注
    local strPutmoney = GameLogic.getPutMoneyText(deskInfo)
    local putmoney = info:getChildByName('putmoney')
    putmoney:setString("下注:" .. strPutmoney)

    -- 奖池
    local Jackpot = info:getChildByName('Jackpot')
    Jackpot:setString("奖池:" .. 0)

    info:setVisible(bool)
end

function DKDeskView:freshDeviceInfo()
    local topbar = self.MainPanel:getChildByName('topbar')
    local net = topbar:getChildByName('net')
    local battery_B = topbar:getChildByName('battery_B')
    local battery_F = topbar:getChildByName('battery_F')
    local time = topbar:getChildByName('time')
    local getTime = os.date('%X');
    time:setString(string.sub(getTime,1,string.len(getTime)-3))
    if testluaj then
        local testluajobj = testluaj.new(self)
        local ok, ret1 = testluajobj.callandroidWifiState(self);
        if ok then
            print("android 网络信号强度为  " .. ret1)
        end
        if ret1 == 21 then
            net:loadTexture("views/lobby/Wifi2.png" )
        elseif ret1 == 22 then
            net:loadTexture("views/lobby/Wifi3.png" )
        elseif ret1 == 23 then
            net:loadTexture("views/lobby/Wifi4.png" )
        elseif ret1 == 24 then
            net:loadTexture("views/lobby/Wifi4.png" )
        elseif ret1 == 25 then
            net:loadTexture("views/lobby/Wifi4.png" )
        elseif ret1 == 11 then
            net:loadTexture("views/lobby/4g2.png" )
        elseif ret1 == 12 then
            net:loadTexture("views/lobby/4g3.png" )
        elseif ret1 == 13 then
            net:loadTexture("views/lobby/4g4.png" )
        elseif ret1 == 14 then
            net:loadTexture("views/lobby/4g4.png" )
        elseif ret1 == 15 then
            net:loadTexture("views/lobby/4g4.png" )
        end
        local ok, ret2 = testluajobj.callandroidBatteryLevel(self);
        if ok then
            print("android 电量为  " .. ret2)
            local w = battery_F:getContentSize().width * ret2 / 100
            local h = battery_F:getContentSize().height
            battery_B:setContentSize(w,h)
        end
    
    elseif device.platform == 'ios' then
        -- local luaoc = nil
        -- luaoc = require('cocos.cocos2d.luaoc')
        -- if luaoc then
        --     local ok, battery = luaoc.callStaticMethod("AppController", "getBattery",{ww='dyyx777777'})
        --     if ok then
        --         print("ios 电量为  " .. battery)
        --         local w = battery_F:getContentSize().width * battery / 100
        --         local h = battery_F:getContentSize().height
        --         battery_B:setContentSize(w,h)
        --     end
        --     local ok, netType = luaoc.callStaticMethod("AppController", "getNetworkType",{ww='dyyx777777'})
        --     if ok then
        --         print("ios 信号类型为  " .. netType)
        --         if netType == 1 or netType == 2 or netType == 3 then
        --             net:loadTexture("views/lobby/4g4.png" )
        --         elseif netType == 5 then
        --             net:loadTexture("views/lobby/Wifi4.png" )
        --         end
        --     end
        -- end
        battery_B:setVisible(false)
        battery_F:setVisible(false)
        net:setVisible(false)

    end
end

-- 屏幕中心游戏状态提示文本 cd: second
function DKDeskView:freshTip(bShow, text, cd)
    bShow = bShow or false

    self.statusText:stopAllActions()
    self.statusTextBg:setVisible(bShow)
    self.statusText:setVisible(bShow)

    if not bShow then
        return
    end

    self.tipText = text

    local function initCdAction()
        local delay = cc.DelayTime:create(1)
        local update = cc.CallFunc:create(function()
            self.statusText:setString(string.format("%s %ss", self.tipText, cd))
            cd = cd - 1
            if cd < 0 then
                self.statusTextBg:setVisible(false)
                self.statusText:setVisible(false)
            end
        end)
        local action = cc.Repeat:create(cc.Sequence:create(update, delay), cd)
        self.statusText:runAction(action)
    end

    self.statusText:setString(text)

    if cd and cd > 0 then
        initCdAction()
    end
end

function DKDeskView:freshTipText(text)
    if not text then return end
    if text == '' then return end
    self.tipText = text
end

-- ================== 作弊界面 ==================
-- 透明
function DKDeskView:freshCheatView(msg)
    if self.cheatBtn then
        self.cheatBtn:setVisible(true)
        self.cheatBtn:setEnabled(true)

        local deskInfo = self.desk:getDeskInfo()
        local setting = deskInfo.special
        local gameplay = deskInfo.gameplay
        local wanfa = deskInfo.wanfa

        for k, v in pairs(msg) do
            local info = self.desk:getPlayerInfo(k)
            if info then
                local viewKey = info.viewKey
                local cards = v.tabCards

                local cnt, sptype, spKey, maxCard = GameLogic.getLocalCardType(cards, gameplay, setting, wanfa)

                local cheatStr = "--"
                if sptype > 0 then
                    cheatStr = spKey or '特殊牌'
                elseif cnt > 0 then
                    cheatStr = string.format( "%s", cnt)
                end

                self:freshCheatLabel(viewKey, cheatStr)
            end
        end

    end
end

function DKDeskView:showCheatView(bShow, key)
    bShow = bShow or false
    key = key or false
    if key and self.tabCheatLable[key] then
        self.tabCheatLable[key]:setVisible(true)
    else
        for k, v in pairs(self.tabCheatLable) do
            v:setVisible(bShow)
        end
    end
end

-- 一键输赢
function DKDeskView:freshCheat1View(show, flag)
    show = show or false
    flag = flag or 0
    self.cheatDa:setVisible(show)
    self.cheatXiao:setVisible(show)
    -- self.cheatXiao:setVisible(false)
    -- if flag == 1 then
    --     self.cheatXiao:setVisible(true)
    -- end
    self.cheatWu:setVisible(false)
end

function DKDeskView:freshCheat1Result(mode)
    if mode then
        -- local state = self.cheatState
        -- state:stopAllActions()
        -- state:setString(string.format( "%s", mode))
        -- state:setVisible(true)
        -- local delay = cc.DelayTime:create(2)
        -- local sequence = cc.Sequence:create(delay, cc.CallFunc:create(function()
        --     state:setVisible(false)
        -- end))
        -- state:runAction(sequence)
        self:freshCheat1View(false, 0)
    end
end

-- ===================================================

function DKDeskView:freshCheatLabel(viewKey, cheatStr)
    cheatStr = cheatStr or ''
    local function getPos(name)
        local seat = self.MainPanel:getChildByName(name)
        local avatar = seat:getChildByName('avatar')
        local frame = avatar:getChildByName('frame')
        local headimg = frame:getChildByName('headimg')
        local pos = frame:convertToWorldSpace(cc.p(headimg:getPosition()))
        return pos
    end

    local function creatLable(pos, name)
        local label = cc.Label:createWithTTF("0",'views/font/fangzheng.ttf', 64)
        label:setPosition(pos)
        label:setVisible(false)
        label:setColor(cc.c3b(255,0,0))
        -- label:setOpacity(180)
        self.tabCheatLable[name] = label
        self.MainPanel:addChild(label, 999)
    end

    if not self.tabCheatLable[viewKey] then
        local pos = getPos(viewKey)
        if pos then
            creatLable(pos, viewKey)
        end
    end
    local label = self.tabCheatLable[viewKey]
    if label then
        label:setString(cheatStr)
    end 
end


function DKDeskView:card_suit(c)
	if not c then print(debug.traceback()) end
    if c == '☆' or c == '★' then
        return c
    else
        return #c > SUIT_UTF8_LENGTH and c:sub(1, SUIT_UTF8_LENGTH) or nil
    end
end

function DKDeskView:card_rank(c)
    return #c > SUIT_UTF8_LENGTH and c:sub(SUIT_UTF8_LENGTH + 1, #c) or nil
end

function DKDeskView:freshCardsTexture(name, idx, value, backIdx)
    local component = self.MainPanel:getChildByName(name)
    local cards = component:getChildByName('cards')
    local card = cards:getChildByName('card' .. idx)
    
    value = value or '♠A'

    local suit = self.suit_2_path[self:card_suit(value)]
    local rnk = self:card_rank(value)

    if not self.tabCardsTexture[name] then
        self.tabCardsTexture[name] = {}
    end
    self.tabCardsTexture[name][idx] = 'front'

    local path
    if backIdx then
        self.tabCardsTexture[name][idx] = 'back'
        path = 'views/xydesk/cards/xpaibei_' .. backIdx .. '.png'
    elseif suit == 'j1' or suit == 'j2' then
        path = 'views/xydesk/cards/' .. suit .. '.png'
    else
        path = 'views/xydesk/cards/' .. suit .. rnk .. '.png'
    end
    card:loadTexture(path)
end

function DKDeskView:freshCardsTextureByNode(cardNode, value, backIdx)

    value = value or '♠A'

    local suit = self.suit_2_path[self:card_suit(value)]
    local rnk = self:card_rank(value)

    local path
    if backIdx then
        path = 'views/xydesk/cards/xpaibei_' .. backIdx .. '.png'
    elseif suit == 'j1' or suit == 'j2' then
        path = 'views/xydesk/cards/' .. suit .. '.png'
    else
        path = 'views/xydesk/cards/' .. suit .. rnk .. '.png'
    end
    cardNode:loadTexture(path)
end


local mulArr = {
    { ['10'] = '4', ['9'] = '3', ['8'] = '2', ['7'] = '2' },

    { ['10'] = '3', ['9'] = '2', ['8'] = '2' }
}

function DKDeskView:freshChatMsg(name, sex, msgType, msgData)

    local chatView = require('app.views.DKChatView')
    local chatsTbl = chatView.getChatsTbl()

    local component = self.MainPanel:getChildByName(name)
    local chatFrame = component:getChildByName('chatFrame')
    local txtPnl = chatFrame:getChildByName('txtPnl')
    local szTxTPnl = txtPnl:getContentSize()
    local txt = txtPnl:getChildByName('txt')
    local txtPnl1 = chatFrame:getChildByName('txtPnl1')
    local txt1 = txtPnl1:getChildByName('txt1')    
    local emoji = chatFrame:getChildByName('emoji')
    
    chatFrame:stopAllActions()
    chatFrame:setVisible(true)

    if msgType == 0 then
        -- 快捷语
        SoundMng.playEft('chat/voice_' .. msgData - 1 .. "_".. sex..'.mp3')
    end

    if msgType == 0 or msgType == 2 then
        -- 快捷语 | 自定义聊天
      local str
      if msgType == 0 then
          str = chatsTbl[msgData]
      else
          str = msgData
      end

      txtPnl:setVisible(false)
      txtPnl1:setVisible(false)
      local len = string.len(str)
      if len <= 42 then
        txt:setString(str)
        txtPnl:setVisible(true)
      elseif len > 42 then
        txt1:setString(str)
        txtPnl1:setVisible(true)        
      end
    elseif msgType == 1 then
        -- emoji 表情
        self:freshEmojiAction(name, msgData)
    end

    local callback = function()
        chatFrame:setVisible(false)
        txtPnl:setVisible(false)
        txtPnl1:setVisible(false)
        emoji:setVisible(false)
        txt:setString('')
        txt1:setString('')
    end

    local delay = cc.DelayTime:create(2.5)
    chatFrame:runAction(cc.Sequence:create(delay, cc.CallFunc:create(callback)))
end

function DKDeskView:freshEmojiAction(name, idx)
    local csbPath = {
        'views/animation/se.csb',
        'views/animation/bishi.csb',
        'views/animation/jianxiao.csb',
        'views/animation/woyun.csb',
        'views/animation/shy.csb',
        'views/animation/kelian.csb',
        'views/animation/zhouma.csb',
        'views/animation/win.csb',
        'views/animation/jiayou.csb',
        'views/animation/cry.csb',
        'views/animation/angry.csb',
        'views/animation/koushui.csb',                
    }

    local getPos = function(name)
        local seat = self.MainPanel:getChildByName(name)
        local avatar = seat:getChildByName('avatar')
        local frame = avatar:getChildByName('frame')
        local headimg = frame:getChildByName('headimg')

        local pos = frame:convertToWorldSpace(cc.p(headimg:getPosition()))

        return pos
    end
    
    local str = csbPath[idx]
    local node = cc.CSLoader:createNode(str) 
    node:setPosition(cc.p(getPos(name)))
    self:addChild(node)
    node:setVisible(true)

    local callback = function()
        local action = cc.CSLoader:createTimeline(str)   
        action:gotoFrameAndPlay(0, false)
        action:setFrameEventCallFunc(function(frame)
            local event = frame:getEvent();
            print("=========",event)
            if event == 'end' then
                node:removeSelf()
            end
        end)      
        node:runAction(action)
    end
 
    local delay = cc.DelayTime:create(0.2)
    local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
    node:runAction(sequence)
end


function DKDeskView:gameSettingAction(derection)
	local gameSetting = self.MainPanel:getChildByName('gameSetting')
	local topbar = self.MainPanel:getChildByName('topbar')
	local setting = topbar:getChildByName('setting')
	
	
	local bg = gameSetting:getChildByName('bg')
	local cl = gameSetting:getChildByName('close')
	local sz = bg:getContentSize()
	local pos = cc.p(bg:getPosition())
	local leave = bg:getChildByName('leave')
    local dismiss = bg:getChildByName('dismiss')
    
	local dest, moveTo
	if derection == 'In' then
		cl:setVisible(true)
		setting:setVisible(false)
		gameSetting:setVisible(true)
        bg:setVisible(true)
        
        -- 离开按钮
        local played = self.desk:isGamePlayed() 
        local inMatch = self.desk:isMeInMatch()
        local isplaying = self.desk:isGamePlaying()
		if played and inMatch then
			leave:setEnabled(false)
		else
			leave:setEnabled(true)
        end
        if not isplaying then
            leave:setEnabled(true)
        end
        -- 解散按钮
        dismiss:setEnabled(false)
        if self.desk:isMeInMatch() or self.desk:isMeOwner() then 
            dismiss:setEnabled(true)
        end

	elseif derection == 'Out' then
		cl:setVisible(false)
		setting:setVisible(true)
		gameSetting:setVisible(false)
		bg:setVisible(false)
		
	end
end 

function DKDeskView:freshGameInfo(bool)
	local infoPanel = self.MainPanel:getChildByName('roomInfo')
	local info = infoPanel:getChildByName('info')
	local close = infoPanel:getChildByName('close')
	
	local text_wanfa = info:getChildByName('text_wanfa')
	local text_difen = info:getChildByName('text_difen')
	local text_beiRule = info:getChildByName('text_beiRule')
	local text_roomRule = info:getChildByName('text_roomRule')
    local text_Twanfa = info:getChildByName('text_Twanfa')
    local text_advanceRule = info:getChildByName('text_advanceRule')
    local text_roomlimit = info:getChildByName('text_roomlimit')

    info:setVisible(bool)
    close:setVisible(bool)

    if not bool then return end
    local deskInfo = self.desk:getDeskInfo()


    -- 玩法
    local gameplayStr = GameLogic.getGameplayText(deskInfo)
	text_wanfa:setString(gameplayStr)

    -- 底分
    local baseStr = GameLogic.getBaseText(deskInfo)
	text_difen:setString(baseStr)

    -- 翻倍规则
    local mulStr = GameLogic.getNiuNiuMulText(deskInfo)
    -- text_beiRule:setString(mulStr)
    text_beiRule:setString("全部1倍")

    -- 房间规则
    local roomRuleStr = GameLogic.getRoomRuleText(deskInfo)
    text_roomRule:setString(roomRuleStr)

    -- 特殊牌
    local spStr = GameLogic.getSpecialText(deskInfo)
    text_Twanfa:setString(spStr)

    -- 高级选项
    local limitText = GameLogic.getLimitText(deskInfo)
    -- text_advanceRule:setString(advanceStr)
    if deskInfo.wanfa and deskInfo.wanfa > 0 then
        limitText = limitText .. '  短牌'
    end
    text_advanceRule:setString(limitText)

    -- 房间限制
    local roomlimitstr = GameLogic.getRoomLimitText(deskInfo)
    text_roomlimit:setString(roomlimitstr)

end 

function DKDeskView:cardsBackToOriginSeat(name)
    local positionName = self.MainPanel:getChildByName(name)
    local cardView = positionName:getChildByName('cards')
    cardView:setScale(0.65)
    for i = 1, self.CARD_COUNT do
        local card = cardView:getChildByName('card' .. i)
        local p = self.cardsOrgPos[name][i]
        card:setPosition(p)
    end
end

function DKDeskView:doVoiceAnimation()
  self:removeVoiceAnimation()

  local yyCountdown = self.MainPanel:getChildByName('yyCountdown')
  local pwr = yyCountdown:getChildByName('power')
  self.tvoice = yyCountdown
  self.tvoice.pwr = pwr

  if not self.tvoice.prg then
    local spr = cc.Sprite:create('views/xydesk/yuyin/prtframe.png')
    local img = yyCountdown:getChildByName('img')
    local imgSz = img:getContentSize()
    local progress = cc.ProgressTimer:create(spr)
    progress:setPercentage(100)
    progress:setPosition(imgSz.width / 2, imgSz.height / 2)
    progress:setName('progress')
    img:addChild(progress)
    self.tvoice.prg = progress
  end

  for i = 0, 3 do
    local delay1 = cc.DelayTime:create(0.1 * i)
    local fIn = cc.FadeIn:create(0.1)
    local delay2 = cc.DelayTime:create(0.1 * (3 - i))
    local fOut = cc.FadeOut:create(0.1)
    local sequence = cc.Sequence:create(delay1, fIn, delay2, fOut)
    local action = cc.RepeatForever:create(sequence)

    local rect = pwr:getChildByName(tostring(i))
    rect:runAction(action)
  end

  pwr:setVisible(true)

  yyCountdown:setVisible(true)
end

function DKDeskView:updateCountdownVoice(delay)
  self.tvoice.prg:setPercentage((20 - delay) / 20  * 100)
end

function DKDeskView:removeVoiceAnimation()
  if self.tvoice then
    local pwr = self.tvoice.pwr
    for i = 0, 3 do
        local rect = pwr:getChildByName(tostring(i))
        rect:stopAllActions()
        rect:setOpacity(0)
    end
    pwr:stopAllActions()
    pwr:setVisible(false)

    self.tvoice.prg:setPercentage(100)
    self.tvoice:setVisible(false)
  end
end

function DKDeskView:freshInviteFriend(bool)
    local invite = self.MainPanel:getChildByName('invite')
    invite:setVisible(bool)
   
end

function DKDeskView:copyRoomNum(content)
     if testluaj then
        local testluajobj = testluaj.new(self)
        local ok, ret1 = testluajobj.callandroidCopy(self,content)
        if ok then 
            tools.showRemind('已复制')
        end
    else
        tools.showRemind('未复制')
    end
end



function DKDeskView:somebodyVoice(uid, total)
    local info = self.desk:getPlayerInfo(uid)
    if not info then return end
    local name = info.viewKey

    local component = self.MainPanel:getChildByName(name)
    local yyIcon = component:getChildByName('yyIcon')
    local yyExt = yyIcon:getChildByName('yyExt')

    for i = 0, 2 do
        local delay1 = cc.DelayTime:create(0.1 * i)
        local fIn = cc.FadeIn:create(0.1)
        local delay2 = cc.DelayTime:create(0.1 * (2 - i))
        local fOut = cc.FadeOut:create(0.1)
        local sequence = cc.Sequence:create(delay1, fIn, delay2, fOut)
        local action = cc.RepeatForever:create(sequence)

        local rect = yyExt:getChildByName(tostring(i))
        rect:runAction(action)
    end

    yyIcon:setVisible(true)

    local delay = cc.DelayTime:create(total)
    local callback = function()
        yyIcon:setVisible(false)

        for i = 0, 2 do
            local rect = yyExt:getChildByName(tostring(i))
            rect:stopAllActions()
            rect:setOpacity(0)
        end
    end

    local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
    yyIcon:runAction(sequence)
end

function DKDeskView:kusoAction(start, dest, idx)
    local getPos = function(name)
        local seat = self.MainPanel:getChildByName(name)
        local avatar = seat:getChildByName('avatar')
        local frame = avatar:getChildByName('frame')
        local headimg = frame:getChildByName('headimg')

        local pos = frame:convertToWorldSpace(cc.p(headimg:getPosition()))

        return pos
    end
    
    local str = 'item'..idx
    local node = cc.CSLoader:createNode("views/animation/"..str..".csb") 
    node:setPosition(cc.p(getPos(start)))
    self:addChild(node)
    node:setVisible(true)

    local action = cc.CSLoader:createTimeline("views/animation/"..str..".csb")  
    action:gotoFrameAndPlay(0, 0, false)
    node:runAction(action)
    local callback = function()
        local action = cc.CSLoader:createTimeline("views/animation/"..str..".csb")   
        action:gotoFrameAndPlay(0, false)
        action:setFrameEventCallFunc(function(frame)
            local event = frame:getEvent();
            print("=========",event);
            if event == 'end' then
                node:removeSelf()
            elseif event == 'playSound' then
                SoundMng.playEft('sfx/' .. str .. '.mp3')
            end
        end)      
        node:runAction(action)

    end
 
    local delay = cc.DelayTime:create(0.2)
    local moveTo = cc.MoveTo:create(0.3, cc.p(getPos(dest)))

    local sequence = cc.Sequence:create(delay, moveTo, cc.CallFunc:create(callback))
    node:runAction(sequence)
end

--打枪表情
function DKDeskView:kusoAction_DaQiang(start, dest, num)
    local getPos = function(name)
        local seat = self.MainPanel:getChildByName(name)
        local avatar = seat:getChildByName('avatar')
        local frame = avatar:getChildByName('frame')
        local headimg = frame:getChildByName('headimg')

        local pos = frame:convertToWorldSpace(cc.p(headimg:getPosition()))

        return pos
    end
    
    local str = 'item15'
    local str1 = 'item15_1'
    local str2 = 'item15_2'

    local node = cc.CSLoader:createNode("views/animation/"..str..".csb") 
    node:setPosition(cc.p(getPos(start)))
    self:addChild(node)
    node:setVisible(true)

    local node1 = cc.CSLoader:createNode("views/animation/"..str1..".csb") 
    node1:setPosition(cc.p(getPos(dest)))
    self:addChild(node1)
    node1:setVisible(true)

    local node2 = cc.CSLoader:createNode("views/animation/"..str2..".csb") 
    node2:setPosition(cc.p(getPos(dest)))
    self:addChild(node2)
    node2:setVisible(true)

    local action = cc.CSLoader:createTimeline("views/animation/"..str..".csb")  
    action:gotoFrameAndPlay(0, 0, false)
    node:runAction(action)

    local action1 = cc.CSLoader:createTimeline("views/animation/"..str1..".csb")  
    action1:gotoFrameAndPlay(0, 0, false)
    node1:runAction(action1)

    local action2 = cc.CSLoader:createTimeline("views/animation/"..str2..".csb")  
    action2:gotoFrameAndPlay(0, 0, false)
    node2:runAction(action2)

    local callback = function(str, action, node)
        local action = cc.CSLoader:createTimeline("views/animation/"..str..".csb")   
        action:gotoFrameAndPlay(0, false)
        action:setFrameEventCallFunc(function(frame)
            local event = frame:getEvent();
            print("=========",event);
            if event == 'end' then
                node:removeSelf()
            elseif event == 'playSound' then
                SoundMng.playEft('sfx/' .. str .. '.mp3')
                node:setVisible(true)    
            end
        end)      
        node:runAction(action)

    end
    
    local delay = cc.DelayTime:create(0.2)

    local moveTo = cc.MoveTo:create(1.5, cc.p(getPos(dest)))

    -- local spawnAction = cc.Spawn:create(moveTo, cc.CallFunc:create(function()
    --     callback(str1, action1, node1)
    -- end))

    local sequence = cc.Sequence:create(delay, cc.CallFunc:create(function ()
        callback(str, action, node)
    end))
    local sequence1 = cc.Sequence:create(delay, cc.CallFunc:create(function()
        callback(str1, action1, node1)
    end))
    local sequence2 = cc.Sequence:create(delay, cc.CallFunc:create(function ()
        callback(str2, action2, node2)
    end))

    if num == 1 then
        node:runAction(sequence)
    else
        node:removeSelf()
    end
    if dest == 'right' or dest == 'rightmid' or dest == 'righttop' then
        node1:runAction(sequence1)
    else
        node1:setRotation(180)
        node1:runAction(sequence1)
    end
    node2:runAction(sequence2)
end


function DKDeskView:freshSummaryView(show, data)
    local view = self.MainPanel:getChildByName('summary')
    if not show then
        view:setVisible(false)
        return
    end

    if self.schedulerID2 then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID2)
    end

    view:setVisible(true)

    self:freshTrusteeshipLayer(false)
    self.playerViews.continue:setVisible(false)
    self.watcherLayout:setVisible(false)
    self:freshBettingBar(false)
    self:hideAllOutFrame()
    self:hideLastPlayer()

    local quit = view:getChildByName('quit')
    local summary = view:getChildByName('summary')

    local function onClickQuit()
        app:switch('LobbyController')
    end

    local function onClickSummary()
        app:switch('DKSummaryController', data)
    end

    quit:addClickEventListener(onClickQuit)
    summary:addClickEventListener(onClickSummary)
end

-- ============================ agent ============================

-- 玩家准备
function DKDeskView:freshReadyState(name, bool)
    local component = self.MainPanel:getChildByName(name)
    if not component then
        return
    end

    local avatar = component:getChildByName('avatar')
    local ready = avatar:getChildByName('ready')
    ready:setVisible(bool)
end

-- 玩家掉线
function DKDeskView:freshDropLine(name, bool)
    local component = self.MainPanel:getChildByName(name)
    local avatar = component:getChildByName('avatar')
    local dropLine = avatar:getChildByName('dropLine')
    dropLine:setVisible(bool)
    if bool then 
        self:freshEnterBackground(name,false)
    end
end

-- 玩家切换后台
function DKDeskView:freshEnterBackground(name, bool)
    local component = self.MainPanel:getChildByName(name)
    local avatar = component:getChildByName('avatar')
    local enterbackground = avatar:getChildByName('enterbackground')
    enterbackground:setVisible(bool)
end

-- 托管/取消托管
function DKDeskView:freshTrusteeshipIcon(name, bool)
    bool = bool or false
    local component = self.MainPanel:getChildByName(name)
    local avatar = component:getChildByName('avatar')
    local trusteeship = avatar:getChildByName('trusteeship')
    trusteeship:setVisible(bool)
end

function DKDeskView:freshTrusteeshipLayer(bool)
    self.trusteeshipLayer:setVisible(bool)
end

function DKDeskView:getTrusteeshipLayer()
    return self.trusteeshipLayer:isVisible()
end

function DKDeskView:getPlayerView(startUid)
    local viewKey = {}
    local i = 1
    if self.desk.tabPlayer then
        for uid, agent in pairs(self.desk.tabPlayer) do
            if agent:getInMatch() and uid ~= startUid then
                viewKey[i] = agent:getViewInfo()
                i = i + 1
            end
        end
    end
    return viewKey
end

-- ===========================声音=================================

-- 抢庄声音
function DKDeskView:playEftQz(qzNum, sex)
    if not qzNum then return end
    if not sex then return end

    local qiangStr = 'buqiang_'
    if qzNum and qzNum > 0 then
        qiangStr = 'qiangzhuang_'
    end
    local sexStr = '0'
    if sex and sex ~= 0 then
        sexStr = '1'
    end
    
    local soundPath = 'desk/' .. tostring(qiangStr .. sexStr .. '.mp3')
    SoundMng.playEftEx(soundPath)
end

-- 下注音效
function DKDeskView:playEftBet(bool)
    local soundPath = 'desk/coin_big.mp3'
    if bool then
        soundPath = 'desk/coins_fly.mp3'
    end
    SoundMng.playEftEx(soundPath)
end

function DKDeskView:playEftOption(viewKey, mode)
    if mode == 3 then return end
    local soundPath = 'dkdesk/avatar'
    local agent = self.desk:getPlayerInfo(nil, viewKey)
    local sex = 0
    if agent then
        sex = agent.player:getSex() or 0
    end
    soundPath = soundPath .. sex .. '_' .. mode .. '.mp3'
    SoundMng.playEftEx(soundPath)
end

-- 牌型
function DKDeskView:playEftCardType(sex, niuCnt, specialType, maxCard)
    local soundPath = 'compare/' .. tostring('f' .. sex .. "_dk" .. niuCnt .. '.mp3')
    if specialType > 0 then
        local idx = self.desk:getGameplayIdx()
        local wanfa = self.desk:getWanfa()
        local specific_specialType = GameLogic.getSpecialTypeByVal(idx, specialType, wanfa)
        soundPath = 'compare/' .. tostring('f'.. sex .."_dk" .. GameLogic.getSpecificType(maxCard, specific_specialType) .. '.mp3')
    end
    SoundMng.playEftEx(soundPath)
end

-- 输赢音效
function DKDeskView:playEftSummary(win)
    local soundPath = 'desk/lose.mp3'
    if win then
        soundPath = 'desk/win.mp3'
    end
    SoundMng.playEftEx(soundPath)
end

function DKDeskView:freshCanPutMoney(name,bool)
    local picture =  self.MainPanel:getChildByName(name):getChildByName('avatar'):getChildByName('CanPutMoney')
    local node = picture:getChildByName('CanPutMoneyAnimation')
    picture:setVisible(bool)
    if bool then
        self:startCsdAnimation(node,true)
    else
        self:stopCsdAnimation(node)
    end
end

function DKDeskView:freshWanfaLayer(bool)
    self.wanfaLayer:getChildByName('rule'):loadTexture('views/nysdesk/dk/rule.png')
    if bool then
        local deskInfo = self.desk:getDeskInfo()
        if deskInfo.wanfa and deskInfo.wanfa > 0 then
            self.wanfaLayer:getChildByName('rule'):loadTexture('views/nysdesk/dk/rule1.png')
        end
    end
    self.wanfaLayer:setVisible(bool)
end

function DKDeskView:startCsdAnimation(node, isRepeat)
    local action = cc.CSLoader:createTimeline("views/xydesk/putmoney/CanPutMoneyAnimation.csb")
    action:gotoFrameAndPlay(0,isRepeat)
    node:stopAllActions()
    node:runAction(action)
end
  
function DKDeskView:stopCsdAnimation(node)
    node:stopAllActions()
end

return DKDeskView
