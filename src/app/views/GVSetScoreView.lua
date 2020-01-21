local Scheduler = require('app.helpers.Scheduler')
local SoundMng = require('app.helpers.SoundMng')
local tools = require('app.helpers.tools')
local ConvertToTableView = require('app.helpers.ConvertToTableView')
local cache = require('app.helpers.cache')
local app = require('app.App'):instance()

local GVSetScoreView = {}

local default_join = 400
local default_qiang = 400
local default_tui = 400

function GVSetScoreView:initialize()
	self.group = nil

end

function GVSetScoreView:layout(data)
	self.group = data[1]
	self.mode = data[2]
	self.ishehuo = data[3]
	self.hehuoId = data[4]

	local mainPanel = self.ui:getChildByName('MainPanel')
	mainPanel:setPosition(display.cx, display.cy)

	self.roomlitLayer = mainPanel:getChildByName('roomlimit')
	self.fanshuiLayer = mainPanel:getChildByName('fanshui')
	self.zhuanrangLayer = mainPanel:getChildByName('zhuanrang')
	self.shangfenLayer = mainPanel:getChildByName('shangfen')
	self.bankLayer = mainPanel:getChildByName('bank')

	self.roomlitLayer:setVisible(false)
	self.fanshuiLayer:setVisible(false)
	self.zhuanrangLayer:setVisible(false)
	self.shangfenLayer:setVisible(false)
	self.bankLayer:setVisible(false)
	-- self:freshLayer(self.mode)
end

