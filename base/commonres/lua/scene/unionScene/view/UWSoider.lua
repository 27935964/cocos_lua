----公会战战场士兵----
--author:hhh time:2017.11.17
local UWSoider=class("UWSoider",function()
	return cc.Layer:create();
end);

function UWSoider:ctor(btmLayer,soiderLine)
	self:setContentSize(cc.size(80,80));

	self.skinIds=require "soiderConfig";
	self.btmLayer=btmLayer;
	self.gridWidth=btmLayer.gridWidth;
	self.gridPos=btmLayer.gridPos;
	self.soiderLine=soiderLine;
	self.action=0;
	self.skinId=0;
	self.skinData=nil;
	self.scaleDir=1;
	self.rowScale=1;
	self.row=0;
	self.col=0;
	self.moveTime=1.2;--2秒移动一格
	self.isMoving=false;
	self.isDie=false;
	self.isWin=false;
	self.maxHP=0;
	self.curHP=0;
	self.data=nil;

	self.skin=cc.Sprite:create();
	self:addChild(self.skin);

	self.nameBg=cc.Sprite:createWithSpriteFrameName("GuildWarMain_userNameBg.png");
	self.nameBg:setPosition(90,120);
	self.skin:addChild(self.nameBg);

	self.bufIcon=cc.Sprite:create();
	self.skin:addChild(self.bufIcon);

	local progressBg=cc.Sprite:createWithSpriteFrameName("GuildWarArms_hpBg.png");
	progressBg:setPosition(40,2);
	self.nameBg:addChild(progressBg);

	self.proTimer=cc.ProgressTimer:create(cc.Sprite:createWithSpriteFrameName("GuildWarArms_hp.png"));
	self.proTimer:setType(cc.PROGRESS_TIMER_TYPE_BAR);
	self.proTimer:setBarChangeRate(cc.p(1,0));
	self.proTimer:setMidpoint(cc.p(0,0));
	self.proTimer:setPosition(40,2);
	self.nameBg:addChild(self.proTimer);

	local lvBg=cc.Sprite:createWithSpriteFrameName("GuildWarMain_userLvBg.png");
	lvBg:setPosition(0,11);
	self.nameBg:addChild(lvBg);

	local ttfConfig={};
	ttfConfig.fontFilePath=ttf_msyh;
	ttfConfig.fontSize=14;

	self.lvLabel=cc.Label:createWithTTF(ttfConfig,"99", cc.VERTICAL_TEXT_ALIGNMENT_CENTER);
	self.lvLabel:setTextColor(cc.c4b(255, 255, 255,255));
	self.lvLabel:setAnchorPoint(cc.p(0.5, 0.5));
	self.lvLabel:setPosition(cc.p(0,11));
	self.nameBg:addChild(self.lvLabel);

	ttfConfig.fontSize=13;
	self.nameLabel=cc.Label:createWithTTF(ttfConfig,"玩家名称", cc.VERTICAL_TEXT_ALIGNMENT_CENTER);
	self.nameLabel:setTextColor(cc.c4b(255, 255, 255,255));
	self.nameLabel:setAnchorPoint(cc.p(0, 0.5));
	self.nameLabel:setPosition(cc.p(15,13));
	self.nameBg:addChild(self.nameLabel);

	self.actionFun={
		[1]=handler(self,self.stand);
		[2]=handler(self,self.walk);
		[3]=handler(self,self.attack);
		[4]=handler(self,self.win);
	}

	self:addClick();
	NodeListener(self);
end

