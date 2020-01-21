local Scheduler = require('app.helpers.Scheduler')
local SoundMng = require('app.helpers.SoundMng')
local tools = require('app.helpers.tools')
local HeartbeatCheck = require('app.helpers.HeartbeatCheck')
local app = require("app.App"):instance()
local GameLogic = require('app.libs.zhajinhua.ZJHGameLogic')

local testluaj = nil
if device.platform == 'android' then
    testluaj = require('app.models.luajTest')--引入luajTest类
end

local SUIT_UTF8_LENGTH = 3

local ZJHDeskView = {}

function ZJHDeskView:initialize(ctrl) -- luacheck: ignore
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
    if desk and desk:getMaxPlayerCnt() == 8 then
        self.ui = View.loadUI('views/ZJHDeskView2.csb')
    elseif desk and desk:getMaxPlayerCnt() == 10 then
        self.ui = View.loadUI('views/ZJHDeskView3.csb')
    else
        self.ui = View.loadUI('views/ZJHDeskView.csb')
    end
    self:addChild(self.ui)

    --开始,继续,坐下 按钮位置
    self.tabBtnPos = {
        left = cc.p(430, 181.4),
        right = cc.p(710, 181.4),
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
        endPos = nil, -- cc.p
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
function ZJHDeskView:reloadState(toState)
    -- if self.state and self['onOut' .. self.state] then
    --     self['onOut' .. self.state](self)
    -- end
    self.next = toState
    self.state = toState
end

function ZJHDeskView:checkState()
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

function ZJHDeskView:setState(state)
    print(string.format('setState %s', self.state))
    self.next = state
    self:checkState()
end

function ZJHDeskView:updateState(dt)
    if self.state and self['onUpdate' .. self.state] then
        self['onUpdate' .. self.state](self, dt)
    end
end

function ZJHDeskView:onMessageState(msg)
    if self.state and self['onMessage' .. self.state] then
        self['onMessage' .. self.state](self, msg)
    end
end

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- state: Ready
function ZJHDeskView:onEnterReady(curState)
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

function ZJHDeskView:onOutReady(curState)
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
end

function ZJHDeskView:onUpdateReady(dt)
    -- 调整界面位置
    self:freshBtnPos()

    -- 刷新提示文本
    local played = self.desk:isGamePlayed()
    local canStart = (self.desk:getReadyPlayerCnt() >= 2)
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
            self:freshTip(true, string.format("等待 %s 开始游戏...", name))
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


function ZJHDeskView:onMessageReady(msg)
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
    end
end

function ZJHDeskView:onReloadReady(curState)
    if self.desk.tabPlayer then
        for uid, agent in pairs(self.desk.tabPlayer) do
            local viewKey, viewPos = agent:getViewInfo()
            self:freshReadyState(viewKey, agent:isReady())
        end
    end
    self:reloadState('Ready')
    self:onEnterReady()
end

function ZJHDeskView:freshIsCoin()
    if not self.desk.tabBaseInfo then return end
    local deskInfo = self.desk.tabBaseInfo.deskInfo
    if not deskInfo then return end
    for key, val in pairs(self.viewKey) do
        local seat = self.MainPanel:getChildByName(val)
        local img = seat:getChildByName('avatar'):getChildByName('point'):getChildByName('img')
        img:setVisible(deskInfo.roomMode == 'bisai')
    end
end

function ZJHDeskView:freshWatcherSp(bShow)
    bShow = bShow or false
    self.watcherStatusSp:setVisible(bShow)
end

function ZJHDeskView:freshWatcherBtn(bShow)
    bShow = bShow or false

    self.watcherSitdownBtn:setVisible(bShow)
    self.playerViews.msg:setVisible(not bShow)
    self.playerViews.voice:setVisible(not bShow)
end

function ZJHDeskView:onResponseSitdown(msg)
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

function ZJHDeskView:freshContinue(bool)
    local component = self.MainPanel:getChildByName('bottom')
    local continue = component:getChildByName('continue')
    continue:setVisible(bool)
end

function ZJHDeskView:freshPrepareBtn(bool)
    local btn = self.MainPanel:getChildByName('prepare')
    self.outerFrameBool = false
    btn:setVisible(bool)
end

function ZJHDeskView:freshBtnPos()
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

function ZJHDeskView:freshGameStartBtn(show, enable)
    local btn = self.MainPanel:getChildByName('gameStart')
    btn:setVisible(show)
    btn:setEnabled(enable)
end


function ZJHDeskView:freshAllReady(bool)
    bool = bool or false
    for _, v in pairs(self.viewKey) do
        self:freshReadyState(v, bool)
    end
end


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- state:StateStarting
function ZJHDeskView:onEnterStarting(curState)
    -- 重置座位界面
    for k, v in pairs(self.viewKey) do
        self:clearDesk(v)
    end

    self:freshRoomInfo(true)

end

function ZJHDeskView:onOutStarting(curState)

end

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- state:Dealing
function ZJHDeskView:onEnterDealing(curState)

end

function ZJHDeskView:onOutDealing(curState)

end

function ZJHDeskView:onMessageDealing(msg)
    if msg.msgID == 'bettingActionEnd' then
        -- self:showBettingActionEnd(msg.viewKey)
    end
end

function ZJHDeskView:onDealMsg(reload)
    if self.desk.tabPlayer then
        for uid, agent in pairs(self.desk.tabPlayer) do
            if agent:getInMatch() then
                local viewKey = agent:getViewInfo()
                local cardData = agent:getHandCardData()
                if cardData then
                    self:freshCards(viewKey, false, nil, 1, self.CARD_COUNT)
                else
                    self:freshCards(viewKey, false, nil, 1, self.CARD_COUNT)
                end
                if not reload then
                    self:showCardsAction(viewKey, 1, self.CARD_COUNT)
                else
                    if agent:getSeeCard() then
                        self:freshCards(viewKey, true, cardData, 1, self.CARD_COUNT)
                    else
                        self:freshCards(viewKey, true, nil, 1, self.CARD_COUNT)
                    end
                end
            end
        end
    end
end

-- 隐藏所有扑克
function ZJHDeskView:freshAllCards()
    for k, v in pairs(self.viewKey) do
        self:freshCards(v, false, nil, 1, self.CARD_COUNT)
    end
end

function ZJHDeskView:freshCards(name, show, data, head, tail, noTexture)
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

function ZJHDeskView:showCardsAction(name, head, tail) -- virtual
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

        local sc = cc.ScaleTo:create(duration, 1)
        local sq = cc.Sequence:create(dtime, sc)
        card:setScale(0.7)
        card:runAction(sq)

    end
end

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- state:PutMoney
function ZJHDeskView:onEnterPutMoney(reload)
    if self.desk:getMeAgent() then
        -- 刷新自动跟注界面
        self:freshAutoGenzhuLayer(true)
        -- 刷新搓牌按钮和亮牌按钮
        local deskInfo = self.desk:getDeskInfo()
        local enableCuopai = GameLogic.isEnableCuoPai(deskInfo)
        self:freshCuoButton(enableCuopai)
        self:freshOpBtns(true, false)
    end


    if reload then
        local gameplay = self.desk.gameplay
        if not gameplay then return end
        local meUid = app.session.user.uid
        self:showOutFrame()
        local currentPlayer = gameplay:getCurrentPlayer()
        if currentPlayer then
            if meUid == currentPlayer then
                self:freshBettingBar(true)
                local tick = self.desk:getTick()
                self:freshTip(true, '请下注:', tick)
                return
            elseif self.desk:getMeAgent() then
                local meAgent = self.desk:getMeAgent()
                if not meAgent:getAbandons() and not meAgent:getCompareLose() then
                    self:freshBettingBar(true, true)
                else
                    self:freshBettingBar(false)
                    self:freshOpBtns(false, false)
                end
            end
        end
    else
        if self.desk:getMeAgent() then
            local meAgent = self.desk:getMeAgent()
            if not meAgent:getAbandons() and not meAgent:getCompareLose() then
                self:freshBettingBar(true, true)
            else
                self:freshBettingBar(false)
                self:freshOpBtns(false, false)
            end
        end
    end
    local tick = self.desk:getTick()
    self:freshTip(true, '等待其他玩家下注:', tick)

end

function ZJHDeskView:onOutPutMoney(curState)
    for i, v in ipairs(self.coinSprite) do
        local rmvSelf = cc.RemoveSelf:create()
        v:runAction(rmvSelf)
        self.coinSprite[i] = nil
    end

    self:showCompareAni(false)
    self:freshBettingBar(false)
    self:hideAllOutFrame()
    self:freshTip(false)
    self:freshAutoGenzhuLayer(false)
    self:freshOpBtns(false, nil)
end

function ZJHDeskView:onUpdatePutMoney(dt)

end

function ZJHDeskView:onReloadPutMoney(reload)
    local gameplay = self.desk.gameplay
    if not gameplay then return end

    -- 押注过程
    if self.desk.tabPlayer then
        for uid, agent in pairs(self.desk.tabPlayer) do
            local viewKey = agent:getViewInfo()
            if agent:getInMatch() then
                self:showBettingActionEnd(viewKey)
            end
            if agent:getCompareLose() then
                self:freshQipai(viewKey, true, true)
            elseif agent:getAbandons() then
                self:freshQipai(viewKey, true)
            end
        end
    end

    self:reloadState('PutMoney')
    self:onEnterPutMoney(reload)
end

function ZJHDeskView:onMessagePutMoney(msg)
    if msg.msgID == 'somebodyPutMoney' then
        local viewKey = msg.info.viewKey
        local meAgent = self.desk:getMeAgent()
        local meViewkey = nil
        if meAgent then
            meViewkey = meAgent:getViewInfo()
            if viewKey == meViewkey then
                self:freshBettingBar(true, true)
            end
        end

        local tick = self.desk:getTick()
        self:freshTip(true, '等待其他玩家下注:', tick)
        if msg.mode == 1 or msg.mode == 2 then
            self:showBettingAction(viewKey, true)
        elseif msg.mode == 4 then
            if viewKey == meViewkey then
                self:freshBettingBar(false)
                self:freshOpBtns(false, false)
            end
            self:freshQipai(viewKey, true)
        elseif msg.mode == 5 then
            self:showCompareAni(false)
            self:showBettingAction(viewKey, true)
            if msg.info and msg.compareInfo then
                self:startCompareCardAni(msg.info.player, msg.compareInfo.player, msg.compareResult)
            end
        end
        self:playEftOption(viewKey, msg.mode)
        self:freshJackpot()

    elseif msg.msgID == 'somebodySeeCard' then
        local viewKey = msg.info.viewKey
        local meAgent = self.desk:getMeAgent()
        if meAgent then
            local meViewkey = meAgent:getViewInfo()
            if viewKey == meViewkey then
                local cards = meAgent:getHandCardData()
                -- self:freshCuoPaiDisplay(true, cards)
                self:freshCards(viewKey, true, cards, 1, self.CARD_COUNT)
                self:freshOpBtns(false, false)
            end
        end
        self:playEftOption(viewKey, 3)

    elseif msg.msgID == 'clickCuoPai' then
        if not self.desk:isMeInMatch() then return end
        local agent = self.desk:getMeAgent()
        local handCardData = agent:getHandCardData()
        self:freshCuoPaiDisplay(true, handCardData)

    elseif msg.msgID == 'putMoney' then
        local tick = self.desk:getTick()
        self:freshTip(true, '请下注:', tick)
        self:freshBettingBar(true)

    elseif msg.msgID == 'nextPlayer' then
        self:showOutFrame()
        self:freshCompareRound()
        self:freshCuoPaiDisplay(false, nil)

    elseif msg.msgID == 'bettingActionEnd' then
        self:showBettingActionEnd(msg.viewKey)

    elseif msg.msgID == 'showCoinFlayActionEnd' then
        self:showCoinFlayActionEnd(msg.start, msg.dest)
    
    elseif msg.msgID == 'cpBack' then
        -- 搓牌回调
        if not self.desk:isMeInMatch() then return end
        local meAgent = self.desk:getMeAgent()
        if meAgent then
            local cards = meAgent:getHandCardData()
            self:freshCards('bottom', true, cards, 1, self.CARD_COUNT)
        end

    elseif msg.msgID == 'summary' then
        self:freshTip(false)
        self.flagEftSummary = false
        self:onSummary()
    end
end

function ZJHDeskView:freshJackpot()
    local topbar = self.MainPanel:getChildByName('topbar')
    local info = topbar:getChildByName('info')
    local JackpotNode = info:getChildByName('Jackpot')
    if not self.desk.gameplay then return end
    local jackpot = self.desk.gameplay:getJackpot()
    JackpotNode:setString("池底:" .. jackpot)
end

function ZJHDeskView:freshCompareRound()
    local topbar = self.MainPanel:getChildByName('topbar')
    local info = topbar:getChildByName('info')
    local node = info:getChildByName('putmoney')
    if not self.desk.gameplay then return end
    local compareRound = self.desk.gameplay:getCompareRound()
    node:setString("轮数:第" .. compareRound .. '轮')
end

-- 下注按钮界面
function ZJHDeskView:freshBettingBar(bool, isMe)
    local betting = self.MainPanel:getChildByName('betting')

    local function freshJiazhuList(putInfo, canPut, hasSeeCard)
        for i = 1, 8 do
            local btn = self.jiazhuList:getChildByName(tostring(i))
            btn:setVisible(false)
        end

        if putInfo then
            local len = #putInfo

            for k, v in ipairs(putInfo) do
                local btn = self.jiazhuList:getChildByName(tostring(k))
                btn:setVisible(true)
                local val = btn:getChildByName('text')
                val:setString(v * (hasSeeCard and 2 or 1))

                if canPut[k] then
                    btn:setEnabled(true)
                else
                    btn:setEnabled(false)
                end

                btn:addClickEventListener(function()
                    self.emitter:emit('clickBet', v)
                end)
            end

            local item = self.jiazhuList:getChildByName(tostring(1))
            local margin = self.jiazhuList:getItemsMargin()
            local itemWidth = item:getContentSize().width * item:getScaleX() * betting:getScaleX() * self.jiazhuList:getScaleX()
            local listWidth = (itemWidth * len) + (margin * (len - 1))
            local posX = display.width - listWidth
            self.jiazhuList:setPositionX(posX)
        end
    end

    if bool then
        if not isMe then
            betting:getChildByName('1'):setEnabled(true)
            betting:getChildByName('2'):setEnabled(true)
            betting:getChildByName('3'):setEnabled(true)
            betting:getChildByName('5'):setEnabled(true)

            local deskInfo = self.desk:getDeskInfo()
            local meAgent = self.desk:getMeAgent()
            if not meAgent then return end
            local putInfo = meAgent:getThisPutOpt()
            if not putInfo then return end
            local hasSeeCard = meAgent:getSeeCard()
            local maxPut = self.desk.gameplay:getMaxPut()
            local compareRound = self.desk.gameplay:getCompareRound()

            -- 比牌轮数
            if GameLogic.getCompareRound(deskInfo) >= compareRound then
                betting:getChildByName('5'):setEnabled(false)
            end

            -- 闷牌轮数
            if GameLogic.getBlindRound(deskInfo) >= compareRound then
                betting:getChildByName('3'):setEnabled(false)
            end

            if deskInfo.roomMode == 'normal' then
                local canPut = {}
                local cnt, putInfoCnt = 0, 0
                for i, v in ipairs(putInfo) do
                    if maxPut < v then
                        table.insert(canPut, true)
                    else
                        table.insert(canPut, false)
                        cnt = cnt + 1
                    end
                    putInfoCnt = putInfoCnt + 1
                end
                if cnt == putInfoCnt then
                    betting:getChildByName('2'):setEnabled(false)
                end
                freshJiazhuList(putInfo, canPut, hasSeeCard)
            elseif deskInfo.roomMode == 'bisai' then
                local putScore = meAgent:getPutscore() or 0
                local groupScore = meAgent:getGroupScore() or 0
                local restScore = groupScore - putScore
                print("maxPut", maxPut, "putScore", putScore, "groupScore", groupScore)

                if restScore < (maxPut * (hasSeeCard and 2 or 1)) then
                    -- 分数不够跟注的人不能跟注或加注 只能弃牌
                    -- 已看牌的人需要下双倍
                    betting:getChildByName('1'):setEnabled(false)
                    betting:getChildByName('2'):setEnabled(false)
                    betting:getChildByName('3'):setEnabled(false)
                    betting:getChildByName('5'):setVisible(false)
                end

                if deskInfo.advanced[7] and deskInfo.advanced[7] > 0 then
                    -- 比牌双倍
                    if restScore < (maxPut * 2 * (hasSeeCard and 2 or 1)) then
                        betting:getChildByName('5'):setVisible(false)
                    end
                end

                local canPut = {}
                local cnt, putInfoCnt = 0, 0
                for i, v in ipairs(putInfo) do
                    if maxPut < v and restScore > (v * (hasSeeCard and 2 or 1)) then
                        table.insert(canPut, true)
                    else
                        table.insert(canPut, false)
                        cnt = cnt + 1
                    end
                    putInfoCnt = putInfoCnt + 1
                end
                if cnt == putInfoCnt then
                    betting:getChildByName('2'):setEnabled(false)
                end

                freshJiazhuList(putInfo, canPut, hasSeeCard)
            end
        else
            betting:getChildByName('1'):setEnabled(false)
            betting:getChildByName('2'):setEnabled(false)
            betting:getChildByName('3'):setEnabled(false)
            betting:getChildByName('5'):setEnabled(false)
        end
    end

    if not bool or (bool and isMe) then
        self:freshJiaZhuLayer(0)
    end

    betting:setVisible(bool)
end

-- 显示下注动画
function ZJHDeskView:showBettingAction(name, bool)
    local component = self.MainPanel:getChildByName(name)
    local avatar = component:getChildByName('avatar')
    local multiple = avatar:getChildByName('multiple')
    local num = multiple:getChildByName('num')
    local panel = self.MainPanel:getChildByName('topbar'):getChildByName('info'):getChildByName('panel')

    -- multiple:setVisible(false)

    local function getStartPos(name)
        local frame = avatar:getChildByName('frame')
        local headimg = frame:getChildByName('headimg')
        local pos = frame:convertToWorldSpace(cc.p(headimg:getPosition()))
        return pos
    end

    local function getDestPos(name)
        local x, y = panel:getPosition()
        local size = panel:getContentSize()
        self.randomseedNum = self.randomseedNum or os.time()
        math.randomseed(self.randomseedNum)
        self.randomseedNum = math.random(1, os.time())
        local randx = math.random(x, x + size.width)
        local randy = math.random(y, y + size.height)
        local pos = self.MainPanel:getChildByName('topbar'):getChildByName('info'):convertToWorldSpace(cc.p(randx, randy))
        return pos
    end

    local start = getStartPos(name)

    -- 获取下注分数
    local info = self.desk:getPlayerInfo(nil, name)
    if not info then return end
    local putScore = info.player:getThisPut()

    for i = 1, 1 do
        local sprite = cc.Sprite:create('views/nysdesk/chouma.png')
        sprite:setVisible(false)
        sprite:setScale(1)
        self:addChild(sprite)

        table.insert(self.coinSprite, sprite)

        sprite:setPosition(start)

        local dest = getDestPos(name)
        -- dump(dest)

        local delay = cc.DelayTime:create(0.05 * i) 
        local moveTo = cc.MoveTo:create(0.4, dest)
        local show = cc.Show:create()

        local eft = cc.CallFunc:create(function()
            if i == 1 then
                self:playEftBet(bool)
            end
        end)
        local callBack = cc.CallFunc:create(function()
            if i == 1 then
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
            retainTime
            -- rmvSelf
        )   

        sprite:runAction(sequence)
    end
end

function ZJHDeskView:freshJiaZhuLayer(num)
    if not num then
        local bool = self.jiazhuList:isVisible()
        self.jiazhuList:setVisible(not bool)
    else
        self.jiazhuList:setVisible(num == 1)
    end
end

function ZJHDeskView:showOutFrame()
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

function ZJHDeskView:hideAllOutFrame()
    local viewkeyData = self.desk:getViewKeyData()
    for i, v in pairs(viewkeyData) do
        self:freshOutFrame(v, false)
    end
end

function ZJHDeskView:freshOutFrame(viewkey, bool)
    local component = self.MainPanel:getChildByName(viewkey)
    local avatar = component:getChildByName('avatar')
    local frame = avatar:getChildByName('frame')
    local outerFrame = frame:getChildByName('outerFrame')
    outerFrame:setVisible(bool)
end

function ZJHDeskView:showBettingActionEnd(name)
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
    if putScore and putScore > 0 then
        self:freshBetting(name, true, putScore)
        if self.desk.tabBaseInfo and self.desk.tabBaseInfo.deskInfo and self.desk.tabBaseInfo.deskInfo.roomMode == 'bisai' then
            self:freshAllRoundScore(name, 0, wGroupScore - putScore)
        end
    else
        self:freshBetting(name, false)
    end
end

-- 刷新下注信息
function ZJHDeskView:freshBetting(name, bool, value)
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
function ZJHDeskView:hideAllQipai()
    local viewkeyData = self.desk:getViewKeyData()
    for i, v in pairs(viewkeyData) do
        self:freshQipai(v, false)
    end
end

--刷新弃牌标志
function ZJHDeskView:freshQipai(viewKey, bool, isCompareLose)
    local loseFlag = self.MainPanel:getChildByName(viewKey):getChildByName('avatar'):getChildByName('frame'):getChildByName('lose')
    if bool then
        loseFlag:setTexture('views/nysdesk/qipai.png')
        if isCompareLose then
            loseFlag:setTexture('views/nysdesk/zjh/lose.png')
        end
    end
    loseFlag:setVisible(bool)
end

-- 刷新比牌动画界面
function ZJHDeskView:showCompareAni(bool)
    local meAgent = self.desk:getMeAgent()
    if not meAgent then return end
    if self.desk.tabPlayer then
        for uid, agent in pairs(self.desk.tabPlayer) do
            if agent:getInMatch() then
                local viewKey = agent:getViewInfo()
                local seat = self.MainPanel:getChildByName(viewKey)
                if viewKey ~= 'bottom' then
                    local compare = seat:getChildByName('compare')
                    local node = compare:getChildByName('compareAni')
                    node:stopAllActions()
                    compare:setVisible(false)
                    if bool and not agent:getAbandons() and not agent:getCompareLose() then
                        local action = cc.CSLoader:createTimeline("views/animation/Compare1.csb")
                        if viewKey == 'right' or viewKey == 'topright' or viewKey == 'rightmid' or viewKey == 'righttop' then
                            action = cc.CSLoader:createTimeline("views/animation/Compare2.csb")
                        end

                        if self.desk:getMaxPlayerCnt() == 10 then
                            if viewKey == 'right' or viewKey == 'rightmid' or viewKey == 'left' or viewKey == 'leftmid' then
                                action = cc.CSLoader:createTimeline("views/animation/Compare3.csb")
                            end
                        end

                        action:gotoFrameAndPlay(0, true)
                        action:setTimeSpeed(1.3)
                        node:stopAllActions()
                        node:runAction(action)
                        compare:setVisible(true)
                    end
                end
            end
        end
    end
end

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- state:Compare
function ZJHDeskView:onEnterCompare(curState)
    self:showCompareAni(false)
    self:freshAutoGenzhuLayer(false)
end

function ZJHDeskView:onOutCompare(curState)
    self:showCompareAni(false)
    self:freshAutoGenzhuLayer(false)
end

function ZJHDeskView:onMessageCompare(msg)
    if msg.msgID == 'bettingActionEnd' then
        self:showBettingActionEnd(msg.viewKey)

    elseif msg.msgID == 'compareResult' then
        self:startCompareCardAni(msg.leftInfo, msg.rightInfo, msg.isLeftWin)

    elseif msg.msgID == 'showCoinFlayActionEnd' then
        self:showCoinFlayActionEnd(msg.start, msg.dest)

    elseif msg.msgID == 'summary' then
        self:freshTip(false)
        self.flagEftSummary = false
        self:onSummary()
    end
end

function ZJHDeskView:onUpdateCompare()

end

function ZJHDeskView:onReloadCompare()

end
--------------------------------------------------------------------------------------------
function ZJHDeskView:showCoinFlayActionEnd(start, dest)
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

function ZJHDeskView:showCoinFlayActionEnd_NOChouma(name)
    local info = self.desk:getPlayerInfo(nil, name)
    if not info then return end 
    local score = info.player:getScore()
    local groupScore = info.player:getGroupScore() or 0
    if not score then return end

    self:freshOneRoundScore(name, true, score)

    local money = info.player:getMoney()
    self:freshAllRoundScore(name, money, groupScore)
end

-- 隐藏所有单局得分界面
function ZJHDeskView:freshAllOneRoundScore()
    for k, v in pairs(self.viewKey) do
        self:freshOneRoundScore(v, false)
    end
end

function ZJHDeskView:onSomebodyShowCards(agent, flag)
    local viewKey = agent:getViewInfo()
    if not flag then
        local cards = agent:getHandCardData()
        if not cards then return end
        local sex = agent:getSex()
        self:freshCards(viewKey, true, cards, 1, self.CARD_COUNT)
        local choose, cnt, spType = agent:getChoosed()
        if not cnt then return end
        self:freshSeatCardType(viewKey, true, false, cnt, spType)
        -- self:freshSeatMul(viewKey, true, cnt, spType)
        self:playEftCardType(sex,cnt,spType)
        self:freshSeatFireworks(viewKey, true, cnt, spType)
    
        if viewKey == 'bottom' then
            self:freshOpBtns(false, false)
        end
    else
        if viewKey == 'bottom' then
            self:freshOpBtns(false, true)
        end
    end
end

function ZJHDeskView:onSummary() -- virtual
    local function showCard(agent)
        -- 显示结果
        local viewKey = agent:getViewInfo()
        local cards = agent:getSummaryCardData()
        local sex = agent:getSex()
        self:freshCards(viewKey, true, cards, 1, self.CARD_COUNT)
        local choose, cnt, spType = agent:getChoosed()
        if not cnt then return end
        self:freshSeatCardType(viewKey, true, false, cnt, spType)
        -- self:freshSeatMul(viewKey, true, cnt, spType)
        self:playEftCardType(sex,cnt,spType)
        self:freshSeatFireworks(viewKey, true, cnt, spType)
    end

    local tabScoreData = {}

    if not self.desk.tabPlayer then return end

    -- 显示自己扑克
    local meAgent = self.desk:getMeAgent()
    if meAgent then
        showCard(meAgent)
    end

    local maxAgent = nil
    for uid, agent in pairs(self.desk.tabPlayer) do
        if agent:getInMatch() then
            -- 显示扑克
            local viewKey = agent:getViewInfo()
            local score = agent:getScore()
            table.insert(tabScoreData, { viewKey, score })
            if agent:getHasCompare() then
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
        if s1[2] > 0 then
            self:showCoinFlayAction(s1[1], s1[1], actionDelay)
        else
            self:showCoinFlayActionEnd_NOChouma(s1[1])
        end
        actionDelay = actionDelay + 0.3
    end
end

-- 金币飞行动画
function ZJHDeskView:showCoinFlayAction(start, dest, delay)
    local panel = self.MainPanel:getChildByName('topbar'):getChildByName('info'):getChildByName('panel')
    local coinCnt = 5
    delay = delay or 0

    local getPos = function(name)
        local seat = self.MainPanel:getChildByName(name)
        local avatar = seat:getChildByName('avatar')
        local frame = avatar:getChildByName('frame')
        local headimg = frame:getChildByName('headimg')
        local pos = frame:convertToWorldSpace(cc.p(headimg:getPosition()))
        return pos
    end

    local function getStartPos()
        local x, y = panel:getPosition()
        local size = panel:getContentSize()
        math.randomseed(cc.Director:getInstance():getTimeInMilliseconds())
        local randx = math.random(x, x + size.width)
        local randy = math.random(y, y + size.height)
        local pos = self.MainPanel:getChildByName('topbar'):getChildByName('info'):convertToWorldSpace(cc.p(randx, randy))
        return pos
    end

    math.randomseed(os.time())

    for i = 1, coinCnt do
        local sprite = cc.Sprite:create('views/nysdesk/chouma.png')
        sprite:setVisible(false)
        sprite:setScale(1)
        self:addChild(sprite)

        local posStart = getStartPos()
        sprite:setPosition(posStart)

        local d = 0
        if bankerSeat and start == bankerSeat then
            d = 1
        end

        local destPos = cc.p(getPos(dest))
        destPos = cc.p(destPos.x + math.random(-20, 20), destPos.y + math.random(-20, 20))
        local time = cc.pGetDistance(posStart, destPos) / 1500

        local delayAction = cc.DelayTime:create(0.05 * i + d + delay)
        local moveTo = cc.MoveTo:create(time, destPos)
        local show = cc.Show:create()
        -- local vol = cc.CallFunc:create(function()
        --     SoundMng.playEftEx('desk/jinbi.mp3')
        -- end)
        local bezier = {
            cc.p(getPos(start)),
            { display.cx, display.cy },
            cc.p(getPos(dest))
        }

        --local bezierTo = cc.BezierTo:create(0.8, bezier)
        local eft = cc.CallFunc:create(function()
            if i == 1 then
                SoundMng.playEft('desk/coins_fly.mp3')
            end
        end)
        local call = function()
            -- self.emitter:emit('showCoinFlayActionEnd',
            -- {
            --     msgID = 'showCoinFlayActionEnd',
            --     start = start,
            --     dest = dest,
            -- })
            self:showCoinFlayActionEnd_NOChouma(dest)
        end
        local rmvSelf = cc.RemoveSelf:create()
        local retainTime = cc.DelayTime:create(1)
        local sequence = cc.Sequence:create(delayAction, show, moveTo, eft, cc.CallFunc:create(call), retainTime, rmvSelf)
        sprite:runAction(sequence)
    end
end

function ZJHDeskView:showWinAction(name)
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
function ZJHDeskView:freshAllRoundScore(name, score, groupScore)
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
function ZJHDeskView:freshOneRoundScore(name, bool, score)
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
function ZJHDeskView:freshSeatCardType(name, bool, wcIcon, niuCnt, spcialType)
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
        path = 'views/xydesk/result/zjh/' .. specialType .. '.png'
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
function ZJHDeskView:freshSeatFireworks(name, bool, niu, special)
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
function ZJHDeskView:freshSeatMul(name, show, niuCnt, specialType)

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
        local path = string.format("views/xydesk/numbers/yellow/%s.png", mul)
        if specialType > 0 or niuCnt == 10 then
            path = string.format("views/xydesk/numbers/red/%s.png", mul)
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

function ZJHDeskView:freshCuoButton(bool)
    local component = self.MainPanel:getChildByName('bottom')
    local opt = component:getChildByName('opt')
    local step1 = opt:getChildByName('step1') --搓牌/翻牌
    local cuo = step1:getChildByName('cuo') --搓牌
    cuo:setVisible(bool)
end


-- 提示/亮牌, 搓牌/翻牌 按钮刷新
function ZJHDeskView:freshOpBtns(sv1, sv2)
    local component = self.MainPanel:getChildByName('bottom')
    local opt = component:getChildByName('opt')
    local step1 = opt:getChildByName('step1') --搓牌/翻牌
    step1:setVisible(sv1)
    if sv2 ~= nil then
        local step2 = opt:getChildByName('step2') --提示/亮牌
        step2:setVisible(sv2)
    end
end

-- ==================== agent =========================
function ZJHDeskView:freshMoney(name, money, groupScore)
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
function ZJHDeskView:freshSeat(name, bool)
    local component = self.MainPanel:getChildByName(name)
    component:setVisible(bool)
end


-- ==================== private =========================
function ZJHDeskView:onExit()
    if self.updateF then
        Scheduler.delete(self.updateF)
        self.updateF = nil
    end
    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
    end
end

function ZJHDeskView:update(dt)
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

function ZJHDeskView:onPing()
    self.heartbeatCheck:onPing()
end

function ZJHDeskView:sendHeartbeatMsg(dt)
    if not self.pauseHeartbeat then
        self.heartbeatCheck:update(dt)
    end
end

function ZJHDeskView:layout(desk)
    self.desk = desk
    self.viewKey = self.desk:getViewKeyData()

    -- 玩法
    local deskInfo = self.desk:getDeskInfo()
    self.CARD_COUNT = 3

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
    btn:setPosition(cc.p(26, 569))
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

    --wanfa view
    self.wanfaLayer = self.MainPanel:getChildByName('wanfa')

    -- init control view
    self.playerViews = {}
    self.playerViews.msg = self.MainPanel:getChildByName('msg')
    self.playerViews.voice = self.MainPanel:getChildByName('voice')
    --self.playerViews.prepare = self.MainPanel:getChildByName('prepare')
    --self.playerViews.gameStart = self.MainPanel:getChildByName('gameStart')
    --self.playerViews.invite = self.MainPanel:getChildByName('invite')

    local bottom = self.MainPanel:getChildByName('bottom')
    self.playerViews.continue = bottom:getChildByName('continue')
    self.playerViews.betting = self.MainPanel:getChildByName('betting')
    self.jiazhuList = self.playerViews.betting:getChildByName('jiazhuList')


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

    -- 记录创建的所有筹码精灵
    self.coinSprite = {}

    -- 记录所有扑克位置
    self.cardsOrgPos = {}
    for key, val in pairs(self.viewKey) do
        local seat = self.MainPanel:getChildByName(val)
        local cardsNode = seat:getChildByName('cards')
        self.cardsOrgPos[val] = {}
        for i = 1, self.CARD_COUNT do
            local card = cardsNode:getChildByName('card' .. i)
            if val == "bottom" then
                local x, y = card:getPosition()
                self.cardsOrgPos[val][i] = cc.p(x, y)
            else
                local x, y = 64 + 111 * (i - 1) , 88
                self.cardsOrgPos[val][i] = cc.p(x, y)
            end
        end
        if val == "bottom" then
            local cards_mini = bottom:getChildByName('cards_mini')
            self.cardsOrgPos['mini'] = {}
            for i = 1, self.CARD_COUNT do
                local x, y = 64 + 111 * (i - 1) , 88
                self.cardsOrgPos['mini'][i] = cc.p(x, y)
            end
        end
    end

    -- 隐藏界面
    self:freshWatcherBtn(false)
    self:freshWatcherSp(false)
    self:freshPrepareBtn(false)
    self:freshGameStartBtn(false, false)
    self:freshAutoGenzhuLayer(false)

    -- 是否比赛场(金币场)
    self:freshIsCoin()

    self:freshBtnPos()

    --刷新电量等信息
    self:freshDeviceInfo()

    --牌九看牌中途变量
    self.tempPos = {}

    --下注量
    self.PutmoneyData = {}

    --添加监听层
    local listenpanel = self.MainPanel:getChildByName('Panel')
    listenpanel:setSwallowTouches(false)
    listenpanel:addClickEventListener(function()
        print("click--------------------------------------------")
        self.nowtime = os.time()
    end)
end

function ZJHDeskView:changeDesktop(idx)
    idx = idx or 4
    local path = ''
    path = 'views/nysdesk/brbg' .. idx .. '.png'
    self.MainPanel:getChildByName('bg'):loadTexture(path)
    self:setCurDesktop(idx)
end

function ZJHDeskView:setCurDesktop(idx)
    local app = require("app.App"):instance()
    app.localSettings:set('desktop', idx)
end

function ZJHDeskView:getCurDesktop()
    local app = require("app.App"):instance()
    local idx = app.localSettings:get('desktop')
    return idx or 2
end

function ZJHDeskView:getCurCuoPai()
    local app = require("app.App"):instance()
    local idx = app.localSettings:get('cuoPai')
    idx = idx or 1
    return idx
end

function ZJHDeskView:changeCardBack()
    local backIdx = self:getCurCuoPai()
    for k, v in pairs(self.tabCardsTexture) do
        for n, m in pairs(v) do
            if m == 'back' then
                self:freshCardsTexture(k, n, nil, backIdx)
            end
        end
    end
end

-- 游戏重连，场景恢复
function ZJHDeskView:recoveryDesk(desk, reload)

    self.nowtime = os.time()

    --退出当前状态
    if self.state and self['onOut' .. self.state] then
        self['onOut' .. self.state](self)
    end

    -- 桌子信息
    local deskInfo = self.desk:getDeskInfo()
    self:freshRoomInfo(true)

    for k, v in pairs(self.viewKey) do
        self:clearDesk(v)
        self:resetPlayerView(v)
    end

    -- 奖池信息
    self:freshJackpot()

    --当前轮数
    self:freshCompareRound()

    -- 隐藏弃牌标志
    self:hideAllQipai()

    -- 玩家基本信息
    if self.desk.tabPlayer then
        for uid, agent in pairs(self.desk.tabPlayer) do
            local actor = agent.actor
            local viewKey, viewPos = agent:getViewInfo()
            local groupScore = agent:getGroupScore() or 0
            local putScore = agent:getPutscore() or 0
            self:freshHeadInfo(viewKey, actor)
            if self.state == 'Ready' then
                self:freshMoney(viewKey, agent:getMoney(), groupScore)
            else
                self:freshMoney(viewKey, agent:getMoney(), groupScore - putScore)
            end
            self:freshSeat(viewKey, true)
            self:freshEnterBackground(viewKey, agent:isEnterBackground() or false)
            self:freshDropLine(viewKey, agent:isDropLine() or false)
            self:freshTrusteeshipIcon(viewKey, agent:getTrusteeship() or false)

            if viewKey == 'bottom' then
                self:freshAutoGenzhu(agent:getAutoOperation())
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

        if curState == 'Blinds' then
            self:onReloadBlinds()
        elseif curState == 'Dealing' then
            self:onEnterDealing()
        elseif curState == 'PutMoney' then
            self:onReloadPutMoney(reload)
        elseif curState == 'Compare' then
            self:onReloadCompare(reload)
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
function ZJHDeskView:clearDesk(name)
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

    self:hideAllQipai()
end


--- 玩家
function ZJHDeskView:resetPlayerView(name)
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

function ZJHDeskView:freshHeadInfo(name, data)
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

        if name ~= 'bottom' then
            local compare = component:getChildByName('compare')
            if compare ~= nil then
                compare:addClickEventListener(function()
                    self.emitter:emit('clickCompare', uid)
                end)
            end
        end
    end
end

function ZJHDeskView:freshSeat(name, bool)
    local component = self.MainPanel:getChildByName(name)
    component:setVisible(bool)
end

-- 桌子信息
function ZJHDeskView:freshRoomInfo(bool)
    local topbar = self.MainPanel:getChildByName('topbar')
    local info = topbar:getChildByName('info')

    local deskInfo = self.desk:getDeskInfo()

    -- 房号
    local strRoomId = self.desk:getDeskId()
    local roomid = info:getChildByName('roomid')
    roomid:setString("房号:" .. strRoomId)

    -- 玩法
    local limit = GameLogic.getGameplayText(deskInfo)
    local gameplay = info:getChildByName('gameplay')
    gameplay:setString("玩法:" .. limit)

    -- 底分
    local strBase = GameLogic.getBaseText(deskInfo)
    local base = info:getChildByName('base')
    base:setString("底分:" .. strBase)

    -- 局数
    local strRound = self.desk:getCurRound()
    local round = info:getChildByName('round')
    round:setString("局数:" .. strRound .. "/" .. deskInfo.round)

    -- 推注
    local putmoney = info:getChildByName('putmoney')
    putmoney:setString("轮数:第0轮")

    -- 奖池
    local Jackpot = info:getChildByName('Jackpot')
    Jackpot:setString("池底:" .. 0)

    info:setVisible(bool)
end

function ZJHDeskView:freshDeviceInfo()
    local topbar = self.MainPanel:getChildByName('topbar')
    local net = topbar:getChildByName('net')
    local battery_B = topbar:getChildByName('battery_B')
    local battery_F = topbar:getChildByName('battery_F')
    local time = topbar:getChildByName('time')
    local getTime = os.date('%X');
    time:setString(string.sub(getTime, 1, string.len(getTime) - 3))
    if testluaj then
        local testluajobj = testluaj.new(self)
        local ok, ret1 = testluajobj.callandroidWifiState(self);
        if ok then
            print("android 网络信号强度为  " .. ret1)
        end
        if ret1 == 21 then
            net:loadTexture("views/lobby/Wifi2.png")
        elseif ret1 == 22 then
            net:loadTexture("views/lobby/Wifi3.png")
        elseif ret1 == 23 then
            net:loadTexture("views/lobby/Wifi4.png")
        elseif ret1 == 24 then
            net:loadTexture("views/lobby/Wifi4.png")
        elseif ret1 == 25 then
            net:loadTexture("views/lobby/Wifi4.png")
        elseif ret1 == 11 then
            net:loadTexture("views/lobby/4g2.png")
        elseif ret1 == 12 then
            net:loadTexture("views/lobby/4g3.png")
        elseif ret1 == 13 then
            net:loadTexture("views/lobby/4g4.png")
        elseif ret1 == 14 then
            net:loadTexture("views/lobby/4g4.png")
        elseif ret1 == 15 then
            net:loadTexture("views/lobby/4g4.png")
        end
        local ok, ret2 = testluajobj.callandroidBatteryLevel(self);
        if ok then
            print("android 电量为  " .. ret2)
            local w = battery_F:getContentSize().width * ret2 / 100
            local h = battery_F:getContentSize().height
            battery_B:setContentSize(w, h)
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
function ZJHDeskView:freshTip(bShow, text, cd)
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

function ZJHDeskView:freshTipText(text)
    if not text then return end
    if text == '' then return end
    self.tipText = text
end

-- ================== 作弊界面 ==================
-- 透明
function ZJHDeskView:freshCheatView(msg)
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

                local cnt, sptype, spKey = GameLogic.getLocalCardType(cards, gameplay, setting, wanfa)

                local cheatStr = "--"
                if sptype > 0 then
                    cheatStr = spKey or '特殊牌'
                elseif cnt > 0 then
                    cheatStr = string.format("%s", cnt)
                end

                self:freshCheatLabel(viewKey, cheatStr)
            end
        end

    end
end

function ZJHDeskView:showCheatView(bShow, key)
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
function ZJHDeskView:freshCheat1View(show, flag)
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

function ZJHDeskView:freshCheat1Result(mode)
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
function ZJHDeskView:freshCheatLabel(viewKey, cheatStr)
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
        local label = cc.Label:createWithTTF("0", 'views/font/fangzheng.ttf', 64)
        label:setPosition(pos)
        label:setVisible(false)
        label:setColor(cc.c3b(255, 0, 0))
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


function ZJHDeskView:card_suit(c)
    if not c then print(debug.traceback()) end
    if c == '☆' or c == '★' then
        return c
    else
        return #c > SUIT_UTF8_LENGTH and c:sub(1, SUIT_UTF8_LENGTH) or nil
    end
end

function ZJHDeskView:card_rank(c)
    return #c > SUIT_UTF8_LENGTH and c:sub(SUIT_UTF8_LENGTH + 1, #c) or nil
end

function ZJHDeskView:freshCardsTexture(name, idx, value, backIdx)
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

function ZJHDeskView:freshCardsTextureByNode(cardNode, value, backIdx)

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
    {['10'] = '4', ['9'] = '3', ['8'] = '2', ['7'] = '2' },

    {['10'] = '3', ['9'] = '2', ['8'] = '2' }
}

