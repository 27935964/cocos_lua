----公会战主界面菜单----
--author:hhh time:2017.11.8
local UWFrameLayer=class("UWFrameLayer",function()
	return cc.Layer:create();
end);

function UWFrameLayer:ctor()
	self.view=nil;

	local widget=MGRCManager:widgetFromJsonFile("UWFrameLayer", "GuildWar_Main_UI_1.ExportJson");
	self:addChild(widget);

	local panel_left=widget:getChildByName("Panel_left");--Panel
	local button_back=panel_left:getChildByName("Button_back");--Button
	button_back:addTouchEventListener(handler(self,self.onButton_backClick));

	local image_level_frame=panel_left:getChildByName("Image_Level_Frame");--ImageView
	local label_level=image_level_frame:getChildByName("Label_Level");--Label
	label_level:setText(MG_TEXT_COCOS("GuildWar_Main_UI_1"));
	self.labelLevelNum=image_level_frame:getChildByName("Label_Level_number");--Label参战等级

	local image_kills_frame=panel_left:getChildByName("Image_Kills_Frame");--ImageView
	local label_kills=image_kills_frame:getChildByName("Label_Kills");--Label
	label_kills:setText(MG_TEXT_COCOS("GuildWar_Main_UI_2"));
	self.labelKilssNum=image_kills_frame:getChildByName("Label_Kilss_number");--Label杀敌数

	local image_rank_frame=panel_left:getChildByName("Image_Rank_Frame");--ImageView
	local label_myrank=image_rank_frame:getChildByName("Label_MyRank");--Label
	label_myrank:setText(MG_TEXT_COCOS("GuildWar_Main_UI_3"));
	self.labelRank=image_rank_frame:getChildByName("Label_25");--Label我的排名

	self.panel_top=widget:getChildByName("Panel_top");--Panel
	self.labelTime=self.panel_top:getChildByName("Label_Time");--Label战斗剩余时间
	self.timeBg=self.panel_top:getChildByName("Image_35");--Label战斗剩余时间
	self.labelAttackName=self.panel_top:getChildByName("Label_OffenseName");--Label攻击方公会名称
	self.labelAttackNum=self.panel_top:getChildByName("Label_Offense_number");--Label攻击方部队数量
	self.labelDefendname=self.panel_top:getChildByName("Label_DefendName");--Label防守方公会名称
	self.labelDefendNum=self.panel_top:getChildByName("Label_Defend_number");--Label防守方部队数量
	self.attackFlagbox=self.panel_top:getChildByName("offenseFlagBox");--Panel攻击方协助公会旗子
	self.defendFlagbox=self.panel_top:getChildByName("defendFlagBox");--Panel防守方协助公会旗子
	self.flagDetail=self.panel_top:getChildByName("Image_GuildInfo");
	self.img_Flag=self.flagDetail:getChildByName("Image_Flag");
	self.img_Totem=self.flagDetail:getChildByName("Image_Totem");
	self.label_AssociationGuild=self.flagDetail:getChildByName("Label_AssociationGuild");
	self.label_GuildName=self.flagDetail:getChildByName("Label_GuildName");
	self.flagDetail:setVisible(false);

	self.overImg=self.panel_top:getChildByName("Image_over");
	self.msgLabel= MGColorLabel:label();
	self.msgLabel:setAnchorPoint(cc.p(0.5,0.5));
	self.msgLabel:setPosition(self.overImg:getContentSize().width/2, self.overImg:getContentSize().height/2);
	self.msgLabel:appendStringAutoWrap(MG_TEXT("unionWar_41"),50,1,Color3B.WHITE,24);
	self.overImg:addChild(self.msgLabel);
	self.overImg:setVisible(false);


	local panel_right=widget:getChildByName("Panel_right");--Panel
	local button_rank=panel_right:getChildByName("Button_Rank");--Button
	button_rank:addTouchEventListener(handler(self,self.onButton_RankClick));--排名

	local button_reward=panel_right:getChildByName("Button_Reward");--Button
	button_reward:addTouchEventListener(handler(self,self.onButton_RewardClick));--累计奖励

	local panel_rightbtm=widget:getChildByName("Panel_rightBtm");--Panel
	self.button_defend=panel_rightbtm:getChildByName("Button_Defend");--Button守卫
	self.button_defend:addTouchEventListener(handler(self,self.onButton_DefendClick));

	self.button_depoly=panel_rightbtm:getChildByName("Button_Depoly");--Button调兵
	self.button_depoly:addTouchEventListener(handler(self,self.onButton_DepolyClick));

	local button_challenge=panel_rightbtm:getChildByName("Button_Challenge");--Button叫阵
	button_challenge:addTouchEventListener(handler(self,self.onButton_ChallengeClick));

	local button_withdraw=panel_rightbtm:getChildByName("Button_WithDraw");--Button收兵
	button_withdraw:addTouchEventListener(handler(self,self.onButton_WithDrawClick));

	local button_dispatch=panel_rightbtm:getChildByName("Button_Dispatch");--Button出兵
	button_dispatch:addTouchEventListener(handler(self,self.onButton_DispatchClick));

	self.leftTime=0;
	self.status=0;
	self.timeFor="";
	self.isWillOver=false;
	self.timer=CCTimer:new();
	self.willTimer=nil;
	self.willLeftTime=0;
