local Scheduler = require('app.helpers.Scheduler')
local SoundMng = require('app.helpers.SoundMng')
local tools = require('app.helpers.tools')
local HeartbeatCheck = require('app.helpers.HeartbeatCheck')
local app = require("app.App"):instance() 
local GameLogic = require('app.libs.sangong.SGGameLogic')

local testluaj = nil
if device.platform == 'android' then
    testluaj = require('app.models.luajTest')--引入luajTest类
end

local SUIT_UTF8_LENGTH = 3

local SGDeskView = {}

function SGDeskView:initialize(ctrl) -- luacheck: ignore
    --节点事件
    self:enableNodeEvents()
    
    --心跳包模块
    self.heartbeatCheck = HeartbeatCheck()

    if self.ui then
        self.ui:removeFromParent()
        self.ui = nil
    end

    local View = require('mvc.View')
    local desk = ctrl.desk
    if desk and desk:getPeopleSelectIdx() == 2 then
        print('八人明牌模式')
        self.ui = View.loadUI('views/SGDeskView2.csb')
        self:addChild(self.ui)
    elseif desk:getPeopleSelectIdx() == 3 then
        self.ui = View.loadUI('views/SGDeskView3.csb')
        self:addChild(self.ui)
    else
        self.ui = View.loadUI('views/SGDeskView.csb')
        self:addChild(self.ui)
    end

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

    self.viewKey = {
        'bottom',
        'left',
        'lefttop',
        'top',
        'righttop',
        'right',
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

function SGDeskView:reloadState(toState)
    -- if self.state and self['onOut' .. self.state] then
    --     self['onOut' .. self.state](self)
    -- end
    self.next = toState
    self.state = toState
end

function SGDeskView:checkState()
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

function SGDeskView:setState(state)
    print(string.format('setState %s', self.state))
    self.next = state
    self:checkState()
end

function SGDeskView:updateState(dt)
    if self.state and self['onUpdate' .. self.state] then
        self['onUpdate' .. self.state](self, dt)
    end
end

function SGDeskView:onMessageState(msg)
    if self.state and self['onMessage' .. self.state] then
        self['onMessage' .. self.state](self, msg)
    end
end

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- state: Ready
function SGDeskView:onEnterReady(curState)
    local desk = self.desk
    
    self:showlastcard()
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

function SGDeskView:onOutReady(curState)
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
    -- 隐藏所有 玩家头像的准备
    self:freshAllReady(false)
    -- 隐藏所有 玩家的标记牌
    self:hideAllLastCard()
end

function SGDeskView:onUpdateReady(dt)
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
            self:freshWatcherBtn(true) -- 显示坐下按钮
        end
    end
end


function SGDeskView:onMessageReady(msg)
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
        if viewKey == 'bottom' then
            self:freshTipText('等待其他玩家准备')
            self:freshPrepareBtn(false)
            self:freshContinue(false)
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
        }
        if retCode and retCode ~= 0 then
            tools.showRemind(textTab[retCode])
        end
        self:freshWatcherBtn(false)
    else
        self:onMessagePlaying(msg)
    end
end

function SGDeskView:onReloadReady(curState)
    if self.desk.tabPlayer then 
        for uid, agent in pairs(self.desk.tabPlayer) do
            local viewKey, viewPos = agent:getViewInfo()
            self:freshReadyState(viewKey, agent:isReady())
        end
    end
    self:reloadState('Ready')
    self:onEnterReady()
end

function SGDeskView:freshIsCoin()
    if not self.desk.tabBaseInfo then return end
    local deskInfo = self.desk.tabBaseInfo.deskInfo
    if not deskInfo then return end
    for key, val in pairs(self.viewKey) do
        local seat = self.MainPanel:getChildByName(val)
        local img = seat:getChildByName('avatar'):getChildByName('point'):getChildByName('img')
        img:setVisible(deskInfo.roomMode == 'bisai')
    end
end

function SGDeskView:freshWatcherSp(bShow)
    bShow = bShow or false
    self.watcherStatusSp:setVisible(bShow)
end

function SGDeskView:freshWatcherBtn(bShow)
    bShow = bShow or false
    self.watcherSitdownBtn:setVisible(bShow)
    self.playerViews.msg:setVisible(not bShow)
    self.playerViews.voice:setVisible(not bShow)
end

function SGDeskView:onResponseSitdown(msg)
    local retCode = msg.errCode
    local textTab = {
        [1] = "没有足够的座位",
        [2] = "您已经坐下了",
        [3] = "本房间为AA模式, 您的房卡不足",
        [4] = "您暂时不能加入该牛友群的游戏, 详情请联系该群管理员",
        [5] = "本房间开启了游戏途中禁止加入功能",
        [6] = "您的信誉值不足",
        [7] = "管理员不能进行游戏",
    }
    if retCode and retCode ~= 0 then
        tools.showRemind(textTab[retCode])
    else
        self:freshWatcherBtn(false)
    end
end

function SGDeskView:freshContinue(bool)
    local component = self.MainPanel:getChildByName('bottom')
    local continue = component:getChildByName('continue')
    continue:setVisible(bool)
end

function SGDeskView:freshPrepareBtn(bool)
	local btn = self.MainPanel:getChildByName('prepare')
    self.outerFrameBool = false
	btn:setVisible(bool)
end

function SGDeskView:freshBtnPos()
    local btnTab = {
        self.prepareBtn,
        self.startBtn,
        self.watcherSitdownBtn
    }
    local showCnt = 0
    for i, v in pairs(btnTab) do
        if v:isVisible() then
            showCnt = showCnt + 1
        end
    end
    if showCnt == 1 then
        self.startBtn:setPosition(self.tabBtnPos.middle)
        self.watcherSitdownBtn:setPosition(self.tabBtnPos.middle)
        self.prepareBtn:setPosition(self.tabBtnPos.middle)
    elseif showCnt == 2 then
        self.startBtn:setPosition(self.tabBtnPos.left)
        self.watcherSitdownBtn:setPosition(self.tabBtnPos.right)
        self.prepareBtn:setPosition(self.tabBtnPos.right)
    elseif showCnt == 0 then
        self.startBtn:setPosition(self.tabBtnPos.middle)
        self.watcherSitdownBtn:setPosition(self.tabBtnPos.middle)
        self.prepareBtn:setPosition(self.tabBtnPos.middle)
    end
end

function SGDeskView:freshGameStartBtn(show, enable)
	local btn = self.MainPanel:getChildByName('gameStart')
	btn:setVisible(show)
    btn:setEnabled(enable)
end


function SGDeskView:freshAllReady(bool)
    bool = bool or false
    for _, v in pairs(self.viewKey) do
        self:freshReadyState(v, bool)
    end
end 


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- state:StateStarting
function SGDeskView:onEnterStarting(curState)
    -- 重置座位界面
    for k,v in pairs(self.viewKey) do
        self:clearDesk(v)
    end
    self:freshRoomInfo(true)

    local gameplay = self.desk:getGameplayIdx()
    if gameplay == 1 or gameplay == 2 or gameplay == 9 then
        -- 刷新庄家
        local info = self.desk:getBankerInfo()
        if info then
            self:freshBanker(info.viewKey, true)
        end
    end

end

function SGDeskView:onOutStarting(curState)

end

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- state:Dealing
function SGDeskView:onEnterDealing(curState)
    
end

function SGDeskView:onOutDealing(curState)

end

function SGDeskView:onMessageDealing(msg)
    if msg.msgID == 'bettingActionEnd' then 
        self:showBettingActionEnd(msg.viewKey)
    end
end

function SGDeskView:onDealMsg(reload) -- virtual
    local deskInfo = self.desk:getDeskInfo()
    if GameLogic.isQzGame(deskInfo) then
        -- 抢庄模式
        if self.desk.tabPlayer then
            for uid, agent in pairs(self.desk.tabPlayer) do
                if agent:getInMatch() then
                    local viewKey = agent:getViewInfo()
                    local cardData = agent:getHandCardData()
                    if cardData then
                        self:freshCards(viewKey, false, cardData, 1, 2)
                        self:freshCards(viewKey, false, nil, 3, 3)
                    else
                        self:freshCards(viewKey, false, nil, 1, 3)
                    end
                    if not reload then
                        self:showCardsAction(viewKey, 1, 2)
                    else
                        self:freshCards(viewKey, true, cardData, 1, 2)
                    end
                end
            end
        end
    end

    if GameLogic.isSzGame(deskInfo) then
        -- 上庄模式
        if self.desk.tabPlayer then
            for uid, agent in pairs(self.desk.tabPlayer) do
                if agent:getInMatch() then
                    local viewKey = agent:getViewInfo()
                    local cardData = agent:getHandCardData()
                    if cardData then
                        -- self:freshCards(viewKey, false, cardData, 1, 3)
                        self:freshCards(viewKey, false, nil, 1, 3)
                    else
                        self:freshCards(viewKey, false, nil, 1, 3)
                    end
                    if not reload then
                        self:showCardsAction(viewKey, 1, 3)
                    else
                        self:freshCards(viewKey, true, cardData, 1, 3)
                    end
                end
            end
        end
    end
end

-- 隐藏所有扑克
function SGDeskView:freshAllCards()
    for k,v in pairs(self.viewKey) do
        self:freshCards(v, false, nil, 1, 3)
        if v == 'bottom' then
            self:freshMiniCards(false)
        end
    end
end

function SGDeskView:freshCards(name, show, data, head, tail, noTexture) -- virtual
    show = show or false
    noTexture = noTexture or false

    -- 刷新扑克显示
    local component = self.MainPanel:getChildByName(name)
    if not component then return end
    if head > tail then return end
    local cards = component:getChildByName('cards')
 

    for i = 1, 3 do
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

function SGDeskView:showCardsAction(name, head, tail) -- virtual
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
        local sq = cc.Sequence:create(dtime, sc, dtime, cc.CallFunc:create(function ()
            if i == tail then
                self.emitter:emit("showCardsActionEnd",{msgID = 'showCardsActionEnd', name = name})
            end
        end))
        card:setScale(0.7)
        card:runAction(sq)
        
    end
end


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- state:QiangZhuang
function SGDeskView:onEnterQiangZhuang(curState)
    self:freshAutoFanpaiLayer(true)
    local tick = self.desk:getTick()
    self:freshTip(true , '操作抢庄：', tick)

    self:hideAllLastCard()

    -- 显示操作界面
    if self.desk:isMeInMatch() then
        local agent = self.desk:getMeAgent()
        if not agent:getQiang() then
            self:freshQiangZhuangBar(true, agent)
        else
            self:freshTipText('等待其他玩家抢庄：')
        end
    end
end

function SGDeskView:freshQiangZhuangBar(bool, agent)
    local gameplayIdx = self.desk:getGameplayIdx() 
    if gameplayIdx == 3 then
        local sqzbar = self.MainPanel:getChildByName('sqzbar')
        sqzbar:setVisible(bool)
    else
        local qzbar = self.MainPanel:getChildByName('qzbar')
        if not bool then
            qzbar:setVisible(false)
            return
        end
    
        local deskInfo = self.desk:getDeskInfo()
        local qzMax = deskInfo.qzMax
        local roomMode = deskInfo.roomMode
        local scoreOption = deskInfo.scoreOption
    
        qzbar:setScrollBarEnabled(false)
        local noBtn = qzbar:getChildByName('no')
        noBtn:setVisible(true)
        qzbar:getChildByName('one'):setVisible(false)
        qzbar:getChildByName('double'):setVisible(false)
        qzbar:getChildByName('triple'):setVisible(false)
        qzbar:getChildByName('four'):setVisible(false)
    
        local function show(qzMax)       
            local margin = qzbar:getItemsMargin()
            local cnt = qzMax + 1
            local itemWidth = noBtn:getContentSize().width * noBtn:getScaleX() * qzbar:getScaleX()
            local listWidth = (itemWidth*cnt) + (margin*(cnt-1))
            local posX = display.cx - (listWidth/2)
        
            qzbar:setPositionX(posX)
            qzbar:setVisible(true)
        end
    
        if roomMode and roomMode == 'bisai' then
            if agent then
                local groupScore = agent:getGroupScore()
                if groupScore < scoreOption.qiang then
                    show(0)
                    return 
                end
            end
        end
    
        if qzMax >= 1 then
            qzbar:getChildByName('one'):setVisible(true)
        end
        if qzMax >= 2 then
            qzbar:getChildByName('double'):setVisible(true)
        end
        if qzMax >= 3 then
            qzbar:getChildByName('triple'):setVisible(true)
        end
        if qzMax >= 4 then
            qzbar:getChildByName('four'):setVisible(true)
        end
    
        show(qzMax)
    end
end

function SGDeskView:onOutQiangZhuang(curState)
    -- 清除庄家动画相关界面
    self:freshTip(false)
    self:freshQiangZhuangBar(false)
    self:freshAllCanPutMoney(false)
    self:freshAutoFanpaiLayer(false)
end

function SGDeskView:onUpdateQiangZhuang(dt)

end

function SGDeskView:onReloadQiangZhuang(curState)
    local gameplay = self.desk.gameplay
    if not gameplay then return end

    local flagBanker = gameplay:getFlagFindBanker()
    if flagBanker then
        -- 抢庄结果
        self:showBankerActionEnd()
    else
        -- 抢庄过程
        if self.desk.tabPlayer then
            for uid, agent in pairs(self.desk.tabPlayer) do
                if agent:getInMatch() then
                    local viewKey = agent:getViewInfo()
                    local num = agent:getQiang()
                    if num then self:freshQZBet(viewKey, num, true) end
                end
            end
        end
    end
    
    --显示可推注提示
    self:freshAllCanPutMoney(true)
    
    self:reloadState('QiangZhuang')
    self:onEnterQiangZhuang()
end

function SGDeskView:onMessageQiangZhuang(msg)
    if msg.msgID == 'somebodyQiang' then
        -- 有人完成抢庄
        local name = msg.info.viewKey
        local num = msg.number
        if name == "bottom" then
            self:freshQiangZhuangBar(false)
            self:freshTipText('等待其他玩家抢庄：')
        end
        self:playEftQz(num, msg.info.player:getSex())
        self:freshQZBet(name, num, true)

    elseif msg.msgID == 'newBanker' then
        self:freshTip(false)
        self:freshQiangZhuangBar(false)
        local name = msg.info.viewKey
        self:freshAllQZBet()
        -- 播放抢庄动画
        self:showBankerAction(name, msg.number, msg.qiangPlayer)
        -- 隐藏可推注动画
        self:freshCanPutMoney(name,false)
    elseif msg.msgID == 'showBankerActionEnd' then
        self:showBankerActionEnd()
    elseif msg.msgID == 'CanPutMoneyPlayer' then
        -- 显示可推注动画
        for i = 1, msg.cnt do
            self:freshCanPutMoney(msg.viewKey[i],true)
        end
    end
end


-- 隐藏所有抢庄界面
function SGDeskView:freshAllQZBet()
    for _, v in pairs(self.viewKey) do
        self:freshQZBet(v, 0, false)
    end
