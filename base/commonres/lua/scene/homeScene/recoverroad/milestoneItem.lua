--------------------------光复之路中的里程碑-----------------------

local milestoneItem = class("milestoneItem", MGWidget)

function milestoneItem:init(delegate,widget)
    self.delegate=delegate;
    self:addChild(widget);
    self.pWidget = widget;

    local Panel_2 = self.pWidget:getChildByName("Panel_2");
    self:setContentSize(Panel_2:getContentSize());

    self.Image_mark = Panel_2:getChildByName("Image_mark");
    self.Image_mark:setVisible(false);

    self.Label_tip = Panel_2:getChildByName("Label_tip");
    self.Label_tip:setVisible(false);

    local Image_bg1 = Panel_2:getChildByName("Image_bg1");
    self.Label_title = Image_bg1:getChildByName("Label_title");
    self.Label_miles = Image_bg1:getChildByName("Label_miles");

    local Image_bg2 = Panel_2:getChildByName("Image_bg2");
    self.BitmapLabel = Image_bg2:getChildByName("BitmapLabel");
    self.ListView = Image_bg2:getChildByName("ListView");
    self.ListView:setScrollBarVisible(false);
    self.ListView:setBounceEnabled(true);

    self.Button_get = Panel_2:getChildByName("Button_get");
    self.Button_get:addTouchEventListener(handler(self,self.onButtonClick));

    self.Label_get = self.Button_get:getChildByName("Label_get");
    self.Label_get:setText(MG_TEXT("recoverroadLayer_5"));
    self.Label_get:getLabel():enableShadow(cc.c4b(  0,   0,   0, 191), cc.size(2, -2),1);
end

function milestoneItem:readSql(loadId,getMileage)--解析数据库数据
    self.rewardInfo = {};
    local sql = string.format("select * from load_mileage_reward where l_id=%d and mileage>%d order by mileage asc limit 1",loadId,getMileage);
    local DBData = LUADB.select(sql, "l_id:mileage:reward");

    self.rewardInfo.l_id = tonumber(DBData.info.l_id);
    self.rewardInfo.mileage = tonumber(DBData.info.mileage);
    self.rewardInfo.reward = getDataList(DBData.info.reward);

end

function milestoneItem:setData(data,loadInfo,loadId)
    self.data = data;
    self.loadInfo = loadInfo;
    self.loadId = loadId;
    self.curMileage = 0;--当前公里数
    self.getMileage = 0;--已领取奖励的公里数

    for i=1,#self.data.loadinfo do
        if loadId == self.data.loadinfo[i].lid then
            self.curMileage = tonumber(self.data.loadinfo[i].mileage);
            self.getMileage = tonumber(self.data.loadinfo[i].get_mileage_reward);
            break;
        end
    end
    self:readSql(loadId,self.getMileage);
    self.Label_title:setText(self.loadInfo.name);
    self.Label_miles:setText(string.format(MG_TEXT("recoverroadLayer_4"),self.curMileage));
    self.BitmapLabel:setText(self.rewardInfo.mileage);

    self.queues = {};
    self.queues = newline(#self.rewardInfo.reward,2);
    self.ListView:removeAllItems();
    local itemLay = ccui.Layout:create();
    itemLay:setSize(cc.size(self.ListView:getContentSize().width, self.queues[#self.rewardInfo.reward].row*115));
    self.ListView:pushBackCustomItem(itemLay);

    -- itemLay:setBackGroundColorType(1);
    -- itemLay:setBackGroundColor(cc.c3b(0,255,250));

    for i=1,#self.rewardInfo.reward do
        local reward = self.rewardInfo.reward[i];
        local item = resItem.create(self);
        item:setData(1,1,1);
        -- item:setData(reward.value1,reward.value2,reward.value3);
        item:setPosition(cc.p(self.queues[i].col*115+item:getContentSize().width/2+2,
            itemLay:getContentSize().height-self.queues[i].row*115+item:getContentSize().height/2+7));
        itemLay:addChild(item);
    end

    if self.curMileage < tonumber(self.rewardInfo.mileage) then
        self.Button_get:setBright(false);
        self.Button_get:setTouchEnabled(false);
        self.Label_get:setText(MG_TEXT("recoverroadLayer_6"));
    elseif self.curMileage >= self.rewardInfo.mileage then
        self.Button_get:setBright(true);
        self.Button_get:setTouchEnabled(true);
        self.Label_get:setText(MG_TEXT("recoverroadLayer_5"));
    end
end

function milestoneItem:onButtonClick(sender, eventType)
    buttonClickScale(sender, eventType, 0.9);

    if eventType == ccui.TouchEventType.ended then
        if self.delegate and self.delegate.getMileageReward then
            self.delegate:getMileageReward(self);
        end
    end
end

function milestoneItem:onEnter()
    
end

function milestoneItem:onExit()
    MGRCManager:releaseResources("milestoneItem")
end

function milestoneItem.create(delegate,widget)
    local layer = milestoneItem:new()
    layer:init(delegate,widget)
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

return milestoneItem