----事件剧情列表项----
--author:hhh time:2017.10.24

local PlotListItem=class("PlotListItem",function()
	return ccui.Layout:create();
end);

function PlotListItem:ctor(main)
	self.main=main;
	self:setSize(cc.size(262,80));
	self.bg=cc.Sprite:createWithSpriteFrameName("Plot_Menu_bg1.png");
	self.bg:setAnchorPoint(cc.p(0,0));
	self:addChild(self.bg);

	local ttfConfig={}
	ttfConfig.fontFilePath=ttf_msyh
	ttfConfig.fontSize=22;

	self.tileLabel=cc.Label:createWithTTF(ttfConfig,MG_TEXT("plotMenu1"), cc.VERTICAL_TEXT_ALIGNMENT_CENTER);
	self.tileLabel:setTextColor(cc.c4b(255, 216, 0,255));
	self.tileLabel:setAnchorPoint(cc.p(0.5, 0.5));
	self.tileLabel:setPosition(cc.p(90,55));
	self:addChild(self.tileLabel);
	
	self.timeLabel=cc.Label:createWithTTF(ttfConfig,"10:22:34", cc.VERTICAL_TEXT_ALIGNMENT_CENTER);
	self.timeLabel:setTextColor(cc.c4b(64, 246, 0,255));
	self.timeLabel:setAnchorPoint(cc.p(0.5, 0.5));
	self.timeLabel:setPosition(cc.p(90,25));
	self:addChild(self.timeLabel);

	self.lvLabel=cc.Label:createWithTTF(ttfConfig,"LV10", cc.VERTICAL_TEXT_ALIGNMENT_CENTER);
	self.lvLabel:setTextColor(cc.c4b(188, 169, 102,255));
	self.lvLabel:setAnchorPoint(cc.p(1, 0.5));
	self.lvLabel:setPosition(cc.p(60,25));
	self:addChild(self.lvLabel);

	self.nameLabel=cc.Label:createWithTTF(ttfConfig,"玩家名字", cc.VERTICAL_TEXT_ALIGNMENT_CENTER);
	self.nameLabel:setTextColor(cc.c4b(64, 246, 0,255));
	self.nameLabel:setAnchorPoint(cc.p(0, 0.5));
	self.nameLabel:setPosition(cc.p(70,25));
	self:addChild(self.nameLabel);

	local HeroCircleHead=require "HeroCircleHead";
	self.circleHead=HeroCircleHead.new(nil,1);
	self.circleHead:setPosition(cc.p(220,40));
	self:addChild(self.circleHead);

	self:setTouchEnabled(true);
	self:addTouchEventListener(handler(self,self.onItemClick));

	NodeListener(self);

	-- self:setBackGroundColorType(1);
	-- self:setBackGroundColor(Color3B.RED);

	self.itemType=0;--1神秘商店，2入侵事件，3开放事件,4未开放事件
	self.data=nil;
	self.timer=CCTimer:new();
end

function PlotListItem:onItemClick(sender, eventType)
          if eventType == ccui.TouchEventType.ended then
                    if self.main then
                    		if self.itemType==1 then
	                    		if self.main.openMysteryStore then
	                            		self.main:openMysteryStore(true);
	                            	end
	                       elseif self.itemType==2 then
	                       	if self.main.openInvadeLayer then
	                       		self.main:openInvadeLayer(true,self.data);
	                       	end
	                       elseif self.itemType==3 then
	                       	if self.main.openPlotLayer then
	                       		self.main:openPlotLayer(true,self.data);
	                       	end
	                       elseif self.itemType==4 then
	               		MGMessageTip:showFailedMessage(MG_TEXT("plotMenu3"));
	               		return;
	                       end

                            	if self.main.openPlotList then
                            		self.main:openPlotList(false);
                            	end
                    end
          end
end

function PlotListItem:initData(type,data)
	self.itemType=type;
	self.data=data;
	if type==1 then--神秘商店
		self.tileLabel:setString(MG_TEXT("plotMenu1"));
		self.lvLabel:setVisible(false);
		self.nameLabel:setVisible(false);
		self.timeLabel:setVisible(true);
		self.leftTime=tonumber(data.sterious_shop_time)-os.time();
		if self.leftTime>0 then
			self.timer:startTimer(1000,handler(self,self.updateTime),false);--每秒回调一次
		else
			self.leftTime=0;
			self:removeMe();
		end
		self.timeLabel:setTextColor(cc.c4b(64, 246, 0,255));
		self.timeLabel:setString(MGDataHelper:secToString(self.leftTime));
		self.circleHead:setHeroFace("Plot_Menu_store_icon.png");
	elseif type==2 then--入侵事件
		self.tileLabel:setString(data.stageInfo.name);
		self.timeLabel:setVisible(false);
		self.lvLabel:setVisible(true);
		self.lvLabel:setString(string.format(MG_TEXT("plotMenu4"),data.lv));
		self.nameLabel:setVisible(true);
		self.nameLabel:setString(unicode_to_utf8(data.name));
		self.circleHead:setHeroFace(data.rewardData.icon);
	elseif type==3 then--开放事件
		local sql=string.format("select * from plot_list where p_id=%d",data.p_id);
		local dbData=LUADB.select(sql, "name:open_lv:show_pic");
		if dbData==nil then
			print("PlotListItem:initData error",sql);
			return;
		end

		self.data.plotData=dbData.info;
		self.tileLabel:setString(dbData.info.name);
		self.lvLabel:setVisible(false);
		self.nameLabel:setVisible(false);
		self.timeLabel:setVisible(true);
		self.leftTime=tonumber(data.end_time)-os.time();
		if self.leftTime>0 then
			self.timer:startTimer(1000,handler(self,self.updateTime),false);--每秒回调一次
		else
			self.leftTime=0;
			self:removeMe();
		end
		self.timeLabel:setTextColor(cc.c4b(64, 246, 0,255));
		self.timeLabel:setString(MGDataHelper:secToString(self.leftTime));
		self.circleHead:setHeroId(data.heroId);
	elseif type==4 then
		self.lvLabel:setVisible(false);
		self.nameLabel:setVisible(false);
		self.timeLabel:setVisible(true);
		self.tileLabel:setString(data.name);
		self.timeLabel:setTextColor(cc.c4b(255, 0, 0,255));
		self.timeLabel:setString(string.format(MG_TEXT("plotMenu2"),data.open_lv));
		self.circleHead:setHeroId(data.heroId);
	end
end

function PlotListItem:updateTime()
           self.leftTime=self.leftTime-1;
           self.timeLabel:setString(MGDataHelper:secToString(self.leftTime));
           if self.leftTime==0 then
                 	self.timer:stopTimer();
                 	self:removeMe();
           end
end

function PlotListItem:removeMe()
	if self.main and self.main.reopenPlotList then
		self.main:reopenPlotList()
	end
end

function PlotListItem:onEnter()

end

function PlotListItem:onExit()
	if self.timer then
		self.timer:stopTimer();
		self.timer=nil;
	end
	MGRCManager:releaseResources("PlotListItem");
end

return PlotListItem;