end 


function SGDeskView:freshQZBet(name, num, bool)
    -- 在用户头像显示抢（不抢）
	local component = self.MainPanel:getChildByName(name)
	local avatar = component:getChildByName('avatar')
	
	local qzBet = avatar:getChildByName('qzBet')
	local qz = qzBet:getChildByName('qz')
    local bq = qzBet:getChildByName('bq')
	local path = 'views/xydesk/result/qiang/'

    bq:setVisible(false)
    qz:setVisible(false)	
	if num == 0 then
		bq:setVisible(true)
    else
        qz:loadTexture(path..num..'.png')
        qz:setVisible(true)
	end

	qzBet:setVisible(bool)
end 

-- 刷新庄家
function SGDeskView:freshBanker(name, bool, qzNum) --virtual
    bool = bool or false

    local function getOutFrame(name)
        local component = self.MainPanel:getChildByName(name)
        local avatar = component:getChildByName('avatar')
        local frame = avatar:getChildByName('frame')
        local outerFrame = frame:getChildByName('outerFrame')
        return outerFrame
    end

    local function getBankerIcon(name)
        local component = self.MainPanel:getChildByName(name)
        local avatar = component:getChildByName('avatar')
        local banker = avatar:getChildByName('banker')
        return banker
    end

    local function freshQZNum(bool, num)
        local component = self.MainPanel:getChildByName(name)
        local avatar = component:getChildByName('avatar')
        local numNode = avatar:getChildByName('qzNum')
        numNode:setVisible(bool)

        if not num or num == 0 then
            numNode:setVisible(false)
            return
        end
        local path = 'views/xydesk/result/bei/' .. num .. '.png'
        numNode:loadTexture(path)
    end

    getOutFrame(name):setVisible(bool)
    getBankerIcon(name):setVisible(bool)
    freshQZNum(bool, qzNum)
end

-- 隐藏所有庄家界面
function SGDeskView:freshAllBanker()
    for _, v in pairs(self.viewKey) do
        self:freshBanker(v, false)
    end
end

-- 隐藏所有可推注动画
function SGDeskView:freshAllCanPutMoney(show)
    for _, v in pairs(self.viewKey) do
        self:freshCanPutMoney(v, false)
    end
    if show then
        if self.desk.tabPlayer then
            for uid, agent in pairs(self.desk.tabPlayer) do
                if agent:getCanPutMoney() then
                    local viewKey = agent:getViewInfo()
                    self:freshCanPutMoney(viewKey, true)
                end
            end
        end        
    end
end


function SGDeskView:showBankerAction(viewKey, qzNum, qiangData)

    if not self.updateBankerFunc then
        self.updateBankerFunc = self:initShowBankerAction(viewKey, qzNum, qiangData)
        return
    end

    -- 停止当前动画
    self.updateBankerFunc(self, nil, true)
    self.updateBankerFunc = nil

    self.updateBankerFunc = self:initShowBankerAction(viewKey, qzNum, qiangData)
end

function SGDeskView:stopBankerAction()
    if self.updateBankerFunc then
        self.updateBankerFunc(self, nil, true)
        self.updateBankerFunc = nil
    end
end

function SGDeskView:onUpdateBanker(dt)
    if self.updateBankerFunc then
        self.updateBankerFunc(self, dt)
    end
end

