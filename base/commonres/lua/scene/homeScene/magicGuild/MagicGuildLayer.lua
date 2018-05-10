----魔法行会（许愿池）模块----
--author:hhh time:2017.10.18

local MagicGuildLayer=class("MagicGuildLayer",function()
	return cc.Layer:create();
end);

function MagicGuildLayer:ctor(main)
	self.main=main;
	self.manager=nil;
	MGRCManager:cacheResource("MagicGuildLayer","package_bg.jpg");
	MGRCManager:cacheResource("MagicGuildLayer","MagicGuild_figure.png");
	self.pWidget=MGRCManager:widgetFromJsonFile("MagicGuildLayer", "MagicGuild_ui.ExportJson");
	self:addChild(self.pWidget);

	local panel_mask=self.pWidget:getChildByName("Panel_mask");--Panel
	local panel_content=self.pWidget:getChildByName("Panel_content");--Panel

	self.button_ok=panel_content:getChildByName("Button_ok");--Button
	self.button_ok:addTouchEventListener(handler(self,self.onButton_okClick));

	self.okBtnLabel=self.button_ok:getChildByName("Label_ok");--Label

	self.button_time=panel_content:getChildByName("Button_time");--Button
	self.timeLabel=self.button_time:getChildByName("Label_40");--Label

	local button_close=panel_content:getChildByName("Button_close");--Button
	button_close:addTouchEventListener(handler(self,self.closeBtnClick));
	panel_mask:addTouchEventListener(handler(self,self.closeBtnClick));

	local image_frame=panel_content:getChildByName("Image_frame");
	local label_32=image_frame:getChildByName("Label_32");--Label
	local label_tips=panel_content:getChildByName("Label_tips");--Label

	self.upbox=panel_content:getChildByName("Panel_upBox");--Panel
	self.downbox=panel_content:getChildByName("Panel_downBox");--Panel

	local item;
	self.upItems={};
	for i=1,8 do
		item=resItem.create(self);
		item:setShowTip(false);
		item:setPosition(((i-1)%4)*126+66,(3-math.ceil(i/4))*110-55);
		item.dataIndex=0;
		item.isUp=true;
		self.upbox:addChild(item);
		table.insert(self.upItems,item);	
	end

	self.downItems={};
	for i=1,4 do
		item = resItem.create(self);
		item:setShowTip(false);
		item:setPosition((i-1)*126+66,62);
		item.dataIndex=0;
		item.isUp=false;
		item.itemIndex=i;
		self.downbox:addChild(item);
		table.insert(self.downItems,item);			
	end

	label_tips:setText(MG_TEXT_COCOS("MagicGuild_ui_1"));
           label_32:setText(MG_TEXT_COCOS("MagicGuild_ui_2"));

         	NodeListener(self);

         	self.status=0;
         	self.leftTime=0;
         	self.showIndex=0;
         	self.rewardArr={};
         	self.getpromise=nil;
         	self.timer=CCTimer:new();
         	self.isShowEffect=false;

          NetHandler:sendData(Post_Promise_getPromise, "");--初始化数据
end

function MagicGuildLayer:ItemSelect(item,resItem)

	if self.status~=0 then
		return;
	end

	if resItem.isUp then--点击上面格子
		if resItem.dataIndex~=0 then
			local data=self.itemDataArr[resItem.dataIndex];
			if data then
				local downItem=self:getEmptyDownItem();
				if downItem then
					data.chose=1;
					downItem:setData(data.goods.type,data.goods.id,data.goods.num);
					downItem.dataIndex=resItem.dataIndex;
					downItem:setTouchEnabled(true);

					resItem:setTouchEnabled(false);
					resItem:setEmpty();
					resItem.dataIndex=0;
				else
					MGMessageTip:showFailedMessage(MG_TEXT("magicGuildLayer_3"));
				end
			end
		end
	else--点击下面格子
		if resItem.dataIndex~=0 then
			local data=self.itemDataArr[resItem.dataIndex];
			local upItem=self.upItems[resItem.dataIndex];
			if data and upItem then
				data.chose=0;
				upItem:setData(data.goods.type,data.goods.id,data.goods.num);
				upItem.dataIndex=resItem.dataIndex;
				upItem:setTouchEnabled(true);

				resItem:setTouchEnabled(false);
				resItem:setEmpty();
				resItem.dataIndex=0;

				self:reorderDownItem();
			end
		end
	end
end

