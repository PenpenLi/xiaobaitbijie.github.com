local PJGameLogic = {}

PJGameLogic.SPECIAL_LONG_TEXT= {
	BOOM = '炸弹',
	GUIZI = '鬼子',
	ZHIZUN = '至尊',
	TIANJIU = '天九王',
	DIJIU = '地九娘娘',
    DUITIAN = '对天',
    DUIDI = '对地',
    DUIREN = '对人',
    DUIHE = '对鹅',
    DILIU = '对长',
    DIQI = '对短',
	-- DIBA = '第八',
	ZAJIU = '对杂九',
	ZABA = '对杂八',
	ZAQI = '对杂七',
	ZAWU = '对杂五',
	TIANGANG = '天杠',
	DIGANG = '地杠',
}

PJGameLogic.SPECIAL_SHORT_TEXT = {
	BOOM = '炸弹',
	GUIZI = '鬼子',
	ZHIZUN = '至尊',
	TIANJIU = '天九王',
	DIJIU = '地九娘娘',
    DUITIAN = '对天',
    DUIDI = '对地',
    DUIREN = '对人',
    DUIHE = '对鹅',
    DILIU = '对长',
    DIQI = '对短',
	-- DIBA = '第八',
	ZAJIU = '对杂九',
	ZABA = '对杂八',
	ZAQI = '对杂七',
	ZAWU = '对杂五',
	TIANGANG = '天杠',
	DIGANG = '地杠',
}

PJGameLogic.SPECIAL_MUL_TEXT = {
	BOOM = '炸弹(1倍)',
	GUIZI = '鬼子(1倍)',
	ZHIZUN = '至尊(1倍)',
	TIANJIU = '天九王(1倍)',
	DIJIU = '地九娘娘(1倍)',
    DUITIAN = '对天(1倍)',
    DUIDI = '对地(1倍)',
    DUIREN = '对人(1倍)',
    DUIHE = '对鹅(1倍)',
    DILIU = '对长(1倍)',
    DIQI = '对短(1倍)',
	-- DIBA = '第八',
	ZAJIU = '对杂九(1倍)',
	ZABA = '对杂八(1倍)',
	ZAQI = '对杂七(1倍)',
	ZAWU = '对杂五(1倍)',
	TIANGANG = '天杠(1倍)',
	DIGANG = '地杠(1倍)',
}

PJGameLogic.NIUMUL_FK = '2点~9点    2~9倍'

PJGameLogic.GAMEPLAY = {
  '加锅牌九',
  '加锅牌九',
}

PJGameLogic.STARTMODE = {
	'手动开始',
	'满2人开',
	'满4人开',
	'满6人开',
}

PJGameLogic.PUTMONEY = {
	-- '无推注',
	-- '5倍封顶',
	-- '10倍封顶',
	-- '15倍封顶',
	-- '25倍封顶',
	-- '35倍封顶',
	-- '45倍封顶',
	'10分',
	'20分',
	'30分',
	'50分',
}

PJGameLogic.PUTMONEYINFO = {
	10,
	20,
	30,
	50,
}

PJGameLogic.XZ = {
	'抢庄',
	'轮庄',
}

PJGameLogic.QZMAX = {
	'1倍',
	'2倍',
	'3倍',
	'4倍',
}

PJGameLogic.QZMAXINFO = {
	{1},
	{1,2},
	{1,2,3},
	{1,2,3,4},
}

PJGameLogic.BASE = {
	['50'] = '50',
	['80'] = '80',
	['100'] = '100',
}

PJGameLogic.BASEINFO = {
	['2/4/6/8'] = {2,4,6,8},
}

PJGameLogic.SPECIAL_EMUN = {
	BOOM = 17,
	GUIZI = 16,
	ZHIZUN = 15,
	TIANJIU = 14,
	DIJIU = 13,
    DUITIAN = 12,
    DUIDI = 11,
    DUIREN = 10,
    DUIHE = 9,
    DILIU = 8,
    DIQI = 7,
	-- DIBA = 3,
	ZAJIU = 6,
	ZABA = 5,
	ZAQI = 4,
	ZAWU = 3,
	TIANGANG = 2,
	DIGANG = 1,
}

