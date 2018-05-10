----玩家升级界面----
--author:hhh time:2017.10.21

local LevelUpLayer=class("LevelUpLayer",function()
	return cc.Layer:create();
end);


function LevelUpLayer:ctor()
	MGRCManager:cacheResource("LevelUpLayer","LevelupEffect2.png","LevelupEffect2.plist");
	MGRCManager:cacheResource("LevelUpLayer","leveup_img_bg.png");
	local widget= MGRCManager:widgetFromJsonFile("LevelUpLayer","LevelupUi_1.ExportJson");
	self:addChild(widget);

	local panel_mask=widget:getChildByName("Panel_mask");--Panel
	panel_mask:addTouchEventListener(handler(self,self.onCloseClick));

	self.panelContent=widget:getChildByName("Panel_content");--Panel

	self.imgBg1=self.panelContent:getChildByName("Image_bg1");

	self.item1=self.panelContent:getChildByName("Image_Level");--ImageView
	local label_level=self.item1:getChildByName("Label_level");--Label
	label_level:setText(MG_TEXT_COCOS("LevelupUi_1"));
	self.labelLevel1=self.item1:getChildByName("Label_Level_number");--Label
	self.labelLevel2=self.item1:getChildByName("Label_Level_number_0");--Label
	self.item1:setVisible(false);

	self.item2=self.panelContent:getChildByName("Image_UpperLimit");--ImageView
	local label_upperlimit=self.item2:getChildByName("Label_UpperLimit");--Label
	label_upperlimit:setText(MG_TEXT_COCOS("LevelupUi_2"));
	self.labelLimit1=self.item2:getChildByName("Label_Limit_number");--Label
	self.labelLimit2=self.item2:getChildByName("Label_Limit_number_0");--Label
	self.item2:setVisible(false);

	self.item3=self.panelContent:getChildByName("Image_Action");--ImageView
	local label_action=self.item3:getChildByName("Label_Action");--Label
	label_action:setText(MG_TEXT_COCOS("LevelupUi_2"));
	self.addActionLabel=self.item3:getChildByName("Label_Action_number");--Label
	self.item3:setVisible(false);

	self.listView=self.panelContent:getChildByName("ListViewNew");--ListView
	self.newTile=self.panelContent:getChildByName("Panel_newTile");

	self.tileEffect=nil;
	self.openArr={};
	NodeListener(self);
end

function LevelUpLayer:onCloseClick(sender, eventType)
          if eventType == ccui.TouchEventType.ended then
          		local mainOpenArr={};
          		local menuOpenArr={};
                    	for k,v in pairs(self.openArr) do
                    		local data=v.data;
                    		if data and data.area_id>0 then
                    			if data.area_id==5 then--开放主城建筑
                    				table.insert(mainOpenArr,{data=data,pos=v:getWorldPosition()});
                    			else--开放菜单
                    				table.insert(menuOpenArr,{data=data,pos=v:getWorldPosition()});
                    			end
                    		end
                    	end

                    	if _G.mainLayer and _G.mainLayer.openFunc then
                    		_G.mainLayer:openFunc(menuOpenArr,mainOpenArr);
                    	end
                    	
                     	openLevelUp(false);
          end
end

function LevelUpLayer:playEffect2()
	if self.tileEffect then
		self.tileEffect:setSpriteFrame("levelup_6.png");
		local action=fuGetAnimate("levelup_",6,10,0.166);
		local forverAction=cc.RepeatForever:create(action);
		self.tileEffect:runAction(forverAction);
	end
end

function LevelUpLayer:fadeInChilds(item,time)
	local childs=item:getChildren();
	for k,v in pairs(childs) do
		v:setOpacity(0);
		v:runAction(cc.Sequence:create(cc.DelayTime:create(time),cc.FadeIn:create(0.2)));
	end
end

