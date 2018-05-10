----公会战收兵----
--author:hhh time:2017.11.8
local UWShouBingCmd=class("UWShouBingCmd",Command); 

function UWShouBingCmd:ctor()
	UWShouBingCmd.super.ctor(self);
	NetHandler:addAckCode(self,Post_Union_War_cancelPrepare);
end

function UWShouBingCmd:onRemove()
	NetHandler:delAckCode(self,Post_Union_War_cancelPrepare);
end

function UWShouBingCmd:onReciveData(msgID, netData)
	if msgID==Post_Union_War_cancelPrepare then
	      	if netData.state==1 then
	      		local num=netData.cancelprepare.cancel_num;
	      		if num>0 then
	      			MGMessageTip:showSuccessMessage(MG_TEXT("unionWar_9"));
	      		else
	      			MGMessageTip:showFailedMessage(MG_TEXT("unionWar_8"));
	      		end
	      	else
	          		NetHandler:showFailedMessage(netData);
	      	end
	end
end

function UWShouBingCmd:execute(notification)
	local initProxy=self:getProxy(UWNN.UWInitProxy);
	if initProxy.userCamp==0 then--玩家未加入阵营，显示加入阵营界面
		initProxy.affterCamp=2;
		initProxy:openSelectCamp(true);
	else
		local str=string.format("&city_id=%d",_G_UN_CITY_ID);
		NetHandler:sendData(Post_Union_War_cancelPrepare, str);
	end
end

return UWShouBingCmd;