end

function UWFrameLayer:initData(initProxy)
	local index=initProxy.index;
	local userWarInfo=index.user_war_info;

	self.labelLevelNum:setText(tostring(index.general_lv));
	if initProxy.userCamp==0 then
		self.labelRank:setText(MG_TEXT("unionWar_12"));
		self.labelKilssNum:setText(tostring(0));
	else
		if index.my_kill_rank<=0 then
			self.labelRank:setText(MG_TEXT("unionWar_12"));
		else
			self.labelRank:setText(tostring(index.my_kill_rank));
		end
		self.labelKilssNum:setText(tostring(userWarInfo.kill));
	end
	self.labelAttackName:setText(unicode_to_utf8(index.atk_union_name));
	self.labelAttackNum:setText(tostring(index.atk_camp_num));

	if index.dfd_union_id==0 then--NPC公会名称
		self.labelDefendname:setText(index.npcUnionName);
	else
		self.labelDefendname:setText(unicode_to_utf8(index.dfd_union_name));
	end
	self.labelDefendNum:setText(tostring(index.dfd_camp_num));
	self:showOtherFlag(self.attackFlagbox,index.atk_assist_union,-1);--功方协助旗子
	self:showOtherFlag(self.defendFlagbox,index.dfd_assist_union,1);--守方协助旗子

	if index.my_post==10 or index.my_post==9 then--10会长，9副会长
		self.button_depoly:setEnabled(true);--调兵按钮
		if tonumber(userWarInfo.union_id)==index.dfd_union_id and (index.war_city_type==1 or index.war_city_type==2) then--1都城 2卫城 0都不是,我是防守方
			self.button_defend:setEnabled(true);--守卫按钮
		else
			self.button_defend:setEnabled(false);
		end
	else
		self.button_defend:setEnabled(false);
		self.button_depoly:setEnabled(false);
	end

	self.status=initProxy.status;
	self.leftTime=initProxy.leftTime;
	if self.status==0 then
		self.labelTime:setText(string.format(MG_TEXT("unionWar_10"),MGDataHelper:secToString(self.leftTime)));
		self.timer:startTimer(1000,handler(self,self.updateTime),false);
	else
		if self.leftTime>0 then
			self.labelTime:setText(string.format(MG_TEXT("unionWar_11"),MGDataHelper:secToString(self.leftTime)));
			self.timer:startTimer(1000,handler(self,self.updateTime),false);
		else
			self.labelTime:setText("");
		end
	end
end

function UWFrameLayer:showOtherFlag(box,data,dir)
	box:removeAllChildren();
	local UWFlagImg=require "UWFlagImg";
	local flag,width;
	for k,v in pairs(data) do
		flag=UWFlagImg.new(self);
		flag:setData(v,dir);
		flag:setScale(0.4);
		width=flag:getSize().width*flag:getScaleX();
		flag:setPosition(dir*width*0.5+(k-1)*dir*width,26);
		box:addChild(flag);
	end
end

function UWFrameLayer:flagClick(item,value)
	if item.data then
		self.flagDetail:setVisible(value);
		if value==true then
			local x=item:getPositionX()-147;
			local y=-170;
			self.img_Totem:loadTexture(string.format("guild_totem_%d.png",item.data.flag_bg),ccui.TextureResType.plistType);
			self.img_Flag:loadTexture(string.format("guild_flag_%d.png",item.data.flag),ccui.TextureResType.plistType);
			if item.dir==-1 then
				self.label_AssociationGuild:setText(MG_TEXT("unionWar_39"));
				self.flagDetail:setPosition(self.attackFlagbox:getPositionX()+x,y);
			else
				self.label_AssociationGuild:setText(MG_TEXT("unionWar_40"));
				self.flagDetail:setPosition(self.defendFlagbox:getPositionX()+x,y);
			end
			self.label_GuildName:setText(unicode_to_utf8(item.data.union_name));
		end
	end
end

function UWFrameLayer:armyNum(msg)
	local row=msg.row;--1攻击方 2防守方
	local sum=msg.data.sum;
	if row==1 then
		self.labelAttackNum:setText(tostring(sum));
	else
		self.labelDefendNum:setText(tostring(sum));
	end
end

function UWFrameLayer:killNum(initProxy,msg)
	if msg then
		self.labelKilssNum:setText(msg.num);
	end
	local index=initProxy.index;
	if index.my_kill_rank<=0 then
		self.labelRank:setText(MG_TEXT("unionWar_12"));
	else
		self.labelRank:setText(tostring(index.my_kill_rank));
	end
end