-- 显示抢庄动画
function SGDeskView:initShowBankerAction(viewKey, qzNum, qiangData)
    local gameplay = self.desk:getGameplayIdx()

    local rank = {}
    local idx = 1
    for k,v in pairs(self.viewKey) do
        rank[v] = k
    end
    -- local rank = {
    --     ['bottom'] = 6,
    --     ['left'] = 5,
    --     ['lefttop'] = 4,
    --     ['top'] = 3,
    --     ['righttop'] = 2,
    --     ['right'] = 1,
    -- }
    -- if gameplay == 8 then
    --     rank = {
    --         ['bottom'] = 6,
    --         ['left'] = 5,
    --         ['lefttop'] = 4,
    --         ['top'] = 3,
    --         ['righttop'] = 2,
    --         ['right'] = 1,
    --     }
    -- end

    local data =  {}
    local this = self
    local mulNum = qzNum or 0
    local function resetData()
        data = {
            run = false,        -- 运行标志
            players = {},       -- 所有的抢庄者 {"left", "bottom"}
            time = 1.9,         -- p1动画时间    
            time1 = 0.9,          -- p2动画时间 
            time2 = 3,          -- 动画总时间  
            interval = 0.08,    -- 切换间隔

            tick1 = 0,          -- 切换tick
            tick2 = 0,          -- 总时间tick
            tick3 = 0,
            tick4 = 0,      --ios播放抢庄声音间隔
            lanxuCnt = 0,

            idx = 1,            -- 切换IDX    
            bankerSeat = "",    -- 庄家位置
            pervIdx = 1,
            mulNum = mulNum,
            gameplay = gameplay,
            status = 1,
            cnt = 1,
        }
        return data
    end

    local function getOutFrame(name)
        local component = this.MainPanel:getChildByName(name)
        local avatar = component:getChildByName('avatar')
        local frame = avatar:getChildByName('frame')
        local outerFrame = frame:getChildByName('outerFrame')
        return outerFrame
    end

    local function getBankerIcon(name)
        local component = this.MainPanel:getChildByName(name)
        local avatar = component:getChildByName('avatar')
        local banker = avatar:getChildByName('banker')
        return banker
    end

    local function freshBlinkAction(name, show)
        local component = this.MainPanel:getChildByName(name)
        local avatar = component:getChildByName('avatar')
        local node = avatar:getChildByName('bankAnimation')
        node:setVisible(show)
        if show then
            local action = cc.CSLoader:createTimeline("views/animation/Zhuangjia1.csb")
            action:gotoFrameAndPlay(0, false)
            node:stopAllActions()
            node:runAction(action)
        end
    end

    local function freshBankerAction(name, show)
        local component = this.MainPanel:getChildByName(name)
        local avatar = component:getChildByName('avatar')
        local node = avatar:getChildByName('qzAnimation')
        node:setVisible(show)
        if show then
            local action = cc.CSLoader:createTimeline("views/animation/Zhuangjia.csb")
            action:gotoFrameAndPlay(0, false)
            node:stopAllActions()
            node:runAction(action)
        end
    end

    local function freshIconAction(name, show)
        local component = this.MainPanel:getChildByName(name)
        local avatar = component:getChildByName('avatar')
        local node = avatar:getChildByName('bankAnimation1')
        node:setVisible(show)
        if show then
            local action = cc.CSLoader:createTimeline("views/animation/Zhuangjia2.csb")
            action:gotoFrameAndPlay(0, false)
            node:stopAllActions()
            node:runAction(action)
        end
    end

    data = resetData()
    data.players = qiangData
    data.idx = 1
    data.bankerSeat = viewKey
    data.run = true

    local interval2 = data.interval * 3

    if data.players and #data.players == 0 then
        -- 没人抢庄, 加入所有玩家
        data.players = {}
        if self.desk.tabPlayer then
            for uid, agent in pairs(self.desk.tabPlayer) do
                if agent:getInMatch() then
                    local viewKey = agent:getViewInfo()
                    table.insert(data.players, viewKey)
                end
            end
        end
        table.sort(data.players, function(a,b)
            if rank[a] and rank[b] then
                return rank[a] > rank[b]
            end
        end)

    elseif data.players and #data.players == 1 then
        -- 一人抢庄
        data.time = 0.1
        
    elseif data.players and #data.players > 1  then
        -- 多人抢庄 排序
        -- table.sort(data.players, function(a,b)
        --     if a.number and b.number then
        --         return a.number > b.number
        --     end
        -- end)

        -- local max = data.players[1].number
        -- for i = #data.players, 1, -1 do
        --     if max ~= data.players[i].number then
        --         table.remove( data.players, i)
        --     end
        -- end

        table.sort(data.players, function(a,b)
            if rank[a] and rank[b] then
                return rank[a] > rank[b]
            end
        end)

        -- if #data.players == 1 then
        --     data.time = 0.1
        -- end
    end
    
    return function(this, dt, stopFlag)
        -- 更新函数
        dt = dt or 0.01
        local function showBanker()
            this.emitter:emit('showBankerActionEnd', 
            {
                msgID = 'showBankerActionEnd',
                viewKey = data.bankerSeat, 
                qzNum = data.mulNum,
            })
            resetData()
        end

        if data.run then
            if stopFlag then
                resetData()
                return data.run
            end

            if dt then
                data.tick1 = data.tick1 + dt
                data.tick2 = data.tick2 + dt
            end

            -- p1 播放声音
            if device.platform == 'ios' and data.status == 1 then
                data.tick4 = data.tick4 + dt
                if data.tick4 >= 1 then
                    SoundMng.playEft('desk/random_banker_lianxu.mp3')
                    data.tick4 = 0
                end
            end

            -- p1
            if data.status == 1 and data.tick1 > data.interval then
                -- 轮换
                local cur = data.players[data.idx]
                local perv = data.players[data.pervIdx]
                if perv then
                    getOutFrame(perv):setVisible(false)
                    getBankerIcon(perv):setVisible(false)
                    freshBlinkAction(perv, false)
                end
                if cur then
                    data.pervIdx = data.idx
                    getOutFrame(cur):setVisible(false)
                    getBankerIcon(cur):setVisible(false)
                    freshBlinkAction(cur, true)
                    if device.platform ~= 'ios' then
                        SoundMng.playEft('desk/random_banker.mp3')
                    end
                end
                local idx = data.idx + 1
                data.idx = (idx > #data.players) and 1 or idx
                data.tick1 = 0
                
                -- 时间到
                if data.tick2 > data.time then
                    data.interval = interval2
                    if cur and cur == data.bankerSeat then
                        getOutFrame(cur):setVisible(false)
                        getBankerIcon(cur):setVisible(false)
                        freshBankerAction(cur,true)
                        data.status = 2
                    end
                end
            end
            -- p2
            if data.status == 2 then
                data.tick3 = data.tick3 + dt
                if data.tick1 > data.interval then
                    data.cnt = data.cnt + 1
                    local bShow = data.cnt%2 == 1
                    -- getOutFrame(data.bankerSeat):setVisible(bShow)
                    -- getBankerIcon(data.bankerSeat):setVisible(bShow)
                    data.tick1 = 0
                end
                if data.tick3 > data.time1 then
                    freshIconAction(data.bankerSeat, true)
                    getOutFrame(data.bankerSeat):setVisible(true)
                    getBankerIcon(data.bankerSeat):setVisible(true)
                    showBanker()
                    return data.run
                end
            end
            -- time out
            if data.tick2 > data.time2 then
                showBanker()
                resetData()
                return data.run
            end
        end
        return data.run
    end
end

function SGDeskView:showBankerActionEnd()
    local banker = self.desk:getBankerInfo()
    if not banker then return end

    local qzNum = banker.player:getQiang()
    self:freshAllBanker()
    self:freshBanker(banker.viewKey, true, qzNum)
end

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- state:PutMoney
function SGDeskView:onEnterPutMoney(curState)
    local tick = self.desk:getTick()

    self:freshAutoFanpaiLayer(true)
    --显示可推注提示
    self:freshAllCanPutMoney(true)

    self:hideAllLastCard()

    local bankerInfo = self.desk:getBankerInfo()
    if bankerInfo and bankerInfo.viewKey == 'bottom' then
        self:freshTip(true , '等待其他玩家下注：', tick)
    else
        self:freshTip(true , '选择下注：', tick)
    end
end


function SGDeskView:onOutPutMoney(curState)
    -- 清除庄家动画相关界面
    self:freshBettingBar(false)
    self:freshTip(false)
    self:freshAllCanPutMoney(false)
    self:freshAutoFanpaiLayer(false)
end

function SGDeskView:onUpdatePutMoney(dt)
    -- > next state
end

function SGDeskView:onReloadPutMoney(curState)
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

    -- 操作界面
    if self.desk:isMeInMatch() then
        local agent = self.desk:getMeAgent()
        if not agent:getPutscore() then
            local putOpt = agent:getThisPutOpt()
            if putOpt then
                self:freshBettingBar(true, putOpt)
            end
        end
    end

    self:reloadState('PutMoney')
    self:onEnterPutMoney()
end

function SGDeskView:onMessagePutMoney(msg)
    if msg.msgID == 'somebodyPut' then
        local viewKey = msg.info.viewKey
        if viewKey == "bottom" then
            self:freshBettingBar(false)
            self:freshTipText('等待其他玩家下注：')
        end
        self:showBettingAction(viewKey, msg.tuizhuflag)
        
        -- 隐藏已推注的人的可推注动画
        self:freshCanPutMoney(viewKey,false)

    elseif msg.msgID == 'putMoney' then  
        local putInfo = msg.putInfo  
        self:freshBettingBar(true, putInfo)

    elseif msg.msgID == 'showBankerActionEnd' then
        self:showBankerActionEnd()
        
    elseif msg.msgID == 'bettingActionEnd' then 
        self:showBettingActionEnd(msg.viewKey)
    end
end

-- 下注按钮界面
function SGDeskView:freshBettingBar(bool, tabPutInfo)
    local component = self.MainPanel:getChildByName('bottom')
    local betting = component:getChildByName('betting')
    betting:setScrollBarEnabled(false)

    local function hideAllBtn()
        for i = 1, 4 do
            local btn = betting:getChildByName(tostring(i))
            btn:setVisible(false)
        end
    end

    hideAllBtn()

    if bool then
        if tabPutInfo then
            local len = #tabPutInfo
            
            for k, v in pairs(tabPutInfo) do
                local btn = betting:getChildByName(tostring(k))
                btn:setVisible(true)
                local val = btn:getChildByName('val')
                val:setString(v)

                btn:addClickEventListener(function()
                    SoundMng.playEft('btn_click.mp3')
                    self.emitter:emit('clickBet', v)
                end)
            end
            
            local item = betting:getChildByName(tostring(1))
            local margin = betting:getItemsMargin()
            local cnt = len
            local itemWidth = item:getContentSize().width * item:getScaleX() * betting:getScaleX()
            local listWidth = (itemWidth*cnt) + (margin*(cnt-1))
            local posX = display.cx - (listWidth/2)
            betting:setPositionX(posX)
        end
    end

    betting:setVisible(bool)
end

-- 显示下注动画
function SGDeskView:showBettingAction(name, bool)
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
        local sprite = cc.Sprite:create('views/xydesk/3x.png')
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

function SGDeskView:showBettingActionEnd(name)
    local info = self.desk:getPlayerInfo(nil, name)
    if not info then return end

    local banker = self.desk:getBankerInfo()
    local gameplay = self.desk:getGameplayIdx()
    if banker and gameplay ~= 5 then
        if banker.viewKey == info.viewKey then
            self:freshBetting(name, false)
            return
        end
    end

    local putScore = info.player:getPutscore()
    if putScore then
        self:freshBetting(name, true, putScore)
    else
        self:freshBetting(name, false)
    end
end

-- 刷新下注界面
function SGDeskView:freshBetting(name, bool, value)
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

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- state:PutLimit
function SGDeskView:onEnterPutLimit(curState)
    local tick = self.desk:getTick()

    self:freshAutoFanpaiLayer(true)

    self:hideAllLastCard()

    self:freshTip(true , '选择下注：', tick)
end


function SGDeskView:onOutPutLimit(curState)
    -- 清除庄家动画相关界面
    self:freshBettingBar_DCX(false)
    self:freshTip(false)
    self:freshAutoFanpaiLayer(false)
end

function SGDeskView:onUpdatePutLimit(dt)
    -- > next state
end

function SGDeskView:onReloadPutLimit(curState)
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

    -- 操作界面
    if self.desk:isMeInMatch() then
        local agent = self.desk:getMeAgent()
        if not agent:getPutscore() then
            local putOpt = agent:getThisPutOpt()
            if putOpt then
                self:freshBettingBar_DCX(true, putOpt)
            end
        end
    end

    self:reloadState('PutLimit')
    self:onEnterPutLimit()
end

function SGDeskView:onMessagePutLimit(msg)
    if msg.msgID == 'somebodyPutLimit' then
        local viewKey = msg.info.viewKey
        if viewKey == "bottom" then
            self:freshBettingBar_DCX(false)
            self:freshTipText('等待其他玩家下注：')
        end
        self:showBettingAction(viewKey, msg.tuizhuflag)

    elseif msg.msgID == 'putLimit' then  
        local putInfo = msg.putInfo  
        self:freshBettingBar_DCX(true, putInfo)

    elseif msg.msgID == 'showBankerActionEnd' then
        self:showBankerActionEnd()
        
    elseif msg.msgID == 'bettingActionEnd' then 
        self:showBettingActionEnd(msg.viewKey)
    end
end

-- 下注按钮界面
function SGDeskView:freshBettingBar_DCX(bool, tabPutInfo)
    local component = self.MainPanel:getChildByName('bottom')
    local slider = component:getChildByName('slider')

    if bool and tabPutInfo then
        self.minScore = tabPutInfo[1]
        self.maxScore = tabPutInfo[2]
        local per = self.bettingSlider:getPercent()
        self:freshBettingSlider(per)
    end

    slider:setVisible(bool)
end

function SGDeskView:freshBettingSlider(percent, value)
    if percent then
        self.bettingSlider:setPercent(percent)
        if not self.maxScore or not self.minScore then return end
        local qujian = self.maxScore - self.minScore
        local score = self.minScore + math.floor(qujian * percent / 100)
        self.bettingSliderText:setString('' .. score)
    end
    if value then
        if not self.maxScore or not self.minScore then return end
        local qujian = self.maxScore - self.minScore
        if value < self.minScore then value = self.minScore end
        if value > self.maxScore then value = self.maxScore end
        self.bettingSliderText:setString('' .. value)
        local per = (value - self.minScore) * 100 / qujian
        self.bettingSlider:setPercent(per)
    end
end

function SGDeskView:getBettingSliderText()
    return tonumber(self.bettingSliderText:getString())
end

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- state:Playing
function SGDeskView:onEnterPlaying(reload)
    local deskInfo = self.desk:getDeskInfo()
    
    self:freshAutoFanpaiLayer(false)
    if self.desk.tabPlayer and (not reload) then
        for uid, agent in pairs(self.desk.tabPlayer) do
            if agent:getInMatch() then
                local viewKey = agent:getViewInfo()
                local cardData = agent:getHandCardData()
                -- 显示搓牌中
                self:freshSeatCuoPai(viewKey, false)

                if GameLogic.isQzGame(deskInfo) then
                    -- 发最后一张牌(牌背)
                    self:freshCards(viewKey, false, nil, 3, 3)
                    self:showCardsAction(viewKey, 3, 3)
                end
            end
        end
    end

    local tick = self.desk:getTick()
    self:freshTip(true , '查看手牌：', tick)

    -- 操作界面
    if self.desk:isMeInMatch() then
        local agent = self.desk:getMeAgent()
        if agent:getChoosed() then
            -- 已经亮牌
            self:freshTipText('等待其他玩家亮牌')
        else
            if reload then
                self:onClickTips()
                self:freshOpBtns(false, true)
            else
                local enableCuopai = GameLogic.isEnableCuoPai(deskInfo)
                self:freshCuoButton(enableCuopai)
                self:freshOpBtns(true, false)
            end
        end
    end
end

function SGDeskView:onOutPlaying(curState)
    self:freshAllSeatCuoPai()
    self:freshOpBtns(false, false)
    self:freshCuoPaiDisplay(false)
    self:freshAutoFanpaiLayer(false)
    self:hideAllLastCard()
end

function SGDeskView:onUpdatePlaying(dt)

end

function SGDeskView:onReloadPlaying(curState)

    -- 押注过程
    if self.desk.tabPlayer then
        for uid, agent in pairs(self.desk.tabPlayer) do
            if agent:getInMatch() then
                local viewKey = agent:getViewInfo()
                self:showBettingActionEnd(viewKey)
            end
        end
    end

    -- 刷新扑克
    local isDeal = self.desk.gameplay:getFlagDealAllPlayer()
    if isDeal then
        if self.desk.tabPlayer then
            for uid, agent in pairs(self.desk.tabPlayer) do
                if agent:getInMatch() then
                    local choose = agent:getChoosed()
                    local viewKey = agent:getViewInfo()
                    
                    self:freshSeatCuoPai(viewKey, (not choose))

                    local cardsData = agent:getSummaryCardData()
                    if choose and cardsData then
                        self:freshCards(viewKey, true, cardsData, 1, 3)
                        self:onSomeBodyChoosed(viewKey, true)
                    else
                        self:freshCards(viewKey, true, nil, 1, 3)
                    end
                end
            end
        end
    end

    self:reloadState('Playing')
    self:onEnterPlaying(true)
    self:showlastcard()
end

function SGDeskView:onMessagePlaying(msg)
    if msg.msgID == 'someBodyChoosed' then
        local info = msg.info
        local agent = info.player
        local viewKey = info.viewKey
        local hasCardData = msg.hasCardData
        self:onSomeBodyChoosed(viewKey)

    elseif msg.msgID == 'summary' then
        self:freshTip(false)
        self.flagEftSummary = false
        self:onSummary()

    elseif msg.msgID == 'showCoinFlayActionEnd' then
        self:showCoinFlayActionEnd(msg.start, msg.dest)

    elseif msg.msgID == 'showCardsActionEnd' then
        local autofanpai = false
        if self.desk.tabPlayer then
            for uid, agent in pairs(self.desk.tabPlayer) do
                local viewKey, viewPos = agent:getViewInfo()
                if viewKey == 'bottom' then
                    local flag = agent:getautoOperation()
                    if flag then
                        autofanpai = true
                    end
                    break
                end
            end
        end
        if autofanpai and msg.name == 'bottom' and self.desk:isMePlayer() then
            self:onClickTips()
            self:freshOpBtns(false, true)
        end

    elseif msg.msgID == 'clickFanPai' then
        -- 点击翻牌
        self:onFanPai()

    elseif msg.msgID == 'clickCuoPai' then
        if not self.desk:isMeInMatch() then return end
        local agent = self.desk:getMeAgent()
        local handCardData = agent:getHandCardData()
        self:freshCards('bottom', false, nil, 1, 3, true)
        self:freshCuoPaiDisplay(true, handCardData)
        
    elseif msg.msgID == 'cpBack' then
        -- 搓牌回调
        self:onFanPai()

    elseif msg.msgID == 'clickTips' then
        -- 点击提示
        self:onClickTips()

    elseif msg.msgID == 'showBankerActionEnd' then
        self:showBankerActionEnd()

    elseif msg.msgID == 'bettingActionEnd' then 
        self:showBettingActionEnd(msg.viewKey)
    end
end

function SGDeskView:onSomeBodyChoosed(viewKey, reload)
    local info = self.desk:getPlayerInfo(nil, viewKey)
    local agent = info.player
    local viewKey = info.viewKey
    local reload = reload or false
    local lastcard = agent:getLastCard()

    if viewKey == 'bottom' then
        self:freshOpBtns(false, false)
        self:freshTipText('等待其他玩家亮牌')
    end
    
    local isMeInMatch = self.desk:isMeInMatch()
    local gameplayIdx = self.desk:getGameplayIdx()
    local isMeBanker = false

    local bankerInfo = self.desk:getBankerInfo()
    local bankerViewKey = nil
    if bankerInfo then
        bankerViewKey = bankerInfo.viewKey
        isMeBanker = (bankerViewKey == 'bottom')
    end
    

    local function showCard()
        -- 显示结果
        local cards = agent:getSummaryCardData()
        if not cards then return end
        local choose, cnt, spType = agent:getChoosed()
        local gCardsData = GameLogic.setLaiziData(cards, spType)
        local sex = agent:getSex()
        if viewKey == 'bottom' then
            self:freshCards(viewKey, false, gCardsData, 1, 3)
            self:freshMiniCards(true, gCardsData)
        else
            self:freshCards(viewKey, true, gCardsData, 1, 3)
        end

        self:freshSeatCardType(viewKey, true, false, cnt, spType)
        self:freshSeatMul(viewKey, true, cnt, spType)
        self:freshSeatFireworks(viewKey,true, cnt, spType)
        if not reload then
            self:playEftCardType(sex,cnt,spType)
        end

        if lastcard then
            for i, v in ipairs(gCardsData) do
                if v == lastcard[1] or GameLogic.card_rank_out(v) == lastcard[1] then
                    self:freshLastCard(viewKey, i, true)
                end
            end
        end
    end

    local function shwoWcIcon()
        -- 显示完成
        self:freshSeatCardType(viewKey, true, true)
        self:freshSeatMul(viewKey, false)
        self:freshSeatFireworks(viewKey, false)
    end

    if isMeInMatch and viewKey == 'bottom' then
        -- 亮牌人是自己 显示结果
        showCard()
        self:freshAutoFanpaiLayer(true)
        return
    end

    -- if gameplayIdx == 5 then
    --     -- 通比不显示结果
    --     shwoWcIcon()
    --     return
    -- end

    if bankerViewKey and bankerViewKey == viewKey then
        -- 亮牌人是庄家
        shwoWcIcon()
        return
    else
        -- 其他情况 显示都显示结果
        showCard()
        return
    end

end

function SGDeskView:onClickTips()
    if not self.desk:isMeInMatch() then return end
    local agent = self.desk:getMeAgent()
    local handCardData = agent:getHandCardData()
    local deskInfo =  self.desk:getDeskInfo()
    local setting = deskInfo.special
    local gameplay = deskInfo.gameplay
    local cnt, sptype, spKey = GameLogic.getLocalCardType(handCardData, gameplay, setting)
    local gCardsData = GameLogic.sortCards(handCardData)
    local lastcard = agent:getLastCard()
    self:freshCards('bottom', false, gCardsData, 1, 3)
    self:freshMiniCards(true, gCardsData)
    self:freshSeatCardType('bottom', true, false, cnt, sptype)
    self:freshSeatMul('bottom',false)
    self:freshSeatFireworks('bottom', false)

    if lastcard then
        for i, v in ipairs(gCardsData) do
            if v == lastcard[1] or GameLogic.card_rank_out(v) == lastcard[1] then
                self:freshLastCard('bottom', i, true)
            end
        end
    end
end

function SGDeskView:onFanPai()
    if not self.desk:isMeInMatch() then return end
    local agent = self.desk:getMeAgent()
    if not agent then return end
    local handCardData = agent:getHandCardData()
    local component = self.MainPanel:getChildByName('bottom')
    local cards = component:getChildByName('cards_mini')
    if not cards:isVisible() then
        self:freshCards('bottom', true, handCardData, 1, 3)
    end

    local lastcard = agent:getLastCard()
    if lastcard then
        for i, v in ipairs(handCardData) do
            if v == lastcard[1] or GameLogic.card_rank_out(v) == lastcard[1] then
                self:freshLastCard('bottom', i, true)
            end
        end
    end
    self:freshOpBtns(false, true)
end

function SGDeskView:showCoinFlayActionEnd(start, dest)
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
        if winner.viewKey == 'bottom' then
            self.playEftSummary(true)
            self.flagEftSummary = true
        elseif loser.viewKey == 'bottom' then
            self.playEftSummary(false)
            self.flagEftSummary = true
        end
    end
end

-- 隐藏所有单局得分界面
function SGDeskView:freshAllOneRoundScore()
    for k,v in pairs(self.viewKey) do
        self:freshOneRoundScore(v, false)
    end
end

function SGDeskView:onSummary() -- virtual
    local function showCard(agent)
        -- 显示结果
        local viewKey = agent:getViewInfo()
        local cards = agent:getHandCardData()
        local choose, cnt, spType = agent:getChoosed()
        if not cards then 
            cards = agent:getSummaryCardData() 
        end
        local gCardsData = GameLogic.setLaiziData(cards, spType)
        local lastcard = agent:getLastCard()
        local sex = agent:getSex()
        if viewKey == 'bottom' then
            self:freshCards(viewKey, false, gCardsData, 1, 3)
            self:freshMiniCards(true, gCardsData)
        else
            self:freshCards(viewKey, true, gCardsData, 1, 3)
        end

        self:freshSeatCardType(viewKey, true, false, cnt, spType)
        self:freshSeatMul(viewKey, true, cnt, spType)
        self:playEftCardType(sex,cnt,spType)
        self:freshSeatFireworks(viewKey,true, cnt, spType)

        if lastcard then
            for i, v in ipairs(gCardsData) do
                if v == lastcard[1] or GameLogic.card_rank_out(v) == lastcard[1] then
                    self:freshLastCard(viewKey, i, true)
                end
            end
        end
    end


    local tabScoreData = {}

    if not self.desk.tabPlayer then return end
       
    for uid, agent in pairs(self.desk.tabPlayer) do
        if agent:getInMatch() then
            -- 显示扑克
            local viewKey = agent:getViewInfo()
            local score = agent:getScore()
            table.insert(tabScoreData, {viewKey, score})
            showCard(agent)
        end
    end

    -- 组织金币飞行动画
    local bankerInfo = self.desk:getBankerInfo()
    local bankerViewKey = nil
    local bankerScore = nil
    if bankerInfo then
        bankerViewKey = bankerInfo.viewKey
        bankerScore = bankerInfo.player:getScore()
    end

    local gameplayIdx = self.desk:getGameplayIdx()
    local actionDelay = 0
    local deskInfo = self.desk:getDeskInfo()
    local gameplay = deskInfo.gameplay

    if gameplay == 5 then -- 通比牛牛
        -- 排序小到大
        table.sort( tabScoreData, function(a,b)
            return (a[2] < b[2])
        end)
        for _, s1 in ipairs(tabScoreData) do
            for _, s2 in ipairs(tabScoreData) do
                if s1[2] < s2[2] then
                    self:showCoinFlayAction(s1[1], s2[1], actionDelay)
                end
            end
            actionDelay = actionDelay + 0.3
        end
    else
        -- 其他模式
        if bankerScore >= 0 then
            actionDelay = 0.5
        end
      
        for _, s1 in ipairs(tabScoreData) do
            if s1[1] ~= bankerViewKey then
                if s1[2] < 0 then
                    self:showCoinFlayAction(s1[1], bankerViewKey, 0)
                else
                    self:showCoinFlayAction(bankerViewKey, s1[1], actionDelay)
                end
            end
        end
    end

end

-- 金币飞行动画
function SGDeskView:showCoinFlayAction(start, dest, delay)
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
        local sprite = cc.Sprite:create('views/xydesk/3x.png')
        sprite:setVisible(false)
        sprite:setScale(1.2)
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

function SGDeskView:showWinAction(name)
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
function SGDeskView:freshAllRoundScore(name, score, groupScore)
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
function SGDeskView:freshOneRoundScore(name, bool, score)
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
        zheng:getChildByName('sign'):setVisible(true)
        zheng:setVisible(true)
    else
        fu:getChildByName('sign'):setVisible(score ~= 0)
        fu:getChildByName('value'):setString(math.abs(score))
        fu:setVisible(true)
    end

    result:setVisible(true)
end


-- 扑克分组(调整扑克位置)
function SGDeskView:groupCards(name, cardsdata, specialType)
    local deskInfo = self.desk:getDeskInfo()
    local gameplay = deskInfo.gameplay
    local gCard, groupInfo = GameLogic.groupingCardData(cardsdata, specialType, gameplay)
    local seat = self.MainPanel:getChildByName(name)
    local cards = seat:getChildByName('cards')

    local function arrangeCard(cards, groupInfo)
        -- 将最后两张牌竖起来
        local card3 = cards:getChildByName('card' .. 3)
        local card4 = cards:getChildByName('card' .. 4)
        local card5 = cards:getChildByName('card' .. 5)
        
        local rX = 36
        if groupInfo[2] and #groupInfo[2] == 1 then
            self:cardsBackToOriginSeat(name)
            local x5, y5 = card5:getPosition()
            card5:setPosition(cc.p(x5 + rX, y5))
        elseif groupInfo[2] and #groupInfo[2] == 2 then
            self:cardsBackToOriginSeat(name)
            local x4, y4 = card4:getPosition()
            local x5, y5 = card5:getPosition()
            card4:setPosition(cc.p(x4 + rX, y4))
            card5:setPosition(cc.p(x5 + rX , y5))
        end
    end
    
    if name == 'bottom' then 
        if groupInfo[2] and #groupInfo[2] > 0 then
            cards:setVisible(false)
            cards = seat:getChildByName('cards_mini')
            self:miniCardsBackToOrigin()
            arrangeCard(cards, groupInfo)
        end
    else
        arrangeCard(cards, groupInfo)
    end

    return gCard
end

function SGDeskView:hideAllLastCard()    
    if self.desk.tabPlayer then
        for uid, agent in pairs(self.desk.tabPlayer) do
            if agent:getInMatch() then
                local viewKey = agent:getViewInfo()
                self:freshLastCard(viewKey, 3, false)
            end
        end
    end
end

function SGDeskView:showlastcard()
    if self.desk.tabPlayer then
        for uid, agent in pairs(self.desk.tabPlayer) do
            if agent:getInMatch() then
                local viewKey = agent:getViewInfo()
                local cards = agent:getHandCardData()
                local choose, cnt, spType = agent:getChoosed()
                local lastcard = agent:getLastCard()
                if not cards then 
                    cards = agent:getSummaryCardData() 
                end
                if not cards then return end
                local gCardsData = GameLogic.setLaiziData(cards, spType)
                if lastcard then
                    for i, v in ipairs(gCardsData) do
                        if v == lastcard[1] or GameLogic.card_rank_out(v) == lastcard[1] then
                            self:freshLastCard(viewKey, i, true)
                        end
                    end
                end
            end
        end
    end
end

function SGDeskView:freshLastCard(viewKey, idx, bool)
    -- print("viewKey:",viewKey) 
    local cardsNode1 = self.MainPanel:getChildByName(viewKey):getChildByName('cards')
    local cardsNode2 = nil
    local cardsNode3 = nil
    if viewKey == 'bottom' then
        cardsNode2 = self.MainPanel:getChildByName(viewKey):getChildByName('cards_big')
        cardsNode3 = self.MainPanel:getChildByName(viewKey):getChildByName('cards_mini')
    end
    local cardsNode = {cardsNode1, cardsNode2, cardsNode3}
    local rX = 16

    for j, v in ipairs(cardsNode) do
        if not v then return end
        local a, b = v:getChildByName('card1'):getPosition()
        local c, d = v:getChildByName('card2'):getPosition()
        local y = b > d and d or b 
        for i = 1, 3 do
            local card = v:getChildByName('card' .. i)
            local x1, y1 = card:getPosition()
            card:getChildByName('image'):setVisible(false)
            card:setPosition(cc.p(x1, y))
            if idx and idx == i and bool then
                card:getChildByName('image'):setVisible(true)
                card:setPosition(cc.p(x1, y + rX))
            end
        end
    end
end

-- bottom 小版卡牌
function SGDeskView:freshMiniCards(bool, data)
    local component = self.MainPanel:getChildByName('bottom')
    local cards = component:getChildByName('cards_mini')
    if not bool then
        cards:setVisible(false)
        return
    end

    if not component or not data then
        return
    end

    local mycards = data
    for i, v in ipairs(mycards) do
        local card = cards:getChildByName('card' .. i)
        self:freshCardsTextureByNode(card, v)
    end
    cards:setVisible(true)
end

-- 牛几 | 特殊牌图片 | 完成
function SGDeskView:freshSeatCardType(name, bool, wcIcon, niuCnt, spcialType)
    local component = self.MainPanel:getChildByName(name)
    local check = component:getChildByName('check')
    local valueSp = check:getChildByName('value')
    local wc = check:getChildByName('wc')

    valueSp:setVisible(false)
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
        path = 'views/xydesk/result/sg/' .. GameLogic.getSpecialTypeByVal(idx, spcialType) .. '.png'
        valueSp:loadTexture(path)
    else
        path = 'views/xydesk/result/sg/' .. niuCnt .. '.png'
        valueSp:loadTexture(path)
    end

    check:setVisible(true)
    valueSp:setVisible(true)
end

-- 焰火
function SGDeskView:freshSeatFireworks(name, bool, niu, special)
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
    if niu == 0 and special == 0 then return end

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
function SGDeskView:freshSeatMul(name, show, niuCnt, specialType)
    
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

    local mul = GameLogic.getMul(gameplay, set, niuCnt, specialType)

    if mul and node then
        local path =  string.format("views/xydesk/numbers/yellow/%s.png", mul)
        if specialType > 0 or niuCnt == 10 then
            path =  string.format("views/xydesk/numbers/red/%s.png", mul)
        end
        node:loadTexture(path)
        node:setVisible(true)
    else
        node:setVisible(false)
    end
end


-- 其他玩家搓牌标志
function SGDeskView:freshSeatCuoPai(name, bool)
    bool = bool or false

    local component = self.MainPanel:getChildByName(name)
    if name ~= 'bottom' then
        local avatar = component:getChildByName('avatar')
        local cuoPai = avatar:getChildByName('cuoPai')
        cuoPai:stopAllActions()
        cuoPai:setVisible(bool)

        if bool then
            -- 创建动画  
            local animation = cc.Animation:create()  
            for i = 1, 6 do    
                local name = "views/xydesk/result/cuo"..i..".png"  
                -- 用图片名称加一个精灵帧到动画中  
                animation:addSpriteFrameWithFile(name)  
            end  
            -- 在1秒内持续4帧  
            animation:setDelayPerUnit(1/4)  
            -- 设置"当动画结束时,是否要存储这些原始帧"，true为存储  
            animation:setRestoreOriginalFrame(true)  
            -- 创建序列帧动画  
            local action = cc.Animate:create(animation)  
            cuoPai:runAction(cc.RepeatForever:create( action ))
        end
    end
end


-- 停止并隐藏其他玩家头像上搓牌动画
function SGDeskView:freshAllSeatCuoPai()
    for _, v in pairs(self.viewKey) do
        if v ~= 'bottom' then
            self:freshSeatCuoPai(v,false)
        end
    end
end

function SGDeskView:freshCuoButton(bool)
    local component = self.MainPanel:getChildByName('bottom')
    local opt = component:getChildByName('opt')
    local step1 = opt:getChildByName('step1') --搓牌/翻牌
    local cuo = step1:getChildByName('cuo') --搓牌
    cuo:setVisible(bool)
end


-- 提示/亮牌, 搓牌/翻牌 按钮刷新
function SGDeskView:freshOpBtns(sv1, sv2)
    local component = self.MainPanel:getChildByName('bottom')
    local opt = component:getChildByName('opt')
    local step1 = opt:getChildByName('step1') --搓牌/翻牌
    step1:setVisible(sv1)
    local step2 = opt:getChildByName('step2') --提示/亮牌
    step2:setVisible(sv2)
end

function SGDeskView:freshAutoFanpaiLayer(bool)
    local fanpaiLayer = self.MainPanel:getChildByName('autoFanpai')
    fanpaiLayer:setVisible(bool)
end  

function SGDeskView:freshAutoFanpai(bool)
    self.MainPanel:getChildByName('autoFanpai'):getChildByName('fanpai'):getChildByName('active'):setVisible(bool)
end

function SGDeskView:freshAutoFanpaiBtn()
    local fanpaiBtn = self.MainPanel:getChildByName('autoFanpai'):getChildByName('fanpai')
    local flag = fanpaiBtn:getChildByName('active'):isVisible()
    fanpaiBtn:getChildByName('active'):setVisible(not flag)
    return (not flag)
end  

-- ==================== agent =========================

function SGDeskView:freshMoney(name, money, groupScore)
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
function SGDeskView:freshSeat(name, bool)
    local component = self.MainPanel:getChildByName(name)
    component:setVisible(bool)
end


-- ==================== private =========================

function SGDeskView:onExit()
    if self.updateF then
        Scheduler.delete(self.updateF)
        self.updateF = nil
    end
    if self.schedulerID2 then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID2)
    end
