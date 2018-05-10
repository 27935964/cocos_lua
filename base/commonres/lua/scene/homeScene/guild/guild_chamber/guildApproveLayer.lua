-----------------------公会议会厅申请审批界面------------------------
require "MessageTip"

local guildApproveItem = require "guildApproveItem";
guildApproveLayer = class("guildApproveLayer", MGLayer)

function guildApproveLayer:ctor()
    self.curItem = nil;
    self:init();
end

function guildApproveLayer:init()
    local pWidget = MGRCManager:widgetFromJsonFile("guildNobilityLayer","guild_hall_ui_7.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);

    local Panel_2 = pWidget:getChildByName("Panel_2");
    self.Image_shade = Panel_2:getChildByName("Image_shade");
    self.Image_shade:setVisible(false);

    self.ListView = Panel_2:getChildByName("ListView");
    self.ListView:setScrollBarVisible(false);

    self.Button_reject = Panel_2:getChildByName("Button_reject");--一键拒绝
    self.Button_reject:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_agree = Panel_2:getChildByName("Button_agree");--一键同意
    self.Button_agree:addTouchEventListener(handler(self,self.onButtonClick));

    local Label_reject = self.Button_reject:getChildByName("Label_reject");
    Label_reject:setText(MG_TEXT_COCOS("guild_hall_ui_7_1"));

    local Label_agree = self.Button_agree:getChildByName("Label_agree");
    Label_agree:setText(MG_TEXT_COCOS("guild_hall_ui_7_2"));

    if not self.itemWidget then
        self.itemWidget = MGRCManager:widgetFromJsonFile("guildApproveLayer", "guild_hall_item_2.ExportJson",false);
        self.itemWidget:retain();
    end
end

function guildApproveLayer:setData(data)
    self.data = data;

    self.Image_shade:setVisible(false);
    self:createItem();

end

function guildApproveLayer:createItem()
    self.ListView:removeAllItems();
    local totalNum = #self.data.union_apply;

    local itemIndex = 1;
    local function loadEachItem(dt)
        if itemIndex > totalNum then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
        else

            local item = guildApproveItem.create(self,self.itemWidget:clone());
            item:setData(self.data.union_apply[itemIndex]);
            self.ListView:pushBackCustomItem(item);
            
            itemIndex = itemIndex+1;
        end
    end

    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
    end
    self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(loadEachItem, 0.001, false);
end

function guildApproveLayer:addTip(item)
    self.curItem = item;
    local MessageTip = MessageTip.showBox(self);
    MessageTip:setText();
end

function guildApproveLayer:callBack(item)
    item:removeFromParent();
    self:sendCancelApplyReq(self.curItem);
end

function guildApproveLayer:onButtonClick(sender, eventType)
    buttonClickScale(sender, eventType);
    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_reject then--一键拒绝
            self.items = {};
            self.items = self.ListView:getItems();
            for i=1,#self.items do
                self:sendCancelApplyReq(self.items[i]);
            end
        elseif sender == self.Button_agree then--一键同意
            self.items = {};
            self.items = self.ListView:getItems();
            for i=1,#self.items do
                self:sendAgreeApplyReq(self.items[i]);
            end
        end
    end
end

function guildApproveLayer:onReciveData(MsgID, NetData)
    print("guildApproveLayer onReciveData MsgID:"..MsgID)

    if MsgID == Post_getApply then
        local ackData = NetData
        if ackData.state == 1 then
            self:setData(ackData.getapply);
        else
            NetHandler:showFailedMessage(ackData)
        end
    elseif MsgID == Post_agreeApply then
        local ackData = NetData
        if ackData.state == 1 then
            if self.curItem then
                local index = self.ListView:getIndex(self.curItem);
                self.ListView:removeItem(index);
            end
            MGMessageTip:showFailedMessage(MG_TEXT("operate_successfully"));
        else
            NetHandler:showFailedMessage(ackData)
        end
    elseif MsgID == Post_cancelApply then
        local ackData = NetData
        if ackData.state == 1 then
            if self.curItem then
                local index = self.ListView:getIndex(self.curItem);
                self.ListView:removeItem(index);
            end
            MGMessageTip:showFailedMessage(MG_TEXT("operate_successfully"));
        else
            NetHandler:showFailedMessage(ackData)
        end
    end
end

function guildApproveLayer:sendAgreeApplyReq(item)
    self.curItem = item;
    local str = string.format("&id=%s",item.uid);
    NetHandler:sendData(Post_agreeApply, str);
end

function guildApproveLayer:sendCancelApplyReq(item)
    local str = string.format("&id=%s",item.uid);
    NetHandler:sendData(Post_cancelApply, str);
end

function guildApproveLayer:pushAck()
    NetHandler:addAckCode(self,Post_getApply);
    NetHandler:addAckCode(self,Post_agreeApply);
    NetHandler:addAckCode(self,Post_cancelApply);
end

function guildApproveLayer:popAck()
    NetHandler:delAckCode(self,Post_getApply);
    NetHandler:delAckCode(self,Post_agreeApply);
    NetHandler:delAckCode(self,Post_cancelApply);
end

function guildApproveLayer:onEnter()
    self:pushAck();
    NetHandler:sendData(Post_getApply, "");
end

function guildApproveLayer:onExit()
    self:popAck();
    MGRCManager:releaseResources("guildApproveLayer");
    if self.itemWidget then
        self.itemWidget:release();
    end
    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
    end
end

function guildApproveLayer.create(delegate)
    local layer = guildApproveLayer:new()
    layer.delegate = delegate
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