function MagicGuildLayer:reorderDownItem()
	local dataIndexArr={};
	for k,v in pairs(self.downItems) do
		if v.dataIndex~=0 then
			table.insert(dataIndexArr,v.dataIndex);
		end
	end

	local dataIndex=0;
	for k,v in pairs(self.downItems) do
		dataIndex=dataIndexArr[k];
		if dataIndex then
			if dataIndex~=v.dataIndex then
				local data=self.itemDataArr[dataIndex];
				if data then
					v:setEmpty();
					v:setData(data.goods.type,data.goods.id,data.goods.num);
					v.dataIndex=dataIndex;
					v:setTouchEnabled(true);
				end
			end
		else
			v:setEmpty();
			v.dataIndex=0;
		end
	end
end

function MagicGuildLayer:getEmptyDownItem()
	local item;
	for k,v in pairs(self.downItems) do
		if v.dataIndex==0 then
			item=v;
			break;
		end
	end
	return item;
end

function MagicGuildLayer:onReciveData(msgId, netData)
    	if msgId == Post_Promise_getPromise then
                    self.pWidget:setVisible(true);
          	if netData.state == 1 then
              		local getpromise=netData.getpromise;
                              self:initData(getpromise);
          	else
              		NetHandler:showFailedMessage(netData);
          	end
          elseif msgId==Post_Promise_doPromise then
                    if netData.state == 1 then
                              local dopromise=netData.dopromise;
                              self:updataData(dopromise);
                    else
                            NetHandler:showFailedMessage(netData);
                    end

                    --test
                    -- NetHandler:sendData(Post_Promise_test, "");--测试使用

          elseif msgId==Post_Promise_getReward then
    		if netData.state==1 then
    			self.getpromise=netData.getpromise;
    			local getreward=netData.getreward;
    			self:showReward(getreward);
    		else
    			NetHandler:showFailedMessage(netData);
    		end
    	end
end

--显示得到的奖励
function MagicGuildLayer:showReward(getreward)
	local mapArr={};
	for k,v in pairs(self.itemDataArr) do
		mapArr[v.id]=v;
	end

	self.rewardArr={};
	local data;
	local get=getreward.get;
	for k,v in pairs(get) do
		data=mapArr[v.id];
		if data then
			table.insert(self.rewardArr,{reward=data.reward,crit=v.crit});--奖励和暴击次数
		end
	end

	if #self.rewardArr>0 then
		self.showIndex=0;
		self.isShowEffect=true;
		self:showAction();
	end
end

function MagicGuildLayer:showAction()
	self.showIndex=self.showIndex+1;
	if self.showIndex>#self.rewardArr then
		self.isShowEffect=false;
		if self.manager then--刷新金币和钻石
		      self.manager:updataMoney();
		end
		self:initData(self.getpromise);
		return;
	end

	function actionCallBack(sender,data)
		if data.item then
			data.item:removeFromParent();
		end

		if data.i==1 then
			self:showAction();
		end
	end

	local data=self.rewardArr[self.showIndex];
	local arr=getneedlist(data.reward);
	local item,downItem;
	if #arr>0 then
		local itemData=arr[1];
		for i=1,data.crit do
			item=resItem.create(self);
			item:setShowTip(false);
			item:setPosition((self.showIndex-1)*126+66,62);
			item:setData(itemData.type,itemData.id,itemData.num);
			self.downbox:addChild(item);

			local dir=-1;
			if i%2==0 then dir=1;end
			dir=dir*i;
			local x=item:getPositionX()+dir*60+math.random()*10;
			if x>500 then
				x=500;
			end

			-- local action=cc.EaseSineInOut:create(cc.JumpTo:create(0.3, cc.p(x,item:getPositionY()), 180, 1));
			local bezierConfig={
			    cc.p(item:getPositionX()+(x-item:getPositionX())*0.25,item:getPositionY()+120),
			    cc.p(item:getPositionX()+(x-item:getPositionX())*0.5,item:getPositionY()+120),
			    cc.p(x,item:getPositionY())
			};
			local action=cc.EaseSineInOut:create(cc.BezierTo:create(0.25, bezierConfig));
			action=cc.Sequence:create(action,cc.DelayTime:create(0.5),cc.CallFunc:create(actionCallBack,{i=i,item=item}));
			item:runAction(action);

			local downItem=self.downItems[self.showIndex];
			if downItem then
				downItem:setEmpty();
			end
		end
	end
end

