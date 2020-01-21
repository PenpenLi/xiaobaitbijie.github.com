local SoundMng = require('app.helpers.SoundMng')
local ShowWaiting = require('app.helpers.ShowWaiting')
local tools = require('app.helpers.tools')
local ZJHGameLogic = require('app.libs.zhajinhua.ZJHGameLogic')

local CreateRoomZJHView = {}
local LocalSettings = require('app.models.LocalSettings')
local roomType = {
    ['zjhOption'] = 1,
}
local typeOptions = {
    ['base'] = 1,
    ['round'] = 2,
    ['roomPrice'] = 3,
    ['startMode'] = 4,
    ['peopleSelect'] = 5,
    ['advanced'] = 6,
    ['compareRound'] = 7,
    ['putScoreRound'] = 8,
    ['blindRound'] = 9,
    ['putScoreLimit'] = 10,
    ['abandonTime'] = 11,
    ['sameCard'] = 12,
    ['tonghua'] = 13,
    ['baozi'] = 14,
}
local tabs = {
    ['zjh'] = 1, -- 扎金花
}

local BASE = {
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

local ABANDONTIME = {
    [1] = 10 * 1000,
    [2] = 15 * 1000,
    [3] = 30 * 1000,
    [4] = 60 * 1000,
    [5] = 90 * 1000,
    [6] = 120 * 1000,
}

local costList = {
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

local scoreOption = {
    choushui = 10,
    join = 400,
    qiang = 400,
    tui = 400,
}

local setVersion = 5

function CreateRoomZJHView:initialize()
    self:enableNodeEvents()
    self.options = {}
    self.paymode = 1
    local setPath = cc.FileUtils:getInstance():getWritablePath() .. '.CreateRoomConfig'

    if io.exists(setPath) then
        local ver = LocalSettings:getRoomZJHConfig('setVersion')
        if (not ver) or ver < setVersion then
            cc.FileUtils:getInstance():removeFile(setPath)
        end
    end

    print("getincreateroom")

    self.options['zjhOption'] = { msg = {
        ['gameplay'] = 1, ['base'] = 1, ['round'] = 1, ['roomPrice'] = 1,
        ['special'] = {1, 2, 3, 4, 5, 6},
        ['advanced'] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
        ['startMode'] = 1, ['peopleSelect'] = 1,

        ['compareRound'] = 1, ['putScoreRound'] = 1, ['blindRound'] = 1,
        ['putScoreLimit'] = 1, ['abandonTime'] = 1, ['sameCard'] = 1,
        ['tonghua'] = 1, ['baozi'] = 1,
    } }

    if not io.exists(cc.FileUtils:getInstance():getWritablePath() .. '.CreateRoomConfig') then

        print(LocalSettings:getRoomZJHConfig('zjhOptionbase'))

        for i, v in pairs(roomType) do
            for j, n in pairs(typeOptions) do
                LocalSettings:setRoomZJHConfig(i .. j, self.options[i]['msg'][j])
            end
        end

        LocalSettings:setRoomZJHConfig('setVersion', setVersion)

    else
        print(" LocalSettings:getRoomZJHConfig(v..n) is not == nil")
    end

    local MainPanel = self.ui:getChildByName('MainPanel')
    local bg = MainPanel:getChildByName('bg')
    self.bg = bg

    for i, v in pairs(roomType) do
        for j, n in pairs(typeOptions) do
            local data = LocalSettings:getRoomZJHConfig(i .. j)
            if data then
                self.options[i]['msg'][j] = data
            end
        end
    end

    self:freshAllItem()
end

function CreateRoomZJHView:freshAllItem()

    if LocalSettings:getRoomZJHConfig("gameplay") then
        self.focus = LocalSettings:getRoomZJHConfig("gameplay")
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
    local option = bg:getChildByName(option_type)
    for j, n in pairs(typeOptions) do
        local data = LocalSettings:getRoomZJHConfig(option_type .. j)
        if data then
            local sender = nil
            if j == 'advanced' then
                sender = nil
            elseif j == 'base' or j == 'round' or j == 'startMode' then
                sender = nil
            else
                sender = option:getChildByName(j):getChildByName(tostring(data))
            end
            local fun = 'fresh' .. j
            if self[fun] then
                self[fun](self, data, sender)
            end
        end
    end
end

--------------------------------------------------------------------------------------------
--左边选择模式点击事件
function CreateRoomZJHView:freshTab(data)
    for i, v in pairs(tabs) do
        local currentItem = self.bg:getChildByName('tab'):getChildByName(i)
        local currentOpt = self.bg:getChildByName(i .. 'Option')
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
    LocalSettings:setRoomZJHConfig("gameplay", self.focus)
    self:freshAllItem()

    local app = require("app.App"):instance()
    app.session.room:setCurrentType(self.focus)
end

--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
--刷新左边模式是否已配
function CreateRoomZJHView:freshHasSave(data)
    for i, v in pairs(tabs) do
        local currentItem = self.bg:getChildByName('tab'):getChildByName(i)
        local hassaveImage = currentItem:getChildByName('Image')
        if data[v] == 1 then
            hassaveImage:setVisible(true)
        else
            hassaveImage:setVisible(false)
        end
    end
    -- LocalSettings:setRoomZJHConfig("gameplay", self.focus)
end

--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
--各个模式的刷新界面逻辑
function CreateRoomZJHView:freshbase(data, sender)
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName(option_type)
    local item = option:getChildByName('base')

    local current_value = self.options[option_type]['msg']['base']
    if sender then
        current_value = (current_value + (tonumber(data) == 0 and -1 or 1) - 1) % 6 + 1
    end
    item:getChildByName('text'):setString(ZJHGameLogic.getBaseOrder(current_value))

    local putScoreLimit = self.options[option_type]['msg']['putScoreLimit']
    if putScoreLimit == 1 and current_value == 6 then
        self.options[option_type]['msg']['putScoreLimit'] = 2
        self:freshputScoreLimit()
    end

    self.options[option_type]['msg']['base'] = current_value
    LocalSettings:setRoomZJHConfig(option_type .. item:getName(), current_value)

    local info = {
        option = option_type,
        item = 'base',
        num = 6,
    }

    -- self:freshTextColor(info)
end

function CreateRoomZJHView:freshround(data, sender)
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName(option_type)
    local item = option:getChildByName('round')

    local current_value = self.options[option_type]['msg']['round']
    if sender then
        current_value = (current_value + (tonumber(data) == 0 and -1 or 1) - 1) % 3 + 1
    end
    item:getChildByName('text'):setString(ROUND[current_value] .. '局')

    self.options[option_type]['msg']['round'] = current_value
    LocalSettings:setRoomZJHConfig(option_type .. item:getName(), current_value)

    local peopleSelect = self.options[option_type]['msg']['peopleSelect']
    local str = 'Option' .. current_value .. peopleSelect
    --根据局数更改房卡数值
    if self.paymode == 1 then
        if current_value == 1 then
            option:getChildByName('roomPrice'):getChildByName('1'):getChildByName('Text'):setString('房主支付(      ' .. costList[str] .. ')')
            option:getChildByName('roomPrice'):getChildByName('2'):getChildByName('Text'):setString('AA支付(每人      1)')
        end
        if current_value == 2 then
            option:getChildByName('roomPrice'):getChildByName('1'):getChildByName('Text'):setString('房主支付(      ' .. costList[str] .. ')')
            option:getChildByName('roomPrice'):getChildByName('2'):getChildByName('Text'):setString('AA支付(每人      2)')
        end
        if current_value == 3 then
            option:getChildByName('roomPrice'):getChildByName('1'):getChildByName('Text'):setString('房主支付(      ' .. costList[str] .. ')')
            option:getChildByName('roomPrice'):getChildByName('2'):getChildByName('Text'):setString('AA支付(每人      3)')
        end
    elseif self.paymode == 2 then
        current_value = self:freshGroupCreateRoomview()
        if current_value == 1 then
            option:getChildByName('roomPrice'):getChildByName('paymode'):getChildByName('Text1'):setString('（      ' .. costList[str] .. '）俱乐部管理员已设置从俱乐部基金中扣除，无需你支付')
        end
        if current_value == 2 then
            option:getChildByName('roomPrice'):getChildByName('paymode'):getChildByName('Text1'):setString('（      ' .. costList[str] .. '）俱乐部管理员已设置从俱乐部基金中扣除，无需你支付')
        end
        if current_value == 3 then
            option:getChildByName('roomPrice'):getChildByName('paymode'):getChildByName('Text1'):setString('（      ' .. costList[str] .. '）俱乐部管理员已设置从俱乐部基金中扣除，无需你支付')
        end
    end

    local info = {
        option = option_type,
        item = 'round',
        num = 3,
    }

    -- self:freshTextColor(info)
end

function CreateRoomZJHView:freshpeopleSelect(data, sender)
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName(option_type)
    local item = option:getChildByName('peopleSelect')

    local current_value = self.options[option_type]['msg']['peopleSelect']
    if sender then
        current_value = (current_value + (tonumber(data) == 0 and -1 or 1) - 1) % 3 + 1
    end
    item:getChildByName('text'):setString(ZJHGameLogic.getPeopleSelectOrder(current_value))

    self.options[option_type]['msg']['peopleSelect'] = current_value
    LocalSettings:setRoomZJHConfig(option_type .. item:getName(), current_value)

    local round = self.options[option_type]['msg']['round']
    local str = 'Option' .. round .. current_value
    --根据局数更改房卡数值
    if self.paymode == 1 then
        if current_value == 1 then
            option:getChildByName('roomPrice'):getChildByName('1'):getChildByName('Text'):setString('房主支付(      ' .. costList[str] .. ')')
            -- option:getChildByName('roomPrice'):getChildByName('2'):getChildByName('Text'):setString('AA支付(每人      1)')
        end
        if current_value == 2 then
            option:getChildByName('roomPrice'):getChildByName('1'):getChildByName('Text'):setString('房主支付(      ' .. costList[str] .. ')')
            -- option:getChildByName('roomPrice'):getChildByName('2'):getChildByName('Text'):setString('AA支付(每人      2)')
        end
        if current_value == 3 then
            option:getChildByName('roomPrice'):getChildByName('1'):getChildByName('Text'):setString('房主支付(      ' .. costList[str] .. ')')
            -- option:getChildByName('roomPrice'):getChildByName('2'):getChildByName('Text'):setString('AA支付(每人      3)')
        end
    elseif self.paymode == 2 then
        current_value = self:freshGroupCreateRoomview()
        if current_value == 1 then
            option:getChildByName('roomPrice'):getChildByName('paymode'):getChildByName('Text1'):setString('（      ' .. costList[str] .. '）俱乐部管理员已设置从俱乐部基金中扣除，无需你支付')
        end
        if current_value == 2 then
            option:getChildByName('roomPrice'):getChildByName('paymode'):getChildByName('Text1'):setString('（      ' .. costList[str] .. '）俱乐部管理员已设置从俱乐部基金中扣除，无需你支付')
        end
        if current_value == 3 then
            option:getChildByName('roomPrice'):getChildByName('paymode'):getChildByName('Text1'):setString('（      ' .. costList[str] .. '）俱乐部管理员已设置从俱乐部基金中扣除，无需你支付')
        end
    end

    local info = {
        option = option_type,
        item = 'peopleSelect',
        num = 3,
    }

    -- self:freshTextColor(info)
end

function CreateRoomZJHView:freshroomPrice(data, sender)
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName(option_type)
    local item = option:getChildByName('roomPrice')

    item:getChildByName('1'):getChildByName('select'):setVisible(false)
    item:getChildByName('2'):getChildByName('select'):setVisible(false)
    item:getChildByName('paymode'):setVisible(false)
    sender:getChildByName('select'):setVisible(true)

    self.options[option_type]['msg']['roomPrice'] = tonumber(data)
    LocalSettings:setRoomZJHConfig(option_type .. item:getName(), tonumber(data))

    local info = {
        option = option_type,
        item = 'roomPrice',
        num = 2,
    }

    self:freshTextColor(info)
end

function CreateRoomZJHView:freshadvanced(data, sender)
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName(option_type)
    local item = option:getChildByName('advanced')
    self.specialselect = 0

    for i = 1, 12 do
        item:getChildByName('opt'):getChildByName('' .. i):getChildByName('select'):setVisible(false)
    end

    for i = 1, #data do
        if data[i] == i then
            item:getChildByName('opt'):getChildByName(tostring(i)):getChildByName('select'):setVisible(true)
            self.specialselect = self.specialselect + 1
        end
    end
    if self.specialselect == 12 then
        item:getChildByName('opt'):getChildByName(tostring('0')):getChildByName('select'):setVisible(true)
        -- item:getChildByName('sel'):getChildByName('Text'):setString("全部勾选")
    else
        item:getChildByName('opt'):getChildByName(tostring('0')):getChildByName('select'):setVisible(false)
        -- item:getChildByName('sel'):getChildByName('Text'):setString("部分勾选")
    end
    item:getChildByName('sel'):getChildByName('Text'):setString(ZJHGameLogic.getAdvanceText({ advanced = data }))

    self.options[option_type]['msg']['advanced'] = data
    LocalSettings:setRoomZJHConfig(option_type .. item:getName(), self.options[option_type]['msg']['advanced'])

    local info = {
        option = option_type,
        item = 'advanced',
    }

    self:freshmulTextColor(info)
end

function CreateRoomZJHView:freshadvancednow(data, sender)
    local data = tonumber(data)
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName(option_type)
    local item = option:getChildByName('advanced')
    local flag = sender:getChildByName('select'):isVisible()

    sender:getChildByName('select'):setVisible(not flag)

    if data == 0 then
        if flag then
            self:freshadvanced({ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
        else
            self:freshadvanced({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 })
        end
        return
    end

    local specialselect = self.options[option_type]['msg']['advanced']
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

    if specialselectnum == 12 then
        item:getChildByName('opt'):getChildByName(tostring('0')):getChildByName('select'):setVisible(true)
        -- item:getChildByName('sel'):getChildByName('Text'):setString("全部勾选")
    else
        item:getChildByName('opt'):getChildByName(tostring('0')):getChildByName('select'):setVisible(false)
        -- item:getChildByName('sel'):getChildByName('Text'):setString("部分勾选")
    end
    self.options[option_type]['msg']['advanced'][data] = flag and 0 or data
    item:getChildByName('sel'):getChildByName('Text'):setString(ZJHGameLogic.getAdvanceText({ advanced = self.options[option_type]['msg']['advanced'] }))

    LocalSettings:setRoomZJHConfig(option_type .. item:getName(), self.options[option_type]['msg']['advanced'])

    local info = {
        option = option_type,
        item = 'advanced',
    }

    self:freshmulTextColor(info)
end

function CreateRoomZJHView:freshstartMode(data, sender)
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName(option_type)
    local item = option:getChildByName('startMode')

    local current_value = self.options[option_type]['msg']['startMode']
    if sender then
        current_value = (current_value + (tonumber(data) == 0 and -1 or 1) - 1) % 4 + 1
    end
    local peopleSelect = self.options[option_type]['msg']['peopleSelect']
    item:getChildByName('text'):setString(ZJHGameLogic.getStartModeOrder(current_value, peopleSelect))

    self.options[option_type]['msg']['startMode'] = current_value
    LocalSettings:setRoomZJHConfig(option_type .. item:getName(), current_value)

    local info = {
        option = option_type,
        item = 'startMode',
        num = 4,
    }

    -- self:freshTextColor(info)
end

function CreateRoomZJHView:freshcompareRound(data, sender)
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName(option_type)
    local item = option:getChildByName('compareRound')

    local current_value = self.options[option_type]['msg']['compareRound']
    if sender then
        current_value = (current_value + (tonumber(data) == 0 and -1 or 1) - 1) % 4 + 1
    end
    item:getChildByName('text'):setString(ZJHGameLogic.getCompareRoundOrder(current_value))

    self.options[option_type]['msg']['compareRound'] = current_value
    LocalSettings:setRoomZJHConfig(option_type .. item:getName(), current_value)

    local info = {
        option = option_type,
        item = 'compareRound',
        num = 4,
    }

    -- self:freshTextColor(info)
end

function CreateRoomZJHView:freshputScoreRound(data, sender)
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName(option_type)
    local item = option:getChildByName('putScoreRound')

    local current_value = self.options[option_type]['msg']['putScoreRound']
    if sender then
        current_value = (current_value + (tonumber(data) == 0 and -1 or 1) - 1) % 3 + 1
    end
    item:getChildByName('text'):setString(ZJHGameLogic.getPutScoreRoundOrder(current_value))

    self.options[option_type]['msg']['putScoreRound'] = current_value
    LocalSettings:setRoomZJHConfig(option_type .. item:getName(), current_value)

    local info = {
        option = option_type,
        item = 'putScoreRound',
        num = 3,
    }

    -- self:freshTextColor(info)
end

function CreateRoomZJHView:freshblindRound(data, sender)
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName(option_type)
    local item = option:getChildByName('blindRound')

    local current_value = self.options[option_type]['msg']['blindRound']
    if sender then
        current_value = (current_value + (tonumber(data) == 0 and -1 or 1) - 1) % 9 + 1
    end
    item:getChildByName('text'):setString(ZJHGameLogic.getBlindRoundOrder(current_value))

    self.options[option_type]['msg']['blindRound'] = current_value
    LocalSettings:setRoomZJHConfig(option_type .. item:getName(), current_value)

    local info = {
        option = option_type,
        item = 'blindRound',
        num = 9,
    }

    -- self:freshTextColor(info)
end

function CreateRoomZJHView:freshputScoreLimit(data, sender)
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName(option_type)
    local item = option:getChildByName('putScoreLimit')

    local current_value = self.options[option_type]['msg']['putScoreLimit']
    local base = self.options[option_type]['msg']['base']
    if sender then
        current_value = (current_value + (tonumber(data) == 0 and -1 or 1) - 1) % 4 + 1
    end
    if base == 6 and current_value == 1 then
        current_value = tonumber(data) == 0 and 4 or 2
    end
    item:getChildByName('text'):setString(ZJHGameLogic.getPutScoreLimitOrder(current_value))

    self.options[option_type]['msg']['putScoreLimit'] = current_value
    LocalSettings:setRoomZJHConfig(option_type .. item:getName(), current_value)

    local info = {
        option = option_type,
        item = 'putScoreLimit',
        num = 4,
    }

    -- self:freshTextColor(info)
end

function CreateRoomZJHView:freshabandonTime(data, sender)
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName(option_type)
    local item = option:getChildByName('abandonTime')

    local current_value = self.options[option_type]['msg']['abandonTime']
    if sender then
        current_value = (current_value + (tonumber(data) == 0 and -1 or 1) - 1) % 6 + 1
    end
    item:getChildByName('text'):setString(ZJHGameLogic.getAbandonTimeOrder(current_value))

    self.options[option_type]['msg']['abandonTime'] = current_value
    LocalSettings:setRoomZJHConfig(option_type .. item:getName(), current_value)

    local info = {
        option = option_type,
        item = 'abandonTime',
        num = 6,
    }

    -- self:freshTextColor(info)
end

function CreateRoomZJHView:freshsameCard(data, sender)
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName(option_type)
    local item = option:getChildByName('sameCard')

    local current_value = self.options[option_type]['msg']['sameCard']
    if sender then
        current_value = (current_value + (tonumber(data) == 0 and -1 or 1) - 1) % 2 + 1
    end
    item:getChildByName('text'):setString(ZJHGameLogic.getSameCardOrder(current_value))

    self.options[option_type]['msg']['sameCard'] = current_value
    LocalSettings:setRoomZJHConfig(option_type .. item:getName(), current_value)

    local info = {
        option = option_type,
        item = 'sameCard',
        num = 2,
    }

    -- self:freshTextColor(info)
end

function CreateRoomZJHView:freshtonghua(data, sender)
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName(option_type)
    local item = option:getChildByName('tonghua')

    local current_value = self.options[option_type]['msg']['tonghua']
    if sender then
        current_value = (current_value + (tonumber(data) == 0 and -1 or 1) - 1) % 5 + 1
    end
    item:getChildByName('text'):setString(ZJHGameLogic.getTonghuaOrder(current_value))

    self.options[option_type]['msg']['tonghua'] = current_value
    LocalSettings:setRoomZJHConfig(option_type .. item:getName(), current_value)

    local info = {
        option = option_type,
        item = 'tonghua',
        num = 5,
    }

    -- self:freshTextColor(info)
end

function CreateRoomZJHView:freshbaozi(data, sender)
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName(option_type)
    local item = option:getChildByName('baozi')

    local current_value = self.options[option_type]['msg']['baozi']
    if sender then
        current_value = (current_value + (tonumber(data) == 0 and -1 or 1) - 1) % 5 + 1
    end
    item:getChildByName('text'):setString(ZJHGameLogic.getBaoziOrder(current_value))

    self.options[option_type]['msg']['baozi'] = current_value
    LocalSettings:setRoomZJHConfig(option_type .. item:getName(), current_value)

    local info = {
        option = option_type,
        item = 'baozi',
        num = 5,
    }

    -- self:freshTextColor(info)
end

function CreateRoomZJHView:freshchoushui()
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

function CreateRoomZJHView:editboxHandle(eventname, sender)
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

function CreateRoomZJHView:freshWinner(data,sender)
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName(option_type)
    local item = option:getChildByName('choushui')

    item:getChildByName('opt'):getChildByName('1'):getChildByName('select'):setVisible(false)
    item:getChildByName('opt'):getChildByName('2'):getChildByName('select'):setVisible(false)
    sender:getChildByName('select'):setVisible(true)
    self.winner = tonumber(data)

end

---------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
--刷新字体颜色
function CreateRoomZJHView:freshmulTextColor(data)
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName(option_type)
    local item = option:getChildByName(data.item)
    if data.item == 'advanced' then
        item = item:getChildByName('opt')
    end
    local selectdata = self.options[data.option]['msg'][data.item]

    for i = 1, #selectdata do
        if selectdata[i] ~= 0 then
            item:getChildByName(tostring(i)):getChildByName('Text'):setColor(cc.c3b(255, 255, 255))
            item:getChildByName(tostring(i)):getChildByName('Text'):setColor(cc.c3b(246, 185, 254))
        else
            item:getChildByName(tostring(i)):getChildByName('Text'):setColor(cc.c3b(255, 255, 255))
            item:getChildByName(tostring(i)):getChildByName('Text'):setColor(cc.c3b(184, 199, 254))
        end
    end
end

function CreateRoomZJHView:freshTextColor(data)
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName(option_type)
    local item = option:getChildByName(data.item)
    if data.item == 'multiply' or data.item == 'special' then
        item = item:getChildByName('opt')
    end
    local selectdata = self.options[data.option]['msg'][data.item]

    for i = 1, data.num do
        if i == selectdata then
            item:getChildByName(tostring(i)):getChildByName('Text'):setColor(cc.c3b(255, 255, 255))
            item:getChildByName(tostring(i)):getChildByName('Text'):setColor(cc.c3b(246, 185, 254))
        else
            item:getChildByName(tostring(i)):getChildByName('Text'):setColor(cc.c3b(255, 255, 255))
            item:getChildByName(tostring(i)):getChildByName('Text'):setColor(cc.c3b(184, 199, 254))
        end
    end
end
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
--三个问号提示的点击事件
function CreateRoomZJHView:freshPriceLayer(bShow)
    self.bg:getChildByName('priceLayer'):setVisible(bShow)
end

function CreateRoomZJHView:freshTuiZhuLayer(bShow)
    self.bg:getChildByName('tuizhuLayer'):setVisible(bShow)
end

function CreateRoomZJHView:freshXiaZhuLayer(bShow)
    self.bg:getChildByName('xiazhuLayer'):setVisible(bShow)
end

function CreateRoomZJHView:freshquickLayer(bShow)
    self.bg:getChildByName('quickLayer'):setVisible(bShow)
end

function CreateRoomZJHView:freshWangLaiLayer(bShow, data)
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
function CreateRoomZJHView:freshAdvancedLayer(bShow, data)
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName(option_type)
    option:getChildByName('advanced'):getChildByName('opt'):setVisible(bShow)
    local path = 'res/views/createroom/' .. data.direction .. '.png'
    local bg = option:getChildByName('advanced'):getChildByName('sel'):getChildByName('bg')
    bg:getChildByName('down'):loadTexture(path)
end

function CreateRoomZJHView:freshChoushuiLayer(bShow,data) 
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName(option_type) 
    option:getChildByName('choushui'):getChildByName('opt'):setVisible(bShow)
    local path = 'res/views/createroom/' .. data.direction ..'.png'
    local bg = option:getChildByName('choushui'):getChildByName('sel'):getChildByName('bg')
    bg:getChildByName('down'):loadTexture(path)
end

------------------------------------------------------------------------------------------
function CreateRoomZJHView:freshGroupCreateRoomview()
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName(option_type)
    local opView = option:getChildByName('roomPrice')
    opView:getChildByName('1'):getChildByName('select'):setVisible(false)
    opView:getChildByName('2'):getChildByName('select'):setVisible(false)
    opView:getChildByName('paymode'):setVisible(true)
    opView:getChildByName('1'):setVisible(false)
    opView:getChildByName('2'):setVisible(false)
    opView:getChildByName('dm1'):setVisible(false)
    opView:getChildByName('dm2'):setVisible(false)
    opView:getChildByName('why'):setVisible(false)
    local round = LocalSettings:getRoomZJHConfig(option_type .. 'round')
    return round
end

function CreateRoomZJHView:layout(isGroup, createmode, paymode)
    local MainPanel = self.ui:getChildByName('MainPanel')
    MainPanel:setContentSize(cc.size(display.width, display.height))
    MainPanel:setPosition(display.cx, display.cy)
    self.MainPanel = MainPanel

    local bg = MainPanel:getChildByName('bg')
    bg:setPosition(display.cx, display.cy)
    self.bg = bg
    self.isgroup = isGroup
    self.paymode = paymode
    self.typeList = bg:getChildByName('typelist')
    self.tabs = bg:getChildByName('tab')
    self.choushuiLayer = bg:getChildByName('zjhOption'):getChildByName('choushui')
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
            -- self:startCsdAnimation(self.bg:getChildByName('quickstart'):getChildByName("PurpleNode"), "PurpleAnimation", true, 0.8)
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

    if LocalSettings:getRoomZJHConfig("gameplay") then
        self.focus = LocalSettings:getRoomZJHConfig("gameplay")
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

function CreateRoomZJHView:getOptions()
    SoundMng.playEft('room_dingding.mp3')
    local key = self.focus .. 'Option'
    local savedata = self.options[key].msg
    local msg = clone(savedata)

    if key == 'tbOption' then
        msg.base = tostring(msg.base)
    else
        msg.base = BASE[msg.base]
    end

    msg.cost = 1
    if msg.roomPrice == 1 then
        msg.cost = costList['Option' .. msg.round .. msg.peopleSelect]
    elseif msg.roomPrice == 2 then
        msg.cost = msg.round
    end

    msg.round = ROUND[msg.round]
    msg.abandonTime = ABANDONTIME[msg.abandonTime]

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

    msg.deskMode = 'zjh'

    msg.scoreOption = {
        choushui_zjh = tonumber(self.choushuiEditBox:getText()),
        join = tonumber(self.joinEditBox:getText()),
        qiang = scoreOption.qiang,
        tui = scoreOption.tui,
        rule = self.winner or 1,
    }

    dump(msg)

    return msg
end

function CreateRoomZJHView:showWaiting()
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

function CreateRoomZJHView:delShowWaiting()
    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
        self.schedulerID = nil
        if self.waitingView then
            ShowWaiting.delete()
            self.waitingView = false
        end
    end
end

function CreateRoomZJHView:onExit()
    self:delShowWaiting()
end

function CreateRoomZJHView:startCsdAnimation(node, csbName, isRepeat, timeSpeed)
    local action = cc.CSLoader:createTimeline("views/createroom/" .. csbName .. ".csb")
    action:gotoFrameAndPlay(0, isRepeat)
    if timeSpeed then
        action:setTimeSpeed(timeSpeed)
    end
    node:stopAllActions()
    node:runAction(action)
end

function CreateRoomZJHView:startallAction()
    -- for i,v in pairs(tabs) do
    --     self:startCsdAnimation(self.bg:getChildByName(i):getChildByName("active"):getChildByName("blinkingBoxNode"),"blinkingBoxAnimation",true,1.3)
    -- end
    -- self:startCsdAnimation(self.bg:getChildByName("flashBoxNode"),"flashBoxAnimation",true,0.8)  
end

return CreateRoomZJHView