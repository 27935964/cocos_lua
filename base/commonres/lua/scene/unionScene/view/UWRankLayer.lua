----公会战排行----
--author:hhh time:2017.11.9

local UWRankListItem=require "UWRankListItem";
local UWRankLayer=class("UWRankLayer",function()
	return cc.Layer:create();
end);

function UWRankLayer:ctor()
	self.view=nil;

	MGRCManager:cacheResource("UWRankLayer","GuildWar_Rank_UI0.png","GuildWar_Rank_UI0.plist");

	local widget=MGRCManager:widgetFromJsonFile("UWRankLayer", "GuildWar_Ui_Rank.ExportJson");
	self:addChild(widget);

	local panel_mask=widget:getChildByName("Panel_mask");--Panel

	local panel_content=widget:getChildByName("Panel_content");--Panel
	local button_close=panel_content:getChildByName("Button_close");--Button
	button_close:addTouchEventListener(handler(self,self.onButton_closeClick));
	panel_mask:addTouchEventListener(handler(self,self.onButton_closeClick));

	local image_outfit=panel_content:getChildByName("Image_Outfit");--ImageView
	self.listview=panel_content:getChildByName("ListView");--ListView

	local cSize=panel_content:getSize();
	local ttfConfig={};
	ttfConfig.fontFilePath=ttf_msyh;
	ttfConfig.fontSize=24;
	self.nothingLabel=cc.Label:createWithTTF(ttfConfig,MG_TEXT_COCOS("GuildWar_Ui_Rank_1"), cc.VERTICAL_TEXT_ALIGNMENT_CENTER);
	self.nothingLabel:setTextColor(cc.c4b(128, 128, 128,255));
	self.nothingLabel:setAnchorPoint(cc.p(0.5, 0.5));
	self.nothingLabel:setPosition(cc.p(cSize.width*0.5,cSize.height*0.5));
	panel_content:addChild(self.nothingLabel);
	self.nothingLabel:setVisible(false);
end

function UWRankLayer:initData(initProxy)
	local kill_rank=initProxy.getkillrank.kill_rank;
	if #kill_rank>0 then
		local item;
		for k,v in pairs(kill_rank) do
			item=UWRankListItem.new();
			item:initData(v,k);
			self.listview:pushBackCustomItem(item);
		end
		self.nothingLabel:setVisible(false);
	else
		self.nothingLabel:setVisible(true);
	end
end

function UWRankLayer:onButton_closeClick(sender, eventType)
	buttonClickScale(sender,eventType,1);
	if eventType == ccui.TouchEventType.ended then
		--MGSound:getInstance():play(SOUND_COM_CLICK);
		self.view:postNotificationName(UWNN.UWRankCmd,{action=2});
	end
end

function UWRankLayer:onEnter()
	
end

function UWRankLayer:onExit()
	MGRCManager:releaseResources("UWRankLayer");
end

function UWRankLayer:setView(view)
	self.view=view;
end

return UWRankLayer;