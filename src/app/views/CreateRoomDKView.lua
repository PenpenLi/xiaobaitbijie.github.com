local SoundMng = require('app.helpers.SoundMng')
local ShowWaiting = require('app.helpers.ShowWaiting')
local tools = require('app.helpers.tools')

local CreateRoomDKView = {}
local LocalSettings = require('app.models.LocalSettings')
local roomType = {
    ['dkOption'] = 1, 
}
local typeOptions = {
    ['base'] = 1,
    ['peopleSelect'] = 2,
    ['roomPrice'] = 3,
    ['putmoney'] = 4,
    ['limit'] = 5,
    ['startMode'] = 6,
    ['wanfa'] = 7,
}
local tabs = {
    ['dk'] = 1, -- 德扑
}

local BASE = {
    [1] = '100',
    [2] = '500',
    [3] = '1000',
    [4] = '2000',
    [5] = '3000',
}

local PUTMONEY = {
    [1] = '5/10',
    [2] = '10/20',
    [3] = '20/40',
    [4] = '50/100',
    [5] = '100/200',
}

local ROUND = {
    [1] = 10,
    [2] = 15,
    [3] = 20,
}

local scoreOption = {
    choushui = 10,
    join = 400,
    qiang = 400,
    tui = 400,
}

local setVersion = 7

function CreateRoomDKView:initialize()
    self:enableNodeEvents()
    self.options = {}
    self.paymode = 1
    local setPath = cc.FileUtils:getInstance():getWritablePath() .. '.CreateRoomDKConfig'

    if io.exists(setPath) then
        local ver = LocalSettings:getRoomDKConfig('setVersion')
        if (not ver) or ver < setVersion then
            cc.FileUtils:getInstance():removeFile(setPath)
        end
    end

    print("getincreateroom")

    self.options['dkOption'] = { msg = {
        ['gameplay'] = 11,  ['base'] = 1,   ['round'] = 1,
        ['roomPrice'] = 1, ['multiply'] = 1, ['special'] = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10},
        ['advanced'] = { 1, 0, 0, 0, 0},
        ['qzMax'] = 1,
        ['putmoney'] = 1,
        ['startMode'] = 1,
        ['peopleSelect'] = 1,
        ['limit'] = 1,
        ['wanfa'] = 0,
    } }

    local MainPanel = self.ui:getChildByName('MainPanel')
    local bg = MainPanel:getChildByName('bg')
    self.bg = bg

    if not io.exists(cc.FileUtils:getInstance():getWritablePath() .. '.CreateRoomDKConfig') then

        print(LocalSettings:getRoomDKConfig('dkOptionbase'))

        for i,v in pairs(roomType) do
            for j,n in pairs(typeOptions) do
                LocalSettings:setRoomDKConfig(i..j, self.options[i]['msg'][j])
            end
        end

        LocalSettings:setRoomDKConfig('setVersion', setVersion)

    else
        print(" LocalSettings:getRoomDKConfig(v..n) is not == nil")
        for i,v in pairs(roomType) do 
            for j,n in pairs(typeOptions) do 
                local data =  LocalSettings:getRoomDKConfig(i..j)
                if data then 
                    self.options[i]['msg'][j] = data
                end
            end
        end
    end
end

function CreateRoomDKView:freshAllItem() 
    local bg = self.bg
    local option_type = self.focus .. 'Option'
    for j,n in pairs(typeOptions) do 
        local data =  LocalSettings:getRoomDKConfig(option_type..j)
        if data then 
            self.options[option_type]['msg'][j] = data
            local fun = 'fresh'..j
            if self[fun] then 
                local sender = bg:getChildByName(option_type):getChildByName(j):getChildByName(tostring(data))
                self[fun](self,data,sender)
            end
        end
    end
end

