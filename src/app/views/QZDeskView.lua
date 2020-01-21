local SoundMng = require("app.helpers.SoundMng")
local XYDeskView = require('app.views.XYDeskView')
local Scheduler = require('app.helpers.Scheduler')
local app = require("app.App"):instance()
local QZDeskView = {}

local function mixin(self, script)
    for k, v in pairs(script) do
        -- added by hthuang: onExit can not be used
        -- assert(self[k] == nil, 'Your script "app/views/'..self.name..'.lua" should not have a member named: ' .. k)
        self[k] = v
    end
end

mixin(QZDeskView, XYDeskView)

function QZDeskView:initialize(ctrl)

    XYDeskView.initialize(self)

    if self.ui then
        self.ui:removeFromParent()
        self.ui = nil
    end

    local View = require('mvc.View')
    local desk = ctrl.desk
    if desk and desk:getPeopleSelectIdx() == 2 then
        print('八人明牌模式')
        self.ui = View.loadUI('views/XYDeskView2.csb')
        self:addChild(self.ui)
    elseif desk:getPeopleSelectIdx() == 3 then
        self.ui = View.loadUI('views/XYDeskView3.csb')
        self:addChild(self.ui)
    else
        self.ui = View.loadUI('views/XYDeskView.csb')
        self:addChild(self.ui)
    end

end

function QZDeskView:layout(desk)
    XYDeskView.layout(self, desk)

    local cpLayer = self.MainPanel:getChildByName('cpLayer')
    self.cpLayer = cpLayer
    self.rubLayer = nil    

    -- self:freshCuoPaiDisplay(true, {'♦Q','♦8','♦8','♦8','♦Q'})
end

-- 替换freshQZBar方法
function QZDeskView:freshQiangZhuangBar(bool, agent)
    local qzbar = self.MainPanel:getChildByName('qzbar')
    if not bool then
        qzbar:setVisible(false)
        return
    end

    local deskInfo = self.desk:getDeskInfo()
    local qzMax = deskInfo.qzMax
    local roomMode = deskInfo.roomMode
    local scoreOption = deskInfo.scoreOption

    qzbar:setScrollBarEnabled(false)
    local noBtn = qzbar:getChildByName('no')
    noBtn:setVisible(true)
    qzbar:getChildByName('one'):setVisible(false)
    qzbar:getChildByName('double'):setVisible(false)
    qzbar:getChildByName('triple'):setVisible(false)
    qzbar:getChildByName('four'):setVisible(false)

    local function show(qzMax)       
        local margin = qzbar:getItemsMargin()
        local cnt = qzMax + 1
        local itemWidth = noBtn:getContentSize().width * noBtn:getScaleX() * qzbar:getScaleX()
        local listWidth = (itemWidth*cnt) + (margin*(cnt-1))
        local posX = display.cx - (listWidth/2)
    
        qzbar:setPositionX(posX)
        qzbar:setVisible(true)
    end

    if roomMode and roomMode == 'bisai' then
        if agent then
            local groupScore = agent:getGroupScore()
            if groupScore < scoreOption.qiang then
                show(0)
                return 
            end
        end
    end

    if qzMax >= 1 then
        qzbar:getChildByName('one'):setVisible(true)
    end
    if qzMax >= 2 then
        qzbar:getChildByName('double'):setVisible(true)
    end
    if qzMax >= 3 then
        qzbar:getChildByName('triple'):setVisible(true)
    end
    if qzMax >= 4 then
        qzbar:getChildByName('four'):setVisible(true)
    end

    show(qzMax)
end


function QZDeskView:showCardsAtCuopai(data)
    local cards = self.cpLayer:getChildByName('cards')
    for i = 1, 4 do
        local card = cards:getChildByName('card' .. i)
        -- self:setFaceDisplay(card,'front',data[i])
        self:freshCardsTextureByNode(card, data[i])
        card:setVisible(true)
    end
end

--ios由于cocos引擎问题用的模型版搓牌
----------------------------------------------------------------------------------------------------
function QZDeskView:init3dLayer_ios(cardValue)
    if not self.cpLayer then
        print("cuopai: nil cplayer")
        return
    end

    -- 层和摄像机
    local layer3D = cc.Layer:create()
    self.cpLayer:addChild(layer3D,999)
    layer3D:setCameraMask(cc.CameraFlag.USER1)
    self.layer3D = layer3D

    self.cpLayer._camera = cc.Camera:createPerspective(45, display.width / display.height, 1,3000)
    self.cpLayer._camera:setCameraFlag(cc.CameraFlag.USER1)
    self.cpLayer._camera:setDepth(2)
    layer3D:addChild(self.cpLayer._camera)

    self.cpLayer._camera:setPosition3D(cc.vec3(0, 0, 310))
    self.cpLayer._camera:lookAt(cc.vec3(0,0,0), cc.vec3(0, 0, -1))


    -- 3D精灵
    local path = '3d/wonder4.c3b'
    local path1 = '3d/wonder3.c3b'
    local card3d = cc.Sprite3D:create(path)
    local card3d1 = cc.Sprite3D:create(path1)
    self.animation = cc.Animation3D:create(path)
    self.animation1 = cc.Animation3D:create(path1)
    if not card3d or not card3d1 then
        print("cuopai: nil card3d")
        return
    end 
    layer3D:addChild(card3d)
    self.card3d = card3d
    layer3D:addChild(card3d1)
    self.card3d1 = card3d1

    local app = require("app.App"):instance()
    local idx = app.localSettings:get('cuoPai')
    idx = idx or 1

    card3d:setTexture('3d/0' .. cardValue .. '.png')
    card3d1:setTexture('3d/paibei/paibei_' .. idx .. '.png')
    card3d:setCameraMask(cc.CameraFlag.USER1)
    card3d:setPosition3D(cc.vec3(0,-1.4,300))
    card3d:setRotation3D(cc.vec3(90,0,0))
    card3d:setScale(0.1)

    card3d1:setCameraMask(cc.CameraFlag.USER1)
    card3d1:setPosition3D(cc.vec3(0,-1.4,300))
    card3d1:setRotation3D(cc.vec3(90,0,0))
    card3d1:setScale(0.1)

    self.updown = 0
    self.animationfirst = nil
    self.animationfirst1 = nil 
    self.start1 = nil   
    self.dest1 = nil 

    --牌的值
    local scardvalue = cc.Sprite:create('3d/1' .. cardValue .. '.png')
    local scardvalue1 = cc.Sprite:create('3d/1' .. cardValue .. '.png')

    if not scardvalue or not scardvalue1 then
        print("cuopai: nil scardvalue")
        return
    end 

    layer3D:addChild(scardvalue)
    self.scardvalue = scardvalue  
    layer3D:addChild(scardvalue1)
    self.scardvalue1 = scardvalue1

    scardvalue:setCameraMask(cc.CameraFlag.USER1)
    scardvalue:setPosition3D(cc.vec3(-74,-105,0))
    scardvalue:setRotation3D(cc.vec3(0,0,0))
    scardvalue:setScale(0.3)

    scardvalue1:setCameraMask(cc.CameraFlag.USER1)
    scardvalue1:setPosition3D(cc.vec3(76,18,0))
    scardvalue1:setRotation3D(cc.vec3(180,180,0))
    scardvalue1:setScale(0.3)

    scardvalue:setOpacity(0)
    scardvalue1:setOpacity(0)
