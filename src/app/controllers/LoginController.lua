local class = require('middleclass')
local Controller = require('mvc.Controller')
local LoginController = class("LoginController", Controller)
local ShowWaiting = require('app.helpers.ShowWaiting')
local uploaderror = require('app.helpers.uploaderror')
local SoundMng = require('app.helpers.SoundMng')

local testluaj = nil
local luaoc = nil 
if device.platform == 'android' then
    testluaj = require('app.models.luajTest')--引入luajTest类
    --print('android luaj 导入成功')
elseif device.platform == 'ios' then
    luaoc = require('cocos.cocos2d.luaoc')
end

local cjson = require('cjson')
local tools = require('app.helpers.tools')

function LoginController:initialize(version)
  Controller.initialize(self)
  self.version = version
  SoundMng.load()
  
  if device.platform == 'ios' or device.platform == 'android' then
    uploaderror.changeTraceback()
  end
end

function LoginController:sendPingMsg()
  local app = require("app.App"):instance()
  app.conn:send(-1,1,{
    receive = 'hello'
  })
end

function LoginController:clickYouKe()
  self:clickLogin(nil, 'youke')
end

function LoginController:clickLogin(sender, options)
  if not self.view:getIsAgree() then
    tools.showRemind("请确认并同意协议")
    return 
  end
  if self.logining then return end
  local platform = 'wechat'
  if sender then
    platform = sender:getComponent("ComExtensionData"):getCustomProperty()
  end

  -- 如果点击的是闲聊判断闲聊是否安装
  if platform == 'xianliao' and device.platform == 'ios' then
    if luaoc then
      local ok,ret = luaoc.callStaticMethod("AppController", "getXLInstall",{ww=''})
      if ok then
        if ret == 0 then
          tools.showRemind("您没有安装闲聊 请选择其他登录方式")
          return 
        end
      end
    end
  end

  self.logining = true
  SoundMng.playEft('sound/common/audio_card_out.mp3')
  --audio.playSound('sound/common/audio_card_out.mp3')
  local app = require("app.App"):instance()
  local login = app.session.login

  local function ios_login(uid,avatar,username, sex)
    login:login(uid,avatar,username, sex, 'wechat')

    app.localSettings:set('avatar', avatar,true)
    app.localSettings:set('logintime', os.time(),true)
    app.localSettings:set('username', username)
  end

  -- if device.platform == 'android' or device.platform == 'ios' then
  if (device.platform == 'android' or device.platform == 'ios') and not options then
  -- if device.platform ~= 'ios' then
    local need_try = true
    if device.platform == 'ios' and platform ~= 'xianliao' then
      local expired = 7200
      local uid = app.localSettings:get('uid')
      local avatar = app.localSettings:get('avatar')
      local username = app.localSettings:get('username')
      local logintime = app.localSettings:get('logintime')
      if uid and avatar and username and logintime then
        local diff = os.time() - logintime
        if diff < expired then
          need_try = false
          ios_login(uid,avatar,username)
        end
      end
    end

    -- 加载umeng的只是为了初始化
    local social_umeng = require('social')

    local social
    if device.platform == 'android' then
      social = social_umeng
    else
      social = require('socialex')
    end

    if need_try and platform ~= 'xianliao' then
      ShowWaiting.show()
      social.authorize(platform, function(stcode,user)
        print('stcode is ',stcode)
        self.logining = false
        if stcode == 100 then return end

        if stcode == 200 then
          dump(user)
          if device.platform == 'ios' then
            if user.sex and user.sex - 1 < 0 then user.sex = 1 end
            ios_login(user.uid,user.avatar,user.username, user.sex - 1)
          else
            if user.sex and user.sex - 1 < 0 then user.sex = 1 end
            login:login(user.unionid,user.headimgurl,user.nickname, user.sex - 1, 'wechat')
          end

          if device.platform == 'ios' then
            social.switch2umeng()
          end
        end
        ShowWaiting.delete()
      end)
    elseif need_try and platform == 'xianliao' then
      if testluaj then
        print('android start_login_xianliao') 
        -- "start_login_xianliao"
        --在这里尝试调用android static代码
        local testluajobj = testluaj.new(self)
        local ok, ret1 = testluajobj.callandroidStart_login_xianliao(self, "")
        if ok then
          self.logining = false
        end
      end
      if luaoc then
        local ok,ret = luaoc.callStaticMethod("AppController", "start_login_xianliao",{ww=''})
        if ok then
          self.logining = false
        end 
      end
    end
  else
    print(app.localSettings:get('uid'))
    local uid = app.localSettings:get('uid')
    if not uid then
      app.localSettings:set('uid', tostring(os.time()))
    end
    login:login(app.localSettings:get('uid'))
  end

  --停止播放动画
  self.view:stopAllCsdAnimation()
end

function LoginController:viewDidLoad()
  local app = require("app.App"):instance()

  cc.Director:getInstance():setClearColor(cc.c4f(1,1,1,1))

  if app.session then
    app.conn:reset()
    app.session = nil
  end

  app:createSession()

  local login = app.session.login
  local net = app.session.net

  net:connect()

  -- windows平台自动登录
  net:once('connect',function()
    if false and cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_WINDOWS then
      self:clickLogin()
      print("auto login")
    else
      if app.localSettings:get('uid') then
        local logintype = app.localSettings:get('logintype') or 'wechat'
        local sender = self.view:getSender(logintype)
        self:clickLogin(sender)
      end
    end
  end)

  self.listens = {
    login:on('loginSuccess',function()
      print("login success")     
      -- 定位
      -- if device.platform == 'ios' then
      --   if luaoc then
      --     local ok, battery = luaoc.callStaticMethod("AppController", "startLocation",{ww=''})
      --   end
      -- end
      app:switch('LobbyController')
    end)
  }

  self.view:layout(self.version)

  -- 每秒获取一次闲聊的返回信息 处理授权登录结果
  local scheduler = cc.Director:getInstance():getScheduler()
	self.schedulerID = scheduler:scheduleScriptFunc(function()
		if testluaj then
      print('android getXLResult') 
      -- "getXLResult"
      --在这里尝试调用android static代码
      local testluajobj = testluaj.new(self)
      local ok, ret1 = testluajobj.callandroidGetXLUserInfo(self, "");
      if ok then
        local data = cjson.decode(ret1)
        dump(data)
        if data.code == 0 then return end
        if data.code == 1 then
          login:login(data.uid,data.avatar,data.nickName, data.sex - 1, 'xianliao')
        elseif data.code == -1 then
          tools.showRemind("取消授权")
        elseif data.code == -2 then
          tools.showRemind("授权失败")
        end
      end
    end
    if luaoc then
      local ok,ret = luaoc.callStaticMethod("AppController", "getXLLoginResult",{ww=''})
      if ok then
        local data = cjson.decode(ret)
        dump(data)
        if data.code == 0 then return end
        if data.code == 1 then
          login:login(data.uid,data.avatar,data.nickName, data.sex - 1, 'xianliao')
        elseif data.code == -1 then
          tools.showRemind("取消授权")
        elseif data.code == -2 then
          tools.showRemind("授权失败")
        end
      end
    end
	end, 1, false)
end

function LoginController:clickShowXieyi()
  self.view:freshXieyiLayer(true)
end

function LoginController:clickCloseXieyi()
  self.view:freshXieyiLayer(false)
end

function LoginController:clickAgree()
  self.view:freshIsAgree()
end

function LoginController:finalize()-- luacheck: ignore
  for i = 1,#self.listens do
    self.listens[i]:dispose()
  end
  if self.schedulerID then
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
  end
end

return LoginController