function LevelUpLayer:initData(oldLv,newLv,newExp)
	local action,seqAction;
	if self.tileEffect1==nil then
		self.tileEffect=cc.Sprite:createWithSpriteFrameName("levelup_0.png");
		self.tileEffect:setPositionY(190);
		action=fuGetAnimate("levelup_",0,5,0.12);
		seqAction=cc.Sequence:create(action,cc.CallFunc:create(handler(self,self.playEffect2)));
		self.tileEffect:runAction(seqAction);
		self.panelContent:addChild(self.tileEffect);
	end

	local item,x,y,time;
	for i=1,3 do
		item=self["item"..i];
		if item then
			x,y=item:getPosition();
			item:setVisible(true);
			item:setOpacity(0);
			item:setPosition(cc.p(x,y-50));
			action=cc.EaseOut:create(cc.MoveTo:create(0.2,cc.p(x,y)),4);
			action=cc.Spawn:create(action,cc.FadeIn:create(0.2));
			time=0.8+i*0.15;
			item:runAction(cc.Sequence:create(cc.DelayTime:create(time),action));
			self:fadeInChilds(item,time);
		end
	end

	local sql=string.format("select * from user_lv where lv=%d",oldLv);
	local oldDBData=LUADB.select(sql, "max_action");
	sql=string.format("select * from user_lv where lv=%d",newLv);
	local newDBData=LUADB.select(sql, "max_action:get_action:open_func");

	self.labelLevel1:setText(tostring(oldLv));
	self.labelLevel2:setText(tostring(newLv));
	self.labelLimit1:setText(tostring(oldDBData.info.max_action));
	self.labelLimit2:setText(tostring(newDBData.info.max_action));
	self.addActionLabel:setText(string.format("+%d",newDBData.info.get_action));
	local openFunc=newDBData.info.open_func;
	local dbData;
	local LUOpenIcon=require "LUOpenIcon";

	local bgSize=self.imgBg1:getSize();
	if openFunc and openFunc~="" then
		local idArr=string.split(openFunc,":");
		for k,v in pairs(idArr) do
			dbData=self:getFunctionDB(v);
			if dbData then
				item=LUOpenIcon.new();
				item:initData(dbData);
				self.listView:pushBackCustomItem(item);
				self:fadeInChilds(item,1.7);
				table.insert(self.openArr,item);
			end
		end
		
		local width=#idArr*100;
		self.listView:setVisible(true);
		self.newTile:setVisible(true);
		self.listView:setSize(cc.size(width,85));
		self.listView:setPositionX((self.panelContent:getSize().width-width)*0.5);
		bgSize.height=432;

		self:fadeInChilds(self.newTile,1.1);
	else
		self.listView:setVisible(false);
		self.newTile:setVisible(false);
		bgSize.height=332;
	end

	self.imgBg1:setSize(bgSize);

	NodeShow(self.panelContent);
end

function LevelUpLayer:getFunctionDB(id)
	local data=nil;
	local sql=string.format("select * from function where id=%d",tonumber(id));
	local dbData=LUADB.select(sql, "id:lvup_pic:area_id:pos");
	if dbData then
		data={};
		data.id=tonumber(dbData.info.id);
		print("LevelUpLayer:getFunctionDB",data.id);
		data.lvup_pic=dbData.info.lvup_pic..".png";
		data.area_id=tonumber(dbData.info.area_id);
		data.pos=dbData.info.pos;
	end
	return data;
end

function LevelUpLayer:onEnter()
	
end

function LevelUpLayer:onExit()
	MGRCManager:releaseResources("LevelUpLayer");
end

local levelUpLayer=nil;
function openLevelUp(value,oldLv,newLv,newExp)
	if value then
		openLevelUp(false);
		levelUpLayer=LevelUpLayer.new();
		levelUpLayer:initData(oldLv,newLv,newExp);

		local curScene=cc.Director:getInstance():getRunningScene();
		curScene:addChild(levelUpLayer,ZORDER_MAX);
	else
		if levelUpLayer then
			levelUpLayer:removeFromParent();
			levelUpLayer=nil;
		end
	end
end