function UWFrameLayer:updateTime()
	self.leftTime=self.leftTime-1;
	if self.leftTime>0 then
		if self.status==0 then
			self.labelTime:setText(string.format(MG_TEXT("unionWar_10"),MGDataHelper:secToString(self.leftTime)));
		else
			self.labelTime:setText(string.format(MG_TEXT("unionWar_11"),MGDataHelper:secToString(self.leftTime)));
		end
	else
		if self.status==0 then
			self.status=1;
			self.leftTime=tonumber(LUADB.readConfig(153));
			self.labelTime:setText(string.format(MG_TEXT("unionWar_11"),MGDataHelper:secToString(self.leftTime)));
		else
			self.timer:stopTimer();
			self.labelTime:setText("");
			self.timeBg:setVisible(false);
		end
	end
end

function UWFrameLayer:willTime()
	self.willLeftTime=self.willLeftTime-1;
	if self.willLeftTime>0 then
		self.msgLabel:clear();
		self.msgLabel:appendStringAutoWrap(string.format(self.timeFor,self.willLeftTime),50,1,Color3B.WHITE,24);
	else
		if self.willTimer~=nil then
			self.willTimer:stopTimer();
		end
		self.overImg:setVisible(false);
		self.msgLabel:clear();
	end
end

function UWFrameLayer:willOver(initProxy,data)
	if initProxy.isWillOver then
		self.willLeftTime=data.leftTime;
		if data.row==1 then
			self.timeFor=MG_TEXT("unionWar_41");
		else
			self.timeFor=MG_TEXT("unionWar_42");
		end
		if self.willTimer==nil then
			self.willTimer=CCTimer:new();
		end
		self.willTimer:startTimer(1000,handler(self,self.willTime),false);
		self.overImg:setVisible(true);
		self.msgLabel:clear();
		self.msgLabel:appendStringAutoWrap(string.format(self.timeFor,self.willLeftTime),50,1,Color3B.WHITE,24);
	else--结束被打断
		if self.willTimer~=nil then
			self.willTimer:stopTimer();
		end
		self.overImg:setVisible(false);
		self.msgLabel:clear();
	end
end

function UWFrameLayer:onButton_backClick(sender, eventType)
	buttonClickScale(sender,eventType,1);
	if eventType == ccui.TouchEventType.ended then
		--MGSound:getInstance():play(SOUND_COM_CLICK);
		self.view:postNotificationName(UWNN.UWExitCmd);
	end
end

function UWFrameLayer:onButton_RankClick(sender, eventType)
	buttonClickScale(sender,eventType,1);
	if eventType == ccui.TouchEventType.ended then
		--MGSound:getInstance():play(SOUND_COM_CLICK);
		self.view:postNotificationName(UWNN.UWRankCmd,{action=1});
	end
end

function UWFrameLayer:onButton_RewardClick(sender, eventType)
	buttonClickScale(sender,eventType,1);
	if eventType == ccui.TouchEventType.ended then
		--MGSound:getInstance():play(SOUND_COM_CLICK);
		self.view:postNotificationName(UWNN.UWRewardCmd,{action=1});
	end
end

function UWFrameLayer:onButton_DefendClick(sender, eventType)
	buttonClickScale(sender,eventType,1);
	if eventType == ccui.TouchEventType.ended then
		--MGSound:getInstance():play(SOUND_COM_CLICK);
		self.view:postNotificationName(UWNN.UWDefendCmd,{action=1});
	end
end

function UWFrameLayer:onButton_DepolyClick(sender, eventType)
	buttonClickScale(sender,eventType,1);
	if eventType == ccui.TouchEventType.ended then
		--MGSound:getInstance():play(SOUND_COM_CLICK);
		self.view:postNotificationName(UWNN.UWDiaoBingCmd,{action=1});
	end
end

function UWFrameLayer:onButton_ChallengeClick(sender, eventType)
	buttonClickScale(sender,eventType,1);
	if eventType == ccui.TouchEventType.ended then
		--MGSound:getInstance():play(SOUND_COM_CLICK);
		self.view:postNotificationName(UWNN.UWJiaoZhenCmd,{action=1});
	end
end

function UWFrameLayer:onButton_WithDrawClick(sender, eventType)
	buttonClickScale(sender,eventType,1);
	if eventType == ccui.TouchEventType.ended then
		--MGSound:getInstance():play(SOUND_COM_CLICK);
		self.view:postNotificationName(UWNN.UWShouBingCmd);
	end
end

function UWFrameLayer:onButton_DispatchClick(sender, eventType)
	buttonClickScale(sender,eventType,1);
	if eventType == ccui.TouchEventType.ended then
		--MGSound:getInstance():play(SOUND_COM_CLICK);
		self.view:postNotificationName(UWNN.UWChuBingCmd,{action=1});
	end
end

function UWFrameLayer:onEnter()

end

function UWFrameLayer:onExit()
	if self.timer~=nil then
	    	self.timer:stopTimer();
	end

	if self.willTimer~=nil then
		self.willTimer:stopTimer();
	end
	MGRCManager:releaseResources("UWFrameLayer");
end

function UWFrameLayer:setView(view)
	self.view=view;
end

return UWFrameLayer;