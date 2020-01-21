local DKGameLogic = {}

DKGameLogic.SPECIAL_LONG_TEXT= {
	RSFLUSH = '皇家同花顺',
	SFLUSH = '同花顺',
	BOOM = '四条',
	HULU = '葫芦',
	FLUSH = '同花',
	STRAIGHT = '顺子',
	THREE = '三条',
	TPAIRS = '两对',
	OPAIRS = '一对',
	HCARD = '高牌',
}

DKGameLogic.SPECIAL_SHORT_TEXT = {
	RSFLUSH = '皇家同花顺',
	SFLUSH = '同花顺',
	BOOM = '四条',
	HULU = '葫芦',
	FLUSH = '同花',
	STRAIGHT = '顺子',
	THREE = '三条',
	TPAIRS = '两对',
	OPAIRS = '一对',
	HCARD = '高牌',
}

DKGameLogic.SPECIAL_MUL_TEXT = {
	RSFLUSH = '皇家同花顺(1倍)',
	SFLUSH = '同花顺(1倍)',
	BOOM = '四条(1倍)',
	HULU = '葫芦(1倍)',
	FLUSH = '同花(1倍)',
	STRAIGHT = '顺子(1倍)',
	THREE = '三条(1倍)',
	TPAIRS = '两对(1倍)',
	OPAIRS = '一对(1倍)',
	HCARD = '高牌(1倍)',
}

DKGameLogic.NIUMUL_FK = '2点~9点    2~9倍'

DKGameLogic.GAMEPLAY = {
  [11] = '德扑',
}

DKGameLogic.STARTMODE = {
	'手动开始',
	'满2人开',
	'满3人开',
	'满4人开',
	'满5人开',
	'满6人开',
	'满7人开',
	'满8人开',
	'满9人开',
}

DKGameLogic.LIMIT = {
	'有限下注',
	'压注限制',
	'无限下注',
}

DKGameLogic.PUTMONEY = {
	['5/10'] = '5/10',
	['10/20'] = '10/20',
	['20/40'] = '20/40',
	['50/100'] = '50/100',
	['100/200'] = '100/200',
}

DKGameLogic.PUTMONEY_MIN = {
	['5/10'] = 5,
	['10/20'] = 10,
	['20/40'] = 20,
	['50/100'] = 50,
	['100/200'] = 100,
}

DKGameLogic.XZ = {
	'抢庄',
	'轮庄',
}

DKGameLogic.QZMAX = {
	'1倍',
	'2倍',
	'3倍',
	'4倍',
}

DKGameLogic.QZMAXINFO = {
	{1},
	{1,2},
	{1,2,3},
	{1,2,3,4},
}

DKGameLogic.BASE = {
	['100'] = '100',
	['500'] = '500',
	['1000'] = '1000',
	['2000'] = '2000',
	['3000'] = '3000',
}

DKGameLogic.SPECIAL_EMUN = {
	RSFLUSH = 10,
    SFLUSH = 9,
    BOOM = 8,
    HULU = 7,
    FLUSH = 6,
    STRAIGHT = 5,
    THREE = 4,
    TPAIRS = 3,
    OPAIRS = 2,
    HCARD = 1,
}

DKGameLogic.SPECIAL_EMUN_WANFA = {
	RSFLUSH = 10,
    SFLUSH = 9,
    BOOM = 8,
    HULU = 7,
    FLUSH = 6,
    THREE = 5,
    STRAIGHT = 4,
    TPAIRS = 3,
    OPAIRS = 2,
    HCARD = 1,
}

DKGameLogic.CLIENT_SETTING = {
	RSFLUSH = 10,
    SFLUSH = 9,
    BOOM = 8,
    HULU = 7,
    FLUSH = 6,
    STRAIGHT = 5,
    THREE = 4,
    TPAIRS = 3,
    OPAIRS = 2,
    HCARD = 1,
}

DKGameLogic.CLIENT_SETTING_WANFA = {
	RSFLUSH = 10,
    SFLUSH = 9,
    BOOM = 8,
    HULU = 7,
    FLUSH = 6,
    THREE = 5,
    STRAIGHT = 4,
    TPAIRS = 3,
    OPAIRS = 2,
    HCARD = 1,
}

DKGameLogic.NIU_MULNUM = {
	default = {
		{[2] = 2, [3] = 3, [4] = 4, [5] = 5, [6] = 6, [7] = 7, [8] = 8, [9] = 9, [0] = 0},
		{[2] = 2, [3] = 3, [4] = 4, [5] = 5, [6] = 6, [7] = 7, [8] = 8, [9] = 9, [0] = 0},
	},
	[1] = {
		{[2] = 1, [3] = 1, [4] = 1, [5] = 1, [6] = 1, [7] = 1, [8] = 1, [9] = 1, [0] = 1},
	}
}

