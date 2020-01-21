local SGGameLogic = {}

SGGameLogic.SPECIAL_LONG_TEXT = {
    ZHIZUN = '至尊',
    DASG = '大三公',
    XIAOSG = '小三公',
    HUNSG = '混三公',
}

SGGameLogic.SPECIAL_SHORT_TEXT = {
    ZHIZUN = '至尊',
    DASG = '大三公',
    XIAOSG = '小三公',
    HUNSG = '混三公',
}

SGGameLogic.SPECIAL_MUL_TEXT1 = {
    ZHIZUN = '至尊(1倍)',
    DASG = '大三公(1倍)',
    XIAOSG = '小三公(1倍)',
    HUNSG = '混三公(1倍)',
}
SGGameLogic.SPECIAL_MUL_TEXT2 = {
    ZHIZUN = '至尊(5倍)',
    DASG = '大三公(5倍)',
    XIAOSG = '小三公(5倍)',
    HUNSG = '混三公(5倍)',
}

SGGameLogic.SPECIAL_MUL_TEXT3 = {
    ZHIZUN = '至尊(8倍)',
    DASG = '大三公(7倍)',
    XIAOSG = '小三公(6倍)',
    HUNSG = '混三公(5倍)',
}

SGGameLogic.NIUMUL = {
    '全部1倍',
    '三公(包含至尊，大小三公，混三公)x5、公九x4、公八x3、公七x2',
    '至尊x8、大三公x7、小三公x6、混三公x5、公九x4、公八x3、公七x2',
}

SGGameLogic.GAMEPLAY = {
    '',
    '',
    '自由抢庄',
    '明牌三公',
    '大吃小',
    '',
    '',
    '',
    '三公轮庄',
}

SGGameLogic.STARTMODE = {
    '手动开始',
    '满4人开',
    '满5人开',
    '满6人开',
}

SGGameLogic.STARTMODE_BM = {
    '手动开始',
    '满6人开',
    '满7人开',
    '满8人开',
}

SGGameLogic.STARTMODE_SM = {
    '手动开始',
    '满8人开',
    '满9人开',
    '满10人开',
}

SGGameLogic.PUTMONEY = {
    '无推注',
    '5倍封顶',
    '10倍封顶',
    '15倍封顶',
    '20倍封顶',
    '40倍封顶',
}

SGGameLogic.PUTMONEY_ORDER = {
    '无',
    '5倍',
    '10倍',
    '15倍',
    '20倍',
    '40倍',
}

SGGameLogic.QZMAX = {
    '1倍',
    '2倍',
    '3倍',
    '4倍',
}

SGGameLogic.PEPLESELECT_TEXT = {
    '6人',
    '8人',
    '10人',
}

SGGameLogic.QZMAXINFO = {
    { 1 },
    { 1, 2 },
    { 1, 2, 3 },
    { 1, 2, 3, 4 },
}

SGGameLogic.BASE = {
    ['1/2/4'] = '1/2/4',
    ['2/4/8'] = '2/4/8',
    ['3/6/12'] = '3/6/12',
    ['4/8/16'] = '4/8/16',
    ['5/10/20'] = '5/10/20',
    ['10/20/40'] = '10/20/40',
}

SGGameLogic.BASEORDER = {
    [1] = '1/2/4',
    [2] = '2/4/8',
    [3] = '3/6/12',
    [4] = '4/8/16',
    [5] = '5/10/20',
    [6] = '10/20/40',
}

SGGameLogic.BASEORDER_DCX = {
    [1] = '10',
    [2] = '20',
    [3] = '30',
    [4] = '40',
    [5] = '50',
    [6] = '100',
}

SGGameLogic.BASEINFO = {
    ['1/2/4'] = { 1, 2, 4 },
    ['2/4/8'] = { 2, 4, 8 },
    ['3/6/12'] = { 3, 6, 12 },
    ['4/8/16'] = { 4, 8, 16 },
    ['5/10/20'] = { 5, 10, 20 },
    ['10/20/40'] = { 10, 20, 40 },
}

SGGameLogic.PUTLIMITORDER = {
    [1] = '100封顶',
    [2] = '200封顶',
    [3] = '300封顶',
    [4] = '400封顶',
    [5] = '500封顶',
    [6] = '1000封顶',
}

