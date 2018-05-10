----公会战累计奖励----
--author:hhh time:2017.11.8
local UWRewardCmd=class("UWRewardCmd",Command); 

function UWRewardCmd:ctor()
	UWRewardCmd.super.ctor(self);
	NetHandler:addAckCode(self,Post_Union_War_getReward);
end

function UWRewardCmd:onRemove()
	NetHandler:delAckCode(self,Post_Union_War_getReward);
end

function UWRewardCmd:onReciveData(msgID, netData)
	local initProxy=self:getProxy(UWNN.UWInitProxy);
	if msgID==Post_Union_War_getReward then
	      	if netData.state==1 then
	      		initProxy.getreward=netData.getreward;
	          		initProxy:openReward(true);
	      	else
	          		NetHandler:showFailedMessage(netData);
	      	end
	end
end

function UWRewardCmd:execute(notification)
	local initProxy=self:getProxy(UWNN.UWInitProxy);
	if notification.action==1 then
		local str=string.format("&city_id=%d",_G_UN_CITY_ID);
		NetHandler:sendData(Post_Union_War_getReward, str);
	elseif notification.action==2 then
		initProxy:openReward(false);
	end
end

return UWRewardCmd;