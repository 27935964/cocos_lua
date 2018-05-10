--------------------------公会成就Item-----------------------

local guildAchievementItem = class("guildAchievementItem", MGWidget)

function guildAchievementItem:init(delegate,widget)
    self.delegate=delegate;
    self:addChild(widget);
    self.pWidget = widget;

    self.timer = CCTimer:new();
    self.isStationed = false;
    self.timeNum = nil;

    local Panel_2 = self.pWidget:getChildByName("Panel_2");
    self:setContentSize(Panel_2:getContentSize());

    self.Label_Capture = Panel_2:getChildByName("Label_Capture");
    self.Image_City = Panel_2:getChildByName("Image_City");
    self.Image_Received = Panel_2:getChildByName("Image_Received");

    self.ListView = Panel_2:getChildByName("ListView");
    self.ListView:setScrollBarVisible(false);

    self.Button_Receive = Panel_2:getChildByName("Button_Receive");
    self.Button_Receive:addTouchEventListener(handler(self,self.onButtonClick));

    local Label_First = Panel_2:getChildByName("Label_First");
    Label_First:setText(MG_TEXT_COCOS("GuildAchievement_ui_item_1"));

    local Label_Receive = self.Button_Receive:getChildByName("Label_Receive");
    Label_Receive:setText(MG_TEXT_COCOS("GuildAchievement_ui_item_2"));

end

function guildAchievementItem:setData(data,achievementData)
    self.data = data;
    self.achievementData = achievementData;
    

    self:creatItem();
    self.Label_Capture:setText(string.format(MG_TEXT("guildAchievementLayer_2"),self.achievementData.city_num));
    
    self.Button_Receive:setEnabled(false);
    self.Image_Received:setVisible(true);
    local str_list = spliteStr(self.data.achievement,':');
    if tonumber(self.data.city_num) >= self.achievementData.city_num then--已完成
        local isGet = false;
        for i=1,#str_list do
            if tonumber(str_list[i]) == self.achievementData.id then--已领取
                isGet = true;
                break;
            end
        end
        if isGet == false then--未领取/可领取
            self.Button_Receive:setEnabled(true);
            self.Image_Received:setVisible(false);
        else--已领取
            self.Image_Received:loadTexture("com_received_1.png",ccui.TextureResType.plistType);
        end
    else
        self.Image_Received:loadTexture("com_unfinished.png",ccui.TextureResType.plistType);
    end
end

function guildAchievementItem:creatItem()
    self.ListView:removeAllItems();
    for i=1,#self.achievementData.reward do
        local reward = self.achievementData.reward[i];
        local item = resItem.create(self);
        item:setData(reward.value1,reward.value2,reward.value3);
        self.ListView:setItemsMargin(10);
        self.ListView:pushBackCustomItem(item);
    end
end

function guildAchievementItem:onButtonClick(sender, eventType)
    buttonClickScale(sender, eventType);

    if eventType == ccui.TouchEventType.ended then
        if self.delegate and self.delegate.sendReq then
            self.delegate:sendReq(self);
        end
    end
end

function guildAchievementItem:onEnter()
    
end

function guildAchievementItem:onExit()
    MGRCManager:releaseResources("guildAchievementItem");
end

function guildAchievementItem.create(delegate,widget)
    local layer = guildAchievementItem:new()
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

return guildAchievementItem