
rankleftItem = class("rankleftItem", function()
    return ccui.Layout:create();
end)

function rankleftItem:ctor()
    self:init();
end

function rankleftItem:init()
    --背景
    self:setTouchEnabled(true);
    self:addTouchEventListener(handler(self,self.onBtnClick));
    self:setSize(cc.size(210,74));

    --头像
    self.Image_line = ccui.ImageView:create();
    self.Image_line:loadTexture("com_left_line3.png",ccui.TextureResType.plistType);
    self.Image_line:setPosition(cc.p(self:getContentSize().width/2, 0));
    self.Image_line:setScale9Enabled(true);
    self.Image_line:setCapInsets(cc.rect(5, 1, 1, 1));
    self.Image_line:setSize(cc.size(210, 3));
    self:addChild(self.Image_line);

    self.boxSpr = cc.Sprite:createWithSpriteFrameName("com_page_select.png");
    self.boxSpr:setPosition(cc.p(self:getContentSize().width/2, self:getContentSize().height/2));
    self:addChild(self.boxSpr);
    self.boxSpr:setVisible(false);
    
    self.nameLabel = cc.Label:createWithTTF("hahhah", ttf_msyh, 27);
    self.nameLabel:setPosition(cc.p(105, self:getContentSize().height/2));
    self:addChild(self.nameLabel,1);
    self.nameLabel:setColor(cc.c3b(130,130,111));
end

function rankleftItem:setData(info)
    self.info = info;
    self.nameLabel:setString(self.info.name);
end

function rankleftItem:Select(bdhow)
    if bdhow then
        self.boxSpr:setVisible(true);
        self.nameLabel:setColor(cc.c3b(255,255,255));
    else
        self.boxSpr:setVisible(false);
        self.nameLabel:setColor(cc.c3b(130,130,111));
    end
end

function rankleftItem:onBtnClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        if self.delegate and self.delegate.rankleftItemSelect then
            self.delegate:rankleftItemSelect(self);
        end
    end
end

function rankleftItem:onEnter()

end

function rankleftItem:onExit()
    MGRCManager:releaseResources("rankleftItem")
end

function rankleftItem.create(delegate)
    local layer = rankleftItem:new()
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