function GVSetScoreView:freshLayer(msg)
	local mode = msg.mode
	local data = msg.data
	if mode == 'fanshui' then
		self.fanshuiLayer:setVisible(true)
		self:freshChoushuiPart(data, msg)
	elseif mode == 'roomlimit' then
		dump(data)
		self.roomlitLayer:setVisible(true)

		local join = self.roomlitLayer:getChildByName('join')
		self.joinEditBox = tools.createEditBox(join, {
			-- holder
			defaultString = data.join or '' .. default_join,
			holderSize = 25,
			holderColor = cc.c3b(185,198,254),

			-- text
			fontColor = cc.c3b(185,198,254),
			size = 25,
			maxCout = 6,
			fontType = 'views/font/Fangzheng.ttf',	
			inputMode = cc.EDITBOX_INPUT_MODE_SINGLELINE,
		})
		self.join = data.join or '' .. default_join

		local qiang = self.roomlitLayer:getChildByName('qiang')
		self.qiangEditBox = tools.createEditBox(qiang, {
			-- holder
			defaultString = data.qiang or '' .. default_qiang,
			holderSize = 25,
			holderColor = cc.c3b(185,198,254),

			-- text
			fontColor = cc.c3b(185,198,254),
			size = 25,
			maxCout = 6,
			fontType = 'views/font/Fangzheng.ttf',	
			inputMode = cc.EDITBOX_INPUT_MODE_SINGLELINE,
		})
		self.qiang = data.qiang or '' .. default_qiang

		local tui = self.roomlitLayer:getChildByName('tui')
		self.tuiEditBox = tools.createEditBox(tui, {
			-- holder
			defaultString = data.tui or '' .. default_tui,
			holderSize = 25,
			holderColor = cc.c3b(185,198,254),

			-- text
			fontColor = cc.c3b(185,198,254),
			size = 25,
			maxCout = 6,
			fontType = 'views/font/Fangzheng.ttf',	
			inputMode = cc.EDITBOX_INPUT_MODE_SINGLELINE,
		})
		self.tui = data.tui or '' .. default_tui

		local choushui = self.roomlitLayer:getChildByName('choushui')
		choushui:setString('' .. data.choushui .. '%')
		self.choushui = data.choushui

		data.choushui_dk = data.choushui_dk or 0
		local choushui_dk = self.roomlitLayer:getChildByName('dk'):getChildByName('choushui')
		choushui_dk:setString('' .. data.choushui_dk .. '%')
		self.choushui_dk = data.choushui_dk

		data.choushui_sg = data.choushui_sg or 0
		local choushui_sg = self.roomlitLayer:getChildByName('sg'):getChildByName('choushui')
		choushui_sg:setString('' .. data.choushui_sg .. '%')
		self.choushui_sg = data.choushui_sg

		data.choushui_pj = data.choushui_pj or 0
		local choushui_pj = self.roomlitLayer:getChildByName('pj'):getChildByName('choushui')
		choushui_pj:setString('' .. data.choushui_pj .. '%')
		self.choushui_pj = data.choushui_pj

		data.choushui_zjh = data.choushui_zjh or 0
		local choushui_zjh = self.roomlitLayer:getChildByName('zjh'):getChildByName('choushui')
		choushui_zjh:setString('' .. data.choushui_zjh .. '%')
		self.choushui_zjh = data.choushui_zjh

		local rule1 = self.roomlitLayer:getChildByName('1')
		local rule2 = self.roomlitLayer:getChildByName('2')
		local rule = data.rule or 1
		self:freshRule(rule == 1 and rule1 or rule2)
	elseif mode == 'shangfen' then
		self.shangfenLayer:setVisible(true)
		self:freshShangfenPart(data, msg)
	elseif mode == 'zhuanrang' then
		self.zhuanrangLayer:setVisible(true)
		local input = self.zhuanrangLayer:getChildByName('input')
		self.playerIDEditBox = tools.createEditBox(input, {
			-- holder
			defaultString = '请输入要转让的成员ID',
			holderSize = 25,
			holderColor = cc.c3b(185,198,254),

			-- text
			fontColor = cc.c3b(185,198,254),
			size = 25,
			maxCout = 6,
			fontType = 'views/font/Fangzheng.ttf',	
			inputMode = cc.EDITBOX_INPUT_MODE_SINGLELINE,
		})
	elseif mode == 'bank' then
		self.bankLayer:setVisible(true)
		self.bankLayer:getChildByName('first'):setVisible(true)
		
		local logionPw = self.bankLayer:getChildByName('first'):getChildByName('input')
		self.logionPwEditBox = tools.createEditBox(logionPw, {
			-- holder
			defaultString = '请输入密码',
			holderSize = 25,
			holderColor = cc.c3b(185,198,254),

			-- text
			fontColor = cc.c3b(185,198,254),
			size = 25,
			maxCout = 8,
			fontType = 'views/font/Fangzheng.ttf',	
			inputMode = cc.EDITBOX_INPUT_MODE_SINGLELINE,
			inputFlag = cc.EDITBOX_INPUT_FLAG_PASSWORD
		})

		local number = self.bankLayer:getChildByName('second'):getChildByName('left'):getChildByName('input')
		self.numberEditBox = tools.createEditBox(number, {
			-- holder
			defaultString = '请输入9位内数字',
			holderSize = 25,
			holderColor = cc.c3b(185,198,254),

			-- text
			fontColor = cc.c3b(185,198,254),
			size = 25,
			maxCout = 9,
			fontType = 'views/font/Fangzheng.ttf',	
			inputMode = cc.EDITBOX_INPUT_MODE_NUMERIC,
		})

		local password = self.bankLayer:getChildByName('second'):getChildByName('right'):getChildByName('input')
		self.passwordEditBox = tools.createEditBox(password, {
			-- holder
			defaultString = '请输入原来的密码',
			holderSize = 25,
			holderColor = cc.c3b(185,198,254),

			-- text
			fontColor = cc.c3b(185,198,254),
			size = 25,
			maxCout = 8,
			fontType = 'views/font/Fangzheng.ttf',	
			inputMode = cc.EDITBOX_INPUT_MODE_SINGLELINE,
			inputFlag = cc.EDITBOX_INPUT_FLAG_PASSWORD
		})

		local password1 = self.bankLayer:getChildByName('second'):getChildByName('right'):getChildByName('input1')
		self.password1EditBox = tools.createEditBox(password1, {
			-- holder
			defaultString = '请输入新密码',
			holderSize = 25,
			holderColor = cc.c3b(185,198,254),

			-- text
			fontColor = cc.c3b(185,198,254),
			size = 25,
			maxCout = 8,
			fontType = 'views/font/Fangzheng.ttf',	
			inputMode = cc.EDITBOX_INPUT_MODE_SINGLELINE,
			inputFlag = cc.EDITBOX_INPUT_FLAG_PASSWORD
		})

		local password2 = self.bankLayer:getChildByName('second'):getChildByName('right'):getChildByName('input2')
		self.password2EditBox = tools.createEditBox(password2, {
			-- holder
			defaultString = '请再次输入新密码',
			holderSize = 25,
			holderColor = cc.c3b(185,198,254),

			-- text
			fontColor = cc.c3b(185,198,254),
			size = 25,
			maxCout = 8,
			fontType = 'views/font/Fangzheng.ttf',	
			inputMode = cc.EDITBOX_INPUT_MODE_SINGLELINE,
			inputFlag = cc.EDITBOX_INPUT_FLAG_PASSWORD
		})
	end
end

