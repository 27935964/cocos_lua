----公会战排行----
--author:hhh time:2017.11.8
local UWRankCmd=class("UWRankCmd",Command); 

function UWRankCmd:ctor()
	UWRankCmd.super.ctor(self);
	NetHandler:addAckCode(self,Post_Union_War_getKillRank);
end

function UWRankCmd:onRemove()
	NetHandler:delAckCode(self,Post_Union_War_getKillRank);
end

function UWRankCmd:onReciveData(msgID, netData)
	local initProxy=self:getProxy(UWNN.UWInitProxy);
	if msgID==Post_Union_War_getKillRank then
	      	if netData.state==1 then
	      		initProxy.getkillrank=netData.getkillrank;
	      		initProxy.index.my_kill_rank=initProxy.getkillrank.my_rank;
	          		initProxy:openRank(true);
	      	else
	          		NetHandler:showFailedMessage(netData);
	      	end
	end
end

function UWRankCmd:execute(notification)
	local initProxy=self:getProxy(UWNN.UWInitProxy);
	if notification.action==1 then
		local str=string.format("&city_id=%d",_G_UN_CITY_ID);
		NetHandler:sendData(Post_Union_War_getKillRank, str);
	elseif notification.action==2 then
		initProxy:openRank(false);
	elseif notification.action==3 then
		initProxy:updateKillNum();
	end
end

return UWRankCmd;