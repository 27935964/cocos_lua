-----------------------公会创建申请界面------------------------
require "guildCreateLayer"
require "guildApplyLayer"

guildLayer = class("guildLayer", MGLayer)

function guildLayer:ctor()
    self:init();
end

function guildLayer:init()
    MGRCManager:cacheResource("guildLayer", "guild_watch_head.png");
    MGRCManager:cacheResource("guildLayer", "guild_flag.png", "guild_flag.plist");
    MGRCManager:cacheResource("guildLayer", "guild_ui.png", "guild_ui.plist");
    local pWidget = MGRCManager:widgetFromJsonFile("guildLayer","guild_ui.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:setAnchorPoint(cc.p(0.5, 0.5));
    CommonMethod:setFullBgScale(self.Panel_1);
    self.Panel_1:addTouchEventListener(handler(self,self.onExitClick));

    local Panel_2 = pWidget:getChildByName("Panel_2");
    self.Panel_2 = Panel_2;

    self.Button_create = Panel_2:getChildByName("Button_create");
    self.Button_create:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_add = Panel_2:getChildByName("Button_add");
    self.Button_add:addTouchEventListener(handler(self,self.onButtonClick));

    local Image_privilege1 = Panel_2:getChildByName("Image_privilege1");
    local Label_desc1 = Image_privilege1:getChildByName("Label_desc1");
    local Label_title1 = Image_privilege1:getChildByName("Label_title1");

    local Image_privilege2 = Panel_2:getChildByName("Image_privilege2");
    local Label_desc2 = Image_privilege2:getChildByName("Label_desc2");
    local Label_title2 = Image_privilege2:getChildByName("Label_title2");

    local Image_privilege3 = Panel_2:getChildByName("Image_privilege3");
    local Label_desc3 = Image_privilege3:getChildByName("Label_desc3");
    local Label_title3 = Image_privilege3:getChildByName("Label_title3");
    
    Label_title1:setText(MG_TEXT_COCOS("guild_ui_1"));
    Label_title2:setText(MG_TEXT_COCOS("guild_ui_2"));
    Label_title3:setText(MG_TEXT_COCOS("guild_ui_3"));
end

function guildLayer:onButtonClick(sender, eventType)

    if eventType == ccui.TouchEventType.began then
        if self.btnSpr==nil then
            self.btnSpr = cc.Sprite:create();
            self.Panel_2:addChild(self.btnSpr,3);
            self.btnSpr:setShaderProgram(MGGraySprite:getLightShaderProgram(3));
        end

        if sender == self.Button_create then
            self.btnSpr:setSpriteFrame("guild_create.png");
            self.btnSpr:setPosition(self.Button_create:getPosition());
        elseif sender == self.Button_add then
            self.btnSpr:setSpriteFrame("guild_add.png");
            self.btnSpr:setPosition(self.Button_add:getPosition());
        end
    end
    if eventType == ccui.TouchEventType.canceled then
        if self.btnSpr then
            self.btnSpr:removeFromParent();
            self.btnSpr = nil;
        end
    end
    if eventType == ccui.TouchEventType.ended then
        if self.btnSpr then
            self.btnSpr:removeFromParent();
            self.btnSpr = nil;
        end

        if sender == self.Button_create then
            local guildCreateLayer = guildCreateLayer.showBox(self,self.scenetype);
            guildCreateLayer:setData(1);
        elseif sender == self.Button_add then
            local guildApplyLayer = guildApplyLayer.showBox(self);
        end
    end
end

function guildLayer:onExitClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        self:removeFromParent();
    end
end

function guildCreateLayer:remove()
    if self.delegate and self.delegate.createGuildMainLayer then
        self.delegate:createGuildMainLayer();
    end
    self:removeFromParent();
end

function guildLayer:onEnter()

end

function guildLayer:onExit()
    MGRCManager:releaseResources("guildLayer");
end

function guildLayer.create(delegate,type)
    local layer = guildLayer:new()
    layer.delegate = delegate
    layer.scenetype = type
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

function guildLayer.showBox(delegate,type)
    local layer = guildLayer.create(delegate,type);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
