local WanFaView = {}
function WanFaView:initialize()
end

function WanFaView:layout(mode)
  local MainPanel = self.ui:getChildByName('MainPanel')
  MainPanel:setContentSize(cc.size(display.width,display.height))
  MainPanel:setPosition(display.cx,display.cy)
  self.MainPanel = MainPanel

  local middle = MainPanel:getChildByName('middle')
  middle:setPosition(display.cx,display.cy)  
  self.ListView_nn = middle:getChildByName('rulePanel'):getChildByName('nn')   
  self.ListView_sg = middle:getChildByName('rulePanel'):getChildByName('sg')   
  self.ListView_dk = middle:getChildByName('rulePanel'):getChildByName('dk')   
  self.ListView_zjh= middle:getChildByName('rulePanel'):getChildByName('zjh')   
  self.nn = middle:getChildByName('nn')
  self.sg = middle:getChildByName('sg')
  self.dk = middle:getChildByName('dk')
  self.zjh = middle:getChildByName('zjh')
  --middle:setVisible(false)

  --local TopBar = MainPanel:getChildByName('TopBar')
  --TopBar:setPositionY(display.height)

  --local bg = MainPanel:getChildByName('bg')
  --bg:setContentSize(cc.size(display.width,display.height))
  --bg:setPosition(display.cx,display.cy)

  -- self.focus = 'nn'
  self:clickTab('nn')
  self.dk:setVisible(false)
  if mode and mode == 2 then
    self.dk:setVisible(true)
  end 
end

function WanFaView:clickTab(tag)
  -- self.focus = tag
  self.ListView_nn:setVisible(false)
  self.ListView_sg:setVisible(false)
  self.ListView_dk:setVisible(false)
  self.ListView_zjh:setVisible(false)
  self.nn:getChildByName('active'):setVisible(false)
  self.sg:getChildByName('active'):setVisible(false)
  self.dk:getChildByName('active'):setVisible(false)
  self.zjh:getChildByName('active'):setVisible(false)
  self[tag]:getChildByName('active'):setVisible(true)
  self['ListView_' .. tag]:setVisible(true)
end

return WanFaView