--------------------------------------------------------------------------------------------
-- 左边选择模式点击事件
function CreateRoomDKView:freshTab(data)
    for i, v in pairs(tabs) do 
        local currentItem = self.bg:getChildByName('tab'):getChildByName(i)
        local currentOpt = self.bg:getChildByName(i .. 'Option')
        if data then 
            self.focus = data
        end
        if self.focus == i then
            currentItem:getChildByName('active'):setVisible(true)
            currentOpt:setVisible(true)
        else
            currentItem:getChildByName('active'):setVisible(false)
            currentOpt:setVisible(false)
        end
    end
    LocalSettings:setRoomDKConfig("gameplay", self.focus)
    self:freshAllItem()

    local app = require("app.App"):instance()
    app.session.room:setCurrentType(self.focus)
end

-- --------------------------------------------------------------------------------------------

-- --------------------------------------------------------------------------------------------
--刷新左边模式是否已配
function CreateRoomDKView:freshHasSave(data)
    for i, v in pairs(tabs) do 
        local currentItem = self.bg:getChildByName('tab'):getChildByName(i)
        local hassaveImage = currentItem:getChildByName('Image')
        if data[v] == 1 then
            hassaveImage:setVisible(true)
        else
            hassaveImage:setVisible(false)
        end
    end
end

-- --------------------------------------------------------------------------------------------

-- --------------------------------------------------------------------------------------
--各个模式的刷新界面逻辑
function CreateRoomDKView:freshbase(data,sender)
    local option = self.bg:getChildByName(self.focus .. 'Option')
    local item = option:getChildByName('base')

    for i = 1, 5 do
        item:getChildByName(tostring(i)):getChildByName('select'):setVisible(false)
    end
    sender:getChildByName('select'):setVisible(true)

    self.options[self.focus .. 'Option']['msg']['base'] = tonumber(data)
    LocalSettings:setRoomDKConfig(self.focus.. 'Option' .. item:getName(), tonumber(data))

    local info = {
        option =  self.focus .. 'Option' ,
        item = 'base' ,
        num = 5 ,
    }

    self:freshTextColor(info)
end

function CreateRoomDKView:freshputmoney(data,sender)
    local option = self.bg:getChildByName(self.focus .. 'Option')
    local item = option:getChildByName('putmoney')

    for i = 1, 5 do
        item:getChildByName(tostring(i)):getChildByName('select'):setVisible(false)
    end
    sender:getChildByName('select'):setVisible(true)

    self.options[self.focus .. 'Option']['msg']['putmoney'] = tonumber(data)
    LocalSettings:setRoomDKConfig(self.focus.. 'Option' .. item:getName(), tonumber(data))

    local info = {
        option =  self.focus .. 'Option' ,
        item = 'putmoney' ,
        num = 5 ,
    }

    self:freshTextColor(info)
end

function CreateRoomDKView:freshpeopleSelect(data,sender)
    local option = self.bg:getChildByName(self.focus .. 'Option')
    local item = option:getChildByName('peopleSelect')

    for i = 1, 2 do
        item:getChildByName(tostring(i)):getChildByName('select'):setVisible(false)
    end
    sender:getChildByName('select'):setVisible(true)

    self.options[self.focus .. 'Option']['msg']['peopleSelect'] = tonumber(data)
    LocalSettings:setRoomDKConfig(self.focus.. 'Option' .. item:getName(), tonumber(data))

    self:freshStartModeIdx()

    local info = {
        option =  self.focus .. 'Option' ,
        item = 'peopleSelect' ,
        num = 2 ,
    }

    self:freshTextColor(info)
end

function CreateRoomDKView:freshroomPrice(data,sender)
    local option = self.bg:getChildByName(self.focus .. 'Option')
    local item = option:getChildByName('roomPrice')

    item:getChildByName('1'):getChildByName('select'):setVisible(false)
    item:getChildByName('2'):getChildByName('select'):setVisible(false)
    item:getChildByName('paymode'):setVisible(false)
    sender:getChildByName('select'):setVisible(true)

    self.options[self.focus .. 'Option']['msg']['roomPrice'] = tonumber(data)
    LocalSettings:setRoomDKConfig(self.focus .. 'Option'..item:getName(), tonumber(data))

    local info = {
        option =  self.focus .. 'Option' ,
        item = 'roomPrice' ,
        num = 2 ,
    }

    self:freshTextColor(info)
