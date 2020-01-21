local ShareView = {}

function ShareView:initialize()
end

function ShareView:layout(data)
	local MainPanel = self.ui:getChildByName('MainPanel')
	MainPanel:setContentSize(cc.size(display.width,display.height))
	MainPanel:setPosition(display.cx,display.cy)
	self.MainPanel = MainPanel

	local middle = MainPanel:getChildByName('middle')
	middle:setPosition(display.cx,display.cy)
	middle:setVisible(false)

	local invite = MainPanel:getChildByName('invite')
	invite:setPosition(display.cx,display.cy)
	invite:setVisible(false)
	
	middle:setVisible(true)
	-- dump(data)
	-- if data and data.deskId then
		-- 	invite:setVisible(true)
	-- else
	-- 	middle:setVisible(true)
	-- end
end

return ShareView