end

function SGDeskView:update(dt)
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

    -- 庄家动画
    self:onUpdateBanker(dt)
end

function SGDeskView:onPing()
    self.heartbeatCheck:onPing()
end

function SGDeskView:sendHeartbeatMsg(dt)
    if not self.pauseHeartbeat then
        self.heartbeatCheck:update(dt)
    end
end

function SGDeskView:layout(desk)
    self.desk = desk
    self.viewKey = self.desk:getViewKeyData()

    -- 界面屏幕位置
    local mainPanel = self.ui:getChildByName('MainPanel')
    mainPanel:setPosition(display.cx, display.cy)
    self.MainPanel = mainPanel
    
    -- 桌面背景
    local desktopIdx = self:getCurDesktop() or 2
    self:setCurDesktop(desktopIdx)
    self:changeDesktop(desktopIdx) 
    
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
    self.watcherSitdownBtn = watcherLayout:getChildByName('sitdownBtn')
    self.watcherStatusSp = watcherLayout:getChildByName('statusSp')
    self.watcherLayout = watcherLayout
    
    
    -- init control view
    self.playerViews = {}
    self.playerViews.msg = self.MainPanel:getChildByName('msg')
    self.playerViews.voice = self.MainPanel:getChildByName('voice')
    --self.playerViews.prepare = self.MainPanel:getChildByName('prepare')
    --self.playerViews.gameStart = self.MainPanel:getChildByName('gameStart')
    --self.playerViews.invite = self.MainPanel:getChildByName('invite')
    self.playerViews.qzbar = self.MainPanel:getChildByName('qzbar')
    self.playerViews.sqzbar = self.MainPanel:getChildByName('sqzbar')
    
    local bottom = self.MainPanel:getChildByName('bottom')
    self.playerViews.opt = bottom:getChildByName('opt')
    self.playerViews.continue = bottom:getChildByName('continue')
    self.playerViews.input = bottom:getChildByName('input')
    self.playerViews.betting = bottom:getChildByName('betting')
    self.playerViews.qzbetting = bottom:getChildByName('qzbetting')
    self.playerViews.qzbanker = bottom:getChildByName('qzbanker')
    
    self.playerViews.slider = bottom:getChildByName('slider')
    self.bettingSliderText = self.playerViews.slider:getChildByName('1'):getChildByName('text')
    self.bettingSlider = self.playerViews.slider:getChildByName('slider')
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
    
    --开始,继续,坐下 按钮位置
    self.tabBtnPos = {
        left = cc.p(self.startBtn:getPosition()),
        right = cc.p(self.watcherSitdownBtn:getPosition()),
    }
    self.tabBtnPos['middle'] = cc.p((self.tabBtnPos['left'].x + self.tabBtnPos['right'].x) / 2, self.tabBtnPos['left'].y)

    if self.desk.isOwner then
        self.startBtn:setPosition(self.tabBtnPos.left)
        self.prepareBtn:setPosition(self.tabBtnPos.right)
        self.watcherSitdownBtn:setPosition(self.tabBtnPos.right)
    else
        self.startBtn:setPosition(self.tabBtnPos.left)
        self.prepareBtn:setPosition(self.tabBtnPos.middle)
        self.watcherSitdownBtn:setPosition(self.tabBtnPos.middle)
    end
    self.watcherLayout:setVisible(true)
    
    self.tabCardsPos = {}
    
    self.trusteeshipLayer = self.MainPanel:getChildByName('trusteeshipLayer')

    local cpLayer = self.MainPanel:getChildByName('cpLayer')
    self.cpLayer = cpLayer
    self.rubLayer = nil 
    
    -- 记录所有扑克位置
    self.cardsOrgPos = {}
    for key, val in pairs(self.viewKey) do
        local seat = self.MainPanel:getChildByName(val)
        local cardsNode = seat:getChildByName('cards')
        self.cardsOrgPos[val] = {}
        for i = 1, 3 do
            local card = cardsNode:getChildByName('card' .. i)
            if val == "bottom" then
                local x, y = card:getPosition()
                self.cardsOrgPos[val][i] = cc.p(x, y)
            else
                local x, y = 64 + 113*(i - 1) , 88
                self.cardsOrgPos[val][i] = cc.p(x, y)
            end
        end
        if val == "bottom" then
            local cards_mini = bottom:getChildByName('cards_mini')
            self.cardsOrgPos['mini'] = {}
            for i = 1, 3 do
                local x, y = 64 + 113*(i - 1) , 88
                self.cardsOrgPos['mini'][i] = cc.p(x, y)
            end
        end
    end
    
    -- 隐藏界面

    self:freshWatcherBtn(false)
    self:freshWatcherSp(false)
    self:freshPrepareBtn(false)
    self:freshGameStartBtn(false, false)
    self:freshAutoFanpaiLayer(false)

    -- 是否比赛场(金币场)
    self:freshIsCoin()

    self:freshBtnPos()

    --刷新电量等信息
    self:freshDeviceInfo()

    -- self:freshCanPutMoney('bottom',true)

    local scheduler = cc.Director:getInstance():getScheduler()
    self.schedulerID2 = scheduler:scheduleScriptFunc(function()
        local time = os.time()
        if self.nowtime then
            if time - self.nowtime > 30 then
                if self.desk:isGamePlaying() and self.desk:isMePlayer() 
                and not self:getTrusteeshipLayer() and not self.desk:isMeRobot() then
                    self.desk:requestTrusteeship()
                    self:freshTrusteeshipLayer(true)
                    self:freshTrusteeshipIcon('bottom', true)
                    print("离开了啊----------------------------------------")
                end
                self.nowtime = time
            end
        end
    end, 0, false)

    --添加监听层
    local listenpanel = self.MainPanel:getChildByName('Panel')
    listenpanel:setSwallowTouches(false)
    listenpanel:addClickEventListener(function ()
        print("click--------------------------------------------")
        self.nowtime = os.time()
    end)

