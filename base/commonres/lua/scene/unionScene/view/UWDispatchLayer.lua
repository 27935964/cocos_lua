----公会战调兵界面派遣部队----
--author:hhh time:2017.11.9
local UWDispatchLayer=class("UWDispatchLayer",function()
	return cc.Layer:create();
end);

function UWDispatchLayer:ctor(main)
	self.main=main;

	local widget=MGRCManager:widgetFromJsonFile("UWDispatchLayer", "GuildWar_Ui_Deploy2.ExportJson");
	self:addChild(widget);

	local panel_mask=widget:getChildByName("Panel_mask");--Panel

	local panel_content=widget:getChildByName("Panel_content");--Panel
	local button_close=panel_content:getChildByName("Button_close");--Button
	button_close:addTouchEventListener(handler(self,self.onButton_closeClick));
	panel_mask:addTouchEventListener(handler(self,self.onButton_closeClick));

	self.label_name=panel_content:getChildByName("Label_Name");--Label
	local label_level=panel_content:getChildByName("Label_Level");--Label
	label_level:setText(MG_TEXT_COCOS("GuildWar_Ui_Deploy2_1"));
	self.label_level_number=panel_content:getChildByName("Label_Level_number");--Label
	local label_ce=panel_content:getChildByName("Label_CE");--Label
	label_ce:setText(MG_TEXT_COCOS("GuildWar_Ui_Deploy2_2"));
	self.label_ce_number=panel_content:getChildByName("Label_CE_number");--Label

	local button_choose=panel_content:getChildByName("Button_Choose");--Button
	button_choose:addTouchEventListener(handler(self,self.onButton_ChooseClick));
	self.label_choose=button_choose:getChildByName("Label_Choose");--Label

	self.panelHero=panel_content:getChildByName("Panel_Hero");--Panel

	self.userHead=userHead.create();
	self.userHead:setPosition(90,404);
	panel_content:addChild(self.userHead);

	self.soiderData=nil;
end

function UWDispatchLayer:initData(data)
	self.soiderData=data;
	if data.select then
		self.label_choose:setText(MG_TEXT("unionWar_15"));
	else
		self.label_choose:setText(MG_TEXT("unionWar_14"));
	end

	self.label_name:setText(unicode_to_utf8(data.name));
	self.label_level_number:setText(tostring(data.lv));
	self.label_ce_number:setText(tostring(data.score));

	local gm=GENERAL:getAllGeneralModel(data.head);
	if gm then
	    	self.userHead:setData(gm);
	end

	for k,v in pairs(data.general_info) do
		heroHead = HeroHeadEx.create(self,1);
		heroHead:setAnchorPoint(cc.p(0.5, 0.5));
		heroHead:setEnemyData(v.g_id,v.lv,v.quality,v.star);
		heroHead:showname();
		heroHead:setPosition(cc.p(60+(k-1)*120,80));
		self.panelHero:addChild(heroHead);
	end
end

function UWDispatchLayer:onButton_closeClick(sender, eventType)
	buttonClickScale(sender,eventType,1);
	if eventType == ccui.TouchEventType.ended then
		--MGSound:getInstance():play(SOUND_COM_CLICK);
		if self.main and self.main.openTeamInfo then
			self.main:openTeamInfo(false);
		end
	end
end

function UWDispatchLayer:onButton_ChooseClick(sender, eventType)
	buttonClickScale(sender,eventType,1);
	if eventType == ccui.TouchEventType.ended then
		--MGSound:getInstance():play(SOUND_COM_CLICK);
		if self.main and self.main.selectItem then
			self.main:selectItem(self.soiderData);
		end
	end
end

function UWDispatchLayer:onEnter()
	
end

function UWDispatchLayer:onExit()
	MGRCManager:releaseResources("UWDispatchLayer");
end

return UWDispatchLayer;