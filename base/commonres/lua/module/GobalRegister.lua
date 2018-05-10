----全局数据推送----
--author:hhh time:2017.17.7

require "CoreLayer"

function registerServerNotic()
	print("GobalRegister->registerServerNotic");
	Core.getInstance():executeCommand("GobalNoticCmd");
end

function allLuaModelReload()
	print("GobalRegister->allModelReload");
	registerServerNotic();
end

function getGobalProxy()
	return Core.getInstance():getProxy("GobalProxy");
end

function addGobalObserver(self,callFun,notificationName)
	Core.getInstance():addObserver(self,callFun,notificationName,nil);
end

function removeGobalObserver(self,notificationName)
	Core.getInstance():removeObserver(self,notificationName);
end