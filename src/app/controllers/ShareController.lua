local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local ShareController = class('ShareController', Controller):include(HasSignals)

function ShareController:initialize(data)
	Controller.initialize(self)
	HasSignals.initialize(self)
	self.groupInfo = nil
	self.data = nil
	if data then
		self.groupInfo = data.groupInfo
		self.data = data
	end
end

function ShareController:viewDidLoad()
	self.view:layout(self.data)
end

function ShareController:clickBack()
  self.emitter:emit('back')
end

function ShareController:setShare(flag)
	local SocialShare = require('app.helpers.SocialShare')

	local share_url = 'http://fir.im/enk9'
	local image_url = 'http://111.229.92.75/icon.png'
	local text = '我在 新世界 玩嗨了，快来加入吧！'
	local token = "0"
	if self.groupInfo then 
		text = text .. '俱乐部id：' .. self.groupInfo.id
		token = "1"
		share_url = share_url .. '?groupID=' .. self.groupInfo.id
	end
	SocialShare.share(flag, function(platform, stCode, errorMsg)
		print('platform, stCode, errorMsg', platform, stCode, errorMsg)
	end,
	share_url,
	image_url,
	text,
	'新世界',
	false,
	"invite",
	self.groupInfo and self.groupInfo.id or "0",
	token)
end

function ShareController:clickHaoYouQun()
	self:setShare(1)
end

function ShareController:clickPengYouQuan()
	self:setShare(2)
end

function ShareController:clickXianLiao()
	self:setShare(7)
end

function ShareController:invite(flag)
	local invokefriend = require('app.helpers.invokefriend')
	invokefriend.invoke(self.data.deskId, self.data.deskInfo, self.data.groupInfo, flag)
end

function ShareController:clickHYQ_invite()
	self:invite(1)
end

function ShareController:clickXL_invite()
	self:invite(7)
end

function ShareController:finalize()-- luacheck: ignore
end

return ShareController
