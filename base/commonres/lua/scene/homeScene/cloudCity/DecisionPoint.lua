----云中城决策点界面----
-- require "ItemJump";
local DecisionPoint=class("DecisionPoint",function()
	return cc.Layer:create();
end);

function DecisionPoint:ctor(delegate)
  	self.delegate=delegate;
  	self.diceContent=delegate.diceContent;
    self.scaleVal=0;
    self.clickType=0; --0上面/1下面
    -- 
  	self.pWidget=MGRCManager:widgetFromJsonFile("DecisionPoint", "CloudCity_DesicionPoint_Ui.ExportJson");
  	self:addChild(self.pWidget);

  	local panel_2=self.pWidget:getChildByName("Panel_2");--Panel
    self.panel_3=self.pWidget:getChildByName("Panel_3");
    self:setNoCanClick(false);
    -- 
    self.panel_choice1=panel_2:getChildByName("Panel_Choice1");
    self.panel_choice1:addTouchEventListener(handler(self,self.choiceBtnClick));
    self.label_choice1=self.panel_choice1:getChildByName("Label_Choice1");
    self.label_fatigueNum=self.panel_choice1:getChildByName("Label_Fatigue_number");
    self.list=self.panel_choice1:getChildByName("ListView_Reward1");
    -- 
    self.panel_choice1_0=panel_2:getChildByName("Panel_Choice1_0");
    self.panel_choice1_0:addTouchEventListener(handler(self,self.choiceBtnClick));
    self.label_choice1_0=self.panel_choice1_0:getChildByName("Label_Choice1");
    self.label_fatigueNum_0=self.panel_choice1_0:getChildByName("Label_Fatigue_number");
    self.list_0=self.panel_choice1_0:getChildByName("ListView_Reward1");
    -- 疲劳度
    self.progressBar=panel_2:getChildByName("ProgressBar_16");
    self.label_progress=panel_2:getChildByName("Label_Progress");
    -- 
    self.selspr=ccui.ImageView:create("com_selected_box.png", ccui.TextureResType.plistType);
    self.selspr:setScale9Enabled(true);
    self.selspr:setCapInsets(cc.rect(50, 50, 10, 10));
    self.selspr:setSize(cc.size(self.panel_choice1:getContentSize().width,self.panel_choice1:getContentSize().height));
    panel_2:addChild(self.selspr);
    self.selspr:setVisible(false);
    -- tips
    self.img_bubble=panel_2:getChildByName("Image_Bubble");
    -- 图片
    self.img_angel=panel_2:getChildByName("Image_Angel");
    -- 名称 
    self.img_name=panel_2:getChildByName("Image_23");
    -- 星级
    self.panel_24=panel_2:getChildByName("Panel_24");
    -- 
    local label_fatigue=panel_2:getChildByName("Label_Fatigue");
    label_fatigue:setText(MG_TEXT_COCOS("DecisionPoint_Ui_1"));

    local label_reward1=panel_2:getChildByName("Label_Reward1");
    label_reward1:setText(MG_TEXT_COCOS("DecisionPoint_Ui_2"));
    -- 
 	NodeListener(self);
    -- 
    self:initData();
    --
    -- 
    -- local Panel_1 = self.pWidget:getChildByName("Panel_1")
    -- local function closeClick(sender,eventType)
    --     if eventType == ccui.TouchEventType.ended then
    --         self:removeFromParentAndCleanup(true);
    --     end
    -- end
    -- Panel_1:addTouchEventListener(closeClick)
end

function DecisionPoint:setNoCanClick(isVisible)
    self.panel_3:setTouchEnabled(isVisible);
end

function DecisionPoint:initData()
    if self.delegate then
        self.delegate:showAngelInfo(self.img_bubble,self.img_angel,self.img_name,self.panel_24,false);
    end
    self:refreshDecision();
end

function DecisionPoint:refreshDecision()
    -- 格式2|5|0
    -- 决策点题目ID|决策点题目ID|疲劳度
    local str_list=spliteStr(self.diceContent,'|');
    local decisionId_1=tonumber(str_list[1]);
    local decisionId_2=tonumber(str_list[2]);
    self.panel_choice1:setTag(decisionId_1);
    self.panel_choice1_0:setTag(decisionId_2);

    local colorTmp1=cc.c3b(255,210,0);
    local colorTmp2=cc.c3b(0,218,15);

    local DBData1=LUADB.select(string.format("select * from cloud_decision where id=%d",decisionId_1), "des:tire:reward");
    self.label_choice1:setText(DBData1.info.des);
    local colorVal1=colorTmp1;
    local tireStr1=string.format("+%d",DBData1.info.tire);
    if tonumber(DBData1.info.tire)<0 then
        colorVal1=colorTmp2;
        tireStr1=string.format("%d",DBData1.info.tire);
    end
    self.label_fatigueNum:setText(tireStr1);
    self.label_fatigueNum:setColor(colorVal1);
    local resData=ResourceTip.getInstance():getResData(DBData1.info.reward);
    self.list:removeAllItems();
    local itemLay = ccui.Layout:create();
    itemLay:setSize(cc.size(self.list:getContentSize().width, self.list:getContentSize().height));
    local item=resItem.create();
    item:setData(resData.type,resData.id,0);
    item:setNum(resData.num);
    itemLay:addChild(item);
    self.scaleVal=itemLay:getContentSize().height/item:getContentSize().height;
    item:setScale(self.scaleVal);
    item:setPosition(item:getContentSize().width/2*self.scaleVal,self.list:getContentSize().height/2);
    self.list:pushBackCustomItem(itemLay);

    local DBData2=LUADB.select(string.format("select * from cloud_decision where id=%d",decisionId_2), "des:tire:reward");
    self.label_choice1_0:setText(DBData2.info.des);
    local colorVal2=colorTmp1;
    local tireStr2=string.format("+%d",DBData2.info.tire);
    if tonumber(DBData2.info.tire)<0 then
        colorVal2=colorTmp2;
        tireStr2=string.format("%d",DBData2.info.tire);
    end
    self.label_fatigueNum_0:setText(tireStr2);
    self.label_fatigueNum_0:setColor(colorVal2);
    local resData2=ResourceTip.getInstance():getResData(DBData2.info.reward);
    self.list_0:removeAllItems();
    local itemLay2 = ccui.Layout:create();
    itemLay2:setSize(cc.size(self.list_0:getContentSize().width, self.list_0:getContentSize().height));
    local item2=resItem.create();
    item2:setData(resData2.type,resData2.id,0);
    item2:setNum(resData2.num);
    itemLay2:addChild(item2);
    item2:setScale(self.scaleVal);
    item2:setPosition(item2:getContentSize().width/2*self.scaleVal,self.list_0:getContentSize().height/2);
    self.list_0:pushBackCustomItem(itemLay2);
    -- 
    local curVal=tonumber(str_list[3]);
    self:setProgressBar(curVal);
