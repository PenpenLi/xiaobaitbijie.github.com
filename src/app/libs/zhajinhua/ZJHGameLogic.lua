local ZJHGameLogic = {}

ZJHGameLogic.SPECIAL_LONG_TEXT = {
    BOOM = '豹子',
    SFLUSH = '顺金',
    TONGHUA = '金花',
    STRAIGHT = '顺子',
    PAIRS = '对子',
    GAOPAI = '单张',
}

ZJHGameLogic.SPECIAL_SHORT_TEXT = {
    BOOM = '豹子',
    SFLUSH = '顺金',
    TONGHUA = '金花',
    STRAIGHT = '顺子',
    PAIRS = '对子',
    GAOPAI = '单张',
}

ZJHGameLogic.SPECIAL_MUL_TEXT = {
    BOOM = '豹子(1倍)',
    SFLUSH = '顺金(1倍)',
    TONGHUA = '金花(1倍)',
    STRAIGHT = '顺子(1倍)',
    PAIRS = '对子(1倍)',
    GAOPAI = '单张(1倍)',
}

ZJHGameLogic.GAMEPLAY = {
    '扎金花',
}

ZJHGameLogic.STARTMODE = {
    '手动开始',
    '满4人开',
    '满5人开',
    '满6人开',
}

ZJHGameLogic.STARTMODE_BM = {
    '手动开始',
    '满6人开',
    '满7人开',
    '满8人开',
}

ZJHGameLogic.STARTMODE_SM = {
    '手动开始',
    '满8人开',
    '满9人开',
    '满10人开',
}

ZJHGameLogic.COMPAREROUND = {
    '无',
    '1轮',
    '2轮',
    '3轮',
}

ZJHGameLogic.PUTSCOREROUND = {
    '10轮封顶',
    '20轮封顶',
    '30轮封顶',
}

ZJHGameLogic.PUTSCORELIMIT = {
    '10注封顶',
    '20注封顶',
    '30注封顶',
    '60注封顶',
}

ZJHGameLogic.BLINDROUND = {
    '不闷牌',
    '必闷1轮',
    '必闷2轮',
    '必闷3轮',
    '必闷4轮',
    '必闷5轮',
    '必闷6轮',
    '必闷7轮',
    '必闷8轮',
}

ZJHGameLogic.ABANDONTIME = {
    '10秒弃牌',
    '15秒弃牌',
    '30秒弃牌',
    '60秒弃牌',
    '90秒弃牌',
    '120秒弃牌',
}

ZJHGameLogic.SAMECARD = {
    '先比为输',
    '按花色比',
}

ZJHGameLogic.TONGHUATEXT = {
    '不收同花喜钱',
    '同花顺5分',
    '同花顺10分',
    '同花顺15分',
    '同花顺30分',
}

ZJHGameLogic.BAOZITEXT = {
    '不收豹子喜钱',
    '豹子10分',
    '豹子20分',
    '豹子30分',
    '豹子50分',
}

ZJHGameLogic.ADVANCEDTEXT = {
    '快速模式',
    '中途禁入',
    '禁止搓牌',
    '禁用道具',
    '禁止语音',
    'A23>JQK',
    '比牌双倍分',
    '235吃豹子',
    '按序看牌',
    '顺子大金花',
    '结束自动亮牌',
    '防作弊',
}

ZJHGameLogic.PEPLESELECT_TEXT = {
    '6人',
    '8人',
    '10人',
}

ZJHGameLogic.BASE = {
    ['1'] = '1',
    ['2'] = '2',
    ['3'] = '3',
    ['4'] = '4',
    ['5'] = '5',
    ['10'] = '10',
}

ZJHGameLogic.BASEORDER = {
    [1] = '1',
    [2] = '2',
    [3] = '3',
    [4] = '4',
    [5] = '5',
    [6] = '10',
}

ZJHGameLogic.BASEINFO = {
    ['1'] = { 1 },
    ['2'] = { 2 },
    ['3'] = { 3 },
    ['4'] = { 4 },
    ['5'] = { 5 },
    ['10'] = { 10 },
}

