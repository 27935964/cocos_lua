----公会战叫阵----
--author:hhh time:2017.11.8
local UWJiaoZhenCmd=class("UWJiaoZhenCmd",Command); 

function UWJiaoZhenCmd:ctor()
	UWJiaoZhenCmd.super.ctor(self);
	NetHandler:addAckCode(self,Post_Union_War_getCampList);
	NetHandler:addAckCode(self,Post_Union_War_doChallenge);
end

function UWJiaoZhenCmd:onRemove()
	NetHandler:delAckCode(self,Post_Union_War_getCampList);
	NetHandler:delAckCode(self,Post_Union_War_doChallenge);
end

function UWJiaoZhenCmd:onReciveData(msgID, netData)
	local initProxy=self:getProxy(UWNN.UWInitProxy);
	if msgID==Post_Union_War_getCampList then
	      	if netData.state==1 then
	      		initProxy.getcamplist=initProxy:parseCamplist(netData.getcamplist);
	      		initProxy:openJiaoZhen(true);
	      	else
	          		NetHandler:showFailedMessage(netData);
	      	end
	elseif msgID==Post_Union_War_doChallenge then
		if netData.state==1 then
			local dochallenge=netData.dochallenge;
			initProxy.getcamplist=initProxy:parseCamplist(netData.getcamplist);
			initProxy:updataJiaoZhen();
		else
		    	NetHandler:showFailedMessage(netData);
		end		
	end
end

function UWJiaoZhenCmd:execute(notification)
	local initProxy=self:getProxy(UWNN.UWInitProxy);
	if notification.action==1 then
		if initProxy.userCamp==0 then--玩家未加入阵营，显示加入阵营界面
			initProxy.affterCamp=3;
			initProxy:openSelectCamp(true);
		else
			local str=string.format("&city_id=%d",_G_UN_CITY_ID);
			NetHandler:sendData(Post_Union_War_getCampList, str);
		end
	elseif notification.action==2 then
		initProxy:openJiaoZhen(false);
	elseif notification.action==3 then--叫阵出兵
		local str=string.format("&city_id=%d&ids=%s",_G_UN_CITY_ID,cjson.encode(notification.idArr));
		NetHandler:sendData(Post_Union_War_doChallenge, str);
	end
end

return UWJiaoZhenCmd;