end


function QZDeskView:freshCardFlipAction(cardValue)
    if nil ~= self.animation and not self.cardFlip then

        local app = require("app.App"):instance()
        local idx = app.localSettings:get('cuoPai')
        idx = idx or 1

        self.card3d:setTexture('3d/0' .. cardValue .. '.png')
        self.card3d1:setTexture('3d/paibei/paibei_' .. idx .. '.png')
        self.card3d:setCameraMask(cc.CameraFlag.USER1)
        self.card3d1:setCameraMask(cc.CameraFlag.USER1)

        local animate = cc.Animate3D:createWithFrames(self.animation, 51, 80)
        local animate1 = cc.Animate3D:createWithFrames(self.animation1, 51, 80)
        local speed = 1.0
        animate:setSpeed(speed)
        animate:setTag(110)
        animate1:setSpeed(speed)
        animate1:setTag(120)

        local callback = function()
            -- 搓牌回调
            self.emitter:emit('cpBack', {msgID = 'cpBack'})
        end

        local callback1 = function()
            local animate2 = cc.FadeIn:create(0.5)
            self.scardvalue:runAction(animate2)
        end

        local callback2 = function()
            local animate2 = cc.FadeIn:create(0.5)
            self.scardvalue1:runAction(animate2)
        end

        local delay = cc.DelayTime:create(1.5)
        local showcardvalue = cc.Spawn:create( cc.CallFunc:create(callback1), cc.CallFunc:create(callback2))
        local sequence = cc.Sequence:create(animate, showcardvalue,delay, cc.CallFunc:create(callback))
        local sequence1 = cc.Sequence:create(animate1, showcardvalue,delay, cc.CallFunc:create(callback))

        self.card3d:stopAllActions()
        self.card3d:runAction(sequence)
        self.card3d1:stopAllActions()
        self.card3d1:runAction(sequence1)

        self.cardFlip = true
        self.card:addTouchEventListener(function() end)
    end
end

function QZDeskView:freshCardMoveAction(derection, start, dest)
    if start < 0 or dest < 0 then
        return
    end

    if nil ~= self.animation then
        local animate = cc.Animate3D:createWithFrames(self.animation, start, dest)
        local speed = 1.0
        animate:setSpeed(speed)
        animate:setTag(110)

        if self.card3d == nil then
            return
        end
        local animate1 = cc.Animate3D:createWithFrames(self.animation1, start, dest)
        local speed = 1.0
        animate1:setSpeed(speed)
        animate1:setTag(120)

        self.card3d:stopAllActions()

        if derection == 'up' then
            self.card3d1:runAction(animate1) 
            self.card3d:runAction(animate) --(cc.Sequence:create(animate,call))--
        elseif derection == 'down' then
            self.card3d1:runAction(animate1:reverse())
            self.card3d:runAction(animate:reverse())
        elseif derection == "reset" then
            animate1:setSpeed(6.0)
            self.card3d1:runAction(
                cc.Sequence:create(animate1:reverse(),
                cc.CallFunc:create(function()
                    self.bBlockTouch = false
                    end)
                ))

            animate:setSpeed(6.0)
            self.card3d:runAction(
                cc.Sequence:create(animate:reverse(),
                cc.CallFunc:create(function()
                    self.bBlockTouch = false
                    end)
                ))
            self.animationfirst = nil
        end
    end
end

function QZDeskView:runAction1(derection, start,dest )
    --防止start<0但还没运行完动画的情况出现
    if start < 0  then
        if dest > 0 then 
            start = 0
        else return end
    end
    --调整速度 根据滑动的距离设置动画的播放速度
    local speed = nil 
    if self.difY < 0 then  
        speed = self.dify / (dest - start)
    elseif self.difY == 0 then 
        speed = 1
    else 
        speed = (self.maxdify - self.dify) / (dest - start)
    end
    if speed == 0 then 
        speed = 1 
    end
    speed = math.floor(speed + 0.5)
    self.animationfirst = cc.Animate3D:createWithFrames(self.animation,start,dest)
    self.animationfirst1 = cc.Animate3D:createWithFrames(self.animation1,start,dest)
    self.start1 = start 
    self.dest1 = dest 
    self.time1 = cc.Director:getInstance():getTimeInMilliseconds()
    self.animationfirst:setSpeed(speed)
    self.animationfirst1:setSpeed(speed)
    if derection == 'up' then
        self.card3d1:runAction(self.animationfirst1) 
        self.card3d:runAction(self.animationfirst) 
    elseif derection == 'down' then
        self.card3d1:runAction(self.animationfirst1:reverse())
        self.card3d:runAction(self.animationfirst:reverse())
    end
    if dest == 50 then 
        self:freshCardFlipAction(self.paimian)
    end
end