function ZJHDeskView:freshChatMsg(name, sex, msgType, msgData)

    local chatView = require('app.views.ZJHChatView')
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
        SoundMng.playEft('chat/voice_' .. msgData - 1 .. "_" .. sex .. '.mp3')
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

function ZJHDeskView:freshEmojiAction(name, idx)
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
            print("=========", event)
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


function ZJHDeskView:gameSettingAction(derection)
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

function ZJHDeskView:freshGameInfo(bool)
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
    local advanceStr = GameLogic.getAdvanceText(deskInfo)
    text_advanceRule:setString(advanceStr)

    -- 房间限制
    local roomlimitstr = GameLogic.getRoomLimitText(deskInfo)
    text_roomlimit:setString(roomlimitstr)

end

function ZJHDeskView:cardsBackToOriginSeat(name)
    local positionName = self.MainPanel:getChildByName(name)
    local cardView = positionName:getChildByName('cards')
    for i = 1, self.CARD_COUNT do
        local card = cardView:getChildByName('card' .. i)
        local p = self.cardsOrgPos[name][i]
        card:setPosition(p)
    end
end

function ZJHDeskView:doVoiceAnimation()
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

function ZJHDeskView:updateCountdownVoice(delay)
    self.tvoice.prg:setPercentage((20 - delay) / 20 * 100)