function MagicGuildLayer:parseData(info)
	local arr;
	for k,v in pairs(info) do
		arr=getneedlist(v.reward);
		v.goods={};
		if #arr>0 then
			v.goods=arr[1];
		end
	end
	return info;
end

function MagicGuildLayer:initData(getpromise)
	self:updataData(getpromise);
	self.itemDataArr=self:parseData(getpromise.info);

	local data;
	local downItemDataArr={};
	for k,v in pairs(self.upItems) do--显示上面格子物品
		v:setEmpty();
		data=self.itemDataArr[k];
		if data then
			if data.chose==0 then
				v:setData(data.goods.type,data.goods.id,data.goods.num);
				v.dataIndex=k;
				v:setTouchEnabled(true);
			else
				table.insert(downItemDataArr,data);
				v.dataIndex=0;
				v:setTouchEnabled(false);
			end
		else
			v.dataIndex=0;
			v:setTouchEnabled(false);	
		end
	end

	for k,v in pairs(self.downItems) do--显示下面格子物品
		v:setEmpty();
		data=downItemDataArr[k];
		if data and data.chose==1 then
			v:setData(data.goods.type,data.goods.id,data.goods.num);
			v.dataIndex=k;
			v:setTouchEnabled(true);
		else
			v:setEmpty();
			v.dataIndex=0;
			v:setTouchEnabled(false);	
		end
	end
end

function MagicGuildLayer:updataData(getpromise)
	self.status=getpromise.status;
	if self.status==0 then--0未许愿
		self.button_ok:setEnabled(true);
		self.button_time:setEnabled(false);
		self.okBtnLabel:setText(MG_TEXT("magicGuildLayer_1"));
	elseif self.status==1 then--1已许愿
		self.leftTime=getpromise.get_reward_sec;
		self.button_ok:setEnabled(false);
		self.button_time:setEnabled(true);
		if self.leftTime>0 then
			self.timeLabel:setText(MGDataHelper:secToString(self.leftTime));
			self.timer:startTimer(1000,handler(self,self.updateTime),false);--每秒回调一次
		end
	elseif self.status==2 then--2可领取
		self.button_ok:setEnabled(true);
		self.button_time:setEnabled(false);
		self.okBtnLabel:setText(MG_TEXT("magicGuildLayer_2"));
	end
end

function MagicGuildLayer:updateTime()
          self.leftTime=self.leftTime-1;
          self.timeLabel:setText(MGDataHelper:secToString(self.leftTime));
          if self.leftTime==0 then
                self.timer:stopTimer();
                self.updateTime({status=2});
          end
end

function MagicGuildLayer:onButton_okClick(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		local downItem=self:getEmptyDownItem();
		if downItem then--下面还有空格子
			if downItem.itemIndex==1 then
				MGMessageTip:showFailedMessage(MG_TEXT("magicGuildLayer_5"));
			else
				MGMessageTip:showFailedMessage(MG_TEXT("magicGuildLayer_4"));
			end
		else
			if self.status==0 then
				local ids = {}
				for k,v in pairs(self.itemDataArr) do
				    	if v.chose==1 then
				        		table.insert(ids,v.id );
				    	end
				end
				if #ids>0 then
				    	local strids=cjson.encode(ids)
				    	local str=string.format("&ids=%s",strids);
				    	NetHandler:sendData(Post_Promise_doPromise,str);--练制
				end
			elseif self.status==2 and self.isShowEffect==false then
				NetHandler:sendData(Post_Promise_getReward,"");--领取物品
			end
		end
	end
end

function MagicGuildLayer:closeBtnClick(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		if self.main then
                            self.main:openMagic(false);
                    end
	end
end

function MagicGuildLayer:onEnter()
	NetHandler:addAckCode(self,Post_Promise_doPromise);
    	NetHandler:addAckCode(self,Post_Promise_getPromise);
    	NetHandler:addAckCode(self,Post_Promise_getReward);
end

function MagicGuildLayer:onExit()
	if self.timer then
	      self.timer:stopTimer();
	      self.timer=nil;
	end

	if self.isShowEffect and self.manager then--刷新金币和钻石
	      self.manager:updataMoney();
	end

	NetHandler:delAckCode(self,Post_Promise_doPromise);
    	NetHandler:delAckCode(self,Post_Promise_getPromise);
    	NetHandler:delAckCode(self,Post_Promise_getReward);
	MGRCManager:releaseResources("MagicGuildLayer");
end

function MagicGuildLayer:setManager(manager)
            self.manager=manager;
end

return MagicGuildLayer;