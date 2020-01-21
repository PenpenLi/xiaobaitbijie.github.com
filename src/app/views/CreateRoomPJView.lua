local SoundMng = require('app.helpers.SoundMng')
local ShowWaiting = require('app.helpers.ShowWaiting')
local tools = require('app.helpers.tools')

local CreateRoomPJView = {}
local LocalSettings = require('app.models.LocalSettings')
local roomType = {
    ['pjOption'] = 1, 
    -- ['pj2Option'] = 2, 
}
local typeOptions = {
    ['wanfa'] = 1,
    ['xuanzhuang'] = 2,
    ['special'] = 3, 
    ['base'] = 4,
    ['putmoney'] = 5,
    ['round'] = 6,
}
local tabs = {
    ['pj'] = 1, -- 牌九
    -- ['pj2'] = 2, -- 牌九
}

local BASE = {
    [1] = '50',
    [2] = '80',
    [3] = '100',
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

local setVersion = 3

function CreateRoomPJView:initialize()
    self:enableNodeEvents()
    self.options = {}
    self.paymode = 1
    local setPath = cc.FileUtils:getInstance():getWritablePath() .. '.CreateRoomPJConfig'

    if io.exists(setPath) then
        local ver = LocalSettings:getRoomPJConfig('setVersion')
        if (not ver) or ver < setVersion then
            cc.FileUtils:getInstance():removeFile(setPath)
        end
    end

    print("getincreateroom")

    self.options['pjOption'] = { msg = {
        ['gameplay'] = 1,  ['base'] = 1,   ['round'] = 1,
        ['roomPrice'] = 1, ['multiply'] = 1, ['special'] = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17},
        ['advanced'] = { 1, 0, 0, 0, 0},
        ['qzMax'] = 1,
        ['putmoney'] = 1,
        ['startMode'] = 1,
        ['peopleSelect'] = 1,
        ['wanfa'] = {1, 0, 0},
        ['xuanzhuang'] = 1,
    } }

    -- self.options['pj2Option'] = { msg = {
    --     ['gameplay'] = 2,  ['base'] = 1,   ['round'] = 1,
    --     ['roomPrice'] = 1, ['multiply'] = 1, ['special'] = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17},
    --     ['advanced'] = { 1, 0, 0, 0, 0},
    --     ['qzMax'] = 1,
    --     ['putmoney'] = 1,
    --     ['startMode'] = 1,
    --     ['peopleSelect'] = 1,
    --     ['wanfa'] = {1, 0, 0},
    --     ['xuanzhuang'] = 1,
    -- } }

    local MainPanel = self.ui:getChildByName('MainPanel')
    local bg = MainPanel:getChildByName('bg')
    self.bg = bg

    if not io.exists(cc.FileUtils:getInstance():getWritablePath() .. '.CreateRoomPJConfig') then

        print(LocalSettings:getRoomPJConfig('pjOptionbase'))

        for i,v in pairs(roomType) do
            for j,n in pairs(typeOptions) do
                LocalSettings:setRoomPJConfig(i..j, self.options[i]['msg'][j])
            end
        end

        LocalSettings:setRoomPJConfig('setVersion', setVersion)

    else
        print(" LocalSettings:getRoomPJConfig(v..n) is not == nil")
        for i,v in pairs(roomType) do 
            for j,n in pairs(typeOptions) do 
                local data =  LocalSettings:getRoomPJConfig(i..j)
                if data then 
                    self.options[i]['msg'][j] = data
                end
            end
        end
    end
end

function CreateRoomPJView:freshAllItem() 
    local bg = self.bg
    local option_type = self.focus .. 'Option'
    for j,n in pairs(typeOptions) do 
        local data =  LocalSettings:getRoomPJConfig(option_type..j)
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
function CreateRoomPJView:freshTab(data)
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
    LocalSettings:setRoomPJConfig("gameplay", self.focus)
    self:freshAllItem()

    local app = require("app.App"):instance()
    app.session.room:setCurrentType(self.focus)
end

-- --------------------------------------------------------------------------------------------