end

function ZJHDeskView:removeVoiceAnimation()
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

function ZJHDeskView:freshInviteFriend(bool)
    local invite = self.MainPanel:getChildByName('invite')
    invite:setVisible(bool)

end

function ZJHDeskView:copyRoomNum(content)
    if testluaj then
        local testluajobj = testluaj.new(self)
        local ok, ret1 = testluajobj.callandroidCopy(self, content)
        if ok then
            tools.showRemind('已复制')
        end
    else
        tools.showRemind('未复制')
    end
end

function ZJHDeskView:somebodyVoice(uid, total)
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

function ZJHDeskView:kusoAction(start, dest, idx)
    local getPos = function(name)
        local seat = self.MainPanel:getChildByName(name)
        local avatar = seat:getChildByName('avatar')
        local frame = avatar:getChildByName('frame')
        local headimg = frame:getChildByName('headimg')

        local pos = frame:convertToWorldSpace(cc.p(headimg:getPosition()))

        return pos
    end

    local str = 'item' .. idx
    local node = cc.CSLoader:createNode("views/animation/" .. str .. ".csb")
    node:setPosition(cc.p(getPos(start)))
    self:addChild(node)
    node:setVisible(true)

    local action = cc.CSLoader:createTimeline("views/animation/" .. str .. ".csb")
    action:gotoFrameAndPlay(0, 0, false)
    node:runAction(action)
    local callback = function()
        local action = cc.CSLoader:createTimeline("views/animation/" .. str .. ".csb")
        action:gotoFrameAndPlay(0, false)
        action:setFrameEventCallFunc(function(frame)
            local event = frame:getEvent();
            print("=========", event);
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
function ZJHDeskView:kusoAction_DaQiang(start, dest, num)
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

    local node = cc.CSLoader:createNode("views/animation/" .. str .. ".csb")
    node:setPosition(cc.p(getPos(start)))
    self:addChild(node)
    node:setVisible(true)

    local node1 = cc.CSLoader:createNode("views/animation/" .. str1 .. ".csb")
    node1:setPosition(cc.p(getPos(dest)))
    self:addChild(node1)
    node1:setVisible(true)

    local node2 = cc.CSLoader:createNode("views/animation/" .. str2 .. ".csb")
    node2:setPosition(cc.p(getPos(dest)))
    self:addChild(node2)
    node2:setVisible(true)

    local action = cc.CSLoader:createTimeline("views/animation/" .. str .. ".csb")
    action:gotoFrameAndPlay(0, 0, false)
    node:runAction(action)

    local action1 = cc.CSLoader:createTimeline("views/animation/" .. str1 .. ".csb")
    action1:gotoFrameAndPlay(0, 0, false)
    node1:runAction(action1)

    local action2 = cc.CSLoader:createTimeline("views/animation/" .. str2 .. ".csb")
    action2:gotoFrameAndPlay(0, 0, false)
    node2:runAction(action2)

    local callback = function(str, action, node)
        local action = cc.CSLoader:createTimeline("views/animation/" .. str .. ".csb")
        action:gotoFrameAndPlay(0, false)
        action:setFrameEventCallFunc(function(frame)
            local event = frame:getEvent();
            print("=========", event);
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
    local sequence = cc.Sequence:create(delay, cc.CallFunc:create(function()
        callback(str, action, node)
    end))
    local sequence1 = cc.Sequence:create(delay, cc.CallFunc:create(function()
        callback(str1, action1, node1)
    end))
    local sequence2 = cc.Sequence:create(delay, cc.CallFunc:create(function()
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


function ZJHDeskView:freshSummaryView(show, data)
    local view = self.MainPanel:getChildByName('summary')
    if not show then
        view:setVisible(false)
        return
    end

    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
    end

    view:setVisible(true)

    self:freshTrusteeshipLayer(false)
    self.playerViews.continue:setVisible(false)
    self.watcherLayout:setVisible(false)
    self:freshBettingBar(false)
    self:hideAllOutFrame()

    local quit = view:getChildByName('quit')
    local summary = view:getChildByName('summary')

    local function onClickQuit()
        app:switch('LobbyController')
    end

    local function onClickSummary()
        app:switch('ZJHSummaryController', data)
    end

    quit:addClickEventListener(onClickQuit)
    summary:addClickEventListener(onClickSummary)
end

function ZJHDeskView:freshAutoGenzhuLayer(bool)
    local fanpaiLayer = self.MainPanel:getChildByName('autoGenZhu')
    fanpaiLayer:setVisible(bool)
end  

function ZJHDeskView:freshAutoGenzhu(bool)
    self.MainPanel:getChildByName('autoGenZhu'):getChildByName('fanpai'):getChildByName('active'):setVisible(bool)
end

function ZJHDeskView:freshAutoGenzhuBtn()
    local fanpaiBtn = self.MainPanel:getChildByName('autoGenZhu'):getChildByName('fanpai')
    local flag = fanpaiBtn:getChildByName('active'):isVisible()
    fanpaiBtn:getChildByName('active'):setVisible(not flag)
    return (not flag)
end 

-- ============================ agent ============================
-- 玩家准备
function ZJHDeskView:freshReadyState(name, bool)
    local component = self.MainPanel:getChildByName(name)
    if not component then
        return
    end

    local avatar = component:getChildByName('avatar')
    local ready = avatar:getChildByName('ready')
    ready:setVisible(bool)
end

-- 玩家掉线
function ZJHDeskView:freshDropLine(name, bool)
    local component = self.MainPanel:getChildByName(name)
    local avatar = component:getChildByName('avatar')
    local dropLine = avatar:getChildByName('dropLine')
    dropLine:setVisible(bool)
    if bool then
        self:freshEnterBackground(name, false)
    end
end

-- 玩家切换后台
function ZJHDeskView:freshEnterBackground(name, bool)
    local component = self.MainPanel:getChildByName(name)
    local avatar = component:getChildByName('avatar')
    local enterbackground = avatar:getChildByName('enterbackground')
    enterbackground:setVisible(bool)
end

-- 托管/取消托管
function ZJHDeskView:freshTrusteeshipIcon(name, bool)
    bool = bool or false
    local component = self.MainPanel:getChildByName(name)
    local avatar = component:getChildByName('avatar')
    local trusteeship = avatar:getChildByName('trusteeship')
    trusteeship:setVisible(bool)
end

function ZJHDeskView:freshTrusteeshipLayer(bool)
    self.trusteeshipLayer:setVisible(bool)
end

function ZJHDeskView:getTrusteeshipLayer()
    return self.trusteeshipLayer:isVisible()
end

function ZJHDeskView:getPlayerView(startUid)
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
function ZJHDeskView:playEftQz(qzNum, sex)
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
function ZJHDeskView:playEftBet(bool)
    local soundPath = 'desk/coin_big.mp3'
    if bool then
        soundPath = 'desk/coins_fly.mp3'
    end
    SoundMng.playEftEx(soundPath)
end

function ZJHDeskView:playEftOption(viewKey, mode)
    local soundPath =  'cscompare_zjh/'
    local agent = self.desk:getPlayerInfo(nil, viewKey)
    local sex = 0
    if agent then
        sex = agent.player:getSex() or 0
    end
    soundPath = soundPath .. 'f' .. sex .. '_zjh_' .. mode .. '.mp3'
    SoundMng.playEftEx(soundPath)
end

-- 牌型
function ZJHDeskView:playEftCardType(sex, niuCnt, specialType)
    local idx = self.desk:getGameplayIdx()
    local soundPath = 'cscompare_zjh/' .. tostring('f' .. sex .. "_zjh_" .. GameLogic.getSpecialTypeByVal(idx, specialType) .. '.mp3')
    SoundMng.playEftEx(soundPath)
end

-- 输赢音效
function ZJHDeskView:playEftSummary(win)
    local soundPath = 'desk/lose.mp3'
    if win then
        soundPath = 'desk/win.mp3'
    end
    SoundMng.playEftEx(soundPath)
end

function ZJHDeskView:freshCanPutMoney(name, bool)
    local picture = self.MainPanel:getChildByName(name):getChildByName('avatar'):getChildByName('CanPutMoney')
    local node = picture:getChildByName('CanPutMoneyAnimation')
    picture:setVisible(bool)
    if bool then
        self:startCsdAnimation(node, true)
    else
        self:stopCsdAnimation(node)
    end
end

function ZJHDeskView:startCsdAnimation(node, isRepeat)
    local action = cc.CSLoader:createTimeline("views/xydesk/putmoney/CanPutMoneyAnimation.csb")
    action:gotoFrameAndPlay(0, isRepeat)
    node:stopAllActions()
    node:runAction(action)
end

function ZJHDeskView:stopCsdAnimation(node)
    node:stopAllActions()
end

function ZJHDeskView:startCompareCardAni(agentLeft, agentRight, isLeftWin)
    local compardCard = self.MainPanel:getChildByName("compardCard")
    local aniLayer = compardCard:getChildByName('aniLayer')
    local leftBg = compardCard:getChildByName("leftBg")
    local rightBg = compardCard:getChildByName("rightBg")
    local vs = compardCard:getChildByName("vs")
    local leftPos = compardCard:getChildByName("leftPos")
    local rightPos = compardCard:getChildByName("rightPos")

    --初始化
    if not self.initFlagCompareCard then
        self.initFlagCompareCard = true
        self.compardCardOrg = {}
        self.compardCardOrg.leftBg = cc.p(leftBg:getPosition())
        self.compardCardOrg.rightBg = cc.p(rightBg:getPosition())
        self.compardCardOrg.vs = cc.p(vs:getPosition())
    else
        leftBg:setPosition(self.compardCardOrg.leftBg)
        rightBg:setPosition(self.compardCardOrg.rightBg)
        vs:setPosition(self.compardCardOrg.vs)
    end

    aniLayer:removeAllChildren();

    --bg 左
    local function aniLeftBg()
        leftBg:setVisible(true);
        leftBg:setOpacity(0);
        local start = cc.p(leftBg:getPosition())
        leftBg:setPosition(cc.p(start.x - 500, start.y))
        local fIn = cc.FadeIn:create(0.3)
        local move = cc.MoveBy:create(0.3, cc.p(500, 0))
        local spawn = cc.Spawn:create(fIn, move)
        leftBg:runAction(spawn)
    end

    --bg 右
    local function aniRightBg()
        rightBg:setVisible(true);
        rightBg:setOpacity(0);
        local start = cc.p(rightBg:getPosition())
        rightBg:setPosition(cc.p(start.x + 500, start.y))
        local fIn = cc.FadeIn:create(0.3)
        local move = cc.MoveBy:create(0.3, cc.p(-500, 0))
        local spawn = cc.Spawn:create(fIn, move)
        rightBg:runAction(spawn)
    end

    --vs 图标
    local function aniVs()
        vs:setVisible(true);
        vs:setOpacity(0);
        local start = cc.p(vs:getPosition())
        vs:setPosition(cc.p(start.x, start.y + 100))
        vs:setScale(2);
        local fIn = cc.FadeIn:create(0.3)
        local move = cc.MoveBy:create(0.3, cc.p(0, -100))
        local scale = cc.ScaleTo:create(0.3, 1)
        local spawn = cc.Spawn:create(fIn, move, scale)
        vs:runAction(spawn)
    end

    --玩家头像
    local function aniAvatar(isLeft)
        local name = isLeft and agentLeft:getViewInfo() or agentRight:getViewInfo()
        local component = self.MainPanel:getChildByName(name)
        if not component then
            return
        end

        local avatar = component:getChildByName('avatar')
        local frame = avatar:getChildByName('frame')

        local avatarCopy = frame:clone()
        aniLayer:addChild(avatarCopy)

        local worldPos = component:convertToWorldSpace(cc.p(frame:getPosition()))
        local startPos = compardCard:convertToNodeSpace(worldPos)

        -- local oX, oY = frame:getPosition()
        local endPos = isLeft and cc.p(leftPos:getPosition()) or cc.p(rightPos:getPosition())
        local endPos1 = cc.p(endPos)
        -- endPos1.x = endPos1.x - oX
        -- endPos1.y = endPos1.y - oY

        local isWin = (isLeft and isLeftWin) or ((not isLeft) and (not isLeftWin))

        local lightNode
        local lightNode1

        avatarCopy:setPosition(startPos)
        local loseFlag = frame:getChildByName('lose')
        local move1 = cc.MoveTo:create(0.3, endPos1)
        local light1 = cc.CallFunc:create(function()
            if not isWin then
                local node = cc.CSLoader:createNode("views/animation/Light.csb")
                node:setPosition(endPos)
                aniLayer:addChild(node)
                local action = cc.CSLoader:createTimeline("views/animation/Light.csb")
                action:gotoFrameAndPlay(0, false)
                action:setTimeSpeed(3)
                node:runAction(action)
                lightNode = node
            end
        end)
        local light2 = cc.CallFunc:create(function()
            if not isWin then
                local node = cc.CSLoader:createNode("views/animation/Light1.csb")
                node:setPosition(endPos)
                aniLayer:addChild(node)
                local action = cc.CSLoader:createTimeline("views/animation/Light1.csb")
                action:gotoFrameAndPlay(0, false)
                action:setTimeSpeed(2)
                node:runAction(action)
                lightNode1 = node
            end
        end)
        local showLose = cc.CallFunc:create(function()
            if not isWin then
                loseFlag:setTexture('views/nysdesk/zjh/lose.png')
                loseFlag:setVisible(true)
            end
            if lightNode1 then lightNode1:removeSelf() end

        end)
        local hideBg = cc.CallFunc:create(function()
            leftBg:runAction(cc.FadeOut:create(0.3))
            rightBg:runAction(cc.FadeOut:create(0.3))
            vs:runAction(cc.FadeOut:create(0.3))
        end)
        local move2 = cc.MoveTo:create(0.3, startPos)
        local endCb = cc.CallFunc:create(function()
            compardCard:setVisible(false)
            frame:setVisible(true)
            if lightNode then lightNode:removeSelf() end
        end)
        local removeSelf = cc.RemoveSelf:create();
        local sequence = cc.Sequence:create(
        move1,
        cc.DelayTime:create(0.3),
        light1,
        cc.DelayTime:create(0.3),
        light2,
        cc.DelayTime:create(0.6),
        showLose,
        cc.DelayTime:create(0.8),
        hideBg,
        move2,
        endCb,
        removeSelf
        )
        avatarCopy:runAction(sequence)

        frame:setVisible(false)
    end

    aniLeftBg()
    aniRightBg()
    aniVs()
    aniAvatar(true)
    aniAvatar(false)
    compardCard:setVisible(true)
    -- compardCard:setEnabled(false)
end

function ZJHDeskView:freshCuoPaiDisplay(bool, data)
    local cpBg = self.MainPanel:getChildByName('cpBg')
    if not cpBg:isVisible() and data then
        local angle = 4
        cpBg.flag = 0

        for i = 1, 5 do
            if i > 3 then
                local card = cpBg:getChildByName('card' .. i)
                card:setVisible(false)
            else
                local card = cpBg:getChildByName('card' .. i)
                if card.oriX and card.oriY then
                    card:setPosition(cc.p(card.oriX, card.oriY))
                end
                card:setRotation(0)
            end
        end

        for i, v in ipairs(data) do
            local card = cpBg:getChildByName('card' .. i)
            local suit = self.suit_2_path[self:card_suit(v)]
            local rnk = self:card_rank(v)

            local path
            if suit == 'j1' or suit == 'j2' then
                path = 'views/xydesk/shuffle/' .. suit .. '.png'
            else
                -- print(" -> suit : ", suit, "rnk : ", rnk)
                path = 'views/xydesk/shuffle/' .. suit .. rnk .. '.png'
            end
            card:loadTexture(path)
            card.state = 'origin'
            if not card.oriX and not card.oriY then
                card.oriX, card.oriY = card:getPosition()
            end

            local rot = cc.RotateTo:create(0.3, angle)
            card:runAction(rot)
            angle = angle - 2

            card:addTouchEventListener(function(sender, type)
                if type == 0 then
                    -- began
                    self.starpos = sender:getTouchBeganPosition()
                    local x, y = card:getPosition()
                    self.orgPos = { x = x, y = y }
                elseif type == 1 then
                    -- move
                    card.state = card.state ~= 'moved' and 'move' or 'moved'

                    local pos = sender:getTouchMovePosition()
                    local difX = self.starpos.x - pos.x
                    local difY = self.starpos.y - pos.y
                    card:setPosition(cc.p(self.orgPos.x - difX, self.orgPos.y - difY))
                else
                    -- ended
                    for i = 1, 5 do
                        local card = cpBg:getChildByName('card' .. i)
                        if card.state == 'move' then
                            card.state = 'moved'
                            cpBg.flag = cpBg.flag + 1
                        end
                    end

                    if cpBg.flag == 3 then
                        local newAngle = 16
                        for i = 1, 3 do
                            local card = cpBg:getChildByName('card' .. i)
                            card:setRotation(newAngle)
                            newAngle = newAngle - 8

                            local delay = cc.DelayTime:create(1.5)
                            local dest = cc.p(card.oriX, card.oriY)
                            local moveTo = cc.MoveTo:create(0.3, dest)

                            local callback = function()
                                -- 搓牌回调
                                self.emitter:emit('cpBack', { msgID = 'cpBack' })
                                card.oriX, card.oriY = nil, nil
                                self:freshCuoPaiDisplay(false, nil)
                            end
                            local sequence = cc.Sequence:create(moveTo, delay, cc.CallFunc:create(callback))
                            card:runAction(sequence)
                        end
                    end
                end
            end)
        end
    else
        for i = 1, 5 do
            local card = cpBg:getChildByName('card' .. i)
            card.state = 'origin'
            card:cleanup()
        end
    end
    cpBg:setVisible(bool)
end

return ZJHDeskView