ZJHGameLogic.SPECIAL_EMUN = {
    BOOM = 6,
    SFLUSH = 5,
    TONGHUA = 4,
    STRAIGHT = 3,
    PAIRS = 2,
    GAOPAI = 1,
}

ZJHGameLogic.CLIENT_SETTING = {
    BOOM = 6,
    SFLUSH = 5,
    TONGHUA = 4,
    STRAIGHT = 3,
    PAIRS = 2,
    GAOPAI = 1,
}

ZJHGameLogic.SPECIAL_MULNUM = {
    BOOM = 1,
    SFLUSH = 1,
    TONGHUA = 1,
    STRAIGHT = 1,
    PAIRS = 1,
    GAOPAI = 1,
}

ZJHGameLogic.CARDS_LOGICE_VALUE = {
    ['A'] = 13, ['2'] = 1, ['3'] = 2, ['4'] = 3, ['5'] = 4,
    ['6'] = 5, ['7'] = 6, ['8'] = 7, ['9'] = 8,
    ['T'] = 9, ['J'] = 10, ['Q'] = 11, ['K'] = 12,
    -- ['☆'] = 14, ['★'] = 15,
}

ZJHGameLogic.HEX_CARDS_DATA = {
    ['♠A'] = 81, ['♠2'] = 82, ['♠3'] = 83, ['♠4'] = 84, ['♠5'] = 85,
    ['♠6'] = 86, ['♠7'] = 87, ['♠8'] = 88, ['♠9'] = 89,
    ['♠T'] = 90, ['♠J'] = 91, ['♠Q'] = 92, ['♠K'] = 93,

    ['♥A'] = 65, ['♥2'] = 66, ['♥3'] = 67, ['♥4'] = 68, ['♥5'] = 69,
    ['♥6'] = 70, ['♥7'] = 71, ['♥8'] = 72, ['♥9'] = 73,
    ['♥T'] = 74, ['♥J'] = 75, ['♥Q'] = 76, ['♥K'] = 77,

    ['♣A'] = 49, ['♣2'] = 50, ['♣3'] = 51, ['♣4'] = 52, ['♣5'] = 53,
    ['♣6'] = 54, ['♣7'] = 55, ['♣8'] = 56, ['♣9'] = 57,
    ['♣T'] = 58, ['♣J'] = 59, ['♣Q'] = 60, ['♣K'] = 61,

    ['♦A'] = 33, ['♦2'] = 34, ['♦3'] = 35, ['♦4'] = 36, ['♦5'] = 37,
    ['♦6'] = 38, ['♦7'] = 39, ['♦8'] = 40, ['♦9'] = 41,
    ['♦T'] = 42, ['♦J'] = 43, ['♦Q'] = 44, ['♦K'] = 45,

    ['★A'] = 17, ['★2'] = 18, ['★3'] = 19, ['★4'] = 20, ['★5'] = 21,
    ['★6'] = 22, ['★7'] = 23, ['★8'] = 24, ['★9'] = 25,
    ['★T'] = 26, ['★J'] = 27, ['★Q'] = 28, ['★K'] = 29,

    ['☆A'] = 1, ['☆2'] = 2, ['☆3'] = 3, ['☆4'] = 4, ['☆5'] = 5,
    ['☆6'] = 6, ['☆7'] = 7, ['☆8'] = 8, ['☆9'] = 9,
    ['☆T'] = 10, ['☆J'] = 11, ['☆Q'] = 12, ['☆K'] = 13,

    ['☆'] = 97, ['★'] = 98
}

local SUIT_UTF8_LENGTH = 3

local function card_suit(c)
    if not c then print(debug.traceback()) end
    if c == '☆' or c == '★' then
        return c
    else
        return #c > SUIT_UTF8_LENGTH and c:sub(1, SUIT_UTF8_LENGTH) or nil
    end
end

local function card_rank(c)
    if c == '☆' or c == '★' then
        return c
    else
        return #c > SUIT_UTF8_LENGTH and c:sub(SUIT_UTF8_LENGTH + 1, #c) or nil
    end
