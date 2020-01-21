local Scheduler = require('app.helpers.Scheduler')
local SoundMng = require('app.helpers.SoundMng')
local tools = require('app.helpers.tools')
local ConvertToTableView = require('app.helpers.ConvertToTableView')
local cache = require('app.helpers.cache')
local app = require('app.App'):instance()

local GVHeHuoView = {}

function GVHeHuoView:initialize()
    self.group = nil
end

function GVHeHuoView:layout(data)
    self.group = data[1]
    self.groupInfo = self.group:getCurGroup()
    self.myPlayerId = self.group:getPlayerRes("playerId")
    self.groupId = self.groupInfo.id
    self.isOwner = data[2]
    self.isHehuo = data[3]
    self.hehuoInfo = self.groupInfo.HehuoRenInfo

    local mainPanel = self.ui:getChildByName('MainPanel')
    mainPanel:setPosition(display.cx, display.cy)

    self.HeHuoAdminLayer = mainPanel:getChildByName('HeHuoAdmin')
    self.memberAdminLayer = mainPanel:getChildByName('memberAdmin')
    self.enterLayer = mainPanel:getChildByName('enter')
    self.tiaoPeiLayer = mainPanel:getChildByName('tiaopeiLayer')

    self.HeHuoAdminLayer:setVisible(false)
    self.memberAdminLayer:setVisible(false)
    self.enterLayer:setVisible(false)
    self.tiaoPeiLayer:setVisible(false)

    if self.isOwner then
        self.HeHuoAdminLayer:setVisible(true)
    end

    if self.isHehuo then
        self:freshMemberLayer(true)
    end

    -- 初始化enterview部分
    self.inputNum = ''
	self.enterLayer:getChildByName('numlist'):setScrollBarEnabled(false)
    for i = 0, 9 do
        local btn = self.enterLayer:getChildByName('btn'):getChildByName('bt' .. i)
        btn:addClickEventListener(function()
            self:clickNumber(i)
        end)
	end
	self.openType = 'find'
    
    -- 初始化调配界面部分
    -- 调配的玩家id
    local playerIdInput = self.tiaoPeiLayer:getChildByName('playerId')
    self.playerIdInput = tools.createEditBox(playerIdInput, {
		-- holder
		defaultString = '',
        holderSize = 25,
		holderColor = cc.c3b(185,198,254),
        
		-- text
		fontColor = cc.c3b(185,198,254),
		size = 25,
        maxCout = 6,
		fontType = 'views/font/fangzheng.ttf',	
        inputMode = cc.EDITBOX_INPUT_MODE_NUMERIC,
    })

    -- 调配到的合伙人id
    local HehuoIdInput = self.tiaoPeiLayer:getChildByName('HehuoId')
    self.HehuoIdInput = tools.createEditBox(HehuoIdInput, {
		-- holder
		defaultString = '',
        holderSize = 25,
		holderColor = cc.c3b(185,198,254),
        
		-- text
		fontColor = cc.c3b(185,198,254),
		size = 25,
        maxCout = 6,
		fontType = 'views/font/fangzheng.ttf',	
        inputMode = cc.EDITBOX_INPUT_MODE_NUMERIC,
    })

    -- 好友分成比例
    local fenchengInput = self.memberAdminLayer:getChildByName('layer1'):getChildByName('input')
    self.fenchengInput = tools.createEditBox(fenchengInput, {
		-- holder
		defaultString = '',
        holderSize = 25,
		holderColor = cc.c3b(185,198,254),
        
		-- text
		fontColor = cc.c3b(185,198,254),
		size = 25,
        maxCout = 3,
		fontType = 'views/font/fangzheng.ttf',	
        inputMode = cc.EDITBOX_INPUT_MODE_NUMERIC,
    })
end

--------------------------------------------------------------------
-- 合伙人界面
function GVHeHuoView:freshHehuoInfo(msg)
    local hehuoList = self.HeHuoAdminLayer:getChildByName('hehuoList')
    local listModule = self.HeHuoAdminLayer:getChildByName('list')
    hehuoList:setScrollBarEnabled(false)
    hehuoList:removeAllItems()
    if not msg.data then return end
    hehuoList:setItemModel(listModule)
    local idx = 0
    for i, v in pairs(msg.data) do
        self:freshItemInfo(hehuoList, idx, v)
        idx = idx + 1
    end
end

function GVHeHuoView:freshItemInfo(list, idx, data)
    list:pushBackDefaultItem()
    local item = list:getItem(idx)
    item:getChildByName('id'):setString(data.playerId)
    item:getChildByName('nickName'):setString(data.nickName)
    item:getChildByName('dyjNum'):setString(data.dyjNum)
    item:getChildByName('roundNum'):setString(data.roundNum)
    item:getChildByName('costNum'):setString(data.costNum)
    item:getChildByName('totalNum'):setString(data.totalNum)
    item:getChildByName('xiangqing'):addClickEventListener(function()
        self:freshMemberLayer(true)
        self.group:queryMemberInfo(self.groupId, tonumber(data.playerId))
    end)
    item:getChildByName('del'):addClickEventListener(function()
        self.group:DelHeHuo(self.groupId, data.playerId)
    end)
end
--------------------------------------------------------------------

