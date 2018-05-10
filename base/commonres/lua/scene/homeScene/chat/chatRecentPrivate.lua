-----------------------最近私聊界面------------------------

chatRecentPrivate = class("chatRecentPrivate",function()  
    return ccui.Layout:create();
end)

function chatRecentPrivate:ctor()
    self:init();
end

function chatRecentPrivate:init()
    self:setSize(cc.size(180, 145));
    self:setAnchorPoint(cc.p(0.5,0));

    --背景
    local bgSpr = ccui.ImageView:create("Chat_reproduction.png", ccui.TextureResType.plistType);
    bgSpr:setPosition(cc.p(self:getContentSize().width/2,self:getContentSize().height/2));
    bgSpr:setScale9Enabled(true);
    bgSpr:setCapInsets(cc.rect(62, 27, 1, 1));
    bgSpr:setSize(cc.size(self:getContentSize().width,self:getContentSize().height));
    self:addChild(bgSpr);

    local lineSpr1 = cc.Sprite:createWithSpriteFrameName("MenuDecoration.png");
    lineSpr1:setPosition(cc.p(self:getSize().width/2,self:getSize().height-5));
    self:addChild(lineSpr1,1);

    local lineSpr2 = cc.Sprite:createWithSpriteFrameName("MenuDecoration.png");
    lineSpr2:setPosition(cc.p(self:getSize().width/2,5));
    lineSpr2:setScaleY(-1);
    self:addChild(lineSpr2,1);

    --创建ListView
    self.ListView = ccui.ListView:create();
    self.ListView:setDirection(ccui.ScrollViewDir.vertical);
    self.ListView:setBounceEnabled(false);
    self.ListView:setAnchorPoint(cc.p(0.5,0.5));
    self.ListView:setSize(cc.size(self:getContentSize().width, self:getContentSize().height));
    self.ListView:setScrollBarVisible(false);--true添加滚动条
    self.ListView:setPosition(cc.p(self:getContentSize().width/2, self:getContentSize().height/2));
    self:addChild(self.ListView);
end

function chatRecentPrivate:setData()
    self.data = _G.CHAT.recentPri or {};
    if 0 == #self.data then
        return ;
    end

    local num = 3;
    if #self.data > 3 then
        num = #self.data;
    end
    self.ListView:removeAllItems();
    for i=1,num do
        local item = self:createItem(i);
        self.ListView:pushBackCustomItem(item);
    end 
end

function chatRecentPrivate:createItem(i)
    local layout = ccui.Layout:create();
    layout:setSize(cc.size(self.ListView:getContentSize().width, self.ListView:getContentSize().height/3));
    layout:setTag(i);
    layout:setTouchEnabled(true);
    layout:addTouchEventListener(handler(self,self.onButtonClick));

    if 1 == math.mod(i,2) then
        local bgSpr1 = ccui.ImageView:create("Chat_stripes.png", ccui.TextureResType.plistType);
        bgSpr1:setPosition(cc.p(self:getContentSize().width/2,self:getContentSize().height/2));
        bgSpr1:setScale9Enabled(true);
        bgSpr1:setCapInsets(cc.rect(30, 25, 1, 1));
        bgSpr1:setSize(cc.size(layout:getContentSize().width,layout:getContentSize().height));
        layout:addChild(bgSpr1);
    end

    local nameLabel = cc.Label:createWithTTF("", ttf_msyh, 22);
    nameLabel:setPosition(cc.p(layout:getContentSize().width/2,layout:getContentSize().height/2));
    -- nameLabel:setColor(cc.c3b(190,170,100));
    layout:addChild(nameLabel);

    if i <= #self.data then
        local att = spliteStr(self.data[i].att,':');
        nameLabel:setString(att[2]);
    end

    return layout;
end

function chatRecentPrivate:onButtonClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        if self.delegate and self.delegate.chatRecentPrivateCallBack then
            local att = spliteStr(self.data[sender:getTag()].att,':');
            self.delegate:chatRecentPrivateCallBack(self.data[sender:getTag()].uid,att[2]);
        end
    end
end

function chatRecentPrivate:onEnter()

end

function chatRecentPrivate:onExit()
    MGRCManager:releaseResources("chatRecentPrivate");
end

function chatRecentPrivate.create(delegate)
    local layer = chatRecentPrivate:new()
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

function chatRecentPrivate.showBox(delegate)
    local layer = chatRecentPrivate.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_PRIORITY);
    return layer;
end
