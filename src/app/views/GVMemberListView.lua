local Scheduler = require('app.helpers.Scheduler')
local SoundMng = require('app.helpers.SoundMng')
local tools = require('app.helpers.tools')
local ConvertToTableView = require('app.helpers.ConvertToTableView')
local cache = require('app.helpers.cache')
local app = require('app.App'):instance()

local GVMemberListView = {}

function GVMemberListView:initialize()
	self.group = nil
	self.isAdmin = nil
	self.isAdminFu = nil
	self.isHehuo = nil
	self.selectIdx = nil
	self.tabPlaying = {} -- k:playerId v:bool
	self.operationMode = 'none'

	self.banData = {}
	self.delData = {}
	self.adminFu = {}
	self.tabItem = {}
end

function GVMemberListView:layout(data)
	self.group = data[1]
	self.isAdmin = data[2]
	self.isAdminFu = data[3]
	self.isHehuo = data[4]
	self.scoreOptions = {}
	self.gameState = nil

	local mainPanel = self.ui:getChildByName('MainPanel')
	mainPanel:setPosition(display.cx, display.cy)

	-- 管理员列表
	self.memberLayer = mainPanel:getChildByName('MemberLayer')
	local adminMember = self.memberLayer:getChildByName('adminMember')

	self.memberItem = adminMember:getChildByName('memberItem')
	self.memberList = adminMember:getChildByName('longList')
	local rowItem = adminMember:getChildByName('memberList')
	self.memberList:setItemModel(rowItem)
	self.memberList:removeAllItems()

	if self.isAdmin then
		self:freshclicktoLayer(true, false, false, false, false, false, false)
		self.memberLayer:getChildByName('back'):setVisible(false)
	elseif self.isAdminFu and self.isHehuo then	
		self:freshclicktoLayer(false, false, false, false, true, false, true)
		self.memberLayer:getChildByName('back'):setVisible(false)
	elseif self.isAdminFu then
		self:freshclicktoLayer(false, false, false, false, true, false, false)
		self.memberLayer:getChildByName('back'):setVisible(false)
	elseif self.isHehuo then
		self:freshclicktoLayer(false, false, false, false, false, false, true)
		self.memberLayer:getChildByName('back'):setVisible(false)
	else	
		self:freshclicktoLayer(false, false, false, false, false, false, false)
		self.memberLayer:getChildByName('back'):setVisible(true)
	end

	-- 提示界面
	self.tipsLayer = self.memberLayer:getChildByName('tipsLayer')

	-- id查找框
	-- local input = self.memberLayer:getChildByName('input')
    -- self.findEditbox = tools.createEditBox(input, {
	-- 	-- holder
	-- 	defaultString = '请输入查找的ID',
	-- 	holderSize = 20,
	-- 	maxCout = 6,
	-- 	holderColor = cc.c3b(169,169,172),

	-- 	-- text
	-- 	fontColor = cc.c3b(169,169,172),
	-- 	size = 20,
	-- 	fontType = 'views/font/fangzheng.ttf',	
    --     inputMode = cc.EDITBOX_INPUT_MODE_NUMERIC,
    -- })
end

function GVMemberListView:getCurGroupMember()
	local groupInfo = self.group:getCurGroup()
	local groupId = groupInfo.id 
	local ret = self.group:getMemberInfo(groupId)
	return ret or {}
end

function GVMemberListView:getCurGroupRooms()
	local groupInfo = self.group:getCurGroup()
	local groupId = groupInfo.id 
	local ret = self.group:getRoomList(groupId)
	return ret or {}
end


