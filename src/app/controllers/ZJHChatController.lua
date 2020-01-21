local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local TranslateView = require('app.helpers.TranslateView')
local ZJHChatController = class("ZJHChatController", Controller):include(HasSignals)

local app = require("app.App"):instance()

function ZJHChatController:initialize(desk)
    Controller.initialize(self)
    HasSignals.initialize(self)
    self.desk = desk
end

function ZJHChatController:viewDidLoad()
    self.view:layout(self.desk)
    self.listener = {
        self.view:on("choosed", function(i)
            self.emitter:emit('back')
            local tmsg = {
                msgID = 'chatInGame',
                type = 0,
                msg = i
            }
            app.conn:send(tmsg)
        end),

        self.view:on("back", function()
            TranslateView.moveCtrl(self.view, 1, function()
                self:delete()
            end)
        end),

        self.desk:on('chatList', function(msg)
            dump(msg)
            local msgData = self.desk:getChatList()
            self.view:freshRecordList(msgData)
        end),

        self.desk:on('chatInGame', function(msg)
            dump(msg)
            local msgData = self.desk:getChatList()
            self.view:freshRecordList(msgData)        
        end),

    }

end

function ZJHChatController:clickSend()
    local text = self.view:getChatEditBoxInfo()
    if #text == 0 then
        return
    end

    local tmsg = {
        msgID = 'chatInGame',
        type = 2,
        msg = text
    }
    app.conn:send(tmsg)
    self.view:freshChatEditBox('', true)
    self:clickBack()
end

function ZJHChatController:clickShortcutBtn()    
    self.view:freshBtnState('shortcut')
    self.view:freshListState('shortcut')
end

function ZJHChatController:clickEmojiBtn()
    self.view:freshBtnState('emoji')
    self.view:freshListState('emoji')
end

function ZJHChatController:clickRecordBtn()
    self.view:freshBtnState('record')
    self.view:freshListState('record')
    self.desk:deskChatList()
end

function ZJHChatController:clickBack()
    self.emitter:emit('back')
end

function ZJHChatController:sendText()
end

function ZJHChatController:finalize()-- luacheck: ignore
    for i = 1, #self.listener do
        self.listener[i]:dispose()
    end
end

return ZJHChatController