end

function ZJHGameLogic.card_rank_out(c)
    return c:sub(1, SUIT_UTF8_LENGTH)
end

function ZJHGameLogic.transformCards(serverCardData)
    local retCards = {}
    table.insert(retCards, serverCardData[5])
    return retCards
end

function ZJHGameLogic.getSpecialTypeByVal(gameplay, spVal)
    local tabEmun = ZJHGameLogic.SPECIAL_EMUN
    if spVal and spVal > 0 then
        for key, val in pairs(tabEmun) do
            if val == spVal then
                return key
            end
        end
    end
end

function ZJHGameLogic.getSpecialType(cards, gameplay, setting, advanced, laizinum, niucnt)

    -- 分析撲克
    local value = ZJHGameLogic.CARDS_LOGICE_VALUE

    local tabHandSort = {}
    local tabHandVal = {} -- 牌值数组(K = 13 Q = 12 J = 11)
    local tabHandSuit = {}

    local isTONGHUA = true

    local prevCard = {-1, "" }

    for k, v in pairs(cards) do
        local cardVal = value[card_rank(v)]
        local cardSuit = card_suit(v)
        --{ [1]=val, [2]=suit}
        table.insert(tabHandSort, { cardVal, cardSuit })
        if cardVal < 14 then
            if prevCard[2] ~= "" and prevCard[2] ~= cardSuit then
                isTONGHUA = false
            end
            prevCard = { cardVal, cardSuit }
        end
    end

    for k, v in pairs(tabHandSort) do
        table.insert(tabHandVal, v[1])
        table.insert(tabHandSuit, v[2])
    end

    local set = ZJHGameLogic.CLIENT_SETTING
    local spEmun = ZJHGameLogic.SPECIAL_EMUN

    -- 特殊牌逻辑
    -- 没有癞子-------------------------------------------------------------------------------
    local function isEnabled(type)
        if type > 0 then
            if setting[type] and setting[type] > 0 then
                return true
            end
        end
        return false
    end

    local function aSflush()
        -- 顺金(同花顺)
        local t = tabHandVal
        if t[1] == t[2] + 1 and
        t[2] == t[3] + 1 and
        isTONGHUA and
        isEnabled(set.SFLUSH)
        then
            return true, spEmun.SFLUSH
        elseif t[1] == 13 and t[2] == 2 and t[3] == 1 and
        isTONGHUA and
        isEnabled(set.SFLUSH)
        then
            return true, spEmun.SFLUSH
        end
    end

    local function aBoom()
        -- 豹子
        if (tabHandVal[1] == tabHandVal[2] and
        tabHandVal[2] == tabHandVal[3]) and
        isEnabled(set.BOOM)
        then
            return true, spEmun.BOOM
        end
    end

    local function aTongHua()
        -- 金花(同花)
        if isTONGHUA and
        isEnabled(set.TONGHUA)
        then
            return true, spEmun.TONGHUA
        end
    end

    local function aStraight()
        -- 顺子
        local t = tabHandVal
        if t[1] == t[2] + 1 and
        t[2] == t[3] + 1 and
        isEnabled(set.STRAIGHT)
        then
            return true, spEmun.STRAIGHT
        elseif t[1] == 13 and t[2] == 2 and t[3] == 1 and
        isEnabled(set.STRAIGHT)
        then
            return true, spEmun.STRAIGHT
        end
    end

    local function aPairs()
        -- 对子
        local t = tabHandVal
        if (t[1] == t[2] or t[2] == t[3]) and
        isEnabled(set.PAIRS)
        then
            return true, spEmun.PAIRS
        end
    end

    local function aGaopai()
        return true, spEmun.GAOPAI
    end

    -------------------------------------------------------------------------------
    -- 优先级
    local tabFunc = { aBoom, aSflush, aTongHua, aStraight, aPairs, aGaopai } -- 普通模式
    if advanced[10] and advanced[10] > 0 then
        tabFunc = { aBoom, aSflush, aStraight, aTongHua, aPairs, aGaopai } -- 普通模式
    end

    local type = 0
    for i, v in ipairs(tabFunc) do
        local bool, val = v()
        if bool then
            type = val
            break
        end
    end

    return type, ZJHGameLogic.getSpecialTypeByVal(gameplay, type)
