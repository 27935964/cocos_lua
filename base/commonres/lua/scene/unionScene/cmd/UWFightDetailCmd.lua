----公会战查看战斗详情----
--author:hhh time:2017.11.8
local UWFightDetailCmd=class("UWFightDetailCmd",Command); 

function UWFightDetailCmd:ctor()
	UWFightDetailCmd.super.ctor(self);
	NetHandler:addAckCode(self,Post_Union_War_getReport);
end

function UWFightDetailCmd:onRemove()
	NetHandler:delAckCode(self,Post_Union_War_getReport);
end

function UWFightDetailCmd:onReciveData(msgID, netData)
	local initProxy=self:getProxy(UWNN.UWInitProxy);
	if msgID==Post_Union_War_getReport then
	      	if netData.state==1 then
	      		local str = cjson.encode(netData.getreport.report);
	      		_G.sceneData.isFightBack=true;
	      		_G.sceneData.layerData=_G_UN_CITY_ID;
	      		FightOP:setUnionWar(_G.sceneData.sceneType);
	      		enterLuaScene(_G.sceneData.sceneType,1,0,MG_TEXT("unionWar_2"),str);--测试战斗战报
	      	else
	      		LuaBackCpp:openCloud();
	          		NetHandler:showFailedMessage(netData);
	      	end
	end
end

function UWFightDetailCmd:execute(notification)
	LuaBackCpp:closeCloud();
	local name=notification.reportName;--"20171201174553_5001_6263_5725"
	print("UWFightDetailCmd:execute:",name);
	local str=string.format("&name=%s",name);
	NetHandler:sendData(Post_Union_War_getReport, str);
end

return UWFightDetailCmd;