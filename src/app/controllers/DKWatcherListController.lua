local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local DKWatcherListController = class("DKWatcherListController", Controller):include(HasSignals)

function DKWatcherListController:initialize(deskModel)
	Controller.initialize(self)
	HasSignals.initialize(self)
	self.desk = deskModel
end

function DKWatcherListController:viewDidLoad()
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


function DKWatcherListController:clickBack()
	self.emitter:emit('back')
end

function DKWatcherListController:finalize()-- luacheck: ignore
	for i = 1, #self.listener do
		self.listener[i]:dispose()
	end
end

return DKWatcherListController