function QZDeskView:freshCardMoveAction1(derection,start,dest)
    --判断是否为空 是就添加第一段动画
    if self.animationfirst == nil then 
        self:runAction1(derection,start,dest)
        return
    end
    --判断上一段动画是否放完 如果没放完则调整要放的帧数
    self.time2 = cc.Director:getInstance():getTimeInMilliseconds()
    local timeadvance = (self.time2 - self.time1)
    local framesadvance = (self.dest1 - self.start1) * 1000 / 30 
    if start == 0 or framesadvance == 0 then 
        timeadvance = 0 
    end
    local frames = self.start1 + timeadvance * 30 / 1000
    local frames1 = math.ceil(frames - (dest - start))
    local frames2 = math.floor(self.dest1 - timeadvance * 30 / 1000)
    if frames1 < 0 then 
        frames1 = 0 
    end
    if self.card3d == nil or self.card3d1 == nil then
        return
    end
    --判断时间间隔 假如比牌所要的时间短就刷新start 长就直接继续播放动画
    if timeadvance > framesadvance then 
        if dest + 1 > 51 then 
            self:freshCardFlipAction(self.paimian)
        else 
            self:runAction1(derection,start,dest)
        end
    else 
        self.card3d:stopAllActions()
        self.card3d1:stopAllActions()
        if dest + 1 > 51 then
            self:runAction1(derection,math.ceil( frames ),50)
        else
            if derection == 'down' then
                if start > frames then 
                    self:runAction1(derection, frames1, math.floor(frames))      --防止回滚太快时跳过了部分动画导致不连贯
                else
                    self:runAction1(derection, start, frames2)
                end
            else
                self:runAction1(derection,math.ceil(frames + 1),dest)      --自动+1帧避免在滑动距离太短时造成重复
            end                                                                 --播放同一帧动画导致动画跳动
        end
    end
end
----------------------------------------------------------------------------------------------------

