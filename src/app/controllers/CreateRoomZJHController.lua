local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local cjson = require('cjson')
local SoundMng = require('app.helpers.SoundMng')
local CreateRoomZJHController = class("CreateRoomZJHController", Controller):include(HasSignals)
local tools = require('app.helpers.tools')

function CreateRoomZJHController:initialize(groupInfo, createmode, paymode)
    Controller.initialize(self)
    HasSignals.initialize(self)
    self.groupInfo = groupInfo
    self.createmode = createmode
    self.paymode = 1
    if paymode then
        self.paymode = paymode.payMode
    end
end

function CreateRoomZJHController:viewDidLoad()
    local app = require("app.App"):instance()
    self.view:layout(self.groupInfo, self.createmode, self.paymode)
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
            if msg == 'zjh' then
                self.view:setVisible(true)
                self.view:freshTab('zjh')
            else
                self.view:setVisible(false)
            end
        end),

        app.session.room:on('closeZJH', function(msg)
            self.emitter:emit('back')
        end),        
    }

    if self.groupInfo then
        app.session.room:roomConfigFlag(self.groupInfo)
    end
end

function CreateRoomZJHController:finalize()-- luacheck: ignore
    for i = 1, #self.listener do
        self.listener[i]:dispose()
    end
end

function CreateRoomZJHController:clickCreate()
    local app = require("app.App"):instance()
    local options = self.view:getOptions()

    if options.scoreOption.choushui_zjh < 0 or options.scoreOption.choushui_zjh >= 100 then
        tools.showRemind("请调整抽水比例")
        return
    end
    if not options.scoreOption.join or not options.scoreOption.tui or not options.scoreOption.qiang then
        tools.showRemind("抽水设置不能为空")
        return
    end

    local gameIdx
    local gameplay = options.gameplay
    gameIdx = app.session.zhajinhua.gameIdx

    self.view:showWaiting()

    app.session.room:createRoom(gameIdx, options, self.groupInfo)
end

function CreateRoomZJHController:clickQuickStart()
    local app = require("app.App"):instance()
    local options = self.view:getOptions()

    if options.scoreOption.choushui_zjh < 0 or options.scoreOption.choushui_zjh >= 100 then
        tools.showRemind("请调整抽水比例")
        return
    end
    if not options.scoreOption.join or not options.scoreOption.tui or not options.scoreOption.qiang then
        tools.showRemind("抽水设置不能为空")
        return
    end

    local gameIdx
    local gameplay = options.gameplay
    gameIdx = app.session.zhajinhua.gameIdx

    self.view:showWaiting()

    app.session.room:quickStart(self.groupInfo, gameplay, gameIdx)
end

function CreateRoomZJHController:clickSureBtn()
    local app = require("app.App"):instance()
    local options = self.view:getOptions()

    if options.scoreOption.choushui_zjh < 0 or options.scoreOption.choushui_zjh >= 100 then
        tools.showRemind("请调整抽水比例")
        return
    end
    if not options.scoreOption.join or not options.scoreOption.tui or not options.scoreOption.qiang then
        tools.showRemind("抽水设置不能为空")
        return
    end

    local gameIdx
    local gameplay = options.gameplay
    gameIdx = app.session.zhajinhua.gameIdx

    app.session.room:roomConfig(gameplay, options, self.groupInfo)
end

function CreateRoomZJHController:clickBack()
    local app = require("app.App"):instance()
    app.session.room:closeAll()
    self.emitter:emit('back')
end

------------------------------------------------------------------------------------------
--三个问号提示的点击事件
function CreateRoomZJHController:clickRoomPriceLayer()
    self.view:freshPriceLayer(false)
end
function CreateRoomZJHController:clickPriceWhy()
    self.view:freshPriceLayer(true)
end

function CreateRoomZJHController:clickquickLayer()
    self.view:freshquickLayer(false)
end
function CreateRoomZJHController:clickquickWhy()
    self.view:freshquickLayer(true)
end

--两个模式的点击事件
function CreateRoomZJHController:clickAdvancedLayer(sender)
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    local body = cjson.decode(data)
    self.view:freshAdvancedLayer(false, body)
end
function CreateRoomZJHController:clickAdvancedSelect(sender)
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    local body = cjson.decode(data)
    self.view:freshAdvancedLayer(true, body)
end

function CreateRoomZJHController:clickChoushuiLayer(sender)
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    local body = cjson.decode(data)
    self.view:freshChoushuiLayer(false,body)
end
function CreateRoomZJHController:clickChoushuiSelect(sender)
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    local body = cjson.decode(data)
    self.view:freshChoushuiLayer(true,body)
end
--------------------------------------------------------------------------------------------
function CreateRoomZJHController:clickNotOpen()
    local tools = require('app.helpers.tools')
    tools.showRemind('暂未开放，敬请期待')
end

--------------------------------------------------------------------------------------------
--左边选择模式点击事件
function CreateRoomZJHController:clickChangeGameType(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    local app = require("app.App"):instance()
    if data == 'zjh' then
        app.session.room:setCurrentType('zjh')
        self.view:freshTab('zjh')
    else
        self.view:setVisible(false)
        app.session.room:showOther(data)
    end
end

function CreateRoomZJHController:clickchangetype(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getName()
    local app = require("app.App"):instance()
    self.view:freshTab(data)
end

--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
--各模式的刷新事件
function CreateRoomZJHController:clickBase(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshbase(data, sender)
end

function CreateRoomZJHController:clickRound(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshround(data, sender)
end

function CreateRoomZJHController:clickroomPrice(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshroomPrice(data, sender)
end

function CreateRoomZJHController:clickstartMode(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshstartMode(data, sender)
end

function CreateRoomZJHController:clickPeopleSelect(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshpeopleSelect(data, sender)
end

function CreateRoomZJHController:clickCompareRound(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshcompareRound(data, sender)
end

function CreateRoomZJHController:clickPutScoreRound(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshputScoreRound(data, sender)
end

function CreateRoomZJHController:clickBlindRound(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshblindRound(data, sender)
end

function CreateRoomZJHController:clickPutScoreLimit(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshputScoreLimit(data, sender)
end

function CreateRoomZJHController:clickAbandonTime(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshabandonTime(data, sender)
end

function CreateRoomZJHController:clickSameCard(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshsameCard(data, sender)
end

function CreateRoomZJHController:clickTonghua(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshtonghua(data, sender)
end

function CreateRoomZJHController:clickBaozi(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshbaozi(data, sender)
end

function CreateRoomZJHController:clickAdvanced(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshadvancednow(data, sender)
end

function CreateRoomZJHController:clickWinner(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshWinner(data,sender)
end

-------------------------------------------------------------------------------------
return CreateRoomZJHController