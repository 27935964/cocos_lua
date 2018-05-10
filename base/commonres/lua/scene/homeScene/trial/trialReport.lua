-----------------------试炼战报-----------------
require "arena_record"

local trialReportItem = require "trialReportItem"
trialReport = class("trialReport", MGLayer)

function trialReport:ctor()
    self:init();
end

function trialReport:init()
    MGRCManager:cacheResource("trialReport", "main_ui_big_number.png");
    MGRCManager:cacheResource("trialReport", "trialReport_ui.png","trialReport_ui.plist");
    local pWidget = MGRCManager:widgetFromJsonFile("trialReport","trial_report_ui.ExportJson");
    self:addChild(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));
    self.Panel_1:setAnchorPoint(cc.p(0.5, 0.5));
    CommonMethod:setFullBgScale(self.Panel_1);

    local Panel_2 = pWidget:getChildByName("Panel_2");

    self.ListView_1 = Panel_2:getChildByName("ListView_1");
    self.ListView_1:setItemsMargin(5);
    self.ListView_1:setScrollBarVisible(false);

    self.ListView_2 = Panel_2:getChildByName("ListView_2");--扫荡
    self.ListView_2:setItemsMargin(5);
    self.ListView_2:setScrollBarVisible(false);

    self.Button_close = Panel_2:getChildByName("Button_close");
    self.Button_close:addTouchEventListener(handler(self,self.onButtonClick));

    self.Label_tip1 = Panel_2:getChildByName("Label_tip1");
    self.Label_tip2 = Panel_2:getChildByName("Label_tip2");
    self.Label_tip1:setVisible(false);
    self.Label_tip2:setVisible(false);
    self.Label_tip1:setText(MG_TEXT_COCOS("trial_report_ui_4"));
    self.Label_tip2:setText(MG_TEXT_COCOS("trial_report_ui_5"));

    local Label_capacity = Panel_2:getChildByName("Label_capacity");
    local Label_name = Panel_2:getChildByName("Label_name");
    local Label_capacity2 = Panel_2:getChildByName("Label_capacity2");
    local Label_name2 = Panel_2:getChildByName("Label_name2");
    local Label_tip = Panel_2:getChildByName("Label_tip");

    Label_capacity:setText(MG_TEXT_COCOS("trial_report_ui_1"));
    Label_name:setText(MG_TEXT_COCOS("trial_report_ui_2"));
    Label_capacity2:setText(MG_TEXT_COCOS("trial_report_ui_1"));
    Label_name2:setText(MG_TEXT_COCOS("trial_report_ui_2"));
    Label_tip:setText(MG_TEXT_COCOS("trial_report_ui_3"));

    if not self.itemWidget then
        self.itemWidget = MGRCManager:widgetFromJsonFile("trialReportItem", "trial_report_item_ui.ExportJson",false);
        self.itemWidget:retain();
    end
end

function trialReport:setData(data)
    self.data = data;

    self.ListView_1:removeAllItems();
    self.items_1 = {};
    for i=1,#self.data.max_strategy do
        local item = trialReportItem.create(self,self.itemWidget:clone());
        item:setData(self.data.max_strategy[i],i);
        self.ListView_1:pushBackCustomItem(item);
        table.insert(self.items_1,item);
    end

    self.ListView_2:removeAllItems();
    self.items_2 = {};
    for i=1,#self.data.min_strategy do
        local item = trialReportItem.create(self,self.itemWidget:clone());
        item:setData(self.data.min_strategy[i],i);
        self.ListView_2:pushBackCustomItem(item);
        table.insert(self.items_2,item);
    end

    if #self.data.max_strategy <= 0 then
        self.Label_tip1:setVisible(true);
    end
    if #self.data.min_strategy <= 0 then
        self.Label_tip2:setVisible(true);
    end
end

function trialReport:callBack()
    local arena_record = arena_record.create(self);
    -- arena_record:setData(ackData.logs.log);
    cc.Director:getInstance():getRunningScene():addChild(arena_record,ZORDER_MAX);
end

function trialReport:onButtonClick(sender, eventType)
    if sender ~= self.Panel_1 then
        buttonClickScale(sender, eventType);
    end

    if eventType == ccui.TouchEventType.ended then
        self:removeFromParent();
    end
end

function trialReport:onEnter()

end

function trialReport:onExit()
    MGRCManager:releaseResources("trialReport");
    if self.itemWidget then
        self.itemWidget:release();
    end
end

function trialReport.create(delegate)
    local layer = trialReport:new()
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

function trialReport.showBox(delegate)
    local layer = trialReport.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
