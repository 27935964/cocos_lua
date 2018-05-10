----公会战检测进入公会战条件---
--author:hhh time:2017.11.8
local UWTryEnterCmd=class("UWTryEnterCmd",Command); 

function UWTryEnterCmd:ctor()
	UWTryEnterCmd.super.ctor(self);
	NetHandler:addAckCode(self,Post_Union_War_warStatus);
	self.cityId=0;
	self.errFun=nil;
end

function UWTryEnterCmd:onRemove()
	NetHandler:delAckCode(self,Post_Union_War_warStatus);
end

function UWTryEnterCmd:onReciveData(msgID, netData)
	if msgID==Post_Union_War_warStatus then
	      	if netData.state==1 then
	      		local warStatus=netData.warstatus;
	      		if warStatus.status==1 then
	      			if _G.sceneData.sceneType==SCENEINFO.UNIONWAR_SCENE then
	      				enterLuaLayer(SCENEINFO.UNIONWAR_SCENE,0,self.cityId);--公会战战斗回来
	      			else 
	      				enterLuaScene(SCENEINFO.UNIONWAR_SCENE,0,self.cityId);--其他场景切换过来
	      			end
	      		else
	      			if self.showMsg then
	      				MGMessageTip:showFailedMessage(MG_TEXT("unionWar_37"));
	      			end
	      			if self.errFun then--战斗结束了
	      				self.errFun();
	      			end
	      		end
	      	else
	      		NetHandler:showFailedMessage(netData);
	      	end
	end
	self:remove();
end

function UWTryEnterCmd:execute(notification)
	self.cityId=notification.cityId;
	self.errFun=notification.errFun;
	self.showMsg=notification.showMsg;
	local str=string.format("&city_id=%d",self.cityId);
	NetHandler:sendData(Post_Union_War_warStatus, str);
end

return UWTryEnterCmd;