-- --------------------------------------------------------------------------------------------
--刷新左边模式是否已配
function CreateRoomPJView:freshHasSave(data)
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
function CreateRoomPJView:freshbase(data,sender)
    local option = self.bg:getChildByName(self.focus .. 'Option')
    local item = option:getChildByName('base')

    for i = 1, 3 do
        item:getChildByName(tostring(i)):getChildByName('select'):setVisible(false)
    end
    sender:getChildByName('select'):setVisible(true)

    self.options[self.focus .. 'Option']['msg']['base'] = tonumber(data)
    LocalSettings:setRoomPJConfig(self.focus.. 'Option' .. item:getName(), tonumber(data))

    local info = {
        option =  self.focus .. 'Option' ,
        item = 'base' ,
        num = 3 ,
    }

    self:freshTextColor(info)
end

function CreateRoomPJView:freshround(data,sender)
    local option = self.bg:getChildByName(self.focus .. 'Option')
    local item = option:getChildByName('round')

    item:getChildByName('1'):getChildByName('select'):setVisible(false)
    item:getChildByName('2'):getChildByName('select'):setVisible(false)
    item:getChildByName('3'):getChildByName('select'):setVisible(false)
    sender:getChildByName('select'):setVisible(true)

    self.options[self.focus .. 'Option']['msg']['round'] = tonumber(data)
    LocalSettings:setRoomPJConfig(self.focus.. 'Option' .. item:getName(), tonumber(data))

    local info = {
        option =  self.focus .. 'Option' ,
        item = 'round' ,
        num = 3 ,
    }

    option:getChildByName('xuanzhuang'):getChildByName('text'):setString('x' .. tonumber(data) * 2)

    self:freshTextColor(info)
end

function CreateRoomPJView:freshspecial(data,sender)
    local option = self.bg:getChildByName(self.focus .. 'Option')
    local item = option:getChildByName('special')

    for i = 1, 9 do
        item:getChildByName('' .. i):getChildByName('select'):setVisible(false)
    end

    for i = 1, #data do
        if data[i] == i then
            item:getChildByName(tostring(i)):getChildByName('select'):setVisible(true)
        end
    end

    self.options[self.focus .. 'Option']['msg']['special'] = data
    LocalSettings:setRoomPJConfig(self.focus.. 'Option' .. item:getName(), data)

    local info = {
        option =  self.focus .. 'Option' ,
        item = 'special' ,
    }

    self:freshmulTextColor(info)
end

function CreateRoomPJView:freshspecial_now(data,sender)
    local option = self.bg:getChildByName(self.focus .. 'Option')
    local item = option:getChildByName('special')
    local flag = sender:getChildByName('select'):isVisible()

    sender:getChildByName('select'):setVisible(not flag)

    self.options[self.focus .. 'Option']['msg']['special'][tonumber(data)] = flag and 0 or tonumber(data)
    LocalSettings:setRoomPJConfig(self.focus.. 'Option' .. item:getName(), self.options[self.focus .. 'Option']['msg']['special'])

    local info = {
        option =  self.focus .. 'Option' ,
        item = 'special' ,
    }

    self:freshmulTextColor(info)
end

function CreateRoomPJView:freshputmoney(data,sender)
    local option = self.bg:getChildByName(self.focus .. 'Option')
    local item = option:getChildByName('putmoney')

    item:getChildByName('1'):getChildByName('select'):setVisible(false)
    item:getChildByName('2'):getChildByName('select'):setVisible(false)
    item:getChildByName('3'):getChildByName('select'):setVisible(false)
    item:getChildByName('4'):getChildByName('select'):setVisible(false)
    sender:getChildByName('select'):setVisible(true)

    self.options[self.focus .. 'Option']['msg']['putmoney'] = tonumber(data)
    LocalSettings:setRoomPJConfig(self.focus.. 'Option' .. item:getName(), tonumber(data))

    local info = {
        option =  self.focus .. 'Option' ,
        item = 'putmoney' ,
        num = 4 ,
    }

    self:freshTextColor(info)
end

