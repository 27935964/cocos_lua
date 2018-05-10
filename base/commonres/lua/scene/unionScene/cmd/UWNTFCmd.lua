----公会战推送----
--author:hhh time:2017.11.13
local UWNTFCmd=class("UWNTFCmd",Command); 

function UWNTFCmd:ctor()
	UWNTFCmd.super.ctor(self);
	NetHandler:addAckCode(self,TCP_UNION_WAR_ACTION_NTF);
	NetHandler:addAckCode(self,TCP_UNION_WAR_BACK_NTF);
	NetHandler:addAckCode(self,TCP_UNION_WAR_RESULT_NTF);
	NetHandler:addAckCode(self,TCP_UNION_WAR_ARMY_NUM_NTF);
	NetHandler:addAckCode(self,TCP_UNION_WAR_ARMY_HEAD_NTF);
	NetHandler:addAckCode(self,TCP_UNION_WAR_ARMY_WILL_OVER);
	NetHandler:addAckCode(self,TCP_UNION_WAR_KILL_NUM_NTF);
end

function UWNTFCmd:onRemove()
	NetHandler:delAckCode(self,TCP_UNION_WAR_ACTION_NTF);
	NetHandler:delAckCode(self,TCP_UNION_WAR_BACK_NTF);
	NetHandler:delAckCode(self,TCP_UNION_WAR_RESULT_NTF);
	NetHandler:delAckCode(self,TCP_UNION_WAR_ARMY_NUM_NTF);
	NetHandler:delAckCode(self,TCP_UNION_WAR_ARMY_HEAD_NTF);
	NetHandler:delAckCode(self,TCP_UNION_WAR_ARMY_WILL_OVER);
	NetHandler:delAckCode(self,TCP_UNION_WAR_KILL_NUM_NTF);
end

function UWNTFCmd:onReciveData(msgID, jsonData)
	if _G.sceneData.isFightBack==true then--进入战斗详情
		return;
	end

	local initProxy=self:getProxy(UWNN.UWInitProxy);
	local arr=string.split(jsonData,"|");
	local msg={};
	msg.channel=tonumber(arr[1]);
	msg.cityId=tonumber(arr[2]);
	msg.row=tonumber(arr[3]);
	if msgID==TCP_UNION_WAR_ACTION_NTF then
		local s,n=string.gsub(arr[4],"+","|");
		msg.data=cjson.decode(s);
		initProxy:actionNTF(msg);
	elseif msgID==TCP_UNION_WAR_BACK_NTF then
		initProxy:backNTF(msg);
	elseif msgID==TCP_UNION_WAR_RESULT_NTF then
		local s,n=string.gsub(arr[4],"+","|");
		msg.data=cjson.decode(s);
		initProxy:resultNTF(msg);
	elseif msgID==TCP_UNION_WAR_ARMY_NUM_NTF then
		msg.data=cjson.decode(arr[4]);
		initProxy:armyNumNTF(msg);
	elseif msgID==TCP_UNION_WAR_ARMY_HEAD_NTF then
		msg.data=cjson.decode(arr[4]);
		initProxy:armyHeadNTF(msg);
	elseif msgID==TCP_UNION_WAR_ARMY_WILL_OVER then
		msg.time=arr[4];
		initProxy:willOver(msg);
	elseif msgID==TCP_UNION_WAR_KILL_NUM_NTF then
		msg.num=arr[4];
		initProxy:killNumNTF(msg);
	end
	-- print(">>> UWNTFCmd:onReciveData",msgID,msg.row);
end

function UWNTFCmd:execute(notification)

end

return UWNTFCmd;