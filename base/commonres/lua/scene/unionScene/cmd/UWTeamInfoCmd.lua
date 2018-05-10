----公会战队伍信息----
--author:hhh time:2017.11.8
local UWTeamInfoCmd=class("UWTeamInfoCmd",Command); 

function UWTeamInfoCmd:ctor()
	UWTeamInfoCmd.super.ctor(self);
	NetHandler:addAckCode(self,Post_Union_War_getCorpsInfo);
end

function UWTeamInfoCmd:onRemove()
	NetHandler:delAckCode(self,Post_Union_War_getCorpsInfo);
end

function UWTeamInfoCmd:onReciveData(msgID, netData)
	local initProxy=self:getProxy(UWNN.UWInitProxy);
	if msgID==Post_Union_War_getCorpsInfo then
		if netData.state==1 then
			initProxy.teamDataEx=netData.getcorpsinfo;
			initProxy:openTeamInfo(true);
		else
		    	NetHandler:showFailedMessage(netData);
		end
	end
end

function UWTeamInfoCmd:execute(notification)
	local initProxy=self:getProxy(UWNN.UWInitProxy);
	if notification.action==1 then
		if not initProxy.isTeamInfoOpen then
			local data=notification.data;
			initProxy.teamData=data;
			if tostring(data.uid)=="0" then--npc
				initProxy:openTeamInfo(true);
			else
				local str=string.format("&uid=%s&corps=%s",data.uid,data.corps);
				NetHandler:sendData(Post_Union_War_getCorpsInfo, str);
			end
		end
	elseif notification.action==2 then
		initProxy:openTeamInfo(false);
	end
end

return UWTeamInfoCmd;