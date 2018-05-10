----公会战招募守卫----
--author:hhh time:2017.11.10
local UWCallDefend=class("UWCallDefend",function()
	return cc.Layer:create();
end);

function UWCallDefend:ctor()
	self.view=nil;

	local widget=MGRCManager:widgetFromJsonFile("UWCallDefend", "GuildWar_Ui_RecruitGuards.ExportJson");
	self:addChild(widget);

	local panel_mask=widget:getChildByName("Panel_mask");--Panel
	local panel_content=widget:getChildByName("Panel_content");--Panel
	local button_close=panel_content:getChildByName("Button_close");--Button
	button_close:addTouchEventListener(handler(self,self.onButton_closeClick));
	panel_mask:addTouchEventListener(handler(self,self.onButton_closeClick));

	local button_recruit=panel_content:getChildByName("Button_Recruit");--Button
	button_recruit:addTouchEventListener(handler(self,self.onButton_RecruitClick));
	local label_recruit=button_recruit:getChildByName("Label_Recruit");--Label
	label_recruit:setText(MG_TEXT_COCOS("GuildWar_Ui_RecruitGuards_4"));

	self.currNumber=panel_content:getChildByName("Label_CurrentGuardsNumber");--Label当前队伍数量
	local label_currentguards=panel_content:getChildByName("Label_CurrentGuards");--Label
	label_currentguards:setText(MG_TEXT_COCOS("GuildWar_Ui_RecruitGuards_1"));
	self.label49=panel_content:getChildByName("Label_49");--Label--可招募数
	local label_recruitment=panel_content:getChildByName("Label_Recruitment");--Label
	label_recruitment:setText(MG_TEXT_COCOS("GuildWar_Ui_RecruitGuards_2"));

	local button_reduce=panel_content:getChildByName("Button_Reduce");--Button
	button_reduce:addTouchEventListener(handler(self,self.onButton_ReduceClick));

	local button_add=panel_content:getChildByName("Button_Add");--Button
	button_add:addTouchEventListener(handler(self,self.onButton_AddClick));

	local button_max=panel_content:getChildByName("Button_Max");--Button
	button_max:addTouchEventListener(handler(self,self.onButton_MaxClick));

	self.inputNum=panel_content:getChildByName("Label_InputNumber");--Label招募数量
	local label_consume=panel_content:getChildByName("Label_Consume");--Label
	label_consume:setText(MG_TEXT_COCOS("GuildWar_Ui_RecruitGuards_3"));

	self.consumeNum=panel_content:getChildByName("Label_ConsumeNumber");--Label花费黄金
	local image_own_guildfunds=panel_content:getChildByName("Image_Own_GuildFunds");--ImageView
	self.ownGuildfunds=image_own_guildfunds:getChildByName("Label_Own_Guildfunds");--Label拥有黄金

	self.num=1;
	self.maxNum=100;
	self.cost=0;
end

function UWCallDefend:initData(initProxy)
	self.cost=tonumber(LUADB.readConfig(184));
	self:updataInput();
end

function UWCallDefend:updataInput()
	self.inputNum:setText(tostring(self.num));
	self.consumeNum:setText(tostring(self.cost*self.num));
end

function UWCallDefend:onButton_closeClick(sender, eventType)
	buttonClickScale(sender,eventType,1);
	if eventType == ccui.TouchEventType.ended then
		--MGSound:getInstance():play(SOUND_COM_CLICK);
		self.view:postNotificationName(UWNN.UWDefendCmd,{action=2});
	end
end

function UWCallDefend:onButton_RecruitClick(sender, eventType)
	buttonClickScale(sender,eventType,1);
	if eventType == ccui.TouchEventType.ended then
		--MGSound:getInstance():play(SOUND_COM_CLICK);
		self.view:postNotificationName(UWNN.UWDefendCmd,{action=3,num=self.num});
	end
end

function UWCallDefend:onButton_ReduceClick(sender, eventType)
	buttonClickScale(sender,eventType,1);
	if eventType == ccui.TouchEventType.ended then
		--MGSound:getInstance():play(SOUND_COM_CLICK);
		self.num=self.num-1;
		if self.num<1 then
			self.num=1;
		end
		self:updataInput();
	end
end

function UWCallDefend:onButton_AddClick(sender, eventType)
	buttonClickScale(sender,eventType,1);
	if eventType == ccui.TouchEventType.ended then
		--MGSound:getInstance():play(SOUND_COM_CLICK);
		self.num=self.num+1;
		if self.num>self.maxNum then
			self.num=self.maxNum;
		end
		self:updataInput();
	end
end

function UWCallDefend:onButton_MaxClick(sender, eventType)
	buttonClickScale(sender,eventType,1);
	if eventType == ccui.TouchEventType.ended then
		--MGSound:getInstance():play(SOUND_COM_CLICK);
		self.num=self.maxNum;
		self:updataInput();
	end
end

function UWCallDefend:onEnter()
	
end

function UWCallDefend:onExit()
	MGRCManager:releaseResources("UWCallDefend");
end

function UWCallDefend:setView(view)
	self.view=view;
end

return UWCallDefend;