function GVMemberListView:freshMemberList()

	local memberList = self:getCurGroupMember()
    local groupInfo = self.group:getCurGroup()
	local ownerId = groupInfo.ownerInfo.playerId
	local scoreList = self.group:getMemberScoreInfo(groupInfo.id)
	
	self.tabItem = {}
	self.banData = {}
	self.delData = {}
	self.adminFu = {}
	self.memberList:removeAllItems()

	local lineCnt = 4
	local row = 0
	local rowCnt = math.ceil(table.nums(memberList)/lineCnt)
	for i = 1, rowCnt do
		self.memberList:pushBackDefaultItem()
		local rowItem = self.memberList:getItem(i-1)
		rowItem:setItemModel(self.memberItem)
	end

	local itemCnt = 0
	for i,v in pairs(memberList) do
		itemCnt = itemCnt + 1
		local rowIdx = math.ceil(itemCnt/lineCnt)
		local rowItem = self.memberList:getItem(rowIdx-1)
		rowItem:pushBackDefaultItem()
		local idx = (itemCnt-1) % lineCnt
		local memberItem = rowItem:getItem(idx)

		local bMgr = (ownerId == v.playerId)
		self:freshMemberItem(memberItem, v, bMgr, scoreList['' .. v.playerId])
	end
end


function GVMemberListView:freshMemberItem(item, data, bMgr, score)

	-- 头像
	local headimg = item:getChildByName('txKuang')
	self:freshItemHeadImg(headimg, data.avatar)
	-- 管理图标
	item:getChildByName('manager'):setVisible(bMgr)

	-- 副管理图标
	local groupInfo = self.group:getCurGroup()
	local groupId = groupInfo.id
	local ownerId = groupInfo.ownerInfo.playerId
	local myPlayerId = self.group:getPlayerRes("playerId")
	local isAdminFu = self.group:getMeAdminFu(groupId,data.playerId)
	item:getChildByName('manager_fu'):setVisible(isAdminFu)

	-- 名字
	item:getChildByName('userName'):setString(tostring(data.nickname))
	-- playerId
	item:getChildByName('userID'):setString('ID:'..tostring(data.playerId))
	-- 禁用
	item:getChildByName('sureBan'):setVisible(data.isBanplayer)
	-- 离线
	item:getChildByName('avatarMask'):setVisible(true)
	-- 信誉值
	local score = score or 0 
	local scoreStr = '信誉值:' .. score
	item:getChildByName('score'):setString(scoreStr)

	local stateStr = '离线'
	item:getChildByName('state'):setString(stateStr)
	item:getChildByName('state'):setColor(cc.c3b(214,214,214))
	if data.online or data.isRobot then
		stateStr = '在线'
		item:getChildByName('avatarMask'):setVisible(false)
		item:getChildByName('state'):setString(stateStr)
		item:getChildByName('state'):setColor(cc.c3b(78,255,78))
	end
	if data.playerId and (data.online or data.isRobot) and self.tabPlaying[data.playerId] then
		stateStr = '游戏中'
		item:getChildByName('avatarMask'):setVisible(false)
		item:getChildByName('state'):setString(stateStr)
		item:getChildByName('state'):setColor(cc.c3b(255,242,144))
	end

	--默认不选中
	item:getChildByName('selectbg'):setVisible(false)
	item:getChildByName('unselectbg'):setVisible(true)

	local touch = item:getChildByName('touch')
	touch:addClickEventListener(function()
		if self.operationMode == 'ban' and bMgr == false then
			if isAdminFu and myPlayerId ~= ownerId then 
				tools.showRemind('您不能管理其他副管理员')
				return  
			end
			if self.banData[data.playerId] then
				self.banData[data.playerId] = nil
				item:getChildByName('selectbg'):setVisible(false)
				item:getChildByName('unselectbg'):setVisible(true)
			else
				self.banData[data.playerId] = data.playerId
				item:getChildByName('selectbg'):setVisible(true)
				item:getChildByName('unselectbg'):setVisible(false)
			end
		elseif self.operationMode == 'del' and bMgr == false then
			if isAdminFu and myPlayerId ~= ownerId then 
				tools.showRemind('您不能管理其他副管理员')
				return  
			end
			if self.delData[data.playerId] then
				self.delData[data.playerId] = nil
				item:getChildByName('selectbg'):setVisible(false)
				item:getChildByName('unselectbg'):setVisible(true)
			else
				self.delData[data.playerId] = data.playerId
				item:getChildByName('selectbg'):setVisible(true)
				item:getChildByName('unselectbg'):setVisible(false)
			end
		elseif self.operationMode == 'setadmin' and bMgr == false then
			if self.adminFu[data.playerId] then
				self.adminFu[data.playerId] = nil
				item:getChildByName('selectbg'):setVisible(false)
				item:getChildByName('unselectbg'):setVisible(true)
			else
				self.adminFu[data.playerId] = data.playerId
				item:getChildByName('selectbg'):setVisible(true)
				item:getChildByName('unselectbg'):setVisible(false)
			end
		elseif self.operationMode == 'setscore' and bMgr == false then
			if self.isHehuo then
				if data.inviter ~= myPlayerId then
					tools.showRemind("你不能给其他不属于你的成员上下分")
				else
					data.score = score
					self:freshScoreLayer(true, data)
				end
			else
				data.score = score
				self:freshScoreLayer(true, data)
			end

		elseif self.operationMode == 'none' then
			self.emitter:emit('userInfo', data.playerId)
		end
	end)

	self.tabItem[data.playerId] = item
