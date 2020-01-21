local luaj = require "cocos.cocos2d.luaj" --引入luaj

local luajTest = class("luajTest")  -- 构建lua 类

function luajTest:callandroid()  --调用android的方法实现
    --包名/类名  这个可以在对应的android工程的manifest中得到 
    local className="org.cocos2dx.lua.AppActivity" 
    local args = { "hello android", 1120 }  
    -- 括号里面是要传到java的参数，Ljava/lang/String是String类型，I是int类型，括号后面是返回类型 V是void 没有返回值
    local sigs = "(Ljava/lang/String;I)V"  

    --luaj 调用 Java 方法时，可能会出现各种错误，因此 luaj 提供了一种机制让 Lua 调用代码可以确定 Java 方法是否成功调用。  
    --luaj.callStaticMethod() 会返回两个值  
    --当成功时，第一个值为 true，第二个值是 Java 方法的返回值（如果有）  
    --当失败时，第一个值为 false，第二个值是错误代码  
    local ok,ret = luaj.callStaticMethod(className,"test",args,sigs)  
    if not ok then  

        print(ok.."error:"..ret)  

    end  

end

function luajTest:callandroidWifiState()  --调用android的方法实现
    --包名/类名  这个可以在对应的android工程的manifest中得到 
    local className="org.cocos2dx.lua.AppActivity" 
    local args = { "hello android", 1121 }  
    local sigs = "(Ljava/lang/String;I)I" 

    --luaj 调用 Java 方法时，可能会出现各种错误，因此 luaj 提供了一种机制让 Lua 调用代码可以确定 Java 方法是否成功调用。  
    --luaj.callStaticMethod() 会返回两个值  
    --当成功时，第一个值为 true，第二个值是 Java 方法的返回值（如果有）  
    --当失败时，第一个值为 false，第二个值是错误代码  
    return luaj.callStaticMethod(className,"getNetInfo",args,sigs)  
   
end

function luajTest:callandroidBatteryLevel()  --调用android的方法实现
    --包名/类名  这个可以在对应的android工程的manifest中得到 
    local className="org.cocos2dx.lua.AppActivity"  
    local sigs = "()I"  

    return luaj.callStaticMethod(className,"getBatteryLevel",{},sigs)  
   
end

function luajTest:callandroidCopy(msg)  --调用android的方法实现
    --包名/类名  这个可以在对应的android工程的manifest中得到 
    local className="org.cocos2dx.lua.AppActivity"  
    local args = {msg, 111}  
    local sigs = "(Ljava/lang/String;I)I" --传入string参数，无返回值  

    --luaj 调用 Java 方法时，可能会出现各种错误，因此 luaj 提供了一种机制让 Lua 调用代码可以确定 Java 方法是否成功调用。  
    --luaj.callStaticMethod() 会返回两个值  
    --当成功时，第一个值为 true，第二个值是 Java 方法的返回值（如果有）  
    --当失败时，第一个值为 false，第二个值是错误代码  
    return luaj.callStaticMethod(className,"setWeiXinCopy",args,sigs)  
   
end

function luajTest:callandroidStart_login_xianliao(msg)  --调用android的方法实现
    --包名/类名  这个可以在对应的android工程的manifest中得到 
    local className="org.cocos2dx.lua.AppActivity"  
    local args = {}  
    local sigs = "()V" --无传入值，无返回值  

    --luaj 调用 Java 方法时，可能会出现各种错误，因此 luaj 提供了一种机制让 Lua 调用代码可以确定 Java 方法是否成功调用。  
    --luaj.callStaticMethod() 会返回两个值  
    --当成功时，第一个值为 true，第二个值是 Java 方法的返回值（如果有）  
    --当失败时，第一个值为 false，第二个值是错误代码  
    return luaj.callStaticMethod(className,"start_login_xianliao",args,sigs)  
   
end

function luajTest:callandroidGetXLUserInfo(msg)  --调用android的方法实现
    --包名/类名  这个可以在对应的android工程的manifest中得到 
    local className="org.cocos2dx.lua.AppActivity"  
    local args = {}  
    local sigs = "()Ljava/lang/String;" --无传入值，返回String  

    --luaj 调用 Java 方法时，可能会出现各种错误，因此 luaj 提供了一种机制让 Lua 调用代码可以确定 Java 方法是否成功调用。  
    --luaj.callStaticMethod() 会返回两个值  
    --当成功时，第一个值为 true，第二个值是 Java 方法的返回值（如果有）  
    --当失败时，第一个值为 false，第二个值是错误代码  
    return luaj.callStaticMethod(className,"getXLResult",args,sigs)  
   
end

function luajTest:callandroidLocation(msg)  --调用android的方法实现
    --包名/类名  这个可以在对应的android工程的manifest中得到 
    local className="org.cocos2dx.lua.AppActivity"  
    local args = {}  
    local sigs = "()Ljava/lang/String;" --无传入参数，返回string  

    --luaj 调用 Java 方法时，可能会出现各种错误，因此 luaj 提供了一种机制让 Lua 调用代码可以确定 Java 方法是否成功调用。  
    --luaj.callStaticMethod() 会返回两个值  
    --当成功时，第一个值为 true，第二个值是 Java 方法的返回值（如果有）  
    --当失败时，第一个值为 false，第二个值是错误代码  
    return luaj.callStaticMethod(className,"getLocationInfo",args,sigs)  
   
end

return luajTest