DKGameLogic.SPECIAL_MULNUM = {
	default = {
		RSFLUSH = 1,
		SFLUSH = 1,
		BOOM = 1,
		HULU = 1,
		FLUSH = 1,
		STRAIGHT = 1,
		THREE = 1,
		TPAIRS = 1,
		OPAIRS = 1,
		HCARD = 1,
	}
}

DKGameLogic.CARDS = {
	['♠A'] = 1, ['♠2'] = 2, ['♠3'] = 3, ['♠4'] = 4, ['♠5'] = 5,
	['♠6'] = 6, ['♠7'] = 7, ['♠8'] = 8, ['♠9'] = 9,
	['♠T'] = 10, ['♠J'] = 11, ['♠Q'] = 12, ['♠K'] = 13,
	
	['♥A'] = 1, ['♥2'] = 2, ['♥3'] = 3, ['♥4'] = 4, ['♥5'] = 5,
	['♥6'] = 6, ['♥7'] = 7, ['♥8'] = 8, ['♥9'] = 9,
	['♥T'] = 10, ['♥J'] = 11, ['♥Q'] = 12, ['♥K'] = 13,
	
	['♣A'] = 1, ['♣2'] = 2, ['♣3'] = 3, ['♣4'] = 4, ['♣5'] = 5,
	['♣6'] = 6, ['♣7'] = 7, ['♣8'] = 8, ['♣9'] = 9,
	['♣T'] = 10, ['♣J'] = 11, ['♣Q'] = 12, ['♣K'] = 13,
	
	['♦A'] = 1, ['♦2'] = 2, ['♦3'] = 3, ['♦4'] = 4, ['♦5'] = 5,
	['♦6'] = 6, ['♦7'] = 7, ['♦8'] = 8, ['♦9'] = 9,
	['♦T'] = 10, ['♦J'] = 11, ['♦Q'] = 12, ['♦K'] = 13,
	['☆'] = 10, ['★'] = 6,
}

DKGameLogic.CARDS_LOGICE_VALUE = {
	['A'] = 13, ['2'] = 1, ['3'] = 2, ['4'] = 3, ['5'] = 4,
	['6'] = 5, ['7'] = 6, ['8'] = 7, ['9'] = 8,
	['T'] = 9, ['J'] = 10, ['Q'] = 11, ['K'] = 12,
	-- ['☆'] = 14, ['★'] = 15,
}