--android用的新版搓牌
function QZDeskView:init3dLayer(cardData)
    local suit = self.suit_2_path[self:card_suit(cardData)]
    local rnk = self:card_rank(cardData) or '_joker'

    if not suit then return end
    if not rnk then return end
    
    local fileName = suit .. rnk
    local cardPath = '3d/0' .. suit .. rnk .. '.png'
    local cardIdx = self:getCurCuoPai()
    local backPath = '3d/paibei/paibei_' .. cardIdx .. '.png'

    -- 通过图片取得纹理id，和该纹理在plist图中的纹理坐标范围
    local function getTextureAndRange(szImage)
        local TextureCache = cc.Director:getInstance():getTextureCache()
        local tex = TextureCache:addImage(szImage)
        
        local rect = tex:getContentSize()
        local id = tex:getName() --纹理ID
        local bigWide = tex:getPixelsWide() --plist图集的宽度
        local bigHigh = tex:getPixelsHigh()

        -- 左右上下的纹理范围
        local ll = 0
        local rr = 1
        local tt = 0
        local bb = 1
        return id, {ll, rr, tt, bb}, {rect.width, rect.height}
    end

    -- 创建3D牌面，所需的顶点和纹理数据, size:宽高, texRange:纹理范围, bFront:是否正面
    local function initCardVertex(size, texRange, bFront, valTexTange)
        local nDiv = 50 
        local verts = {} --位置坐标
        local texs = {} --纹理坐标
        local dh = size.height / nDiv
        local dw = size.width / nDiv

        local valW = 168*0.9
        local valH = 66*0.9
        local valX = size.width - valW -10
        local valY =  7

        local valW1 = valW
        local valH1 = valH
        local valX1 = 10
        local valY1 =  size.height - 66

        local valVer = {}
        local valTex = {}

        local valVer1 = {}
        local valTex1 = {}

        local function isInValRange(x, y)
            local xIn = valX<=x and x<=(valW+valX)
            local yIn = valY<=y and y<=(valH+valY)
            return xIn and yIn
        end

        local function isInValRange1(x, y)
            local xIn = valX1<=x and x<=(valW1+valX1)
            local yIn = valY1<=y and y<=(valH1+valY1)
            return xIn and yIn
        end

        --计算顶点位置
        for row = 1, nDiv do
            for line = 1, nDiv do
                local x = (row - 1)* dw
                local y = (line - 1)* dh
                local quad = {}
                if bFront then 
                    --正面
                    quad = {
                        -- 1            --2                 --3
                        x, y,           x + dw, y,          x, y + dh, 
                        -- 1            --2                 --3
                        x + dw, y,      x + dw, y + dh,     x, y + dh,
                    }
                else  
                    --背面
                    quad = {
                        -- 1            --2                 --3
                        x, y,           x, y + dh,          x + dw, y, 
                        -- 1            --2                 --3
                        x + dw, y,      x, y + dh,          x + dw, y + dh,
                    }
                    if valTexTange then
                        -- Val顶点
                        for i=1,#quad,2 do
                            if isInValRange(quad[i], quad[i+1]) then
                                table.insert(valVer, quad[i])
                                table.insert(valVer, quad[i+1])
                            end
                            if isInValRange1(quad[i], quad[i+1]) then
                                table.insert(valVer1, quad[i])
                                table.insert(valVer1, quad[i+1])
                            end
                        end
                    end
                end

                for _, v in ipairs(quad) do
                    table.insert(verts, v)
                end
            end
        end

        local bXTex = true --是否当前在计算横坐标纹理坐标，
        for _, v in ipairs(verts) do
            if bXTex then
                if bFront then
                    table.insert(texs, v / size.width * (texRange[2] - texRange[1]) + texRange[1])
                else
                    table.insert(texs, v / size.width * (texRange[1] - texRange[2]) + texRange[2])
                end
            else
                if bFront then
                    table.insert(texs, (1 - v / size.height) * (texRange[4] - texRange[3]) + texRange[3])
                else
                    table.insert(texs, v / size.height * (texRange[3] - texRange[4]) + texRange[4])
                end
            end
            bXTex = not bXTex
        end

        if valTexTange then
            local bXTex = true --是否当前在计算横坐标纹理坐标，
            for _, v in ipairs(valVer) do
                if bXTex then
                    table.insert(valTex, 1-((v-valX) / valW))
                else
                    table.insert(valTex, 1-((v-valY) / valH))
                end
                bXTex = not bXTex
            end

            local bXTex = true --是否当前在计算横坐标纹理坐标，
            for _, v in ipairs(valVer1) do
                if bXTex then
                    table.insert(valTex1, ((v-valX1) / valW1))
                else
                    table.insert(valTex1, ((v-valY1) / valH1))
                end
                bXTex = not bXTex
            end
        end

        local res = {}
        local tmp = {verts, texs}
        for _, v in ipairs(tmp) do
            -- 创建一个 VBO
            local buffid = gl.createBuffer()
            -- 绑定 VBO 到 GL_ARRAY_BUFFER 目标上
            gl.bindBuffer(gl.ARRAY_BUFFER, buffid)
            -- 设置 顶点数据
            gl.bufferData(gl.ARRAY_BUFFER, table.getn(v), v, gl.STATIC_DRAW)
            -- 取消 目标绑定
            gl.bindBuffer(gl.ARRAY_BUFFER, 0)
            -- 记录 VBO i
            table.insert(res, buffid)
        end


        local valRes = {}
        local valRes1 = {}
        if valTexTange then
            for _, v in ipairs({valVer, valTex}) do
                -- 创建一个 VBO
                local buffid = gl.createBuffer()
                -- 绑定 VBO 到 GL_ARRAY_BUFFER 目标上
                gl.bindBuffer(gl.ARRAY_BUFFER, buffid)
                -- 设置 顶点数据
                gl.bufferData(gl.ARRAY_BUFFER, table.getn(v), v, gl.STATIC_DRAW)
                -- 取消 目标绑定
                gl.bindBuffer(gl.ARRAY_BUFFER, 0)
                -- 记录 VBO i
                table.insert(valRes, buffid)
            end

            for _, v in ipairs({valVer1, valTex1}) do
                -- 创建一个 VBO
                local buffid = gl.createBuffer()
                -- 绑定 VBO 到 GL_ARRAY_BUFFER 目标上
                gl.bindBuffer(gl.ARRAY_BUFFER, buffid)
                -- 设置 顶点数据
                gl.bufferData(gl.ARRAY_BUFFER, table.getn(v), v, gl.STATIC_DRAW)
                -- 取消 目标绑定
                gl.bindBuffer(gl.ARRAY_BUFFER, 0)
                -- 记录 VBO i
                table.insert(valRes1, buffid)
            end
        end
        return res, #verts, valRes, #valVer, valRes1, #valVer1
    end

    local function showValueSpAction(layer, mode)
        local z = -layer.rubRadius*2 + 1

        local wx = layer.cardWidth/2 - 60
        local wy = layer.cardHeight/2 - 20

        local tabPos = {
            [1.0] = {
                cc.vec3(-wx-12,-wy,z),
                cc.vec3(wx-12,wy,z),
                false,
                false,
            },
            [2.0] = {
                false,
                false,
                cc.vec3(-wy-9,wx,z),
                cc.vec3(wy,-wx,z),
            },
            [3.0] = {
                cc.vec3(-wx+3,-wy+11,z),
                cc.vec3(wx,wy+15,z),
                false,
                false,
            },
            [4.0] = {
                cc.vec3(-wx+10,-wy,z),
                cc.vec3(wx+10,wy,z),
                false,
                false,
            },
            [5.0] = {
                false,
                false,
                cc.vec3(-wy,wx,z),
                cc.vec3(wy+8,-wx,z),
            },
        }

        for i = 1, 4 do
            if tabPos[layer.mode][i] then
                local action = cc.FadeIn:create(0.3)
                layer['valSp'..i]:setPosition3D(tabPos[layer.mode][i])
                layer['valSp'..i]:stopAllActions()
                layer['valSp'..i]:runAction(action)
            end
        end
    end

    -- 创建搓牌效果层, pList:图片合集.plist文件, szBack:牌背面图片名, szFont:牌正面图片名, 注意：默认传入的牌在plist文件中是竖直的, scale缩放比
    local function createRubCardEffectLayer(pList, szBack, szFont, scale)
        scale = scale or 1.0

        -- 取得屏幕宽高
        local Director = cc.Director:getInstance()
        local WinSize = Director:getWinSize()

        -- 创建广角60度，视口宽高比是屏幕宽高比，近平面1.0，远平面1000.0，的视景体
        local camera = cc.Camera:createPerspective(45, WinSize.width / WinSize.height, 1, 1000)
        camera:setCameraFlag(cc.CameraFlag.USER2)
        --设置摄像机的绘制顺序，越大的深度越绘制的靠上，所以默认摄像机默认是0，其他摄像机默认是1, 这句很重要！！
        camera:setDepth(1)
        camera:setPosition3D(cc.vec3(0, 0, 800))
        camera:lookAt(cc.vec3(0, 0, 0), cc.vec3(0, 1, 0))

        -- 创建用于OpenGL绘制的节点
        local glNode = gl.glNodeCreate()
        -- local glProgram = cc.GLProgram:createWithByteArrays(strVertSource, strFragSource)
        local glProgram = cc.GLProgram:createWithFilenames('3d/card1.c3b', '3d/card2.c3b')
        glProgram:retain()
        glProgram:updateUniforms()

        -- 创建搓牌图层
        local layer = cc.Layer:create()
        layer:setCameraMask(cc.CameraFlag.USER2)
        layer:addChild(glNode)
        layer:addChild(camera)

        -- 退出时，释放glProgram程序
        local function onNodeEvent(event)
            if "exit" == event then
                Scheduler.delete(layer.updateF)
                glProgram:release()
            end
        end
        layer:registerScriptHandler(onNodeEvent)

        --------------------------------------------------------------------------------------------------------------------------------
        -- 触摸事件
        --创建触摸回调
        local posBegin = cc.p(0,0)
        local initMode = false
        local function touchBegin(touch, event)
            local location = touch:getLocation()
            posBegin = location
            return true
        end

        local function onMoveJ1(dx, dy)
            if initMode == 1.0 then 
                --右向左
                if layer.actionFlag == 0.0 then
                    layer.j1 = layer.j1 + dx
                    layer.j2 = layer.j1 + layer.halfRubPerimeter
                    if layer.j1 < (layer.cardWidth * 0.3) then
                        layer.actionOffX = layer.j1
                        layer.actionFrameCnt = math.ceil(layer.j1/dx)
                        layer.actionOffX1 = layer.cardWidth+layer.halfRubPerimeter
                        layer.actionOffY1 = 0
                        layer.actionFlag = 1.0
                    end
                elseif layer.actionFlag == 1.0 then
                    layer.j1 = layer.j1 - dx
                    layer.j2 = layer.j1 + layer.halfRubPerimeter
                    if layer.j2 < 0 then
                        layer.actionFlag = 2.0
                    end
                end

            elseif initMode == 2.0 then 
                --右下到左上
                if layer.actionFlag == 0.0 then
                    layer.j1 = layer.j1 + layer.k1*(-dx)
                    layer.j2 = layer.j1 + layer.k1*(-layer.rubLength)
                    if layer.j1 > -(layer.cardWidth*0.1) then
                        layer.actionOffX = layer.j1
                        layer.actionFrameCnt = math.abs(math.ceil(layer.j1/layer.k1*(-dx)))

                        local len3 = math.cos(math.rad(45))*layer.halfRubPerimeter
                        local len2 = (layer.cardWidth - layer.cardHeight)/2
                        layer.actionOffX1 = len2 + len3 + layer.cardHeight
                        layer.actionOffY1 = -(len3 + layer.cardHeight + len2)

                        layer.actionFlag = 1.0
                    end
                elseif layer.actionFlag == 1.0 then
                    layer.j1 = layer.j1 + layer.k1*(-dx*-1)
                    layer.j2 = layer.j1 + layer.k1*(-layer.rubLength)
                    if layer.j2 > (layer.cardHeight/math.tan(math.rad(45))) then
                        layer.actionFlag = 2.0
                    end
                end

            elseif initMode == 3.0 then 
                --下到上
                if layer.actionFlag == 0.0 then
                    layer.j1 = layer.j1 + dy
                    layer.j2 = layer.j1 - layer.halfRubPerimeter
                    if layer.j1 > (layer.cardHeight * 0.7) then
                        layer.actionOffY = layer.j1
                        layer.actionFrameCnt = math.abs(math.ceil(layer.j1/dy))

                        layer.actionOffX1 = 0
                        layer.actionOffY1 = -layer.cardHeight - layer.halfRubPerimeter

                        layer.actionFlag = 1.0
                    end
                elseif layer.actionFlag == 1.0 then
                    layer.j1 = layer.j1 + dy
                    layer.j2 = layer.j1 - layer.halfRubPerimeter
                    if layer.j2 > layer.cardHeight then
                        layer.actionFlag = 2.0
                    end
                end

            elseif initMode == 4.0 then 
                --左到右
                if layer.actionFlag == 0.0 then
                    print('layer.j1',layer.j1)
                    layer.j1 = layer.j1 + dx
                    layer.j2 = layer.j1 - layer.halfRubPerimeter
                    if layer.j1 > (layer.cardWidth * 0.7) then
                        layer.actionOffX = layer.j1
                        layer.actionFrameCnt = math.abs(math.ceil(layer.j1/dx))

                        layer.actionOffX1 = -layer.cardWidth - layer.halfRubPerimeter
                        layer.actionOffY1 = 0

                        layer.actionFlag = 1.0
                    end
                elseif layer.actionFlag == 1.0 then
                    layer.j1 = layer.j1 + dx
                    layer.j2 = layer.j1 - layer.halfRubPerimeter
                    if layer.j2 > (layer.cardWidth) then
                        layer.actionFlag = 2.0
                    end
                end

            elseif initMode == 5.0 then 
                --左下到右上
                if layer.actionFlag == 0.0 then
                    layer.j1 = layer.j1 + layer.k1*(-dx)
                    layer.j2 = layer.j1 + layer.k1*(layer.rubLength)
                    if layer.j1 > (layer.cardWidth*0.9) then
                        layer.actionFrameCnt = math.abs(math.ceil(layer.j1/layer.k1*(-dx)))
                        layer.actionOffX = layer.j1
                        
                        local len3 = math.cos(math.rad(45))*layer.halfRubPerimeter
                        local len2 = (layer.cardWidth - layer.cardHeight)/2
                        layer.actionOffX1 = len2 - (len3 + layer.cardWidth)
                        layer.actionOffY1 = -(len3 + layer.cardHeight + len2)

                        layer.actionFlag = 1.0
                    end
                elseif layer.actionFlag == 1.0 then
                    layer.j1 = layer.j1 + layer.k1*(-dx)
                    layer.j2 = layer.j1 + layer.k1*(layer.rubLength)
                    if layer.j2 > (layer.cardHeight/math.tan(math.rad(45)) + layer.cardWidth) then
                        layer.actionFlag = 2.0
                    end
                end
            end
        end

        local function touchMove(touch, event)
            local location = touch:getLocation()
            local dx = (location.x - posBegin.x)
            local dy = (location.y - posBegin.y)
            dx = dx * 1.0
            if initMode == 3.0 then
                dy = dy * 0.8
            else
                dy = dy * 1.0
            end
            print('dx',dx)
            if initMode == 1.0 then
                if layer.j1 < 420 then
                    dx = dx * layer.j1/730
                end
            end

            if initMode == 4.0 then
                if layer.j1 > 125 then
                    dx = dx * (-layer.j1 / 1100 + 0.65)
                else
                    dx = dx * 1.2
                end
            end

            
            if not initMode then
                local dt = math.sqrt(math.pow(dx,2) + math.pow(dy,2))
                if dt > layer.modeThreshold then
                    local angle = math.atan2(dy, dx)/math.pi*180
                    if angle >= -80 and angle < 22.5 then 
                        --左到右
                        initMode = 4.0
                        layer.mode = initMode
                        layer.k1 = 0.0
                        layer.j1 = 0.0
                        layer.j2 = layer.j1 - layer.halfRubPerimeter

                    elseif angle >= 22.5 and angle < 67.5 then 
                        --左下到右上
                        initMode = 5.0
                        layer.mode = initMode
                        layer.k1 = -1.0
                        layer.j1 = 0.0
                        layer.j2 = layer.k1*(-layer.rubLength)

                    elseif angle >= 67.5 and angle < 112.5 then 
                        --下到上
                        initMode = 3.0
                        layer.mode = initMode
                        layer.k1 = 0.0
                        -- layer.j1 = -layer.halfRubPerimeter
                        layer.j1 = 15.0
                        layer.j2 = layer.j1 - layer.halfRubPerimeter

                    elseif angle >= 112.5 and angle < 157 then 
                        --右下到左上
                        initMode = 2.0
                        layer.mode = initMode
                        layer.k1 = 1.0
                        layer.j1 = layer.k1*(-layer.cardWidth)
                        layer.j2 = layer.k1*(-1*(layer.cardWidth + layer.rubLength))

                    elseif (angle >= 157 and angle <=180) or (-180 <= angle and angle <= -120) then 
                        --右向左
                        initMode = 1.0 
                        layer.mode = initMode
                        layer.k1 = 0
                        layer.j1 = layer.cardWidth
                        layer.j2 = layer.j1 + layer.halfRubPerimeter

                    end
                    if initMode then
                        posBegin = location
                        print("initMode: ", initMode, " angle: ", angle)
                    end
                end
            else
                if layer.actionFlag > 0.0 then return end
                posBegin = location
                onMoveJ1(dx, dy)
            end
        end

        local function touchEnd(touch, event)
            if layer.actionFlag == 0.0 then
                initMode = false
                layer.mode = 4.0
                layer.k1 = 0.0
                layer.j1 = 0.0
                layer.j2 = layer.j1 - layer.halfRubPerimeter
                return true
            elseif layer.actionFlag == 1.0 then

            end
        end

        local listener = cc.EventListenerTouchOneByOne:create()
        listener:registerScriptHandler(touchBegin, cc.Handler.EVENT_TOUCH_BEGAN)
        listener:registerScriptHandler(touchMove, cc.Handler.EVENT_TOUCH_MOVED)
        listener:registerScriptHandler(touchEnd, cc.Handler.EVENT_TOUCH_ENDED)
        local eventDispatcher = layer:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)


        --------------------------------------------------------------------------------------------------------------------------------
        
        --创建牌的背面
        local id1, texRange1, sz1 = getTextureAndRange(szBack)
        local msh1, nVerts1 = initCardVertex(cc.size(sz1[1] * scale, sz1[2] * scale), texRange1, true)

        --创建牌的正面
        local id3, texRange3, sz3 = getTextureAndRange('3d/1' .. fileName .. '.png')

        local id2, texRange2, sz2 = getTextureAndRange(szFont)
        local msh2, nVerts2, msh3, nVerts3, msh4, nVerts4= initCardVertex(cc.size(sz2[1] * scale, sz2[2] * scale), texRange2, false, texRange3)
        
        
        --------------------------------------------------------------------------------------------------------------------------------
        --搓牌控制部分

        layer.cardWidth = sz1[1] * scale
        layer.cardHeight = sz1[2] * scale
        
        --确定方向
        layer.modeThreshold = 10.0

        layer.rubRadius = 30.0
        layer.halfRubPerimeter = layer.rubRadius*math.pi
        layer.rubPerimeter = layer.rubRadius*math.pi*2

        layer.rubLength = layer.halfRubPerimeter/math.cos(math.rad(45))

        layer.mode = 1.0
        layer.k1 = 0
        layer.j1 = layer.cardWidth
        layer.j2 = layer.j1 + (math.pi*layer.rubRadius)
    
        layer.actionFlag = 0.0
        layer.actionR = 0.0
        layer.actionStep = 10.0
        layer.actionOffX = 0.0
        layer.actionOffY = 0.0
        layer.actionOffZ = 0.0

        layer.actionOffX1 = 0.0
        layer.actionOffY1 = 0.0
        layer.actionOffZ1 = 0.0

        layer.actionStepZ = 0
        layer.actionStepZ1 = 0
        layer.actionFrameCnt = 0

        layer.offCx = 0
        layer.offCy = 0

        layer.flagShowValueSp = false

        -----------------------------------------------------------------------------
        --value sprite
        layer.offX = WinSize.width / 2 - layer.cardWidth/2
        layer.offY = WinSize.height / 2 - layer.cardHeight/2

        local sp1 = cc.Sprite:create('3d/1' .. fileName .. '.png')    -- 左
        sp1:setPosition3D(cc.vec3(-layer.cardWidth/2,-layer.cardHeight/2,0))
        -- sp1:setAnchorPoint(cc.p(0,0))
        sp1:setCameraMask(cc.CameraFlag.USER2)
        sp1:setScale(0.9)
        sp1:setOpacity(0)

        local sp2 = cc.Sprite:create('3d/1' .. fileName .. '.png')    -- 右
        sp2:setPosition3D(cc.vec3(layer.cardWidth/2,layer.cardHeight/2,0))
        sp2:setRotation(180)
        -- sp2:setAnchorPoint(cc.p(0,0))
        sp2:setCameraMask(cc.CameraFlag.USER2)
        sp2:setScale(0.9)
        sp2:setOpacity(0)

        local sp3 = cc.Sprite:create('3d/1' .. fileName .. '.png')    -- 上
        sp3:setPosition3D(cc.vec3(-layer.cardHeight/2,layer.cardWidth/2,0))
        sp3:setRotation(90)
        -- sp3:setAnchorPoint(cc.p(0,1))
        sp3:setCameraMask(cc.CameraFlag.USER2)
        sp3:setScale(0.9)
        sp3:setOpacity(0)

        local sp4 = cc.Sprite:create('3d/1' .. fileName .. '.png')    -- 下
        sp4:setPosition3D(cc.vec3(layer.cardHeight/2,-layer.cardWidth/2,0))
        sp4:setRotation(270)
        -- sp4:setAnchorPoint(cc.p(1,0))
        sp4:setCameraMask(cc.CameraFlag.USER2)
        sp4:setOpacity(0)
        sp4:setScale(0.9)


        layer:addChild(sp1)
        layer:addChild(sp2)
        layer:addChild(sp3)
        layer:addChild(sp4)
        layer.valSp1 = sp1
        layer.valSp2 = sp2
        layer.valSp3 = sp3
        layer.valSp4 = sp4
        

        -----------------------------------------------------------------------------
        --tick
        layer.finishTick1 = 0
        layer.finishTick2 = 0
        layer.flagHideLayer = false
        layer.updateF = Scheduler.new(function(dt)
            layer.finishTick1 = layer.finishTick1 + dt
            if layer.flagShowValueSp then
                layer.finishTick2 = layer.finishTick2 + dt
            end
            if layer.finishTick1 > 0 then
                if layer.actionFlag == 1.0 then 
                    onMoveJ1(layer.actionStep, layer.actionStep)
                    if layer.actionOffZ < layer.rubRadius*2 then
                        layer.actionOffZ = layer.actionOffZ + layer.actionStepZ
                        layer.actionStepZ = layer.actionStepZ + 0.05
                    end
                end
                if layer.actionFlag == 2.0 then 
                    if layer.actionOffZ >= -layer.rubRadius*2 then
                        layer.actionOffZ = layer.actionOffZ - layer.actionStepZ1
                        layer.actionStepZ1 = layer.actionStepZ1 + 0.6
                    elseif layer.flagShowValueSp == false then
                        layer.flagShowValueSp = true
                        -- showValueSpAction(layer)
                    end
                end
                layer.finishTick1 = 0
            end
            if layer.finishTick2 > 1.5 and layer.flagHideLayer == false then
                layer.flagHideLayer = true
                self:freshCuoPaiDisplay(false)
                self:onMessageState({msgID = 'clickFanPai'})
            end
        end)

        --------------------------------------------------------------------------------------------------------------------------------

        --牌的渲染信息
        local cardMesh = {{id1, msh1, nVerts1}, {id2, msh2, nVerts2}, {id3, msh3, nVerts3}, {id3, msh4, nVerts4}}
        -- OpenGL绘制函数
        local function draw(transform, transformUpdated)
            --开启表面裁剪
            gl.enable(gl.CULL_FACE)
            --使用此shader
            glProgram:use()
            --设置该shader的一些内置uniform,主要是MVP，即model-view-project矩阵
            glProgram:setUniformsForBuiltins()

            for idx, v in ipairs(cardMesh) do
                repeat
                    if idx > 2 and not layer.flagShowValueSp then break end
                
                gl.bindTexture(gl.TEXTURE_2D, v[1])--id

                -- 扑克尺寸
                local cardWidth = gl.getUniformLocation(glProgram:getProgram(), "cardWidth")
                glProgram:setUniformLocationF32(cardWidth, layer.cardWidth)
                local cardHeight = gl.getUniformLocation(glProgram:getProgram(), "cardHeight")
                glProgram:setUniformLocationF32(cardWidth, layer.cardHeight)

                -- 偏移牌，使得居中
                local offx = gl.getUniformLocation(glProgram:getProgram(), "offx")
                glProgram:setUniformLocationF32(offx, layer.offX)
                local offy = gl.getUniformLocation(glProgram:getProgram(), "offy")
                glProgram:setUniformLocationF32(offy, layer.offY)
                -- glProgram:setUniformLocationF32(offy, 100)

                -- 推进模式
                local mode = gl.getUniformLocation(glProgram:getProgram(), "mode")
                glProgram:setUniformLocationF32(mode, layer.mode)

                -- 弯曲半径
                local rubRadius = gl.getUniformLocation(glProgram:getProgram(), "rubRadius")
                glProgram:setUniformLocationF32(rubRadius, layer.rubRadius)

                -- j1 j2 k1
                local k1 = gl.getUniformLocation(glProgram:getProgram(), "k1")
                glProgram:setUniformLocationF32(k1, layer.k1)
                local j1 = gl.getUniformLocation(glProgram:getProgram(), "j1")
                glProgram:setUniformLocationF32(j1, layer.j1)
                local j2 = gl.getUniformLocation(glProgram:getProgram(), "j2")
                glProgram:setUniformLocationF32(j2, layer.j2)

                -- 结束动画
                local actionRad = gl.getUniformLocation(glProgram:getProgram(), "actionRadius")
                glProgram:setUniformLocationF32(actionRad, layer.actionR)
                local actionFlag = gl.getUniformLocation(glProgram:getProgram(), "actionFlag")
                glProgram:setUniformLocationF32(actionFlag, layer.actionFlag)

                local actionOffX = gl.getUniformLocation(glProgram:getProgram(), "actionOffX")
                glProgram:setUniformLocationF32(actionOffX, layer.actionOffX)
                local actionOffY = gl.getUniformLocation(glProgram:getProgram(), "actionOffY")
                glProgram:setUniformLocationF32(actionOffY, layer.actionOffY)
                local actionOffZ = gl.getUniformLocation(glProgram:getProgram(), "actionOffZ")
                glProgram:setUniformLocationF32(actionOffZ, layer.actionOffZ)

                local actionOffX1 = gl.getUniformLocation(glProgram:getProgram(), "actionOffX1")
                glProgram:setUniformLocationF32(actionOffX1, layer.actionOffX1)
                local actionOffY1 = gl.getUniformLocation(glProgram:getProgram(), "actionOffY1")
                glProgram:setUniformLocationF32(actionOffY1, layer.actionOffY1)
                local actionOffZ1 = gl.getUniformLocation(glProgram:getProgram(), "actionOffZ1")
                glProgram:setUniformLocationF32(actionOffZ1, layer.actionOffZ1)
                
                gl.glEnableVertexAttribs(bit._or(cc.VERTEX_ATTRIB_FLAG_TEX_COORDS, cc.VERTEX_ATTRIB_FLAG_POSITION))
                
                gl.bindBuffer(gl.ARRAY_BUFFER, v[2][1]) --msh
                gl.vertexAttribPointer(cc.VERTEX_ATTRIB_POSITION, 2, gl.FLOAT, false, 0, 0)
                
                gl.bindBuffer(gl.ARRAY_BUFFER, v[2][2]) --msh
                gl.vertexAttribPointer(cc.VERTEX_ATTRIB_TEX_COORD, 2, gl.FLOAT, false, 0, 0)
                
                gl.drawArrays(gl.TRIANGLES, 0, v[3]/2) --nVerts

                until true
            end
            gl.bindTexture(gl.TEXTURE_2D, 0)
            gl.bindBuffer(gl.ARRAY_BUFFER, 0)
        end

        glNode:registerScriptDrawHandler(draw)
        
        return layer
    end
    local layer = createRubCardEffectLayer("", backPath, cardPath, 0.8)
    self.cpLayer:addChild(layer, 999)
    self.rubLayer = layer
