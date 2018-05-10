----神秘商店----
--author:hhh time:2017.10.19
require "shopInfo1"
require "shopInfo2"

local MysteryStoreLayer=class("MysteryStoreLayer",function()
	return cc.Layer:create();
end);

function MysteryStoreLayer:ctor(main,getusermain)
	self.main=main;
	self.getusermain=getusermain;

	MGRCManager:cacheResource("MysteryStoreLayer","MysteryStoreUi0.png","MysteryStoreUi0.plist");
	MGRCManager:cacheResource("MysteryStoreLayer","MysteryStore_figure.png");
	
	self.pPanelTop=PanelTop.create(self)
	self.pPanelTop:setData("mysteryStore_tile.png");
	self:addChild(self.pPanelTop,2);

	MGRCManager:cacheResource("MagicGuildLayer","package_bg.jpg");
	self.widget=MGRCManager:widgetFromJsonFile("MysteryStoreLayer", "mysteryStoreUi_1.ExportJson");
	self:addChild(self.widget);

	local panel_content=self.widget:getChildByName("Panel_content");--Panel
	
	local label_tips1=panel_content:getChildByName("Label_tips1");--Label
	label_tips1:setText(MG_TEXT_COCOS("mysteryStoreUi_1"));

	self.timeLabel=panel_content:getChildByName("Label_Countdown");--Label

	local label_tips2=panel_content:getChildByName("Label_tips2");--Label
	label_tips2:setText(MG_TEXT_COCOS("mysteryStoreUi_2"));

	self.listView=panel_content:getChildByName("ListView_1");--ListView
	self.listView:setScrollBarVisible(false);--true添加滚动条
	self.listView:setItemsMargin(20);

	if self.shopItemWidget==nil then
		MGRCManager:cacheResource("MysteryStoreLayer","shop_ui0.png","shop_ui0.plist");
	    	self.shopItemWidget=MGRCManager:widgetFromJsonFile("MysteryStoreLayer", "shop_ui_2.ExportJson",true);
	    	self.shopItemWidget:retain();
	end

	self.shopId=getusermain.sterious_shop_id;
	self.timer=CCTimer:new();
	self.leftTime=tonumber(getusermain.sterious_shop_time)-os.time();
	if self.leftTime>0 then
		self.timeLabel:setText(MGDataHelper:secToString(self.leftTime));
		self.timer:startTimer(1000,handler(self,self.updateTime),false);--每秒回调一次
	else
		self:back();
	end
	self.getshopinfo=nil;
	self.treasure=nil;

	self:setVisible(false);

	NodeListener(self);

	local str="&shop="..self.shopId;
	NetHandler:sendData(Post_Shop_getShopInfo, str);
end

function MysteryStoreLayer:onReciveData(msgId, netData)
    	if msgId == Post_Shop_getShopInfo then
          		if netData.state == 1 then
              		self.getshopinfo=netData.getshopinfo;
              		NetHandler:sendData(Post_General_getTreasure, "");
          		else
              		NetHandler:showFailedMessage(netData);
          		end
          	elseif msgId==Post_General_getTreasure then
          		if netData.state==1 then
          			self.treasure=netData.gettreasure.treasure;
          			self:initData();
          		else
          			NetHandler:showFailedMessage(netData);
          		end
           elseif msgId==Post_Shop_buyItem then
                    	if netData.state == 1 then
                              	getItem.showBox(netData.buyitem.get_item);
                              	if self.pPanelTop then
                              		self.pPanelTop:upData();
                              	end
           			self.getshopinfo=netData.getshopinfo;
                              	self:initData();
                    	else
                            	NetHandler:showFailedMessage(netData);
                    	end
    	end
end

function MysteryStoreLayer:updateTime()
           self.leftTime=self.leftTime-1;
           self.timeLabel:setText(MGDataHelper:secToString(self.leftTime));
           if self.leftTime==0 then
                 	self.timer:stopTimer();
                 	self:back();
           end
end

function MysteryStoreLayer:back()
	if self.main and self.main.openMysteryStore then
		self.main:openMysteryStore(false);
	end
