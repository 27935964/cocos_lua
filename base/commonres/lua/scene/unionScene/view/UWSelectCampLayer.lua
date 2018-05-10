----公会战选择阵营----
--author:hhh time:2017.11.10
local UWSelectCampLayer=class("UWSelectCampLayer",function()
	return cc.Layer:create();
end);

function UWSelectCampLayer:ctor()
	self.view=nil;

	MGRCManager:cacheResource("UWRankLayer","GuildWar_SelectCamp_UI0.png","GuildWar_SelectCamp_UI0.plist");

	local widget=MGRCManager:widgetFromJsonFile("UWSelectCampLayer", "GuildWar_Ui_SelectCamp.ExportJson");
	self:addChild(widget);

	local panel_mask=widget:getChildByName("Panel_mask");--Panel
	local panel_content=widget:getChildByName("Panel_content");--Panel

	local button_close=panel_content:getChildByName("Button_close");--Button
	button_close:addTouchEventListener(handler(self,self.onButton_closeClick));
	panel_mask:addTouchEventListener(handler(self,self.onButton_closeClick));

	self.attackerName=panel_content:getChildByName("Label_GuildName_Attacker");--Label攻击方名字
	local label_currenttroop1=panel_content:getChildByName("Label_CurrentTroop1");--Label
	label_currenttroop1:setText(MG_TEXT_COCOS("GuildWar_Ui_7"));
	self.troopNum1=panel_content:getChildByName("Label_TroopNumber1");--Label攻击方军队数量
	self.labelTips1=panel_content:getChildByName("Label_Tips1");--Label--提示信息
	self.labelTips1:setText(MG_TEXT_COCOS("GuildWar_Ui_3"));
	self.labelTips2=panel_content:getChildByName("Label_Tips2");--Label
	self.labelTips2:setText(MG_TEXT_COCOS("GuildWar_Ui_4"));

	self.defenderName=panel_content:getChildByName("Label_GuildName_Defender");--Label防守方名字
	local label_currenttroop2=panel_content:getChildByName("Label_CurrentTroop2");--Label
	label_currenttroop2:setText(MG_TEXT_COCOS("GuildWar_Ui_7"));
	self.troopNum2=panel_content:getChildByName("Label_TroopNumber2");--Label
	self.defendBtn=panel_content:getChildByName("Button_Defend");--Button
	self.defendBtn:addTouchEventListener(handler(self,self.onButton_DefendClick));
	local label_defend=self.defendBtn:getChildByName("Label_Defend");--Label
	label_defend:setText(MG_TEXT_COCOS("GuildWar_Ui_5"));

	self.attackBtn=panel_content:getChildByName("Button_attack");--Button
	self.attackBtn:addTouchEventListener(handler(self,self.onButton_attackClick));
	local label_attack=self.attackBtn:getChildByName("Label_Attack");--Label
	label_attack:setText(MG_TEXT_COCOS("GuildWar_Ui_6"));

	local label_29=panel_content:getChildByName("Label_29");--Label
	label_29:setText(MG_TEXT_COCOS("GuildWar_Ui_1"));

	self.Image_flagBg1=panel_content:getChildByName("Image_flagBg1");
	self.Image_flagIcon1=panel_content:getChildByName("Image_flagIcon1");
	self.Image_flagBg2=panel_content:getChildByName("Image_flagBg2");
	self.Image_flagIcon2=panel_content:getChildByName("Image_flagIcon2");
end

function UWSelectCampLayer:initData(initProxy)
	local index=initProxy.index;
	self.attackerName:setText(unicode_to_utf8(index.atk_union_name));
	self.troopNum1:setText(tostring(index.atk_camp_num));
	self.defenderName:setText(unicode_to_utf8(index.dfd_union_name));
	self.troopNum2:setText(tostring(index.dfd_camp_num));

	local disNum=index.atk_city_num-index.dfd_city_num;
	if disNum>=3 then--进攻方城池数大于3
		self.attackBtn:setEnabled(false);
	elseif disNum<=-3 then--防守方城池数大于3
		self.defendBtn:setEnabled(false);
		self.labelTips1:setText(MG_TEXT_COCOS("GuildWar_Ui_8"));
		self.labelTips1:setPositionX(654);
		self.labelTips2:setPositionX(640);
	else
		self.labelTips1:setVisible(false);
		self.labelTips2:setVisible(false);
		self.attackBtn:setEnabled(true);
		self.defendBtn:setEnabled(true);
	end
	self:setFlag(index);
end

function UWSelectCampLayer:setFlag(index)
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

function UWSelectCampLayer:onButton_closeClick(sender, eventType)
	buttonClickScale(sender,eventType,1);
	if eventType == ccui.TouchEventType.ended then
		--MGSound:getInstance():play(SOUND_COM_CLICK);
		self.view:postNotificationName(UWNN.UWSelectCampCmd,{action=2});
	end
end

function UWSelectCampLayer:onButton_DefendClick(sender, eventType)
	buttonClickScale(sender,eventType,1);
	if eventType == ccui.TouchEventType.ended then
		--MGSound:getInstance():play(SOUND_COM_CLICK);
		self.view:postNotificationName(UWNN.UWSelectCampCmd,{action=1,camp=2});
	end
end

function UWSelectCampLayer:onButton_attackClick(sender, eventType)
	buttonClickScale(sender,eventType,1);
	if eventType == ccui.TouchEventType.ended then
		--MGSound:getInstance():play(SOUND_COM_CLICK);
		self.view:postNotificationName(UWNN.UWSelectCampCmd,{action=1,camp=1});
	end
end

function UWSelectCampLayer:onEnter()
	
end

function UWSelectCampLayer:onExit()
	MGRCManager:releaseResources("UWSelectCampLayer");
end

function UWSelectCampLayer:setView(view)
	self.view=view;
end

return UWSelectCampLayer;