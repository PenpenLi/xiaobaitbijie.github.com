local class = require('middleclass')
local XYDesk = require('app.models.xydesk')
local QZDesk = class("QZDesk", XYDesk)

function QZDesk:initialize()
    XYDesk.initialize(self)

    self.gameIdx = 30
    self.DeskName = 'niumowangqz'

    self:listen()
end

function QZDesk:onCustomSwitch()
    local app = require('app.App'):instance()

    app:switch('QZDeskController', self.DeskName)
end

function QZDesk:onPutMoney(msg)
    self.emitter:emit('freshBettingBar', msg)
    self.emitter:emit('bettingTimerStart')
end

function QZDesk:onQiangZhuang()
    self.emitter:emit('qiangZhuang')
    self.emitter:emit('qzTimerStart')
end

return QZDesk