end

function CreateRoomDKView:freshlimit(data,sender)
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName(option_type)
    local item = option:getChildByName('limit')

    item:getChildByName('1'):getChildByName('select'):setVisible(false)
    item:getChildByName('2'):getChildByName('select'):setVisible(false)
    item:getChildByName('3'):getChildByName('select'):setVisible(false)
    sender:getChildByName('select'):setVisible(true)

    self.options[option_type]['msg']['limit'] = tonumber(data)
    LocalSettings:setRoomDKConfig(option_type..item:getName(), tonumber(data))

    local info = {
        option =  self.focus .. 'Option' ,
        item = 'limit' ,
        num = 3 ,
    }

    self:freshTextColor(info)
end

function CreateRoomDKView:freshstartMode(data,sender)
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName(option_type)
    local item = option:getChildByName('startMode')

    for i = 1, 9 do
        item:getChildByName('' .. i):getChildByName('select'):setVisible(false)
    end
    sender:getChildByName('select'):setVisible(true)

    self.options[option_type]['msg']['startMode'] = tonumber(data)
    LocalSettings:setRoomDKConfig(option_type..item:getName(), tonumber(data))

    local info = {
        option =  self.focus .. 'Option' ,
        item = 'startMode' ,
        num = 9 ,
    }

    self:freshTextColor(info)
end

function CreateRoomDKView:freshwanfa(data)
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName(option_type)
    local item = option:getChildByName('wanfa')
    local flag

    if data then
        flag = data == 1
        item:getChildByName('1'):getChildByName('select'):setVisible(flag)
        self.options[option_type]['msg']['wanfa'] = data
    else
        local bool = item:getChildByName('1'):getChildByName('select'):isVisible()
        item:getChildByName('1'):getChildByName('select'):setVisible(not bool)
        self.options[option_type]['msg']['wanfa'] = bool and 0 or 1
        flag = not bool
    end
    LocalSettings:setRoomDKConfig(option_type..item:getName(), self.options[option_type]['msg']['wanfa'])

    if flag then
        item:getChildByName('1'):getChildByName('Text'):setColor(cc.c3b(255,255,255))
        item:getChildByName('1'):getChildByName('Text'):setColor(cc.c3b(246,185,254))
    else
        item:getChildByName('1'):getChildByName('Text'):setColor(cc.c3b(255,255,255))
        item:getChildByName('1'):getChildByName('Text'):setColor(cc.c3b(184,199,254))
    end
end

function CreateRoomDKView:freshStartModeIdx()
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName(option_type)
    local item = option:getChildByName('startMode')

    local startMode = self.options[option_type]['msg']['startMode']
    local peopleSelect = self.options[option_type]['msg']['peopleSelect']

    if peopleSelect == 1 then
        item:getChildByName('8'):setVisible(false)
        item:getChildByName('9'):setVisible(false)
        if startMode > 7 then
            self:freshstartMode(7, item:getChildByName('7'))
        end
    else
        item:getChildByName('8'):setVisible(true)
        item:getChildByName('9'):setVisible(true)
    end
end

function CreateRoomDKView:freshchoushui()
    self.joinEditBox:setText(scoreOption.join)
    -- self.qiangEditBox:setText(scoreOption.qiang)
    -- self.tuiEditBox:setText(scoreOption.tui)
    self.choushuiEditBox:setText(scoreOption.choushui)
    self.choushuiLayer:getChildByName('sel'):getChildByName('Text'):setString('进场:' .. scoreOption.join .. ' 抽水比例:' .. scoreOption.choushui .. '%')

    self.joinEditBox:registerScriptEditBoxHandler(function(eventname,sender) self:editboxHandle(eventname,sender) end)
    -- self.qiangEditBox:registerScriptEditBoxHandler(function(eventname,sender) self:editboxHandle(eventname,sender) end)
    -- self.tuiEditBox:registerScriptEditBoxHandler(function(eventname,sender) self:editboxHandle(eventname,sender) end)
    self.choushuiEditBox:registerScriptEditBoxHandler(function(eventname,sender) self:editboxHandle(eventname,sender) end)
