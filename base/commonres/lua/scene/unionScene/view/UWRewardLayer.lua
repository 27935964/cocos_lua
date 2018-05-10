----公会战累计奖励----
--author:hhh time:2017.11.9
local UWRewardLayer=class("UWRewardLayer",function()
	return cc.Layer:create();
end);

function UWRewardLayer:ctor()
	self.view=nil;
	MGRCManager:cacheResource("UWRewardLayer","GuildWar_Reward_UI0.png","GuildWar_Reward_UI0.plist");

	local widget=MGRCManager:widgetFromJsonFile("UWRewardLayer", "GuildWar_Ui_CumulativeReward.ExportJson");
	self:addChild(widget);

	local panel_mask=widget:getChildByName("Panel_mask");--Panel

	local panel_content=widget:getChildByName("Panel_content");--Panel
	local button_ok=panel_content:getChildByName("Button_Ok");--Button
	button_ok:addTouchEventListener(handler(self,self.onButton_OkClick));

	local label_ok=button_ok:getChildByName("Label_Ok");--Label
	label_ok:setText(MG_TEXT_COCOS("GuildWar_Ui_CumulativeReward_1"));

	local button_close=panel_content:getChildByName("Button_close");--Button
	button_close:addTouchEventListener(handler(self,self.onButton_closeClick));
	panel_mask:addTouchEventListener(handler(self,self.onButton_closeClick));

	local label_tips=panel_content:getChildByName("Label_Tips");--Label
	label_tips:setText(MG_TEXT_COCOS("GuildWar_Ui_CumulativeReward_2"));

	self.listview=panel_content:getChildByName("listView");--ListView
	self.listview:setItemsMargin(10);
	self.rewardTip=panel_content:getChildByName("Label_rewardTip");
	self.rewardTip:setText(MG_TEXT_COCOS("GuildWar_Ui_CumulativeReward_3"));
end

function UWRewardLayer:initData(initProxy)
	self.listview:removeAllItems();
	local itemArr=getDataList(initProxy.getreward.get_item);
	local count=#itemArr;
	if count>0 then
		self.rewardTip:setVisible(false);
		for i=1,count do
		    	local item = resItem.create(self);
		    	item:setData(itemArr[i].value1,itemArr[i].value2,itemArr[i].value3);
		    	self.listview:pushBackCustomItem(item);
		end
		if count>=4 then
			self.listview:setSize(cc.size(450,110));
			self.listview:setPosition(39,145);
		else
			local width=count*105+(count-1)*10;
			self.listview:setSize(cc.size(width,110));
			self.listview:setPosition(270-width*0.5,145);
		end
	else
		self.rewardTip:setVisible(true);
	end
end

function UWRewardLayer:onButton_OkClick(sender, eventType)
	buttonClickScale(sender,eventType,1);
	if eventType == ccui.TouchEventType.ended then
		--MGSound:getInstance():play(SOUND_COM_CLICK);
		self.view:postNotificationName(UWNN.UWRewardCmd,{action=2});
	end
end

function UWRewardLayer:onButton_closeClick(sender, eventType)
	buttonClickScale(sender,eventType,1);
	if eventType == ccui.TouchEventType.ended then
		--MGSound:getInstance():play(SOUND_COM_CLICK);
		self.view:postNotificationName(UWNN.UWRewardCmd,{action=2});
	end
end

function UWRewardLayer:onEnter()
	
end

function UWRewardLayer:onExit()
	MGRCManager:releaseResources("UWRewardLayer");
end

function UWRewardLayer:setView(view)
	self.view=view;
end

return UWRewardLayer;