SGGameLogic.SZSELECTORDER = {
    [1] = '霸王庄',
    [2] = '轮流坐庄',
    [3] = '牌大坐庄',
}

SGGameLogic.SPECIAL_EMUN = {
    ZHIZUN = 4,
    DASG = 3,
    XIAOSG = 2,
    HUNSG = 1,
}

SGGameLogic.SPECIAL_EMUN7 = {
    ZHIZUN = 4,
    DASG = 3,
    XIAOSG = 2,
    HUNSG = 1,
}

SGGameLogic.CLIENT_SETTING = {
    ZHIZUN = 4,
    DASG = 3,
    XIAOSG = 2,
    HUNSG = 1,
}

SGGameLogic.CLIENT_SETTING7 = {
    ZHIZUN = 4,
    DASG = 3,
    XIAOSG = 2,
    HUNSG = 1,
}


SGGameLogic.NIU_MULNUM = {
    default = {
        {[9] = 1, [8] = 1, [7] = 1 },
        {[9] = 4, [8] = 3, [7] = 2 },
        {[9] = 4, [8] = 3, [7] = 2 },
    }
}

SGGameLogic.SPECIAL_MULNUM = {
    [1] = {
        ZHIZUN = 1,
    	DASG = 1,
    	XIAOSG = 1,
    	HUNSG = 1,
	},
	[2] = {
		ZHIZUN = 5,
    	DASG = 5,
    	XIAOSG = 5,
    	HUNSG = 5,
	},
	[3] = {
		ZHIZUN = 8,
    	DASG = 7,
    	XIAOSG = 6,
    	HUNSG = 5,
	}
}

SGGameLogic.CARDS = {
    ['♠A'] = 1, ['♠2'] = 2, ['♠3'] = 3, ['♠4'] = 4, ['♠5'] = 5,
    ['♠6'] = 6, ['♠7'] = 7, ['♠8'] = 8, ['♠9'] = 9,
    ['♠T'] = 10, ['♠J'] = 10, ['♠Q'] = 10, ['♠K'] = 10,

    ['♥A'] = 1, ['♥2'] = 2, ['♥3'] = 3, ['♥4'] = 4, ['♥5'] = 5,
    ['♥6'] = 6, ['♥7'] = 7, ['♥8'] = 8, ['♥9'] = 9,
    ['♥T'] = 10, ['♥J'] = 10, ['♥Q'] = 10, ['♥K'] = 10,

    ['♣A'] = 1, ['♣2'] = 2, ['♣3'] = 3, ['♣4'] = 4, ['♣5'] = 5,
    ['♣6'] = 6, ['♣7'] = 7, ['♣8'] = 8, ['♣9'] = 9,
    ['♣T'] = 10, ['♣J'] = 10, ['♣Q'] = 10, ['♣K'] = 10,

    ['♦A'] = 1, ['♦2'] = 2, ['♦3'] = 3, ['♦4'] = 4, ['♦5'] = 5,
    ['♦6'] = 6, ['♦7'] = 7, ['♦8'] = 8, ['♦9'] = 9,
    ['♦T'] = 10, ['♦J'] = 10, ['♦Q'] = 10, ['♦K'] = 10,
    ['☆'] = 10, ['★'] = 10,

    ['☆A'] = 1, ['☆2'] = 2, ['☆3'] = 3, ['☆4'] = 4, ['☆5'] = 5,
    ['☆6'] = 6, ['☆7'] = 7, ['☆8'] = 8, ['☆9'] = 9,
    ['☆T'] = 10, ['☆J'] = 10, ['☆Q'] = 10, ['☆K'] = 10,

    ['★A'] = 1, ['★2'] = 2, ['★3'] = 3, ['★4'] = 4, ['★5'] = 5,
    ['★6'] = 6, ['★7'] = 7, ['★8'] = 8, ['★9'] = 9,
    ['★T'] = 10, ['★J'] = 10, ['★Q'] = 10, ['★K'] = 10
}


SGGameLogic.CARDS_LOGICE_VALUE = {
    ['A'] = 1, ['2'] = 2, ['3'] = 3, ['4'] = 4, ['5'] = 5,
    ['6'] = 6, ['7'] = 7, ['8'] = 8, ['9'] = 9,
    ['T'] = 10, ['J'] = 11, ['Q'] = 12, ['K'] = 13,
    ['☆'] = 14, ['★'] = 15,
}

