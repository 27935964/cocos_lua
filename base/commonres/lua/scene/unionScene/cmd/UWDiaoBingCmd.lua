----公会战调兵----
--author:hhh time:2017.11.8
local UWDiaoBingCmd=class("UWDiaoBingCmd",Command); 

function UWDiaoBingCmd:ctor()
	UWDiaoBingCmd.super.ctor(self);
	NetHandler:addAckCode(self,Post_Union_War_checkDispatch);
	NetHandler:addAckCode(self,Post_Union_War_useDeclareWarNum);
	NetHandler:addAckCode(self,Post_Union_Troops_index);
	NetHandler:addAckCode(self,Post_Union_War_unionDispatchTroops);
end

function UWDiaoBingCmd:onRemove()
	NetHandler:delAckCode(self,Post_Union_War_checkDispatch);
	NetHandler:delAckCode(self,Post_Union_War_useDeclareWarNum);
	NetHandler:delAckCode(self,Post_Union_Troops_index);
	NetHandler:delAckCode(self,Post_Union_War_unionDispatchTroops);
end

function UWDiaoBingCmd:onReciveData(msgID, netData)
	local initProxy=self:getProxy(UWNN.UWInitProxy);
	if msgID==Post_Union_War_checkDispatch then
		if netData.state==1 then
			if initProxy.userCamp==0 then--玩家未加入阵营，显示加入阵营界面
				initProxy.affterCamp=4;
				initProxy:openSelectCamp(true);
			elseif initProxy.index.is_dispatch==0 then--公会宣战次数未扣过
				local maxNum=tonumber(LUADB.readConfig(127));
				local msg=string.format(MG_TEXT("unionWar_13"),maxNum-initProxy.index.my_union_declear_num,maxNum);
				GobalDialog:getInstance():showComfirm(msg,function()
					local str=string.format("&city_id=%d",_G_UN_CITY_ID);
					NetHandler:sendData(Post_Union_War_useDeclareWarNum, str);
				end);
			else--显示调兵界面，请求数据
				self:reqTroops();
			end
		else
		     	NetHandler:showFailedMessage(netData);
		end
	elseif msgID==Post_Union_War_useDeclareWarNum then
		if netData.state==1 then--显示调兵界面，请求数据
			initProxy.index.is_dispatch=1;
			self:reqTroops();
		else
		     	NetHandler:showFailedMessage(netData);
		end
	elseif msgID==Post_Union_Troops_index then
		if netData.state==1 then--显示调兵界面，请求数据
			initProxy.troopsData=initProxy:parseTroops(netData.index);
			initProxy:openDiaoBin(true);
		else
		     	NetHandler:showFailedMessage(netData);
		end
	elseif msgID==Post_Union_War_unionDispatchTroops then
		if netData.state==1 then--派遣士兵
			local troops=netData.uniondispatchtroops;
			initProxy:updataTroops(troops);
			local msg=string.format(MG_TEXT("unionWar_18"),#troops.ids);
			MGMessageTip:showSuccessMessage(msg);
		else
		     	NetHandler:showFailedMessage(netData);
		end
	end
end

function UWDiaoBingCmd:reqTroops()
	NetHandler:sendData(Post_Union_Troops_index,"");
end

function UWDiaoBingCmd:execute(notification)
	local initProxy=self:getProxy(UWNN.UWInitProxy);
	if notification.action==1 then
		local str=string.format("&city_id=%d",_G_UN_CITY_ID);--判断10名以上成员达到服务器平均等级
		NetHandler:sendData(Post_Union_War_checkDispatch, str);
	elseif notification.action==2 then
		initProxy:openDiaoBin(false);
	elseif notification.action==3 then
		local heros=cjson.encode(notification.data);
		local str=string.format("&city_id=%d&ids=%s",_G_UN_CITY_ID,heros);--判断10名以上成员达到服务器平均等级
		NetHandler:sendData(Post_Union_War_unionDispatchTroops, str);
	end
end

return UWDiaoBingCmd;