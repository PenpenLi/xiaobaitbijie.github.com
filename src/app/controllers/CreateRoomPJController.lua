local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local cjson = require('cjson')
local SoundMng = require('app.helpers.SoundMng')
local CreateRoomPJController = class("CreateRoomPJController", Controller):include(HasSignals)
local tools = require('app.helpers.tools')

function CreateRoomPJController:initialize(groupInfo, createmode,paymode)
    Controller.initialize(self)
    HasSignals.initialize(self)
    self.groupInfo = groupInfo
    self.createmode = createmode
    self.paymode = 1
    if paymode then 
        self.paymode = paymode.payMode 
    end
end

function CreateRoomPJController:viewDidLoad()
    local app = require("app.App"):instance()
    self.view:layout(self.groupInfo, self.createmode,self.paymode)
    self.listener = {
        app.session.room:on('createRoom', function(msg)
            if msg.errorCode then
                self:delShowWaiting()
            end
            if msg.enterOnCreate and msg.enterOnCreate == 1 then
                -- self:clickBack()
                self:delShowWaiting()
            end
        end),

        app.session.room:on('Group_setRoomConfigResult', function(msg)
            self:clickBack()
        end),    

        app.session.room:on('roomConfigFlag', function(msg)
            self.view:freshHasSave(msg.data)
        end), 

        app.session.room:on('closePJ', function(msg)
            self.emitter:emit('back')
        end),  
        
        app.session.room:on('showOther', function(msg)
            if msg == 'pj' then
                self.view:setVisible(true)
                self.view:freshTab(msg)
            else
                self.view:setVisible(false)
            end
        end),  
    }

    if self.groupInfo then
        app.session.room:roomConfigFlag(self.groupInfo)
    end
end

function CreateRoomPJController:finalize()-- luacheck: ignore
    for i = 1, #self.listener do
        self.listener[i]:dispose()
    end
end

function CreateRoomPJController:clickCreate()
    local app = require("app.App"):instance()
    local options = self.view:getOptions()

    if options.scoreOption.choushui_pj < 0 or options.scoreOption.choushui_pj >= 100 then
        tools.showRemind("请调整抽水比例")
        return
    end
    if not options.scoreOption.join or not options.scoreOption.tui or not options.scoreOption.qiang then
        tools.showRemind("抽水设置不能为空")
        return
    end

    local gameIdx = app.session.paijiu.gameIdx

    self.view:showWaiting()

    app.session.room:createRoom(gameIdx, options, self.groupInfo)
end

function CreateRoomPJController:clickQuickStart()
    local app = require("app.App"):instance()
    local options = self.view:getOptions()

    if options.scoreOption.choushui_pj < 0 or options.scoreOption.choushui_pj >= 100 then
        tools.showRemind("请调整抽水比例")
        return
    end
    if not options.scoreOption.join or not options.scoreOption.tui or not options.scoreOption.qiang then
        tools.showRemind("抽水设置不能为空")
        return
    end

    local gameIdx = app.session.paijiu.gameIdx
    local gameplay = options.gameplay

    self.view:showWaiting()

    app.session.room:quickStart(self.groupInfo, gameplay, gameIdx)
end

function CreateRoomPJController:clickSureBtn()
    local app = require("app.App"):instance()
    local options = self.view:getOptions()

    if options.scoreOption.choushui_pj < 0 or options.scoreOption.choushui_pj >= 100 then
        tools.showRemind("请调整抽水比例")
        return
    end
    if not options.scoreOption.join or not options.scoreOption.tui or not options.scoreOption.qiang then
        tools.showRemind("抽水设置不能为空")
        return
    end

    local gameIdx = app.session.paijiu.gameIdx
    local gameplay = options.gameplay
    app.session.room:roomConfig(gameplay, options, self.groupInfo)
end

function CreateRoomPJController:clickBack()
    local app = require("app.App"):instance()
    app.session.room:closeAll()
    self.emitter:emit('back')
end

------------------------------------------------------------------------------------------
--三个问号提示的点击事件
function CreateRoomPJController:clickRoomPriceLayer()
    self.view:freshPriceLayer(false) 
end
function CreateRoomPJController:clickPriceWhy()
    self.view:freshPriceLayer(true) 
end

function CreateRoomPJController:clickquickLayer()
    self.view:freshquickLayer(false) 
end
function CreateRoomPJController:clickquickWhy()
    self.view:freshquickLayer(true) 
end

function CreateRoomPJController:clickChoushuiLayer(sender)
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    local body = cjson.decode(data)
    self.view:freshChoushuiLayer(false,body)
end
function CreateRoomPJController:clickChoushuiSelect(sender)
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    local body = cjson.decode(data)
    self.view:freshChoushuiLayer(true,body)
end
--------------------------------------------------------------------------------------------

function CreateRoomPJController:clickNotOpen()
    local tools = require('app.helpers.tools')
    tools.showRemind('暂未开放，敬请期待')
end

--------------------------------------------------------------------------------------------
--左边选择模式点击事件
function CreateRoomPJController:clickChangeGameType(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    local app = require("app.App"):instance()
    if data == 'pj' then
        app.session.room:setCurrentType('pj')
        self.view:freshTab('pj')
    else
        self.view:setVisible(false)
        app.session.room:showOther(data)
    end
end

function CreateRoomPJController:clickchangetype(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = 'pj'
    local app = require("app.App"):instance()
    self.view:freshTab(data)
end

--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
--各模式的刷新事件
function CreateRoomPJController:clickBase(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshbase(data,sender)
end

function CreateRoomPJController:clickRound(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshround(data,sender)
end

function CreateRoomPJController:clickspecial(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshspecial_now(data,sender)
end

function CreateRoomPJController:clickputmoney(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshputmoney(data,sender)
end

function CreateRoomPJController:clickwanfa(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshwanfa_now(data,sender)
end

function CreateRoomPJController:clickxuanzhuang(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshxuanzhuang(data,sender)
end

function CreateRoomPJController:clickWinner(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshWinner(data,sender)
end
-------------------------------------------------------------------------------------

return CreateRoomPJController