end


function ZJHGameLogic.findNiuniuByData(cards, laizinum)
    return 0
end

function ZJHGameLogic.groupingCardData(cards, specialType, gameplay, wanglai)
    local retGroup = { cards, {} }

    local retCards = {}
    for groupIdx = 1, 2 do
        if retGroup[groupIdx] then
            for i1 = 1, #retGroup[groupIdx] do
                table.insert(retCards, retGroup[groupIdx][i1])
            end
        end
    end
    return retCards, retGroup
end

function ZJHGameLogic.getMul(gameplay, setting, niuCnt, specialType)
    setting = setting or 1

    if specialType and specialType > 0 then
        local type = ZJHGameLogic.getSpecialTypeByVal(gameplay, specialType)
        local mulTab = ZJHGameLogic.SPECIAL_MULNUM
        return mulTab[type]
    end

    if niuCnt then
        return 1
    end

end

function ZJHGameLogic.getSetting(gameplay, setNum)
    local tabSetting = ZJHGameLogic.CLIENT_SETTING
    for name, v in pairs(tabSetting) do
        if v > 0 and setNum and v == setNum then
            return name
        end
    end
end

-- 哈希表转数组
function ZJHGameLogic.hashCountsToArray(hash)
    local a = {}
    for k, v in pairs(hash) do
        for _ = 1, v do
            a[#a + 1] = k
        end
    end
    return a
end


-- mode: 1:五小牛。。。 | 2:五小  |  3:五小牛（8倍） 
function ZJHGameLogic.getSpecialText(deskInfo, mode, oneLine)
    mode = mode or 3

    local gameplay = deskInfo.gameplay
    local tabRule
    if mode == 1 then -- 长文本
        tabRule = ZJHGameLogic.SPECIAL_LONG_TEXT
    elseif mode == 2 then	-- 短文本
        tabRule = ZJHGameLogic.SPECIAL_SHORT_TEXT
    elseif mode == 3 then -- 带倍数
        tabRule = ZJHGameLogic.SPECIAL_MUL_TEXT
    else
        tabRule = ZJHGameLogic.SPECIAL_LONG_TEXT
    end

    local special = deskInfo.special
    local ruleText = ""
    local addCnt = 0
    for i, v in pairs(special) do
        if v > 0 then
            local spName = ZJHGameLogic.getSetting(gameplay, v)
            if spName then
                addCnt = addCnt + 1
                local r = addCnt == 3 and "\r" or ""
                if oneLine then r = '' end
                ruleText = ruleText .. ' ' .. tabRule[spName] .. r
            end
        end
    end

    return ruleText
end

-- 禁止搓牌 | 中途禁止加入 | 
function ZJHGameLogic.getAdvanceText(deskInfo)
    local setting = ZJHGameLogic.ADVANCEDTEXT;
    local retStr = ''
    for k, v in pairs(deskInfo.advanced) do
        if v > 0 then
            local text = setting[k] or ''
            retStr = retStr .. text .. ' '
        end
    end
    return retStr
end

-- 2/4 。。。
function ZJHGameLogic.getBaseText(deskInfo)
    local base = deskInfo.base
    return ZJHGameLogic.BASE[base] or base
end

function ZJHGameLogic.getBaseOrder(idx)
    return ZJHGameLogic.BASEORDER[idx]
end

--2/4——{2,4}
function ZJHGameLogic.getBaseInfoText(deskInfo)
    local base = deskInfo.base
    return ZJHGameLogic.BASEINFO[base]
end

-- 牛9X5 。。。
function ZJHGameLogic.getNiuNiuMulText(deskInfo, mode)
    return ''
end

-- 牛牛玩法
function ZJHGameLogic.getGameplayText(deskInfo)
    local idx = deskInfo.gameplay
    return ZJHGameLogic.GAMEPLAY[idx] or ''
end

-- 支付方式
function ZJHGameLogic.getPayModeText(deskInfo)
    local idx = deskInfo.roomPrice
    local payText = "房主"
    if idx == 1 then
        payText = "房主"
    else
        payText = "AA"
    end
    return payText
end

-- 比牌轮数
function ZJHGameLogic.getCompareRoundText(deskInfo)
    local idx = deskInfo.compareRound
    return ZJHGameLogic.COMPAREROUND[idx] or ''
end

function ZJHGameLogic.getCompareRoundOrder(idx)
    return ZJHGameLogic.COMPAREROUND[idx] or ''
end

function ZJHGameLogic.getCompareRound(deskInfo)
    local idx = deskInfo.compareRound
    return idx - 1
end

-- 人数
function ZJHGameLogic.getPeopleSelectOrder(idx)
    return ZJHGameLogic.PEPLESELECT_TEXT[idx] or ''
end

-- 压分回合
function ZJHGameLogic.getPutScoreRoundText(deskInfo)
    local idx = deskInfo.putScoreRound
    return ZJHGameLogic.PUTSCOREROUND[idx] or ''
end

function ZJHGameLogic.getPutScoreRoundOrder(idx)
    return ZJHGameLogic.PUTSCOREROUND[idx] or ''
end

--压分选项
function ZJHGameLogic.getPutScoreLimitText(deskInfo)
    local idx = deskInfo.putScoreLimit
    return ZJHGameLogic.PUTSCORELIMIT[idx] or ''
end

function ZJHGameLogic.getPutScoreLimitOrder(idx)
    return ZJHGameLogic.PUTSCORELIMIT[idx] or ''
end

-- 闷牌轮数
function ZJHGameLogic.getBlindRoundText(deskInfo)
    local idx = deskInfo.blindRound
    return ZJHGameLogic.BLINDROUND[idx] or ''
end

function ZJHGameLogic.getBlindRoundOrder(idx)
    return ZJHGameLogic.BLINDROUND[idx] or ''
end

function ZJHGameLogic.getBlindRound(deskInfo)
    local idx = deskInfo.blindRound
    return idx - 1
end

-- 弃牌时间
function ZJHGameLogic.getAbandonTimeText(deskInfo)
    local idx = deskInfo.abandonTime
    return ZJHGameLogic.ABANDONTIME[idx] or ''
end

function ZJHGameLogic.getAbandonTimeOrder(idx)
    return ZJHGameLogic.ABANDONTIME[idx] or ''
end

-- 同牌输赢
function ZJHGameLogic.getSameCardText(deskInfo)
    local idx = deskInfo.sameCard
    return ZJHGameLogic.SAMECARD[idx] or ''
end

function ZJHGameLogic.getSameCardOrder(idx)
    return ZJHGameLogic.SAMECARD[idx] or ''
end

-- 同花喜钱
function ZJHGameLogic.getTonghuaText(deskInfo)
    local idx = deskInfo.tonghua
    return ZJHGameLogic.TONGHUATEXT[idx] or ''
end

function ZJHGameLogic.getTonghuaOrder(idx)
    return ZJHGameLogic.TONGHUATEXT[idx] or ''
end

-- 豹子喜钱
function ZJHGameLogic.getBaoziText(deskInfo)
    local idx = deskInfo.baozi
    return ZJHGameLogic.BAOZITEXT[idx] or ''
end

function ZJHGameLogic.getBaoziOrder(idx)
    return ZJHGameLogic.BAOZITEXT[idx] or ''
end

-- 自动开始
function ZJHGameLogic.getStartModeText(deskInfo)
    local idx = deskInfo.startMode
    local str = ZJHGameLogic.STARTMODE
    if deskInfo.peopleSelect == 2 then
        str = ZJHGameLogic.STARTMODE_BM
    elseif deskInfo.peopleSelect == 3 then
        str = ZJHGameLogic.STARTMODE_SM
    end
    return str[idx] or ''
end

-- 自动开始
function ZJHGameLogic.getStartModeOrder(idx, peopleSelect)
    local mode = ZJHGameLogic.STARTMODE
    if peopleSelect == 2 then
        mode = ZJHGameLogic.STARTMODE_BM
    elseif peopleSelect == 3 then
        mode = ZJHGameLogic.STARTMODE_SM
    end
    return mode[idx] or ''
end

-- 房间限制
function ZJHGameLogic.getRoomLimitText(deskInfo)
    local text = '无'
    if deskInfo.roomMode == 'bisai' and deskInfo.scoreOption then
        local options = deskInfo.scoreOption
        text = '入场:' .. options.join .. '  抢庄:' .. options.qiang .. '  推注:' .. options.tui
        .. '  抽水:' .. options.choushui_zjh .. '%  ' .. (options.rule == 1 and '大赢家抽水' or '赢家抽水')
    end
    return text
end

function ZJHGameLogic.isQzGame(deskInfo)
    local idx = deskInfo.gameplay
    local tab = {
        [4] = 4,
        [7] = 7,
        [6] = 6,
        [8] = 8,
        [9] = 9,
    }
    return tab[idx] or false
end

function ZJHGameLogic.isSzGame(deskInfo)
    local idx = deskInfo.gameplay
    local tab = {
        [1] = 1,
        [2] = 2,
        [3] = 3,
        [5] = 5,
    }
    return tab[idx] or false
end

-- 房间规则
function ZJHGameLogic.getRoomRuleText(deskInfo)
    local roomRuleText = ""
    roomRuleText = ZJHGameLogic.getPayModeText(deskInfo) .. "支付"
    roomRuleText = roomRuleText .. " 比牌轮数:" .. ZJHGameLogic.getCompareRoundText(deskInfo)
    roomRuleText = roomRuleText .. " " .. ZJHGameLogic.getPutScoreRoundText(deskInfo)
    roomRuleText = roomRuleText .. " " .. ZJHGameLogic.getPutScoreLimitText(deskInfo)
    roomRuleText = roomRuleText .. " " .. ZJHGameLogic.getSameCardText(deskInfo)
    roomRuleText = roomRuleText .. " " .. ZJHGameLogic.getAbandonTimeText(deskInfo)
    roomRuleText = roomRuleText .. " 闷牌轮数:" .. ZJHGameLogic.getBlindRoundText(deskInfo)
    roomRuleText = roomRuleText .. " " .. ZJHGameLogic.getStartModeText(deskInfo)
    return roomRuleText
end

function ZJHGameLogic.isEnableCuoPai(deskInfo)
    if deskInfo.advanced and deskInfo.advanced[3] > 0 then
        return false
    end
    return true
end

function ZJHGameLogic.sortCards(cards)

    local value = ZJHGameLogic.CARDS_LOGICE_VALUE
    local cardcolor = ZJHGameLogic.HEX_CARDS_DATA
    local laizinum = 0

    for i, v in pairs(cards) do
        if value[card_rank(v)] > 13 then
            laizinum = laizinum + 1
        end
    end

    -- 按大到小排序
    table.sort(cards, function(a, b)
        local A = value[card_rank(a)]
        local B = value[card_rank(b)]

        if A > B then return true end
        if A < B then return false end
        if A == B then
            local C = cardcolor[a]
            local D = cardcolor[b]
            return (C > D)
        end

        return false
    end)
    return cards, laizinum
end

function ZJHGameLogic.getLocalCardType(cardsdata, gameplay, setting, advanced)
    local cards, laizinum = ZJHGameLogic.sortCards(cardsdata)
    local cnt = ZJHGameLogic.findNiuniuByData(cards, laizinum)
    cnt = cnt or 0
    local spType, spKey = ZJHGameLogic.getSpecialType(cards, gameplay, setting, advanced, laizinum, cnt)
    return cnt, spType, spKey
end

return ZJHGameLogic