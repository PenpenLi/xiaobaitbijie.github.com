local SoundMng = require('app.helpers.SoundMng')
local ShowWaiting = require('app.helpers.ShowWaiting')
local tools = require('app.helpers.tools')
local GameLogic = require('app.libs.niuniu.NNGameLogic')

local CreateRoomView = {}
local LocalSettings = require('app.models.LocalSettings')
local roomType = {
    ['szOption'] = 1, 
    ['gzOption'] = 2, 
    ['zqOption'] = 3, 
    ['mqOption'] = 4, 
    ['tbOption'] = 5, 
    -- ['fkOption'] = 6, 
    -- ['bmOption'] = 7,
    -- ['smOption'] = 8,
    -- ['flOption'] = 9,
}
local typeOptions = {
    ['base'] = 1, 
    ['round'] = 2,
    ['roomPrice'] = 3, 
    ['multiply'] = 4, 
    ['special'] = 5, 
    ['advanced'] = 6, 
    ['qzMax'] = 7, 
    ['putmoney'] = 8,
    ['startMode'] = 9,
    ['wanglai'] = 10,
    ['peopleSelect'] = 10,
}
local tabs = {
    ['sz'] = 1, -- 牛牛上庄
    ['gz'] = 2, -- 固定上庄
    ['zq'] = 3, -- 自由抢庄
    ['mq'] = 4, -- 明牌抢庄
    ['tb'] = 5, -- 通比牛牛
    -- ['fk'] = 6, -- 疯狂加倍
    -- ['bm'] = 7, -- 八人明牌
    -- ['sm'] = 8, -- 十人明牌
    -- ['fl'] = 9, -- 疯狂轮庄
}

local BASE = {
    [1] = '1/2/4',
    [2] = '2/4/8',
    [3] = '3/6/12',
    [4] = '4/8/16',
    [5] = '5/10/20',
    [6] = '10/20/40',
}

local TBBASE = {
    [1] = '1',
    [2] = '2',
    [3] = '3',
    [4] = '4',
    [5] = '5',
    [6] = '10',
}

local ROUND = {
    [1] = 10,
    [2] = 15,
    [3] = 20,
}

