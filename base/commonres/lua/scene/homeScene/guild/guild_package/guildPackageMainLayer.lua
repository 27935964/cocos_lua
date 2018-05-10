-----------------------公会仓库主界面------------------------
require "guildPackageLayer"
require "guildPackageGoods"
require "guildPackageMoney"
require "guildPackageLog"
require "guildPackageApprove"

guildPackageMainLayer = class("guildPackageMainLayer", MGLayer)

function guildPackageMainLayer:ctor()
    self.curTag = 1;
    self.curLayer = nil;
    self.curLabel = nil;
    self.myPost = 0;--职位 固定 10会长 9副会长 8精英 0普通成员
    self:init();
end

function guildPackageMainLayer:init()
    MGRCManager:cacheResource("guildPackageMainLayer", "guild_package.png", "guild_package.plist");
    local pWidget = MGRCManager:widgetFromJsonFile("guildPackageMainLayer","guild_package_main_ui.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);

    self.pPanelTop = PanelTop.create(self)
    self.pPanelTop:setData("guild_package_title.png");
    self:addChild(self.pPanelTop,10);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:setAnchorPoint(cc.p(0.5, 0.5));
    CommonMethod:setFullBgScale(self.Panel_1);

    local Panel_2 = pWidget:getChildByName("Panel_2");
    local Panel_left = Panel_2:getChildByName("Panel_left");

    self.btns = {};
    self.posY = {};
    self.names = {};
    for i=1,5 do
        local Panel_btn = Panel_left:getChildByName("Panel_btn"..i);
        Panel_btn:setTag(i);
        Panel_btn:setTouchEnabled(true);
        Panel_btn:addTouchEventListener(handler(self,self.onButtonClick));

        local Label_btn = Panel_btn:getChildByName("Label_btn"..i);
        Label_btn:setText(MG_TEXT_COCOS("guild_package_main_ui_"..i));

        table.insert(self.btns,Panel_btn);
        table.insert(self.posY,Panel_btn:getPositionY()+Panel_btn:getContentSize().height/2);
        table.insert(self.names,Label_btn);
    end
    self.Image_select = Panel_left:getChildByName("Image_select");
    self.curLabel = self.names[1];
    self.curLabel:setColor(cc.c3b(255, 255, 255));
    self:onButtonClick(self.btns[1], ccui.TouchEventType.ended);
end

function guildPackageMainLayer:setData(data)
    self.guildInfo = data;
    if tonumber(self.guildInfo.my_post) < 9 then
        self.btns[#self.btns]:setTouchEnabled(false);
        self.btns[#self.btns]:setVisible(false);
    end
end

function guildPackageMainLayer:back()
    self:removeFromParent();
end

function guildPackageMainLayer:getGuildInfo()
    return self.guildInfo;
end

function guildPackageMainLayer:onButtonClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        if self.curTag == sender:getTag() and self.curLayer then
            return;
        end

        if self.curLayer then
            self.curLayer:removeFromParent();
            self.curLayer = nil;
        end

        if sender:getTag() == 1 then--公会仓库
            self.curLayer = guildPackageLayer.create(self);
        elseif sender:getTag() == 2 then--捐献资金
            self.curLayer = guildPackageMoney.create(self);
        elseif sender:getTag() == 3 then--捐献物品
            self.curLayer = guildPackageGoods.create(self);
        elseif sender:getTag() == 4 then--捐献日志
            self.curLayer = guildPackageLog.create(self);
        elseif sender:getTag() == 5 then--审批
            self.curLayer = guildPackageApprove.create(self);
        end
        if self.curLayer then
            self:addChild(self.curLayer,5);
        end
        
        self.Image_select:setPositionY(self.posY[sender:getTag()]);
        self.curTag = sender:getTag();
        self.curLabel:setColor(cc.c3b(130, 130, 111));
        self.names[sender:getTag()]:setColor(cc.c3b(255, 255, 255));
        self.curLabel = self.names[sender:getTag()];
    end
end

function guildPackageMainLayer:onEnter()

end

function guildPackageMainLayer:onExit()
    MGRCManager:releaseResources("guildPackageMainLayer");
end

function guildPackageMainLayer.create(delegate,type)
    local layer = guildPackageMainLayer:new()
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

function guildPackageMainLayer.showBox(delegate,type)
    local layer = guildPackageMainLayer.create(delegate,type);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
