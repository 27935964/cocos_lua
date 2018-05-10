require "Item"

MLReward = class("MLReward", MGLayer)

function MLReward:ctor()
    self:init();
end

function MLReward:init()
    MGRCManager:cacheResource("MLReward", "user_card_get_bg.png");
    local pWidget = MGRCManager:widgetFromJsonFile("MLReward","reward_ui_2.ExportJson");
    self:addChild(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));
    local Panel_2 = pWidget:getChildByName("Panel_2");

    self.Image_title = Panel_2:getChildByName("Image_title");
    self.Image_star = Panel_2:getChildByName("Image_star");
    
    self.Label_over = Panel_2:getChildByName("Label_over");
    self.Label_over:setVisible(false);
    self.Label_over:setText(MG_TEXT_COCOS("reward_ui_2_2"));

    self.ProgressBar = Panel_2:getChildByName("ProgressBar");
    self.Label_value = self.ProgressBar:getChildByName("Label_value");

    self.ListView = Panel_2:getChildByName("ListView");

    self.Button_receive = Panel_2:getChildByName("Button_receive");--领奖
    self.Button_receive:addTouchEventListener(handler(self,self.onButtonClick));

    local Label_receive = self.Button_receive:getChildByName("Label_receive");
    Label_receive:setText(MG_TEXT_COCOS("reward_ui_2_1"));

end

function MLReward:setData(data,type)
    self.data = data;
    self.type = type;
    
    self.itemDatas = {};
    if type == 1 then--关卡进度
        self.Image_title:loadTexture("checkpoint_reward_title_1.png",ccui.TextureResType.plistType);
        self.Label_value:setText(string.format("%d%%",self.delegate.data.percent));
        self.ProgressBar:setPercent(self.delegate.data.percent);
        self.Image_star:setVisible(false);
        self.Label_over:setVisible(true);
        self.itemDatas = self.data.all_pass_reward;
    elseif type == 2 then--满星率
        self.Image_title:loadTexture("checkpoint_reward_title_2.png",ccui.TextureResType.plistType);
        self.Label_value:setText(string.format("%d/%d",self.delegate.data.star,self.delegate.totalStarNum));
        self.ProgressBar:setPercent(self.delegate.data.star*100/self.delegate.totalStarNum);
        self.Image_star:setVisible(true);
        self.Label_over:setVisible(false);
        self.itemDatas = self.data.full_star_reward;
    end

    self.ListView:removeAllItems();
    local itemLay = ccui.Layout:create();
    itemLay:setSize(cc.size(self.ListView:getContentSize().width, self.ListView:getContentSize().height));
    if #self.itemDatas > 5 then
        itemLay:setSize(cc.size(#self.itemDatas*130, self.ListView:getContentSize().height));
    end
    self.ListView:pushBackCustomItem(itemLay);

    self.items = {};
    for i=1,#self.itemDatas do
        local item = resItem.create(self);
        item:setData(self.itemDatas[i].type,self.itemDatas[i].id,self.itemDatas[i].num);
        item.nameLabel:setVisible(true);
        itemLay:addChild(item);
        -- item.numLabel:setVisible(false);
        item:setPosition(cc.p(item:getContentSize().width/2+(i-1)*(item:getContentSize().width+20),itemLay:getContentSize().height/2+30));
        table.insert(self.items,item);
    end

    local average = math.ceil(#self.items/2);
    local mod = math.mod(#self.items,2);
    local posX = itemLay:getContentSize().width/2;
    if mod == 0 then
        posX = posX-self.items[1]:getContentSize().width/2-10;
        for i=1,#self.items do
            if i < average then
                self.items[i]:setPositionX(posX-(average-i)*(self.items[i]:getContentSize().width+20));
            elseif i == average then
                self.items[i]:setPositionX(posX);
            else
                self.items[i]:setPositionX(posX+(i-average)*(self.items[i]:getContentSize().width+20));
            end
        end
    elseif mod == 1 then
        for i=1,#self.items do
            if i < average then
                self.items[i]:setPositionX(posX-(average-i)*(self.items[i]:getContentSize().width+20));
            elseif i == average then
                self.items[i]:setPositionX(posX);
            else
                self.items[i]:setPositionX(posX+(i-average)*(self.items[i]:getContentSize().width+20));
            end
        end
    end
end

function MLReward:onButtonClick(sender, eventType)
    if sender ~= self.Panel_1 then
        buttonClickScale(sender, eventType);
    end

    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_receive then
            if self.type ==1 then----关卡进度
                if self.delegate and self.delegate.getAllPassRewardSendReq then
                    self.delegate:getAllPassRewardSendReq();
                end
            elseif self.type ==2 then--满星率
                if self.delegate and self.delegate.getFullStarRewardSendReq then
                    self.delegate:getFullStarRewardSendReq();
                end
            end
        end
        self:removeFromParent();
    end
end

function MLReward:onEnter()

end

function MLReward:onExit()
    MGRCManager:releaseResources("MLReward");
end

function MLReward.create(delegate)
    local layer = MLReward:new()
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

function MLReward.showBox(delegate)
    local layer = MLReward.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