end

function QZDeskView:remove3dLayer()
    if self.rubLayer then
        self.rubLayer:removeFromParent()
        self.rubLayer = nil
    end
end

function QZDeskView:freshCuoPaiDisplay(bool, data)
    -- if device.platform == 'android' then --window上旧版搓牌
    -- if device.platform ~= 'ios' then --window上新版搓牌
    if device.platform == 'android' or device.platform == 'windows' or device.platform == 'ios' then 
        if bool then
            self:remove3dLayer()
            self:showCardsAtCuopai(data)
            self:init3dLayer(data[5])
            self.cpLayer:setVisible(true)
        else
            self:remove3dLayer()
            self.cpLayer:setVisible(false)
        end
    elseif device.platform == 'ios' then
        print("================ cuopai view ================")
        local cpLayer = self.MainPanel:getChildByName('cpLayer')
        self.cpLayer = cpLayer

        if bool and (self.cpLayer and not cpLayer:isVisible() and data) then
            print("show cuopai")
            local suit = self.suit_2_path[self:card_suit(data[5])]
            local rnk = self:card_rank(data[5]) or '_joker'
            self.paimian = suit .. rnk
            --print(' -> suit : ', suit, ' rnk : ', rnk)

            local card = cpLayer:getChildByName('card')
            card:setScale(1)
            self:showCardsAtCuopai(data)
            self:init3dLayer_ios(suit .. rnk)

            self.preIdx = 0
            self.preDifY = 0
            self.cardFlip = false
            self.card = card
            self.bBlockTouch = false

            card:addTouchEventListener(function(sender, type)
                if self.bBlockTouch then
                    return
                end
                
                if type == 0 then
                    -- begin

                    self.starpos = sender:getTouchBeganPosition()
                    local beganposition = self.starpos.y
                    self.beganposition = beganposition   
                    local x, y = card:getPosition()
                    self.orgPos = {x = x, y = y}

                elseif type == 1 then
                    -- move
                    --[[
                    local pos = sender:getTouchMovePosition()
                    local difX = self.starpos.x - pos.x
                    local difY = self.starpos.y - pos.y

                    local idx = math.ceil(math.abs(difY) / 8)
                    local delta = idx - self.preIdx
                    
                    if delta ~= 0 then
                        if difY - self.preDifY > 0 then
                            if self.preIdx - 1 < 0 then return end

                            self:freshCardMoveAction('down', self.preIdx - 1, self.preIdx)
                            self.preIdx = self.preIdx - 1

                        elseif difY - self.preDifY < 0 then
                            if self.preIdx + 1 > 15 then
                                self:freshCardFlipAction(suit .. rnk)
                                return
                            end

                            self:freshCardMoveAction('up', self.preIdx, self.preIdx + 1)
                            self.preIdx = self.preIdx + 1
                        end
                        self.preDifY = difY
                    end
                    ]]
                    local pos = sender:getTouchMovePosition()
                    local difX = self.starpos.x - pos.x
                    local difY = self.starpos.y - pos.y
                    local dify = self.beganposition - pos.y
                    local maxposition = self.beganposition
                    --将鼠标点击初始位置的数值进行适当调整 避免动画播放速度过快(此处控制搓牌灵敏度)
                    -- 旧版控制灵敏度(初始几帧会不灵敏 没效果)
                    --[[if self.beganposition < 100 then
                        self.beganposition = self.beganposition + 100
                        dify = dify / 2
                    elseif self.beganposition < 200 then
                        dify = dify / 2
                    elseif self.beganposition > 400 then 
                        dify = dify * 2
                    end
                    if self.beganposition > 180 and self.beganposition < 200 then 
                        dify = dify * 2
                    end]]
                    --新版控制灵敏度
                    maxposition = 640 - self.beganposition
                    if self.beganposition < 100 then
                        dify = dify * 1.6
                    elseif self.beganposition < 200 then 
                        dify = dify * 1.4
                    elseif self.beganposition < 300 then 
                        dify = dify * 1.2
                    end
                    self.difY = difY
                    self.dify = math.abs(dify)
                    if dify > 0 then dify = 0 end 
                    local getframes = math.abs(math.floor(dify * 50 / maxposition)) 
                    print("difY", difY, math.abs(difY))
                    print("getframes", getframes)
                    if math.abs(difY) >= 1 then                              
                        if difY > 0 then
                            if self.preIdx - 1 < 0 then return  end
                            self:freshCardMoveAction1('down', getframes, self.preIdx)
                            self.preIdx = getframes
                        else
                            self.maxdify = math.abs(dify)
                            if self.preIdx >= getframes then return end
                            self:freshCardMoveAction1('up', self.preIdx, getframes)
                            self.preIdx = getframes
                        end
                        self.starpos.y = pos.y
                    end
                else
                    -- end
                    if self.preIdx < 51 then
                        print("reset", self.preIdx)
                        self.bBlockTouch = true
                        self:freshCardMoveAction('reset', 0, self.preIdx)
                        self.preIdx = 0
                    end
                end
            end)
            self.cpLayer:setVisible(true)
        elseif (not bool) and (self.cpLayer and cpLayer:isVisible()) then
            print("hide cuopai")
            if self.layer3D then
                self.layer3D:removeFromParent(true)
                self.layer3D = nil
                self.card3d = nil
                self.card3d1 = nil
            end
            cpLayer:setVisible(false)
        end
    end
end

return QZDeskView