end

function CreateRoomDKView:editboxHandle(eventname, sender)
    if eventname == "began" then
        --光标进入，选中全部内容
    elseif eventname == "ended" then
        -- 当编辑框失去焦点并且键盘消失的时候被调用
    elseif eventname == "return" then
        -- 当用户点击编辑框的键盘以外的区域，或者键盘的Return按钮被点击时所调用
    elseif eventname == "changed" then
        -- 输入内容改变时调用
        self.choushuiLayer:getChildByName('sel'):getChildByName('Text'):setString('进场:' .. self.joinEditBox:getText() ..
        ' 抽水比例:' .. self.choushuiEditBox:getText() .. '%')
    end
end

function CreateRoomDKView:freshWinner(data,sender)
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName(option_type)
    local item = option:getChildByName('choushui')

    item:getChildByName('opt'):getChildByName('1'):getChildByName('select'):setVisible(false)
    item:getChildByName('opt'):getChildByName('2'):getChildByName('select'):setVisible(false)
    sender:getChildByName('select'):setVisible(true)
    self.winner = tonumber(data)

end
-- ---------------------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------------
-- --刷新字体颜色
function CreateRoomDKView:freshmulTextColor(data) 
    local option = self.bg:getChildByName(data.option)
    local item = option:getChildByName(data.item)
    local selectdata = self.options[data.option]['msg'][data.item]

    for i = 1, #selectdata do
        if selectdata[i] ~= 0 then
            item:getChildByName(tostring(i)):getChildByName('Text'):setColor(cc.c3b(255,255,255))
            item:getChildByName(tostring(i)):getChildByName('Text'):setColor(cc.c3b(246,185,254))
        else
            item:getChildByName(tostring(i)):getChildByName('Text'):setColor(cc.c3b(255,255,255))
            item:getChildByName(tostring(i)):getChildByName('Text'):setColor(cc.c3b(184,199,254))
        end
    end
end

function CreateRoomDKView:freshTextColor(data) 
    local option = self.bg:getChildByName(data.option)
    local item = option:getChildByName(data.item)
    if data.item == 'multiply' or data.item == 'special' then 
        item = item:getChildByName('opt')
    end
    local selectdata = self.options[data.option]['msg'][data.item]
    
    for i = 1, data.num do
        if i == selectdata then
            item:getChildByName(tostring(i)):getChildByName('Text'):setColor(cc.c3b(255,255,255))
            item:getChildByName(tostring(i)):getChildByName('Text'):setColor(cc.c3b(246,185,254))
        else
            item:getChildByName(tostring(i)):getChildByName('Text'):setColor(cc.c3b(255,255,255))
            item:getChildByName(tostring(i)):getChildByName('Text'):setColor(cc.c3b(184,199,254))
        end
    end
end
-- ------------------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------------
-- --三个问号提示的点击事件
function CreateRoomDKView:freshPriceLayer(bShow) 
    self.bg:getChildByName('priceLayer'):setVisible(bShow)
end

function CreateRoomDKView:freshquickLayer(bShow) 
    self.bg:getChildByName('quickLayer'):setVisible(bShow)
end

function CreateRoomDKView:freshChoushuiLayer(bShow,data) 
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName(option_type) 
    option:getChildByName('choushui'):getChildByName('opt'):setVisible(bShow)
    local path = 'res/views/createroom/' .. data.direction ..'.png'
    local bg = option:getChildByName('choushui'):getChildByName('sel'):getChildByName('bg')
    bg:getChildByName('down'):loadTexture(path)
end
-- ------------------------------------------------------------------------------------------

