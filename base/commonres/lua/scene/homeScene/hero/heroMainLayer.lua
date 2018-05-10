-----------------------英雄界面------------------------
require "PanelTop"
require "heroBottom"
require "heroAttLayer"
require "treasureLayer"
require "heroStarLayer"
require "heroFeaturesLayer"
require "heroCommunication"

heroMainLayer = class("heroMainLayer", MGLayer)

function heroMainLayer:ctor()
    self.curpanel  = nil;
    self.gm = nil;
end

function heroMainLayer:init()
    MGRCManager:cacheResource("heroMainLayer", "package_bg.jpg");
    MGRCManager:cacheResource("heroMainLayer", "general_pic_1.png");
    MGRCManager:cacheResource("heroMainLayer", "heroAttLayer_ui0.png","heroAttLayer_ui0.plist");

    local size = cc.Director:getInstance():getWinSize();
    local bgSpr = cc.Sprite:create("package_bg.jpg");
    bgSpr:setPosition(cc.p(size.width/2, size.height/2));
    self:addChild(bgSpr);
    CommonMethod:setFullBgScale(bgSpr);

    self.pPanelTop = PanelTop.create(self)
    self.pPanelTop:setData("hero_title.png");
    self:addChild(self.pPanelTop,10);

    self.kind = 1;
    self:getpanel();

    local pheroBottom = heroBottom.create(self,self.gm)
    self:addChild(pheroBottom,10);
    NetHandler:sendData(Post_General_getTreasure, "");
end

function heroMainLayer:getpanel()
    if self.curpanel~=nil then
        self.curpanel:removeFromParent();
        self.curpanel = nil;
    end
    if self.kind == 1 then--属性
        self.curpanel = heroAttLayer.create(self);
    elseif self.kind == 2 then--特性
        self.curpanel =  heroFeaturesLayer.create(self);
    elseif self.kind == 3 then--升星
        self.curpanel = heroStarLayer.create(self);
    elseif self.kind == 4 then--情义
        self.curpanel = heroCommunication.create(self);
    elseif self.kind == 5 then--宝物
        self.curpanel = treasureLayer.create(self);
    elseif self.kind == 6 then--天赋
        ---self.curpanel =  
    elseif self.kind == 7 then--神器
        ---self.curpanel =  
    end
    if self.curpanel~=nil then 
        self:addChild(self.curpanel,1);
        if  self.gm and self.curpanel.setData then
            self.curpanel:setData(self.gm);
        end
    end
end

function heroMainLayer:upData()
    self.pPanelTop:upData()
end

function heroMainLayer:back()
    -- enterLuaLayer(self.type,1,dwParm3,dwParm4,dwParm5);
    if self.delegate and self.delegate.upData then
        self.delegate:upData();
    end
    self:removeFromParent();
end

function heroMainLayer:changeHero(gm)
    self.gm = gm;
    if  self.curpanel and self.curpanel.setData then
        self.curpanel:setData(gm);
    end
end

function heroMainLayer:changeKind(kind)
    if kind~=self.kind then
        self.kind  = kind;
        print(kind);
        self:getpanel();
    end
end

function heroMainLayer:onEnter()
end

function heroMainLayer:onExit()
    MGRCManager:releaseResources("heroMainLayer");
end

function heroMainLayer.create(delegate,type,gm)
    local layer = heroMainLayer:new()
    layer.delegate = delegate
    layer.type = type
    layer.gm = gm
    layer:init();
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

function heroMainLayer.showBox(delegate,type,gm)
    local layer = heroMainLayer.create(delegate,type,gm);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
