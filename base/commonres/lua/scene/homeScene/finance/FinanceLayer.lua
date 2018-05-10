----财政厅模块----
--author:hhh time:2017.10.17

require "ResourceTip";

local FinanceLayer=class("FinanceLayer",function ()
	return cc.Layer:create();
end);

function FinanceLayer:ctor(main)
          self.main=main;
          MGRCManager:cacheResource("FinanceLayer","finance_bg.jpg");
          self.pWidget = MGRCManager:widgetFromJsonFile("FinanceLayer","finance_ui.ExportJson");
          self:addChild(self.pWidget);
          self.pWidget:setVisible(false);

          local panel1=self.pWidget:getChildByName("Panel_1");
          local panel2=self.pWidget:getChildByName("Panel_2");
          self.closeBtn=panel2:getChildByName("Button_close");
          self.closeBtn:addTouchEventListener(handler(self,self.onCloseClick));
          panel1:addTouchEventListener(handler(self,self.onCloseClick));
          
          self.btnGet=panel2:getChildByName("Button_levy");
          self.btnGet:addTouchEventListener(handler(self,self.onGetClick));
          self.coinNum=self.btnGet:getChildByName("Label_number");

          self.buyInfoPanel=panel2:getChildByName("Panel_buy_info");
          local label1=self.buyInfoPanel:getChildByName("Label_1");
          local label2=self.buyInfoPanel:getChildByName("Label_2");
          self.buyCount=self.buyInfoPanel:getChildByName("Label_3");
          self.buyCost=self.buyInfoPanel:getChildByName("Label_4");
          
          self.freePanle=panel2:getChildByName("Panel_free");
          local label5=self.freePanle:getChildByName("Label_5");
          self.freeNum=self.freePanle:getChildByName("Label_6");

          local tipsLabel1=panel2:getChildByName("Label_tips1");
          local tipsLabel2=panel2:getChildByName("Label_tips2");
          local tipsLabel3=panel2:getChildByName("Label_tips3");
          local tipsLabel4=panel2:getChildByName("Label_tips4");

          self.imgCrit=panel2:getChildByName("Image_crit");
          self.critLabel=cc.Label:createWithCharMap("finance_number_font.png",30,28,48);
          self.critLabel:setAnchorPoint(cc.p(0.5,0.5));
          self.critLabel:setString(tostring(1));
          self.critLabel:setPosition(cc.p(70,30));
          self.imgCrit:addChild(self.critLabel);

          label1:setText(MG_TEXT_COCOS("finance_ui_5"));
          label2:setText(MG_TEXT_COCOS("finance_ui_6"));
          label5:setText(MG_TEXT_COCOS("finance_ui_7"));
          tipsLabel1:setText(MG_TEXT_COCOS("finance_ui_1"));
          tipsLabel2:setText(MG_TEXT_COCOS("finance_ui_3"));
          tipsLabel3:setText(MG_TEXT_COCOS("finance_ui_2"));
          tipsLabel4:setText(MG_TEXT_COCOS("finance_ui_4"));

          self.canBuy=true;

	     NodeListener(self);

          NetHandler:sendData(Post_Finance_financeInfo, "");--初始化数据
end

function FinanceLayer:onCloseClick(sender, eventType)
          if eventType == ccui.TouchEventType.ended then
                    if self.main then
                            self.main:openFinance(false);
                    end
          end
end

function FinanceLayer:onGetClick(sender, eventType)
          buttonClickScale(sender,eventType,1)
          if eventType == ccui.TouchEventType.ended then
                    if self.canBuy then
                            ResourceTip.getInstance():init();
                            NetHandler:sendData(Post_Finance_doFinance, "");
                    else
                            MGMessageTip:showFailedMessage(MG_TEXT("financeLayer_1"));
                    end
          end
end

function FinanceLayer:onReciveData(msgId, netData)
    	     if msgId == Post_Finance_financeInfo then
                    self.pWidget:setVisible(true);
          		if netData.state == 1 then
              		       local financeinfo=netData.financeinfo;
                              self:initData(financeinfo);
          		else
              		        NetHandler:showFailedMessage(netData);
          		end
          elseif msgId==Post_Finance_doFinance then
                    if netData.state == 1 then
                              local financeinfo=netData.financeinfo;
                              local dofinance=netData.dofinance;
                              self:updataData(financeinfo);
                              self:showCritEffect(tonumber(dofinance.crit));
                              if self.manager then--刷新金币和钻石
                                    self.manager:updataMoney();
                              end
                              ResourceTip.getInstance():show();
                    else
                            NetHandler:showFailedMessage(netData);
                    end
    	   end
end

function FinanceLayer:initData(financeinfo)
          self:updataData(financeinfo);
          self:showCritEffect(0);
end

function FinanceLayer:updataData(financeinfo)
           self.canBuy=true;
           self.coinNum:setText(tostring(financeinfo.get_coin));
           if financeinfo.s_num>0 then--有免费次数
                 self.freePanle:setVisible(true);
                 self.buyInfoPanel:setVisible(false);
                 self.freeNum:setText(tostring(financeinfo.s_num));
           else
                 self.buyInfoPanel:setVisible(true);
                 self.freePanle:setVisible(false);
                 self.buyCost:setText(tostring(financeinfo.use_gold));
                 self.buyCount:setText(tostring(financeinfo.buy_num));
                 if financeinfo.buy_num<=0 then
                        self.canBuy=false;
                 end
           end
end

function FinanceLayer:showCritEffect(crit)
            if crit<=1 then
                    self.imgCrit:setVisible(false);
            else
                    self.imgCrit:setVisible(true);
                    self.critLabel:setString(tostring(crit));

                    self.imgCrit:stopAllActions();
                    self.imgCrit:setScale(3);
                    local scaleTo1=cc.EaseBackOut:create(cc.ScaleTo:create(0.15, 1.0, 1.0));
                    local delayTime=cc.DelayTime:create(1.5);
                    local seqAction=cc.Sequence:create(scaleTo1,delayTime,cc.CallFunc:create(function()
                        self.imgCrit:setVisible(false);
                    end));
                    self.imgCrit:runAction(seqAction);
            end
end

function FinanceLayer:setManager(manager)
            self.manager=manager;
end

function FinanceLayer:onEnter()
	NetHandler:addAckCode(self,Post_Finance_financeInfo);
    	NetHandler:addAckCode(self,Post_Finance_doFinance);
end

function FinanceLayer:onExit()
	NetHandler:delAckCode(self,Post_Finance_financeInfo);
    	NetHandler:delAckCode(self,Post_Finance_doFinance);
     MGRCManager:releaseResources("FinanceLayer");
end

return FinanceLayer;