end

function SGDeskView:changeDesktop(idx)
    idx = idx or 1
    local path = ''
    path = 'views/nysdesk/brbg' .. idx .. '.png'
	self.MainPanel:getChildByName('bg'):loadTexture(path)
	self:setCurDesktop(idx)
end

function SGDeskView:setCurDesktop(idx)
	local app = require("app.App"):instance()
	app.localSettings:set('desktop', idx)
end

function SGDeskView:getCurDesktop()
	local app = require("app.App"):instance()
	local idx = app.localSettings:get('desktop')
	return idx or 2
end

function SGDeskView:getCurCuoPai()
	local app = require("app.App"):instance()
	local idx = app.localSettings:get('cuoPai')
	idx = idx or 1
	return idx
end 

function SGDeskView:changeCardBack()
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
function SGDeskView:recoveryDesk(desk, reload)

    self.nowtime = os.time()
    -- 结束动画
    self:stopBankerAction()

    --隐藏最后一张牌标记
    self:hideAllLastCard()

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

    -- 玩家基本信息
    if self.desk.tabPlayer then
        for uid, agent in pairs(self.desk.tabPlayer) do
            local actor = agent.actor
            local viewKey, viewPos = agent:getViewInfo()
            self:freshHeadInfo(viewKey, actor)
            self:freshMoney(viewKey, agent:getMoney(), agent:getGroupScore())
            self:freshSeat(viewKey, true)
            self:freshEnterBackground(viewKey,agent:isEnterBackground() or false)
            self:freshDropLine(viewKey,agent:isDropLine() or false)
            self:freshTrusteeshipIcon(viewKey,agent:getTrusteeship() or false)
            if agent:getFlagBanker() then
                self:freshBanker(viewKey, true, agent:getQiang())
            else
                self:freshBanker(viewKey, false)
            end
            if viewKey == 'bottom' then
                self:freshAutoFanpai(agent:getautoOperation())
            end
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

        if curState == 'QiangZhuang' then
            self:onReloadQiangZhuang()
        elseif curState == 'Dealing' then
            self:onEnterDealing()
        elseif curState == 'PutMoney' then
            self:onReloadPutMoney()
        elseif curState == 'Playing' then
            self:onReloadPlaying()
        elseif curState == 'PutLimit' then
            self:onReloadPutLimit()
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
function SGDeskView:clearDesk(name)
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
    for i = 1, 3 do
        self:freshCardsTexture(name, i, nil, idx)
    end
    if name == 'bottom' then
        self:freshMiniCards(false)
    end
end


--- 玩家
function SGDeskView:resetPlayerView(name)
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

function SGDeskView:freshHeadInfo(name, data)
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

function SGDeskView:freshSeat(name, bool)
    local component = self.MainPanel:getChildByName(name)
    component:setVisible(bool)
end

-- 桌子信息
function SGDeskView:freshRoomInfo(bool)
    local topbar = self.MainPanel:getChildByName('topbar')
    local info = topbar:getChildByName('info')

    local deskInfo = self.desk:getDeskInfo()

    -- 房号
    local strRoomId = self.desk:getDeskId()
    local roomid = info:getChildByName('roomid')
    roomid:setString("房号:" .. strRoomId)

    -- 玩法
    local strGameplay = GameLogic.getGameplayText(deskInfo)
    local gameplay = info:getChildByName('gameplay')
    gameplay:setString("玩法:" .. strGameplay)

    -- 底分
    local strBase = GameLogic.getBaseText(deskInfo)
    local base = info:getChildByName('base')
    base:setString("底分:" .. strBase)

    -- 局数
    local strRound = self.desk:getCurRound()
    local round = info:getChildByName('round')
    round:setString("局数:" .. strRound .. "/" .. deskInfo.round)

    -- 推注
    local strPutmoney = GameLogic.getPutMoneyText(deskInfo)
    local putmoney = info:getChildByName('putmoney')
    putmoney:setString("推注:" .. strPutmoney)

    -- 下注封顶
    local strPutLimit = GameLogic.getPutLimitText(deskInfo)
    local putLimit = info:getChildByName('putLimit')
    putLimit:setString("下注:" .. strPutLimit)

    if deskInfo.gameplay == 5 then
        putLimit:setVisible(true)
        putmoney:setVisible(false)
    else
        putmoney:setVisible(true)
        putLimit:setVisible(false)
    end

    info:setVisible(bool)
end

function SGDeskView:freshDeviceInfo()
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
function SGDeskView:freshTip(bShow, text, cd)
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

function SGDeskView:freshTipText(text)
    if not text then return end
    if text == '' then return end
    self.tipText = text
end

-- ================== 作弊界面 ==================
-- 透明
function SGDeskView:freshCheatView(msg)
    if self.cheatBtn then
        self.cheatBtn:setVisible(true)
        self.cheatBtn:setEnabled(true)

        local deskInfo = self.desk:getDeskInfo()
        local setting = deskInfo.special
        local gameplay = deskInfo.gameplay

        for k, v in pairs(msg) do
            local info = self.desk:getPlayerInfo(k)
            if info then
                local viewKey = info.viewKey
                local cards = v.tabCards

                local cnt, sptype, spKey = GameLogic.getLocalCardType(cards, gameplay, setting)

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

function SGDeskView:showCheatView(bShow, key)
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
function SGDeskView:freshCheat1View(show, flag)
    show = show or false
    flag = flag or 0
    self.cheatDa:setVisible(show)
    self.cheatXiao:setVisible(false)
    if flag == 1 then
        self.cheatXiao:setVisible(true)
    end
    self.cheatWu:setVisible(false)
end

function SGDeskView:freshCheat1Result(mode)
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

function SGDeskView:freshCheatLabel(viewKey, cheatStr)
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


function SGDeskView:card_suit(c)
	if not c then print(debug.traceback()) end
    if c == '☆' or c == '★' then
        return c
    else
        return #c > SUIT_UTF8_LENGTH and c:sub(1, SUIT_UTF8_LENGTH) or nil
    end
end

function SGDeskView:card_rank(c)
    return #c > SUIT_UTF8_LENGTH and c:sub(SUIT_UTF8_LENGTH + 1, #c) or nil
end

function SGDeskView:freshCardsTexture(name, idx, value, backIdx)
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

function SGDeskView:freshCardsTextureByNode(cardNode, value, backIdx)

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

local pathArr = {
    ['checkCards'] = 'views/xydesk/countdown/4.png', -- 查看手牌
    ['chooseBet'] = 'views/xydesk/countdown/2.png', -- 选择下注分数
    ['chooseQZ'] = 'views/xydesk/countdown/5.png', -- 操作抢庄
    -- ['waitBet'] = 'views/xydesk/countdown/5.png', -- 请等待闲家下注
    -- ['waitShowCards'] = 'views/xydesk/countdown/5.png', -- 等待其他玩家亮牌
}

function SGDeskView:freshCDHint(pkey)
    local component = self.MainPanel:getChildByName('bottom')
    local avatar = component:getChildByName('avatar')
    local countdown = avatar:getChildByName('countdown')
    local hint = countdown:getChildByName('hint')
    hint:loadTexture(pathArr[pkey])

    local num = hint:getChildByName('num')
    local sz = hint:getContentSize()
    local _, y = num:getPosition()
    num:setPosition(sz.width + 20, y)
end

function SGDeskView:freshTimer(value, bool)
    local component = self.MainPanel:getChildByName('bottom')
    local avatar = component:getChildByName('avatar')
    local countdown = avatar:getChildByName('countdown')
    local hint = countdown:getChildByName('hint')
    local num = hint:getChildByName('num')

    num:setString(value)
    countdown:setVisible(bool)
end

function SGDeskView:freshChatMsg(name, sex, msgType, msgData)

    local chatView = require('app.views.SGChatView')
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

function SGDeskView:freshEmojiAction(name, idx)
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
    
    local str = "views/animation/magicExpress/csb/"..idx..".csb"
    local node = cc.CSLoader:createNode(str) 
    node:setPosition(cc.p(getPos(name)))
    node:setScale(0.6)
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


function SGDeskView:gameSettingAction(derection)
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
		if played and inMatch then
			leave:setEnabled(false)
		else
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

function SGDeskView:freshGameInfo(bool)
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
    text_beiRule:setString(mulStr)

    -- 房间规则
    local roomRuleStr = GameLogic.getRoomRuleText(deskInfo)
    text_roomRule:setString(roomRuleStr)

    -- 特殊牌
    local spStr = GameLogic.getSpecialText(deskInfo)
    text_Twanfa:setString(spStr)

    -- 高级选项
    local advanceStr = GameLogic.getAdvanceText(deskInfo)
    text_advanceRule:setString(advanceStr)

    -- 房间限制
	local roomlimitstr = GameLogic.getRoomLimitText(deskInfo)
	text_roomlimit:setString(roomlimitstr)

end 

function SGDeskView:cardsBackToOrigin()
    local bottom = self.MainPanel:getChildByName('bottom')
    local cards = bottom:getChildByName('cards')

    for i = 1, 3 do
        local card = cards:getChildByName('card' .. i)
        if card.focus == 'focus' then
            local x, y = card:getPosition()
            card:setPosition(cc.p(x, y - 30))
            card.focus = nil
        end
    end

    -- 将不是bottom的最后两张牌强制还原
    local names = {'left', 'lefttop', 'top', 'righttop', 'right', "bottom"}
    for k, v in ipairs(names) do 
        local positionName = self.MainPanel:getChildByName(v)
        local cardView = positionName:getChildByName('cards')
        for i = 1, 3 do
            local card = cardView:getChildByName('card' .. i)
            local p = self.cardsOrgPos[v][i]
            card:setPosition(p)
        end
    end
end

function SGDeskView:cardsBackToOriginSeat(name)
    local positionName = self.MainPanel:getChildByName(name)
    local cardView = positionName:getChildByName('cards')
    for i = 1, 3 do
        local card = cardView:getChildByName('card' .. i)
        local p = self.cardsOrgPos[name][i]
        card:setPosition(p)
    end
end

function SGDeskView:miniCardsBackToOrigin()
    local positionName = self.MainPanel:getChildByName('bottom')
    local cardView = positionName:getChildByName('cards_mini')
    for i = 1, 3 do
        local card = cardView:getChildByName('card' .. i)
        local p = self.cardsOrgPos['mini'][i]
        card:setPosition(p)
    end
end

function SGDeskView:doVoiceAnimation()
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

  for i = 0, 8 do
    local delay1 = cc.DelayTime:create(0.1 * i)
    local fIn = cc.FadeIn:create(0.1)
    local delay2 = cc.DelayTime:create(0.1 * (8 - i))
    local fOut = cc.FadeOut:create(0.1)
    local sequence = cc.Sequence:create(delay1, fIn, delay2, fOut)
    local action = cc.RepeatForever:create(sequence)

    local rect = pwr:getChildByName(tostring(i))
    rect:runAction(action)
  end

  pwr:setVisible(true)

  yyCountdown:setVisible(true)
end

function SGDeskView:updateCountdownVoice(delay)
  self.tvoice.prg:setPercentage((20 - delay) / 20  * 100)
end

function SGDeskView:removeVoiceAnimation()
  if self.tvoice then
    local pwr = self.tvoice.pwr
    for i = 0, 8 do
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

function SGDeskView:freshInviteFriend(bool)
    local invite = self.MainPanel:getChildByName('invite')
    invite:setVisible(bool)
   
end

function SGDeskView:copyRoomNum(content)
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



function SGDeskView:somebodyVoice(uid, total)
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

function SGDeskView:kusoAction(start, dest, idx)
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
function SGDeskView:kusoAction_DaQiang(start, dest, num)
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


function SGDeskView:freshSummaryView(show, data)
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

    local quit = view:getChildByName('quit')
    local summary = view:getChildByName('summary')
    quit:setVisible(false)
    summary:setVisible(false)

    local function onClickQuit()
        app:switch('LobbyController')
    end

    local function onClickSummary()
        app:switch('SGSummaryController', data)
    end

    quit:addClickEventListener(onClickQuit)
    summary:addClickEventListener(onClickSummary)

    local delay = cc.DelayTime:create(2.5)
    summary:runAction(cc.Sequence:create(delay, cc.CallFunc:create(onClickSummary)))
end

-- ============================ agent ============================

-- 玩家准备
function SGDeskView:freshReadyState(name, bool)
    local component = self.MainPanel:getChildByName(name)
    if not component then
        return
    end

    local avatar = component:getChildByName('avatar')
    local ready = avatar:getChildByName('ready')
    ready:setVisible(bool)
end

-- 玩家掉线
function SGDeskView:freshDropLine(name, bool)
    local component = self.MainPanel:getChildByName(name)
    local avatar = component:getChildByName('avatar')
    local dropLine = avatar:getChildByName('dropLine')
    dropLine:setVisible(bool)
    if name == 'bottom' then
        dropLine:setVisible(false)
    end
    if bool then 
        self:freshEnterBackground(name,false)
    end
end

-- 玩家切换后台
function SGDeskView:freshEnterBackground(name, bool)
    local component = self.MainPanel:getChildByName(name)
    local avatar = component:getChildByName('avatar')
    local enterbackground = avatar:getChildByName('enterbackground')
    enterbackground:setVisible(bool)
    if name == 'bottom' then
        enterbackground:setVisible(false)
    end
end

-- 托管/取消托管
function SGDeskView:freshTrusteeshipIcon(name, bool)
    bool = bool or false
    local component = self.MainPanel:getChildByName(name)
    local avatar = component:getChildByName('avatar')
    local trusteeship = avatar:getChildByName('trusteeship')
    trusteeship:setVisible(bool)
end

function SGDeskView:freshTrusteeshipLayer(bool)
    self.trusteeshipLayer:setVisible(bool)
end

function SGDeskView:getTrusteeshipLayer()
    return self.trusteeshipLayer:isVisible()
end

