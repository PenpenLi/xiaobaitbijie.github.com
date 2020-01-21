local SocialShare = {}
local social = require('social')
--local fu = cc.FileUtils:getInstance()

local luaoc
local luaj

if device.platform == 'ios' then
	luaoc = require('cocos.cocos2d.luaoc')
end

if device.platform == 'android' then
	luaj = require('cocos.cocos2d.luaj')
end

local all_platforms = {
    'Wechat',           --  1 微信
    'WechatMoments',    --  2 微信朋友圈
    'QZone',            --  4 QQ空间
    'Weibo',            --  0 新浪微博
    'QQ'                --  6 QQ好友
}

local called = false

function SocialShare.share(
  tag,                     -- 平台
  call,                    -- 分享成功的回调
  share_url,               -- 分享的url
  image_url,               -- 如果设置那么使用此url替代本地图片
  text,                    -- 分享的文本
  title,                   -- 分享的标题
  onlyImage,               -- 只有图片
  shareType,               -- 分享类型("image": 图片, "text"：文字, "invite"：邀请)
  roomId,                  -- 房间号
  roomToken                -- 区分是俱乐部id("1")还是房间id("2")还是都没有("0"))
)
  local url = share_url
  if not onlyImage then onlyImage = false end

  local targetplatform = cc.Application:getInstance():getTargetPlatform()
  if tag == 4 then-- weibo
    if targetplatform == 3 then
      text = text .. url
    end
  end

  called = false

  local options = {
      text = text,
      title = title, -- Optional, and not all platform support title.
      image = image_url,
      ui = false, -- Optional. Wheather to show the share UI. default true. false to share directly without UI.
      platform = all_platforms[tag], -- Needed only when ui is false.
      url = url, -- Optional, and not all platform support title.
      onlyImage = onlyImage
  }
  dump(options)

  local function go()
    social.share(options, function(platform,stCode,errorMsg)
      if stCode == 100 then return end

      if called then return end
      if stCode == 200 then
        called = true
      end

      print('###################stCode errorMsg ',stCode,errorMsg)
      call(platform,stCode,errorMsg)
    end)
  end

  local function shareToXL()
    local xloptions = {
      path = image_url,
      shareType = shareType,
      text = text,
      roomId = "" .. roomId,
      roomToken = "" .. roomToken,
      title = title,
      description = text,
    }
    dump(xloptions)
    local xl_string = "{\"path\":\"" .. image_url .. "\",\"shareType\":\"" .. shareType .. 
      "\",\"text\":\"" .. text .. "\",\"roomId\":\"" .. (roomId or "") .. "\",\"roomToken\":\"" .. (roomToken or "")
      .. "\",\"title\":\"" .. title .. "\",\"description\":\"" .. text .. "\"}"
    print("要传过去闲聊的json",xl_string)
    if luaj then
      print('android startShareToXL') 
      -- "startShareToXL"
      --在这里尝试调用android static代码
      local className = "org.cocos2dx.lua.AppActivity"
	    local sigs = "(Ljava/lang/String;)V"
	    local ok, ret = luaj.callStaticMethod(className, "startShareToXL", {xl_string}, sigs)
      if ok then
        local app = require("app.App"):instance()
        app.session.user:startScheduler_getXL()
      end
    end
    if luaoc then
      local ok,ret = luaoc.callStaticMethod("AppController", "shareToXL",xloptions)
      if ok then
        local app = require("app.App"):instance()
        app.session.user:startScheduler_getXL()
      end
    end
  end

  if tag == 7 then
    -- 闲聊不调用友盟
    if device.platform == 'ios' then
      if luaoc then
        local ok,ret = luaoc.callStaticMethod("AppController", "getXLInstall",{ww=""})
        if ok then
          if ret == 1 then
            shareToXL()
          else
            tools.showRemind("您没有安装闲聊 请选择其他分享方式")
          end
        end
      end
    else
      shareToXL()
    end
  else
    go()
  end
end

return SocialShare