------------------------反水部分--------------------------------------------------------------
function GVSetScoreView:freshChoushuiPart(data, msg)
	local yesterday_fanshui = self.fanshuiLayer:getChildByName('fanshui_text')
	local yesterday_fanshui1 = self.fanshuiLayer:getChildByName('fanshui_text1')
	local list = self.fanshuiLayer:getChildByName('list')
	local fanshuiList = self.fanshuiLayer:getChildByName('fanshuiList')

	if msg.day and (msg.day == 1 or self.hehuoId) then
		if msg.day == 1 and not self.hehuoId and fanshuiList:getItem(0) then
		else
			fanshuiList:setItemModel(list)
			fanshuiList:removeAllItems()
			fanshuiList:setScrollBarEnabled(false)
		
			-- dump(data)
			local idx = 0
			for i, v in pairs(data) do
				for j, k in pairs(v.chouShuiList) do
					fanshuiList:pushBackDefaultItem()
					local item = fanshuiList:getItem(idx)
					local time = os.date("%Y/%m/%d %H:%M:%S", v.time)
					item:getChildByName('time'):setString(time)
					item:getChildByName('id'):setString(k.playerId)
					item:getChildByName('nickname'):setString(k.nickName)
					item:getChildByName('num'):setString(k.score)
					idx = idx + 1
				end
			end
		end
	end
	yesterday_fanshui:setString('' .. msg.ydata)
	local text1 = '[昨天]总分成反水:'
	local text2 = '[昨天]总剩余反水:'
	if msg.day and msg.day == 2 then
		text1 = '[前天]总分成反水:'
		text2 = '[前天]总剩余反水:'
	elseif msg.day and msg.day == 3 then
		text1 = '[大前天]总分成反水:'
		text2 = '[大前天]总剩余反水:'
	end
	if self.ishehuo then
		yesterday_fanshui1:setString(text1 .. msg.ydata1)
	else
		yesterday_fanshui1:setString(text2 .. msg.ydata1)
	end

	local groupInfo = self.group:getCurGroup()
	if not groupInfo then return end
	local owenerId = groupInfo.ownerInfo.playerId
	local myPlayerId = self.group:getPlayerRes('playerId')
	if owenerId == myPlayerId then
		self.fanshuiLayer:getChildByName('1'):setVisible(true)
		self.fanshuiLayer:getChildByName('2'):setVisible(true)
		self.fanshuiLayer:getChildByName('3'):setVisible(true)
	end
end
----------------------------------------------------------------------------------------------

------------------------上下分部分-------------------------------------------------------------
function GVSetScoreView:freshShangfenPart(data, msg)
	local yesterday_shang = self.shangfenLayer:getChildByName('shangfen_text')
	local yesterday_xia = self.shangfenLayer:getChildByName('xiafen_text')
	local list = self.shangfenLayer:getChildByName('list')
	local shangfenList = self.shangfenLayer:getChildByName('shangfenList')
	shangfenList:setItemModel(list)
	shangfenList:removeAllItems()
	shangfenList:setScrollBarEnabled(false)

	local idx = 0

	for i, v in pairs(data) do
		shangfenList:pushBackDefaultItem()
		local item = shangfenList:getItem(idx)
		local time = os.date("%Y/%m/%d %H:%M:%S", v.time)
		item:getChildByName('id'):setString(v.memberId)
		item:getChildByName('operate'):setString(v.mode == 0 and '下分' or '上分')
		item:getChildByName('num'):setString(v.score)
		item:getChildByName('time'):setString(time)
		idx = idx + 1
	end
	yesterday_shang:setString('' .. msg.ysdata)
	yesterday_xia:setString('' .. msg.yxdata)
end
----------------------------------------------------------------------------------------------

------------------------转让群主部分-----------------------------------------------------------
function GVSetScoreView:getChangePlayerId()
	return self.playerIDEditBox:getText()
end
----------------------------------------------------------------------------------------------

------------------------房间限制部分-----------------------------------------------------------
function GVSetScoreView:freshChoushui(mode)
	local choushui = self.roomlitLayer:getChildByName('choushui')
	if mode == 'add' then
		self.choushui = self.choushui == 10 and 10 or (self.choushui + 1)
	elseif mode == 'reduce' then
		self.choushui = self.choushui == 0 and 0 or (self.choushui - 1)
	end
	choushui:setString('' .. self.choushui .. '%')
end

function GVSetScoreView:freshChoushuiDK(mode)
	local choushui_dk = self.roomlitLayer:getChildByName('dk'):getChildByName('choushui')
	if mode == 'add' then
		self.choushui_dk = self.choushui_dk == 10 and 10 or (self.choushui_dk + 1)
	elseif mode == 'reduce' then
		self.choushui_dk = self.choushui_dk == 0 and 0 or (self.choushui_dk - 1)
	end
	choushui_dk:setString('' .. self.choushui_dk .. '%')
end

