local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local GVOpenRoomListController = class("GVOpenRoomListController", Controller):include(HasSignals)

function GVOpenRoomListController:initialize(group)
    Controller.initialize(self)
    HasSignals.initialize(self)

    self.group = group
end

function GVOpenRoomListController:viewDidLoad()
    self.view:layout(self.group)
    local group = self.group

    self.listener = {
        self.group:on('Group_recentlSummaryResult',function(msg)     
            self.view:reloadTableView()
        end),       
    } 

    local groupInfo = self.group:getCurGroup()
    local groupId = groupInfo.id     
    self.group:recentlSummary(groupId)    
end

function GVOpenRoomListController:clickBack()
    self.emitter:emit('back')
end

function GVOpenRoomListController:finalize()
    for i = 1,#self.listener do
      self.listener[i]:dispose()
    end
end

return GVOpenRoomListController
