----事件剧情详细页----
--author:hhh time:2017.10.25

require "trialReport"
local PlotRewardListItem=require "PlotRewardListItem";

local PlotLayer=class("PlotLayer",function()
	return cc.Layer:create();
end);

function PlotLayer:ctor(main)
	self.main=main;
	local widget=MGRCManager:widgetFromJsonFile("PlotLayer", "PlotUi_1.ExportJson");
	self:addChild(widget);

	local panel_mask=widget:getChildByName("Panel_mask");--Panel

	local panel_content=widget:getChildByName("Panel_content");--Panel
	local panel_2=panel_content:getChildByName("Panel_2");--Panel

	self.imgBust=panel_2:getChildByName("Image_bust");
	local button_close=panel_2:getChildByName("Button_close");--Button
	button_close:addTouchEventListener(handler(self,self.onCloseClick));
	panel_mask:addTouchEventListener(handler(self,self.onCloseClick));

	self.tileLabel=panel_2:getChildByName("Label_Title");--Label
	self.rewardList=panel_2:getChildByName("ListView_reward");--ListView
	self.rewardList:setScrollBarVisible(false);--true添加滚动条

	local panel_right=panel_content:getChildByName("Panel_right");--Panel
	local broadcastLabel=panel_right:getChildByName("Label_Broadcast");
	broadcastLabel:setText(MG_TEXT_COCOS("PlotLayerUI_1"));

	self.orderTile=panel_right:getChildByName("Label_Order_number");--Label
	self.tips1Label=panel_right:getChildByName("Label_Tips1");--Label
	self.tips2Label=panel_right:getChildByName("Label_Tips2");--Label
	self.targetLabel=panel_right:getChildByName("Label_Target");--Label

	self.limitLabel=MGColorLabel:label();
	self.limitLabel:setAnchorPoint(cc.p(0,0.5));
	self.limitLabel:setPosition(100,223);
	panel_right:addChild(self.limitLabel);

	local broadcastBtn=panel_right:getChildByName("Button_Broadcast");--Button
	broadcastBtn:addTouchEventListener(handler(self,self.onbroadcastClick));

	self.startBtn=panel_right:getChildByName("Button_Start");--Button
	self.startBtn:addTouchEventListener(handler(self,self.onStartClick));

	NodeListener(self);

	self.data=nil;
	self.timer=CCTimer:new();
	self.uiTimer=CCTimer.new();
end

function PlotLayer:onCloseClick(sender, eventType)
          buttonClickScale(sender, eventType);
          if eventType == ccui.TouchEventType.ended then
                    if self.main then
                            self.main:openPlotLayer(false);
                    end
          end
end

function PlotLayer:onStartClick(sender, eventType)
  	buttonClickScale(sender, eventType);
          if eventType == ccui.TouchEventType.ended then
          	    	_G.sceneData.layerData=self.data;
         		local teamdata = string.format("&p_id=%d&c_id=%d",self.data.p_id,self.curStage);
    	 	local fightdata = string.format("&p_id=%d",self.data.p_id);
          		FightOP:setTeam(_G.sceneData.sceneType,Fight_Plot,teamdata,fightdata,self.data.plotData.name);
          end
end

function PlotLayer:onbroadcastClick(sender, eventType)
	buttonClickScale(sender, eventType);
          if eventType == ccui.TouchEventType.ended then
          	           local str = string.format("&p_id=%d&c_id=%d",self.data.p_id,self.curStage);
                      NetHandler:sendData(Post_Plot_getStrategy, str);--玩家事件
          end
end

function PlotLayer:initData(data)
	self.data=data;
	local sql=string.format("select * from plot_stage where p_id=%d",data.p_id);
	local dbData=LUADB.selectlist(sql, "c_id:reward:g_id:win_des:limit_des:plot");
	if dbData==nil then
		print("PlotLayer:initData error",sql);
		return;
	end

	self.tileLabel:setText(data.plotData.name);--显示标题

	self.leftTime=tonumber(data.end_time)-os.time();--倒记时
	if self.leftTime>0 then
		self.timer:startTimer(1000,handler(self,self.updateTime),false);--每秒回调一次
	else
		self.leftTime=0;
	end
	self.tips2Label:setText(string.format(MG_TEXT("plot_2"),MGDataHelper:secToString(self.leftTime)));

	self.data.plotStage=dbData.info;
	table.sort(self.data.plotStage,function(a,b)
		return a.c_id<b.c_id;
	end);
	self.curStage=1;
	if self.data.is_win==1 then
		self.curStage=self.data.win_c_id;
		self.startBtn:setEnabled(false);
	else
		self.curStage=self.data.win_c_id+1;
		self.startBtn:setEnabled(true);
	end
	self.orderTile:setText(string.format(MG_TEXT("plot_4"),MG_TEXT("NUM_"..self.curStage)));
	
	self:updataData();
	self.uiTimer:startTimer(0,handler(self,self.addRewardItem),false);
end

function PlotLayer:updateTime()
           self.leftTime=self.leftTime-1;
           self.tips2Label:setText(string.format(MG_TEXT("plot_2"),MGDataHelper:secToString(self.leftTime)));
           if self.leftTime==0 then
                 	self.timer:stopTimer();
                 	self:onCloseClick(nil,ccui.TouchEventType.ended);
           end
end

function PlotLayer:updataData()
	local stageData=self.data.plotStage[self.curStage];
	if stageData then
		self.tips1Label:setText(stageData.plot);
		self.targetLabel:setText(string.format(MG_TEXT("plot_3"),stageData.win_des));
		self.limitLabel:appendStringAutoWrap(stageData.limit_des,50,1,Color3B.WHITE,22);

		local info=GeneralData:getGeneralInfo(stageData.g_id);
		if info then
			local pic=info:pic()..".png";
			MGRCManager:cacheResource("PlotLayer",pic);
			self.imgBust:loadTexture(pic,ccui.TextureResType.plistType);
		end
	end
end

function PlotLayer:addRewardItem()
	local i=self.uiTimer.count;
	local plotStageNum=#self.data.plotStage;
	if i>plotStageNum then
		self.uiTimer:stopTimer();
		local index=self.curStage;
		if index>=plotStageNum then
			index=plotStageNum-1;
		end
		self.rewardList:scorllToIndex(index);
	else
		local data=self.data.plotStage[i];
		local rewardItem=PlotRewardListItem.new(self);
		rewardItem:initData(data);

		if self.data.is_win==1 or i<self.curStage then
			rewardItem:showMark(true);
		else
			rewardItem:showMark(false);
		end

		self.rewardList:pushBackCustomItem(rewardItem);
	end
end

function PlotLayer:onReciveData(msgId, netData)
    	if msgId == Post_Plot_getStrategy then
          		if netData.state == 1 then
              		self.getstrategy=netData.getstrategy;
              		local trialReport = trialReport.showBox(self);
              		trialReport:setData(self.getstrategy);
          		else
              		NetHandler:showFailedMessage(netData);
          		end
    	end
end

function PlotLayer:onEnter()
	NetHandler:addAckCode(self,Post_Plot_getStrategy);
end

function PlotLayer:onExit()
	if self.uiTimer then
		self.uiTimer:stopTimer();
	end

	if self.timer then
		self.timer:stopTimer();
	end
	NetHandler:delAckCode(self,Post_Plot_getStrategy);
	MGRCManager:releaseResources("PlotLayer");
end

return PlotLayer;