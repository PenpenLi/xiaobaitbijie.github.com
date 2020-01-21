local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local WanFaController = class("WanFaController", Controller):include(HasSignals)

function WanFaController:initialize(data)
  Controller.initialize(self)
  HasSignals.initialize(self)
  self.mode = data[1]
end

function WanFaController:viewDidLoad()
  self.view:layout(self.mode)
end

function WanFaController:clickBack()
  self.emitter:emit('back')
end

function WanFaController:clickTab(sender)
  local tag = sender:getName()
  self.view:clickTab(tag)
end

function WanFaController:finalize()-- luacheck: ignore
end

function WanFaController:clickNotOpen()
  local tools = require('app.helpers.tools')
  tools.showRemind('暂未开放，敬请期待')
end

return WanFaController