function CreateRoomDKView:freshgroupCreateRoomDKView()
    -- local MainPanel = self.ui:getChildByName('MainPanel')
    -- local bg = MainPanel:getChildByName('bg')
    -- for i,v in pairs(roomType) do
    --     for j,n in pairs(typeOptions) do
    --         local view = bg:getChildByName(i)
    --         local opView = view:getChildByName(j)
    --         if(j == 'roomPrice') then
    --             opView:getChildByName('1'):getChildByName('select'):setVisible(false)
    --             opView:getChildByName('2'):getChildByName('select'):setVisible(false)
    --             opView:getChildByName('paymode'):setVisible(true)
    --             opView:getChildByName('1'):setVisible(false)
    --             opView:getChildByName('2'):setVisible(false)
    --             opView:getChildByName('dm1'):setVisible(false)
    --             opView:getChildByName('dm2'):setVisible(false)
    --             opView:getChildByName('why'):setVisible(false)
    --             local round = LocalSettings:getRoomDKConfig(i ..'round')
    --             self:freshround({['type'] = i, ['round'] = round},view:getChildByName('round'):getChildByName(tostring(round)))
    --         end
    --     end
    -- end
    -- self.isgroup = true
end

function CreateRoomDKView:layout(isGroup, createmode, paymode)
    local MainPanel = self.ui:getChildByName('MainPanel')
    MainPanel:setContentSize(cc.size(display.width, display.height))
    MainPanel:setPosition(display.cx, display.cy)
    self.MainPanel = MainPanel

    local bg = MainPanel:getChildByName('bg')
    bg:setPosition(display.cx, display.cy)
    self.bg = bg
    self.isgroup = isGroup
    self.paymode = paymode
    self.choushuiLayer = bg:getChildByName('dkOption'):getChildByName('choushui')
    self.choushuiLayer:setVisible(false)
    if self.isgroup then --group
        self.choushuiLayer:setVisible(true)
        if createmode == 1 then
            self.bg:getChildByName('confirm'):setVisible(false)
            self.bg:getChildByName('tips'):setVisible(false)
            self.bg:getChildByName('sureBtn'):setVisible(true)
        elseif createmode == 2 then
            self.bg:getChildByName('confirm'):setVisible(true)
            self.bg:getChildByName('tips'):setVisible(false)
            self.bg:getChildByName('sureBtn'):setVisible(false)
            -- self.bg:getChildByName('quickstart'):setVisible(true)
        end
        if paymode == 2 then 
            -- self:freshgroupCreateRoomDKView()
        end
    else
        -- 正常创建
        self.bg:getChildByName('confirm'):setVisible(true)
        self.bg:getChildByName('tips'):setVisible(true)
        self.bg:getChildByName('sureBtn'):setVisible(false)    
    end
    
    if LocalSettings:getRoomDKConfig("gameplay") then
        self.focus = LocalSettings:getRoomDKConfig("gameplay")
    else
        self.focus = 'dk'
    end

    --创建editText
    local join = self.choushuiLayer:getChildByName('opt'):getChildByName('joinLayer')
    self.joinEditBox = tools.createEditBox(join, {
        -- holder
        defaultString = 400,
        holderSize = 18,
        holderColor = cc.c3b(185,198,254),

        -- text
        fontColor = cc.c3b(185,198,254),
        size = 18,
        maxCout = 6,
        fontType = 'views/font/Fangzheng.ttf',	
        inputMode = cc.EDITBOX_INPUT_MODE_NUMERIC,
    })

    -- local qiang = self.choushuiLayer:getChildByName('opt'):getChildByName('qiangLayer')
    -- self.qiangEditBox = tools.createEditBox(qiang, {
    --     -- holder
    --     defaultString = 400,
    --     holderSize = 18,
    --     holderColor = cc.c3b(185,198,254),

    --     -- text
    --     fontColor = cc.c3b(185,198,254),
    --     size = 18,
    --     maxCout = 6,
    --     fontType = 'views/font/Fangzheng.ttf',	
    --     inputMode = cc.EDITBOX_INPUT_MODE_NUMERIC,
    -- })

    -- local tui = self.choushuiLayer:getChildByName('opt'):getChildByName('tuiLayer')
    -- self.tuiEditBox = tools.createEditBox(tui, {
    --     -- holder
    --     defaultString = 400,
    --     holderSize = 18,
    --     holderColor = cc.c3b(185,198,254),

    --     -- text
    --     fontColor = cc.c3b(185,198,254),
    --     size = 18,
    --     maxCout = 6,
    --     fontType = 'views/font/Fangzheng.ttf',	
    --     inputMode = cc.EDITBOX_INPUT_MODE_NUMERIC,
    -- })

    local choushui = self.choushuiLayer:getChildByName('opt'):getChildByName('rateLayer')
    self.choushuiEditBox = tools.createEditBox(choushui, {
        -- holder
        defaultString = 10,
        holderSize = 18,
        holderColor = cc.c3b(185,198,254),

        -- text
        fontColor = cc.c3b(185,198,254),
        size = 18,
        maxCout = 3,
        fontType = 'views/font/Fangzheng.ttf',	
        inputMode = cc.EDITBOX_INPUT_MODE_NUMERIC,
    })

    self:freshchoushui()
    
    self:freshTab()

    --启动csd动画
    self:startallAction()
