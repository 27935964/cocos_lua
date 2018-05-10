
-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    print(string.format("----------------------------------------"));
    print(string.format("LUA ERROR: " .. tostring(msg) .. "\n"));
    print(string.format(debug.traceback()));
    print(string.format("----------------------------------------"));
end

require "comdef"
require "NetHandler"
require "FightOP"
require "cjson"
require "pushCmd"
require "GobalRegister"

function luaMain()
	
	--当设置了setstepmul和setpause，Lua便会开启自动垃圾回收。
	collectgarbage("setpause", 100);
	collectgarbage("setstepmul", 5000);
	--随机种子
	math.randomseed(os.time());
    
    NetHandler:init();
    FightOP:init();
    pushCmd:init();
    registerServerNotic();
end


xpcall(luaMain, __G__TRACKBACK__);
