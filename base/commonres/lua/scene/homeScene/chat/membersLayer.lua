-----------------------公会成员界面------------------------

local membersItem = require "membersItem"
membersLayer = class("membersLayer", MGLayer)

function membersLayer:ctor()
    self:init();
end

function membersLayer:init()
    MGRCManager:cacheResource("membersLayer", "mail_selman_title.png");
    local pWidget = MGRCManager:widgetFromJsonFile("membersLayer","union_members_ui.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:setAnchorPoint(cc.p(0.5, 0.5));
    CommonMethod:setFullBgScale(self.Panel_1);
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));

    local Panel_2 = pWidget:getChildByName("Panel_2");

    self.Button_close = Panel_2:getChildByName("Button_close");
    self.Button_close:addTouchEventListener(handler(self,self.onButtonClick));

    self.ListView = Panel_2:getChildByName("ListView");
    self.ListView:setScrollBarVisible(false);

    if not self.itemWidget then
        self.itemWidget = MGRCManager:widgetFromJsonFile("membersLayer", "union_members_item_ui.ExportJson",false);
        self.itemWidget:retain();
    end

end

function membersLayer:setData(data)
    self.data = data;
    self.mem_list = self.data.mem_list or {};
    
    self:creatItem();
end

function membersLayer:creatItem()
    self.ListView:removeAllItems();
    for i=1,#self.mem_list do
        local item = membersItem.create(self,self.itemWidget:clone());
        item:setData(self.mem_list[i]);
        self.ListView:pushBackCustomItem(item);
        self.ListView:setItemsMargin(20);
    end
end

function membersLayer:select(item)
    if self.delegate and self.delegate.select then
        self.delegate:select(item.data.uid,item.data.name);
    end
    self:removeFromParent();
end

function membersLayer:onButtonClick(sender, eventType)
    if sender ~= self.Panel_1 then
        buttonClickScale(sender, eventType);
    end
    if eventType == ccui.TouchEventType.ended then
        self:removeFromParent(self.Panel_2);
    end
end

function membersLayer:onEnter()

end

function membersLayer:onExit()
    MGRCManager:releaseResources("membersLayer");
    if self.itemWidget then
        self.itemWidget:release();
    end
end

function membersLayer.create(delegate)
    local layer = membersLayer:new()
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

function membersLayer.showBox(delegate)
    local layer = membersLayer.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_PRIORITY);
    return layer;
end
