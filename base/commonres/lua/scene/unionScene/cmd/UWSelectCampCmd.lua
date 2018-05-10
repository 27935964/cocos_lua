----公会战选择阵营----
--author:hhh time:2017.11.8
local UWSelectCampCmd=class("UWSelectCampCmd",Command); 

function UWSelectCampCmd:ctor()
	UWSelectCampCmd.super.ctor(self);
	NetHandler:addAckCode(self,Post_Union_War_addCamp);
end

function UWSelectCampCmd:onRemove()
	NetHandler:delAckCode(self,Post_Union_War_addCamp);
end

function UWSelectCampCmd:onReciveData(msgID, netData)
	local initProxy=self:getProxy(UWNN.UWInitProxy);
	if msgID==Post_Union_War_addCamp then
	      	if netData.state==1 then
	      		local addcamp=netData.addcamp;
	      		if addcamp.is_ok==1 then
	      			initProxy:openSelectCamp(false);
	      			initProxy:addCampBack(addcamp);

	      			if initProxy.affterCamp==1 then
	      				self:postNotificationName(UWNN.UWChuBingCmd);
	      			elseif initProxy.affterCamp==2 then
	      				self:postNotificationName(UWNN.UWShouBingCmd);
	      			elseif initProxy.affterCamp==3 then
	      				self:postNotificationName(UWNN.UWJiaoZhenCmd,{action=1});
	      			elseif initProxy.affterCamp==4 then
	      				self:postNotificationName(UWNN.UWDiaoBingCmd,{action=1});
	      			end
	      		end
	      	else
	          		NetHandler:showFailedMessage(netData);
	      	end
	end
end

function UWSelectCampCmd:execute(notification)
	if notification.action==1 then--选择阵营
		local str=string.format("&city_id=%d&camp=%d",_G_UN_CITY_ID,notification.camp);--camp 1攻击方 2防守方
		NetHandler:sendData(Post_Union_War_addCamp, str);
	else--关闭阵营
		local initProxy=self:getProxy(UWNN.UWInitProxy);
		initProxy:openSelectCamp(false);
	end
end

return UWSelectCampCmd;