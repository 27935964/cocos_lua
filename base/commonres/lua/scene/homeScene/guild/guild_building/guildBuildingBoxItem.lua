--------------------------公会建设--宝箱Item-----------------------


guildBuildingBoxItem = class("guildBuildingBoxItem",function()  
    return ccui.Layout:create(); 
end)

function guildBuildingBoxItem:ctor()
    self.isCanGet = false;
end

function guildBuildingBoxItem:init()
    self:setSize(cc.size(80, 100));
    self:setAnchorPoint(cc.p(0.5,0.5));

    self.boxImg = ccui.ImageView:create("GuildBuilding_RewardBox.png", ccui.TextureResType.plistType);
    local y = self:getContentSize().height-self.boxImg:getContentSize().height/2;
    self.boxImg:setPosition(cc.p(self:getContentSize().width/2, y));
    self.boxImg:setTouchEnabled(true);
    self.boxImg:addTouchEventListener(handler(self,self.onButtonClick));
    self:addChild(self.boxImg);
    self.oldHeadProgram = self.boxImg:getSprit():getShaderProgram();
    self.boxImg:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());

    --已领取
    self.getSpr = cc.Sprite:createWithSpriteFrameName("com_received_2.png");
    self.getSpr:setPosition(self.boxImg:getPosition());
    self:addChild(self.getSpr,1);
    self.getSpr:setVisible(false);

    --数量
    self.numLabel = cc.Label:createWithTTF("", ttf_msyh, 22);
    self.numLabel:setAnchorPoint(cc.p(0.5,0.5));
    self.numLabel:setPosition(cc.p(self.boxImg:getPositionX(),10));
    self.numLabel:enableOutline(cc.c4b(  0,   0,   0, 255),1);
    self:addChild(self.numLabel,2);
    self.numLabel:setAdditionalKerning(-2);
end

function guildBuildingBoxItem:setData(data,rewardData)
    self.data = data;
    self.rewardData = rewardData;

    self.numLabel:setString(self.rewardData.exp);
    local str_list = spliteStr(self.data.get_reward,'|');
    if tonumber(self.data.day_exp) >= self.rewardData.exp then--可领取/已领取
        self.boxImg:getSprit():setShaderProgram(self.oldHeadProgram);
        self.isCanGet = true;--可领取
        for i=1,#str_list do
            if tonumber(str_list[i]) == self.rewardData.exp then--已领取
                self.getSpr:setVisible(true);
                self.boxImg:setTouchEnabled(false);
                self.isCanGet = false;--已领取
                break;
            end
        end
    end

end

function guildBuildingBoxItem:onButtonClick(sender, eventType)
    buttonClickScale(sender, eventType);
    if eventType == ccui.TouchEventType.ended then
        if self.delegate and self.delegate.response then
            self.delegate:response(self);
        end
    end
end

function guildBuildingBoxItem:onEnter()

end

function guildBuildingBoxItem:onExit()
    MGRCManager:releaseResources("guildBuildingBoxItem");
end

function guildBuildingBoxItem.create(delegate)
    local layer = guildBuildingBoxItem:new();
    layer.delegate = delegate;
    layer:init();
    local function onNodeEvent(event)
        if event == "enter" then
            layer:onEnter();
        elseif event == "exit" then
            layer:onExit();
        end
    end
    layer:registerScriptHandler(onNodeEvent);
    return layer;
end
