----公会战出兵---
--author:hhh time:2017.11.8
local UWChuBingCmd=class("UWChuBingCmd",Command); 

function UWChuBingCmd:execute(notification)
	local initProxy=self:getProxy(UWNN.UWInitProxy);
	if initProxy.userCamp==0 then--玩家未加入阵营，显示加入阵营界面
		initProxy.affterCamp=1;
		initProxy:openSelectCamp(true);
	else
		local teamdata = string.format("&city_id=%d",_G_UN_CITY_ID);
		FightOP:setTeam(_G.sceneData.sceneType,Fight_union_war,teamdata,"",MG_TEXT("unionWar_2"));
	end
end

return UWChuBingCmd;