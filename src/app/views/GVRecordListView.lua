local Scheduler = require('app.helpers.Scheduler')
local SoundMng = require('app.helpers.SoundMng')
local tools = require('app.helpers.tools')
local ConvertToTableView = require('app.helpers.ConvertToTableView')
local cache = require('app.helpers.cache')
local app = require('app.App'):instance()

local GVRecordListView = {}

function GVRecordListView:initialize()
	self.group = nil
	self.selectIdx = nil
end

function GVRecordListView:layout(group)
	self.group = group

	local mainPanel = self.ui:getChildByName('MainPanel')
	mainPanel:setPosition(display.cx, display.cy)
	self.mainPanel = mainPanel
	local recordLayer = mainPanel:getChildByName('recordLayer')
	local recordList = recordLayer:getChildByName('recordList')
	local recordItem = recordLayer:getChildByName('item')
	recordList = ConvertToTableView.convert(recordList)

	self.item = recordItem
	self.tableView = recordList
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

function GVRecordListView:reloadTableView()
	self.tableView:reloadData()
end

function GVRecordListView:freshCellSelectImg(cell, bShow)
	-- local item = cell:getChildByTag(6666)
	-- item:getChildByName('selectBg'):setVisible(bShow or false)
end

function GVRecordListView:freshCell(cell, data)
	local item = cell:getChildByTag(6666)
	item:setVisible(true)
	local time = os.date("%Y/%m/%d %H:%M:%S", data.time)	
	print(time)
	item:getChildByName('time'):setString(time)
	item:getChildByName('deductRoomCard'):setString('扣卡 '..data.cost)

	for k, v in pairs(data.data) do
		local subItem = item:getChildByName('subItem'..k)
		subItem:getChildByName('userName'):setString(v.nickname)
		subItem:getChildByName('userId'):setString('ID:'..v.playerId)
		subItem:getChildByName('score'):setString('+'..v.money):setColor(cc.c3b(247,187,4))
		subItem:setVisible(true)
	end
end

function GVRecordListView:freshCellHeadImg(headimg, headUrl)
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

function GVRecordListView:tableCellTouched(view, cell)
	if self.selectIdx then
		local lastCell = self.tableView:cellAtIndex(self.selectIdx)
		if lastCell then
			-- self:freshCellSelectImg(lastCell, false)
		end
	end
	self.selectIdx = cell:getIdx()
end

function GVRecordListView:cellSizeForTable(view, idx)
	local size = self.item:getContentSize()
	return size.width, size.height
end

function GVRecordListView:tableCellAtIndex(view, idx)
	local dataIdx = idx + 1
	local cell = view:dequeueCell()

	local groupInfo = self.group:getCurGroup()    
	local groupId = groupInfo.id  
	local dataTmp = self.group:getRecordList(groupId)
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

function GVRecordListView:numberOfCellsInTableView()
	local groupInfo = self.group:getCurGroup()    
	local groupId = groupInfo.id  
	local data = self.group:getRecordList(groupId)
	local cnt = data and #data.data or 0
	return cnt
end

function GVRecordListView:cellHightLight()	
end

function GVRecordListView:cellUnHightLight()	
end



return GVRecordListView
