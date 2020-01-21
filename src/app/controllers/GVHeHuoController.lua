local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local tools = require('app.helpers.tools')
local SoundMng = require('app.helpers.SoundMng')
local GVHeHuoController = class("GVHeHuoController", Controller):include(HasSignals)

function GVHeHuoController:initialize(data)
    Controller.initialize(self)
    HasSignals.initialize(self)

    self.group = data[1]
	self.isOwner = data[2]
	self.isHehuo = data[3]
	local groupInfo = self.group:getCurGroup()
	self.bindgroupId = groupInfo.id
	self.memberInfoRecord = {}
end


function GVHeHuoController:viewDidLoad()
	self.view:layout({self.group, self.isOwner, self.isHehuo})
	local group = self.group

	self.listener = {

		group:on('Group_queryHeHuoInfoResult',function(msg)
			self.view:freshHehuoInfo(msg)
		end),		

		group:on('HeHuoOperationResult',function(msg)
			if msg.openType == 'add' then
				if msg.code == -2 then
					tools.showRemind('该成员已经是合伙人')
				elseif msg.code == -1 then
					tools.showRemind('俱乐部没有该成员')
				elseif msg.code == 1 then
					tools.showRemind('添加成功')
					self.view:freshEnterView(false)
				end
			elseif msg.openType == 'invite' then
				if msg.code == -1 then
					tools.showRemind('邀请失败')
				elseif msg.code == -2 then
					tools.showRemind('该玩家已成为俱乐部其它合伙人的成员')
				elseif msg.code == 1 then
					tools.showRemind('已向玩家发送邀请')
					self.view:freshEnterView(false)
				end
			elseif msg.openType == 'find' then
				if msg.code == -1 then
					tools.showRemind('没有该合伙人')
				elseif msg.code == 1 then
					if msg.data then
						self.view:freshEnterView(false)
						self.view:freshHehuoInfo(msg)
					end
				end
			elseif msg.openType == 'tiaopei' then
				if msg.code == -1 then
					tools.showRemind('俱乐部没有该合伙人')
				elseif msg.code == -2 then
					tools.showRemind('俱乐部没有该成员')
				elseif msg.code == -3 then
					tools.showRemind('该合伙人没有该成员')
				elseif msg.code == 1 then
					tools.showRemind('调配成功')
					self.view:freshTiaoPeiLayer(false)
				end
			end
		end),	

		group:on('Group_DelHeHuoResult',function(msg)
			if msg.code == -1 then
				tools.showRemind('没有该合伙人')
			elseif msg.code == 1 then
				tools.showRemind('删除成功')
			end
		end),	
		
		group:on('Group_queryMemberInfoResult',function(msg)
			if msg.isEnd then
				if msg.data then
					self.memberInfoRecord[msg.data.playerId] = msg.data
				end
				self.fengcheng = msg.fengcheng
				self.view:freshMemberInfo({inviter = msg.inviter, fengcheng = msg.fengcheng, data = clone(self.memberInfoRecord)})
				self.memberInfoRecord = {}
			else
				self.memberInfoRecord[msg.data.playerId] = msg.data
			end
		end),

		group:on('Group_DelMemberResult',function(msg)
			if msg.code == -1 then
				tools.showRemind('没有该成员')
			elseif msg.code == 1 then
				tools.showRemind('删除成功')
				-- self.view:freshMemberInfo(msg)
			end
		end),	

		group:on('Group_SetFengchengResult',function(msg)
			if msg.code == -1 then
				tools.showRemind('设置比例失败')
			elseif msg.code == 1 then
				tools.showRemind('设置比例成功')
				self.view:freshMemberLayer(false)
			end
		end),	
	}
	
	local groupInfo = self.group:getCurGroup()
	local groupId = groupInfo.id
	self.groupId = groupId
	if self.isOwner then
		self.group:queryHehuoInfo(groupId)
	end
	if self.isHehuo then
		self.group:queryMemberInfo(groupId, self.group:getPlayerRes("playerId"))
	end
end 

------------------------------------------------------------------------------------
-- 群主功能
function GVHeHuoController:clickFindHeHuo()
	SoundMng.playEft('btn_click.mp3')
	self.view:freshEnterView(true, 'find')
