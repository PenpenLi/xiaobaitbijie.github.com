local Scheduler = require('app.helpers.Scheduler')
local SoundMng = require('app.helpers.SoundMng')
local tools = require('app.helpers.tools')
local ConvertToTableView = require('app.helpers.ConvertToTableView')
local cache = require('app.helpers.cache')
local app = require('app.App'):instance()

local GVOpenRoomListView = {}

function GVOpenRoomListView:initialize()
	self.group = nil
	self.selectIdx = nil
end

function GVOpenRoomListView:layout(group)
	self.group = group

	local mainPanel = self.ui:getChildByName('MainPanel')
	mainPanel:setPosition(display.cx, display.cy)
	self.mainPanel = mainPanel
	local openRoomInfoLayer = mainPanel:getChildByName('openRoomInfoLayer')
	local roomInfoList = openRoomInfoLayer:getChildByName('infoList')
	local item = openRoomInfoLayer:getChildByName('item')
	roomInfoList = ConvertToTableView.convert(roomInfoList,{
		fillOrder = cc.TABLEVIEW_FILL_BOTTOMUP
	})

	self.item = item
	self.tableView = roomInfoList
	self.item:setVisible(false)

	local function handler(func)
		return function(...)
			return func(self, ...)
		end
	end

	self.tableView:registerScriptHandler(handler(self.tableCellTouched), cc.TABLECELL_TOUCHED)
	self.tableView:registerScriptHandler(handler(self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
	self.tableView:registerScriptHandler(handler(self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
	self.tableView:registerScriptHandler(handler(self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	self.tableView:registerScriptHandler(handler(self.cellHightLight), cc.TABLECELL_HIGH_LIGHT)
	self.tableView:registerScriptHandler(handler(self.cellUnHightLight), cc.TABLECELL_UNHIGH_LIGHT)
	self.tableView:reloadData()
end

function GVOpenRoomListView:reloadTableView()
	self.tableView:reloadData()
end

function GVOpenRoomListView:freshCellSelectImg(cell, bShow)
	-- local item = cell:getChildByTag(6666)
	-- item:getChildByName('selectBg'):setVisible(bShow or false)
end

function GVOpenRoomListView:freshCell(cell, data)
	local item = cell:getChildByTag(6666)
	item:setVisible(true)

	item:getChildByName('roomId'):setString('房号'..data.roomId)		
	local time = os.date("%Y/%m/%d %H:%M:%S", data.time)	
	item:getChildByName('playTime'):setString('对战时间: '..time)

	for k, v in pairs(data.data) do
		local subItem = item:getChildByName('subItem'):getChildByName('subItem'..k)
		subItem:getChildByName('userName'):setString(v.nickname)
		subItem:getChildByName('userId'):setString('ID:'..v.playerId)		
		local score = subItem:getChildByName('score')		
		if v.money >= 0 then
			score:setString('+'..v.money)
			score:setColor(cc.c3b(17,217,38))
		else
			score:setString(''..v.money)
			score:setColor(cc.c3b(212,20,23))
		end
		subItem:setVisible(true)
	end
end

function GVOpenRoomListView:freshCellHeadImg(headimg, headUrl)
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

-- ==================== table view callback =========================

function GVOpenRoomListView:tableCellTouched(view, cell)
	if self.selectIdx then
		local lastCell = self.tableView:cellAtIndex(self.selectIdx)
		if lastCell then
			-- self:freshCellSelectImg(lastCell, false)
		end
	end
	self.selectIdx = cell:getIdx()
	-- self:freshCellSelectImg(cell, true)
end

function GVOpenRoomListView:cellSizeForTable(view, idx)
	local size = self.item:getContentSize()
	return size.width, size.height
end

function GVOpenRoomListView:tableCellAtIndex(view, idx)
	local dataIdx = idx + 1
	local cell = view:dequeueCell()

	local groupInfo = self.group:getCurGroup()    
	local groupId = groupInfo.id  
	local dataTmp = self.group:getSummaryList(groupId)
	local data = dataTmp and dataTmp.data[dataIdx] or {}

    if nil == cell then
        cell = cc.TableViewCell:new()
        --创建列表项
        local item = self.item:clone()
        item:setPosition(cc.p(0, 0))
        item:setTag(6666)
		cell:addChild(item)
	end
	
	self:freshCell(cell, data)
	return cell
end

function GVOpenRoomListView:numberOfCellsInTableView()
	local groupInfo = self.group:getCurGroup()    
	local groupId = groupInfo.id  
	local dataTmp = self.group:getSummaryList(groupId)
	local cnt = dataTmp and #dataTmp.data or 0
	return cnt
end

function GVOpenRoomListView:cellHightLight()
	
end

function GVOpenRoomListView:cellUnHightLight()
	
end



return GVOpenRoomListView
