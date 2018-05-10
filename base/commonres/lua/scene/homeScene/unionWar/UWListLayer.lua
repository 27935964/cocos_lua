----主界面公会战列表----
--author:hhh time:2017.11.6

local UWListItem=require "UWListItem";

local UWListLayer=class("UWListLayer",function()
	return cc.Layer:create();
end);

function UWListLayer:ctor(main)
	self.main=main;
	MGRCManager:cacheResource("UWListLayer","PlotListUI.png","PlotListUI.plist");

	self.winSize=cc.Director:getInstance():getWinSize();
	self.bg=ccui.Layout:create();
	self.bg:setSize(self.winSize);
	-- self.bg:setBackGroundColorType(1);
	-- self.bg:setBackGroundColor(Color3B.BLUE);
	self:addChild(self.bg);
	self.bg:setTouchEnabled(true);
	self.bg:addTouchEventListener(handler(self,self.onCloseClick));

	self.bgHeight=95;
	self.layerBg=cc.Scale9Sprite:createWithSpriteFrameName("Plot_Menu_bg.png", cc.rect(150, 47, 1, 1));
	self.layerBg:setAnchorPoint(cc.p(0.5,1));
	self.layerBg:setContentSize(cc.size(335,self.bgHeight));
	self:addChild(self.layerBg);

	self.listView=ccui.ListView:create();--ListView
	self.listView:setClippingType(1);
	self.listView:setDirection(ccui.ScrollViewDir.vertical);
	self.listView:setTouchEnabled(true);
	self.listView:setBounceEnabled(true);
	self.listView:setSize(cc.size(335, self.bgHeight-30));
	self.listView:setScrollBarVisible(false);--true添加滚动条
	self.listView:setItemsMargin(5);
	self.listView:setPositionY(-23);
	-- self.listView:setBackGroundColorType(1);
	-- self.listView:setBackGroundColor(Color3B.BLUE);
	self.listView:setAnchorPoint(cc.p(0.5,1));
	self:addChild(self.listView);

	NodeListener(self);

	self.status=0;
	self.leftTime=0;
	self.itemArr={};
	self.unionWarList=nil;
	self.timer=CCTimer:new();
end

function UWListLayer:onCloseClick(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
	          if self.main then
	                  self.main:openUWList(false);
	          end
	end
end

function UWListLayer:initData()
	NetHandler:sendData(Post_Main_unionWarList, "");--玩家事件
	local x,y=self:getPosition();
	self.bg:setPosition(cc.p(-x,-y));
end

function UWListLayer:onReciveData(msgId, netData)
    	if msgId == Post_Main_unionWarList then
          		if netData.state == 1 then
              		self:updata(netData.unionwarlist)
          		else
              		NetHandler:showFailedMessage(netData);
          		end
    	end
end

function UWListLayer:updata(unionwarlist)
	self.unionWarList=unionwarlist;

	local startTime=LUADB.readConfig(152);
	local timeArr=string.split(startTime,":");

	local nowTime=ME:getServerTime();
	local temData=os.date("*t", nowTime);
	temData.hour=tonumber(timeArr[1]);
	temData.min=tonumber(timeArr[2]);
	startTime=os.time(temData);

	local timeStr="";
	if nowTime>startTime then
		self.status=1;
		timeStr=MG_TEXT("unionWar_29");
	else
		self.status=0;
		self.leftTime=startTime-nowTime;--战斗倒计时间
		timeStr=MGDataHelper:secToString(self.leftTime);
	end

	self.itemArr={};
	local item;
	for k,v in pairs(self.unionWarList.data) do
		item=UWListItem.new(self);--玩家事件
		item:initData(k,v,self.status,timeStr);
		self.listView:pushBackCustomItem(item);
		table.insert(self.itemArr,item);
	end

	local items=self.listView:getItems();
	self:updataBgHeight(#items);

	if self.status==0 then
		self.timer:startTimer(1000,handler(self,self.updateTime),false);--每秒回调一次
	end
end

function UWListLayer:updateTime()
           self.leftTime=self.leftTime-1;
           local timeStr="";
           if self.leftTime>0 then
           		timeStr=MGDataHelper:secToString(self.leftTime);
           else
           		self.timer:stopTimer();
           		timeStr=MG_TEXT("unionWar_29");
           end

           for k,v in pairs(self.itemArr) do
           		v:setTime(timeStr);
           end
end

function UWListLayer:updataBgHeight(count)
	local bgHeight=30+count*65+(count-1)*5;
	if bgHeight>445 then
		bgHeight=445;
	elseif bgHeight<95 then
		bgHeight=95;
	end
	self.layerBg:setContentSize(cc.size(335,bgHeight));
	self.listView:setSize(cc.size(335,bgHeight-30));
end

function UWListLayer:removeItem(index)
	if index~=0 then
		table.remove(self.itemArr,index);
		self.listView:removeItem(index-1);
		local items=self.listView:getItems();
		self:updataBgHeight(#items);
		for k,v in pairs(self.itemArr) do
			v:setIndex(k);
		end
	end
end

function UWListLayer:onEnter()
	NetHandler:addAckCode(self,Post_Main_unionWarList);
end

function UWListLayer:onExit()
	if self.timer then
		self.timer:stopTimer();
		self.timer=nil;
	end

	NetHandler:delAckCode(self,Post_Main_unionWarList);
	MGRCManager:releaseResources("UWListLayer");
end

return UWListLayer;