
mailSelItem = class("mailSelItem", function()
    return ccui.Layout:create();
end)

function mailSelItem:ctor()
    self:init();
end

function mailSelItem:init()
    --背景
    self:setTouchEnabled(true);
    self:addTouchEventListener(handler(self,self.onBtnClick));
    self:setSize(cc.size(546,117));

    --头像
    self.Image_line = ccui.ImageView:create();
    self.Image_line:loadTexture("common_three_box.png",ccui.TextureResType.plistType);
    self.Image_line:setPosition(cc.p(273, 57));
    self.Image_line:setScale9Enabled(true);
    self.Image_line:setCapInsets(cc.rect(5, 5, 1, 1));
    self.Image_line:setSize(cc.size(536, 109));
    self:addChild(self.Image_line);

    
    self.nameLabel = cc.Label:createWithTTF("名字", ttf_msyh, 22);
    self.nameLabel:setAnchorPoint(cc.p(0, 0.5));
    self.nameLabel:setPosition(cc.p(128, 61));
    self:addChild(self.nameLabel,1);
    self.nameLabel:setColor(cc.c3b(222,198,114));

    self.workLabel = cc.Label:createWithTTF("职业", ttf_msyh, 22);
    self.workLabel:setAnchorPoint(cc.p(1, 0.5));
    self.workLabel:setPosition(cc.p(527, 61));
    self:addChild(self.workLabel,1);

    require "userHead";
    self.heroHead = userHead.create(self);
    self.heroHead:setTouchEnabled(false);
    self.heroHead:setAnchorPoint(cc.p(0.5, 0.5));
    self.heroHead:setPosition(cc.p(58, 59));
    self:addChild(self.heroHead,1);
end

function mailSelItem:setData(info)
    self.info = info;
    self.nameLabel:setString(self.info);

end

function mailSelItem:onBtnClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        if self.delegate and self.delegate.mailSelItemSelect then
            self.delegate:mailSelItemSelect(self.info);
        end
    end
end

function mailSelItem:onEnter()

end

function mailSelItem:onExit()
    MGRCManager:releaseResources("mailSelItem")
end

function mailSelItem.create(delegate)
    local layer = mailSelItem:new()
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
