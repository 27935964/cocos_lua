require "HeroHeadEx";
local InvadeLayer=class("InvadeLayer",function()
	return cc.Layer:create();
end);

function InvadeLayer:ctor(main,data)
	self.main=main;

	local widget=MGRCManager:widgetFromJsonFile("InvadeLayer", "InvadeUi_1.ExportJson");
	self:addChild(widget);

	local panelMask=widget:getChildByName("Panel_mask");--Panel
	local panel_content=widget:getChildByName("Panel_content");--Panel
	local buttonClose=panel_content:getChildByName("Button_close");--Button
	buttonClose:addTouchEventListener(handler(self,self.onCloseClick));
	panelMask:addTouchEventListener(handler(self,self.onCloseClick));

	self.userName=panel_content:getChildByName("Label_Tips_Name");--Label
	self.labelTips=panel_content:getChildByName("Label_Tips");--Label
	self.levelNum=panel_content:getChildByName("Label_Level_num");--Label
	local label_level=panel_content:getChildByName("Label_Level");--Label
	label_level:setText(MG_TEXT_COCOS("InvadeUi_1_5"));
	self.capacityNum=panel_content:getChildByName("Label_Capacity_num");--Label
	local label_capacity=panel_content:getChildByName("Label_Capacity");--Label
	label_capacity:setText(MG_TEXT_COCOS("InvadeUi_1_4"));
	self.listview=panel_content:getChildByName("ListView_Lineup");--ListView
	self.listview:setItemsMargin(12);
	-- self.listview:setBackGroundColorType(1);
	-- self.listview:setBackGroundColor(Color3B.BLUE);

	local image_diamond=panel_content:getChildByName("Image_Diamond");--ImageView
	self.consumediamond=image_diamond:getChildByName("Label_ConsumeDiamond");--Label

	local button_change=panel_content:getChildByName("Button_Change");--Button
	button_change:addTouchEventListener(handler(self,self.onChangeClick));
	local label_Change=button_change:getChildByName("Label_Change");
	label_Change:setText(MG_TEXT_COCOS("InvadeUi_1_2"));

	local button_start=panel_content:getChildByName("Button_Start");--Button
	button_start:addTouchEventListener(handler(self,self.onButton_StartClick));
	local label_Start=button_start:getChildByName("Label_Start");
	label_Start:setText(MG_TEXT_COCOS("InvadeUi_1_3"));

	self.imgHero=panel_content:getChildByName("Image_hero");--ImageView
	self.imgHero:setScale(0.64);
	self.dialgoLayer=nil;

	self:setVisible(false);
	NodeListener(self);

	_G.sceneData.layerData=data;
	self.s_id=data.s_id;
	self.reflashCost=0;
	local str=string.format("&s_id=%d",self.s_id);
	NetHandler:sendData(Post_Invade_getInvadeInfo,str);--玩家事件
end

function InvadeLayer:initData()

	local sql=string.format("select * from config where id=%d",124);--城池入侵刷新对手需求钻石
	local dBData=LUADB.select(sql, "value");

	self.reflashCost=tonumber(dBData.info.value);
	self.consumediamond:setText(tostring(self.reflashCost));

	self.userName:setText(unicode_to_utf8(self.getinvadeinfo.name));
	self.labelTips:setPositionX(self.userName:getPositionX()+self.userName:getContentSize().width+20);
	self.levelNum:setText(tostring(self.getinvadeinfo.lv));
	self.capacityNum:setText(tostring(self.getinvadeinfo.score));
	local localInfo=GeneralData:getGeneralInfo(self.getinvadeinfo.head);
	if localInfo then
		local pic=localInfo:pic()..".png";
		MGRCManager:cacheResource("InvadeLayer", pic);
		self.imgHero:loadTexture(pic,ccui.TextureResType.plistType);
	end
	
	self.listview:removeAllItems();
	local layout,heroHead,gm,str;
	for k, v in pairs(self.getinvadeinfo.corps) do
		gm=GeneralModel:create(tonumber(v.g_id),false);
		str= cjson.encode(v);
		gm:updata(str)
		if gm then
			layout=ccui.Layout:create();
			layout:setSize(cc.size(HeroHeadEx.WIDTH,HeroHeadEx.WIDTH));
			heroHead=HeroHeadEx.create(self,1);
			heroHead:setData(gm,false);
			layout:addChild(heroHead);
			self.listview:pushBackCustomItem(layout);
		end
	end
end

function InvadeLayer:onCloseClick(sender, eventType)
	buttonClickScale(sender, eventType);
	if eventType == ccui.TouchEventType.ended then
		--MGSound:getInstance():play(SOUND_COM_CLICK);
		if self.main then
		        self.main:openInvadeLayer(false);
		end
	end
end

function InvadeLayer:onChangeClick(sender, eventType)
	buttonClickScale(sender, eventType);
	if eventType == ccui.TouchEventType.ended then
		--MGSound:getInstance():play(SOUND_COM_CLICK);
		self:openInvadeDialgo(true,self.reflashCost);
	end
end

--打开入侵事件
function InvadeLayer:openInvadeDialgo(value,reflashCost)
        local curScene=cc.Director:getInstance():getRunningScene();
        if value then
                if self.dialgoLayer==nil then
                    	local InvadeDialgo=require "InvadeDialgo";
                    	self.dialgoLayer=InvadeDialgo.new(self);
                    	curScene:addChild(self.dialgoLayer,ZORDER_MAX);
                end
                self.dialgoLayer:initData(reflashCost);
        else
                if self.dialgoLayer then
                    	self.dialgoLayer:removeFromParent();
                    	self.dialgoLayer=nil;
                end
        end
end

--更换对手
function InvadeLayer:doChange()
	local str=string.format("&s_id=%d",self.s_id);
	NetHandler:sendData(Post_Invade_doChange,str);
end

function InvadeLayer:onButton_StartClick(sender, eventType)
	buttonClickScale(sender, eventType);
	if eventType == ccui.TouchEventType.ended then
		--MGSound:getInstance():play(SOUND_COM_CLICK);
		local teamdata=string.format("&s_id=%d",self.s_id);
		local fightdata=string.format("&s_id=%d",self.s_id);
		FightOP:setTeam(_G.sceneData.sceneType,Fight_Invade,teamdata,fightdata,MG_TEXT("invade_1"));
	end
end

function InvadeLayer:onReciveData(msgId, netData)
          	if msgId==Post_Invade_getInvadeInfo then
          		if netData.state == 1 then
          		    	self:setVisible(true);
          		    	self.getinvadeinfo=netData.getinvadeinfo;
          		    	self:initData();
          		else
          		    	NetHandler:showFailedMessage(netData);
          		end
          	elseif msgId==Post_Invade_doChange then
          		if netData.state == 1 then
          			self.getinvadeinfo=netData.dochange;
          			self:initData();
          			if self.main and self.main.updataMoney then
          				self.main:updataMoney();
          			end
          		else
          		    	NetHandler:showFailedMessage(netData);
          		end
    	end
end

function InvadeLayer:onEnter()
	NetHandler:addAckCode(self,Post_Invade_getInvadeInfo);
	NetHandler:addAckCode(self,Post_Invade_doChange);
end

function InvadeLayer:onExit()
	if self.uiTimer then
		self.uiTimer:stopTimer();
	end

	if self.timer then
		self.timer:stopTimer();
	end
	NetHandler:delAckCode(self,Post_Invade_getInvadeInfo);
	NetHandler:delAckCode(self,Post_Invade_doChange);
	MGRCManager:releaseResources("InvadeLayer");
end


return InvadeLayer;