end

function GVHeHuoController:clickAddHeHuo()
	SoundMng.playEft('btn_click.mp3')
	self.view:freshEnterView(true, 'add')
end

function GVHeHuoController:clickTiaoPei()
	SoundMng.playEft('btn_click.mp3')
	self.view:freshTiaoPeiLayer(true)
end

function GVHeHuoController:clickCloseMemberLayer()
	SoundMng.playEft('btn_click.mp3')
	
	local text = tonumber(self.view:getFenchengText())
	if text and text == self.fengcheng then
		self.view:freshMemberLayer(false)
		self.view:setCurrentInviter(nil)
		return 
	end
	if text > 100 or text < 0 then
		tools.showRemind("分成比例请设置在0~100之间")
		return 
	end
	local inviter = self.view:getCurrentInviter()
	self.group:onFengcheng(self.groupId, text, inviter)
end

function GVHeHuoController:clickFanshui()
	SoundMng.playEft('btn_click.mp3')

	local inviter = self.view:getCurrentInviter()
	if not inviter then return end
	local groupInfo = self.group:getCurGroup()
    local groupId = groupInfo.id     
    local myPlayerId = self.group:getPlayerRes("playerId") 
    local isMeHehuo = self.group:getMeHehuo(groupId, myPlayerId)
    self:setWidgetAction('GVSetScoreController', {self.group,'fanshui',isMeHehuo,inviter}) 
end
------------------------------------------------------------------------------------

------------------------------------------------------------------------------------
-- 合伙人功能
function GVHeHuoController:clickInvite()
	SoundMng.playEft('btn_click.mp3')
	self.view:freshEnterView(true, 'invite')
end

------------------------------------------------------------------------------------

------------------------------------------------------------------------------------
-- enterView
function GVHeHuoController:clickCloseEnter()
	self.view:freshEnterView(false)
end

function GVHeHuoController:clickDelete()
	SoundMng.playEft('btn_click.mp3')
	self.view:Delete()
end

function GVHeHuoController:clickReenter()
	SoundMng.playEft('btn_click.mp3')
	self.view:Reenter()
end
------------------------------------------------------------------------------------

------------------------------------------------------------------------------------
--调配界面
function GVHeHuoController:clickSure()
	local playerId, hehuoId = self.view:getTiaoPeiInfo()
	local currentInviter = self.view:getCurrentInviter()
	if not playerId or playerId == '' then
		tools.showRemind('请输入要调配的玩家id')
		return
	end
	if not hehuoId or hehuoId == '' then
		tools.showRemind('请输入要调配到的合伙人id')
		return
	end
	if not currentInviter then 
		tools.showRemind('信息获取错误, 请重新进入界面')
		return
	end

	local list = self.group:getRoomList(self.groupId)
	if list then
		for i,v in pairs(list) do
			for j,k in pairs(v.playerList) do
				if playerId == k.playerId then
					tools.showRemind("该玩家正在游戏中，不能调配")
					return 
				end
			end
		end
	end

	local msg = {
		playerId = tonumber(playerId),
		hehuoId = tonumber(hehuoId),
		openType = 'tiaopei',
		groupId = self.groupId,
		currentInviter = currentInviter,
	}
	self.group:HeHuoOperation(msg)
end

function GVHeHuoController:clickCloseTiaoPei()
	self.view:freshTiaoPeiLayer(false)
end
------------------------------------------------------------------------------------

function GVHeHuoController:finalize()
    for i = 1,#self.listener do
      self.listener[i]:dispose()
    end
end

function GVHeHuoController:clickBack()
	SoundMng.playEft('btn_click.mp3')
	self.emitter:emit('back')
end

function GVHeHuoController:setWidgetAction(controllerName, ...)
    local ctrl = Controller:load(controllerName, ...)
    self:add(ctrl)

    local app = require("app.App"):instance()
    app.layers.ui:addChild(ctrl.view)
    ctrl.view:setPositionX(0)

    ctrl:on('back', function()
        ctrl:delete()
    end)
    return ctrl
end

return GVHeHuoController