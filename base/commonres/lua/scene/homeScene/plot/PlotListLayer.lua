----事件剧情列表----
--author:hhh time:2017.10.24

local PlotListItem=require "PlotListItem";

local PlotListLayer=class("PlotListLayer",function()
	return cc.Layer:create();
end);

function PlotListLayer:ctor(main)
	self.main=main;
	MGRCManager:cacheResource("PlotListLayer","PlotListUI.png","PlotListUI.plist");

	self.winSize=cc.Director:getInstance():getWinSize();
	self.bg=ccui.Layout:create();
	self.bg:setSize(self.winSize);
	-- self.bg:setBackGroundColorType(1);
	-- self.bg:setBackGroundColor(Color3B.BLUE);
	self:addChild(self.bg);
	self.bg:setTouchEnabled(true);
	self.bg:addTouchEventListener(handler(self,self.onCloseClick));

	self.bgHeight=125;
	self.layerBg=cc.Scale9Sprite:createWithSpriteFrameName("Plot_Menu_bg.png", cc.rect(150, 47, 1, 1));
	self.layerBg:setAnchorPoint(cc.p(0.5,1));
	self.layerBg:setContentSize(cc.size(302,self.bgHeight));
	self:addChild(self.layerBg);

	self.listView=ccui.ListView:create();--ListView
	self.listView:setClippingType(1);
	self.listView:setDirection(ccui.ScrollViewDir.vertical);
	self.listView:setTouchEnabled(true);
	self.listView:setBounceEnabled(true);
	self.listView:setSize(cc.size(290, self.bgHeight-45));
	self.listView:setScrollBarVisible(false);--true添加滚动条
	self.listView:setItemsMargin(5);
	self.listView:setPositionY(-30);
	-- self.listView:setBackGroundColorType(1);
	-- self.listView:setBackGroundColor(Color3B.BLUE);
	self.listView:setAnchorPoint(cc.p(0.5,1));
	self:addChild(self.listView);

	NodeListener(self);
end

function PlotListLayer:onCloseClick(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
	          if self.main then
	                  self.main:openPlotList(false);
	          end
	end
end

function PlotListLayer:setShopData(getusermain)
	self.listView:removeAllItems();
	local shopTime=tonumber(getusermain.sterious_shop_time)-os.time();
	if shopTime>0 then
		local item=PlotListItem.new(self.main);
		item:initData(1,getusermain);--神秘商店
		self.listView:pushBackCustomItem(item);
	end

	NetHandler:sendData(Post_Plot_plotList, "");--玩家事件

	local x,y=self:getPosition();
	self.bg:setPosition(cc.p(-x,-y));
end

function PlotListLayer:onReciveData(msgId, netData)
    	if msgId == Post_Plot_plotList then
          		if netData.state == 1 then
              		self.userPlot=netData.plotlist.user_plot;
                              	NetHandler:sendData(Post_Invade_invadeList, "");--玩家事件
          		else
              		NetHandler:showFailedMessage(netData);
          		end
          	elseif msgId==Post_Invade_invadeList then
          		if netData.state==1 then
          			self.userInvade=netData.invadelist.user_invade;
          			self:initData();
          		else
          			NetHandler:showFailedMessage(netData);
          		end
    	end
end

function PlotListLayer:initData()
	local eventNum=0;
	local sql,dbData,item;
	for k,v in pairs(self.userPlot) do
		sql=string.format("select * from plot_list where p_id=%d",v.p_id);
		dbData=LUADB.select(sql, "show_pic");
		if dbData then
			local arr=string.split(dbData.info.show_pic,":");--查找武将头像
			if arr and arr[1] then
				v.heroId=arr[1];
				item=PlotListItem.new(self.main);--玩家事件
				item:initData(3,v);
				self.listView:pushBackCustomItem(item);
				eventNum=eventNum+1;
			end
		end
	end

	if eventNum==0 then
		sql=string.format("select * from plot_list where open_lv>=%d",ME:Lv());
		dbData=LUADB.select(sql, "name:open_lv:show_pic");
		if dbData==nil then
			print("PlotListLayer:initData",sql);
			return;
		end

		local data=dbData.info;
		local arr=string.split(data.show_pic,":");--查找武将头像
		if arr and arr[1] then
			data.heroId=arr[1];
			item=PlotListItem.new(self.main);--玩家事件
			item:initData(4,data);
			self.listView:pushBackCustomItem(item);
		end
	end

	for k,v in pairs(self.userInvade) do
		local resData=ResourceTip.getInstance():getResData(v.reward);
		v.rewardData=resData;
		sql=string.format("select * from stage_list where id>=%d",v.s_id);
		dbData=LUADB.select(sql, "name");
		if dbData~=nil then
			v.stageInfo=dbData.info;
			item=PlotListItem.new(self.main);--入侵事件
			item:initData(2,v);
			self.listView:pushBackCustomItem(item);
		else
			print("PlotListLayer:initData",sql);
		end
	end

	local items=self.listView:getItems();
	self:updataBgHeight(#items);
end

function PlotListLayer:updataBgHeight(count)
	local bgHeight=self.bgHeight+(count-1)*85;
	if bgHeight>465 then
		bgHeight=465;
	end
	self.layerBg:setContentSize(cc.size(302,bgHeight));
	self.listView:setSize(cc.size(290,bgHeight-45));
end

function PlotListLayer:onEnter()
	NetHandler:addAckCode(self,Post_Plot_plotList);
	NetHandler:addAckCode(self,Post_Invade_invadeList);
end

function PlotListLayer:onExit()
	NetHandler:delAckCode(self,Post_Plot_plotList);
	NetHandler:delAckCode(self,Post_Invade_invadeList);
	MGRCManager:releaseResources("PlotListLayer");
end

return PlotListLayer;