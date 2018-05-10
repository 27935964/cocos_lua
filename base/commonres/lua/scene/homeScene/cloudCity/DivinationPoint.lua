----云中城翻牌点界面----

local DivinationPoint=class("DivinationPoint",function()
	return cc.Layer:create();
end);

function DivinationPoint:ctor(delegate)
  	self.delegate=delegate;
  	self.diceContent=delegate.diceContent;
    -- 位置
    self.pos=0;
    -- 剩余翻牌次数
    self.remainNum=0;
    -- 
    MGRCManager:cacheResource("DivinationPoint", "fanpai_ui.png","fanpai_ui.plist");
  	self.pWidget=MGRCManager:widgetFromJsonFile("DivinationPoint", "CloudCity_DivinationPoint_Ui.ExportJson");
  	self:addChild(self.pWidget);

  	local panel_2 = self.pWidget:getChildByName("Panel_2");
    self.panel_3=self.pWidget:getChildByName("Panel_3");
    self:setNoCanClick(false);
    -- 剩余次数
    self.label_times=panel_2:getChildByName("Label_Times");
    -- 
    self.cardsTab={};
    local panel_cards=panel_2:getChildByName("Panel_Cards");
    for i=1,6 do
        local btn_card=panel_cards:getChildByName(string.format("Image_%d",9+i));
        btn_card:setTouchEnabled(true);
        btn_card:setTag(i);
        btn_card:addTouchEventListener(handler(self,self.cardBtnClick));
        table.insert(self.cardsTab,btn_card);
    end
    -- tips
    self.img_bubble=panel_2:getChildByName("Image_Bubble");
    -- 图片
    self.img_angel=panel_2:getChildByName("Image_Angel");
    -- 名称 
    self.img_name=panel_2:getChildByName("Image_23");
    -- 星级
    self.panel_24=panel_2:getChildByName("Panel_24");
    -- 
    local label_remainingFT=panel_2:getChildByName("Label_RemainingFlopTimes");
    label_remainingFT:setText(MG_TEXT_COCOS("DivinationPoint_Ui_1"));
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

function DivinationPoint:setNoCanClick(isVisible)
    self.panel_3:setTouchEnabled(isVisible);
end

function DivinationPoint:initData()
    if self.delegate then
        self.delegate:showAngelInfo(self.img_bubble,self.img_angel,self.img_name,self.panel_24,false);
    end
    self:refreshDivination(true);
end

function DivinationPoint:refreshDivination(isInit)
    -- 格式3|4:18:1:500|3:18:1:500
    -- 翻牌次数|位置:物品类型:ID:数量|...
    self.remainNum=0;
    if string.len(self.diceContent)>0 then
        local str_list=spliteStr(self.diceContent,'|');
        self.remainNum=tonumber(str_list[1]);
        -- 已经翻过的
        if isInit then
            for i=2,#str_list do
                local str=spliteStr(str_list[i],':');
                local pos=tonumber(str[1]);
                self.reward="";
                for j=2,#str do
                    self.reward=self.reward..str[j];
                    if j<#str then
                        self.reward=self.reward..":"
                    end
                end
                for j=1,table.getn(self.cardsTab) do
                    if j==pos then
                        self.turnCard=self.cardsTab[j];
                        self.turnCard:setTag(0);
                        self:loadGetGood(false);
                        break
                    end
                end
            end
        end
    end
    self.label_times:setText(string.format("%d",self.remainNum));
end

function DivinationPoint:loadGetGood(isTurn)
    local resData=ResourceTip.getInstance():getResData(self.reward);
    local img_17=self.turnCard:getChildByName("Image_17");
    img_17:setVisible(false);
    local item = resItem.create();
    item:setData(resData.type,resData.id,0);
    item:setNum(resData.num);
    self.turnCard:addChild(item);
    item:setPosition(img_17:getPositionX(),img_17:getPositionY());
    if isTurn then
        item:setScaleX(-1);
    end
end

function DivinationPoint:onReciveData(msgId, netData)
	  if msgId == Post_Cloud_Main_doFlip then
      	if netData.state == 1 then
            self.reward=netData.doflip.reward;
            self.diceContent=netData.doflip.content;
            local coin=netData.doflip.get_coin;
            local stone=netData.doflip.get_stone;
            if self.delegate then
                self.delegate:changeTopInfo(coin,stone);
            end
            -- 
            self:startTurn();
      	else
          	NetHandler:showFailedMessage(netData);
      	end
  	end
end

function DivinationPoint:startTurn()
    self.turnCard=nil;
    for i=1,table.getn(self.cardsTab) do
        if self.pos==i then
            self.turnCard=self.cardsTab[i];
            break
        end
    end
    if self.turnCard then
        local timer=0.25;
        local orbit=cc.OrbitCamera:create(timer, 1, 0, 0, 90, 0, 0);
        local orbit2=cc.OrbitCamera:create(timer, 1, 0, 90, 90, 0, 0);
        local function turnHalf()
            self:loadGetGood(true);
        end
        local delay=cc.DelayTime:create(timer);
        local callFunc=cc.CallFunc:create(turnHalf);
        local function turnOver()
            self:setNoCanClick(false);
            self:refreshDivination(false);
            if self.remainNum<=0 then
                self:setNoCanClick(true);
                -- 延迟关闭
                local function delayClose()
                    self:closeDivination();
                end
                local delay=cc.DelayTime:create(1.0);
                local callFunc=cc.CallFunc:create(delayClose);
                self:runAction(cc.Sequence:create(delay,callFunc));
            end
        end
        local callFunc2=cc.CallFunc:create(turnOver);
        self.turnCard:runAction(cc.Sequence:create(orbit,callFunc,orbit2,delay,callFunc2));
    end
end

function DivinationPoint:cardBtnClick(sender, eventType)
  	if eventType == ccui.TouchEventType.ended then
        self.pos=sender:getTag();
        if self.pos>0 then
            self:setNoCanClick(true);
            local str=string.format("&pos=%d",self.pos);
            NetHandler:sendData(Post_Cloud_Main_doFlip, str);
            sender:setTag(0);
        end
  	end
end

function DivinationPoint:closeDivination()
    if self.delegate then
        self.delegate:closeOpenLayer();
    end
end

function DivinationPoint:onEnter()
  	NetHandler:addAckCode(self,Post_Cloud_Main_doFlip);
end

function DivinationPoint:onExit()
  	NetHandler:delAckCode(self,Post_Cloud_Main_doFlip);
  	MGRCManager:releaseResources("DivinationPoint");
end

return DivinationPoint;