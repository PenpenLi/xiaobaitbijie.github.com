local SocialShare = {}

if device.platform ~= "windows" then
    SocialShare = require("app.helpers.SocialShare")
end

local GameLogic = require("app.libs.niuniu.NNGameLogic")
local DKGameLogic = require("app.libs.depu.DKGameLogic")
local PJGameLogic = require("app.libs.paijiu.PJGameLogic")

local invokefriend = {}

function invokefriend.invoke(deskId, deskInfo, groupInfo, flag)
	if not deskId then return end
	if not deskInfo then return end

  --支付方式
  local roomprice = GameLogic.getPayModeText(deskInfo) .. '支付'
  -- 玩法
  local gameplayStr = GameLogic.getGameplayText(deskInfo)
  -- 底分
  local baseStr = GameLogic.getBaseText(deskInfo)
  -- 翻倍规则
  local mulStr = GameLogic.getNiuNiuMulText(deskInfo)
  -- 房间规则
  local advanceStr = GameLogic.getAdvanceText(deskInfo)
  -- 特殊牌
  local spStr = GameLogic.getSpecialText(deskInfo, 3, true)

	
  local share_url = string.format('http://fir.im/enk9?roomID=%s',deskId)
  local image_url = 'http://111.229.92.75/icon.png'
	

	-- 分享标题
	local title = "新世界【房间号：" .. deskId .. "】"

	-- 分享详情 
	local text = string.format(" 底分：%s, %d局, %s, %s, %s", 
		baseStr, 
    	deskInfo.round,
    	roomprice,
		gameplayStr,
		spStr
	)
	if groupInfo then
		text = string.format("俱乐部：%d, 底分：%s, %d局, %s, %s, %s", 
		groupInfo.id,
		baseStr, 
    	deskInfo.round,
    	roomprice,
		gameplayStr,
		spStr
	)
	end
	if device.platform ~= "windows" then
		SocialShare.share(
			1,
			function(platform, stCode, errorMsg)
				print("platform,stCode,errorMsg", platform, stCode, errorMsg)
			end,
			share_url,
			image_url,
			text,
			title,
			false,
			"invite",
			deskId,
			"2"
		)
	end
end

function invokefriend.invoke_dk(deskId, deskInfo, groupInfo, flag)
	if not deskId then return end
	if not deskInfo then return end

  --支付方式
--   local roomprice = GameLogic.getPayModeText(deskInfo) .. '支付'
  -- 玩法
  local gameplayStr = DKGameLogic.getGameplayText(deskInfo)
  -- 底分
  local baseStr = DKGameLogic.getBaseText(deskInfo)
  -- 翻倍规则
--   local mulStr = GameLogic.getNiuNiuMulText(deskInfo)
  -- 房间规则
--   local advanceStr = GameLogic.getAdvanceText(deskInfo)
  -- 特殊牌
--   local spStr = GameLogic.getSpecialText(deskInfo, 3, true)

	
  local share_url = string.format('http://fir.im/enk9?roomID=%s',deskId)
  local image_url = 'http://111.229.92.75/icon.png'
	

	-- 分享标题
	local title = "新世界【房间号：" .. deskId .. "】"

	-- 分享详情 
	local text = string.format(" 底分：%s", 
		baseStr 
    	-- deskInfo.round,
    	-- roomprice,
		-- gameplayStr,
		-- spStr
	)
	if groupInfo then
		text = string.format("俱乐部：%d, 底分：%s", 
		groupInfo.id,
		baseStr 
    	-- deskInfo.round,
    	-- roomprice,
		-- gameplayStr,
		-- spStr
	)
	end
	if device.platform ~= "windows" then
		SocialShare.share(
			1,
			function(platform, stCode, errorMsg)
				print("platform,stCode,errorMsg", platform, stCode, errorMsg)
			end,
			share_url,
			image_url,
			text,
			title,
			false,
			"invite",
			deskId,
			"2"
		)
	end
end

function invokefriend.invoke_pj(deskId, deskInfo, groupInfo, flag)
	if not deskId then return end
	if not deskInfo then return end

  --支付方式
--   local roomprice = GameLogic.getPayModeText(deskInfo) .. '支付'
  -- 玩法
  local gameplayStr = PJGameLogic.getGameplayText(deskInfo)
  -- 底分
  local baseStr = PJGameLogic.getBaseText(deskInfo)
  -- 翻倍规则
--   local mulStr = GameLogic.getNiuNiuMulText(deskInfo)
  -- 房间规则
--   local advanceStr = GameLogic.getAdvanceText(deskInfo)
  -- 特殊牌
--   local spStr = GameLogic.getSpecialText(deskInfo, 3, true)

	
  local share_url = string.format('http://fir.im/enk9?roomID=%s',deskId)
  local image_url = 'http://111.229.92.75/icon.png'
	

	-- 分享标题
	local title = "新世界【房间号：" .. deskId .. "】"

	-- 分享详情 
	local text = string.format(" 底分：%s", 
		baseStr 
    	-- deskInfo.round,
    	-- roomprice,
		-- gameplayStr,
		-- spStr
	)
	if groupInfo then
		text = string.format("俱乐部：%d, 底分：%s", 
		groupInfo.id,
		baseStr 
    	-- deskInfo.round,
    	-- roomprice,
		-- gameplayStr,
		-- spStr
	)
	end
	if device.platform ~= "windows" then
		SocialShare.share(
			1,
			function(platform, stCode, errorMsg)
				print("platform,stCode,errorMsg", platform, stCode, errorMsg)
			end,
			share_url,
			image_url,
			text,
			title,
			false,
			"invite",
			deskId,
			"2"
		)
	end
end

return invokefriend
