----公会战退出---
--author:hhh time:2017.11.20
local UWExitCmd=class("UWExitCmd",Command); 

function UWExitCmd:ctor()
	UWExitCmd.super.ctor(self);
	NetHandler:addAckCode(self,Post_Union_War_moveWarChanel);
end

function UWExitCmd:onRemove()
	NetHandler:delAckCode(self,Post_Union_War_moveWarChanel);
end

function UWExitCmd:onReciveData(msgID, netData)
	if msgID==Post_Union_War_moveWarChanel then
	      	if netData.state==1 then
	          		if netData.movewarchanel.is_ok==1 then
	          			print("UWExitCmd:onReciveData 退出成功");
	          		else
	          			print("UWExitCmd:onReciveData 退出失败")
	          		end
	      	else
	          		NetHandler:showFailedMessage(netData);
	      	end
	end
	enterLuaScene(_G.sceneData.lastSceneType);
end

function UWExitCmd:execute(notification)
	local str=string.format("&city_id=%d",_G_UN_CITY_ID);
	NetHandler:sendData(Post_Union_War_moveWarChanel, str);
end

return UWExitCmd;