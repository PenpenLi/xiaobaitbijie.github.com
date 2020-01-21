local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local winSize = cc.Director:getInstance():getWinSize()
local currentwidth = 1136 * 0.7
local ZJHSummaryController = class("ZJHSummaryController", Controller):include(HasSignals)

function ZJHSummaryController:initialize(data)
    Controller.initialize(self)
    HasSignals.initialize(self)

    --dump(data)
    self.data = data

end

function ZJHSummaryController:viewDidLoad()
    self.view:layout(self.data)
    if self.data.autoShare then
        --self:clickShare()
        --self.emitter:emit('back')
    end
end

function ZJHSummaryController:clickBack()
    if self.data.autoShare then
        self.emitter:emit('back')
    else
        local app = require('app.App'):instance()
        app:switch('LobbyController')
    end
end

function ZJHSummaryController:clickShare(t)
    local CaptureScreen = require('app.helpers.capturescreen')
    local SocialShare = require('app.helpers.SocialShare')

    local size = currentwidth / winSize.width
    local scale = size > 1 and 1 or size

    CaptureScreen.capture('screen.jpg', function(ok, path)
        if ok then
            if device.platform == 'ios' then
                path = cc.FileUtils:getInstance():getWritablePath() .. path
            end
            -- if self.data.autoShare then
            --     self.emitter:emit('back')
            -- end
            if device.platform == 'ios' then
                local luaoc = nil
                luaoc = require('cocos.cocos2d.luaoc')
                if luaoc then
                    local ok2, ret = luaoc.callStaticMethod("AppController", "shareWithWeixinFriendImg", { txt = '', filePath = path })
                    if ok2 then
                        print('分享图片成功')
                    end
                end
            else
                SocialShare.share(1, function(stcode)
                    print('stcode is ', stcode)
                end,
                nil,
                path,
                "",
                '新世界', true)
            end

        end
    end, self.view, scale)
end

function ZJHSummaryController:clickShare_to_Xianliao()
    local CaptureScreen = require('app.helpers.capturescreen')
    local SocialShare = require('app.helpers.SocialShare')

    local size = currentwidth / winSize.width
    local scale = size > 1 and 1 or size

    CaptureScreen.capture('screen.jpg', function(ok, path)
        if ok then
            if device.platform == 'ios' then
                path = cc.FileUtils:getInstance():getWritablePath() .. path
            end
            -- if self.data.autoShare then
            --     self.emitter:emit('back')
            -- end
            SocialShare.share(7, function(stcode)
                print('stcode is ', stcode)
            end,
            nil,
            path,
            "",
            '新世界',
            true,
            "image",
            "0",
            "0")
        end
    end, self.view, scale)
end

return ZJHSummaryController