DKGameLogic.HEX_CARDS_DATA = {
	['♠A'] = 0x51, ['♠2'] = 0x52, ['♠3'] = 0x53, ['♠4'] = 0x54, ['♠5'] = 0x55,
	['♠6'] = 0x56, ['♠7'] = 0x57, ['♠8'] = 0x58, ['♠9'] = 0x59,
	['♠T'] = 0x5A, ['♠J'] = 0x5B, ['♠Q'] = 0x5C, ['♠K'] = 0x5D,
	
	['♥A'] = 0x41, ['♥2'] = 0x42, ['♥3'] = 0x43, ['♥4'] = 0x44, ['♥5'] = 0x45,
	['♥6'] = 0x46, ['♥7'] = 0x47, ['♥8'] = 0x48, ['♥9'] = 0x49,
	['♥T'] = 0x4A, ['♥J'] = 0x4B, ['♥Q'] = 0x4C, ['♥K'] = 0x4D,
	
	['♣A'] = 0x31, ['♣2'] = 0x32, ['♣3'] = 0x33, ['♣4'] = 0x34, ['♣5'] = 0x35,
	['♣6'] = 0x36, ['♣7'] = 0x37, ['♣8'] = 0x38, ['♣9'] = 0x39,
	['♣T'] = 0x3A, ['♣J'] = 0x3B, ['♣Q'] = 0x3C, ['♣K'] = 0x3D,
	
	['♦A'] = 0x21, ['♦2'] = 0x22, ['♦3'] = 0x23, ['♦4'] = 0x24, ['♦5'] = 0x25,
	['♦6'] = 0x26, ['♦7'] = 0x27, ['♦8'] = 0x28, ['♦9'] = 0x29,
	['♦T'] = 0x2A, ['♦J'] = 0x2B, ['♦Q'] = 0x2C, ['♦K'] = 0x2D,

	['★A'] = 0x11, ['★2'] = 0x12, ['★3'] = 0x13, ['★4'] = 0x14, ['★5'] = 0x15, 
	['★6'] = 0x16,['★7'] = 0x17, ['★8'] = 0x18, ['★9'] = 0x19, 
	['★T'] = 0x1A, ['★J'] = 0x1B, ['★Q'] = 0x1C, ['★K'] = 0x1D,

	['☆A'] = 0x01, ['☆2'] = 0x02, ['☆3'] = 0x03, ['☆4'] = 0x04, ['☆5'] = 0x05, 
	['☆6'] = 0x06,['☆7'] = 0x07, ['☆8'] = 0x08, ['☆9'] = 0x09, 
	['☆T'] = 0x0A, ['☆J'] = 0x0B, ['☆Q'] = 0x0C, ['☆K'] = 0x0D,

	['☆'] = 0x61, ['★'] = 0x62
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

function DKGameLogic.getSpecificType(maxCard, specailType)
	-- if specailType == 'DILIU' then
	-- 	if maxCard == 10 then
	-- 		return 'DUIMEI'
	-- 	elseif maxCard == 6 then
	-- 		return 'CHANGSAN'
	-- 	elseif maxCard == 4 then
	-- 		return 'BANDENG'
	-- 	end
	-- end
	-- if specailType == 'DIQI' then
	-- 	if maxCard == 11 then
	-- 		return 'FUTOU'
	-- 	elseif maxCard == 10 then
	-- 		return 'HONGSHI'
	-- 	elseif maxCard == 7 then
	-- 		return 'HONGQI'
	-- 	elseif maxCard == 6 then
	-- 		return 'HONGLIU'
	-- 	end
	-- end
	-- if specailType == 'DIBA' then
	-- 	if maxCard == 9 then
	-- 		return 'HONGJIU'
	-- 	elseif maxCard == 8 then
	-- 		return 'QINGBA'
	-- 	elseif maxCard == 7 then
	-- 		return 'HEIQI'
	-- 	elseif maxCard == 5 then
	-- 		return 'HONGWU'
	-- 	end
	-- end
	return specailType
end

function DKGameLogic.getSpecialTypeByVal(gameplay, spVal, wanfa)
    wanfa = wanfa or 0
    local tabEmun = DKGameLogic.SPECIAL_EMUN
    if wanfa > 0 then
        tabEmun = DKGameLogic.SPECIAL_EMUN_WANFA
    end
	if spVal and spVal > 0 then
		for key, val in pairs(tabEmun) do
			if val == spVal then
				return key
			end
		end
	end
end

function DKGameLogic.getSpecialType(cards, gameplay, setting, wanfa)

	-- 分析撲克
	local value = DKGameLogic.CARDS_LOGICE_VALUE
	
	local maxCardsComb = {}		-- 最大牌组合

	local tabHandSort = {}
	local tabHandVal = {} -- 牌值数组
	local tabHandSuit = {}
	
	local sum = 0   -- 牌值和
	local hasDaWang = false   

	for k, v in pairs(cards) do
		local cardVal = value[card_rank(v)]
		local cardSuit = card_suit(v)
		--{ [1]=val, [2]=suit}
		table.insert(tabHandSort, {cardVal, cardSuit})
		if cardSuit == '★' then
			hasDaWang = true
		end
	end
	
	for k, v in pairs(tabHandSort) do
		table.insert(tabHandVal, v[1])
		table.insert(tabHandSuit, v[2])
	end
	
	local set = DKGameLogic.CLIENT_SETTING
    local spEmun = DKGameLogic.SPECIAL_EMUN
    
    if wanfa and wanfa > 0 then
        set = DKGameLogic.CLIENT_SETTING_WANFA
        spEmun = DKGameLogic.SPECIAL_EMUN_WANFA
    end

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

	local function aRSflush()
        -- 皇家同花顺
        local t = tabHandVal
        -- 先找出顺子
        for i = 1, 3 do
            maxCardsComb = {}
            local hasA, hasT, hasJ, hasQ, hasK = false, false, false, false, false
            for j = i, 7 do
                if t[j] == 13 and not hasA then
                    hasA = true
                    table.insert(maxCardsComb, cards[j])
                end
                if t[j] == 12 and not hasK then
                    hasK = true
                    table.insert(maxCardsComb, cards[j])
                end
                if t[j] == 11 and not hasQ then
                    hasQ = true
                    table.insert(maxCardsComb, cards[j])
                end
                if t[j] == 10 and not hasJ then
                    hasJ = true
                    table.insert(maxCardsComb, cards[j])
                end
                if t[j] == 9 and not hasT then
                    hasT = true
                    table.insert(maxCardsComb, cards[j])
                end
            end
            if hasA and hasT and hasJ and hasQ and hasK then
                -- 验证是否同花
                local cardSuit1 = card_suit(maxCardsComb[1])
                local flag = true
                for k = 2, 5 do
                    if card_suit(maxCardsComb[k]) ~= cardSuit1 then
                        flag = false
                        break
                    end
                end
                if flag and isEnabled(set.RSFLUSH) then
                    return true, spEmun.RSFLUSH
                end
            end
        end
    end

    local function aSflush()
        -- 同花顺
        local t = tabHandVal
        -- 先找出顺子
        for i = 1, 3 do
            maxCardsComb = {}
            maxCardsComb[1] = cards[i]
            local value1 = t[i]
            local second, third, forth, fiveth = false, false, false, false
            for j = i + 1, 7 do
                if t[j] == value1 - 1 and not second  then
                    second = true
                    table.insert(maxCardsComb, cards[j])
                end 
                if t[j] == value1 - 2 and not third then
                    third = true
                    table.insert(maxCardsComb, cards[j])
                end 
                if t[j] == value1 - 3 and not forth then
                    forth = true
                    table.insert(maxCardsComb, cards[j])
                end 
                if t[j] == value1 - 4 and not fiveth then
                    fiveth = true
                    table.insert(maxCardsComb, cards[j])
                end 
            end
            if second and third and forth and fiveth and isEnabled(set.SFLUSH) then
                -- 验证是否同花
                local cardSuit1 = card_suit(maxCardsComb[1])
                local flag = true
                for k = 2, 5 do
                    if card_suit(maxCardsComb[k]) ~= cardSuit1 then
                        flag = false
                        break
                    end
                end
                if flag and isEnabled(set.SFLUSH) then
                    return true, spEmun.SFLUSH
                end
            end
        end

        if t[1] == 13 then
            maxCardsComb = {}
            local second, third, forth, fiveth = false, false, false, false
            for j = 2, 7 do
                if t[j] == 5 and not second  then
                    second = true
                    table.insert(maxCardsComb, cards[j])
                end 
                if t[j] == 4 and not third then
                    third = true
                    table.insert(maxCardsComb, cards[j])
                end 
                if t[j] == 3 and not forth then
                    forth = true
                    table.insert(maxCardsComb, cards[j])
                end 
                if t[j] == 2 and not fiveth then
                    fiveth = true
                    table.insert(maxCardsComb, cards[j])
                end 
            end
            if second and third and forth and fiveth and isEnabled(set.SFLUSH) then
                -- 验证是否同花
                local cardSuit1 = card_suit(maxCardsComb[1])
                local flag = true
                for k = 2, 5 do
                    if card_suit(maxCardsComb[k]) ~= cardSuit1 then
                        flag = false
                        break
                    end
                end
                if flag and isEnabled(set.SFLUSH) then
                    return true, spEmun.SFLUSH
                end
            end
        end

        if wanfa and wanfa > 0 then
            if t[1] == 13 then
                maxCardsComb = {}
                local second, third, forth, fiveth = false, false, false, false
                for j = 2, 7 do
                    if t[j] == 9 and not second  then
                        second = true
                        table.insert(maxCardsComb, cards[j])
                    end 
                    if t[j] == 8 and not third then
                        third = true
                        table.insert(maxCardsComb, cards[j])
                    end 
                    if t[j] == 7 and not forth then
                        forth = true
                        table.insert(maxCardsComb, cards[j])
                    end 
                    if t[j] == 6 and not fiveth then
                        fiveth = true
                        table.insert(maxCardsComb, cards[j])
                    end 
                end
                if second and third and forth and fiveth and isEnabled(set.SFLUSH) then
                    -- 验证是否同花
                    local cardSuit1 = card_suit(maxCardsComb[1])
                    local flag = true
                    for k = 2, 5 do
                        if card_suit(maxCardsComb[k]) ~= cardSuit1 then
                            flag = false
                            break
                        end
                    end
                    if flag and isEnabled(set.SFLUSH) then
                        return true, spEmun.SFLUSH
                    end
                end
            end
        end
    end

    local function aBoom()
        -- 四条
        local t = tabHandVal
        if isEnabled(set.BOOM) then
            if (t[1] == t[4] or t[2] == t[5]) then
                maxCardsComb = {cards[1], cards[2], cards[3], cards[4], cards[5]}
                return true, spEmun.BOOM
    
            elseif t[3] == t[6] then
                maxCardsComb = {cards[1], cards[3], cards[4], cards[5], cards[6]}
                return true, spEmun.BOOM
    
            elseif t[4] == t[7] then
                maxCardsComb = {cards[1], cards[4], cards[5], cards[6], cards[7]}
                return true, spEmun.BOOM
            end
        end
    end

    local function aHulu()
        -- 葫芦
        local t = tabHandVal
        if isEnabled(set.HULU) then
            if t[1] == t[3] then
                if t[4] == t[5] then
                    maxCardsComb = {cards[1], cards[2], cards[3], cards[4], cards[5]}
                    return true, spEmun.HULU

                elseif t[5] == t[6] then
                    maxCardsComb = {cards[1], cards[2], cards[3], cards[5], cards[6]}
                    return true, spEmun.HULU

                elseif t[6] == t[7] then
                    maxCardsComb = {cards[1], cards[2], cards[3], cards[6], cards[7]}
                    return true, spEmun.HULU
                end
            elseif t[2] == t[4] then
                if t[5] == t[6] then
                    maxCardsComb = {cards[2], cards[3], cards[4], cards[5], cards[6]}
                    return true, spEmun.HULU

                elseif t[6] == t[7] then
                    maxCardsComb = {cards[2], cards[3], cards[4], cards[6], cards[7]}
                    return true, spEmun.HULU
                end
            elseif t[3] == t[5] then
                if t[1] == t[2] then
                    maxCardsComb = {cards[1], cards[2], cards[3], cards[4], cards[5]}
                    return true, spEmun.HULU

                elseif t[6] == t[7] then
                    maxCardsComb = {cards[3], cards[4], cards[5], cards[6], cards[7]}
                    return true, spEmun.HULU
                end
            elseif t[4] == t[6] then
                if t[1] == t[2] then
                    maxCardsComb = {cards[1], cards[2], cards[4], cards[5], cards[6]}
                    return true, spEmun.HULU

                elseif t[2] == t[3] then
                    maxCardsComb = {cards[2], cards[3], cards[4], cards[5], cards[6]}
                    return true, spEmun.HULU
                end
            elseif t[5] == t[7] then
                if t[1] == t[2] then
                    maxCardsComb = {cards[1], cards[2], cards[5], cards[6], cards[7]}
                    return true, spEmun.HULU

                elseif t[2] == t[3] then
                    maxCardsComb = {cards[2], cards[3], cards[5], cards[6], cards[7]}
                    return true, spEmun.HULU

                elseif t[3] == t[4] then
                    maxCardsComb = {cards[3], cards[4], cards[5], cards[6], cards[7]}
                    return true, spEmun.HULU
                end
            end
        end
    end

    local function aFlush()
        -- 同花
        local flag = false
        maxCardsComb = {}
        local heit, hongt, meih, fangk = 0, 0, 0, 0
        for i, v in ipairs(tabHandSuit) do
            if v == '♦' then
                fangk = fangk + 1
            end
            if v == '♣' then
                meih = meih + 1
            end
            if v == '♥' then
                hongt = hongt + 1
            end
            if v == '♠' then
                heit = heit + 1
            end
        end
        -- 找出同花组合
        if fangk >= 5 then
            flag = true
            for i, v in ipairs(cards) do
                if tabHandSuit[i] == '♦' then
                    table.insert(maxCardsComb, v)
                end 
                if #maxCardsComb >= 5 then
                    break
                end
            end
        end
        if meih >= 5 then
            flag = true
            for i, v in ipairs(cards) do
                if tabHandSuit[i] == '♣' then
                    table.insert(maxCardsComb, v)
                end 
                if #maxCardsComb >= 5 then
                    break
                end
            end
        end
        if hongt >= 5 then
            flag = true
            for i, v in ipairs(cards) do
                if tabHandSuit[i] == '♥' then
                    table.insert(maxCardsComb, v)
                end 
                if #maxCardsComb >= 5 then
                    break
                end
            end
        end
        if heit >= 5 then
            flag = true
            for i, v in ipairs(cards) do
                if tabHandSuit[i] == '♠' then
                    table.insert(maxCardsComb, v)
                end 
                if #maxCardsComb >= 5 then
                    break
                end
            end
        end
        if flag and isEnabled(set.FLUSH) then
            return true, spEmun.FLUSH
        end
    end

    local function aStraight()
        -- 顺子
        local t = tabHandVal
        for i = 1, 3 do
            maxCardsComb = {}
            maxCardsComb[1] = cards[i]
            local value1 = t[i]
            local second, third, forth, fiveth = false, false, false, false
            for j = i + 1, 7 do
                if t[j] == value1 - 1 and not second  then
                    second = true
                    table.insert(maxCardsComb, cards[j])
                end 
                if t[j] == value1 - 2 and not third then
                    third = true
                    table.insert(maxCardsComb, cards[j])
                end 
                if t[j] == value1 - 3 and not forth then
                    forth = true
                    table.insert(maxCardsComb, cards[j])
                end 
                if t[j] == value1 - 4 and not fiveth then
                    fiveth = true
                    table.insert(maxCardsComb, cards[j])
                end 
            end
            if second and third and forth and fiveth and isEnabled(set.STRAIGHT) then
                return true, spEmun.STRAIGHT
            end
        end

        if t[1] == 13 then
            maxCardsComb = {}
            local second, third, forth, fiveth = false, false, false, false
            for j = 2, 7 do
                if t[j] == 5 and not second  then
                    second = true
                    table.insert(maxCardsComb, cards[j])
                end 
                if t[j] == 4 and not third then
                    third = true
                    table.insert(maxCardsComb, cards[j])
                end 
                if t[j] == 3 and not forth then
                    forth = true
                    table.insert(maxCardsComb, cards[j])
                end 
                if t[j] == 2 and not fiveth then
                    fiveth = true
                    table.insert(maxCardsComb, cards[j])
                end 
            end
            if second and third and forth and fiveth and isEnabled(set.STRAIGHT) then
                return true, spEmun.STRAIGHT
            end
        end

        if wanfa and wanfa > 0 then
            if t[1] == 13 then
                maxCardsComb = {}
                local second, third, forth, fiveth = false, false, false, false
                for j = 2, 7 do
                    if t[j] == 9 and not second  then
                        second = true
                        table.insert(maxCardsComb, cards[j])
                    end 
                    if t[j] == 8 and not third then
                        third = true
                        table.insert(maxCardsComb, cards[j])
                    end 
                    if t[j] == 7 and not forth then
                        forth = true
                        table.insert(maxCardsComb, cards[j])
                    end 
                    if t[j] == 6 and not fiveth then
                        fiveth = true
                        table.insert(maxCardsComb, cards[j])
                    end 
                end
                if second and third and forth and fiveth and isEnabled(set.STRAIGHT) then
                    return true, spEmun.STRAIGHT
                end
            end
        end
    end

    local function aThree()
        -- 三条
        local t = tabHandVal
        if isEnabled(set.THREE) then 
            if t[1] == t[3] or t[2] == t[4] or t[3] == t[5] then
                maxCardsComb = {cards[1], cards[2], cards[3], cards[4], cards[5]}
                return true, spEmun.THREE
            elseif t[4] == t[6] then
                maxCardsComb = {cards[1], cards[2], cards[4], cards[5], cards[6]}
                return true, spEmun.THREE
            elseif t[5] == t[7] then
                maxCardsComb = {cards[1], cards[2], cards[5], cards[6], cards[7]}
                return true, spEmun.THREE
            end
        end
    end

    local function aTpairs()
        -- 两对
        local t = tabHandVal
        if isEnabled(set.TPAIRS) then
            if t[1] == t[2] then
                if t[3] == t[4] or t[4] == t[5] then
                    maxCardsComb = {cards[1], cards[2], cards[3], cards[4], cards[5]}
                    return true, spEmun.TPAIRS

                elseif t[5] == t[6] then
                    maxCardsComb = {cards[1], cards[2], cards[3], cards[5], cards[6]}
                    return true, spEmun.TPAIRS

                elseif t[6] == t[7] then
                    maxCardsComb = {cards[1], cards[2], cards[3], cards[6], cards[7]}
                    return true, spEmun.TPAIRS
                end
            elseif t[2] == t[3] then
                if t[4] == t[5] then
                    maxCardsComb = {cards[1], cards[2], cards[3], cards[4], cards[5]}
                    return true, spEmun.TPAIRS
                    
                elseif t[5] == t[6] then
                    maxCardsComb = {cards[1], cards[2], cards[3], cards[5], cards[6]}
                    return true, spEmun.TPAIRS

                elseif t[6] == t[7] then
                    maxCardsComb = {cards[1], cards[2], cards[3], cards[6], cards[7]}
                    return true, spEmun.TPAIRS

                end
            elseif t[3] == t[4] then
                if t[5] == t[6] then
                    maxCardsComb = {cards[1], cards[3], cards[4], cards[5], cards[6]}
                    return true, spEmun.TPAIRS

                elseif t[6] == t[7] then
                    maxCardsComb = {cards[1], cards[3], cards[4], cards[6], cards[7]}
                    return true, spEmun.TPAIRS
                end
            elseif t[4] == t[5] and t[6] == t[7] then
                maxCardsComb = {cards[1], cards[4], cards[5], cards[6], cards[7]}
                return true, spEmun.TPAIRS
            end
        end
    end

    local function aOpairs()
        -- 一对
        local t = tabHandVal
        if isEnabled(set.OPAIRS) then
            if t[1] == t[2] or t[2] == t[3] or t[3] == t[4] or t[4] == t[5] then
                maxCardsComb = {cards[1], cards[2], cards[3], cards[4], cards[5]}
                return true, spEmun.OPAIRS

            elseif t[5] == t[6] then
                maxCardsComb = {cards[1], cards[2], cards[3], cards[5], cards[6]}
                return true, spEmun.OPAIRS

            elseif t[6] == t[7] then
                maxCardsComb = {cards[1], cards[2], cards[3], cards[6], cards[7]}
                return true, spEmun.OPAIRS
            end
        end 
    end

    local function aHcard()
        -- 高牌
        maxCardsComb = {cards[1], cards[2], cards[3], cards[4], cards[5]}
        return true, spEmun.HCARD
    end
	-------------------------------------------------------------------------------
	-- 优先级
    local tabFunc = {aRSflush, aSflush, aBoom, aHulu, aFlush, aStraight, aThree, aTpairs, aOpairs, aHcard} -- 普通模式
    
    if wanfa and wanfa > 0 then
        tabFunc = {aRSflush, aSflush, aBoom, aHulu, aFlush, aThree, aStraight, aTpairs, aOpairs, aHcard}  -- 短牌
    end

	local type = 0
	for i,v in ipairs(tabFunc) do
		local bool, val = v()
		if bool then
			type = val
			break
		end
	end

	return type, DKGameLogic.getSpecialTypeByVal(gameplay, type, wanfa)
end

function DKGameLogic.getMul(gamePlay, setting, niuCnt, specialType, wanfa)
    setting = setting or 1
    wanfa = wanfa or 0
	
	if specialType and specialType > 0 then
		local type = DKGameLogic.getSpecialTypeByVal(gamePlay, specialType, wanfa)
		local mulTab = DKGameLogic.SPECIAL_MULNUM.default
		if DKGameLogic.SPECIAL_MULNUM[gamePlay] then
			mulTab = DKGameLogic.SPECIAL_MULNUM[gamePlay]
		end
		return mulTab[type]
	end
	
	if niuCnt then
		local mulTab = DKGameLogic.NIU_MULNUM.default
		if DKGameLogic.NIU_MULNUM[gamePlay] then
			mulTab = DKGameLogic.NIU_MULNUM[gamePlay]
		end
		return mulTab[setting] [niuCnt]
	end
	
end

function DKGameLogic.getSetting(gameplay, setNum, wanfa)
    wanfa = wanfa or 0
    local tabSetting = DKGameLogic.CLIENT_SETTING
    if wanfa > 0 then
        tabSetting = DKGameLogic.CLIENT_SETTING_WANFA
    end
	for name, v in pairs(tabSetting) do
		if v > 0 and setNum and v == setNum then
			return name
		end
	end
end

-- 哈希表转数组
function DKGameLogic.hashCountsToArray(hash)
    local a = {}
    for k, v in pairs(hash) do
        for _ = 1, v do
          a[#a + 1] = k
        end
    end
    return a
end


-- mode: 1:五小牛。。。 | 2:五小  |  3:五小牛（8倍） 
function DKGameLogic.getSpecialText(deskInfo, mode, oneLine)
	mode = mode or 3

    local gameplay = deskInfo.gameplay
    local wanfa = deskInfo.wanfa
	local tabRule
	if mode == 1 then -- 长文本
		tabRule = DKGameLogic.SPECIAL_LONG_TEXT
	elseif mode == 2 then	-- 短文本
		tabRule = DKGameLogic.SPECIAL_SHORT_TEXT
	elseif mode == 3 then -- 带倍数
		tabRule = DKGameLogic.SPECIAL_MUL_TEXT
	else
		tabRule = DKGameLogic.SPECIAL_LONG_TEXT
	end

	local special = deskInfo.special
	local ruleText = ""
	local addCnt = 0
    for i, v in pairs(special) do 
        if v > 0 then
            local spName = DKGameLogic.getSetting(gameplay, v, wanfa)
            if spName then
                -- addCnt = addCnt + 1
				-- local r = addCnt == 3 and "\r\n" or ""
				-- if oneLine then r = '' end
				-- ruleText = ruleText .. ' ' .. tabRule[spName] .. r
				ruleText = ruleText .. tabRule[spName]
            end
        end
	end

	-- local str1 = "至尊 对天 对地 对人 对和 对梅 对长三 对板凳 对斧头 对红十 对红七 对红六 对红九 对青八 对黑七 对红五 天九王 天杠 地杠"
	-- local str2 = "至尊(13倍) 对天(12倍) 对地(12倍) 对人(12倍) 对和(12倍) 对梅(12倍) 对长三(12倍) 对板凳(12倍) 对斧头(12倍) 对红十(12倍)"
	-- str2 = str2 .. " 对红七(12倍) 对红六(12倍) 对红九(12倍) 对青八(12倍) 对黑七(12倍) 对红五(12倍) 天九王(11倍) 天杠(10倍) 地杠(10倍)"
	-- str2 = str2 .. " 鳖十(0)不吃不赔"
	-- local ruleText = str1
	-- if mode == 3 then
	-- 	ruleText = str2
	-- end
	return ruleText
end

-- 禁止搓牌 | 中途禁止加入 | 
function DKGameLogic.getAdvanceText(deskInfo)
	local setting = {
		'闲家推注',
		'游戏开始后禁止加入',
		'禁止搓牌',
		'下注限制',
		'王癞玩法',
	}
	local retStr = ''
	for k,v in pairs(deskInfo.advanced) do
		if v > 0 then
			local text = setting[k] or ''
			retStr = retStr .. text .. ' '
		end
	end
	return retStr
end

-- 2/4 。。。
function DKGameLogic.getBaseText(deskInfo)
	local base = deskInfo.base
	return DKGameLogic.BASE[base] or base
end

function DKGameLogic.getLimitText(deskInfo)
	local limit = deskInfo.limit
	return DKGameLogic.LIMIT[limit]
end

-- 牛9X5 。。。
function DKGameLogic.getNiuNiuMulText(deskInfo, mode)
	local mul = deskInfo.multiply

	if mul == 1 then
		return DKGameLogic.NIUMUL_1
	else 
		return DKGameLogic.NIUMUL_2
	end

end

-- 牛牛玩法
function DKGameLogic.getGameplayText(deskInfo)
    local idx = deskInfo.gameplay
    local wanfa = deskInfo.wanfa or 0
    local str = DKGameLogic.GAMEPLAY[idx]
    if wanfa > 0 then
        str = str .. '短牌'
    end
	return str or ''
end

-- 支付方式
function DKGameLogic.getPayModeText(deskInfo)
	local idx = deskInfo.roomPrice
	local payText = "房主"
	if idx == 1 then
	  payText = "房主"
	else
	  payText = "AA"
	end
	return payText
end

-- 房间限制
function DKGameLogic.getRoomLimitText(deskInfo)
    local text = '无'
    if deskInfo.roomMode == 'bisai' and deskInfo.scoreOption then
        local options = deskInfo.scoreOption
        -- text = '入场:' .. options.join .. '  抢庄:' .. options.qiang .. '  推注:' .. options.tui 
        --     .. '  抽水:' .. options.choushui_dk .. '%  ' .. ( options.rule == 1 and '大赢家抽水' or '赢家抽水')
        text = '入场:' .. options.join .. '  抽水:' .. (options.choushui_dk or 0) .. '%'
    end
    return text
end

-- 推注选项
function DKGameLogic.getPutMoneyText(deskInfo)
	local idx = deskInfo.putmoney
	return DKGameLogic.PUTMONEY[idx] or ''
end

function DKGameLogic.getPutMoneyMinData(deskInfo)
	local idx = deskInfo.putmoney
	return DKGameLogic.PUTMONEY_MIN[idx] or ''
end

-- 最大抢庄
function DKGameLogic.getQzMaxText(deskInfo)
	local idx = deskInfo.qzMax
	return DKGameLogic.QZMAX[idx] or ''
end

-- 最大抢庄具体数目
function DKGameLogic.getQzMaxInfoText(deskInfo)
	local idx = deskInfo.qzMax
	return DKGameLogic.QZMAXINFO[idx]
end

-- 自动开始
function DKGameLogic.getStartModeText(deskInfo)
	local idx = deskInfo.startMode
	return DKGameLogic.STARTMODE[idx] or ''
end

-- 抢庄or轮庄Text
function DKGameLogic.getXuanzhuangText(deskInfo)
	local idx = deskInfo.xuanzhuang
	return DKGameLogic.XZ[idx] or ''
end

-- 房间规则
function DKGameLogic.getRoomRuleText(deskInfo)
	local roomRuleText = ""
	roomRuleText = DKGameLogic.getPayModeText(deskInfo).."支付"
	roomRuleText = roomRuleText .. " 下注" ..DKGameLogic.getPutMoneyText(deskInfo)
	roomRuleText = roomRuleText .. " " .. DKGameLogic.getXuanzhuangText(deskInfo)
	roomRuleText = roomRuleText .. " " ..DKGameLogic.getStartModeText(deskInfo)
	return roomRuleText
end

function DKGameLogic.isEnableCuoPai(deskInfo)
	if deskInfo.advanced and deskInfo.advanced[3] > 0 then
		return false
	end
	return true
end

function DKGameLogic.findNiuniuCnt(cards)
    local niuCnt = 0
	local maxCard = DKGameLogic.CARDS[cards[1]]

    if cards then
		local max = 0
        for _, v in ipairs(cards) do
			max = max + DKGameLogic.CARDS[v]
        end

    end
	niuCnt = max % 10
    return niuCnt, maxCard
end

function DKGameLogic.sortCards(cards)

	local value = DKGameLogic.CARDS_LOGICE_VALUE
	local cardcolor = DKGameLogic.HEX_CARDS_DATA

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
	return cards
end

function DKGameLogic.getLocalCardType(cardsdata, gameplay, setting, wanfa)
	local cards = DKGameLogic.sortCards(cardsdata)
	local cnt, maxCard = DKGameLogic.findNiuniuCnt(cards)
	cnt = cnt or 0
	local spType, spKey = DKGameLogic.getSpecialType(cards, gameplay, setting, wanfa)
	return cnt, spType, spKey, maxCard
end

return DKGameLogic 