end

function MysteryStoreLayer:initData()
	if self.getshopinfo and self.treasure then
		local layout,sItem;
		local items=self.getshopinfo.item;
		local col;
		self.listView:removeAllItems();
		for i=1,#items,4 do
			layout=ccui.Layout:create();
			layout:setSize(cc.size(1000, 248));
			-- layout:setBackGroundColorType(1);
			-- layout:setBackGroundColor(Color3B.BLUE);
			col=0;
			for j=i,i+3 do
				if items[j]==nil then break; end
				sItem=shopItem.create(self,self.shopItemWidget:clone());
				sItem:setData(items[j],self.treasure);
				sItem:setPosition(cc.p(col*258,0));
				layout:addChild(sItem);
				col=col+1;
			end
			self.listView:pushBackCustomItem(layout);
		end
	else
		print("getshopinfo or treasure is nil");
	end
	self:setVisible(true);
end

function MysteryStoreLayer:shopItemSelect(item)
	if item.item[1]==nil then
		print("MysteryStoreLayer:shopItemSelect item error");
	end

	self.spaceId=tonumber(item.info.space_id);
	if item.item[1].value1==11 or item.item[1].value1==12 then--宝物碎片 军械
	        	local shopInfo2 = shopInfo2.showBox(self);
	        	shopInfo2:setData(item.info,item.gmList);
	else
	        	local shopInfo1 = shopInfo1.showBox(self);
	       	shopInfo1:setData(item.info);
	end
end

function MysteryStoreLayer:checkIsFirstBuy(item)
	self.spaceId=tonumber(item.info.space_id);
	local userDefault=cc.UserDefault:getInstance();
	local data=nil;
	local dataKey="mysteryStore";
	local dataStr=userDefault:getStringForKey(dataKey);
	if dataStr==nil or dataStr=="" then--登录后首次购买需要弹框
	    	self:shopItemSelect(item);
	else
		-- data=json.decode(dataStr);
		data=cjson.decode(dataStr);
		if nil==data.isFirst or data.isFirst==true then
		        	self:shopItemSelect(item);
		else
			self:buyItemSendReq();
		end
	end
end

--登录后首次购买需要弹框
function MysteryStoreLayer:setIsFirstBuy()
	local userDefault=cc.UserDefault:getInstance();
	local data=nil;
	local dataKey="mysteryStore";
	local dataStr=userDefault:getStringForKey(dataKey);
	if dataStr==nil or dataStr=="" then--登录后首次购买需要弹框
		data={};
		data.isFirst=false;
		dataStr=cjson.encode(data);
		userDefault:setStringForKey(dataKey,dataStr);
		userDefault:flush();
	else
		-- data=cjson.decode(dataStr);
		data=cjson.decode(dataStr);
		if nil==data.isFirst or data.isFirst==true then
		           data.isFirst=false;
		           dataStr=cjson.encode(data);
		           userDefault:setStringForKey(dataKey,dataStr);
		           userDefault:flush();
		end
	end
end

function MysteryStoreLayer:buyItemSendReq()
	local str=string.format("&shop=%d&space=%d&rtime=%d",self.shopId,self.spaceId,tonumber(self.getshopinfo.reset_time));
	NetHandler:sendData(Post_Shop_buyItem, str);
end

function MysteryStoreLayer:onEnter()
	NetHandler:addAckCode(self,Post_Shop_getShopInfo);
	NetHandler:addAckCode(self,Post_Shop_buyItem);
	NetHandler:addAckCode(self,Post_General_getTreasure);
end

function MysteryStoreLayer:onExit()
	if self.timer then
		self.timer:stopTimer();
		self.timer=nil;
	end

	if self.shopItemWidget then
	    	self.shopItemWidget:release();
	end
	MGRCManager:releaseResources("MysteryStoreLayer");

	NetHandler:delAckCode(self,Post_Shop_getShopInfo);
	NetHandler:delAckCode(self,Post_Shop_buyItem);
	NetHandler:delAckCode(self,Post_General_getTreasure);
end

return MysteryStoreLayer;