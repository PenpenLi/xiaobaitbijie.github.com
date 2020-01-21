local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local GVChatRecordListController = class("GVChatRecordListController", Controller):include(HasSignals)

function GVChatRecordListController:initialize(data)
	Controller.initialize(self)
	HasSignals.initialize(self)
	
	self.group = data[1]
	self.parentCtrl = data[2]
end

function GVChatRecordListController:viewDidLoad()
	self.view:layout(self.group)
	local group = self.group
	
	self.listener = {
        self.group:on('Group_synMsgResult', function(msg)	
            self.view:setVisible(true)
			self.view:reloadTableView()
		end),
    }
    
	-- local groupInfo = group:getCurGroup()
    -- if groupInfo then
    --     local groupId = groupInfo.id
    --     self.group:synMsg(groupId)
    -- end
end

function GVChatRecordListController:finalize()
	for i = 1, #self.listener do
		self.listener[i]:dispose()
	end
end

return GVChatRecordListController
