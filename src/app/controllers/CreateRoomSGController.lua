local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local cjson = require('cjson')
local SoundMng = require('app.helpers.SoundMng')
local CreateRoomSGController = class("CreateRoomSGController", Controller):include(HasSignals)
local tools = require('app.helpers.tools')

function CreateRoomSGController:initialize(groupInfo, createmode,paymode)
    Controller.initialize(self)
    HasSignals.initialize(self)
    self.groupInfo = groupInfo
    self.createmode = createmode
    self.paymode = 1
    if paymode then 
        self.paymode = paymode.payMode 
    end
end

function CreateRoomSGController:viewDidLoad()
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

        app.session.room:on('showOther', function(msg)
            if msg == 'sg' then
                self.view:setVisible(true)
                self.view:freshTab(app.session.room:getCurrentSGType() or 'zs')
            else
                self.view:setVisible(false)
            end
        end),    

        app.session.room:on('closeSG', function(msg)
            self.emitter:emit('back')
        end),              
    }

    if self.groupInfo then
        app.session.room:roomConfigFlag(self.groupInfo)
    end
end

function CreateRoomSGController:finalize()-- luacheck: ignore
    for i = 1, #self.listener do
        self.listener[i]:dispose()
    end
end

function CreateRoomSGController:clickCreate()
    local app = require("app.App"):instance()
    local options = self.view:getOptions()

    if options.scoreOption.choushui_sg < 0 or options.scoreOption.choushui_sg >= 100 then
        tools.showRemind("请调整抽水比例")
        return
    end
    if not options.scoreOption.join or not options.scoreOption.tui or not options.scoreOption.qiang then
        tools.showRemind("抽水设置不能为空")
        return
    end

    local gameIdx
    local gameplay = options.gameplay
    gameIdx = app.session.sangong.gameIdx

    self.view:showWaiting()

    app.session.room:createRoom(gameIdx, options, self.groupInfo)
end

function CreateRoomSGController:clickQuickStart()
    local app = require("app.App"):instance()
    local options = self.view:getOptions()

    if options.scoreOption.choushui_sg < 0 or options.scoreOption.choushui_sg >= 100 then
        tools.showRemind("请调整抽水比例")
        return
    end
    if not options.scoreOption.join or not options.scoreOption.tui or not options.scoreOption.qiang then
        tools.showRemind("抽水设置不能为空")
        return
    end

    local gameIdx
    local gameplay = options.gameplay
    gameIdx = app.session.sangong.gameIdx

    self.view:showWaiting()

    app.session.room:quickStart(self.groupInfo, gameplay, gameIdx)
end

function CreateRoomSGController:clickSureBtn()
    local app = require("app.App"):instance()
    local options = self.view:getOptions()

    if options.scoreOption.choushui_sg < 0 or options.scoreOption.choushui_sg >= 100 then
        tools.showRemind("请调整抽水比例")
        return
    end
    if not options.scoreOption.join or not options.scoreOption.tui or not options.scoreOption.qiang then
        tools.showRemind("抽水设置不能为空")
        return
    end

    local gameIdx
    local gameplay = options.gameplay
    gameIdx = app.session.sangong.gameIdx

    app.session.room:roomConfig(gameplay, options, self.groupInfo)
end

function CreateRoomSGController:clickBack()
    local app = require("app.App"):instance()
    app.session.room:closeAll()
    self.emitter:emit('back')
end

------------------------------------------------------------------------------------------
--三个问号提示的点击事件
function CreateRoomSGController:clickRoomPriceLayer()
    self.view:freshPriceLayer(false) 
end
function CreateRoomSGController:clickPriceWhy()
    self.view:freshPriceLayer(true) 
end

function CreateRoomSGController:clickTuiZhuLayer()
    self.view:freshTuiZhuLayer(false) 
end
function CreateRoomSGController:clickTuiZhuWhy()
    self.view:freshTuiZhuLayer(true) 
end

function CreateRoomSGController:clickXiaZhuLayer()
    self.view:freshXiaZhuLayer(false) 
end
function CreateRoomSGController:clickXiaZhuWhy()
    self.view:freshXiaZhuLayer(true) 
end

function CreateRoomSGController:clickquickLayer()
    self.view:freshquickLayer(false) 
end
function CreateRoomSGController:clickquickWhy()
    self.view:freshquickLayer(true) 
end

function CreateRoomSGController:clickWangLaiLayer()
    self.view:freshWangLaiLayer(false) 
end
function CreateRoomSGController:clickWangLaiWhy(sender)
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshWangLaiLayer(true, data) 
end

--两个模式的点击事件
function CreateRoomSGController:clickSpecialLayer(sender)
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    local body = cjson.decode(data)
    self.view:freshSpecialLayer(false,body) 
end
function CreateRoomSGController:clickSpecialSelect(sender)
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    local body = cjson.decode(data)
    self.view:freshSpecialLayer(true,body) 
end

function CreateRoomSGController:clickMultiplyLayer(sender)
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    local body = cjson.decode(data)
    self.view:freshMultiplyLayer(false,body) 
end
function CreateRoomSGController:clickMultiplySelect(sender)
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    local body = cjson.decode(data)
    self.view:freshMultiplyLayer(true,body) 
end

function CreateRoomSGController:clickChoushuiLayer(sender)
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    local body = cjson.decode(data)
    self.view:freshChoushuiLayer(false,body)
end
function CreateRoomSGController:clickChoushuiSelect(sender)
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    local body = cjson.decode(data)
    self.view:freshChoushuiLayer(true,body)
end
--------------------------------------------------------------------------------------------

function CreateRoomSGController:clickNotOpen()
    local tools = require('app.helpers.tools')
    tools.showRemind('暂未开放，敬请期待')
end

--------------------------------------------------------------------------------------------
--左边选择模式点击事件
function CreateRoomSGController:clickChangeGameType(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    local app = require("app.App"):instance()
    if data == 'sg' then
        self.view:setShowList()
        app.session.room:setCurrentType('sg')
        self.view:freshTab(app.session.room:getCurrentSGType() or 'zs')
    else
        self.view:setVisible(false)
        app.session.room:showOther(data)
    end
end

function CreateRoomSGController:clickchangetype(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getName()
    local app = require("app.App"):instance()
    self.view:freshTab(data)
end

--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
--各模式的刷新事件
function CreateRoomSGController:clickBase(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshbase(data,sender)
end

function CreateRoomSGController:clickRound(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshround(data,sender)
end

function CreateRoomSGController:clickroomPrice(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshroomPrice(data,sender)
end

function CreateRoomSGController:clickMultiply(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshmultiply(data,sender)
end

function CreateRoomSGController:clickSpecial(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshspecialnow(data,sender)
end

function CreateRoomSGController:clickqzMax(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshqzMax(data,sender)
end

function CreateRoomSGController:clickszSelect(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshszSelect(data,sender)
end

function CreateRoomSGController:clickstartMode(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshstartMode(data,sender)
end

function CreateRoomSGController:clickputMoney(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshputmoney(data,sender)
end

function CreateRoomSGController:clickAdvanced(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshadvancednow(data,sender)
end

function CreateRoomSGController:clickWanglai(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshwanglai(data,sender)
end

function CreateRoomSGController:clickPeopleSelect(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshpeopleSelect(data,sender)
end

function CreateRoomSGController:clickPutLimit(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshputLimit(data,sender)
end

function CreateRoomSGController:clickWinner(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshWinner(data,sender)
end

-------------------------------------------------------------------------------------

return CreateRoomSGController
