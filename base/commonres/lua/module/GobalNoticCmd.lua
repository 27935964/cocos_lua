----全局数据推送----
--author:hhh time:2017.17.7

local GobalNoticCmd=class("GobalNoticCmd",Command); 

function GobalNoticCmd:ctor()
	GobalNoticCmd.super.ctor(self);
	self:setGobal(true);
	-- NetHandler:addAckCode(self,Post_Union_War_unionBuyNpc);
end

function GobalNoticCmd:onRemove()
	-- NetHandler:delAckCode(self,Post_Union_War_unionBuyNpc);
	print("GobalNoticCmd:onRemove error: can not remove GobalNoticCmd");
end

function GobalNoticCmd:onReciveData(msgID, netData)
	local gobalProxy=self:getProxy("GobalProxy");

	-- if msgID==Post_Union_War_unionBuyNpc then
	--       	if netData.state==1 then
	--       		MGMessageTip:showSuccessMessage(MG_TEXT("unionWar_19"));
	--       	else
	--           		NetHandler:showFailedMessage(netData);
	--       	end
	-- end
end

function GobalNoticCmd:execute(notification)

end

return GobalNoticCmd;