end

function GVMemberListView:setAllMemberItemUnselect()
	for k,item in pairs(self.tabItem) do
		if not tolua.isnull(item) then
			item:getChildByName('selectbg'):setVisible(false)
			item:getChildByName('unselectbg'):setVisible(true)
		end
	end
end

function GVMemberListView:freshItemHeadImg(headimg, headUrl)
	headimg:loadTexture('views/public/tx.png')
	if headUrl == nil or headUrl == '' then return end		 
	cache.get(headUrl, function(ok, path)
		local function loadImg()
			if tolua.isnull(headimg) then return end
			if ok then
				headimg:show()
				headimg:loadTexture(path)
			else
				headimg:loadTexture('views/public/tx.png')
			end
		end
		pcall(loadImg, 'headImg')
	end)
end

function GVMemberListView:freshScoreLayer(show, data)
	local MainPanel = self.ui:getChildByName('MainPanel')
	local MemberLayer = MainPanel:getChildByName('MemberLayer')
	MemberLayer:getChildByName('scoreLayer'):setVisible(show)
	if not show or not data then 
		self.scoreOptions.data = nil 
		return 
	end
	local userInfoLayer = MemberLayer:getChildByName('scoreLayer'):getChildByName('userInfo')
	local headImg = userInfoLayer:getChildByName('headImg')
	self:freshItemHeadImg(headImg, data.avatar)
	userInfoLayer:getChildByName('nickName'):setString(data.nickname)
	userInfoLayer:getChildByName('id'):setString(data.playerId)
	local score = data.score or 0
	userInfoLayer:getChildByName('score'):setString(score)
	self.scoreText = MemberLayer:getChildByName('scoreLayer'):getChildByName('currentCardCnt')
	self.newScore = '0'
	self.scoreText:setString(self.newScore)
	self.scoreOptions.data = data
end

function GVMemberListView:freshSureLayer(show, data)
	local MainPanel = self.ui:getChildByName('MainPanel')
	local MemberLayer = MainPanel:getChildByName('MemberLayer')
	MemberLayer:getChildByName('scoreLayer'):getChildByName('sureLayer'):setVisible(show)
	-- data = self.ScoreMode
	if not show or not data then
		self.scoreOptions.mode = nil
		return 
	end
	local tips = MemberLayer:getChildByName('scoreLayer'):getChildByName('sureLayer'):getChildByName('tips')
	if data == 'add' then
		tips:setString("确定要给对方赠送分数吗？")
		self.scoreOptions.mode = 'add'
	elseif data == 'reduce' then
		tips:setString("确定要扣除对方分数吗？")
		self.scoreOptions.mode = 'reduce'
	end
end

function GVMemberListView:getScoreOptions()
	if not self.scoreOptions.data then return end
	self.scoreOptions.state = self.tabPlaying[self.scoreOptions.data.playerId]
	return self.scoreOptions
end