function CreateRoomPJView:freshwanfa(data,sender)
    local option = self.bg:getChildByName(self.focus .. 'Option')
    local item = option:getChildByName('wanfa')

    item:getChildByName('1'):getChildByName('select'):setVisible(false)
    item:getChildByName('2'):getChildByName('select'):setVisible(false)
    item:getChildByName('3'):getChildByName('select'):setVisible(false)

    for i = 1, #data do
        if data[i] == i then
            item:getChildByName(tostring(i)):getChildByName('select'):setVisible(true)
        end
    end

    self.options[self.focus .. 'Option']['msg']['wanfa'] = data
    LocalSettings:setRoomPJConfig(self.focus.. 'Option' .. item:getName(), data)

    local info = {
        option =  self.focus .. 'Option' ,
        item = 'wanfa' ,
    }

    self:freshmulTextColor(info)
end

function CreateRoomPJView:freshwanfa_now(data,sender)
    local option = self.bg:getChildByName(self.focus .. 'Option')
    local item = option:getChildByName('wanfa')
    local flag = sender:getChildByName('select'):isVisible()

    if tonumber(data) ~= 3 then
        item:getChildByName('1'):getChildByName('select'):setVisible(false)
        item:getChildByName('2'):getChildByName('select'):setVisible(false)
        sender:getChildByName('select'):setVisible(true)
        self.options[self.focus .. 'Option']['msg']['wanfa'][1] = 0
        self.options[self.focus .. 'Option']['msg']['wanfa'][2] = 0
        self.options[self.focus .. 'Option']['msg']['wanfa'][tonumber(data)] = tonumber(data)
    else
        sender:getChildByName('select'):setVisible(not flag)
        self.options[self.focus .. 'Option']['msg']['wanfa'][tonumber(data)] = flag and 0 or tonumber(data)
    end

    LocalSettings:setRoomPJConfig(self.focus.. 'Option' .. item:getName(), self.options[self.focus .. 'Option']['msg']['wanfa'])

    local info = {
        option =  self.focus .. 'Option' ,
        item = 'wanfa' ,
    }

    self:freshmulTextColor(info)
end

function CreateRoomPJView:freshxuanzhuang(data,sender)
    local option = self.bg:getChildByName(self.focus .. 'Option')
    local item = option:getChildByName('xuanzhuang')

    item:getChildByName('1'):getChildByName('select'):setVisible(false)
    item:getChildByName('2'):getChildByName('select'):setVisible(false)
    sender:getChildByName('select'):setVisible(true)

    self.options[self.focus .. 'Option']['msg']['xuanzhuang'] = tonumber(data)
    LocalSettings:setRoomPJConfig(self.focus.. 'Option' .. item:getName(), tonumber(data))

    local info = {
        option =  self.focus .. 'Option' ,
        item = 'xuanzhuang' ,
        num = 2 ,
    }

    self:freshTextColor(info)
end

function CreateRoomPJView:freshchoushui()
    self.joinEditBox:setText(scoreOption.join)
    -- self.qiangEditBox:setText(scoreOption.qiang)
    -- self.tuiEditBox:setText(scoreOption.tui)
    self.choushuiEditBox:setText(scoreOption.choushui)
    self.choushuiLayer:getChildByName('sel'):getChildByName('Text'):setString('进场:' .. scoreOption.join ..  
    ' 抽水比例:' .. scoreOption.choushui .. '%')

    self.joinEditBox:registerScriptEditBoxHandler(function(eventname,sender) self:editboxHandle(eventname,sender) end)
    -- self.qiangEditBox:registerScriptEditBoxHandler(function(eventname,sender) self:editboxHandle(eventname,sender) end)
    -- self.tuiEditBox:registerScriptEditBoxHandler(function(eventname,sender) self:editboxHandle(eventname,sender) end)
    self.choushuiEditBox:registerScriptEditBoxHandler(function(eventname,sender) self:editboxHandle(eventname,sender) end)
end

function CreateRoomPJView:editboxHandle(eventname, sender)
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

function CreateRoomPJView:freshWinner(data,sender)
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
function CreateRoomPJView:freshmulTextColor(data) 
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

