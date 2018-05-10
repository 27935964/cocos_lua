----云中城宝箱点界面----
-- require "ItemJump";
local TreasureBoxPoint=class("TreasureBoxPoint",function()
	return cc.Layer:create();
end);

function TreasureBoxPoint:ctor(delegate)
  	self.delegate=delegate;
    self.diceContent=delegate.diceContent;
    -- 剩余开箱次数
    self.remainNum=0;
    -- 
  	self.pWidget=MGRCManager:widgetFromJsonFile("TreasureBoxPoint", "CloudCity_TreasureBoxPoint_Ui_1.ExportJson");
  	self:addChild(self.pWidget);

  	local panel_2 = self.pWidget:getChildByName("Panel_2");--Panel
    self.panel_3=self.pWidget:getChildByName("Panel_3");
    self:setNoCanClick(false);

    self.label_rdNum=panel_2:getChildByName("Label_ResidueDegree_number");
    -- 
    self.treasureBoxTab={};
    self.panel_treasureBox=panel_2:getChildByName("Panel_TreasureBox");
    for i=1,6 do
        local treasureBoxBtn=self.panel_treasureBox:getChildByName(string.format("Image_%d",4+i));
        treasureBoxBtn:setTag(i);
        treasureBoxBtn:addTouchEventListener(handler(self,self.treasureBoxBtnClick));
        table.insert(self.treasureBoxTab,treasureBoxBtn);
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
    local label_residueDegree=panel_2:getChildByName("Label_ResidueDegree");
    label_residueDegree:setText(MG_TEXT_COCOS("TreasureBoxPoint_Ui_1"));
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

function TreasureBoxPoint:setNoCanClick(isVisible)
    self.panel_3:setTouchEnabled(isVisible);
end

function TreasureBoxPoint:initData()
    if self.delegate then
        self.delegate:showAngelInfo(self.img_bubble,self.img_angel,self.img_name,self.panel_24,false);
    end
    self:refreshTreasureBox(true);
end

function TreasureBoxPoint:refreshTreasureBox(isInit)
    self.remainNum=0;
    if string.len(self.diceContent)>0 then
        local str_list=spliteStr(self.diceContent,'|');
        self.remainNum=tonumber(str_list[1]);
        -- 已经开过的
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
                for j=1,table.getn(self.treasureBoxTab) do
                    if j==pos then
                        local openTBox=self.treasureBoxTab[j];
                        openTBox:setTag(0);
                        local img_17=openTBox:getChildByName("Image_17");
                        img_17:loadTexture("CloudCity_TreasureBox_open.png", ccui.TextureResType.plistType);
                        break
                    end
                end
            end
        end
    end
    self.label_rdNum:setText(string.format("%d",self.remainNum));
end

function TreasureBoxPoint:treasureBoxBtnClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local tagVal=sender:getTag();
        if tagVal>0 then
            self.openTBox=sender;
            local str=string.format("&pos=%d",tagVal);
            NetHandler:sendData(Post_Cloud_Main_doBox, str);
            sender:setTag(0);
            -- 
            local img_17=self.openTBox:getChildByName("Image_17");
            img_17:loadTexture("CloudCity_TreasureBox_open.png", ccui.TextureResType.plistType);
        else
            -- 等于0表示已经开过了
        end
    end
end

function TreasureBoxPoint:onReciveData(msgId, netData)
	  if msgId == Post_Cloud_Main_doBox then
      	if netData.state == 1 then
            local dobox=netData.dobox;
            self.diceContent=dobox.content;
            self:refreshTreasureBox(true);
            -- 
            local reward=dobox.reward;
            if string.len(reward)>0 then
                local itemPos={};
                local pos=cc.p(self.openTBox:getPositionX(),self.openTBox:getPositionY());
                table.insert(itemPos,pos);
                ItemJump:getInstance():showItemJump(reward,self.panel_treasureBox,itemPos,0.7,true);
            else
                MGMessageTip:showFailedMessage(MG_TEXT("TreasureBoxPoint_1"));
            end
            -- 
            local coin=dobox.get_coin;
            local stone=dobox.get_stone;
            if self.delegate then
                self.delegate:changeTopInfo(coin,stone);
            end
            -- 
            if self.remainNum<=0 then
                self:setNoCanClick(true);
                -- 延迟关闭
                local function delayClose()
                    self:closeTreasureBox();
                end
                local delay=cc.DelayTime:create(2.0);
                local callFunc=cc.CallFunc:create(delayClose);
                self:runAction(cc.Sequence:create(delay,callFunc));
            end
      	else
          	NetHandler:showFailedMessage(netData);
      	end
  	end
end

function TreasureBoxPoint:closeTreasureBox()
    if self.delegate then
        self.delegate:closeOpenLayer();
    end
end

function TreasureBoxPoint:onEnter()
    NetHandler:addAckCode(self,Post_Cloud_Main_doBox);
end

function TreasureBoxPoint:onExit()
	  NetHandler:delAckCode(self,Post_Cloud_Main_doBox);
	  MGRCManager:releaseResources("TreasureBoxPoint");
end

return TreasureBoxPoint;