PJGameLogic.CLIENT_SETTING = {
	BOOM = 17,
	GUIZI = 16,
	ZHIZUN = 15,
	TIANJIU = 14,
	DIJIU = 13,
    DUITIAN = 12,
    DUIDI = 11,
    DUIREN = 10,
    DUIHE = 9,
    DILIU = 8,
    DIQI = 7,
	-- DIBA = 3,
	ZAJIU = 6,
	ZABA = 5,
	ZAQI = 4,
	ZAWU = 3,
	TIANGANG = 2,
	DIGANG = 1,
}

PJGameLogic.NIU_MULNUM = {
	default = {
		{[2] = 2, [3] = 3, [4] = 4, [5] = 5, [6] = 6, [7] = 7, [8] = 8, [9] = 9, [0] = 0},
		{[2] = 2, [3] = 3, [4] = 4, [5] = 5, [6] = 6, [7] = 7, [8] = 8, [9] = 9, [0] = 0},
	},
	[1] = {
		{[2] = 1, [3] = 1, [4] = 1, [5] = 1, [6] = 1, [7] = 1, [8] = 1, [9] = 1, [0] = 1},
	}
}

PJGameLogic.SPECIAL_MULNUM = {
	default = {
		BOOM = 1,
		GUIZI = 1,
		ZHIZUN = 1,
		TIANJIU = 1,
		DIJIU = 1,
		DUITIAN = 1,
		DUIDI = 1,
		DUIREN = 1,
		DUIHE = 1,
		DILIU = 1,
		DIQI = 1,
		-- DIBA = 1,
		ZAJIU = 1,
		ZABA = 1,
		ZAQI = 1,
		ZAWU = 1,
		TIANGANG = 1,
		DIGANG = 1,
	}
}

