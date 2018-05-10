-----------------------聊天弹框界面------------------------

chatTip = class("chatTip",function()  
    return ccui.Layout:create();
end)

function chatTip:ctor()
    self:init();
end

function chatTip:init()
    self:setSize(cc.size(125, 145));
    self:setAnchorPoint(cc.p(0,1));

    --背景
    local bgSpr = ccui.ImageView:create("Chat_reproduction.png", ccui.TextureResType.plistType);
    bgSpr:setPosition(cc.p(self:getContentSize().width/2,self:getContentSize().height/2));
    bgSpr:setScale9Enabled(true);
    bgSpr:setCapInsets(cc.rect(62, 27, 1, 1));
    bgSpr:setSize(cc.size(self:getContentSize().width,self:getContentSize().height));
    self:addChild(bgSpr);

    local bgSpr1 = ccui.ImageView:create("Chat_stripes.png", ccui.TextureResType.plistType);
    bgSpr1:setPosition(cc.p(self:getContentSize().width/2,self:getContentSize().height/2));
    bgSpr1:setScale9Enabled(true);
    bgSpr1:setCapInsets(cc.rect(30, 25, 1, 1));
    bgSpr1:setSize(cc.size(self:getContentSize().width,49));
    self:addChild(bgSpr1);

    local lineSpr1 = cc.Sprite:createWithSpriteFrameName("MenuDecoration.png");
    lineSpr1:setPosition(cc.p(self:getSize().width/2,self:getSize().height-5));
    self:addChild(lineSpr1,1);

    local lineSpr2 = cc.Sprite:createWithSpriteFrameName("MenuDecoration.png");
    lineSpr2:setPosition(cc.p(self:getSize().width/2,5));
    lineSpr2:setScaleY(-1);
    self:addChild(lineSpr2,1);

    self.btns = {};
    self.icons = {};
    for i=1,3 do
        local layout = ccui.Layout:create();
        layout:setSize(cc.size(self:getContentSize().width, self:getContentSize().height/3));
        layout:setPositionY((i-1)*self:getContentSize().height/3);
        self:addChild(layout);
        layout:setTag(i);
        layout:setTouchEnabled(true);
        layout:addTouchEventListener(handler(self,self.onButtonClick));

        local shieldImg = ccui.ImageView:create("Chat_Shield_icon.png", ccui.TextureResType.plistType);
        shieldImg:setPosition(cc.p(layout:getContentSize().width/4-5,layout:getContentSize().height/2));
        layout:addChild(shieldImg);

        local shieldLabel = cc.Label:createWithTTF("", ttf_msyh, 20);
        shieldLabel:setAnchorPoint(cc.p(0,0.5));
        shieldLabel:setPosition(cc.p(layout:getContentSize().width/2-5,shieldImg:getPositionY()));
        shieldLabel:setColor(cc.c3b(190,170,100));
        layout:addChild(shieldLabel);

        if i == 1 then
            self.shieldImg = shieldImg;
            shieldImg:loadTexture("Chat_Shield_icon.png",ccui.TextureResType.plistType);
            shieldLabel:setString(MG_TEXT("chatLayer_5"));
        elseif i == 2 then
            shieldImg:loadTexture("Chat_Look_icon.png",ccui.TextureResType.plistType);
            shieldLabel:setString(MG_TEXT("chatLayer_6"));
        elseif i == 3 then
            shieldImg:loadTexture("Chat_PrivateChat_icon.png",ccui.TextureResType.plistType);
            shieldLabel:setString(MG_TEXT("chatLayer_7"));
        end

        table.insert(self.btns,layout);
        table.insert(self.icons,{shieldImg=shieldImg,shieldLabel=shieldLabel});
    end
end

function chatTip:setData(data)
    self.data = data;

    self.icons[1].shieldImg:loadTexture("Chat_Shield_icon.png",ccui.TextureResType.plistType);
    self.icons[1].shieldLabel:setString(MG_TEXT("chatLayer_5"));
    self.icons[1].shieldLabel:setPositionX(self.btns[1]:getContentSize().width/2-5);
    for i=1,#_G.CHAT.shields do
        if _G.CHAT.shields[i] == self.data.uid then
            self.icons[1].shieldImg:loadTexture("Chat_Shield_icon_1.png",ccui.TextureResType.plistType);
            self.icons[1].shieldLabel:setString(MG_TEXT("chatLayer_8"));
            self.icons[1].shieldLabel:setPositionX(self.btns[1]:getContentSize().width/2-20);
            break;
        end
    end
end

function chatTip:onButtonClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        if self.delegate and self.delegate.chatTipCallBack then
            self.delegate:chatTipCallBack(sender:getTag());
        end
    end
end

function chatTip:onEnter()

end

function chatTip:onExit()
    MGRCManager:releaseResources("chatTip");
end

function chatTip.create(delegate)
    local layer = chatTip:new()
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

function chatTip.showBox(delegate)
    local layer = chatTip.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_PRIORITY);
    return layer;
end
