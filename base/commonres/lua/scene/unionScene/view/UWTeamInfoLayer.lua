----公会战队伍信息----
--author:hhh time:2017.11.9
local UWTeamInfoLayer=class("UWTeamInfoLayer",function()
	return cc.Layer:create();
end);

function UWTeamInfoLayer:ctor()
	self.view=nil;

	local widget=MGRCManager:widgetFromJsonFile("UWTeamInfoLayer", "GuildWar_Ui_TeamDetail.ExportJson");
	self:addChild(widget);
	local panel_mask=widget:getChildByName("Panel_mask");--Panel
	local panel_content=widget:getChildByName("Panel_content");--Panel
	local button_close=panel_content:getChildByName("Button_close");--Button
	button_close:addTouchEventListener(handler(self,self.onButton_closeClick));
	panel_mask:addTouchEventListener(handler(self,self.onButton_closeClick));

	self.labelName=panel_content:getChildByName("Label_Name");--Label玩家名称
	local label_level=panel_content:getChildByName("Label_Level");--Label
	label_level:setText(MG_TEXT_COCOS("GuildWar_Ui_TeamDetail_1"));
	self.levelNum=panel_content:getChildByName("Label_Level_number");--Label--等级
	local label_guild=panel_content:getChildByName("Label_Guild");--Label
	label_guild:setText(MG_TEXT_COCOS("GuildWar_Ui_TeamDetail_2"));
	self.label_guild_name=panel_content:getChildByName("Label_Guild_name");--Label
	local label_ce=panel_content:getChildByName("Label_CE");--Label
	label_ce:setText(MG_TEXT_COCOS("GuildWar_Ui_TeamDetail_3"));
	self.ceNum=panel_content:getChildByName("Label_CE_number");--Label--战力
	self.label_buff=panel_content:getChildByName("Label_Buff");--Label
	self.label_buff_description=panel_content:getChildByName("Label_Buff_Description");--Label
	self.panelHero=panel_content:getChildByName("Panel_Hero");--Panel

	self.userHead=userHead.create();
	self.userHead:setPosition(90,345);
	panel_content:addChild(self.userHead);
end

function UWTeamInfoLayer:initData(initProxy)
	local data=initProxy.teamData;
	
	self.labelName:setText(to_utf8(data.name));
	self.levelNum:setText(tostring(data.lv));
	local heroArr,heroHead,gm;
	if tostring(data.uid)=="0" then
		self.label_guild_name:setText(unicode_to_utf8(data.union_name));
		self.ceNum:setText(tostring(data.score));
		gm=GENERAL:getAllGeneralModel(data.head);
		if gm then
		    	self.userHead:setData(gm);
		end
		local corps=data.corps;
		heroArr=getrewardlist(corps);
		for k,v in pairs(heroArr) do
			gm=NPCGeneralModel:create(v.id);
			if gm then
				heroHead = HeroHeadEx.create(self,1);
				heroHead:setAnchorPoint(cc.p(0.5, 0.5));
				heroHead:setData(gm,tostring(data.uid)=="0");
				heroHead:showname();
				heroHead:setPosition(cc.p(60+(k-1)*120,80));
				self.panelHero:addChild(heroHead);
			end
		end
	else
		local data2=initProxy.teamDataEx;
		self.label_guild_name:setText(unicode_to_utf8(data2.union_name));
		self.ceNum:setText(tostring(data2.score));
		gm=GENERAL:getAllGeneralModel(data2.head);
		if gm then
		    	self.userHead:setData(gm);
		end
		heroArr=data2.general_info;
		for k,v in pairs(heroArr) do
			heroHead = HeroHeadEx.create(self,1);
			heroHead:setAnchorPoint(cc.p(0.5, 0.5));
			heroHead:setEnemyData(v.g_id,v.lv,v.quality,v.star);
			heroHead:showname();
			heroHead:setPosition(cc.p(60+(k-1)*120,80));
			self.panelHero:addChild(heroHead);
		end
	end

	local num=data.kill;
	if num>25 then
		num=25;
	end
	local sql=string.format("select des from union_fight_debuff where num=%d",num);
	local dbData=LUADB.select(sql, "des");
	if dbData then
		local arr=string.split(dbData.info.des,"：");
		self.label_buff:setText(arr[1]);
		self.label_buff_description:setText(arr[2]);
	else
		self.label_buff:setVisible(false);
		self.label_buff_description:setVisible(false);
	end
end

function UWTeamInfoLayer:onButton_closeClick(sender, eventType)
	buttonClickScale(sender,eventType,1);
	if eventType == ccui.TouchEventType.ended then
		--MGSound:getInstance():play(SOUND_COM_CLICK);
		self.view:postNotificationName(UWNN.UWTeamInfoCmd,{action=2});
	end
end

function UWTeamInfoLayer:onEnter()
	
end

function UWTeamInfoLayer:onExit()
	MGRCManager:releaseResources("UWTeamInfoLayer");
end

function UWTeamInfoLayer:setView(view)
	self.view=view;
end

return UWTeamInfoLayer;