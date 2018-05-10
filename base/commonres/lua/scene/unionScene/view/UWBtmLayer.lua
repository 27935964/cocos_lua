----公会战战场----
--author:hhh time:2017.11.17

local UWBtmLayer=class("UWBtmLayer",function()
	return cc.Layer:create();
end);

function UWBtmLayer:ctor()
	local winSize=cc.Director:getInstance():getWinSize();

	self.touchArr={};
	self.mapWidth=0;
	self.mapHeight=0;
	self.gridWidth=140;
	self.gridHeight=70;
	self.camps={};--双方的营帐
	self:createMap("GuildWarMap1");
	self.bound={minX=-(self.mapWidth-winSize.width),maxX=0,minY=-(self.mapHeight-winSize.height),maxY=0};--边界

	local eventDispatcher = self:getEventDispatcher();
	local listener=cc.EventListenerTouchOneByOne:create();--点击事件
	listener:setSwallowTouches(true);
	listener:registerScriptHandler(handler(self,self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN);
	listener:registerScriptHandler(handler(self,self.onTouchMoved), cc.Handler.EVENT_TOUCH_MOVED);
	listener:registerScriptHandler(handler(self,self.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED);
	listener:registerScriptHandler(handler(self,self.onTouchCancelled), cc.Handler.EVENT_TOUCH_CANCELLED);
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener,self);

	MGRCManager:cacheResource("UWBtmLayer","GuildWarMap_posBg.png");
	self.gridPos={};
	self.campPos={
		{{x=351,y=552},{x=3072,y=552}},
		{{x=292,y=486},{x=3115,y=486}},
		{{x=237,y=415},{x=3155,y=415}},
		{{x=175,y=343},{x=3203,y=343}},
		{{x=110,y=254},{x=3260,y=254}},
	};
	self:initGrid();

	self.soiderLines={};--战斗数据
	local UWSoiderLine=require "UWSoiderLine";
	local soiderLine;
	for row=1,5 do
		soiderLine=UWSoiderLine.new(self,row);
		self:addChild(soiderLine,0);
		table.insert(self.soiderLines,soiderLine);
	end

	self.timer=CCTimer:new();
	self.timer:startTimer(1500,handler(self,self.updateTime),false);
end

function UWBtmLayer:initGrid()
	local startX=404+70;
	local startY=460;
	local midX=math.floor(self.mapWidth/2)+1;
	local dotX,dotY,offsetX,offsetY;
	for row=1,5 do
		if self.gridPos[row]==nil then
			self.gridPos[row]={};
		end

		for col=1,18 do
			dotX=startX+(col-1)*self.gridWidth;
			dotY=startY-(row-1)*self.gridHeight;
			offsetX=(dotX-midX)*(row-1)*0.04;
			offsetY=(dotY-startY)*(row-1)*0.05;
			dotX=dotX+offsetX;
			dotY=dotY+offsetY;
			table.insert(self.gridPos[row],{x=dotX,y=dotY});

			-- local UWDot=require "UWDot";--test
			-- local dot=UWDot.new();--显示坐标点
			-- dot:initData(col);
			-- dot:setScale(1-(5-row)*0.0625);
			-- dot:setPosition(self.gridPos[row][col]);
			-- self:addChild(dot);
		end
	end
end


function UWBtmLayer:onTouchBegan(touch, event)
        	if #self.touchArr>1 then
            	return false;
        	end

        	table.insert(self.touchArr,touch);
        	self.isTouchMove=false;
        	self.touchPoint=self.touchArr[1]:getLocation();
        	return true;
end

function UWBtmLayer:onTouchMoved(touch, event)
           if touch==self.touchArr[1] then
           		local diff = self.touchArr[1]:getDelta();
                    	local dragLen=cc.pGetLength(diff);
                    	if dragLen>2 then
                        	self.isTouchMove=true;
                        	local x, y=self:getPosition();
                        	x=x + diff.x;
                        	y=y + diff.y;
                        	x,y=self:getBound(x,y);
                       	self:setPosition(cc.p(x,y));
                    	end
           end
end

function UWBtmLayer:getBound(x,y)
	x=math.max(self.bound.minX,x);
	x=math.min(self.bound.maxX,x);
	y=math.max(self.bound.minY,y);
	y=math.min(self.bound.maxY,y);
	return x,y;
end

function UWBtmLayer:onTouchEnded(touch, event)
          	self.isTouchMove=false;
        	self.touchArr={};
end

function UWBtmLayer:onTouchCancelled(touch, event)
           	if touch==self.touchArr[1] then
           		self.touchArr={};
           		self.isTouchMove=false;
           	end
end

function UWBtmLayer:sodierClick(sodier)
	self.view:postNotificationName(UWNN.UWTeamInfoCmd,{action=1,data=sodier.data});
end

function UWBtmLayer:initData(initProxy)
	local index=initProxy.index;
	local run_info=index.run_info;
	local camp_num_info=index.camp_num_info;--阵营的部队数量
	local campData;
	local UWCampLayer=require "UWCampLayer";
	for row,v1 in pairs(self.campPos) do
		if self.camps[row]==nil then
			self.camps[row]={};
		end

		for col,v2 in pairs(v1) do
			if col==1 then
				campData=camp_num_info.atk;
			else
				campData=camp_num_info.dfd;
			end

			local campLayer=UWCampLayer.new();
			campLayer:setPosition(v2);
			campLayer:setNum(campData[tostring(row)]);
			self:addChild(campLayer,10);
			table.insert(self.camps[row],campLayer);
		end
	end

	if initProxy.userCamp~=0 and (initProxy.userCamp==1 or initProxy.userCamp==2) then
		local campData=index.camp_herds;
		for k,v in pairs(campData) do
			local campLayer=self.camps[v.row][initProxy.userCamp];
			if campLayer then
				campLayer:setHeroId(tonumber(v.head));
			end
		end
	end

	for k,v in pairs(run_info) do
		local soiderLine=self.soiderLines[v.row];
		if soiderLine then
			soiderLine:initData(v.info);
		end
	end
end

function UWBtmLayer:fightAction(msg)
	local row=msg.row;
	local soiderLine=self.soiderLines[row];
	if soiderLine then
		soiderLine:updataData(msg.data);
	end
end

function UWBtmLayer:fightBack(msg)
	local row=msg.row;
	local soiderLine=self.soiderLines[row];
	if soiderLine then
		soiderLine:back(msg.data);
	end
end

function UWBtmLayer:armyNum(msg)
	local row=msg.row;--1攻击方 2防守方
	local campData=msg.data.info;
	for row,v in pairs(self.camps) do
		local campLayer=v[msg.row];
		if campLayer then	
			campLayer:setNum(campData[tostring(row)]);
		end
	end
end

function UWBtmLayer:armyHead(msg)
	local row=msg.row;--1攻击方 2防守方
	for row,v in pairs(self.camps) do
		local campLayer=v[msg.row];
		if campLayer then
			campLayer:setHeroId(0);
		end
	end

	local campData=msg.data;
	for k,v in pairs(campData) do
		local campLayer=self.camps[v.row][msg.row];
		if campLayer then
			campLayer:setHeroId(tonumber(v.head));
		end
	end
end

function UWBtmLayer:updateTime()
	for k,v in pairs(self.soiderLines) do
		v:updataStep();
	end
end

function UWBtmLayer:createMap(fileName)
	self.mapWidth=0;
	self.mapHeight=0;
	for i=1,3 do
		local imgName=string.format("%s_%d.jpg",fileName,i);
		MGRCManager:cacheResource("UWBtmLayer",imgName);
		local sp=cc.Sprite:createWithSpriteFrameName(imgName);
		sp:setAnchorPoint(0,0);
		sp:setPosition(cc.p(self.mapWidth,0));
		local size=sp:getContentSize();
		self.mapWidth=self.mapWidth+size.width;
		if size.height>self.mapHeight then
			self.mapHeight=size.height;
		end
		self:addChild(sp);
	end
end

function UWBtmLayer:lostHP(soilder,value)
	local x,y=soilder:getPosition();
	local scale=math.abs(soilder.rowScale);
	local hpLabel=cc.Label:createWithBMFont("war_font_blooddamage.fnt","0");
	local hpStr=tostring(value);
	hpLabel:setString(hpStr);
	hpLabel:setScale(scale);
	hpLabel:setPosition(x,y+20);
	self:addChild(hpLabel,11);
	hpLabel:setVisible(false);

	local delay=cc.DelayTime:create(0.6);
	local callFunc1=cc.CallFunc:create(function(label)
		label:setVisible(true);
	end);
	local inScale=cc.Spawn:create(cc.MoveBy:create(0.25*scale,cc.p(0, 40)), cc.ScaleTo:create(0.25*scale, 1.8*scale));
	local scaleSmal=cc.ScaleTo:create(0.15*scale, 0.85*scale);
	local showTime=cc.DelayTime:create(0.4);
	local outScale=cc.ScaleTo:create(0.1, 0.1);
	local callFunc2=cc.CallFunc:create(function(label)
		label:removeFromParent();
	end);
	local action=cc.Sequence:create(delay,callFunc1,inScale,scaleSmal,showTime,outScale,callFunc2);
	hpLabel:runAction(action);
end

function UWBtmLayer:onEnter()

end

function UWBtmLayer:onExit()
	if self.timer~=nil then
	    	self.timer:stopTimer();
	end
	MGRCManager:releaseResources("UWBtmLayer");
end

function UWBtmLayer:setView(view)
	self.view=view;
	for k,v in pairs(self.soiderLines) do
		v:setView(view);
	end
end

return UWBtmLayer;