end

function DecisionPoint:setProgressBar(curVal)

    local maxVal=100;
    if maxVal<=0 then
        maxVal=1;
    end
    self.progressBar:setPercent(tonumber(curVal)*100/tonumber(maxVal));
    self.label_progress:setText(string.format("%d/%d",curVal,maxVal));
end

function DecisionPoint:onReciveData(msgId, netData)
	  if msgId == Post_Cloud_Main_doDecision then
      	if netData.state == 1 then
            local dodecision=netData.dodecision;
            self.diceContent=dodecision.content;
            -- 
            local reward=dodecision.reward;
            local itemLay=self.list:getItem(0);
            if self.clickType==1 then
                itemLay=self.list_0:getItem(0);
            end
            local itemPos={};
            for k,v in pairs(itemLay:getChildren()) do
                local point=v:convertToWorldSpace(cc.p(v:getPositionX()+v:getContentSize().width/2*(1-self.scaleVal),
                    v:getPositionY()+v:getContentSize().height/2*(1-self.scaleVal)));
                local pos=cc.p(point.x,point.y);
                table.insert(itemPos,pos);
            end
            ItemJump:getInstance():showItemJump(reward,self.pWidget,itemPos,self.scaleVal,true); 
            -- 
            local coin=dodecision.get_coin;
            local stone=dodecision.get_stone;
            if self.delegate then
                self.delegate:changeTopInfo(coin,stone);
            end
            -- 
            self.selspr:setVisible(false);
            if string.len(self.diceContent)>0 then
                self.panel_choice1:stopAllActions();
                self.panel_choice1_0:stopAllActions();
                local timeVal=0.2;
                local timeVal2=1.5;
                local moveX=580;
                for i=1,2 do
                    local delay=cc.DelayTime:create(timeVal2);
                    local moveBy=cc.MoveBy:create(timeVal, cc.p(moveX, 0));
                    local fadeout=cc.FadeOut:create(timeVal);
                    local spawn=cc.Spawn:create(moveBy,fadeout);
                    local moveBy2=cc.MoveBy:create(timeVal, cc.p(-moveX, 0));
                    local fadeout2=cc.FadeOut:create(timeVal);
                    local spawn2=cc.Spawn:create(moveBy2,fadeout2);
                    local seq=cc.Sequence:create(delay,spawn,spawn2);
                    if i==1 then
                        self.panel_choice1:runAction(seq);
                    elseif i==2 then
                        self.panel_choice1_0:runAction(seq);
                    end
                end
                local function delayDeal()
                    self:refreshDecision();
                    self:setNoCanClick(false);
                end
                local delay=cc.DelayTime:create(timeVal*2+timeVal2);
                local callFunc=cc.CallFunc:create(delayDeal);
                self:runAction(cc.Sequence:create(delay,callFunc));
            else
                self:setProgressBar(100);
                self:setNoCanClick(true);
                -- 延迟关闭
                local function delayClose()
                    self:closeDecision();
                end
                local delay=cc.DelayTime:create(2.5);
                local callFunc=cc.CallFunc:create(delayClose);
                self:runAction(cc.Sequence:create(delay,callFunc));
            end
      	else
          	NetHandler:showFailedMessage(netData);
      	end
  	end
end

function DecisionPoint:choiceBtnClick(sender, eventType)
  	if eventType == ccui.TouchEventType.ended then
        self.selspr:setVisible(true);
        self.selspr:setPosition(cc.p(sender:getPositionX()+sender:getContentSize().width/2, sender:getPositionY()+sender:getContentSize().height/2));

        if sender==self.panel_choice1_0 then
            self.clickType=1;
        elseif sender==self.panel_choice1 then
            self.clickType=0;
        end
        -- 
        local str=string.format("&id=%d",sender:getTag());
        NetHandler:sendData(Post_Cloud_Main_doDecision, str);
        self:setNoCanClick(true);
  	end
end

function DecisionPoint:closeDecision()
    if self.delegate then
        self.delegate:closeOpenLayer();
    end
end

function DecisionPoint:onEnter()
  	NetHandler:addAckCode(self,Post_Cloud_Main_doDecision);
end

function DecisionPoint:onExit()
  	NetHandler:delAckCode(self,Post_Cloud_Main_doDecision);
  	MGRCManager:releaseResources("DecisionPoint");
end

return DecisionPoint;
