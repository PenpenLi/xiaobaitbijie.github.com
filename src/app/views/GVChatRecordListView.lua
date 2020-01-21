local Scheduler = require('app.helpers.Scheduler')
local SoundMng = require('app.helpers.SoundMng')
local tools = require('app.helpers.tools')
local ConvertToTableView = require('app.helpers.ConvertToTableView')
local cache = require('app.helpers.cache')
local app = require('app.App'):instance()

local GVChatRecordListView = {}

local chatsTbl = {
    '游戏搞起来, 气氛热起来!',
    '缺一, 没人就开了!',
    '房里的赶紧准备, 开始了!',
    '大家一起浪起来!',
	'我有点事, 你们先玩!',  
}

function GVChatRecordListView:initialize()
	self.group = nil
	self.selectIdx = nil

	self.sysMsgTag = 333
	self.userMsgTag = 666

	self.tabCacheHead = {} --[[
		K: idx..lastTag | 
		V:{
			idx:num, 	-- 取出cell
			itemTag:num,  --区分item类型 
			headTag:num,  -- 头像节点标签
		}]]
	
end

function GVChatRecordListView:layout(group)
	self.group = group

	local mainPanel = self.ui:getChildByName('MainPanel')
	self.mainPanel = mainPanel
	local chatRecordList = mainPanel:getChildByName('chatRecordList')
	chatRecordList = ConvertToTableView.convert(chatRecordList)

	self.tableView = chatRecordList

	self.itemSysMsg = mainPanel:getChildByName('systemMessageItem')
	self.itemMyMsg = mainPanel:getChildByName('myMessageItem')
	self.itemOtherMsg = mainPanel:getChildByName('othersMessageItem')

	local function handler(func)
		return function(...)
			return func(self, ...)
		end
	end

	-- self.tabData = {
	-- 	2,3,4,5,6,2,3,4,5,6,2,3,4,5,6,2,3,4,5,6,2,3,4,5,6,2,3,4,5,6,2,3,4,5,6,2,3,4,5,6,2,3,4,5,6,
	-- }

	-- self.tabData = {
	-- 	0,2,0,3,0,4,0,5,0,6,1,1,1,2,1,3,1,4,1,5,1,6,0,2,0,3,0,4,0,5,0,6,1,1,1,2,1,3,1,4,1,5,1,6,0,2,0,3,0,4,0,5,0,6,1,1,1,2,1,3,1,4,1,5,1,6,0,2,0,3,0,4,0,5,0,6,1,1,1,2,1,3,1,4,1,5,1,6,
	-- }


	-- self.tabData = {
	-- 	2,3,4,5,6,
	-- }

	self.tableView:registerScriptHandler(handler(self.tableCellTouched), cc.TABLECELL_TOUCHED)
	self.tableView:registerScriptHandler(handler(self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
	self.tableView:registerScriptHandler(handler(self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
	self.tableView:registerScriptHandler(handler(self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	self.tableView:registerScriptHandler(handler(self.cellHightLight), cc.TABLECELL_HIGH_LIGHT)
	self.tableView:registerScriptHandler(handler(self.cellUnHightLight), cc.TABLECELL_UNHIGH_LIGHT)
	self.tableView:reloadData()

	self:jumpToIndex()
end

function GVChatRecordListView:reloadTableView()
	math.newrandomseed()
	self.tableView:reloadData()
	self:jumpToIndex()
end

function GVChatRecordListView:freshCellSelectImg(cell, bShow)
	-- local item = cell:getChildByTag(6666)
	-- item:getChildByName('selectBg'):setVisible(bShow or false)
end

function GVChatRecordListView:freshCell(cell, data)
	local item = cell:getChildByTag(6666)
	item:setVisible(true)
			
end

function GVChatRecordListView:freshCellHeadImg(headimg, headUrl)
	headimg:loadTexture('views/public/tx.png')
	if headUrl == nil or headUrl == '' then return end		 
	cache.get(headUrl, function(ok, path)
		if ok then
			headimg:show()
			headimg:loadTexture(path)
		else
			headimg:loadTexture('views/public/tx.png')
		end
	end)
end

function GVChatRecordListView:cacheAvatar(headUrl, idx, type, headnode, subIdx)
	local bool, cPath = cache.getCache(headUrl)
	if bool then
		headnode:loadTexture(cPath)
		return
	end

	-- 未缓存的头像

	local rand = math.random(1000, 9999)
	local name = idx..rand
	headnode:setName(name)

	print('cacheHead',idx, name)

	-- local key = string.format('%s%s', idx, headTag)
	-- local data = {
	-- 	idx = idx,
	-- 	itemTag = type,
	-- 	headTag = headTag,
	-- }
	
	-- self.tabCacheHead[key] = data


	cache.get(headUrl, function(ok, path)
		if ok then
			local function loadImg() 
				repeat
					print('loadHead', idx, name)
					-- if not self.tabCacheHead[key] then break end
					if not self then break end
					if not self.tableView then break end
					if tolua.isnull(self.tableView) then return end
					
					local cell = self.tableView:cellAtIndex(idx)
					if not cell then 
						print('	 |no cell', name)
						break 
					end
					local item = cell:getChildByTag(type)
					if not item then 
						print('	 |diff type', name)
						break 
					end
					local headImg 
					if type == self.sysMsgTag then
						local content = item:getChildByName('content')
						local subList = content:getChildByName('subList')
						local subItem = subList:getItem(subIdx)	
						if not subItem then
							print('	 |no subItem', subIdx)
							break
						end
						headImg = subItem:getChildByName('txKuang')
					elseif type == self.userMsgTag then
						headImg = item:getChildByName('txKuang')
					end
					if not headImg then
						print('	 |no headImg', type)
						break
					end
					local curName = headImg:getName()
					if curName == name then
						print('	 |loadImg', name)
						headImg:setVisible(true)
						headImg:loadTexture(path)
					end
				until true
			end
			pcall(loadImg, 'gvchatheadimg')
			-- self.tabCacheHead[key] = nil
		end
	end)
end

-- ==================== items =========================

function GVChatRecordListView:sizeForSystemMsg(cnt)
	-- min 129 max 310 per 39
	local height = 176 + ((cnt - 2)*40)
	return 820, height
end

function GVChatRecordListView:initSystemMsg(cell, idx, data)

	local item = self.itemSysMsg:clone()
	item:setTag(self.sysMsgTag)

	local content = item:getChildByName('content')
	local bg = content:getChildByName('img_bg')
	local subList = content:getChildByName('subList')
	content:getChildByName('roomId'):setString('房号: '..data.roomId)
	local playTime = content:getChildByName('playTime')
	local time = os.date("%Y/%m/%d %H:%M:%S", data.time) --data
	playTime:setString(time)

	local cnt = #data.data

	local function freshBg(cnt)
		local h = 145 + ((cnt - 2)*37)
		bg:setContentSize(cc.size(612, h))
	end

	local function freshSubList(cnt, data)
		for i = 0, 5 do
			local subItem = subList:getItem(i)
			if i <= (cnt-1) then
				local iData = data[i+1]
				if not iData then 
					subItem:setVisible(false)
					return
				end

				subItem:setVisible(true)

				-- self:freshCellHeadImg(headimg, iData.avatar) -- headUrl data
				local headimg = subItem:getChildByName('txKuang')
				-- headimg:loadTexture('views/public/tx.png')
				self:cacheAvatar(iData.avatar, idx, self.sysMsgTag, headimg, i)

				subItem:getChildByName('userName'):setString(iData.nickname) --data

				subItem:getChildByName('score'):setString(iData.money) --data
				if iData.money >= 0 then
					subItem:getChildByName('score'):setColor(cc.c3b(255,255,0))
				else
					subItem:getChildByName('score'):setColor(cc.c3b(255,0,0))
				end

				local winner = subItem:getChildByName('winner')
				winner:setVisible(false)
				if iData.bigWinner then --data
					winner:setVisible(true)
				end
			else
				subItem:setVisible(false)
			end 
		end
	end

	freshBg(cnt)
	freshSubList(cnt, data.data)

	cell:addChild(item)
	
	local size = cc.size(self:sizeForSystemMsg(cnt))
	item:setContentSize(size)
	item:setPositionY(size.height)

	content:setPositionY(size.height)

	item:setVisible(true)
end

function GVChatRecordListView:sizeForChatMsg()
	return 820, 90
end

function GVChatRecordListView:initChatMsg(cell, idx, data)
	local item 

	local pInfo = data.playerInfo
	local myPlayerId = self.group:getPlayerRes("playerId") --自己id

	if myPlayerId == pInfo.playerId then
		item = self.itemMyMsg:clone()
	else
		item = self.itemOtherMsg:clone()
	end

	item:setTag(self.userMsgTag)
	cell:addChild(item)

	-- 头像
	-- self:freshCellHeadImg(headimg, pInfo.avatar) -- headUrl data
	local headimg = item:getChildByName('txKuang')
	-- headimg:loadTexture('views/public/tx.png')
	self:cacheAvatar(pInfo.avatar, idx, self.userMsgTag, headimg)

	
	local nameStr = string.format('%s (ID: %s)',pInfo.nickname, pInfo.playerId) 
	item:getChildByName('userNameAndId'):setString(nameStr) --data
	item:getChildByName('copyTouch'):addTouchEventListener(function()			
		-- local content --data
		-- self.emitter:emit('selectGroup', content)
	end)	

	--管理员
	
	local mgrImg = item:getChildByName('img_manager')
	mgrImg:setVisible(false)
	local groupInfo = self.group:getCurGroup()
	if groupInfo then
		if pInfo.playerId == groupInfo.ownerInfo.playerId then
			mgrImg:setVisible(true)
		end
	end

	-- 内容

	local content = ''
	local chatType = data.chatType
	if chatType and chatType == 1 then
		local chatIdx = data.chatIdx or 1
		content = chatsTbl[chatIdx]
	elseif chatType and chatType == 2 then
		content = data.chatContent or ''
	end
	item:getChildByName('content'):setString(content)

	-- 点击复制文本
	item:getChildByName('copyTips'):setVisible(false)

	local size = cc.size(self:sizeForChatMsg())
	item:setPositionY(size.height)

	item:setVisible(true)
end

function GVChatRecordListView:jumpToIndex(idx)
	if not idx then 
		self.tableView:setContentOffset(cc.p(0, 0), false) 
		return 
	end

	local sum = 0
	for i = 0, idx do
		local _, h = self:cellSizeForTable(nil, i)
		sum = sum + h
	end
	local off = self.tableView:getContentOffset(cc.p(0, -sum), false)
	
end

function GVChatRecordListView:getGroupMsgList(dataIdx)
	dataIdx = dataIdx or 1
	local groupInfo = self.group:getCurGroup()
	if not groupInfo then return end
	local groupId = groupInfo.id
	local msgList = self.group:getMsgList(groupId)
	if msgList then
		return msgList[dataIdx], msgList
	end
end

-- function GVChatRecordListView:getCurGroup()
-- 	local groupInfo = self.group:getCurGroup()
-- 	if not groupInfo then return end
-- 	local groupId = groupInfo.id
-- 	local msgList = self.group:getMsgList(groupId)
-- 	return msgList[dataIdx], msgList
-- end

-- ==================== table view callback =========================

function GVChatRecordListView:tableCellTouched(view, cell)

	-- if self.selectIdx then
	-- 	local lastCell = self.tableView:cellAtIndex(self.selectIdx)
	-- 	if lastCell then
	-- 		-- self:freshCellSelectImg(lastCell, false)
	-- 	end
	-- end
	-- self.selectIdx = cell:getIdx()
	-- -- self:freshCellSelectImg(cell, true)
end

function GVChatRecordListView:cellSizeForTable(view, idx)
	-- local size = self.item:getContentSize()
	local dataIdx = idx + 1
	local data = self:getGroupMsgList(dataIdx)
	if not data then
		return 0, 0 
	end

	local type = data.type or ''
	local w, h
	if type == 'chat' then
		w, h = self:sizeForChatMsg()
	elseif type == 'summary' then
		w, h = self:sizeForSystemMsg(#data.data)
	else
		w = 0
		h = 0
	end
	return w, h
end

function GVChatRecordListView:tableCellAtIndex(view, idx)
	local dataIdx = idx + 1
	local cell = view:dequeueCell()

    if not cell then
        cell = cc.TableViewCell:new()
	end
	
	local data = self:getGroupMsgList(dataIdx)
	if not data then 
		return
	end

	local type = data.type or ''
	cell:removeAllChildren()

	if type == 'chat' then
		self:initChatMsg(cell, idx, data)
	elseif type == 'summary' then
		self:initSystemMsg(cell, idx, data)
	else
		return
	end
	
	return cell
end

function GVChatRecordListView:numberOfCellsInTableView()
	local _, data = self:getGroupMsgList()
	return data and #data or 0
end

function GVChatRecordListView:cellHightLight()
	
end

function GVChatRecordListView:cellUnHightLight()
	
end



return GVChatRecordListView
