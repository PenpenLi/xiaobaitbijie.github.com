local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local PJPlaybackController = class("PJPlaybackController", Controller):include(HasSignals)

function PJPlaybackController:initialize(deskModel)
    Controller.initialize(self)
    HasSignals.initialize(self)
    self.desk = deskModel    
end

function PJPlaybackController:viewDidLoad()
    self.view:layout(self.desk)
	self.listener = {		
        self.desk:on('deskRecord', function(msg)
			self.view:freshRecordView('lastPage', msg.mode)
		end),   

    } 

    self.desk:deskRecord()
end

function PJPlaybackController:firstPage()
    self.view:freshRecordView('firstPage')   
end

function PJPlaybackController:frontPage()
    self.view:freshRecordView('frontPage')   
end

function PJPlaybackController:nextPage()
    self.view:freshRecordView('nextPage')   
end

function PJPlaybackController:lastPage()
    self.view:freshRecordView('lastPage')   
end

function PJPlaybackController:clickBack()
    self.emitter:emit('back')
end

function PJPlaybackController:finalize()
	for i = 1, #self.listener do
		self.listener[i]:dispose()
	end
end

return PJPlaybackController