function SGDeskView:getPlayerView(startUid)
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
function SGDeskView:playEftQz(qzNum, sex)
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
function SGDeskView:playEftBet(bool)
    local soundPath = 'desk/coin_big.mp3'
    if bool then
        soundPath = 'desk/coins_fly.mp3'
    end
    SoundMng.playEftEx(soundPath)
end

-- 牌型
function SGDeskView:playEftCardType(sex, niuCnt, specialType)
    local soundPath = 'cscompare_sg/' .. tostring('f' .. sex .. "_nn" .. niuCnt .. '.mp3')
    if specialType > 0 then
        local idx = self.desk:getGameplayIdx()
        soundPath = 'cscompare_sg/' .. tostring('f'.. sex .."_nn" .. GameLogic.getSpecialTypeByVal(idx, specialType) .. '.mp3')
    end
    SoundMng.playEftEx(soundPath)
end

-- 输赢音效
function SGDeskView:playEftSummary(win)
    local soundPath = 'desk/lose.mp3'
    if win then
        soundPath = 'desk/win.mp3'
    end
    SoundMng.playEftEx(soundPath)
end

function SGDeskView:freshCanPutMoney(name,bool)
    local picture =  self.MainPanel:getChildByName(name):getChildByName('avatar'):getChildByName('CanPutMoney')
    local node = picture:getChildByName('CanPutMoneyAnimation')
    picture:setVisible(bool)
    if bool then
        self:startCsdAnimation(node,true)
    else
        self:stopCsdAnimation(node)
    end
end

function SGDeskView:startCsdAnimation(node, isRepeat)
    local action = cc.CSLoader:createTimeline("views/xydesk/putmoney/CanPutMoneyAnimation.csb")
    action:gotoFrameAndPlay(0,isRepeat)
    node:stopAllActions()
    node:runAction(action)
end
  
function SGDeskView:stopCsdAnimation(node)
    node:stopAllActions()
end


-- 搓牌部分
function SGDeskView:showCardsAtCuopai(data)
    local cards = self.cpLayer:getChildByName('cards')
    for i = 1, 2 do
        local card = cards:getChildByName('card' .. i)
        -- self:setFaceDisplay(card,'front',data[i])
        self:freshCardsTextureByNode(card, data[i])
        card:setVisible(true)
    end
end

function SGDeskView:init3dLayer_ios(cardValue)
    if not self.cpLayer then
        print("cuopai: nil cplayer")
        return
    end

    -- 层和摄像机
    local layer3D = cc.Layer:create()
    self.cpLayer:addChild(layer3D,999)
    layer3D:setCameraMask(cc.CameraFlag.USER1)
    self.layer3D = layer3D

    self.cpLayer._camera = cc.Camera:createPerspective(45, display.width / display.height, 1,3000)
    self.cpLayer._camera:setCameraFlag(cc.CameraFlag.USER1)
    self.cpLayer._camera:setDepth(2)
    layer3D:addChild(self.cpLayer._camera)

    self.cpLayer._camera:setPosition3D(cc.vec3(0, 0, 310))
    self.cpLayer._camera:lookAt(cc.vec3(0,0,0), cc.vec3(0, 0, -1))


    -- 3D精灵
    local path = '3d/wonder4.c3b'
    local path1 = '3d/wonder3.c3b'
    local card3d = cc.Sprite3D:create(path)
    local card3d1 = cc.Sprite3D:create(path1)
    self.animation = cc.Animation3D:create(path)
    self.animation1 = cc.Animation3D:create(path1)
    if not card3d or not card3d1 then
        print("cuopai: nil card3d")
        return
    end 
    layer3D:addChild(card3d)
    self.card3d = card3d
    layer3D:addChild(card3d1)
    self.card3d1 = card3d1

    local app = require("app.App"):instance()
    local idx = app.localSettings:get('cuoPai')
    idx = idx or 1

    card3d:setTexture('3d/0' .. cardValue .. '.png')
    card3d1:setTexture('3d/paibei/paibei_' .. idx .. '.png')
    card3d:setCameraMask(cc.CameraFlag.USER1)
    card3d:setPosition3D(cc.vec3(0,-1.4,300))
    card3d:setRotation3D(cc.vec3(90,0,0))
    card3d:setScale(0.1)

    card3d1:setCameraMask(cc.CameraFlag.USER1)
    card3d1:setPosition3D(cc.vec3(0,-1.4,300))
    card3d1:setRotation3D(cc.vec3(90,0,0))
    card3d1:setScale(0.1)

    self.updown = 0
    self.animationfirst = nil
    self.animationfirst1 = nil 
    self.start1 = nil   
    self.dest1 = nil 

    --牌的值
    local scardvalue = cc.Sprite:create('3d/1' .. cardValue .. '.png')
    local scardvalue1 = cc.Sprite:create('3d/1' .. cardValue .. '.png')

    if not scardvalue or not scardvalue1 then
        print("cuopai: nil scardvalue")
        return
    end 

    layer3D:addChild(scardvalue)
    self.scardvalue = scardvalue  
    layer3D:addChild(scardvalue1)
    self.scardvalue1 = scardvalue1

    scardvalue:setCameraMask(cc.CameraFlag.USER1)
    scardvalue:setPosition3D(cc.vec3(-74,-105,0))
    scardvalue:setRotation3D(cc.vec3(0,0,0))
    scardvalue:setScale(0.3)

    scardvalue1:setCameraMask(cc.CameraFlag.USER1)
    scardvalue1:setPosition3D(cc.vec3(76,18,0))
    scardvalue1:setRotation3D(cc.vec3(180,180,0))
    scardvalue1:setScale(0.3)

    scardvalue:setOpacity(0)
    scardvalue1:setOpacity(0)
end


function SGDeskView:freshCardFlipAction(cardValue)
    if nil ~= self.animation and not self.cardFlip then

        local app = require("app.App"):instance()
        local idx = app.localSettings:get('cuoPai')
        idx = idx or 1

        self.card3d:setTexture('3d/0' .. cardValue .. '.png')
        self.card3d1:setTexture('3d/paibei/paibei_' .. idx .. '.png')
        self.card3d:setCameraMask(cc.CameraFlag.USER1)
        self.card3d1:setCameraMask(cc.CameraFlag.USER1)

        local animate = cc.Animate3D:createWithFrames(self.animation, 51, 80)
        local animate1 = cc.Animate3D:createWithFrames(self.animation1, 51, 80)
        local speed = 1.0
        animate:setSpeed(speed)
        animate:setTag(110)
        animate1:setSpeed(speed)
        animate1:setTag(120)

        local callback = function()
            -- 搓牌回调
            self.emitter:emit('cpBack', {msgID = 'cpBack'})
        end

        local callback1 = function()
            local animate2 = cc.FadeIn:create(0.5)
            self.scardvalue:runAction(animate2)
        end

        local callback2 = function()
            local animate2 = cc.FadeIn:create(0.5)
            self.scardvalue1:runAction(animate2)
        end

        local delay = cc.DelayTime:create(1.5)
        local showcardvalue = cc.Spawn:create( cc.CallFunc:create(callback1), cc.CallFunc:create(callback2))
        local sequence = cc.Sequence:create(animate, showcardvalue,delay, cc.CallFunc:create(callback))
        local sequence1 = cc.Sequence:create(animate1, showcardvalue,delay, cc.CallFunc:create(callback))

        self.card3d:stopAllActions()
        self.card3d:runAction(sequence)
        self.card3d1:stopAllActions()
        self.card3d1:runAction(sequence1)

        self.cardFlip = true
        self.card:addTouchEventListener(function() end)
    end
end

function SGDeskView:freshCardMoveAction(derection, start, dest)
    if start < 0 or dest < 0 then
        return
    end

    if nil ~= self.animation then
        local animate = cc.Animate3D:createWithFrames(self.animation, start, dest)
        local speed = 1.0
        animate:setSpeed(speed)
        animate:setTag(110)

        if self.card3d == nil then
            return
        end
        local animate1 = cc.Animate3D:createWithFrames(self.animation1, start, dest)
        local speed = 1.0
        animate1:setSpeed(speed)
        animate1:setTag(120)

        self.card3d:stopAllActions()

        if derection == 'up' then
            self.card3d1:runAction(animate1) 
            self.card3d:runAction(animate) --(cc.Sequence:create(animate,call))--
        elseif derection == 'down' then
            self.card3d1:runAction(animate1:reverse())
            self.card3d:runAction(animate:reverse())
        elseif derection == "reset" then
            animate1:setSpeed(6.0)
            self.card3d1:runAction(
                cc.Sequence:create(animate1:reverse(),
                cc.CallFunc:create(function()
                    self.bBlockTouch = false
                    end)
                ))

            animate:setSpeed(6.0)
            self.card3d:runAction(
                cc.Sequence:create(animate:reverse(),
                cc.CallFunc:create(function()
                    self.bBlockTouch = false
                    end)
                ))
            self.animationfirst = nil
        end
    end
end

function SGDeskView:runAction1(derection, start,dest )
    --防止start<0但还没运行完动画的情况出现
    if start < 0  then
        if dest > 0 then 
            start = 0
        else return end
    end
    --调整速度 根据滑动的距离设置动画的播放速度
    local speed = nil 
    if self.difY < 0 then  
        speed = self.dify / (dest - start)
    elseif self.difY == 0 then 
        speed = 1
    else 
        speed = (self.maxdify - self.dify) / (dest - start)
    end
    if speed == 0 then 
        speed = 1 
    end
    speed = math.floor(speed + 0.5)
    self.animationfirst = cc.Animate3D:createWithFrames(self.animation,start,dest)
    self.animationfirst1 = cc.Animate3D:createWithFrames(self.animation1,start,dest)
    self.start1 = start 
    self.dest1 = dest 
    self.time1 = cc.Director:getInstance():getTimeInMilliseconds()
    self.animationfirst:setSpeed(speed)
    self.animationfirst1:setSpeed(speed)
    if derection == 'up' then
        self.card3d1:runAction(self.animationfirst1) 
        self.card3d:runAction(self.animationfirst) 
    elseif derection == 'down' then
        self.card3d1:runAction(self.animationfirst1:reverse())
        self.card3d:runAction(self.animationfirst:reverse())
    end
    if dest == 50 then 
        self:freshCardFlipAction(self.paimian)
    end
end

function SGDeskView:freshCardMoveAction1(derection,start,dest)
    --判断是否为空 是就添加第一段动画
    if self.animationfirst == nil then 
        self:runAction1(derection,start,dest)
        return
    end
    --判断上一段动画是否放完 如果没放完则调整要放的帧数
    self.time2 = cc.Director:getInstance():getTimeInMilliseconds()
    local timeadvance = (self.time2 - self.time1)
    local framesadvance = (self.dest1 - self.start1) * 1000 / 30 
    if start == 0 or framesadvance == 0 then 
        timeadvance = 0 
    end
    local frames = self.start1 + timeadvance * 30 / 1000
    local frames1 = math.ceil(frames - (dest - start))
    local frames2 = math.floor(self.dest1 - timeadvance * 30 / 1000)
    if frames1 < 0 then 
        frames1 = 0 
    end
    if self.card3d == nil or self.card3d1 == nil then
        return
    end
    --判断时间间隔 假如比牌所要的时间短就刷新start 长就直接继续播放动画
    if timeadvance > framesadvance then 
        if dest + 1 > 51 then 
            self:freshCardFlipAction(self.paimian)
        else 
            self:runAction1(derection,start,dest)
        end
    else 
        self.card3d:stopAllActions()
        self.card3d1:stopAllActions()
        if dest + 1 > 51 then
            self:runAction1(derection,math.ceil( frames ),50)
        else
            if derection == 'down' then
                if start > frames then 
                    self:runAction1(derection, frames1, math.floor(frames))      --防止回滚太快时跳过了部分动画导致不连贯
                else
                    self:runAction1(derection, start, frames2)
                end
            else
                self:runAction1(derection,math.ceil(frames + 1),dest)      --自动+1帧避免在滑动距离太短时造成重复
            end                                                                 --播放同一帧动画导致动画跳动
        end
    end
end
----------------------------------------------------------------------------------------------------