PJGameLogic.CARDS = {
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

PJGameLogic.CARDS_LOGICE_VALUE = {
	['A'] = 1, ['2'] = 2, ['3'] = 3, ['4'] = 4, ['5'] = 5,
	['6'] = 6, ['7'] = 7, ['8'] = 8, ['9'] = 9,
	['T'] = 10, ['J'] = 11, ['Q'] = 12, ['K'] = 13,
	['☆'] = 14, ['★'] = 6,
}

PJGameLogic.HEX_CARDS_DATA = {
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

function PJGameLogic.getSpecificType(maxCard, specailType)
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

function PJGameLogic.getSpecialTypeByVal(gameplay, spVal)
	local tabEmun = PJGameLogic.SPECIAL_EMUN
	if spVal and spVal > 0 then
		for key, val in pairs(tabEmun) do
			if val == spVal then
				return key
			end
		end
	end
end

function PJGameLogic.getSpecialType(cards, gameplay, setting)

	-- 分析撲克
	local value = PJGameLogic.CARDS_LOGICE_VALUE
	
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
	
	local set = PJGameLogic.CLIENT_SETTING
	local spEmun = PJGameLogic.SPECIAL_EMUN

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

	local function aBoom()
		--炸弹
		if tabHandVal[2] == 3 and
		tabHandVal[1] == 8 and
		isEnabled(set.BOOM) 
		then
			return true, spEmun.BOOM
		end
	end

	local function aGuiZi()
		--鬼子
		if tabHandVal[2] == 9 and
		tabHandVal[1] == 11 and 
		isEnabled(set.GUIZI)  
		then
			return true, spEmun.GUIZI
		end
	end
	
	local function aZhiZun()
        -- 至尊
		if tabHandVal[2] == 3 and
		hasDaWang and
        isEnabled(set.ZHIZUN)
        then
            return true, spEmun.ZHIZUN
        end
    end

	local function aDuiTian()
		-- 对天
		if tabHandVal[1] == tabHandVal[2] and
		tabHandVal[1] == 12 and
        isEnabled(set.DUITIAN)
        then
            return true, spEmun.DUITIAN
        end
	end
	
	local function aDuiDi()
		-- 对地
		if tabHandVal[1] == tabHandVal[2] and
		tabHandVal[1] == 2 and
        isEnabled(set.DUIDI)
        then
            return true, spEmun.DUIDI
        end
	end
	
	local function aDuiRen()
		-- 对人
		if tabHandVal[1] == tabHandVal[2] and
		tabHandVal[1] == 8 and
		tabHandSuit[1] == '♥' and
		tabHandSuit[2] == '♦' and
        isEnabled(set.DUIREN)
        then
            return true, spEmun.DUIREN
        end
	end
	
	local function aDuiHe()
		-- 对和
		if tabHandVal[1] == tabHandVal[2] and
		tabHandVal[1] == 4 and
		tabHandSuit[1] == '♥' and
		tabHandSuit[2] == '♦' and
        isEnabled(set.DUIHE)
        then
            return true, spEmun.DUIHE
        end
	end
	
	local function aDiLiu()
		-- 第六
		if tabHandVal[1] == tabHandVal[2] and
		tabHandSuit[1] == '♠' and
		tabHandSuit[2] == '♣' and
		(tabHandVal[1] == 4 or 
		tabHandVal[1] == 6 or
		tabHandVal[1] == 10) and
        isEnabled(set.DILIU)
        then
            return true, spEmun.DILIU
        end
	end
	
	local function aDiQi()
		-- 第七
		if tabHandVal[1] == tabHandVal[2] and
		tabHandSuit[1] == '♥' and
		tabHandSuit[2] == '♦' and
		(tabHandVal[1] == 11 or 
		tabHandVal[1] == 6 or
		tabHandVal[1] == 10 or
		tabHandVal[1] == 7) and
        isEnabled(set.DIQI)
        then
            return true, spEmun.DIQI
        end
	end

	local function aDiBa()
		-- 第八
		if tabHandVal[1] == tabHandVal[2] and
		tabHandSuit[1] == '♥' and
		tabHandSuit[2] == '♦' and
		(tabHandVal[1] == 9 or 
		tabHandVal[1] == 5) and
        isEnabled(set.DIBA)
        then
			return true, spEmun.DIBA
		elseif tabHandVal[1] == tabHandVal[2] and
		tabHandSuit[1] == '♠' and
		tabHandSuit[2] == '♣' and
		(tabHandVal[1] == 8 or 
		tabHandVal[1] == 7) and
        isEnabled(set.DIBA)
        then
			return true, spEmun.DIBA
        end
	end
	
	local function aZaJiu()
		-- 对杂九
		if tabHandVal[1] == tabHandVal[2] and
		tabHandSuit[1] == '♥' and
		tabHandSuit[2] == '♦' and
		tabHandVal[1] == 9 and
        isEnabled(set.ZAJIU)
        then
			return true, spEmun.ZAJIU
        end
	end

	local function aZaBa()
		-- 对杂八
		if tabHandVal[1] == tabHandVal[2] and
		tabHandSuit[1] == '♠' and
		tabHandSuit[2] == '♣' and
		tabHandVal[1] == 8 and
        isEnabled(set.ZABA)
        then
			return true, spEmun.ZABA
        end
	end

	local function aZaQi()
		-- 对杂七
		if tabHandVal[1] == tabHandVal[2] and
		tabHandSuit[1] == '♠' and
		tabHandSuit[2] == '♣' and
		tabHandVal[1] == 7 and
        isEnabled(set.ZAQI)
        then
			return true, spEmun.ZAQI
        end
	end

	local function aZaWu()
		-- 对杂五
		if tabHandVal[1] == tabHandVal[2] and
		tabHandSuit[1] == '♥' and
		tabHandSuit[2] == '♦' and
		tabHandVal[1] == 5 and
        isEnabled(set.ZAWU)
        then
			return true, spEmun.ZAWU
        end
	end

	local function aTianJiu()
		-- 天九王
		if tabHandVal[2] == 9 and
		tabHandVal[1] == 12 and
        isEnabled(set.TIANJIU)
        then
            return true, spEmun.TIANJIU
        end
	end

	local function aDiJiu()
		-- 地九娘娘
		if tabHandVal[2] == 2 and
		tabHandVal[1] == 9 and
        isEnabled(set.DIJIU)
        then
            return true, spEmun.DIJIU
        end
	end

	local function aTianGang()
		-- 天杠
		if tabHandVal[2] == 8 and
		tabHandVal[1] == 12 and
        isEnabled(set.TIANGANG)
        then
            return true, spEmun.TIANGANG
        end
	end

	local function aDiGang()
		-- 地杠
		if tabHandVal[2] == 2 and
		tabHandVal[1] == 8 and
        isEnabled(set.DIGANG)
        then
            return true, spEmun.DIGANG
        end
	end
	-------------------------------------------------------------------------------
	-- 优先级
	local tabFunc = {aBoom,aGuiZi, aZhiZun, aTianJiu, aDiJiu, aDuiTian, aDuiDi, aDuiRen, aDuiHe, aDiLiu, aDiQi, aZaJiu, aZaBa, aZaQi, aZaWu, aTianGang, aDiGang} -- 普通模式

	local type = 0
	for i,v in ipairs(tabFunc) do
		local bool, val = v()
		if bool then
			type = val
			break
		end
	end

	return type, PJGameLogic.getSpecialTypeByVal(gameplay, type)
end

function PJGameLogic.getMul(gamePlay, setting, niuCnt, specialType)
	setting = setting or 1
	
	if specialType and specialType > 0 then
		local type = PJGameLogic.getSpecialTypeByVal(gamePlay, specialType)
		local mulTab = PJGameLogic.SPECIAL_MULNUM.default
		if PJGameLogic.SPECIAL_MULNUM[gamePlay] then
			mulTab = PJGameLogic.SPECIAL_MULNUM[gamePlay]
		end
		return mulTab[type]
	end
	
	if niuCnt then
		local mulTab = PJGameLogic.NIU_MULNUM.default
		if PJGameLogic.NIU_MULNUM[gamePlay] then
			mulTab = PJGameLogic.NIU_MULNUM[gamePlay]
		end
		return mulTab[setting] [niuCnt]
	end
	
end

function PJGameLogic.getSetting(gameplay, setNum)
	local tabSetting = PJGameLogic.CLIENT_SETTING
	for name, v in pairs(tabSetting) do
		if v > 0 and setNum and v == setNum then
			return name
		end
	end
end

-- 哈希表转数组
function PJGameLogic.hashCountsToArray(hash)
    local a = {}
    for k, v in pairs(hash) do
        for _ = 1, v do
          a[#a + 1] = k
        end
    end
    return a
end


-- mode: 1:五小牛。。。 | 2:五小  |  3:五小牛（8倍） 
function PJGameLogic.getSpecialText(deskInfo, mode, oneLine)
	mode = mode or 3

	local gameplay = deskInfo.gameplay
	local tabRule
	if mode == 1 then -- 长文本
		tabRule = PJGameLogic.SPECIAL_LONG_TEXT
	elseif mode == 2 then	-- 短文本
		tabRule = PJGameLogic.SPECIAL_SHORT_TEXT
	elseif mode == 3 then -- 带倍数
		tabRule = PJGameLogic.SPECIAL_MUL_TEXT
	else
		tabRule = PJGameLogic.SPECIAL_LONG_TEXT
	end

	local special = deskInfo.special
	local ruleText = ""
	local addCnt = 0
    for i, v in pairs(special) do 
        if v > 0 then
            local spName = PJGameLogic.getSetting(gameplay, v)
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
function PJGameLogic.getAdvanceText(deskInfo)
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
function PJGameLogic.getBaseText(deskInfo)
	local base = deskInfo.base
	return PJGameLogic.BASE[base] or base
end

--2/4——{2,4}
function PJGameLogic.getBaseInfoText(deskInfo)
	local base = deskInfo.base
	return PJGameLogic.BASEINFO[base]
end

function PJGameLogic.getPutMoneyData(deskInfo)
	local putmoney = deskInfo.putmoney
	return PJGameLogic.PUTMONEYINFO[putmoney]
end

-- 牛9X5 。。。
function PJGameLogic.getNiuNiuMulText(deskInfo, mode)
	local mul = deskInfo.multiply

	if mul == 1 then
		return PJGameLogic.NIUMUL_1
	else 
		return PJGameLogic.NIUMUL_2
	end

end

-- 牛牛玩法
function PJGameLogic.getGameplayText(deskInfo)
	local idx = deskInfo.gameplay
	return PJGameLogic.GAMEPLAY[idx] or ''
end

-- 支付方式
function PJGameLogic.getPayModeText(deskInfo)
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
function PJGameLogic.getRoomLimitText(deskInfo)
    local text = '无'
    if deskInfo.roomMode == 'bisai' and deskInfo.scoreOption then
        local options = deskInfo.scoreOption
        text = '入场:' .. options.join .. '  抢庄:' .. options.qiang .. '  推注:' .. options.tui 
            .. '  抽水:' .. options.choushui_pj .. '%  ' .. ( options.rule == 1 and '大赢家抽水' or '赢家抽水')
        -- text = '入场:' .. options.join .. '  普通玩家:' .. options.choushui_all
		-- 	.. '  抽水:' .. options.choushui_pj .. ( options.rule == 1 and '  大赢家抽水' or '赢家抽水')
		-- 	.. '  额外抽水:' .. options.choushui_extra
    end
    return text
end


-- 推注选项
function PJGameLogic.getPutMoneyText(deskInfo)
	local idx = deskInfo.putmoney
	return PJGameLogic.PUTMONEY[idx] or ''
end

-- 最大抢庄
function PJGameLogic.getQzMaxText(deskInfo)
	local idx = deskInfo.qzMax
	return PJGameLogic.QZMAX[idx] or ''
end

-- 最大抢庄具体数目
function PJGameLogic.getQzMaxInfoText(deskInfo)
	local idx = deskInfo.qzMax
	return PJGameLogic.QZMAXINFO[idx]
end

-- 自动开始
function PJGameLogic.getStartModeText(deskInfo)
	local idx = deskInfo.startMode
	return PJGameLogic.STARTMODE[idx] or ''
end

-- 抢庄or轮庄Text
function PJGameLogic.getXuanzhuangText(deskInfo)
	local idx = deskInfo.xuanzhuang
	return PJGameLogic.XZ[idx] or ''
end

-- 房间规则
function PJGameLogic.getRoomRuleText(deskInfo)
	local roomRuleText = ""
	roomRuleText = PJGameLogic.getPayModeText(deskInfo).."支付"
	roomRuleText = roomRuleText .. " 最低押注" ..PJGameLogic.getPutMoneyText(deskInfo)
	roomRuleText = roomRuleText .. " " .. PJGameLogic.getXuanzhuangText(deskInfo)
	roomRuleText = roomRuleText .. " " ..PJGameLogic.getStartModeText(deskInfo)
	return roomRuleText
end

function PJGameLogic.isEnableCuoPai(deskInfo)
	if deskInfo.advanced and deskInfo.advanced[3] > 0 then
		return false
	end
	return true
end

function PJGameLogic.findNiuniuCnt(cards)
    local niuCnt = 0
	local maxCard = PJGameLogic.CARDS[cards[1]]

    if cards then
		local max = 0
        for _, v in ipairs(cards) do
			max = max + PJGameLogic.CARDS[v]
        end

    end
	niuCnt = max % 10
    return niuCnt, maxCard
end

function PJGameLogic.sortCards(cards)

	local value = PJGameLogic.CARDS_LOGICE_VALUE
	local cardcolor = PJGameLogic.HEX_CARDS_DATA

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

function PJGameLogic.getLocalCardType(cardsdata, gameplay, setting)
	local cards = PJGameLogic.sortCards(cardsdata)
	local cnt, maxCard = PJGameLogic.findNiuniuCnt(cards)
	cnt = cnt or 0
	local spType, spKey = PJGameLogic.getSpecialType(cards, gameplay, setting)
	return cnt, spType, spKey, maxCard
end

return PJGameLogic 