SGGameLogic.HEX_CARDS_DATA = {
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

function SGGameLogic.card_rank_out(c)
    return c:sub(1, SUIT_UTF8_LENGTH)
end

function SGGameLogic.transformCards(serverCardData)
    local retCards = {}
    table.insert(retCards, serverCardData)
    return retCards
end

function SGGameLogic.getSpecialTypeByVal(gameplay, spVal)
    local tabEmun = SGGameLogic.SPECIAL_EMUN
    if gameplay == 6 then
        tabEmun = SGGameLogic.SPECIAL_EMUN7
    end
    if spVal and spVal > 0 then
        for key, val in pairs(tabEmun) do
            if val == spVal then
                return key
            end
        end
    end
end

function SGGameLogic.getSpecialType(cards, gameplay, setting, wanglai, laizinum, niucnt)

    -- 分析撲克
    local value = SGGameLogic.CARDS_LOGICE_VALUE

    local tabHandSort = {}
    local tabHandVal = {} -- 牌值数组(K = 13 Q = 12 J = 11)
    local tabHandVal1 = {} -- 牌值数组(KQJ = 10)
    local tabHandSuit = {}

    local sum = 0   -- 牌值和  

    for k, v in pairs(cards) do
        local cardVal = value[card_rank(v)]
        local cardSuit = card_suit(v)
        local cardVal1 = SGGameLogic.CARDS[v]
        --{ [1]=val, [2]=suit}
        table.insert(tabHandSort, { cardVal, cardSuit, cardVal1 })
        if cardVal < 14 then
            sum = sum + cardVal
        end
    end

    for k, v in pairs(tabHandSort) do
        table.insert(tabHandVal, v[1])
        table.insert(tabHandSuit, v[2])
        table.insert(tabHandVal1, v[3])
    end

    local set = SGGameLogic.CLIENT_SETTING
    local spEmun = SGGameLogic.SPECIAL_EMUN

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

    local function aZhiZun()
        -- 至尊(3个3)
        if tabHandVal[1] == tabHandVal[2] and 
        tabHandVal[2] == tabHandVal[3] and 
        tabHandVal[1] == 3 and
        isEnabled(set.ZHIZUN)
        then
            return true, spEmun.ZHIZUN
        end
    end

    local function aDasg()
        -- 大三公(KKK,QQQ,JJJ)
        if tabHandVal[1] == tabHandVal[2] and 
        tabHandVal[2] == tabHandVal[3] and 
        (tabHandVal[1] == 13 or tabHandVal[1] == 12 or tabHandVal[1] == 11) and
        isEnabled(set.DASG)
        then
            return true, spEmun.DASG
        end
    end

    local function aXiaosg()
        -- 小三公(111,222,...,999)
        if tabHandVal[1] == tabHandVal[2] and 
        tabHandVal[2] == tabHandVal[3] and 
        tabHandVal[1] ~= 13 and tabHandVal[1] ~= 12 and tabHandVal[1] ~= 11 and
        isEnabled(set.XIAOSG)
        then
            return true, spEmun.XIAOSG
        end
    end

    local function aHunsg()
        -- 混三公(三张都是KQJ)
        if tabHandVal[1] > 10 and tabHandVal[2] > 10 and tabHandVal[3] > 10 and
        isEnabled(set.HUNSG)
        then
            return true, spEmun.HUNSG
        end
    end

    -------------------------------------------------------------------------------
    -- 一个癞子---------------------------------------------------------------------
    local function wlZhiZun()
        -- 至尊(3个3)
        if tabHandVal[2] == tabHandVal[3] and 
        tabHandVal[3] == 3 and
        isEnabled(set.ZHIZUN)
        then
            return true, spEmun.ZHIZUN
        end
    end

    local function wlDasg()
        -- 大三公(KKK,QQQ,JJJ)
        if tabHandVal[2] == tabHandVal[3] and 
        (tabHandVal[3] == 13 or tabHandVal[3] == 12 or tabHandVal[3] == 11) and
        isEnabled(set.DASG)
        then
            return true, spEmun.DASG
        end
    end

    local function wlXiaosg()
        -- 小三公(111,222,...,999)
        if tabHandVal[2] == tabHandVal[3] and 
        tabHandVal[3] ~= 13 and tabHandVal[3] ~= 12 and tabHandVal[3] ~= 11 and
        isEnabled(set.XIAOSG)
        then
            return true, spEmun.XIAOSG
        end
    end

    local function wlHunsg()
        -- 混三公(三张都是KQJ)
        if tabHandVal[2] > 10 and tabHandVal[3] > 10 and
        isEnabled(set.HUNSG)
        then
            return true, spEmun.HUNSG
        end
    end
    -------------------------------------------------------------------------------
    -- 两个癞子---------------------------------------------------------------------	
    local function wl2ZhiZun()
        -- 至尊(3个3)
        if tabHandVal[3] == 3 and
        isEnabled(set.ZHIZUN)
        then
            return true, spEmun.ZHIZUN
        end
    end

    local function wl2Dasg()
        -- 大三公(KKK,QQQ,JJJ)
        if (tabHandVal[3] == 13 or tabHandVal[3] == 12 or tabHandVal[3] == 11) and
        isEnabled(set.DASG)
        then
            return true, spEmun.DASG
        end
    end

    local function wl2Xiaosg()
        -- 小三公(111,222,...,999)
        if tabHandVal[3] ~= 13 and tabHandVal[3] ~= 12 and tabHandVal[3] ~= 11 and
        isEnabled(set.XIAOSG)
        then
            return true, spEmun.XIAOSG
        end
    end

    local function wl2Hunsg()
        -- 混三公(三张都是KQJ)
        if tabHandVal[3] > 10 and
        isEnabled(set.HUNSG)
        then
            return true, spEmun.HUNSG
        end
    end
    -------------------------------------------------------------------------------
    -- 优先级
    local tabFunc = { aZhiZun, aDasg, aXiaosg, aHunsg } -- 普通模式
    if gameplay == 6 or gameplay == 9 then -- 疯狂加倍模式
        tabFunc = { aZhiZun, aDasg, aXiaosg, aHunsg }
    end

    if wanglai and wanglai > 0 then -- 王癞模式
        if laizinum == 1 then
            tabFunc = { wlZhiZun, wlDasg, wlXiaosg, wlHunsg }
        elseif laizinum == 2 then
            tabFunc = { wl2ZhiZun, wl2Dasg, wl2Xiaosg, wl2Hunsg }
        end
        if gameplay == 6 or gameplay == 9 then -- 疯狂加倍模式
            if laizinum == 1 then
                tabFunc = { wlZhiZun, wlDasg, wlXiaosg, wlHunsg }
            elseif laizinum == 2 then
                tabFunc = { wl2ZhiZun, wl2Dasg, wl2Xiaosg, wl2Hunsg }
            end
        end
    end

    local type = 0
    for i, v in ipairs(tabFunc) do
        local bool, val = v()
        if bool then
            type = val
            break
        end
    end

    return type, SGGameLogic.getSpecialTypeByVal(gameplay, type)
end


function SGGameLogic.findNiuniuByData(cards, laizinum)
    local niuCnt = 0
    local cnt = #cards
    local sum = 0
    
    if laizinum == 0 then
        for i = 1, cnt do
            sum = sum + SGGameLogic.CARDS[cards[i]]
        end
        niuCnt = sum % 10
        return niuCnt
        
    else
        return 9
    end
end

function SGGameLogic.setLaiziData(cardsdata, specialType)
    local cards, laizinum = SGGameLogic.sortCards(cardsdata)
    if laizinum == 0 then return cards end
    local cardsvalue = {}
    local cardbiaomian = {}
    local cardvalue1 = {}

    for k, v in pairs(cards) do
        table.insert(cardsvalue, SGGameLogic.CARDS_LOGICE_VALUE[card_rank(v)])
    end

    for k, v in pairs(cards) do
        table.insert(cardvalue1, SGGameLogic.CARDS[v])
    end

    for k, v in pairs(cards) do
        table.insert(cardbiaomian, card_rank(v))
    end

    local function getcard_rank(value)
        for k, v in pairs(SGGameLogic.CARDS_LOGICE_VALUE) do
            if v == value then
                return k
            end
        end
    end

    local function ZHIZUN()
        if laizinum == 1 then
            cards[1] = cards[1] .. '3'
        elseif laizinum == 2 then
            cards[1] = cards[1] .. '3'
            cards[2] = cards[2] .. '3'
        end
    end

    local function DASG()
        if laizinum == 1 then
            cards[1] = cards[1] .. cardbiaomian[3]
        elseif laizinum == 2 then
            cards[1] = cards[1] .. cardbiaomian[3]
            cards[2] = cards[2] .. cardbiaomian[3]
        end
    end

    local function XIAOSG()
        if laizinum == 1 then
            cards[1] = cards[1] .. cardbiaomian[3]
        elseif laizinum == 2 then
            cards[1] = cards[1] .. cardbiaomian[3]
            cards[2] = cards[2] .. cardbiaomian[3]
        end
    end

    local function HUNSG()
        if laizinum == 1 then
            cards[1] = cards[1] .. 'K'
        elseif laizinum == 2 then
            cards[1] = cards[1] .. 'K'
            cards[2] = cards[2] .. 'K'
        end
    end

    local function addTwoCards(laizinum)
        local cnt = 0
        local sum = 0
        for i, v in pairs(cardvalue1) do
            sum = sum + v
        end
        cnt = sum % 10
        local rank = (9 - cnt) == 0 and 'K' or (9 - cnt)
        rank = rank == 1 and 'A' or rank
        if laizinum == 1 then
            cards[1] = cards[1] .. rank
        else
            cards[1] = cards[1] .. 'K'
            cards[2] = cards[2] .. rank
        end
    end

    local typelist = { HUNSG, XIAOSG, DASG, ZHIZUN }
    if specialType and specialType > 0 then
        -- 特殊牌
        for k, v in pairs(typelist) do
            if k == specialType then
                v()
            end
        end
    else
        -- 普通牌
        addTwoCards(laizinum)
    end
    cards, laizinum = SGGameLogic.sortCards(cards)
    return cards
end

function SGGameLogic.groupingCardData(cards, specialType, gameplay, wanglai)
    local retGroup = {}

    local cards, laizinum = SGGameLogic.sortCards(cards)

    if laizinum > 0 then
        cards = SGGameLogic.setLaiziData(cards, specialType)
    end

    local function getVal(card)
        return SGGameLogic.CARDS_LOGICE_VALUE[card_rank(card)]
    end
    local val1 = getVal(cards[1])
    local val3 = getVal(cards[3])
    local val4 = getVal(cards[4])

    retGroup = { cards, {} }
    if specialType and specialType > 0 then
        -- 特殊牌
        local typename = SGGameLogic.getSpecialTypeByVal(gameplay, specialType)
        if typename == "BOOM" then
            if (val1 == val4) then
                retGroup = { { cards[1], cards[2], cards[3], cards[4] }, { cards[5] } }
            else
                retGroup = { { cards[2], cards[3], cards[4], cards[5] }, { cards[1] } }
            end
        end
        if typename == "HULU" then
            if (val1 == val3) then
                retGroup = { { cards[1], cards[2], cards[3] }, { cards[4], cards[5] } }
            else
                retGroup = { { cards[3], cards[4], cards[5] }, { cards[1], cards[2] } }
            end
        end

    else
        -- 普通牛
        local niuniusP, niuniuT = SGGameLogic.findNiuniuByData(cards, laizinum)
        if niuniusP then
            retGroup = { niuniusP[1], niuniuT[1] }
        end
    end

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

function SGGameLogic.getMul(gamePlay, setting, niuCnt, specialType)
    setting = setting or 1

    if specialType and specialType > 0 then
        local type = SGGameLogic.getSpecialTypeByVal(gamePlay, specialType)
        local mulTab = SGGameLogic.SPECIAL_MULNUM[setting]
        return mulTab[type]
    end

    if niuCnt then
        local mulTab = SGGameLogic.NIU_MULNUM.default
        return mulTab[setting][niuCnt]
    end

end

function SGGameLogic.getSetting(gameplay, setNum)
    local tabSetting = SGGameLogic.CLIENT_SETTING
    if gameplay == 6 then
        tabSetting = SGGameLogic.CLIENT_SETTING7
    end
    for name, v in pairs(tabSetting) do
        if v > 0 and setNum and v == setNum then
            return name
        end
    end
end

-- 哈希表转数组
function SGGameLogic.hashCountsToArray(hash)
    local a = {}
    for k, v in pairs(hash) do
        for _ = 1, v do
            a[#a + 1] = k
        end
    end
    return a
end


-- mode: 1:五小牛。。。 | 2:五小  |  3:五小牛（8倍） 
function SGGameLogic.getSpecialText(deskInfo, mode, oneLine)
    mode = mode or 3

	local gameplay = deskInfo.gameplay
	local multiply = deskInfo.multiply
    local tabRule
    if mode == 1 then -- 长文本
        tabRule = SGGameLogic.SPECIAL_LONG_TEXT
    elseif mode == 2 then	-- 短文本
        tabRule = SGGameLogic.SPECIAL_SHORT_TEXT
    elseif mode == 3 then -- 带倍数
        tabRule = SGGameLogic.SPECIAL_MUL_TEXT1
        if multiply == 2 then
			tabRule = SGGameLogic.SPECIAL_MUL_TEXT2
		elseif multiply == 3 then
			tabRule = SGGameLogic.SPECIAL_MUL_TEXT3
        end
    else
        tabRule = SGGameLogic.SPECIAL_LONG_TEXT
    end

    local special = deskInfo.special
    local ruleText = ""
    local addCnt = 0
    for i, v in pairs(special) do
        if v > 0 then
            local spName = SGGameLogic.getSetting(gameplay, v)
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
function SGGameLogic.getAdvanceText(deskInfo)
    local setting = {
        -- '闲家推注',
        '',
        '游戏开始后禁止加入',
        '禁止搓牌',
        '下注限制',
        '王癞玩法',
    }
    local wanglai = {
        '',
        '经典王癞',
        '疯狂王癞',
    }
    local retStr = ''
    for k, v in pairs(deskInfo.advanced) do
        if v > 0 then
            local text = setting[k] or ''
            retStr = retStr .. text .. ' '
        end
    end
    retStr = retStr .. wanglai[deskInfo.wanglai]
    return retStr
end

-- 2/4 。。。
function SGGameLogic.getBaseText(deskInfo)
    local base = deskInfo.base
    return SGGameLogic.BASE[base] or base
end

function SGGameLogic.getBaseOrder(idx, mode)
    if mode == 'dcx' then
        return SGGameLogic.BASEORDER_DCX[idx]
    else
        return SGGameLogic.BASEORDER[idx]
    end
end

--2/4——{2,4}
function SGGameLogic.getBaseInfoText(deskInfo)
    local base = deskInfo.base
    return SGGameLogic.BASEINFO[base]
end

function SGGameLogic.getSzSelectText(deskInfo)
    local szSelect = deskInfo.szSelect
    return SGGameLogic.SZSELECTORDER[szSelect]
end

function SGGameLogic.getPutLimitText(deskInfo)
    local putLimit = deskInfo.putLimit
    return SGGameLogic.PUTLIMITORDER[putLimit]
end

function SGGameLogic.getPutLimitOrder(idx)
    return SGGameLogic.PUTLIMITORDER[idx]
end

-- 牛9X5 。。。
function SGGameLogic.getNiuNiuMulText(deskInfo, mode)
    local mul = deskInfo.multiply
    local gameplay = deskInfo.gameplay
    if mode then
        if gameplay == 6 then
            return '牛牛X10倍'
        elseif mul == 1 then
            return '牛牛X4倍'
        else
            return '牛牛X3倍'
        end
    end

    return SGGameLogic.NIUMUL[mul]

end

-- 牛牛玩法
function SGGameLogic.getGameplayText(deskInfo)
    local idx = deskInfo.gameplay
    return SGGameLogic.GAMEPLAY[idx] or ''
end

-- 支付方式
function SGGameLogic.getPayModeText(deskInfo)
    local idx = deskInfo.roomPrice
    local payText = "房主"
    if idx == 1 then
        payText = "房主"
    else
        payText = "AA"
    end
    return payText
end

-- 推注选项
function SGGameLogic.getPutMoneyText(deskInfo)
    local idx = deskInfo.putmoney
    return SGGameLogic.PUTMONEY[idx] or ''
end

-- 推注选项
function SGGameLogic.getPutMoneyOrder(idx)
    return SGGameLogic.PUTMONEY_ORDER[idx] or ''
end

-- 人数
function SGGameLogic.getPeopleSelectOrder(idx)
    return SGGameLogic.PEPLESELECT_TEXT[idx] or ''
end

-- 最大抢庄
function SGGameLogic.getQzMaxText(deskInfo)
    local idx = deskInfo.qzMax
    return SGGameLogic.QZMAX[idx] or ''
end

-- 最大抢庄具体数目
function SGGameLogic.getQzMaxInfoText(deskInfo)
    local idx = deskInfo.qzMax
    return SGGameLogic.QZMAXINFO[idx]
end

-- 自动开始
function SGGameLogic.getStartModeText(deskInfo)
    local idx = deskInfo.startMode
    local str = SGGameLogic.STARTMODE
    if deskInfo.peopleSelect == 2 then
        str = SGGameLogic.STARTMODE_BM
    elseif deskInfo.peopleSelect == 3 then
        str = SGGameLogic.STARTMODE_SM
    end
    return str[idx] or ''
end

-- 自动开始
function SGGameLogic.getStartModeOrder(idx, peopleSelect)
    local mode = SGGameLogic.STARTMODE
    if peopleSelect == 2 then
        mode = SGGameLogic.STARTMODE_BM
    elseif peopleSelect == 3 then
        mode = SGGameLogic.STARTMODE_SM
    end
    return mode[idx] or ''
end

-- 房间限制
function SGGameLogic.getRoomLimitText(deskInfo)
    local text = '无'
    if deskInfo.roomMode == 'bisai' and deskInfo.scoreOption then
        local options = deskInfo.scoreOption
        text = '入场:' .. options.join .. '  抢庄:' .. options.qiang .. '  推注:' .. options.tui
        .. '  抽水:' .. options.choushui_sg .. '%  ' .. (options.rule == 1 and '大赢家抽水' or '赢家抽水')
    end
    return text
end

function SGGameLogic.isQzGame(deskInfo)
    local idx = deskInfo.gameplay
    local tab = {
        [3] = 3,
        [4] = 4,
        [7] = 7,
        [5] = 5,
        [6] = 6,
        [8] = 8,
        [9] = 9,
    }
    return tab[idx] or false
end

function SGGameLogic.isSzGame(deskInfo)
    local idx = deskInfo.gameplay
    local tab = {
        [1] = 1,
        [2] = 2,
    }
    return tab[idx] or false
end

-- 房间规则
function SGGameLogic.getRoomRuleText(deskInfo)
    local roomRuleText = ""
    roomRuleText = SGGameLogic.getPayModeText(deskInfo) .. "支付"
    roomRuleText = roomRuleText .. " 推注" .. SGGameLogic.getPutMoneyText(deskInfo)
    if SGGameLogic.isQzGame(deskInfo) then
        roomRuleText = roomRuleText .. " 最大抢庄" .. SGGameLogic.getQzMaxText(deskInfo)
    end
    roomRuleText = roomRuleText .. " " .. SGGameLogic.getStartModeText(deskInfo)
    return roomRuleText
end

function SGGameLogic.isEnableCuoPai(deskInfo)
    if deskInfo.advanced and deskInfo.advanced[3] > 0 then
        return false
    end
    return true
end

-- 已弃用
function SGGameLogic.findNiuniuCnt(cards)
    local niuCnt = 0

    if cards then
        local max = 0
        for _, v in ipairs(cards) do
            max = max + SGGameLogic.CARDS[v]
        end

        max = max % 10
        niuCnt = max

        if niuCnt == 0 then
            niuCnt = 10
        end
    end

    return niuCnt
end

function SGGameLogic.sortCards(cards)

    local value = SGGameLogic.CARDS_LOGICE_VALUE
    local cardcolor = SGGameLogic.HEX_CARDS_DATA
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

function SGGameLogic.getLocalCardType(cardsdata, gameplay, setting, wanglai)
    local cards, laizinum = SGGameLogic.sortCards(cardsdata)
    local cnt = SGGameLogic.findNiuniuByData(cards, laizinum)
    cnt = cnt or 0
    local spType, spKey = SGGameLogic.getSpecialType(cards, gameplay, setting, wanglai, laizinum, cnt)
    return cnt, spType, spKey
end

return SGGameLogic