function CreateRoomPJView:freshTextColor(data) 
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
function CreateRoomPJView:freshPriceLayer(bShow) 
    self.bg:getChildByName('priceLayer'):setVisible(bShow)
end

function CreateRoomPJView:freshquickLayer(bShow) 
    self.bg:getChildByName('quickLayer'):setVisible(bShow)
end

function CreateRoomPJView:freshChoushuiLayer(bShow,data) 
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName(option_type) 
    option:getChildByName('choushui'):getChildByName('opt'):setVisible(bShow)
    local path = 'res/views/createroom/' .. data.direction ..'.png'
    local bg = option:getChildByName('choushui'):getChildByName('sel'):getChildByName('bg')
    bg:getChildByName('down'):loadTexture(path)
end
-- ------------------------------------------------------------------------------------------
function CreateRoomPJView:layout(isGroup, createmode, paymode)
    local MainPanel = self.ui:getChildByName('MainPanel')
    MainPanel:setContentSize(cc.size(display.width, display.height))
    MainPanel:setPosition(display.cx, display.cy)
    self.MainPanel = MainPanel

    local bg = MainPanel:getChildByName('bg')
    bg:setPosition(display.cx, display.cy)
    self.bg = bg
    self.isgroup = isGroup
    self.paymode = paymode
    self.choushuiLayer = bg:getChildByName('pjOption'):getChildByName('choushui')
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
            self.isgroup = true
        end
    else
        -- 正常创建
        self.bg:getChildByName('typelist'):removeItem(2)
        self.bg:getChildByName('confirm'):setVisible(true)
        self.bg:getChildByName('tips'):setVisible(true)
        self.bg:getChildByName('sureBtn'):setVisible(false)    
    end
    
    -- if LocalSettings:getRoomPJConfig("gameplay") then
    --     self.focus = LocalSettings:getRoomPJConfig("gameplay")
    -- else
    --     self.focus = 'pj'
    -- end
    self.focus = 'pj'

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

function CreateRoomPJView:getOptions()
    SoundMng.playEft('room_dingding.mp3')
    local key = self.focus .. 'Option'
    local savedata = self.options[key].msg
    local msg = clone(savedata)
    msg.base = BASE[msg.base]

    msg.round = ROUND[msg.round]
    -- msg.round = 300

    if self.isgroup and self.paymode == 2 then
        msg.roomPrice = 1
    end

    msg.enter = {}
    msg.robot = 1
    msg.enter.buyHorse = 0
    msg.enter.enterOnCreate = 1
    
    msg.maxPeople = 4

    msg.deskMode = 'pj'

    msg.scoreOption = {
        choushui_pj = tonumber(self.choushuiEditBox:getText()),
        join = tonumber(self.joinEditBox:getText()),
        qiang = scoreOption.qiang,
        tui = scoreOption.tui,
        rule = self.winner or 1,
    }

    dump(msg)

    return msg
end

function CreateRoomPJView:showWaiting()
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

function CreateRoomPJView:delShowWaiting()
    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
        self.schedulerID = nil
        if self.waitingView then
            ShowWaiting.delete()
            self.waitingView = false
        end
    end
end

function CreateRoomPJView:onExit()
    self:delShowWaiting()
end

function CreateRoomPJView:startCsdAnimation( node, csbName, isRepeat, timeSpeed)
    local action = cc.CSLoader:createTimeline("views/createroom/"..csbName..".csb")
    action:gotoFrameAndPlay(0,isRepeat)
    if timeSpeed then
    action:setTimeSpeed(timeSpeed)
    end
    node:stopAllActions()
    node:runAction(action)
end

function CreateRoomPJView:startallAction()
    for i,v in pairs(tabs) do
        -- self:startCsdAnimation(self.bg:getChildByName(i):getChildByName("active"):getChildByName("blinkingBoxNode"),"blinkingBoxAnimation",true,1.3)
    end

    -- self:startCsdAnimation(self.bg:getChildByName("flashBoxNode"),"flashBoxAnimation",true,0.8)  
end

return CreateRoomPJView