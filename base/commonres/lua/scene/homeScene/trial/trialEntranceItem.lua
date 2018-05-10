--------------------------试炼难度选择界面-----------------------

trialEntranceItem = class("trialEntranceItem",function()  
    return ccui.Layout:create();
end)

function trialEntranceItem:ctor()
    self:init()
end

function trialEntranceItem:init()
    self:setSize(cc.size(145, 580));
    self:setAnchorPoint(cc.p(0.5,0.5));

    --入口按钮
    self.enterBtn = ccui.Button:create();
    self.enterBtn:setPosition(cc.p(self:getSize().width/2, self:getSize().height/2));
    self.enterBtn:loadTextureNormal("trial_base_normal_1.png", ccui.TextureResType.plistType);
    self.enterBtn:loadTexturePressed("trial_base_pressed_1.png", ccui.TextureResType.plistType);
    self.enterBtn:loadTextureDisabled("trial_base_pressed_1.png", ccui.TextureResType.plistType);
    self:addChild(self.enterBtn);
    self.enterBtn:addTouchEventListener(handler(self,self.onButtonClick));

    self.starSprs = {};
    for i=1,3 do
        local starSpr = cc.Sprite:createWithSpriteFrameName("com_sciSoldier_star_5.png");
        starSpr:setPosition(cc.p(self:getSize().width/2-starSpr:getContentSize().width/2-20
            +(i-1)*(starSpr:getContentSize().width/2+20),self:getSize().height*3/4-50));
        self:addChild(starSpr,1);
        table.insert(self.starSprs,starSpr);
    end

    self.skullSpr = cc.Sprite:create();
    self.skullSpr:setPosition(cc.p(self:getSize().width/2,self:getSize().height*3/4+30));
    self:addChild(self.skullSpr,1);

    self.levelLabel = cc.Label:createWithTTF("0",ttf_msyh,22);
    self.levelLabel:setAnchorPoint(cc.p(0.5, 0.5));
    self.levelLabel:setPosition(cc.p(self:getSize().width/2, 28));
    self:addChild(self.levelLabel,1);
end

function trialEntranceItem:setData(data,checkpointInfo,index)
    self.data = data;
    self.index = index;
    self.checkpointInfo = checkpointInfo;

    for i=1,#self.starSprs do
        self.starSprs[i]:setVisible(false);
        if i <= tonumber(data.star[index].star) then
            self.starSprs[i]:setVisible(true);
        end
    end

    self.skullSpr:setSpriteFrame(string.format("trial_skull_%d.png",index));
    self.levelLabel:setString(string.format(MG_TEXT("trialEntranceItem_1"),checkpointInfo.need_lv));
    self.enterBtn:loadTextureNormal(string.format("trial_base_normal_%d.png",index), ccui.TextureResType.plistType);
    self.enterBtn:loadTexturePressed(string.format("trial_base_pressed_%d.png",index), ccui.TextureResType.plistType);
    self.enterBtn:loadTextureDisabled(string.format("trial_base_pressed_%d.png",index), ccui.TextureResType.plistType);
end

function trialEntranceItem:setBright(isBright)
    self.enterBtn:setBright(isBright);
end

function trialEntranceItem:onButtonClick(sender, eventType)
    if eventType == ccui.TouchEventType.began then
        -- self.bgSpr:setShaderProgram(MGGraySprite:getLightShaderProgram(3));
        -- self.logoSpr:setShaderProgram(MGGraySprite:getLightShaderProgram(3));
    end
    if eventType == ccui.TouchEventType.canceled then
        -- self.bgSpr:setShaderProgram(MGGraySprite:getLightShaderProgram(0));
        -- self.logoSpr:setShaderProgram(MGGraySprite:getLightShaderProgram(0));
    end
    if eventType == ccui.TouchEventType.ended then
        -- self.bgSpr:setShaderProgram(MGGraySprite:getLightShaderProgram(0));
        -- self.logoSpr:setShaderProgram(MGGraySprite:getLightShaderProgram(0));
        -- if self.delegate and self.delegate.doFlipSendReq then
        --     self.delegate:doFlipSendReq(self.index);
        -- end
        if self.delegate and self.delegate.callBack then
            self.delegate:callBack(self);
        end
    end
end

function trialEntranceItem:onEnter()

end

function trialEntranceItem:onExit()
    MGRCManager:releaseResources("trialEntranceItem");
end

function trialEntranceItem.create(delegate)
    local layer = trialEntranceItem:new()
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