--android用的新版搓牌
function SGDeskView:init3dLayer(cardData)
    local suit = self.suit_2_path[self:card_suit(cardData)]
    local rnk = self:card_rank(cardData) or '_joker'

    if not suit then return end
    if not rnk then return end
    
    local fileName = suit .. rnk
    local cardPath = '3d/0' .. suit .. rnk .. '.png'
    local cardIdx = self:getCurCuoPai()
    local backPath = '3d/paibei/paibei_' .. cardIdx .. '.png'

    -- 通过图片取得纹理id，和该纹理在plist图中的纹理坐标范围
    local function getTextureAndRange(szImage)
        local TextureCache = cc.Director:getInstance():getTextureCache()
        local tex = TextureCache:addImage(szImage)
        
        local rect = tex:getContentSize()
        local id = tex:getName() --纹理ID
        local bigWide = tex:getPixelsWide() --plist图集的宽度
        local bigHigh = tex:getPixelsHigh()

        -- 左右上下的纹理范围
        local ll = 0
        local rr = 1
        local tt = 0
        local bb = 1
        return id, {ll, rr, tt, bb}, {rect.width, rect.height}
    end

    -- 创建3D牌面，所需的顶点和纹理数据, size:宽高, texRange:纹理范围, bFront:是否正面
    local function initCardVertex(size, texRange, bFront, valTexTange)
        local nDiv = 50 
        local verts = {} --位置坐标
        local texs = {} --纹理坐标
        local dh = size.height / nDiv
        local dw = size.width / nDiv

        local valW = 168*0.9
        local valH = 66*0.9
        local valX = size.width - valW -10
        local valY =  7

        local valW1 = valW
        local valH1 = valH
        local valX1 = 10
        local valY1 =  size.height - 66

        local valVer = {}
        local valTex = {}

        local valVer1 = {}
        local valTex1 = {}

        local function isInValRange(x, y)
            local xIn = valX<=x and x<=(valW+valX)
            local yIn = valY<=y and y<=(valH+valY)
            return xIn and yIn
        end

        local function isInValRange1(x, y)
            local xIn = valX1<=x and x<=(valW1+valX1)
            local yIn = valY1<=y and y<=(valH1+valY1)
            return xIn and yIn
        end

        --计算顶点位置
        for row = 1, nDiv do
            for line = 1, nDiv do
                local x = (row - 1)* dw
                local y = (line - 1)* dh
                local quad = {}
                if bFront then 
                    --正面
                    quad = {
                        -- 1            --2                 --3
                        x, y,           x + dw, y,          x, y + dh, 
                        -- 1            --2                 --3
                        x + dw, y,      x + dw, y + dh,     x, y + dh,
                    }
                else  
                    --背面
                    quad = {
                        -- 1            --2                 --3
                        x, y,           x, y + dh,          x + dw, y, 
                        -- 1            --2                 --3
                        x + dw, y,      x, y + dh,          x + dw, y + dh,
                    }
                    if valTexTange then
                        -- Val顶点
                        for i=1,#quad,2 do
                            if isInValRange(quad[i], quad[i+1]) then
                                table.insert(valVer, quad[i])
                                table.insert(valVer, quad[i+1])
                            end
                            if isInValRange1(quad[i], quad[i+1]) then
                                table.insert(valVer1, quad[i])
                                table.insert(valVer1, quad[i+1])
                            end
                        end
                    end
                end

                for _, v in ipairs(quad) do
                    table.insert(verts, v)
                end
            end
        end

        local bXTex = true --是否当前在计算横坐标纹理坐标，
        for _, v in ipairs(verts) do
            if bXTex then
                if bFront then
                    table.insert(texs, v / size.width * (texRange[2] - texRange[1]) + texRange[1])
                else
                    table.insert(texs, v / size.width * (texRange[1] - texRange[2]) + texRange[2])
                end
            else
                if bFront then
                    table.insert(texs, (1 - v / size.height) * (texRange[4] - texRange[3]) + texRange[3])
                else
                    table.insert(texs, v / size.height * (texRange[3] - texRange[4]) + texRange[4])
                end
            end
            bXTex = not bXTex
        end

        if valTexTange then
            local bXTex = true --是否当前在计算横坐标纹理坐标，
            for _, v in ipairs(valVer) do
                if bXTex then
                    table.insert(valTex, 1-((v-valX) / valW))
                else
                    table.insert(valTex, 1-((v-valY) / valH))
                end
                bXTex = not bXTex
            end

            local bXTex = true --是否当前在计算横坐标纹理坐标，
            for _, v in ipairs(valVer1) do
                if bXTex then
                    table.insert(valTex1, ((v-valX1) / valW1))
                else
                    table.insert(valTex1, ((v-valY1) / valH1))
                end
                bXTex = not bXTex
            end
        end

        local res = {}
        local tmp = {verts, texs}
        for _, v in ipairs(tmp) do
            -- 创建一个 VBO
            local buffid = gl.createBuffer()
            -- 绑定 VBO 到 GL_ARRAY_BUFFER 目标上
            gl.bindBuffer(gl.ARRAY_BUFFER, buffid)
            -- 设置 顶点数据
            gl.bufferData(gl.ARRAY_BUFFER, table.getn(v), v, gl.STATIC_DRAW)
            -- 取消 目标绑定
            gl.bindBuffer(gl.ARRAY_BUFFER, 0)
            -- 记录 VBO i
            table.insert(res, buffid)
        end


        local valRes = {}
        local valRes1 = {}
        if valTexTange then
            for _, v in ipairs({valVer, valTex}) do
                -- 创建一个 VBO
                local buffid = gl.createBuffer()
                -- 绑定 VBO 到 GL_ARRAY_BUFFER 目标上
                gl.bindBuffer(gl.ARRAY_BUFFER, buffid)
                -- 设置 顶点数据
                gl.bufferData(gl.ARRAY_BUFFER, table.getn(v), v, gl.STATIC_DRAW)
                -- 取消 目标绑定
                gl.bindBuffer(gl.ARRAY_BUFFER, 0)
                -- 记录 VBO i
                table.insert(valRes, buffid)
            end

            for _, v in ipairs({valVer1, valTex1}) do
                -- 创建一个 VBO
                local buffid = gl.createBuffer()
                -- 绑定 VBO 到 GL_ARRAY_BUFFER 目标上
                gl.bindBuffer(gl.ARRAY_BUFFER, buffid)
                -- 设置 顶点数据
                gl.bufferData(gl.ARRAY_BUFFER, table.getn(v), v, gl.STATIC_DRAW)
                -- 取消 目标绑定
                gl.bindBuffer(gl.ARRAY_BUFFER, 0)
                -- 记录 VBO i
                table.insert(valRes1, buffid)
            end
        end
        return res, #verts, valRes, #valVer, valRes1, #valVer1
    end

    local function showValueSpAction(layer, mode)
        local z = -layer.rubRadius*2 + 1

        local wx = layer.cardWidth/2 - 60
        local wy = layer.cardHeight/2 - 20

        local tabPos = {
            [1.0] = {
                cc.vec3(-wx-12,-wy,z),
                cc.vec3(wx-12,wy,z),
                false,
                false,
            },
            [2.0] = {
                false,
                false,
                cc.vec3(-wy-9,wx,z),
                cc.vec3(wy,-wx,z),
            },
            [3.0] = {
                cc.vec3(-wx+3,-wy+11,z),
                cc.vec3(wx,wy+15,z),
                false,
                false,
            },
            [4.0] = {
                cc.vec3(-wx+10,-wy,z),
                cc.vec3(wx+10,wy,z),
                false,
                false,
            },
            [5.0] = {
                false,
                false,
                cc.vec3(-wy,wx,z),
                cc.vec3(wy+8,-wx,z),
            },
        }

        for i = 1, 4 do
            if tabPos[layer.mode][i] then
                local action = cc.FadeIn:create(0.3)
                layer['valSp'..i]:setPosition3D(tabPos[layer.mode][i])
                layer['valSp'..i]:stopAllActions()
                layer['valSp'..i]:runAction(action)
            end
        end
    end

    -- 创建搓牌效果层, pList:图片合集.plist文件, szBack:牌背面图片名, szFont:牌正面图片名, 注意：默认传入的牌在plist文件中是竖直的, scale缩放比
    local function createRubCardEffectLayer(pList, szBack, szFont, scale)
        scale = scale or 1.0

        -- 取得屏幕宽高
        local Director = cc.Director:getInstance()
        local WinSize = Director:getWinSize()

        -- 创建广角60度，视口宽高比是屏幕宽高比，近平面1.0，远平面1000.0，的视景体
        local camera = cc.Camera:createPerspective(45, WinSize.width / WinSize.height, 1, 1000)
        camera:setCameraFlag(cc.CameraFlag.USER2)
        --设置摄像机的绘制顺序，越大的深度越绘制的靠上，所以默认摄像机默认是0，其他摄像机默认是1, 这句很重要！！
        camera:setDepth(1)
        camera:setPosition3D(cc.vec3(0, 0, 800))
        camera:lookAt(cc.vec3(0, 0, 0), cc.vec3(0, 1, 0))

        -- 创建用于OpenGL绘制的节点
        local glNode = gl.glNodeCreate()
        -- local glProgram = cc.GLProgram:createWithByteArrays(strVertSource, strFragSource)
        local glProgram = cc.GLProgram:createWithFilenames('3d/card1.c3b', '3d/card2.c3b')
        glProgram:retain()
        glProgram:updateUniforms()

        -- 创建搓牌图层
        local layer = cc.Layer:create()
        layer:setCameraMask(cc.CameraFlag.USER2)
        layer:addChild(glNode)
        layer:addChild(camera)

        -- 退出时，释放glProgram程序
        local function onNodeEvent(event)
            if "exit" == event then
                Scheduler.delete(layer.updateF)
                glProgram:release()
            end
        end
        layer:registerScriptHandler(onNodeEvent)

        --------------------------------------------------------------------------------------------------------------------------------
        -- 触摸事件
        --创建触摸回调
        local posBegin = cc.p(0,0)
        local initMode = false
        local function touchBegin(touch, event)
            local location = touch:getLocation()
            posBegin = location
            return true
        end

        local function onMoveJ1(dx, dy)
            if initMode == 1.0 then 
                --右向左
                if layer.actionFlag == 0.0 then
                    layer.j1 = layer.j1 + dx
                    layer.j2 = layer.j1 + layer.halfRubPerimeter
                    if layer.j1 < (layer.cardWidth * 0.3) then
                        layer.actionOffX = layer.j1
                        layer.actionFrameCnt = math.ceil(layer.j1/dx)
                        layer.actionOffX1 = layer.cardWidth+layer.halfRubPerimeter
                        layer.actionOffY1 = 0
                        layer.actionFlag = 1.0
                    end
                elseif layer.actionFlag == 1.0 then
                    layer.j1 = layer.j1 - dx
                    layer.j2 = layer.j1 + layer.halfRubPerimeter
                    if layer.j2 < 0 then
                        layer.actionFlag = 2.0
                    end
                end

            elseif initMode == 2.0 then 
                --右下到左上
                if layer.actionFlag == 0.0 then
                    layer.j1 = layer.j1 + layer.k1*(-dx)
                    layer.j2 = layer.j1 + layer.k1*(-layer.rubLength)
                    if layer.j1 > -(layer.cardWidth*0.1) then
                        layer.actionOffX = layer.j1
                        layer.actionFrameCnt = math.abs(math.ceil(layer.j1/layer.k1*(-dx)))

                        local len3 = math.cos(math.rad(45))*layer.halfRubPerimeter
                        local len2 = (layer.cardWidth - layer.cardHeight)/2
                        layer.actionOffX1 = len2 + len3 + layer.cardHeight
                        layer.actionOffY1 = -(len3 + layer.cardHeight + len2)

                        layer.actionFlag = 1.0
                    end
                elseif layer.actionFlag == 1.0 then
                    layer.j1 = layer.j1 + layer.k1*(-dx*-1)
                    layer.j2 = layer.j1 + layer.k1*(-layer.rubLength)
                    if layer.j2 > (layer.cardHeight/math.tan(math.rad(45))) then
                        layer.actionFlag = 2.0
                    end
                end

            elseif initMode == 3.0 then 
                --下到上
                if layer.actionFlag == 0.0 then
                    layer.j1 = layer.j1 + dy
                    layer.j2 = layer.j1 - layer.halfRubPerimeter
                    if layer.j1 > (layer.cardHeight * 0.7) then
                        layer.actionOffY = layer.j1
                        layer.actionFrameCnt = math.abs(math.ceil(layer.j1/dy))

                        layer.actionOffX1 = 0
                        layer.actionOffY1 = -layer.cardHeight - layer.halfRubPerimeter

                        layer.actionFlag = 1.0
                    end
                elseif layer.actionFlag == 1.0 then
                    layer.j1 = layer.j1 + dy
                    layer.j2 = layer.j1 - layer.halfRubPerimeter
                    if layer.j2 > layer.cardHeight then
                        layer.actionFlag = 2.0
                    end
                end

            elseif initMode == 4.0 then 
                --左到右
                if layer.actionFlag == 0.0 then
                    print('layer.j1',layer.j1)
                    layer.j1 = layer.j1 + dx
                    layer.j2 = layer.j1 - layer.halfRubPerimeter
                    if layer.j1 > (layer.cardWidth * 0.7) then
                        layer.actionOffX = layer.j1
                        layer.actionFrameCnt = math.abs(math.ceil(layer.j1/dx))

                        layer.actionOffX1 = -layer.cardWidth - layer.halfRubPerimeter
                        layer.actionOffY1 = 0

                        layer.actionFlag = 1.0
                    end
                elseif layer.actionFlag == 1.0 then
                    layer.j1 = layer.j1 + dx
                    layer.j2 = layer.j1 - layer.halfRubPerimeter
                    if layer.j2 > (layer.cardWidth) then
                        layer.actionFlag = 2.0
                    end
                end

            elseif initMode == 5.0 then 
                --左下到右上
                if layer.actionFlag == 0.0 then
                    layer.j1 = layer.j1 + layer.k1*(-dx)
                    layer.j2 = layer.j1 + layer.k1*(layer.rubLength)
                    if layer.j1 > (layer.cardWidth*0.9) then
                        layer.actionFrameCnt = math.abs(math.ceil(layer.j1/layer.k1*(-dx)))
                        layer.actionOffX = layer.j1
                        
                        local len3 = math.cos(math.rad(45))*layer.halfRubPerimeter
                        local len2 = (layer.cardWidth - layer.cardHeight)/2
                        layer.actionOffX1 = len2 - (len3 + layer.cardWidth)
                        layer.actionOffY1 = -(len3 + layer.cardHeight + len2)

                        layer.actionFlag = 1.0
                    end
                elseif layer.actionFlag == 1.0 then
                    layer.j1 = layer.j1 + layer.k1*(-dx)
                    layer.j2 = layer.j1 + layer.k1*(layer.rubLength)
                    if layer.j2 > (layer.cardHeight/math.tan(math.rad(45)) + layer.cardWidth) then
                        layer.actionFlag = 2.0
                    end
                end
            end
        end

        local function touchMove(touch, event)
            local location = touch:getLocation()
            local dx = (location.x - posBegin.x)
            local dy = (location.y - posBegin.y)
            dx = dx * 1.0
            if initMode == 3.0 then
                dy = dy * 0.8
            else
                dy = dy * 1.0
            end
            print('dx',dx)
            if initMode == 1.0 then
                if layer.j1 < 420 then
                    dx = dx * layer.j1/730
                end
            end

            if initMode == 4.0 then
                if layer.j1 > 125 then
                    dx = dx * (-layer.j1 / 1100 + 0.65)
                else
                    dx = dx * 1.2
                end
            end

            
            if not initMode then
                local dt = math.sqrt(math.pow(dx,2) + math.pow(dy,2))
                if dt > layer.modeThreshold then
                    local angle = math.atan2(dy, dx)/math.pi*180
                    if angle >= -80 and angle < 22.5 then 
                        --左到右
                        initMode = 4.0
                        layer.mode = initMode
                        layer.k1 = 0.0
                        layer.j1 = 0.0
                        layer.j2 = layer.j1 - layer.halfRubPerimeter

                    elseif angle >= 22.5 and angle < 67.5 then 
                        --左下到右上
                        initMode = 5.0
                        layer.mode = initMode
                        layer.k1 = -1.0
                        layer.j1 = 0.0
                        layer.j2 = layer.k1*(-layer.rubLength)

                    elseif angle >= 67.5 and angle < 112.5 then 
                        --下到上
                        initMode = 3.0
                        layer.mode = initMode
                        layer.k1 = 0.0
                        -- layer.j1 = -layer.halfRubPerimeter
                        layer.j1 = 15.0
                        layer.j2 = layer.j1 - layer.halfRubPerimeter

                    elseif angle >= 112.5 and angle < 157 then 
                        --右下到左上
                        initMode = 2.0
                        layer.mode = initMode
                        layer.k1 = 1.0
                        layer.j1 = layer.k1*(-layer.cardWidth)
                        layer.j2 = layer.k1*(-1*(layer.cardWidth + layer.rubLength))

                    elseif (angle >= 157 and angle <=180) or (-180 <= angle and angle <= -120) then 
                        --右向左
                        initMode = 1.0 
                        layer.mode = initMode
                        layer.k1 = 0
                        layer.j1 = layer.cardWidth
                        layer.j2 = layer.j1 + layer.halfRubPerimeter

                    end
                    if initMode then
                        posBegin = location
                        print("initMode: ", initMode, " angle: ", angle)
                    end
                end
            else
                if layer.actionFlag > 0.0 then return end
                posBegin = location
                onMoveJ1(dx, dy)
            end
        end

        local function touchEnd(touch, event)
            if layer.actionFlag == 0.0 then
                initMode = false
                layer.mode = 4.0
                layer.k1 = 0.0
                layer.j1 = 0.0
                layer.j2 = layer.j1 - layer.halfRubPerimeter
                return true
            elseif layer.actionFlag == 1.0 then

            end
        end

        local listener = cc.EventListenerTouchOneByOne:create()
        listener:registerScriptHandler(touchBegin, cc.Handler.EVENT_TOUCH_BEGAN)
        listener:registerScriptHandler(touchMove, cc.Handler.EVENT_TOUCH_MOVED)
        listener:registerScriptHandler(touchEnd, cc.Handler.EVENT_TOUCH_ENDED)
        local eventDispatcher = layer:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)


        --------------------------------------------------------------------------------------------------------------------------------
        
        --创建牌的背面
        local id1, texRange1, sz1 = getTextureAndRange(szBack)
        local msh1, nVerts1 = initCardVertex(cc.size(sz1[1] * scale, sz1[2] * scale), texRange1, true)

        --创建牌的正面
        local id3, texRange3, sz3 = getTextureAndRange('3d/1' .. fileName .. '.png')

        local id2, texRange2, sz2 = getTextureAndRange(szFont)
        local msh2, nVerts2, msh3, nVerts3, msh4, nVerts4= initCardVertex(cc.size(sz2[1] * scale, sz2[2] * scale), texRange2, false, texRange3)
        
        
        --------------------------------------------------------------------------------------------------------------------------------
        --搓牌控制部分

        layer.cardWidth = sz1[1] * scale
        layer.cardHeight = sz1[2] * scale
        
        --确定方向
        layer.modeThreshold = 10.0

        layer.rubRadius = 30.0
        layer.halfRubPerimeter = layer.rubRadius*math.pi
        layer.rubPerimeter = layer.rubRadius*math.pi*2

        layer.rubLength = layer.halfRubPerimeter/math.cos(math.rad(45))

        layer.mode = 1.0
        layer.k1 = 0
        layer.j1 = layer.cardWidth
        layer.j2 = layer.j1 + (math.pi*layer.rubRadius)
    
        layer.actionFlag = 0.0
        layer.actionR = 0.0
        layer.actionStep = 10.0
        layer.actionOffX = 0.0
        layer.actionOffY = 0.0
        layer.actionOffZ = 0.0

        layer.actionOffX1 = 0.0
        layer.actionOffY1 = 0.0
        layer.actionOffZ1 = 0.0

        layer.actionStepZ = 0
        layer.actionStepZ1 = 0
        layer.actionFrameCnt = 0

        layer.offCx = 0
        layer.offCy = 0

        layer.flagShowValueSp = false

        -----------------------------------------------------------------------------
        --value sprite
        layer.offX = WinSize.width / 2 - layer.cardWidth/2
        layer.offY = WinSize.height / 2 - layer.cardHeight/2

        local sp1 = cc.Sprite:create('3d/1' .. fileName .. '.png')    -- 左
        sp1:setPosition3D(cc.vec3(-layer.cardWidth/2,-layer.cardHeight/2,0))
        -- sp1:setAnchorPoint(cc.p(0,0))
        sp1:setCameraMask(cc.CameraFlag.USER2)
        sp1:setScale(0.9)
        sp1:setOpacity(0)

        local sp2 = cc.Sprite:create('3d/1' .. fileName .. '.png')    -- 右
        sp2:setPosition3D(cc.vec3(layer.cardWidth/2,layer.cardHeight/2,0))
        sp2:setRotation(180)
        -- sp2:setAnchorPoint(cc.p(0,0))
        sp2:setCameraMask(cc.CameraFlag.USER2)
        sp2:setScale(0.9)
        sp2:setOpacity(0)

        local sp3 = cc.Sprite:create('3d/1' .. fileName .. '.png')    -- 上
        sp3:setPosition3D(cc.vec3(-layer.cardHeight/2,layer.cardWidth/2,0))
        sp3:setRotation(90)
        -- sp3:setAnchorPoint(cc.p(0,1))
        sp3:setCameraMask(cc.CameraFlag.USER2)
        sp3:setScale(0.9)
        sp3:setOpacity(0)

        local sp4 = cc.Sprite:create('3d/1' .. fileName .. '.png')    -- 下
        sp4:setPosition3D(cc.vec3(layer.cardHeight/2,-layer.cardWidth/2,0))
        sp4:setRotation(270)
        -- sp4:setAnchorPoint(cc.p(1,0))
        sp4:setCameraMask(cc.CameraFlag.USER2)
        sp4:setOpacity(0)
        sp4:setScale(0.9)


        layer:addChild(sp1)
        layer:addChild(sp2)
        layer:addChild(sp3)
        layer:addChild(sp4)
        layer.valSp1 = sp1
        layer.valSp2 = sp2
        layer.valSp3 = sp3
        layer.valSp4 = sp4
        

        -----------------------------------------------------------------------------
        --tick
        layer.finishTick1 = 0
        layer.finishTick2 = 0
        layer.flagHideLayer = false
        layer.updateF = Scheduler.new(function(dt)
            layer.finishTick1 = layer.finishTick1 + dt
            if layer.flagShowValueSp then
                layer.finishTick2 = layer.finishTick2 + dt
            end
            if layer.finishTick1 > 0 then
                if layer.actionFlag == 1.0 then 
                    onMoveJ1(layer.actionStep, layer.actionStep)
                    if layer.actionOffZ < layer.rubRadius*2 then
                        layer.actionOffZ = layer.actionOffZ + layer.actionStepZ
                        layer.actionStepZ = layer.actionStepZ + 0.05
                    end
                end
                if layer.actionFlag == 2.0 then 
                    if layer.actionOffZ >= -layer.rubRadius*2 then
                        layer.actionOffZ = layer.actionOffZ - layer.actionStepZ1
                        layer.actionStepZ1 = layer.actionStepZ1 + 0.6
                    elseif layer.flagShowValueSp == false then
                        layer.flagShowValueSp = true
                        -- showValueSpAction(layer)
                    end
                end
                layer.finishTick1 = 0
            end
            if layer.finishTick2 > 1.5 and layer.flagHideLayer == false then
                layer.flagHideLayer = true
                self:freshCuoPaiDisplay(false)
                self:onMessageState({msgID = 'clickFanPai'})
            end
        end)

        --------------------------------------------------------------------------------------------------------------------------------

        --牌的渲染信息
        local cardMesh = {{id1, msh1, nVerts1}, {id2, msh2, nVerts2}, {id3, msh3, nVerts3}, {id3, msh4, nVerts4}}
        -- OpenGL绘制函数
        local function draw(transform, transformUpdated)
            --开启表面裁剪
            gl.enable(gl.CULL_FACE)
            --使用此shader
            glProgram:use()
            --设置该shader的一些内置uniform,主要是MVP，即model-view-project矩阵
            glProgram:setUniformsForBuiltins()

            for idx, v in ipairs(cardMesh) do
                repeat
                    if idx > 2 and not layer.flagShowValueSp then break end
                
                gl.bindTexture(gl.TEXTURE_2D, v[1])--id

                -- 扑克尺寸
                local cardWidth = gl.getUniformLocation(glProgram:getProgram(), "cardWidth")
                glProgram:setUniformLocationF32(cardWidth, layer.cardWidth)
                local cardHeight = gl.getUniformLocation(glProgram:getProgram(), "cardHeight")
                glProgram:setUniformLocationF32(cardWidth, layer.cardHeight)

                -- 偏移牌，使得居中
                local offx = gl.getUniformLocation(glProgram:getProgram(), "offx")
                glProgram:setUniformLocationF32(offx, layer.offX)
                local offy = gl.getUniformLocation(glProgram:getProgram(), "offy")
                glProgram:setUniformLocationF32(offy, layer.offY)
                -- glProgram:setUniformLocationF32(offy, 100)

                -- 推进模式
                local mode = gl.getUniformLocation(glProgram:getProgram(), "mode")
                glProgram:setUniformLocationF32(mode, layer.mode)

                -- 弯曲半径
                local rubRadius = gl.getUniformLocation(glProgram:getProgram(), "rubRadius")
                glProgram:setUniformLocationF32(rubRadius, layer.rubRadius)

                -- j1 j2 k1
                local k1 = gl.getUniformLocation(glProgram:getProgram(), "k1")
                glProgram:setUniformLocationF32(k1, layer.k1)
                local j1 = gl.getUniformLocation(glProgram:getProgram(), "j1")
                glProgram:setUniformLocationF32(j1, layer.j1)
                local j2 = gl.getUniformLocation(glProgram:getProgram(), "j2")
                glProgram:setUniformLocationF32(j2, layer.j2)

                -- 结束动画
                local actionRad = gl.getUniformLocation(glProgram:getProgram(), "actionRadius")
                glProgram:setUniformLocationF32(actionRad, layer.actionR)
                local actionFlag = gl.getUniformLocation(glProgram:getProgram(), "actionFlag")
                glProgram:setUniformLocationF32(actionFlag, layer.actionFlag)

                local actionOffX = gl.getUniformLocation(glProgram:getProgram(), "actionOffX")
                glProgram:setUniformLocationF32(actionOffX, layer.actionOffX)
                local actionOffY = gl.getUniformLocation(glProgram:getProgram(), "actionOffY")
                glProgram:setUniformLocationF32(actionOffY, layer.actionOffY)
                local actionOffZ = gl.getUniformLocation(glProgram:getProgram(), "actionOffZ")
                glProgram:setUniformLocationF32(actionOffZ, layer.actionOffZ)

                local actionOffX1 = gl.getUniformLocation(glProgram:getProgram(), "actionOffX1")
                glProgram:setUniformLocationF32(actionOffX1, layer.actionOffX1)
                local actionOffY1 = gl.getUniformLocation(glProgram:getProgram(), "actionOffY1")
                glProgram:setUniformLocationF32(actionOffY1, layer.actionOffY1)
                local actionOffZ1 = gl.getUniformLocation(glProgram:getProgram(), "actionOffZ1")
                glProgram:setUniformLocationF32(actionOffZ1, layer.actionOffZ1)
                
                gl.glEnableVertexAttribs(bit._or(cc.VERTEX_ATTRIB_FLAG_TEX_COORDS, cc.VERTEX_ATTRIB_FLAG_POSITION))
                
                gl.bindBuffer(gl.ARRAY_BUFFER, v[2][1]) --msh
                gl.vertexAttribPointer(cc.VERTEX_ATTRIB_POSITION, 2, gl.FLOAT, false, 0, 0)
                
                gl.bindBuffer(gl.ARRAY_BUFFER, v[2][2]) --msh
                gl.vertexAttribPointer(cc.VERTEX_ATTRIB_TEX_COORD, 2, gl.FLOAT, false, 0, 0)
                
                gl.drawArrays(gl.TRIANGLES, 0, v[3]/2) --nVerts

                until true
            end
            gl.bindTexture(gl.TEXTURE_2D, 0)
            gl.bindBuffer(gl.ARRAY_BUFFER, 0)
        end

        glNode:registerScriptDrawHandler(draw)
        
        return layer
    end
    local layer = createRubCardEffectLayer("", backPath, cardPath, 0.8)
    self.cpLayer:addChild(layer, 999)
    self.rubLayer = layer
