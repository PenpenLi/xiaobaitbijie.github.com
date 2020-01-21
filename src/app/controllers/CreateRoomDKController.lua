local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local cjson = require('cjson')
local SoundMng = require('app.helpers.SoundMng')
local CreateRoomDKController = class("CreateRoomDKController", Controller):include(HasSignals)
local tools = require('app.helpers.tools')

function CreateRoomDKController:initialize(groupInfo, createmode,paymode)
    Controller.initialize(self)
    HasSignals.initialize(self)
    self.groupInfo = groupInfo
    self.createmode = createmode
    self.paymode = 1
    if paymode then 
        self.paymode = paymode.payMode 
    end
end

function CreateRoomDKController:viewDidLoad()
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

        app.session.room:on('closeDK', function(msg)
            self.emitter:emit('back')
        end),  
        
        app.session.room:on('showOther', function(msg)
            if msg == 'dk' then
                self.view:setVisible(true)
                self.view:freshTab('dk')
            else
                self.view:setVisible(false)
            end
        end),
    }

    if self.groupInfo then
        app.session.room:roomConfigFlag(self.groupInfo)
    end
end

function CreateRoomDKController:finalize()-- luacheck: ignore
    for i = 1, #self.listener do
        self.listener[i]:dispose()
    end
end

function CreateRoomDKController:clickCreate()
    local app = require("app.App"):instance()
    local options = self.view:getOptions()

    if options.scoreOption.choushui_dk < 0 or options.scoreOption.choushui_dk >= 100 then
        tools.showRemind("请调整抽水比例")
        return
    end
    if not options.scoreOption.join or not options.scoreOption.tui or not options.scoreOption.qiang then
        tools.showRemind("抽水设置不能为空")
        return
    end

    local gameIdx = app.session.depu.gameIdx

    self.view:showWaiting()

    app.session.room:createRoom(gameIdx, options, self.groupInfo)
end

function CreateRoomDKController:clickQuickStart()
    local app = require("app.App"):instance()
    local options = self.view:getOptions()

    if options.scoreOption.choushui_dk < 0 or options.scoreOption.choushui_dk >= 100 then
        tools.showRemind("请调整抽水比例")
        return
    end
    if not options.scoreOption.join or not options.scoreOption.tui or not options.scoreOption.qiang then
        tools.showRemind("抽水设置不能为空")
        return
    end

    local gameIdx = app.session.depu.gameIdx
    local gameplay = options.gameplay

    self.view:showWaiting()

    app.session.room:quickStart(self.groupInfo, gameplay, gameIdx)
end

function CreateRoomDKController:clickSureBtn()
    local app = require("app.App"):instance()
    local options = self.view:getOptions()

    if options.scoreOption.choushui_dk < 0 or options.scoreOption.choushui_dk >= 100 then
        tools.showRemind("请调整抽水比例")
        return
    end
    if not options.scoreOption.join or not options.scoreOption.tui or not options.scoreOption.qiang then
        tools.showRemind("抽水设置不能为空")
        return
    end

    local gameIdx = app.session.depu.gameIdx
    local gameplay = options.gameplay
    app.session.room:roomConfig(gameplay, options, self.groupInfo)
end

function CreateRoomDKController:clickBack()
    local app = require("app.App"):instance()
    app.session.room:closeAll()
    self.emitter:emit('back')
end

------------------------------------------------------------------------------------------
--三个问号提示的点击事件
function CreateRoomDKController:clickRoomPriceLayer()
    self.view:freshPriceLayer(false) 
end
function CreateRoomDKController:clickPriceWhy()
    self.view:freshPriceLayer(true) 
end

function CreateRoomDKController:clickquickLayer()
    self.view:freshquickLayer(false) 
end
function CreateRoomDKController:clickquickWhy()
    self.view:freshquickLayer(true) 
end

function CreateRoomDKController:clickChoushuiLayer(sender)
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    local body = cjson.decode(data)
    self.view:freshChoushuiLayer(false,body)
end
function CreateRoomDKController:clickChoushuiSelect(sender)
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    local body = cjson.decode(data)
    self.view:freshChoushuiLayer(true,body)
end
--------------------------------------------------------------------------------------------

function CreateRoomDKController:clickNotOpen()
    local tools = require('app.helpers.tools')
    tools.showRemind('暂未开放，敬请期待')
end

--------------------------------------------------------------------------------------------
--左边选择模式点击事件
function CreateRoomDKController:clickChangeGameType(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    local app = require("app.App"):instance()
    if data == 'dk' then
        app.session.room:setCurrentType('dk')
        self.view:freshTab('dk')
    else
        self.view:setVisible(false)
        app.session.room:showOther(data)
    end
end

function CreateRoomDKController:clickchangetype(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = 'dk'
    local app = require("app.App"):instance()
    self.view:freshTab(data)
end

--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
--各模式的刷新事件
function CreateRoomDKController:clickBase(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshbase(data,sender)
end

function CreateRoomDKController:clickPeopleSelect(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshpeopleSelect(data,sender)
end

function CreateRoomDKController:clickroomPrice(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshroomPrice(data,sender)
end

function CreateRoomDKController:clickputMoney(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshputmoney(data,sender)
end

function CreateRoomDKController:clickLimit(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshlimit(data,sender)
end

function CreateRoomDKController:clickStartMode(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshstartMode(data,sender)
end

function CreateRoomDKController:clickWanfa(sender)
    SoundMng.playEft('btn_click.mp3')
    self.view:freshwanfa()
end

function CreateRoomDKController:clickWinner(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshWinner(data,sender)
end
-------------------------------------------------------------------------------------

return CreateRoomDKController
