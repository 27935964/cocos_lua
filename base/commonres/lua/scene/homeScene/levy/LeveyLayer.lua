----国会大楼模块----
--author:hhh time:2017.10.18

require "ResourceTip";

local LeveyLayer=class("LeveyLayer",function ()
	return cc.Layer:create();
end);

function LeveyLayer:ctor(main)
          self.main=main;
          MGRCManager:cacheResource("LeveyLayer","bg_ParliamentHouse.jpg");
          self.pWidget = MGRCManager:widgetFromJsonFile("LeveyLayer","levey_ui.ExportJson");
          self:addChild(self.pWidget);
          self.pWidget:setVisible(false);

          local panel1=self.pWidget:getChildByName("Panel_mask");
          local panel2=self.pWidget:getChildByName("Panel_content");
          self.closeBtn=panel2:getChildByName("Button_close");
          self.closeBtn:addTouchEventListener(handler(self,self.onCloseClick));
          panel1:addTouchEventListener(handler(self,self.onCloseClick));
          
          self.btnGet=panel2:getChildByName("Button_levy");
          self.btnGet:addTouchEventListener(handler(self,self.onGetClick));

          self.labelOutput=panel2:getChildByName("Label_output");
          self.labelleft=panel2:getChildByName("Label_surplus");
          
          local tipsLabel1=panel2:getChildByName("Label_unit");
          local tipsLabel2=panel2:getChildByName("Labe_tips");
     
          tipsLabel1:setText(MG_TEXT_COCOS("levey_ui_1"));
          tipsLabel2:setText(MG_TEXT_COCOS("levey_ui_2"));

          self.canGet=true;
          self.nextTime=0;
          self.timer=CCTimer:new();

	     NodeListener(self);

          NetHandler:sendData(Post_Levy_levyInfo, "");--初始化数据
end

function LeveyLayer:onCloseClick(sender, eventType)
          if eventType == ccui.TouchEventType.ended then
                    if self.main then
                            self.main:openLevey(false);
                    end
          end
end

function LeveyLayer:onGetClick(sender, eventType)
          buttonClickScale(sender,eventType,1)
          if eventType == ccui.TouchEventType.ended then
                    if self.canGet then
                            NetHandler:sendData(Post_Levy_doLevy, "");
                    else
                            MGMessageTip:showFailedMessage(string.format(MG_TEXT("leveyLayer_2"),math.ceil(self.nextTime/60)));
                    end
          end
end

function LeveyLayer:onReciveData(msgId, netData)
    	     if msgId == Post_Levy_levyInfo then
                    self.pWidget:setVisible(true);
          		if netData.state == 1 then
              		          local leveyInfo=netData.levyinfo;
                              self:initData(leveyInfo);
          		else
              		          NetHandler:showFailedMessage(netData);
          		end
          elseif msgId==Post_Levy_doLevy then
                    if netData.state == 1 then
                              local dolevy=netData.dolevy;
                              local leveyInfo=netData.levyinfo;
                              self:updataData(leveyInfo);
                              if self.manager then--刷新金币和钻石
                                    self.manager:updataMoney();
                              end
                              getItem.showBox(dolevy.get_item);
                              ResourceTip.getInstance():showData(dolevy.get_item);
                    else
                            NetHandler:showFailedMessage(netData);
                    end
    	   end
end

function LeveyLayer:initData(leveyInfo)
          self:updataData(leveyInfo);
end

function LeveyLayer:updataData(leveyInfo)
           self.canGet=true;
           self.nextTime=leveyInfo.levy_time-os.time();
           self.labelOutput:setText(tostring(leveyInfo.get_coin_num ));
           self.labelleft:setText(string.format(MG_TEXT("leveyLayer_1"),tonumber(leveyInfo.levy)));
           if tonumber(leveyInfo.levy)<=0 then--没有领取次数
                    self.canGet=false;
                    if self.nextTime>0 then
                          self.timer:startTimer(500,handler(self,self.updateTime),false);--每秒回调一次
                    end
           end
end

function LeveyLayer:updateTime()
          self.nextTime=self.nextTime-1;
          if self.nextTime==0 then
                self.timer:stopTimer();
                NetHandler:sendData(Post_Levy_levyInfo, "");--初始化数据
          end
end

function LeveyLayer:setManager(manager)
          self.manager=manager;
end

function LeveyLayer:onEnter()
	     NetHandler:addAckCode(self,Post_Levy_levyInfo);
    	     NetHandler:addAckCode(self,Post_Levy_doLevy);
end

function LeveyLayer:onExit()
          if self.timer then
                self.timer:stopTimer();
                self.timer=nil;
          end
	     NetHandler:delAckCode(self,Post_Levy_levyInfo);
    	     NetHandler:delAckCode(self,Post_Levy_doLevy);
          MGRCManager:releaseResources("LeveyLayer");
end

return LeveyLayer;