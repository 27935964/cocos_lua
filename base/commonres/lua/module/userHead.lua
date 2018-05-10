----------------------用户信息头像-----------------------

userHead = class("userHead", function()
    return ccui.ImageView:create();
end)

function userHead:ctor()
    self:init();
end

function userHead:init()
    --背景
    self:loadTexture("com_user_bg.png",ccui.TextureResType.plistType);
    self:setTouchEnabled(true);
    self:addTouchEventListener(handler(self,self.onBtnClick));
    self.size = self:getContentSize();

    self.headSpr = cc.Sprite:create();
    self.headSpr:setPosition(cc.p(self.size.width/2, self.size.height/2));
    self:addChild(self.headSpr);

    self.boxSpr = cc.Sprite:createWithSpriteFrameName("com_general_box.png");
    self.boxSpr:setPosition(cc.p(self.size.width/2, self.size.height/2));
    self:addChild(self.boxSpr,1);
    
end

function userHead:setData(gm)
    self.gm = gm;
    if self.gm then
        MGRCManager:cacheResource("userHead", self.gm:head());
        self.headSpr:setSpriteFrame(self.gm:head());
        local rate1 = (self:getContentSize().width-10)/self.headSpr:getContentSize().width;
        local rate2 = (self:getContentSize().height-10)/self.headSpr:getContentSize().height;
        if rate1 <= rate2 then
            self.headSpr:setScale(rate1);
        else
            self.headSpr:setScale(rate2);
        end
    end
end

function userHead:setHeadData(fileName)--通用的
    MGRCManager:cacheResource("userHead", fileName);
    self.headSpr:setSpriteFrame(fileName);
    local rate1 = (self:getContentSize().width-10)/self.headSpr:getContentSize().width;
    local rate2 = (self:getContentSize().height-10)/self.headSpr:getContentSize().height;
    if rate1 <= rate2 then
        self.headSpr:setScale(rate1);
    else
        self.headSpr:setScale(rate2);
    end
end

function userHead:onBtnClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        if self.delegate and self.delegate.HeroHeadSelect then
            self.delegate:HeroHeadSelect(self);
        end
    end
end

function userHead:onEnter()

end

function userHead:onExit()
    MGRCManager:releaseResources("userHead")
end

function userHead.create(delegate)
    local layer = userHead:new()
    layer.delegate = delegate;
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
