--------------------------维护者之誓( 草船借箭)系统-----------------------

local vindicatorReportItem = require "vindicatorReportItem"
vindicatorReport = class("vindicatorReport", MGLayer)

function vindicatorReport:ctor()

end

function vindicatorReport:init(delegate)
    self.delegate = delegate;
    local pWidget = MGRCManager:widgetFromJsonFile("vindicatorReport","report_ui.ExportJson");
    self:addChild(pWidget);

    local Panel_1 = pWidget:getChildByName("Panel_1");
    Panel_1:setTouchEnabled(false);
    Panel_1:addTouchEventListener(handler(self,self.onButtonClick));

    local Panel_2 = pWidget:getChildByName("Panel_2");
    self.ListView = Panel_2:getChildByName("ListView");
    self.ListView:setItemsMargin(10);
    self.ListView:setScrollBarVisible(false);

    self.Button_close = Panel_2:getChildByName("Button_close");
    self.Button_close:addTouchEventListener(handler(self,self.onButtonClick));

    if not self.itemWidget then
        self.itemWidget = MGRCManager:widgetFromJsonFile("vindicatorReport", "report_item_ui.ExportJson",false);
        self.itemWidget:retain();
    end
end

function vindicatorReport:setData(data)
    self.data = data;

    self.ListView:removeAllItems();
    for i=1,10 do
        local item = vindicatorReportItem.create(self,self.itemWidget:clone());
        item:setData(self.data,i);
        self.ListView:pushBackCustomItem(item);
    end
end

function vindicatorReport:reportItemSelect(item)
    if self.delegate and self.delegate.reportItemSelect then
        self.delegate:reportItemSelect(item);
    end
end

function vindicatorReport:onButtonClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        self:removeFromParent();
    end
end

function vindicatorReport:onEnter()

end

function vindicatorReport:onExit()
    MGRCManager:releaseResources("vindicatorReport");
    if self.itemWidget then
        self.itemWidget:release()
    end
end

function vindicatorReport.create(delegate)
    local layer = vindicatorReport:new()
    layer:init(delegate)
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

function vindicatorReport.showBox(delegate)
    local layer = vindicatorReport.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
