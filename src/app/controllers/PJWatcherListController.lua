local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local PJWatcherListController = class("PJWatcherListController", Controller):include(HasSignals)

function PJWatcherListController:initialize(deskModel)
	Controller.initialize(self)
	HasSignals.initialize(self)
	self.desk = deskModel
end

function PJWatcherListController:viewDidLoad()
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


function PJWatcherListController:clickBack()
	self.emitter:emit('back')
end

function PJWatcherListController:finalize()-- luacheck: ignore
	for i = 1, #self.listener do
		self.listener[i]:dispose()
	end
end

return PJWatcherListController