local QZ_ROUND = {
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

local costList = {
    -- szOption1 = 4,
    -- szOption2 = 6,
    -- szOption3 = 9,

    -- gzOption1 = 4,
    -- gzOption2 = 6,
    -- gzOption3 = 9,

    -- zqOption1 = 4,
    -- zqOption2 = 6,
    -- zqOption3 = 9,
    
    -- mqOption1 = 4,
    -- mqOption2 = 6,
    -- mqOption3 = 9,

    -- tbOption1 = 4,
    -- tbOption2 = 6,
    -- tbOption3 = 9,

    -- fkOption1 = 4,
    -- fkOption2 = 6,
    -- fkOption3 = 9,

    -- bmOption1 = 5,
    -- bmOption2 = 8,
    -- bmOption3 = 12,

    -- smOption1 = 6,
    -- smOption2 = 10,
    -- smOption3 = 15,

    -- flOption1 = 4,
    -- flOption2 = 6,
    -- flOption3 = 9,

    Option11 = 4,
    Option12 = 5,
    Option13 = 6,
    Option21 = 6,
    Option22 = 8,
    Option23 = 10,
    Option31 = 9,
    Option32 = 12,
    Option33 = 15,
}

local setVersion = 26

function CreateRoomView:initialize()
    self:enableNodeEvents()
    self.options = {}
    self.paymode = 1
    local setPath = cc.FileUtils:getInstance():getWritablePath() .. '.CreateRoomConfig'

    if io.exists(setPath) then
        local ver = LocalSettings:getRoomConfig('setVersion')
        if (not ver) or ver < setVersion then
            cc.FileUtils:getInstance():removeFile(setPath)
        end
    end

    print("getincreateroom")

    self.options['szOption'] = { msg = {
        ['gameplay'] = 1,  ['base'] = 1,   ['round'] = 1,
        ['roomPrice'] = 1, ['multiply'] = 1, ['special'] = { 1, 2, 3, 4, 5, 6, 7, 0, 9},
        ['advanced'] = { 1, 0, 0, 0, 0, 0, 0, 0, 0},
        ['putmoney'] = 1,
        ['startMode'] = 1,
        ['wanglai'] = 1,
        ['peopleSelect'] = 1,
    } }

    self.options['gzOption'] = { msg = {
        ['gameplay'] = 2,  ['base'] = 1,   ['round'] = 1,
        ['roomPrice'] = 1, ['multiply'] = 1, ['special'] = { 1, 2, 3, 4, 5, 6, 7, 0, 9},
        ['advanced'] = { 1, 0, 0, 0, 0, 0, 0, 0, 0},
        ['putmoney'] = 1,
        ['startMode'] = 1,
        ['wanglai'] = 1,
        ['peopleSelect'] = 1,
    } }

    self.options['zqOption'] = { msg = {
        ['gameplay'] = 3,  ['base'] = 1,   ['round'] = 1,
        ['roomPrice'] = 1, ['multiply'] = 1, ['special'] = { 1, 2, 3, 4, 5, 6, 7, 0, 9},
        ['advanced'] = { 1, 0, 0, 0, 0, 0, 0, 0, 0},
        ['putmoney'] = 1,
        ['startMode'] = 1,
        ['wanglai'] = 1,
        ['peopleSelect'] = 1,
    } }

    self.options['mqOption'] = { msg = {
        ['gameplay'] = 4,  ['base'] = 1,   ['round'] = 1,
        ['roomPrice'] = 1, ['multiply'] = 1, ['special'] = { 1, 2, 3, 4, 5, 6, 7, 0, 9},
        ['advanced'] = { 1, 0, 0, 0, 0, 0, 0, 0, 0},
        ['qzMax'] = 1,
        ['putmoney'] = 1,
        ['startMode'] = 1,
        ['wanglai'] = 1,
        ['peopleSelect'] = 1,
    } }

    self.options['tbOption'] = { msg = {
        ['gameplay'] = 5,  ['base'] = 1,     ['round'] = 1,
        ['roomPrice'] = 1, ['multiply'] = 1, ['special'] = { 1, 2, 3, 4, 5, 6, 7, 0, 9},
        ['advanced'] = { 1, 0, 0, 0, 0, 0, 0, 0, 0},
        ['putmoney'] = 1,
        ['startMode'] = 1,
        ['wanglai'] = 1,
        ['peopleSelect'] = 1,
    } }

    -- self.options['fkOption'] = { msg = {
    --     ['gameplay'] = 6,  ['base'] = 1,   ['round'] = 1,
    --     ['roomPrice'] = 1, ['multiply'] = 1, ['special'] = { 1, 2, 3, 4, 5, 6, 7, 0, 9},
    --     ['advanced'] = { 1, 0, 0, 0, 0, 0, 0, 0, 0},
    --     ['qzMax'] = 1,
    --     ['putmoney'] = 1,
    --     ['startMode'] = 1,
    --     ['wanglai'] = 1,
    --     ['peopleSelect'] = 1,
    -- } }

    -- self.options['bmOption'] = { msg = {
    --     ['gameplay'] = 7,  ['base'] = 1,   ['round'] = 1,
    --     ['roomPrice'] = 1, ['multiply'] = 1, ['special'] = { 1, 2, 3, 4, 5, 6, 7, 0, 9},
    --     ['advanced'] = { 1, 0, 0, 0, 0, 0, 0, 0, 0},
    --     ['qzMax'] = 1,
    --     ['putmoney'] = 1,
    --     ['startMode'] = 1,
    --     ['wanglai'] = 1,
    --     ['peopleSelect'] = 1,
    -- } }

    -- self.options['smOption'] = { msg = {
    --     ['gameplay'] = 8,  ['base'] = 1,   ['round'] = 1,
    --     ['roomPrice'] = 1, ['multiply'] = 1, ['special'] = { 1, 2, 3, 4, 5, 6, 7, 0, 9},
    --     ['advanced'] = { 1, 0, 0, 0, 0, 0, 0, 0, 0},
    --     ['qzMax'] = 1,
    --     ['putmoney'] = 1,
    --     ['startMode'] = 1,
    --     ['wanglai'] = 1,
    --     ['peopleSelect'] = 1,
    -- } }

    -- self.options['flOption'] = { msg = {
    --     ['gameplay'] = 9,  ['base'] = 1,   ['round'] = 1,
    --     ['roomPrice'] = 1, ['multiply'] = 1, ['special'] = { 1, 2, 3, 4, 5, 6, 7, 0, 9},
    --     ['advanced'] = { 1, 0, 0, 0, 0, 0, 0, 0, 0},
    --     ['putmoney'] = 1,
    --     ['startMode'] = 1,
    --     ['wanglai'] = 1,
    --     ['peopleSelect'] = 1,
    -- } }

    if not io.exists(cc.FileUtils:getInstance():getWritablePath() .. '.CreateRoomConfig')  then

        print(LocalSettings:getRoomConfig('szOptionbase'))

        for i,v in pairs(roomType) do
            for j,n in pairs(typeOptions) do
                LocalSettings:setRoomConfig(i..j, self.options[i]['msg'][j])
            end
        end

        LocalSettings:setRoomConfig('setVersion', setVersion)

    else
        print(" LocalSettings:getRoomConfig(v..n) is not == nil")
    end

    local MainPanel = self.ui:getChildByName('MainPanel')
    local bg = MainPanel:getChildByName('bg')
    self.bg = bg

    for i,v in pairs(roomType) do 
        for j, n in pairs(typeOptions) do 
            local data =  LocalSettings:getRoomConfig(i..j)
            if data then 
                self.options[i]['msg'][j] = data
            end
        end
    end

    self:freshAllItem()
end

function CreateRoomView:freshAllItem() 

    if LocalSettings:getRoomConfig("gameplay") then
        self.focus = LocalSettings:getRoomConfig("gameplay")
        if self.focus == 'bm' or self.focus == 'sm' then
            self.focus = 'mq'
        end
    else
        self.focus = 'sz'
    end

    -- if self.isgroup then
    --     if self.focus == 'gz' or self.focus == 'tb' then
    --         self.focus = 'sz'
    --     end
    -- end

    local bg = self.bg
    local option_type = self.focus .. 'Option'
    local option = bg:getChildByName('Option')
    for j, n in pairs(typeOptions) do 
        local data =  LocalSettings:getRoomConfig(option_type..j)
        if data then 
            local sender = nil
            if j == 'multiply' then 
                sender = option:getChildByName(j):getChildByName('opt'):getChildByName(tostring(data))
            elseif j == 'special' or j == 'advanced' then
                sender = nil 
            elseif j == 'base' or j == 'round' or j == 'startMode' or j == 'putmoney' then
                sender = nil
            else
                sender =  option:getChildByName(j):getChildByName(tostring(data))
            end 
            local fun = 'fresh'..j
            if self[fun] then 
                self[fun](self,data,sender)
            end
        end
    end
end

--------------------------------------------------------------------------------------------
--左边选择模式点击事件
function CreateRoomView:freshTab(data)
    for i, v in pairs(tabs) do 
        local tab = self.isShow and self.typeList:getItem(1) or self.bg:getChildByName('tab')
        local currentItem = tab:getChildByName(i)
        local currentOpt = self.bg:getChildByName('Option')
        if data then 
            self.focus = data
        end
        if self.focus == i then
            currentItem:getChildByName('active'):setVisible(true)
            -- currentOpt:setVisible(true)
        else
            currentItem:getChildByName('active'):setVisible(false)
            -- currentOpt:setVisible(false)
        end
    end
    -- if self.isgroup then 
    --     self.bg:getChildByName('tb'):setVisible(false)
    --     self.bg:getChildByName('gz'):setVisible(false)
    -- end
    if self.focus == 'mq' then
        self.bg:getChildByName('Option'):getChildByName('qzMax'):setVisible(true)
        self.bg:getChildByName('Option'):getChildByName('wanglai'):setVisible(true)
    else
        self.bg:getChildByName('Option'):getChildByName('qzMax'):setVisible(false)
        self.bg:getChildByName('Option'):getChildByName('wanglai'):setVisible(false)
    end
    LocalSettings:setRoomConfig("gameplay", self.focus)
    self:freshAllItem()

    local app = require("app.App"):instance()
    app.session.room:setCurrentNNType(self.focus)
end

--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
--刷新左边模式是否已配
function CreateRoomView:freshHasSave(data)
    for i, v in pairs(tabs) do 
        local tab = self.isShow and self.typeList:getItem(1) or self.bg:getChildByName('tab')
        local currentItem = tab:getChildByName(i)
        local hassaveImage = currentItem:getChildByName('Image')
        if data[v] == 1 then
            hassaveImage:setVisible(true)
        else
            hassaveImage:setVisible(false)
        end
    end
    -- LocalSettings:setRoomConfig("gameplay", self.focus)
end

--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------
--各个模式的刷新界面逻辑
function CreateRoomView:freshbase(data,sender)
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName('Option')
    local item = option:getChildByName('base')

    local current_value = self.options[option_type]['msg']['base']
    if sender then
        current_value = (current_value + (tonumber(data) == 0 and -1 or 1) - 1) % 6 + 1
    end
    item:getChildByName('text'):setString(GameLogic.getBaseOrder(current_value, self.focus))

    self.options[option_type]['msg']['base'] = current_value
    LocalSettings:setRoomConfig(option_type..item:getName(), current_value)

    local info = {
        option =  option_type ,
        item = 'base' ,
        num = 6 ,
    }

    -- self:freshTextColor(info)
end

function CreateRoomView:freshround(data,sender)
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName('Option')
    local item = option:getChildByName('round')

    local current_value = self.options[option_type]['msg']['round']
    if sender then
        current_value = (current_value + (tonumber(data) == 0 and -1 or 1) - 1) % 3 + 1
    end
    item:getChildByName('text'):setString(ROUND[current_value] .. '局')

    self.options[option_type]['msg']['round'] = current_value
    LocalSettings:setRoomConfig(option_type..item:getName(), current_value)

    local peopleSelect = self.options[option_type]['msg']['peopleSelect']
    local str = 'Option' .. current_value .. peopleSelect
    --根据局数更改房卡数值
    if self.paymode == 1 then
        if current_value == 1 then
            option:getChildByName('roomPrice'):getChildByName('1'):getChildByName('Text'):setString('房主支付(      ' .. costList[str]..')')
            option:getChildByName('roomPrice'):getChildByName('2'):getChildByName('Text'):setString('AA支付(每人      1)')
        end
        if current_value == 2 then
            option:getChildByName('roomPrice'):getChildByName('1'):getChildByName('Text'):setString('房主支付(      ' .. costList[str]..')')
            option:getChildByName('roomPrice'):getChildByName('2'):getChildByName('Text'):setString('AA支付(每人      2)')
        end
        if current_value == 3 then
            option:getChildByName('roomPrice'):getChildByName('1'):getChildByName('Text'):setString('房主支付(      ' .. costList[str]..')')
            option:getChildByName('roomPrice'):getChildByName('2'):getChildByName('Text'):setString('AA支付(每人      3)')
        end
    elseif self.paymode == 2 then 
        current_value = self:freshGroupCreateRoomview()
        if current_value == 1 then
            option:getChildByName('roomPrice'):getChildByName('paymode'):getChildByName('Text1'):setString('（      ' .. costList[str]..'）俱乐部管理员已设置从俱乐部基金中扣除，无需你支付')
        end
        if current_value == 2 then
            option:getChildByName('roomPrice'):getChildByName('paymode'):getChildByName('Text1'):setString('（      ' .. costList[str]..'）俱乐部管理员已设置从俱乐部基金中扣除，无需你支付')
        end
        if current_value == 3 then
            option:getChildByName('roomPrice'):getChildByName('paymode'):getChildByName('Text1'):setString('（      ' .. costList[str]..'）俱乐部管理员已设置从俱乐部基金中扣除，无需你支付')
        end
    end

    local info = {
        option =  option_type ,
        item = 'round' ,
        num = 3 ,
    }

    -- self:freshTextColor(info)
end

function CreateRoomView:freshpeopleSelect(data,sender)
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName('Option')
    local item = option:getChildByName('peopleSelect')

    local current_value = self.options[option_type]['msg']['peopleSelect']
    if sender then
        current_value = (current_value + (tonumber(data) == 0 and -1 or 1) - 1) % 3 + 1
    end
    item:getChildByName('text'):setString(GameLogic.getPeopleSelectOrder(current_value))

    self.options[option_type]['msg']['peopleSelect'] = current_value
    LocalSettings:setRoomConfig(option_type..item:getName(), current_value)

    local round = self.options[option_type]['msg']['round']
    local str = 'Option' .. round .. current_value
    --根据局数更改房卡数值
    if self.paymode == 1 then
        if current_value == 1 then
            option:getChildByName('roomPrice'):getChildByName('1'):getChildByName('Text'):setString('房主支付(      ' .. costList[str]..')')
            -- option:getChildByName('roomPrice'):getChildByName('2'):getChildByName('Text'):setString('AA支付(每人      1)')
        end
        if current_value == 2 then
            option:getChildByName('roomPrice'):getChildByName('1'):getChildByName('Text'):setString('房主支付(      ' .. costList[str]..')')
            -- option:getChildByName('roomPrice'):getChildByName('2'):getChildByName('Text'):setString('AA支付(每人      2)')
        end
        if current_value == 3 then
            option:getChildByName('roomPrice'):getChildByName('1'):getChildByName('Text'):setString('房主支付(      ' .. costList[str]..')')
            -- option:getChildByName('roomPrice'):getChildByName('2'):getChildByName('Text'):setString('AA支付(每人      3)')
        end
    elseif self.paymode == 2 then 
        current_value = self:freshGroupCreateRoomview()
        if current_value == 1 then
            option:getChildByName('roomPrice'):getChildByName('paymode'):getChildByName('Text1'):setString('（      ' .. costList[str]..'）俱乐部管理员已设置从俱乐部基金中扣除，无需你支付')
        end
        if current_value == 2 then
            option:getChildByName('roomPrice'):getChildByName('paymode'):getChildByName('Text1'):setString('（      ' .. costList[str]..'）俱乐部管理员已设置从俱乐部基金中扣除，无需你支付')
        end
        if current_value == 3 then
            option:getChildByName('roomPrice'):getChildByName('paymode'):getChildByName('Text1'):setString('（      ' .. costList[str]..'）俱乐部管理员已设置从俱乐部基金中扣除，无需你支付')
        end
    end

    local info = {
        option =  option_type ,
        item = 'peopleSelect' ,
        num = 3 ,
    }

    -- self:freshTextColor(info)
end

function CreateRoomView:freshroomPrice(data,sender)
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName('Option')
    local item = option:getChildByName('roomPrice')

    item:getChildByName('1'):getChildByName('select'):setVisible(false)
    item:getChildByName('2'):getChildByName('select'):setVisible(false)
    item:getChildByName('paymode'):setVisible(false)
    sender:getChildByName('select'):setVisible(true)

    self.options[option_type]['msg']['roomPrice'] = tonumber(data)
    LocalSettings:setRoomConfig(option_type..item:getName(), tonumber(data))

    local info = {
        option =  option_type ,
        item = 'roomPrice' ,
        num = 2 ,
    }

    self:freshTextColor(info)
end

function CreateRoomView:freshmultiply(data,sender)
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName('Option')
    local item = option:getChildByName('multiply')

    for i = 1, 5 do
        item:getChildByName('opt'):getChildByName('' .. i):getChildByName('select'):setVisible(false)
    end
    sender:getChildByName('select'):setVisible(true)
    item:getChildByName('sel'):getChildByName('Text'):setString(sender:getChildByName("Text"):getString())

    self.options[option_type]['msg']['multiply'] = tonumber(data)
    LocalSettings:setRoomConfig(option_type..item:getName(), tonumber(data))

    local info = {
        option =  option_type ,
        item = 'multiply' ,
        num = 5 ,
    }

    self:freshTextColor(info)
end

function CreateRoomView:freshspecial(data,sender)
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName('Option')
    local item = option:getChildByName('special')
    self.specialselect = 0

    for i = 1, 9 do
        item:getChildByName('opt'):getChildByName('' .. i):getChildByName('select'):setVisible(false)
    end

    for i = 1, #data do
        if data[i] == i then
            item:getChildByName('opt'):getChildByName(tostring(i)):getChildByName('select'):setVisible(true)
            self.specialselect = self.specialselect + 1
        end
    end
    if self.specialselect == 8 then 
        item:getChildByName('sel'):getChildByName('Text'):setString("全部勾选")
    else
        item:getChildByName('sel'):getChildByName('Text'):setString("部分勾选")
    end

    self.options[option_type]['msg']['special'] = data
    LocalSettings:setRoomConfig(option_type..item:getName(), self.options[option_type]['msg']['special'])

    local info = {
        option =  option_type ,
        item = 'special' ,
    }

    self:freshmulTextColor(info)
end

function CreateRoomView:freshspecialnow(data,sender)
    local data = tonumber(data)
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName('Option')
    local item = option:getChildByName('special')
    local flag = sender:getChildByName('select'):isVisible()

    sender:getChildByName('select'):setVisible(not flag)

    local specialselect =  self.options[option_type]['msg']['special']
    local specialselectnum = 0

    for i, v in pairs(specialselect) do
        if v == i then
            specialselectnum = specialselectnum + 1
        end
    end

    if flag then
        specialselectnum = specialselectnum - 1
    else
        specialselectnum = specialselectnum + 1
    end

    if specialselectnum == 8 then 
        item:getChildByName('sel'):getChildByName('Text'):setString("全部勾选")
    else
        item:getChildByName('sel'):getChildByName('Text'):setString("部分勾选")
    end
    
    self.options[option_type]['msg']['special'][data] = flag and 0 or data
    LocalSettings:setRoomConfig(option_type..item:getName(), self.options[option_type]['msg']['special'])

    local info = {
        option =  option_type ,
        item = 'special' ,
    }

    self:freshmulTextColor(info)
end

function CreateRoomView:freshqzMax(data,sender)
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName('Option')
    local item = option:getChildByName('qzMax')

    item:getChildByName('1'):getChildByName('select'):setVisible(false)
    item:getChildByName('2'):getChildByName('select'):setVisible(false)
    item:getChildByName('3'):getChildByName('select'):setVisible(false)
    item:getChildByName('4'):getChildByName('select'):setVisible(false)
    sender:getChildByName('select'):setVisible(true)

    self.options[option_type]['msg']['qzMax'] = tonumber(data)
    LocalSettings:setRoomConfig(option_type..item:getName(), tonumber(data))

    local info = {
        option =  option_type ,
        item = 'qzMax' ,
        num = 4 ,
    }

    self:freshTextColor(info)
end

function CreateRoomView:freshstartMode(data,sender)
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName('Option')
    local item = option:getChildByName('startMode')

    local current_value = self.options[option_type]['msg']['startMode']
    if sender then
        current_value = (current_value + (tonumber(data) == 0 and -1 or 1) - 1) % 4 + 1
    end
    local peopleSelect = self.options[option_type]['msg']['peopleSelect']
    item:getChildByName('text'):setString(GameLogic.getStartModeOrder(current_value, peopleSelect))

    self.options[option_type]['msg']['startMode'] = current_value
    LocalSettings:setRoomConfig(option_type..item:getName(), current_value)

    local info = {
        option =  option_type ,
        item = 'startMode' ,
        num = 4 ,
    }

    -- self:freshTextColor(info)
end

function CreateRoomView:freshputmoney(data,sender)
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName('Option')
    local item = option:getChildByName('putmoney')

    local current_value = self.options[option_type]['msg']['putmoney']
    if sender then
        current_value = (current_value + (tonumber(data) == 0 and -1 or 1) - 1) % 6 + 1
    end
    item:getChildByName('text'):setString(GameLogic.getPutMoneyOrder(current_value))

    self.options[option_type]['msg']['putmoney'] = current_value
    LocalSettings:setRoomConfig(option_type..item:getName(), current_value)

    local info = {
        option =  option_type ,
        item = 'putmoney' ,
        num = 6 ,
    }

    -- self:freshTextColor(info)
end

function CreateRoomView:freshadvanced(data,sender)
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName('Option')
    local item = option:getChildByName('advanced')

    for i = 1, 9 do
        item:getChildByName('' .. i):getChildByName('select'):setVisible(false)
    end

    -- if option_type == 'zqOption' or option_type == 'mqOption' or option_type == 'fkOption' or option_type == 'bmOption' or option_type == 'smOption' then
    --     item:getChildByName('4'):getChildByName('select'):setVisible(false)
    -- end

    -- if option_type == 'mqOption' or option_type == 'fkOption' or option_type == 'bmOption' or option_type == 'smOption' then
    --     item:getChildByName('5'):getChildByName('select'):setVisible(false)
    -- end

    for i = 1, #data do
        if data[i] == i then
            item:getChildByName(tostring(i)):getChildByName('select'):setVisible(true)
        end
    end

    self.options[option_type]['msg']['advanced'] = data
    LocalSettings:setRoomConfig(option_type..item:getName(), self.options[option_type]['msg']['advanced'])

    local info = {
        option =  option_type ,
        item = 'advanced' ,
    }

    self:freshmulTextColor(info)
end

function CreateRoomView:freshadvancednow(data,sender)
    local data = tonumber(data)
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName('Option')
    local item = option:getChildByName('advanced')
    local flag = sender:getChildByName('select'):isVisible()

    sender:getChildByName('select'):setVisible(not flag)
    
    self.options[option_type]['msg']['advanced'][data] = flag and 0 or data
    LocalSettings:setRoomConfig(option_type..item:getName(), self.options[option_type]['msg']['advanced'])

    local info = {
        option =  option_type ,
        item = 'advanced' ,
    }

    self:freshmulTextColor(info)
end

function CreateRoomView:freshwanglai(data,sender)
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName('Option')
    local item = option:getChildByName('wanglai')

    item:getChildByName('1'):getChildByName('select'):setVisible(false)
    item:getChildByName('2'):getChildByName('select'):setVisible(false)
    item:getChildByName('3'):getChildByName('select'):setVisible(false)
    sender:getChildByName('select'):setVisible(true)

    self.options[option_type]['msg']['wanglai'] = tonumber(data)
    LocalSettings:setRoomConfig(option_type..item:getName(), tonumber(data))

    local info = {
        option =  option_type ,
        item = 'wanglai' ,
        num = 3 ,
    }

    self:freshTextColor(info)
end

function CreateRoomView:freshchoushui()
    self.joinEditBox:setText(scoreOption.join)
    self.qiangEditBox:setText(scoreOption.qiang)
    self.tuiEditBox:setText(scoreOption.tui)
    self.choushuiEditBox:setText(scoreOption.choushui)
    self.choushuiLayer:getChildByName('sel'):getChildByName('Text'):setString('进场:' .. scoreOption.join .. ' 抢:' .. scoreOption.qiang 
    .. ' 推:' .. scoreOption.tui .. ' 抽水比例:' .. scoreOption.choushui .. '%')

    self.joinEditBox:registerScriptEditBoxHandler(function(eventname,sender) self:editboxHandle(eventname,sender) end)
    self.qiangEditBox:registerScriptEditBoxHandler(function(eventname,sender) self:editboxHandle(eventname,sender) end)
    self.tuiEditBox:registerScriptEditBoxHandler(function(eventname,sender) self:editboxHandle(eventname,sender) end)
    self.choushuiEditBox:registerScriptEditBoxHandler(function(eventname,sender) self:editboxHandle(eventname,sender) end)
end

function CreateRoomView:editboxHandle(eventname, sender)
    if eventname == "began" then
        --光标进入，选中全部内容
    elseif eventname == "ended" then
        -- 当编辑框失去焦点并且键盘消失的时候被调用
    elseif eventname == "return" then
        -- 当用户点击编辑框的键盘以外的区域，或者键盘的Return按钮被点击时所调用
    elseif eventname == "changed" then
        -- 输入内容改变时调用
        self.choushuiLayer:getChildByName('sel'):getChildByName('Text'):setString('进场:' .. self.joinEditBox:getText() ..
        ' 抢:' .. self.qiangEditBox:getText() .. ' 推:' .. self.tuiEditBox:getText() .. ' 抽水比例:' .. self.choushuiEditBox:getText() .. '%')
    end
end

function CreateRoomView:freshWinner(data,sender)
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName('Option')
    local item = option:getChildByName('choushui')

    item:getChildByName('opt'):getChildByName('1'):getChildByName('select'):setVisible(false)
    item:getChildByName('opt'):getChildByName('2'):getChildByName('select'):setVisible(false)
    sender:getChildByName('select'):setVisible(true)
    self.winner = tonumber(data)

end

---------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
--刷新字体颜色
function CreateRoomView:freshmulTextColor(data) 
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName('Option')
    local item = option:getChildByName(data.item)
    if data.item == 'multiply' or data.item == 'special' then 
        item = item:getChildByName('opt')
    end
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

function CreateRoomView:freshTextColor(data) 
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName('Option')
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
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
--三个问号提示的点击事件
function CreateRoomView:freshPriceLayer(bShow) 
    self.bg:getChildByName('priceLayer'):setVisible(bShow)
end

function CreateRoomView:freshTuiZhuLayer(bShow) 
    self.bg:getChildByName('tuizhuLayer'):setVisible(bShow)
end

function CreateRoomView:freshXiaZhuLayer(bShow) 
    self.bg:getChildByName('xiazhuLayer'):setVisible(bShow)
end

function CreateRoomView:freshquickLayer(bShow) 
    self.bg:getChildByName('quickLayer'):setVisible(bShow)
end

function CreateRoomView:freshWangLaiLayer(bShow, data) 
    self.bg:getChildByName('wanglaiLayer'):setVisible(bShow)
    if bShow then
        if (self.focus == 'bm' or self.focus == 'mq') and data then
            self.bg:getChildByName('wanglaiLayer'):getChildByName('bm'):setVisible(true)
            self.bg:getChildByName('wanglaiLayer'):getChildByName('bm'):getChildByName('1'):setVisible(false)
            self.bg:getChildByName('wanglaiLayer'):getChildByName('bm'):getChildByName('2'):setVisible(false)
            self.bg:getChildByName('wanglaiLayer'):getChildByName('bm'):getChildByName(data):setVisible(true)
        end
    end
end

--两个模式的点击事件
function CreateRoomView:freshSpecialLayer(bShow,data) 
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName('Option') 
    option:getChildByName('special'):getChildByName('opt'):setVisible(bShow)
    local path = 'res/views/createroom/' .. data.direction ..'.png'
    local bg = option:getChildByName('special'):getChildByName('sel'):getChildByName('bg')
    bg:getChildByName('down'):loadTexture(path)
end

function CreateRoomView:freshMultiplyLayer(bShow,data) 
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName('Option') 
    option:getChildByName('multiply'):getChildByName('opt'):setVisible(bShow)
    local path = 'res/views/createroom/' .. data.direction ..'.png'
    local bg = option:getChildByName('multiply'):getChildByName('sel'):getChildByName('bg')
    bg:getChildByName('down'):loadTexture(path)
end

function CreateRoomView:freshChoushuiLayer(bShow,data) 
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName('Option') 
    option:getChildByName('choushui'):getChildByName('opt'):setVisible(bShow)
    local path = 'res/views/createroom/' .. data.direction ..'.png'
    local bg = option:getChildByName('choushui'):getChildByName('sel'):getChildByName('bg')
    bg:getChildByName('down'):loadTexture(path)
end
------------------------------------------------------------------------------------------

function CreateRoomView:freshGroupCreateRoomview()
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName('Option') 
    local opView = option:getChildByName('roomPrice')
    opView:getChildByName('1'):getChildByName('select'):setVisible(false)
    opView:getChildByName('2'):getChildByName('select'):setVisible(false)
    opView:getChildByName('paymode'):setVisible(true)
    opView:getChildByName('1'):setVisible(false)
    opView:getChildByName('2'):setVisible(false)
    opView:getChildByName('dm1'):setVisible(false)
    opView:getChildByName('dm2'):setVisible(false)
    opView:getChildByName('why'):setVisible(false)
    local round = LocalSettings:getRoomConfig(option_type ..'round')
    return round
end

function CreateRoomView:layout(isGroup, createmode, paymode)
    local MainPanel = self.ui:getChildByName('MainPanel')
    MainPanel:setContentSize(cc.size(display.width, display.height))
    MainPanel:setPosition(display.cx, display.cy)
    self.MainPanel = MainPanel

    local bg = MainPanel:getChildByName('bg')
    bg:setPosition(display.cx, display.cy)
    self.bg = bg
    self.isgroup = isGroup
    self.paymode = paymode
    self.isShow = false
    self.typeList = bg:getChildByName('typelist')
    self.tabs = bg:getChildByName('tab')
    self.choushuiLayer = bg:getChildByName('Option'):getChildByName('choushui')
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
            -- self:startCsdAnimation(self.bg:getChildByName('quickstart'):getChildByName("PurpleNode"),"PurpleAnimation",true,0.8)
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
    
    if LocalSettings:getRoomConfig("gameplay") then
        self.focus = LocalSettings:getRoomConfig("gameplay")
        if self.focus == 'bm' or self.focus == 'sm' then
            self.focus = 'mq'
        end
    else
        self.focus = 'sz'
    end

    -- if self.isgroup then
    --     if self.focus == 'gz' or self.focus == 'tb' then
    --         self.focus = 'sz'
    --     end
    -- end

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

    local qiang = self.choushuiLayer:getChildByName('opt'):getChildByName('qiangLayer')
    self.qiangEditBox = tools.createEditBox(qiang, {
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

    local tui = self.choushuiLayer:getChildByName('opt'):getChildByName('tuiLayer')
    self.tuiEditBox = tools.createEditBox(tui, {
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

function CreateRoomView:getOptions()
    SoundMng.playEft('room_dingding.mp3')
    local key = self.focus .. 'Option'
    local savedata = self.options[key].msg
    local msg = clone(savedata)
    if key == 'fkOption' then
        -- msg.putmoney = 1
        -- msg.qzMax = 1
    end

    -- if key == 'tbOption' then
    --     msg.gameplay = 4
    --     key = 'mqOption'
    -- end

    if key == 'tbOption' then
        msg.base = TBBASE[msg.base]
    else
        msg.base = BASE[msg.base]
    end

    msg.cost = 1
    if msg.roomPrice == 1 then
        msg.cost = costList['Option' .. msg.round .. msg.peopleSelect]
    elseif msg.roomPrice == 2 then
        msg.cost = msg.round
    end

    if msg.gameplay == 4 or msg.gameplay == 6 or msg.gameplay == 7 or msg.gameplay == 8 then
        msg.round = QZ_ROUND[msg.round]
    else
        msg.round = ROUND[msg.round]
    end

    if self.isgroup and self.paymode == 2 then
        msg.roomPrice = 1
    end

    msg.enter = {}
    msg.robot = 1
    msg.enter.buyHorse = 0
    msg.enter.enterOnCreate = 1
    
    msg.maxPeople = 6
    if msg.peopleSelect == 2 then
        msg.maxPeople = 8
    elseif msg.peopleSelect == 3 then
        msg.maxPeople = 10
    end

    if key == 'zqOption' then
        msg.qzMax = 1
    end

    msg.deskMode = 'nn'

    msg.scoreOption = {
        choushui = tonumber(self.choushuiEditBox:getText()),
        join = tonumber(self.joinEditBox:getText()),
        qiang = tonumber(self.qiangEditBox:getText()),
        tui = tonumber(self.tuiEditBox:getText()),
        rule = self.winner or 1,
    }

    dump(msg)

    return msg
end

function CreateRoomView:showWaiting()
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

function CreateRoomView:delShowWaiting()
    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
        self.schedulerID = nil
        if self.waitingView then
            ShowWaiting.delete()
            self.waitingView = false
        end
    end
end

function CreateRoomView:onExit()
    self:delShowWaiting()
end

function CreateRoomView:startCsdAnimation( node, csbName, isRepeat, timeSpeed)
    local action = cc.CSLoader:createTimeline("views/createroom/"..csbName..".csb")
    action:gotoFrameAndPlay(0,isRepeat)
    if timeSpeed then
    action:setTimeSpeed(timeSpeed)
    end
    node:stopAllActions()
    node:runAction(action)
end

function CreateRoomView:startallAction()
    -- for i,v in pairs(tabs) do
    --     self:startCsdAnimation(self.bg:getChildByName(i):getChildByName("active"):getChildByName("blinkingBoxNode"),"blinkingBoxAnimation",true,1.3)
    -- end

    -- self:startCsdAnimation(self.bg:getChildByName("flashBoxNode"),"flashBoxAnimation",true,0.8)  
end

function CreateRoomView:setShowList()
    self.isShow = not self.isShow
    if self.isShow then
        local tabsModule = self.tabs:clone()
        self.typeList:insertCustomItem(tabsModule, 1)
    else
        self.typeList:removeItem(1)
    end
end

return CreateRoomView