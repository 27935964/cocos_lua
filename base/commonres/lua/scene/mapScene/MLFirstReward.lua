--------------------------首次攻克城池奖励---------------------------

MLFirstReward = class("MLFirstReward", MGLayer)

function MLFirstReward:ctor()
    self:init();
end

function MLFirstReward:init()
    require "Item";
    MGRCManager:cacheResource("MLFirstReward", "checkpoint_choose_bg.png");
    local pWidget = MGRCManager:widgetFromJsonFile("MLFirstReward","MainLine_first_reward_ui.ExportJson");
    self:addChild(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:setTouchEnabled(true)
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));

    local Panel_2 = pWidget:getChildByName("Panel_2");

    self.ListView = Panel_2:getChildByName("ListView");
    self.ListView:setScrollBarVisible(false);

    self.Image_soldier = Panel_2:getChildByName("Image_soldier");
    self.Label_name = Panel_2:getChildByName("Label_name");
    self.Image_gold = Panel_2:getChildByName("Image_gold");
    self.Label_gold = Panel_2:getChildByName("Label_gold");

    self.Button_sharing = Panel_2:getChildByName("Button_sharing");--分享
    self.Button_sharing:addTouchEventListener(handler(self,self.onButtonClick));
    self.Button_sharing:setEnabled(false);

    local Label_tip = Panel_2:getChildByName("Label_tip");
    Label_tip:setText(MG_TEXT_COCOS("MainLine_first_reward_ui_1"));

    local Label_tip1 = Panel_2:getChildByName("Label_tip1");
    Label_tip1:setText(MG_TEXT_COCOS("MainLine_first_reward_ui_2"));

    local Label_sharing = self.Button_sharing:getChildByName("Label_sharing");
    Label_sharing:setText(MG_TEXT_COCOS("MainLine_first_reward_ui_3"));

    NodeListener(self);
    self.value1 = tonumber(LUADB.readConfig(57));--城池每日税收
end

function MLFirstReward:setData(data)
    self.data = data;

    self.Label_gold:setText(string.format(MG_TEXT("ML_CheckpointLayer_1"),self.value1));
    self.Label_name:setText(self.data.name);
    MGRCManager:cacheResource("MLFirstReward", self.data.seize_city_pic);
    self.Image_soldier:loadTexture(self.data.seize_city_pic,ccui.TextureResType.plistType);

    self:createItem();
end

function MLFirstReward:createItem()
    self.ListView:removeAllItems();
    local totalNum = #self.data.reward;
    if nil == totalNum or totalNum <= 0 then
        return;
    end

    local itemLay = ccui.Layout:create();
    itemLay:setSize(cc.size(totalNum*155, self.ListView:getContentSize().height));
    self.ListView:pushBackCustomItem(itemLay);

    local itemIndex = 1;
    local function loadEachItem(dt)
        if itemIndex > totalNum then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
        else
            local data = self.data.reward[itemIndex];
            local item = resItem.create(self);
            item:setPosition(cc.p(item:getContentSize().width/2+(itemIndex-1)*(item:getContentSize().width+20)
                ,itemLay:getContentSize().height/2));
            item:setData(data.value1,data.value2,data.value3);
            item:setNum(data.value3);
            itemLay:addChild(item);

            itemIndex = itemIndex+1;
        end
    end

    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
    end
    self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(loadEachItem, 0.001, false);
end

function MLFirstReward:onButtonClick(sender, eventType)
    if sender ~= self.Panel_1 then
        buttonClickScale(sender, eventType);
    end

    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_sharing then
            print(">>>>>>>>>>>>>分享>>>>>>>>>>>>>>>>")
        else
            if self.delegate and self.delegate.upLevel then
                self.delegate:upLevel();
            end

            self:removeFromParent();
        end
    end
end

function MLFirstReward:onEnter()

end

function MLFirstReward:onExit()
    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
    end
    MGRCManager:releaseResources("MLFirstReward");
end

function MLFirstReward.create(delegate)
    local layer = MLFirstReward:new()
    layer.delegate = delegate
    layer:init()
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

function MLFirstReward.showBox(delegate)
    local layer = MLFirstReward.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_PRIORITY);
    return layer;
end
