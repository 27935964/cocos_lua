----------------------帮助界面------------------------

local helpItem = require "helpItem"
local helpInfo = require "helpInfo";
help = class("help", MGLayer)

function help:ctor()
    self.curTag = 1;
    self:init();
end

function help:init()
    MGRCManager:cacheResource("help", "package_bg.jpg");
    MGRCManager:cacheResource("help", "help_ui.png", "help_ui.plist");
    MGRCManager:cacheResource("help", "rule_ui0.png", "rule_ui0.plist");
    local pWidget = MGRCManager:widgetFromJsonFile("help","help_ui.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:setAnchorPoint(cc.p(0.5, 0.5));
    CommonMethod:setFullBgScale(self.Panel_1);

    local Panel_2 = pWidget:getChildByName("Panel_2");

    self.Button_close = Panel_2:getChildByName("Button_close");
    self.Button_close:addTouchEventListener(handler(self,self.onButtonClick));

    self.ListView = Panel_2:getChildByName("ListView");
    self.ListView:setScrollBarVisible(false);

    self.ListView_btn = Panel_2:getChildByName("ListView_btn");
    self.ListView_btn:setScrollBarVisible(false);

    self.itemWidgets = {};
    self.btnInfo = {};
    for i=1,#helpInfo do
        local item = self:createBtn(i);
        self.ListView_btn:pushBackCustomItem(item);

        -- if not self.itemWidget[i] then
        --     self.itemWidget[i] = MGRCManager:widgetFromJsonFile("help", helpInfo[i].exportJson,false);
        --     self.itemWidget[i]:retain();
        --     table.insert(self.itemWidgets,self.itemWidget[i]);
        -- end
    end

    if not self.itemWidgets[1] then
        self.itemWidgets[1] = MGRCManager:widgetFromJsonFile("help", helpInfo[1].exportJson,false);
        self.itemWidgets[1]:retain();
        table.insert(self.itemWidgets,self.itemWidgets[1]);
    end

    self:createItem(1);

end

function help:createItem(i)
    if not self.itemWidgets[i] then
        self.itemWidgets[i] = MGRCManager:widgetFromJsonFile("help", helpInfo[i].exportJson,false);
        self.itemWidgets[i]:retain();
        table.insert(self.itemWidgets,self.itemWidgets[i]);
    end

    self.ListView:removeAllItems();
    local item = helpItem.create(self,self.itemWidgets[i]:clone(),helpInfo[i]);
    self.ListView:pushBackCustomItem(item);
end

function help:createBtn(i)
    local layout = ccui.Layout:create();
    layout:setAnchorPoint(cc.p(0.5,0.5));
    layout:setTag(i);
    layout:setSize(cc.size(self.ListView_btn:getContentSize().width, 80));
    layout:setTouchEnabled(true);
    layout:addTouchEventListener(handler(self,self.onButtonClick));

    -- layout:setBackGroundColorType(1);
    -- layout:setBackGroundColor(cc.c3b(0,255,250));

    --底线
    local lineImg = ccui.ImageView:create("com_login_line.png", ccui.TextureResType.plistType);
    lineImg:setPosition(cc.p(layout:getContentSize().width/2, 0));
    lineImg:setScale9Enabled(true);
    lineImg:setCapInsets(cc.rect(15, 1, 1, 1));
    lineImg:setSize(cc.size(210, 2));
    layout:addChild(lineImg,1);

    local btnLabel = cc.Label:createWithTTF(helpInfo[i].name, ttf_msyh, 22);
    btnLabel:setPosition(cc.p(layout:getContentSize().width/2,layout:getContentSize().height/2));
    btnLabel:setColor(cc.c3b(130, 130, 111));
    layout:addChild(btnLabel);

    table.insert(self.btnInfo,{btn=layout,btnLabel=btnLabel});
    self.btnInfo[1].btnLabel:setColor(cc.c3b(255, 255, 255));

    return layout;
end

function help:onButtonClick(sender, eventType)
    if sender == self.Button_close then 
        buttonClickScale(sender, eventType);
    end
    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_close then
            self:removeFromParent();
        else
            if sender:getTag() == self.curTag then
                return;
            end

            self.btnInfo[sender:getTag()].btnLabel:setColor(cc.c3b(255, 255, 255));
            self.btnInfo[self.curTag].btnLabel:setColor(cc.c3b(130, 130, 111));
            self.curTag = sender:getTag();
            self:createItem(sender:getTag());
        end
    end
end

function help:onEnter()
    NetHandler:sendData(Post_union_main, "");
end

function help:onExit()
    MGRCManager:releaseResources("help");
end

function help.create(delegate)
    local layer = help:new()
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

function help.showBox(delegate)
    local layer = help.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
