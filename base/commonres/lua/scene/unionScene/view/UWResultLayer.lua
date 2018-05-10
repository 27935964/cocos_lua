----公会战战斗结果----
--author:hhh time:2017.11.13
local UWResultLayer=class("UWResultLayer",function()
	return cc.Layer:create();
end);

function UWResultLayer:ctor()
	self.view=nil;

	MGRCManager:cacheResource("UWResultLayer","GuildWar_Result_WinOlive.png");

	local widget=MGRCManager:widgetFromJsonFile("UWResultLayer", "GuildWar_Ui_Result.ExportJson");
	self:addChild(widget);

	local panel_mask=widget:getChildByName("Panel_mask");--Panel

	local panel_content=widget:getChildByName("Panel_content");--Panel
	local button_close=panel_content:getChildByName("Button_close");--Button
	button_close:addTouchEventListener(handler(self,self.onButton_OkClick));

	self.attackerName=panel_content:getChildByName("Label_GuildName_Attacker");--Label

	local label_troops1=panel_content:getChildByName("Label_Troops1");--Label
	label_troops1:setText(MG_TEXT_COCOS("GuildWar_Ui_Result_1"));
	self.troopsnumber1=panel_content:getChildByName("Label_TroopsNumber1");--Label

	local label_damagetroops1=panel_content:getChildByName("Label_DamageTroops1");--Label
	label_damagetroops1:setText(MG_TEXT_COCOS("GuildWar_Ui_Result_2"));
	self.damagetroopsnumber1=panel_content:getChildByName("Label_DamageTroopsNumber1");--Label

	local label_mostkill_1=panel_content:getChildByName("Label_MostKill_1");--Label
	label_mostkill_1:setText(MG_TEXT_COCOS("GuildWar_Ui_Result_3"));
	self.mostkiller_1=panel_content:getChildByName("Label_MostKiller_1");--Label

	self.defenderName=panel_content:getChildByName("Label_GuildName_Defender");--Label
	
	local label_troops2=panel_content:getChildByName("Label_Troops2");--Label
	label_troops2:setText(MG_TEXT_COCOS("GuildWar_Ui_Result_1"));
	self.troopsnumber2=panel_content:getChildByName("Label_TroopsNumber2");--Label

	local label_damagetroops2=panel_content:getChildByName("Label_DamageTroops2");--Label
	label_damagetroops2:setText(MG_TEXT_COCOS("GuildWar_Ui_Result_2"));
	self.damagetroopsnumber2=panel_content:getChildByName("Label_DamageTroopsNumber2");--Label

	local label_mostkill_2=panel_content:getChildByName("Label_MostKill_2");--Label
	label_mostkill_2:setText(MG_TEXT_COCOS("GuildWar_Ui_Result_3"));
	self.mostkiller_2=panel_content:getChildByName("Label_MostKiller_2");--Label

	self.winoliveImg=panel_content:getChildByName("Image_WinOlive");--ImageView

	local button_ok=panel_content:getChildByName("Button_Ok");--Button
	button_ok:addTouchEventListener(handler(self,self.onButton_OkClick));
	local label_ok=button_ok:getChildByName("Label_Ok");--Label
	label_ok:setText(MG_TEXT_COCOS("GuildWar_Ui_Result_4"));

	local label_tile=panel_content:getChildByName("Label_tile");--Label
	label_tile:setText(MG_TEXT_COCOS("GuildWar_Ui_Result_5"));

	self.Image_flagBg1=panel_content:getChildByName("Image_flagBg1");
	self.Image_flagIcon1=panel_content:getChildByName("Image_flagIcon1");
	self.Image_flagBg2=panel_content:getChildByName("Image_flagBg2");
	self.Image_flagIcon2=panel_content:getChildByName("Image_flagIcon2");
end

function UWResultLayer:initData(initProxy)
	local index=initProxy.index;
	self.attackerName:setText(unicode_to_utf8(index.atk_union_name));
	if index.dfd_union_id==0 then--NPC公会名称
		self.defenderName:setText(index.npcUnionName);
	else
		self.defenderName:setText(unicode_to_utf8(index.dfd_union_name));
	end
	self:setFlag(index);

	local resultData=initProxy.resultData;
	if resultData.row==1 then
		self.winoliveImg:setPositionX(241);
	else
		self.winoliveImg:setPositionX(647);
	end
	self.troopsnumber1:setText(tostring(resultData.data.atk_num));
	self.troopsnumber2:setText(tostring(resultData.data.dfd_num));
	self.damagetroopsnumber1:setText(tostring(resultData.data.atk_die));
	self.damagetroopsnumber2:setText(tostring(resultData.data.dfd_die));
	self.mostkiller_1:setText(to_utf8(resultData.data.atk_kill_name));
	self.mostkiller_2:setText(to_utf8(resultData.data.dfd_kill_name));
end

function UWResultLayer:setFlag(index)
	local unionFlag=index.war_union_flag;
	self.Image_flagBg1:loadTexture(string.format("guild_flag_%d.png",unionFlag.atk.flag_bg),ccui.TextureResType.plistType);
	self.Image_flagIcon1:loadTexture(string.format("guild_totem_%d.png",unionFlag.atk.flag),ccui.TextureResType.plistType);
	
	if index.dfd_union_id==0 then--NPC公会旗子，公会名称读配置
		self.Image_flagBg2:loadTexture(string.format("guild_flag_%d.png",index.npcFlagBgId),ccui.TextureResType.plistType);
		self.Image_flagIcon2:loadTexture(string.format("guild_totem_%d.png",index.npcFlagIconId),ccui.TextureResType.plistType);
		self.defenderName:setText(index.npcUnionName);
	else
		self.Image_flagBg2:loadTexture(string.format("guild_flag_%d.png",unionFlag.dfd.flag_bg),ccui.TextureResType.plistType);
		self.Image_flagIcon2:loadTexture(string.format("guild_totem_%d.png",unionFlag.dfd.flag),ccui.TextureResType.plistType);
	end
end

function UWResultLayer:onButton_closeClick(sender, eventType)
	buttonClickScale(sender,eventType,1);
	if eventType == ccui.TouchEventType.ended then
		--MGSound:getInstance():play(SOUND_COM_CLICK);
		self.view:postNotificationName(UWNN.UWExitCmd);
	end
end

function UWResultLayer:onButton_OkClick(sender, eventType)
	buttonClickScale(sender,eventType,1);
	if eventType == ccui.TouchEventType.ended then
		--MGSound:getInstance():play(SOUND_COM_CLICK);
		self.view:postNotificationName(UWNN.UWExitCmd);
	end
end

function UWResultLayer:onEnter()

end

function UWResultLayer:onExit()
	MGRCManager:releaseResources("UWResultLayer");
end

function UWResultLayer:setView(view)
	self.view=view;
end

return UWResultLayer;