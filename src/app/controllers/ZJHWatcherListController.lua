local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local ZJHWatcherListController = class("ZJHWatcherListController", Controller):include(HasSignals)

function ZJHWatcherListController:initialize(deskModel)
    Controller.initialize(self)
    HasSignals.initialize(self)
    self.desk = deskModel
end

function ZJHWatcherListController:viewDidLoad()
    local app = require("app.App"):instance()
    self.view:layout(self.desk)

    self.listener = {    
    self.desk:on('watcherList', function(msg)
        local data = self.desk:getWatcherList()
        self.view:freshListView(data)
    end),
    }

    self.desk:watcherList()
end


function ZJHWatcherListController:clickBack()
    self.emitter:emit('back')
end

function ZJHWatcherListController:finalize()-- luacheck: ignore
    for i = 1, #self.listener do
        self.listener[i]:dispose()
    end
end

return ZJHWatcherListController