function GVSetScoreView:freshChoushuiSG(mode)
	local choushui_sg = self.roomlitLayer:getChildByName('sg'):getChildByName('choushui')
	if mode == 'add' then
		self.choushui_sg = self.choushui_sg == 10 and 10 or (self.choushui_sg + 1)
	elseif mode == 'reduce' then
		self.choushui_sg = self.choushui_sg == 0 and 0 or (self.choushui_sg - 1)
	end
	choushui_sg:setString('' .. self.choushui_sg .. '%')
end

function GVSetScoreView:freshChoushuiZJH(mode)
	local choushui_zjh = self.roomlitLayer:getChildByName('zjh'):getChildByName('choushui')
	if mode == 'add' then
		self.choushui_zjh = self.choushui_zjh == 10 and 10 or (self.choushui_zjh + 1)
	elseif mode == 'reduce' then
		self.choushui_zjh = self.choushui_zjh == 0 and 0 or (self.choushui_zjh - 1)
	end
	choushui_zjh:setString('' .. self.choushui_zjh .. '%')
end

function GVSetScoreView:freshChoushuiPJ(mode)
	local choushui_pj = self.roomlitLayer:getChildByName('pj'):getChildByName('choushui')
	if mode == 'add' then
		self.choushui_pj = self.choushui_pj == 10 and 10 or (self.choushui_pj + 1)
	elseif mode == 'reduce' then
		self.choushui_pj = self.choushui_pj == 0 and 0 or (self.choushui_pj - 1)
	end
	choushui_pj:setString('' .. self.choushui_pj .. '%')
end

function GVSetScoreView:freshRule(sender)
	local rule1 = self.roomlitLayer:getChildByName('1')
	local rule2 = self.roomlitLayer:getChildByName('2')
	rule1:getChildByName('active'):setVisible(false)
	rule2:getChildByName('active'):setVisible(false)
	sender:getChildByName('active'):setVisible(true)
	self:freshColor(sender)
end

function GVSetScoreView:getRoomLimit()
	local msg = {}
	local join = self.joinEditBox:getText()
	local qiang = self.qiangEditBox:getText()
	local tui = self.tuiEditBox:getText()
	local rule1 = self.roomlitLayer:getChildByName('1')
	msg.join = join == '' and self.join or tonumber(join)
	msg.qiang = qiang == '' and self.qiang or tonumber(qiang)
	msg.tui = tui == '' and self.tui or tonumber(tui)
	msg.choushui = self.choushui
	msg.choushui_dk = self.choushui_dk or 0
	msg.choushui_sg = self.choushui_sg or 0
	msg.choushui_pj = self.choushui_jp or 0
	msg.choushui_zjh = self.choushui_zjh or 0
	msg.rule = rule1:getChildByName('active'):isVisible() and 1 or 2
	return msg
end

function GVSetScoreView:freshColor(sender)
	self.roomlitLayer:getChildByName('1'):getChildByName('text'):setColor(cc.c3b(185,198,254))
	self.roomlitLayer:getChildByName('2'):getChildByName('text'):setColor(cc.c3b(185,198,254))
	sender:getChildByName('text'):setColor(cc.c3b(246,185,254))
end
-----------------------------------------------------------------------------------------------

------------------------保险箱部分-----------------------------------------------------------
function GVSetScoreView:showBank(msg)
	local mode = msg.mode
	self.bankLayer:getChildByName('first'):setVisible(false)
	self.bankLayer:getChildByName('second'):setVisible(true)
	self.bankLayer:getChildByName('second'):getChildByName('left'):setVisible(false)
	self.bankLayer:getChildByName('second'):getChildByName('left'):setVisible(false)
	if mode == 'saveAndGet' then
		self.bankLayer:getChildByName('second'):getChildByName('left'):setVisible(true)
		self:freshBankMoney(msg.saveScore, msg.nowScore)
	else
		self.bankLayer:getChildByName('second'):getChildByName('right'):setVisible(true)
	end
end

function GVSetScoreView:freshBankMoney(saveScore, nowScore)
	if not saveScore or not nowScore then return end
	self.bankLayer:getChildByName('second'):getChildByName('left'):getChildByName('money'):setString('' .. saveScore)
	self.bankLayer:getChildByName('second'):getChildByName('left'):getChildByName('nowMoney'):setString('' .. nowScore)
end

function GVSetScoreView:getLoginPassWord()
	return self.logionPwEditBox:getText()
end

function GVSetScoreView:getNumber()
	return self.numberEditBox:getText()
end

function GVSetScoreView:getPassWord()
	return self.passwordEditBox:getText()
end

function GVSetScoreView:getPassWord1()
	return self.password1EditBox:getText()
end

function GVSetScoreView:getPassWord2()
	return self.password2EditBox:getText()
end
----------------------------------------------------------------------------------------------

function GVSetScoreView:getCurGroup()
	local groupInfo = self.group:getCurGroup()
	return groupInfo
end

return GVSetScoreView