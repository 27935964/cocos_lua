----公会战战场兵线----
--author:hhh time:2017.11.23
local UWSoider=require "UWSoider";

local UWSoiderLine=class("UWSoiderLine",function()
	return cc.Layer:create();
end);

UWSoiderLine.START_COL=1;
UWSoiderLine.END_COL=18;

function UWSoiderLine:ctor(btmLayer,row)
	self:setContentSize(cc.size(100,100));
	self.btmLayer=btmLayer;
	self.row=row;
	self.data=nil;
	self.totalStep=0;
	self.step=0;
	self.attiveNum=0;
	self.soiders={};
	self.repMark={};
	self.repNum=-1;
	self.fightRound=0;
	self.runing=false;--用于控制出兵
	self.soider1=nil;
	self.soider2=nil;
	self.isFightOver=false;
	self.fightEffect=nil;
	self:createFightEffect();

	self.timeRec=MGDataHelper:getMilSec();
	self.timer=CCTimer:new();

	self.clickRect=cc.rect(0,0,0,0);
	self.clickBegin={x=0,y=0};
	self.clickEnd={x=0,y=0};

	local eventDispatcher = self:getEventDispatcher();
	local listener=cc.EventListenerTouchOneByOne:create();--点击事件
	listener:setSwallowTouches(false);
	listener:registerScriptHandler(handler(self,self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN);
	listener:registerScriptHandler(handler(self,self.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED);
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener,self);
	NodeListener(self);
end

function UWSoiderLine:createFightEffect()
	self.fightEffect=cc.Sprite:create();
	self.fightEffect:setVisible(false);
	self.btmLayer:addChild(self.fightEffect,self.row);
end

function UWSoiderLine:initData(data)
	self.data=data;

	if data.info==nil then
		-- print("UWSoiderLine:initData data.info is nil");
		return;
	end

	local col=0;
	local soider;
	for k,v in pairs(data.info) do--战斗数据
		col=tonumber(k);
		soider=UWSoider.new(self.btmLayer,self);
		soider:setData(v);
		soider:setRowCol(self.row,col);
		self.btmLayer:addChild(soider,self.row);
		self.soiders[col]=soider;
	end

	if data.report then
		local passTime=ME:getServerTime()-tonumber(data.send_time);
		print("UWSoiderLine:initData passTime",passTime);
		if passTime<5 then
			local soiderData={};--移动前
			for k,v in pairs(data.before) do
				soiderData[tonumber(k)]=v;	
			end

			local col1=0;
			local col2=0;
			local sdata=nil;
			for k,v in pairs(data.move) do
				col1=v.move[1];
				col2=v.move[#v.move];
				sdata=soiderData[col1];
				if  sdata then
					soiderData[col2]=sdata;
					soiderData[col1]=nil;
				elseif data.new_camp[v.id] then
					soiderData[col2]=data.new_camp[v.id];
				end
			end

			if self:createRepSodier(data.report.atk_pos,soiderData) and self:createRepSodier(data.report.dfd_pos,soiderData) then
				print("UWSoiderLine:initData report ok");
				self.isFightOver=false;
				self:initReport();
			end
		end
	end
end

function UWSoiderLine:createRepSodier(col,soiderData)
	local sdata=soiderData[col];
	if sdata then
		local soider=self.soiders[col];
		if soider then
			soider:setData(sdata);
		else
			soider=UWSoider.new(self.btmLayer,self);
			soider:setData(sdata);
			soider:setRowCol(self.row,col);
			self.btmLayer:addChild(soider,self.row);
			self.soiders[col]=soider;
		end
		return true;
	end
	return false;
end

function UWSoiderLine:updataData(data)

	if self.data~=nil then
		local newTime=MGDataHelper:getMilSec();
		print(string.format("UWSoiderLine:updataData 数据太快 行:%d 间隔时间:%d",self.row,newTime-self.timeRec));
		self.timeRec=newTime;
	end

	self.data=data;
	self:checkBefore(data.before);
	if data.report then--有发生战斗
		local pos1=data.report.atk_pos;
		local pos2=data.report.dfd_pos;
		self.repMark={};
		self.repMark[pos1]=true;
		self.repMark[pos2]=true;
		self.repNum=pos1+pos2;
		self.isFightOver=false;
	else 
		self.repNum=-1;
	end

	self.totalStep=#data.move;
	self.attiveNum=self.totalStep;
	self.step=1;

	print(self.step,self.totalStep);
	self.runing=true;
end

function UWSoiderLine:back(data)
	for k,v in pairs(self.soiders) do
		v:removeFromParent();
	end
	self.soiders={};
end

function UWSoiderLine:checkBefore(beforeData)
	self.fightEffect:setVisible(false);

	self.runing=false;
	self.fightRound=0;
	self.timer:stopTimer();

	local col=0;
	local soider;
	local hasSoider={};
	for k,v in pairs(beforeData) do
		col=tonumber(k);
		soider=self.soiders[col];
		if soider==nil then
			print("UWSoiderLine:checkBefore 战前创建部队",col);
			soider=UWSoider.new(self.btmLayer,self);
			soider:setData(v);
			soider:setRowCol(self.row,col);
			self.btmLayer:addChild(soider,self.row);
			self.soiders[col]=soider;
		end
		hasSoider[col]=true;
	end

	for i=self.START_COL,self.END_COL do
		if not hasSoider[i] then
			soider=self.soiders[i];
			if soider~=nil then
				print("UWSoiderLine:checkBefore 战前删除部队",i);
				soider:removeFromParent();
				self.soiders[i]=nil;
			end
		end
	end
end

function UWSoiderLine:updataStep()
	if not self.runing then 
		return; 
	end

	if self.step<=self.totalStep then
		local moveData=self.data.move[self.step];
		self:move(moveData);
		self.step=self.step+1;
	else
		self.runing=false;
	end
end

function UWSoiderLine:move(moveData)
	local col1=moveData.move[1];
	local col2=moveData.move[#moveData.move];
	local soider;
	if col1==self.START_COL or col1==self.END_COL then
		soider=self.soiders[col1];
		if soider==nil then
			local soiderData=self.data.new_camp[moveData.id];
			if soiderData then
				soider=UWSoider.new(self.btmLayer,self);
				soider:setData(soiderData);
				soider:setRowCol(self.row,col1);
				self.btmLayer:addChild(soider,self.row);
				self.soiders[col1]=soider;
			else
				print("UWSoiderLine error 新出生军队的数据",moveData.id);
				return;
			end
		end
	else
		soider=self.soiders[col1];
		if soider==nil then
			print("UWSoiderLine error 该位置军队没找到",col1);
			return;
		end
	end

	soider:moveTo(col2);
	self.soiders[col1]=nil;
	self.soiders[col2]=soider;
end

function UWSoiderLine:soiderArrive(col)
	if self.repNum~=-1 then--有战报
		if self.repMark[col] then--判断双方是否都到达战斗位置
			self.repNum=self.repNum-col;
			local soider=self.soiders[self.repNum];--有一方部队没有移动位置,就发生战报
			if soider and (soider.action==1 or soider.action==4) then--武将在待机(站，欢呼)
				self.repNum=0;
			end

			if self.repNum==0 then
				self:initReport();
			end
		end
	end

	self.attiveNum=self.attiveNum-1;
	if self.attiveNum==0 then--每个军队都走到目标位置
		if self.repNum==-1 or self.isFightOver==true then--无战报
			self:checkData();--校验军队血量
		end
	end
end

function UWSoiderLine:initReport()
	self.fightRound=5;
	local report=self.data.report;
	self.soider1=self.soiders[report.atk_pos];
	self.soider2=self.soiders[report.dfd_pos];
	if self.soider1~=nil and self.soider2~=nil then
		local arr=string.split(report.atk_forces,":");
		local maxHP=tonumber(arr[1]);
		local curHP=tonumber(arr[2])+report.atk_lose;
		self.soider1:updateHP(curHP,maxHP);

		arr=string.split(report.dfd_forces,":");
		maxHP=tonumber(arr[1]);
		curHP=tonumber(arr[2])+report.dfd_lose;
		self.soider2:updateHP(curHP,maxHP);
		self:showFightEffect(self.soider1,self.soider2);
		self:playFight();
		self.timer:startTimer(1500,handler(self,self.updateFight),false);
	end
end

function UWSoiderLine:showFightEffect(soider1,soider2)

	self.fightEffect:setVisible(true);
	local x1,y1=soider1:getPosition();
	local x2,y2=soider2:getPosition();
	self.fightEffect:setPosition(cc.p(x1+math.floor((x2-x1)*0.5),y1+50));
	self.fightEffect:setScale(math.abs(soider1.rowScale));

	self.fightEffect:stopAllActions();
	local action=fuGetAnimate("GuildWar_fightEffect",0,11,0.083,true)
	self.fightEffect:runAction(action);

	local x,y=self.fightEffect:getPosition();
	self.clickRect=cc.rect(x-30,y-30,60,60);
end

function UWSoiderLine:onTouchBegan(touch, event)
	if self.fightEffect:isVisible()==false then
		return false;
	else
		self.clickBegin=touch:getLocation();
		local point=self:convertToNodeSpace(self.clickBegin);
		if not cc.rectContainsPoint(self.clickRect, point) then
		        	return false;
		end
	end
        	return true;
end

function UWSoiderLine:onTouchEnded(touch, event)
       	self.clickEnd=touch:getLocation();
       	local len=cc.pGetLength(cc.pSub(self.clickEnd,self.clickBegin));
       	if len<=10 then
       		if self.fightEffect:isVisible() then
       			self.view:postNotificationName(UWNN.UWFightDetailCmd,{reportName=self.data.report.report_name});
       		end
       	end
end

function UWSoiderLine:updateFight()
	if self.fightRound>0 then
		self:playFight();
	else
		self.timer:stopTimer();
	end
end

function UWSoiderLine:playFight()
	local report=self.data.report;
	local lost1=0;
	local lost2=0;
	if self.fightRound==1 then
		lost1=report.atk_lose;
		lost2=report.dfd_lose;
	else
		lost1=report.atk_lose/self.fightRound*math.random(0.8,1.9);
		report.atk_lose=report.atk_lose-lost1;
		lost2=report.dfd_lose/self.fightRound*math.random(0.8,1.9);
		report.dfd_lose=report.dfd_lose-lost2;
	end
	self.soider1:attack();
	self.soider2:attack();
	self.soider1:lostHP(-lost1);
	self.soider2:lostHP(-lost2);
	self.fightRound=self.fightRound-1;
	if self.fightRound==0 then
		if report.win==1 then
			self.soider1:setIsWin(true);
			self.soiders[report.dfd_pos]=nil;
			self.soider2:die();
		else
			self.soider2:setIsWin(true);
			self.soiders[report.atk_pos]=nil;
			self.soider1:die();
		end

		self.timer:stopTimer();
		self.soider1=nil;
		self.soider2=nil;
		self.fightEffect:stopAllActions();
		self.fightEffect:setVisible(false);
	end
end

--战斗结束
function UWSoiderLine:fightOver()
	self.isFightOver=true;
	if self.attiveNum==0 then
		self:checkData();
	end
	self.view:postNotificationName(UWNN.UWRankCmd,{action=3});
end

function UWSoiderLine:checkData()
	if self.data then
		for k,v in pairs(self.soiders) do
			local data=self.data.info[tostring(k)];
			if data then
				v:checkData(data);
			end
		end
		self.data=nil;
	end
end

function UWSoiderLine:onEnter()
	
end

function UWSoiderLine:onExit()
	if self.timer~=nil then
	    	self.timer:stopTimer();
	end
end

function UWSoiderLine:setView(view)
	self.view=view;
end

return UWSoiderLine;