end

function CreateRoomDKView:getOptions()
    SoundMng.playEft('room_dingding.mp3')
    local key = self.focus .. 'Option'
    local savedata = self.options[key].msg
    local msg = clone(savedata)
    msg.base = BASE[msg.base]
    msg.putmoney = PUTMONEY[msg.putmoney]

    -- msg.round = ROUND[msg.round]
    msg.round = 300

    if self.isgroup and self.paymode == 2 then
        msg.roomPrice = 1
    end

    msg.enter = {}
    msg.robot = 1
    msg.enter.buyHorse = 0
    msg.enter.enterOnCreate = 1
    
    msg.maxPeople = 7
    if msg.peopleSelect == 2 then
        msg.maxPeople = 9
    end

    msg.deskMode = 'dk'

    msg.scoreOption = {
        choushui_dk = tonumber(self.choushuiEditBox:getText()),
        join = tonumber(self.joinEditBox:getText()),
        qiang = scoreOption.qiang,
        tui = scoreOption.tui,
        rule = self.winner or 1,
    }

    dump(msg)

    return msg
end

function CreateRoomDKView:showWaiting()
    local scheduler = cc.Director:getInstance():getScheduler()
    if not self.schedulerID then

        ShowWaiting.show()
        self.waitingView = true

        self.schedulerID = scheduler:scheduleScriptFunc(function()
            ShowWaiting.delete()
            self.waitingView = false

            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
            self.schedulerID = nil
        end, 3, false)
    end
end

function CreateRoomDKView:delShowWaiting()
    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
        self.schedulerID = nil
        if self.waitingView then
            ShowWaiting.delete()
            self.waitingView = false
        end
    end
end

function CreateRoomDKView:onExit()
    self:delShowWaiting()
end

function CreateRoomDKView:startCsdAnimation( node, csbName, isRepeat, timeSpeed)
    local action = cc.CSLoader:createTimeline("views/createroom/"..csbName..".csb")
    action:gotoFrameAndPlay(0,isRepeat)
    if timeSpeed then
    action:setTimeSpeed(timeSpeed)
    end
    node:stopAllActions()
    node:runAction(action)
end

function CreateRoomDKView:startallAction()
    for i,v in pairs(tabs) do
        -- self:startCsdAnimation(self.bg:getChildByName(i):getChildByName("active"):getChildByName("blinkingBoxNode"),"blinkingBoxAnimation",true,1.3)
    end

    -- self:startCsdAnimation(self.bg:getChildByName("flashBoxNode"),"flashBoxAnimation",true,0.8)  
end

return CreateRoomDKView