end

function SGDeskView:remove3dLayer()
    if self.rubLayer then
        self.rubLayer:removeFromParent()
        self.rubLayer = nil
    end
end

function SGDeskView:freshCuoPaiDisplay(bool, data)
    -- if device.platform == 'android' then --window上旧版搓牌
    -- if device.platform ~= 'ios' then --window上新版搓牌
    if device.platform == 'android' or device.platform == 'windows' or device.platform == 'ios' then 
        if bool then
            self:remove3dLayer()
            self:showCardsAtCuopai(data)
            self:init3dLayer(data[3])
            self.cpLayer:setVisible(true)
        else
            self:remove3dLayer()
            self.cpLayer:setVisible(false)
        end
    elseif device.platform == 'ios' then
        print("================ cuopai view ================")
        local cpLayer = self.MainPanel:getChildByName('cpLayer')
        self.cpLayer = cpLayer

        if bool and (self.cpLayer and not cpLayer:isVisible() and data) then
            print("show cuopai")
            local suit = self.suit_2_path[self:card_suit(data[3])]
            local rnk = self:card_rank(data[3]) or '_joker'
            self.paimian = suit .. rnk
            --print(' -> suit : ', suit, ' rnk : ', rnk)

            local card = cpLayer:getChildByName('card')
            card:setScale(1)
            self:showCardsAtCuopai(data)
            self:init3dLayer_ios(suit .. rnk)

            self.preIdx = 0
            self.preDifY = 0
            self.cardFlip = false
            self.card = card
            self.bBlockTouch = false

            card:addTouchEventListener(function(sender, type)
                if self.bBlockTouch then
                    return
                end
                
                if type == 0 then
                    -- begin

                    self.starpos = sender:getTouchBeganPosition()
                    local beganposition = self.starpos.y
                    self.beganposition = beganposition   
                    local x, y = card:getPosition()
                    self.orgPos = {x = x, y = y}

                elseif type == 1 then
                    local pos = sender:getTouchMovePosition()
                    local difX = self.starpos.x - pos.x
                    local difY = self.starpos.y - pos.y
                    local dify = self.beganposition - pos.y
                    local maxposition = self.beganposition
                    --新版控制灵敏度
                    maxposition = 640 - self.beganposition
                    if self.beganposition < 100 then
                        dify = dify * 1.6
                    elseif self.beganposition < 200 then 
                        dify = dify * 1.4
                    elseif self.beganposition < 300 then 
                        dify = dify * 1.2
                    end
                    self.difY = difY
                    self.dify = math.abs(dify)
                    if dify > 0 then dify = 0 end 
                    local getframes = math.abs(math.floor(dify * 50 / maxposition)) 
                    print("difY", difY, math.abs(difY))
                    print("getframes", getframes)
                    if math.abs(difY) >= 1 then                              
                        if difY > 0 then
                            if self.preIdx - 1 < 0 then return  end
                            self:freshCardMoveAction1('down', getframes, self.preIdx)
                            self.preIdx = getframes
                        else
                            self.maxdify = math.abs(dify)
                            if self.preIdx >= getframes then return end
                            self:freshCardMoveAction1('up', self.preIdx, getframes)
                            self.preIdx = getframes
                        end
                        self.starpos.y = pos.y
                    end
                else
                    -- end
                    if self.preIdx < 51 then
                        print("reset", self.preIdx)
                        self.bBlockTouch = true
                        self:freshCardMoveAction('reset', 0, self.preIdx)
                        self.preIdx = 0
                    end
                end
            end)
            self.cpLayer:setVisible(true)
        elseif (not bool) and (self.cpLayer and cpLayer:isVisible()) then
            print("hide cuopai")
            if self.layer3D then
                self.layer3D:removeFromParent(true)
                self.layer3D = nil
                self.card3d = nil
                self.card3d1 = nil
            end
            cpLayer:setVisible(false)
        end
    end
end

return SGDeskView
