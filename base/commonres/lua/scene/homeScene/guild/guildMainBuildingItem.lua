
guildMainBuildingItem = class("guildMainBuildingItem", MGImageView)

function guildMainBuildingItem:ctor()
    
end

function guildMainBuildingItem:init(delegate)
	self.delegate = delegate
	self.cityImg = ccui.ImageView:create();
	self:addChild(self.cityImg);
	self.cityImg:setTouchEnabled(true);
    self.cityImg:addTouchEventListener(handler(self,self.onButtonClick));

    --建筑名
    self.nameSpr = cc.Sprite:create();
    self:addChild(self.nameSpr,1);

    self.pointSpr = cc.Sprite:createWithSpriteFrameName("common_change_red_dot.png");
    self.nameSpr:addChild(self.pointSpr);
    self.pointSpr:setVisible(false);
end

function guildMainBuildingItem:setData(buildInfo)
    self.buildInfo = buildInfo;
    self.cityImg:loadTexture(self.buildInfo.pic..".png",ccui.TextureResType.plistType);
    self.nameSpr:setSpriteFrame(self.buildInfo.namePic..".png");
    self.nameSpr:setPosition(cc.p(self.buildInfo.namepos.x,self.buildInfo.namepos.y));
    self.pointSpr:setPosition(cc.p(self.nameSpr:getContentSize().width,self.nameSpr:getContentSize().height));
end

function guildMainBuildingItem:onButtonClick(sender, eventType)
    if eventType == ccui.TouchEventType.began then
        if self.buildSpr==nil then
            self.buildSpr = cc.Sprite:createWithSpriteFrameName(self.buildInfo.pic..".png");
            self.buildSpr:setPosition(self.cityImg:getPosition());
            self:addChild(self.buildSpr);
            self.buildSpr:setShaderProgram(MGGraySprite:getLightShaderProgram(1));
        end
    end
    if eventType == ccui.TouchEventType.canceled then
        if self.buildSpr then
            self.buildSpr:removeFromParent();
            self.buildSpr = nil;
        end
    end
    if eventType == ccui.TouchEventType.ended then
        if self.buildSpr then
            self.buildSpr:removeFromParent();
            self.buildSpr = nil;
        end
        if self.delegate and self.delegate.onSelect then
            self.delegate:onSelect(tonumber(self.buildInfo.id));
        end
    end
end

function guildMainBuildingItem:remove()
    self:removeFromParent();
end

function guildMainBuildingItem:onEnter()

end

function guildMainBuildingItem:onExit()
	MGRCManager:releaseResources("guildMainBuildingItem")
end

function guildMainBuildingItem.create(delegate)
	local layer = guildMainBuildingItem:new()
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