function UWSoider:addClick()
	-- local clickRect=ccui.Layout:create();
	-- clickRect:setSize(cc.size(110,80));
	-- clickRect:setPositionX(-55);
	-- self:addChild(clickRect);
	-- clickRect:setBackGroundColorType(1);
	-- clickRect:setBackGroundColor(Color3B.BLUE);
	
	self.clickRect=cc.rect(-55,0,110,80);
	self.clickBegin={x=0,y=0};
	self.clickEnd={x=0,y=0};
	local eventDispatcher = self:getEventDispatcher();
	local listener=cc.EventListenerTouchOneByOne:create();--点击事件
	listener:setSwallowTouches(false);
	listener:registerScriptHandler(handler(self,self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN);
	listener:registerScriptHandler(handler(self,self.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED);
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener,self);
end

function UWSoider:onTouchBegan(touch, event)
	self.clickBegin=touch:getLocation();
        	local point=self:convertToNodeSpace(self.clickBegin);
        	if not cc.rectContainsPoint(self.clickRect, point) then
        	           return false;
        	end
        	return true;
end

function UWSoider:onTouchEnded(touch, event)
       	self.clickEnd=touch:getLocation();
       	local len=cc.pGetLength(cc.pSub(self.clickEnd,self.clickBegin));
       	if len<=10 then
       		if self.btmLayer and self.btmLayer.sodierClick then
       			self.btmLayer:sodierClick(self);
       		end
       	end
end

function UWSoider:setData(data)
	self.data=data;
	local camp=tonumber(data.camp);
	if camp==1 then
		self.scaleDir=1;
	else
		self.scaleDir=-1;
		self.lvLabel:setScaleX(self.scaleDir);
		self.nameLabel:setScaleX(self.scaleDir);
		self.nameLabel:setAnchorPoint(cc.p(1, 0.5));
	end

	self.nameLabel:setString(to_utf8(data.name));
	self.lvLabel:setString(tostring(data.lv));

	if data.forces=="0" then
		self:updateHP(0,0);
	else
		local arr=string.split(data.forces,":");
		local curHP=tonumber(arr[2]);
		local maxHP=tonumber(arr[1]);
		self:updateHP(curHP,maxHP);
	end

	local skinId=self:getLeadSkinId(data);
	if skinId~=0 then
		self:setSkin(skinId);
	else
		print("UWSoider:skinId error",data.corps);
	end
	self:updataBuff(data.kill);
end

function UWSoider:updateHP(curHP,maxHP)
	self.curHP=curHP;
	self.maxHP=maxHP;
	if self.maxHP==0 then
		self.proTimer:setPercentage(99.99);
	else
		local percent=math.floor(self.curHP*100/self.maxHP);
		if percent>=100 then
			percent=99.99;
		end
		self.proTimer:setPercentage(percent);
	end
end

function UWSoider:lostHP(value)
	if value==0 then
		value=1;
	end

	if self.btmLayer then	
		self.btmLayer:lostHP(self,math.ceil(value));
	end
	self.curHP=self.curHP+value;
	local percent=math.floor(self.curHP*100/self.maxHP);
	if percent>=100 then
		percent=99.99;
	end
	local progressTo=cc.ProgressTo:create(0.6, percent);
	local action=cc.Sequence:create(cc.DelayTime:create(1),progressTo);
	self.proTimer:runAction(action);
end

function UWSoider:checkData(data)
	if data.forces=="0" then
		self:updateHP(0,0);
	else
		local arr=string.split(data.forces,":");
		local curHP=tonumber(arr[2]);
		local maxHP=tonumber(arr[1]);
		self:updateHP(curHP,maxHP);
	end
	self:updataBuff(data.kill);
end

function UWSoider:updataBuff(kill)
	if kill<=0 then
		self.bufIcon:setVisible(false);
	else
		if kill>25 then
			kill=25;
		end
		local sql=string.format("select pic from union_fight_debuff where num=%d",kill);
		local dbData=LUADB.select(sql, "pic");
		if dbData then
			local picName=dbData.info.pic..".png";
			MGRCManager:cacheResource("UWSoider",picName);
			self.bufIcon:setSpriteFrame(picName);
			self.bufIcon:setVisible(true);
		end
	end
end

function UWSoider:getLeadSkinId(data)
	local temArr=getrewardlist(data.corps);
	if #temArr>0 then
		local heroId=temArr[1].id;
		local sql="";
		if tostring(data.uid)=="0" then--npc
			sql=string.format("select soldier_id from npc where id=%d",heroId);
		else
			sql=string.format("select soldier_id from general_list where id=%d",heroId);
		end
		local dbData=LUADB.select(sql, "soldier_id");
		if dbData then
			return tonumber(dbData.info.soldier_id);
		end
	end
	return 0;
end

function UWSoider:setSkin(skinId)
	if skinId<1 or skinId>10 then
		print("UWSoider:setSkin skinId error",skinId);
		return;
	end
	self.skinId=skinId;
	self.skinData=self.skinIds[skinId];
	self.skin:setAnchorPoint(self.skinData.anchor);
	self.nameBg:setPosition(self.skinData.npos);
	local x=self.skinData.anchor.x*self.skinData.size.width;
	local y=self.skinData.size.height*0.5-self.skinData.anchor.y*self.skinData.size.height;
	self.bufIcon:setPosition(x,y);
	self:stand();
end

function UWSoider:setAction(action)
	if self.action~=action and self.actionFun[action] then
		self.actionFun[action]();
	end
end

function UWSoider:setRowCol(row,col)
	local pos=self.gridPos[row][col];
	if pos then
		self.row=row;
		self.col=col;
		self:setPosition(pos);
		self:setMYScale();
	end
end

function UWSoider:setMYScale()
	self.rowScale=(1-(5-self.row)*0.0625);
	self.skin:setScale(self.rowScale);
	self.skin:setScaleX(self.rowScale*self.scaleDir);
end

function UWSoider:moveTo(col)
	if self.isMoving then
		return;
	end

	self.isMoving=true;
	local pos=self.gridPos[self.row][col];
	if pos then
		self:stopAllActions();
		self.action=0;
		self:walk();

		local time=math.abs(col-self.col)*self.moveTime;
		self.col=col;
		local action=cc.MoveTo:create(time,pos);
		action=cc.Sequence:create(action, cc.CallFunc:create(handler(self,self.changStand)));
		self:runAction(action);
	end
end

function UWSoider:stand()
	if self.skinId~=0 and self.action~=1 then
		self.action=1;
		self.skin:stopAllActions();
		local actionName=self.skinData.skinPre.."_stand_";
		self.skin:setSpriteFrame(actionName.."0.png");
		local action=fuGetAnimate(actionName,0,self.skinData.stand,self.skinData.speed,true);
		self.skin:runAction(action);
	end
end

function UWSoider:walk()
	if self.skinId~=0 and self.action~=2 then
		self.action=2;
		self.skin:stopAllActions();
		local actionName=self.skinData.skinPre.."_walk_";
		self.skin:setSpriteFrame(actionName.."0.png");
		local action=fuGetAnimate(actionName,0,self.skinData.walk,self.skinData.speed,true);
		self.skin:runAction(action);
	end
end

function UWSoider:attack()
	if self.skinId~=0 and self.action~=3 then
		self.action=3;
		self.skin:stopAllActions();
		local actionName=self.skinData.skinPre.."_attack_";
		self.skin:setSpriteFrame(actionName.."0.png");
		local action=fuGetAnimate(actionName,0,self.skinData.attack,self.skinData.speed);
		action=cc.Sequence:create(action, cc.CallFunc:create(handler(self,self.changStand)));
		self.skin:runAction(action);
	end
end

function UWSoider:changStand()
	if self.isDie then
		if self.soiderLine and self.soiderLine.fightOver then
			self.soiderLine:fightOver(self.col);
		end
		self.isDie=false;
		self:removeFromParent();
	elseif self.isWin then
		self:win();
		self.isWin=false;
	else
		self:stand();
		if self.isMoving then--士兵移动到指定位置
			self.isMoving=false;
			if self.soiderLine and self.soiderLine.soiderArrive then
				self.soiderLine:soiderArrive(self.col);
			end
		end
	end
end

function UWSoider:win()
	if self.skinId~=0 and self.action~=4 then
		self.action=4;
		self.skin:stopAllActions();
		local actionName=self.skinData.skinPre.."_win_";
		self.skin:setSpriteFrame(actionName.."0.png");
		local action=fuGetAnimate(actionName,0,self.skinData.win,self.skinData.speed,true);
		self.skin:runAction(action);
	end
end

function UWSoider:die()
	self.isDie=true;
end

function UWSoider:setIsWin(value)
	self.isWin=value;
end

function UWSoider:onEnter()
	
end

function UWSoider:onExit()
	MGRCManager:releaseResources("UWSoider");
end

return UWSoider;