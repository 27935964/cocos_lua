----公会战我的杀敌排名----
--author:hhh time:2017.12.8
local UWMyKillRankCmd=class("UWMyKillRankCmd",Command); 

function UWMyKillRankCmd:ctor()
	UWMyKillRankCmd.super.ctor(self);
	NetHandler:addAckCode(self,Post_Union_War_getMyKillRank);
end

function UWMyKillRankCmd:onRemove()
	NetHandler:delAckCode(self,Post_Union_War_getMyKillRank);
end

function UWMyKillRankCmd:onReciveData(msgID, netData)
	local initProxy=self:getProxy(UWNN.UWInitProxy);
	if msgID==Post_Union_War_getMyKillRank then
	      	if netData.state==1 then
	      		local getmykillrank=netData.getmykillrank;
	      		initProxy.index.my_kill_rank=getmykillrank.my_rank;--更新我的排名
	      		initProxy:updateKillNum();
	      	else
	          		NetHandler:showFailedMessage(netData);
	      	end
	end
end

function UWMyKillRankCmd:execute(notification)
	local str=string.format("&city_id=%d",_G_UN_CITY_ID);
	NetHandler:sendData(Post_Union_War_getMyKillRank, str);
end

return UWMyKillRankCmd;