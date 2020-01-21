local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local GVRecordListController = class("GVRecordListController", Controller):include(HasSignals)

function GVRecordListController:initialize(group)
    Controller.initialize(self)
    HasSignals.initialize(self)

    self.group = group
end

function GVRecordListController:viewDidLoad()
    self.view:layout(self.group)
    local group = self.group

    self.listener = {
        self.group:on('Group_winnerListResult',function(msg)     
            self.view:reloadTableView()
        end),  

      --[[   self.view:on('messageListOperate',function(optApply)
            dump(optApply)
            local groupInfo = group:getCurGroup()
            local groupId = groupInfo.id
            local playerId = optApply[1]
            local operate = optApply[2]
            group:acceptJoin(groupId, playerId, operate)
        end),   ]]         
    } 

    local groupInfo = self.group:getCurGroup()
    local groupId = groupInfo.id     
    self.group:winnerList(groupId)
end

function GVRecordListController:clickBack()
    self.emitter:emit('back')
end

function GVRecordListController:finalize()
    for i = 1,#self.listener do
      self.listener[i]:dispose()
    end
end

return GVRecordListController
