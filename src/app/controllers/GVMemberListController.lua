local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local tools = require('app.helpers.tools')
local GVMemberListController = class("GVMemberListController", Controller):include(HasSignals)
local SoundMng = require "app.helpers.SoundMng"

function GVMemberListController:initialize(data)
    Controller.initialize(self)
    HasSignals.initialize(self)

    self.group = data[1]
	self.isAdmin = data[2] 
	self.isAdminFu = data[3] 
	self.isHehuo = data[4] 
end


function GVMemberListController:viewDidLoad()
	self.view:layout({self.group, self.isAdmin, self.isAdminFu, self.isHehuo})
	local group = self.group
	self.listener = {
		self.group:on('memberList', function(msg)
			self.view:freshGameState(true)
			self.view:freshMemberList()
		end),	

		self.view:on('userInfo', function(playerId)
			self.group:queryUserInfo(playerId)
		end),	
		group:on('resultSetAdminPlayer', function()
			self.view:freshtipsLayer(false)
		end),	
		group:on('resultSetMemberScore', function(msg)
			if msg.code == -1 then
				tools.showRemind("操作失败")
			elseif msg.code == 0 then
				tools.showRemind(msg.errorCode)
			elseif msg.code == 1 then
				tools.showRemind("操作成功")
				self:clickCloseScoreLayer()
			end
		end),	
	}
	
	local groupInfo = self.group:getCurGroup()
	local groupId = groupInfo.id
	self.group:memberList(groupId)
end 

function GVMemberListController:clickBan()
	local groupInfo = self.group:getCurGroup()
	if not groupInfo then return end
	local groupId = groupInfo.id
	if next(self.view.banData) then
		local arr = {}
		for k,v in pairs(self.view.banData) do
			table.insert(arr, k)
		end
		self.group:banUser(groupId, arr, 'ban')
	end
end

function GVMemberListController:clickUnban()
	local groupInfo = self.group:getCurGroup()
	if not groupInfo then return end
	local groupId = groupInfo.id
	if next(self.view.banData) then
		local arr = {}
		for k,v in pairs(self.view.banData) do
			table.insert(arr, k)
		end
		self.group:banUser(groupId, arr, 'unban')
	end
end

function GVMemberListController:clickSureDel()
	local groupInfo = self.group:getCurGroup()
	if not groupInfo then return end
	local groupId = groupInfo.id
	if next(self.view.delData) then
		local arr = {}
		for k,v in pairs(self.view.delData) do
			table.insert(arr, k)
		end
		self.group:delUser(groupId, arr)
	end
end

function GVMemberListController:clickSureSet()
	local k = 0
	if self.view.adminFu then
		for i, v in pairs(self.view.adminFu) do
			k = k + 1
		end
		if k > 3 then
			tools.showRemind('每个俱乐部最多设置3个副管理员')
			return
		end
	end
	self.view:freshtipsLayer(true)
end

function GVMemberListController:clickCloseTips()
	self.view:freshtipsLayer(false)
end

function GVMemberListController:clickCloseScoreLayer()
	self.view:freshScoreLayer(false)
end

function GVMemberListController:clickSetAdmin()
	local groupInfo = self.group:getCurGroup()
	if not groupInfo then return end
	local groupId = groupInfo.id
	local arr = {}
	if next(self.view.adminFu) then
		for k,v in pairs(self.view.adminFu) do
			table.insert(arr, k)
		end
	end
	self.group:setAdmin(groupId, arr)
end

function GVMemberListController:clickToBan()
	self.view:setOperationMode('ban')
	self.view:freshclicktoLayer(false,false,true,false,false,false,false)
end

function GVMemberListController:clickToDelete()
	self.view:setOperationMode('del')
	self.view:freshclicktoLayer(false,true,false,false,false,false,false)
end

function GVMemberListController:clickToAdmin()
	self.view:setOperationMode('none')
	if self.isAdminFu and self.isHehuo then
		self.view:freshclicktoLayer(false,false,false,false,true,false,true)
	elseif self.isAdminFu then
		self.view:freshclicktoLayer(false,false,false,false,true,false,false)
	elseif self.isHehuo then
		self.view:freshclicktoLayer(false,false,false,false,false,false,true)
	else
		self.view:freshclicktoLayer(true,false,false,false,false,false,false)
	end
end

function GVMemberListController:clickToSetAdmin()
	self.view:setOperationMode('setadmin') 
	self.view:freshclicktoLayer(false,false,false,true,false,false,false)
end

function GVMemberListController:clickToSetScore(sender)
	local data = sender:getComponent("ComExtensionData"):getCustomProperty()
	self.view:setOperationMode('setscore') 
	self.view:freshclicktoLayer(false,false,false,false,false,true,false)
	self.view:setScoreMode(data)
end

function GVMemberListController:clickReduceScore()
	self.view:freshSureLayer(true, 'reduce')
end

function GVMemberListController:clickAddScore()
	self.view:freshSureLayer(true, 'add')
end

function GVMemberListController:clickAddDelScore()
	self.view:freshSureLayer(true)
end

function GVMemberListController:clickCloseSureLayer()
	self.view:freshSureLayer(false)
end

function GVMemberListController:clickSureScore()
	local options = self.view:getScoreOptions()
	if not options.data or not options.mode or not options.newScore then 
		tools.showRemind('操作失败')
		return 
	end
	local groupInfo = self.group:getCurGroup()
	if not groupInfo then return end
	if options.state then
		tools.showRemind('该玩家正在游戏中')
		return 
	end
	dump(options)
	local groupId = groupInfo.id
	self.group:setMemberScore(groupId, options)
	self:clickCloseSureLayer()
end

function GVMemberListController:clickFind()
	SoundMng.playEft('btn_click.mp3')
	self.view:freshFindLayer(true)
end

--------------------------------------------------------------------
-- setScoreLayer
function GVMemberListController:clickGuoLv()
	SoundMng.playEft('btn_click.mp3')
	self.view:GuoLvPlayer()
end
--------------------------------------------------------------------
-- scoreLayer
function GVMemberListController:clickNumber(sender)
	SoundMng.playEft('btn_click.mp3')
	local data = sender:getComponent("ComExtensionData"):getCustomProperty()
  	self.view:setNewScore('input', data)
end

function GVMemberListController:clickDelete()
	SoundMng.playEft('btn_click.mp3')
  	self.view:setNewScore('del')
end

function GVMemberListController:clickReenter()
	SoundMng.playEft('btn_click.mp3')
  	self.view:setNewScore('reenter')
end
--------------------------------------------------------------------

--------------------------------------------------------------------
-- findLayer
function GVMemberListController:clickCloseFind()
	self.view:freshFindLayer(false)
end

function GVMemberListController:clickNumber_f(sender)
	SoundMng.playEft('btn_click.mp3')
	local data = sender:getComponent("ComExtensionData"):getCustomProperty()
  	self.view:setFindID('input', data)
end

function GVMemberListController:clickDelete_f()
	SoundMng.playEft('btn_click.mp3')
	self.view:setFindID('del')
end

function GVMemberListController:clickReenter_f()
	SoundMng.playEft('btn_click.mp3')
	self.view:setFindID('reenter')
end
--------------------------------------------------------------------

function GVMemberListController:finalize()
    for i = 1,#self.listener do
      self.listener[i]:dispose()
    end
end

function GVMemberListController:clickBack()
	self.emitter:emit('back')
end

return GVMemberListController