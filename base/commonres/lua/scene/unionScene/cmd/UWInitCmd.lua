----公会战初始化----
--author:hhh time:2017.11.6
local UWInitCmd=class("UWInitCmd",Command); 

function UWInitCmd:ctor()
	UWInitCmd.super.ctor(self);
	NetHandler:addAckCode(self,Post_Union_War_index);
end

function UWInitCmd:onRemove()
	NetHandler:delAckCode(self,Post_Union_War_index);
end

function UWInitCmd:onReciveData(msgID, netData)
	local initProxy=self:getProxy(UWNN.UWInitProxy);
	if msgID==Post_Union_War_index then
	      	if netData.state==1 then
	      		initProxy:initBack(netData);
	      		if initProxy.isFightBack then
	      			enterLuaScene(_G.sceneData.sceneType,1,1);--关闭战斗
	      		end
	      	elseif tonumber(netData.reportMsg)==161 then--进入公会战加载过程中结束了
	      		GobalDialog:getInstance():showAlert(MG_TEXT("unionWar_37"),function()
				enterLuaScene(_G.sceneData.lastSceneType);	
			end);
	      	else
	          		NetHandler:showFailedMessage(netData);
	      	end
	end
end

function UWInitCmd:execute(notification)
	local initProxy=self:getProxy(UWNN.UWInitProxy);
	if notification~=nil then--TWMainLayer过来初始化
		initProxy.isFightBack=notification.isFightBack;
		local topBox=notification.topBox;
		local midBox=notification.midBox;
		local btmBox=notification.btmBox;

		self:addView(UWNN.UWTopView,topBox);
		self:addView(UWNN.UWMidView,midBox);
		self:addView(UWNN.UWBtmView,btmBox);

		self:postNotificationName(UWNN.UWNTFCmd);
	end
	self:sendReq();
end

function UWInitCmd:sendReq()
	local str=string.format("&city_id=%d",_G_UN_CITY_ID);
	NetHandler:sendData(Post_Union_War_index, str);
end

return UWInitCmd;