function GVMemberListView:setNewScore(mode, data)
	if mode == 'input' and data then
		if self.newScore == '0' then
			self.newScore = '' .. data
		else
			self.newScore = self.newScore .. data
		end
	elseif mode == 'del' then
		self.newScore = string.sub(self.newScore,1,#self.newScore - 1)
		if self.newScore == '' then
			self.newScore = '0'
		end
	elseif mode == 'reenter' then
		self.newScore = '0'
	end
	self.scoreText:setString(self.newScore)
	self.scoreOptions.newScore = tonumber(self.newScore)
end

function GVMemberListView:freshFindLayer(bool)
	local MainPanel = self.ui:getChildByName('MainPanel')
	local MemberLayer = MainPanel:getChildByName('MemberLayer')
	MemberLayer:getChildByName('findLayer'):setVisible(bool)
	self.numList = MemberLayer:getChildByName('findLayer'):getChildByName('numlist')
	self.findId = ''
	self:freshNumber()
end

function GVMemberListView:setFindID(mode, data)
	if mode == 'input' and data then
		if #self.findId == 6 then return end
		self.findId = self.findId .. tostring(data)
		self:freshNumber()

		if #self.findId == 6 then
			if self:findPlayer() then
				self:freshFindLayer(false)
			end
		end
	elseif mode == 'del' then
		self.findId = string.sub(self.findId,1,#self.findId - 1)
		self:freshNumber()
	elseif mode == 'reenter' then
		self.findId = ''
		self:freshNumber()
	end
end

function GVMemberListView:freshNumber()
    local list = self.numList

    for n = 1, 6 do
        list:getChildByName('' .. n):getChildByName('atlasNumber'):setString('')
    end

    local cnt = #self.findId
    for i = 1, cnt do
        local n = string.sub(self.findId, i, i)
        list:getChildByName('' .. i):getChildByName('atlasNumber'):setString(n)
    end
end

function GVMemberListView:freshGameState(bShow)
	if not bShow then
		self.gameState:setVisible(false)
	end
	
	local list = self:getCurGroupMember()
	local cnt = 0
	if list and #list > 0 then
		for i,v in pairs(list) do
			if v.online then
				cnt = cnt + 1
			end
		end
	end

	self.tabPlaying = {}
	local cnt1 = 0
	local list1 = self:getCurGroupRooms()
	if list1 then
		for i,v in pairs(list1) do
			for j,k in pairs(v.playerList) do
				self.tabPlaying[k.playerId] = true
				cnt1 = cnt1 + 1
			end
		end
	end

end

function GVMemberListView:resetOptionView()
	self.selectIdx = nil
	self.delBtn:setEnabled(false)
	self.delBtn:setVisible(true)
	self.banBtn:setEnabled(false)
	self.banBtn:setVisible(true)
	
	self.unBanBtn:setEnabled(false)
	self.unBanBtn:setVisible(false)
end

function GVMemberListView:freshclicktoLayer(isadmin, isdelete, isban, issetadmin, isadminFu, issetScore, isHehuo)
	local MainPanel = self.ui:getChildByName('MainPanel')
	local MemberLayer = MainPanel:getChildByName('MemberLayer')
	local adminLayer = MemberLayer:getChildByName('adminLayer')
	local adminFuLayer = MemberLayer:getChildByName('adminFuLayer')
	local adminFuLayer1 = MemberLayer:getChildByName('adminFuLayer1')
	local deleteLayer = MemberLayer:getChildByName('deleteLayer')
	local banLayer = MemberLayer:getChildByName('banLayer')
	local setadminLayer = MemberLayer:getChildByName('setadminLayer')
	local setScoreLayer = MemberLayer:getChildByName('setScoreLayer')
	local HehuoLayer = MemberLayer:getChildByName('HehuoLayer')
	adminLayer:setVisible(isadmin)
	deleteLayer:setVisible(isdelete)
	banLayer:setVisible(isban)
	setadminLayer:setVisible(issetadmin)
	setScoreLayer:setVisible(issetScore)
	adminFuLayer1:setVisible(false)
	HehuoLayer:setVisible(false)
	adminFuLayer:setVisible(false)
	if isadminFu and isHehuo then
		adminFuLayer1:setVisible(true)
	elseif isadminFu then
		adminFuLayer:setVisible(true)
	elseif isHehuo then
		HehuoLayer:setVisible(true)
	end

	if issetScore then
		if self.isHehuo then
			setScoreLayer:getChildByName('findMyMember'):setVisible(true)
		else
			setScoreLayer:getChildByName('findMyMember'):setVisible(false)
		end
	end
end

function GVMemberListView:freshtipsLayer(bool)
	self.tipsLayer:setVisible(bool)
end

function GVMemberListView:findPlayer()
	local playerId = tonumber(self.findId)
	local memberList = self:getCurGroupMember()
	local groupInfo = self.group:getCurGroup()
	local ownerId = groupInfo.ownerInfo.playerId
	local scoreList = self.group:getMemberScoreInfo(groupInfo.id)
	
	-- 查找是否有这个玩家
	local playerInfo = nil
	for i, v in pairs(memberList) do
		if v.playerId == playerId then
			playerInfo = v
		end
	end

	if playerInfo then
		self.memberList:removeAllItems()
		self.memberList:pushBackDefaultItem()
		local rowItem = self.memberList:getItem(0)
		rowItem:setItemModel(self.memberItem)
		rowItem:removeAllItems()
		rowItem:pushBackDefaultItem()
		local memberItem = rowItem:getItem(0)
		local bMgr = (ownerId == playerInfo.playerId)
		self:freshMemberItem(memberItem, playerInfo, bMgr, scoreList['' .. playerInfo.playerId])
		return true
	else
		tools.showRemind("找不到该玩家!")
		return false
	end
end

function GVMemberListView:GuoLvPlayer()
	local memberList = self:getCurGroupMember()
	local groupInfo = self.group:getCurGroup()
	local scoreList = self.group:getMemberScoreInfo(groupInfo.id)
	local myPlayerId = self.group:getPlayerRes("playerId")
	
	-- 查找是否有这个玩家
	local playerInfo = {}
	for i, v in pairs(memberList) do
		if v.inviter and v.inviter == myPlayerId then
			table.insert(playerInfo, v)
		end
	end

	if next(playerInfo) ~= nil then
		self.memberList:removeAllItems()
		local lineCnt = 4
		local row = 0
		local rowCnt = math.ceil(table.nums(playerInfo)/lineCnt)
		for i = 1, rowCnt do
			self.memberList:pushBackDefaultItem()
			local rowItem = self.memberList:getItem(i-1)
			rowItem:setItemModel(self.memberItem)
		end

		local itemCnt = 0
		for i,v in pairs(playerInfo) do
			itemCnt = itemCnt + 1
			local rowIdx = math.ceil(itemCnt/lineCnt)
			local rowItem = self.memberList:getItem(rowIdx-1)
			rowItem:pushBackDefaultItem()
			local idx = (itemCnt-1) % lineCnt
			local memberItem = rowItem:getItem(idx)

			self:freshMemberItem(memberItem, v, false, scoreList['' .. v.playerId])
		end
	else
		tools.showRemind("没有玩家!")
	end
end

function GVMemberListView:setScoreMode(data)
	self.ScoreMode = data
end

function GVMemberListView:setOperationMode(mode)
	self.operationMode = mode
	if self.operationMode == 'ban' then
		self.delData = {}
		self.banData = {}
		self.adminFu = {}

	-- elseif self.operationMode == 'del' and bMgr == false then
	elseif self.operationMode == 'del' then
		self.delData = {}
		self.banData = {}
		self.adminFu = {}

	elseif self.operationMode == 'setadmin' then
		self.delData = {}
		self.banData = {}
		self.adminFu = {}

	elseif self.operationMode == 'setscore' then
		self.delData = {}
		self.banData = {}
		self.adminFu = {}

	elseif self.operationMode == 'none' then
		self.delData = {}
		self.banData = {}
		self.adminFu = {}
		self:setAllMemberItemUnselect()

	end
end

return GVMemberListView