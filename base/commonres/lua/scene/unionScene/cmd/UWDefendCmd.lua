----公会战守卫----
--author:hhh time:2017.11.8
local UWDefendCmd=class("UWDefendCmd",Command); 

function UWDefendCmd:ctor()
	UWDefendCmd.super.ctor(self);
	NetHandler:addAckCode(self,Post_Union_War_unionBuyNpc);
end

function UWDefendCmd:onRemove()
	NetHandler:delAckCode(self,Post_Union_War_unionBuyNpc);
end

function UWDefendCmd:onReciveData(msgID, netData)
	if msgID==Post_Union_War_unionBuyNpc then
	      	if netData.state==1 then
	      		MGMessageTip:showSuccessMessage(MG_TEXT("unionWar_19"));
	      	else
	          		NetHandler:showFailedMessage(netData);
	      	end
	end
end

function UWDefendCmd:execute(notification)
	local initProxy=self:getProxy(UWNN.UWInitProxy);
	if notification.action==1 then
		initProxy:openCallDefend(true);
	elseif notification.action==2 then
		initProxy:openCallDefend(false);
	elseif notification.action==3 then
		local str=string.format("&city_id=%d&num=%d",_G_UN_CITY_ID,notification.num);
		NetHandler:sendData(Post_Union_War_unionBuyNpc, str);
	end
end

return UWDefendCmd;