--------------------------------------------------------------------
-- 成员管理界面
function GVHeHuoView:freshMemberLayer(bool)
    self.memberAdminLayer:getChildByName('tiaopei'):setVisible(false)
    self.memberAdminLayer:getChildByName('closelayer'):setVisible(false)
    self.memberAdminLayer:getChildByName('back'):setVisible(false)
    self.memberAdminLayer:getChildByName('layer1'):setVisible(false)
    
    if self.isOwner and bool then
        self.memberAdminLayer:getChildByName('tiaopei'):setVisible(true)
        self.memberAdminLayer:getChildByName('closelayer'):setVisible(true)
        self.memberAdminLayer:getChildByName('layer1'):setVisible(true)
        self.memberAdminLayer:setVisible(bool)
        return 
    end
    self.memberAdminLayer:getChildByName('back'):setVisible(true)
    self.memberAdminLayer:setVisible(bool)
end

-- 成员信息
function GVHeHuoView:freshMemberInfo(msg)
    local memberList = self.memberAdminLayer:getChildByName('memberList')
    local listModule = self.memberAdminLayer:getChildByName('list')
    memberList:setScrollBarEnabled(false)
    memberList:removeAllItems()
    self:setCurrentInviter(msg.inviter)
    if not msg.data then return end
    memberList:setItemModel(listModule)
    local idx = 0
    for i, v in pairs(msg.data) do
        self:freshMemberItemInfo(memberList, idx, v)
        idx = idx + 1
    end
    self.memberAdminLayer:getChildByName('member_cnt'):setString(idx)

    if msg.fengcheng then
        self.fenchengInput:setText(msg.fengcheng)
    end
end

function GVHeHuoView:freshMemberItemInfo(list, idx, data)
    list:pushBackDefaultItem()
    local item = list:getItem(idx)
    item:getChildByName('id'):setString(data.playerId)
    item:getChildByName('nickName'):setString(data.nickName)
    item:getChildByName('score'):setString(data.score)
    item:getChildByName('dyjNum'):setString(data.dyjNum)
    item:getChildByName('roundNum'):setString(data.roundNum)
    item:getChildByName('costNum'):setString(data.costNum)
    item:getChildByName('totalNum'):setString(data.totalNum)
    item:getChildByName('del'):addClickEventListener(function()
        self.group:DelMember(self.groupId, data.playerId, data.inviter)
    end)
end

function GVHeHuoView:getFenchengText()
    return self.fenchengInput:getText()
end
--------------------------------------------------------------------

--------------------------------------------------------------------
-- enterview
function GVHeHuoView:freshEnterView(bool, openType)
    local title = self.enterLayer:getChildByName('title')
    local text = self.enterLayer:getChildByName('text')

    title:getChildByName('find'):setVisible(false)
    title:getChildByName('add'):setVisible(false)
    title:getChildByName('invite'):setVisible(false)

    text:getChildByName('find'):setVisible(false)
    text:getChildByName('add'):setVisible(false)
    text:getChildByName('invite'):setVisible(false)
    self:Reenter()
    self.enterLayer:setVisible(bool)

    if bool then
        title:getChildByName(openType):setVisible(true)
		text:getChildByName(openType):setVisible(true)
		self.openType = openType
    end
end

function GVHeHuoView:freshNumber()
    local list = self.enterLayer:getChildByName('numlist')

    for n = 1, 6 do
        list:getChildByName('' .. n):getChildByName('atlasNumber'):setString('')
    end

    local cnt = #self.inputNum
    for i = 1, cnt do
        local n = string.sub(self.inputNum, i, i)
        list:getChildByName('' .. i):getChildByName('atlasNumber'):setString(n)
    end
end

function GVHeHuoView:clickNumber(i)
    if #self.inputNum == 6 then return end
    SoundMng.playEft('btn_click.mp3')
    self.inputNum = self.inputNum .. tostring(i)
    self:freshNumber()

    if #self.inputNum == 6 then
        local msg = {
            playerId = tonumber(self.inputNum),
            openType = self.openType,
            groupId = self.groupId,
        }
        if self.openType == 'invite' then
            msg.inviter = self:getCurrentInviter()
            msg.nickName = self.group:getPlayerRes("nickName")
        end
        self.group:HeHuoOperation(msg)
    end
end

function GVHeHuoView:Delete()
    self.inputNum = string.sub(self.inputNum, 1, #self.inputNum - 1)
    self:freshNumber()
end

function GVHeHuoView:Reenter()
    self.inputNum = ''
    self:freshNumber()
end
--------------------------------------------------------------------

--------------------------------------------------------------------
-- 调配界面
function GVHeHuoView:freshTiaoPeiLayer(bool)
    self.tiaoPeiLayer:setVisible(bool)
    if not bool then
        self.playerIdInput:setText('')
        self.HehuoIdInput:setText('')
    end
end

function GVHeHuoView:getTiaoPeiInfo()
    local playerId = self.playerIdInput:getText()
    local hehuoId = self.HehuoIdInput:getText()
    return playerId, hehuoId
end

function GVHeHuoView:setCurrentInviter(value)
    self.CurrentInviter = value
end

function GVHeHuoView:getCurrentInviter()
    return self.CurrentInviter
end
--------------------------------------------------------------------

function GVHeHuoView:getCurGroup()
    return self.groupInfo
end
return GVHeHuoView