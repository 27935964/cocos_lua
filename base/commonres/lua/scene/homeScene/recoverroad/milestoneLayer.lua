--------------------------光复之路中的里程碑-----------------------

local milestoneItem = require "milestoneItem"
milestoneLayer = class("milestoneLayer", MGLayer)

function milestoneLayer:ctor()

end

function milestoneLayer:init(delegate)
    self.delegate = delegate
    local pWidget = MGRCManager:widgetFromJsonFile("milestoneLayer","recoverroad_milestone.ExportJson");
    self:addChild(pWidget);

    if not self.itemWidget then
        self.itemWidget = MGRCManager:widgetFromJsonFile("milestoneLayer", "recoverroad_milestone_record.ExportJson",false);
        self.itemWidget:retain();
    end

    local Panel_1 = pWidget:getChildByName("Panel_1");
    Panel_1:addTouchEventListener(handler(self,self.onButtonClick));
    local Panel_2 = pWidget:getChildByName("Panel_2");

    self.Button_close = Panel_2:getChildByName("Button_close");--返回
    self.Button_close:addTouchEventListener(handler(self,self.onButtonClick));

    self.ListView = Panel_2:getChildByName("ListView");
    self.ListView:setScrollBarVisible(false);
    self.ListView:setItemsMargin(35);
    -- self.ListView:setBounceEnabled(true);

    local Label_tip = Panel_2:getChildByName("Label_tip");
    Label_tip:setVisible(false);

    self.tipLabel = MGColorLabel:label();
    self.tipLabel:setPosition(Label_tip:getPosition());
    Panel_2:addChild(self.tipLabel);

    self.tipLabel:clear();
    self.tipLabel:appendStringAutoWrap(string.format(MG_TEXT("recoverroadLayer_2"),5),26,1,cc.c3b(187,170,100),22);

end

function milestoneLayer:setData(data,loadList)
    self.data = data;
    self.loadList = loadList;

    self.ListView:removeAllItems();
    for i=1,#self.loadList do
        local item = milestoneItem.create(self,self.itemWidget:clone());
        item:setData(self.data,self.loadList[i],i);
        self.ListView:pushBackCustomItem(item);
    end
end

function milestoneLayer:getMileageReward(item)
    if self.delegate and self.delegate.getMileageRewardSendReq then
        self.delegate:getMileageRewardSendReq(item.loadId);
    end
end

function milestoneLayer:onButtonClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        if self.delegate and self.delegate.removeMilestoneLayer then
            self.delegate:removeMilestoneLayer();
        end
        self:removeFromParent();
    end
end

function milestoneLayer:onReciveData(MsgID, NetData)
    print("milestoneLayer onReciveData MsgID:"..MsgID)

    if MsgID == Post_getUserExpeditionCoin then
        local ackData = NetData
        if ackData.state == 1 then
            self.pPanelTop:setRankCoin(ackData.getuserexpeditioncoin.expedition_coin);
            NetHandler:sendData(Post_getUserExpedition, "");
        else
            NetHandler:showFailedMessage(ackData)
        end
    end
end

function milestoneLayer:sendReq(isDash)
    local str = string.format("&is_dash=%d",isDash);
    NetHandler:sendData(Post_entryStage, str);
end

function milestoneLayer:pushAck()
    NetHandler:addAckCode(self,Post_getUserExpeditionCoin);
    NetHandler:addAckCode(self,Post_getUserExpedition);
    NetHandler:addAckCode(self,Post_stageInfo);
    NetHandler:addAckCode(self,Post_entryStage);
    NetHandler:addAckCode(self,Post_payReSet);
    NetHandler:addAckCode(self,Post_reSetExpedition);
end

function milestoneLayer:popAck()
    NetHandler:delAckCode(self,Post_getUserExpeditionCoin);
    NetHandler:delAckCode(self,Post_getUserExpedition);
    NetHandler:delAckCode(self,Post_stageInfo);
    NetHandler:delAckCode(self,Post_entryStage);
    NetHandler:delAckCode(self,Post_payReSet);
    NetHandler:delAckCode(self,Post_reSetExpedition);
end

function milestoneLayer:onEnter()
    self:pushAck();
end

function milestoneLayer:onExit()
    MGRCManager:releaseResources("milestoneLayer");
    self:popAck();
    if self.itemWidget then
        self.itemWidget:release()
    end
end

function milestoneLayer.create(delegate)
    local layer = milestoneLayer:new()
    layer:init(delegate)
    local function onNodeEvent(event)
        if event == "enter" then
            layer:onEnter()
        elseif event == "exit" then
            layer:onExit()
        end
    end
    layer:registerScriptHandler(onNodeEvent)
    return layer   
end

function milestoneLayer.showBox(delegate)
    local layer = milestoneLayer.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
