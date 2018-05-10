require "MLLegionItem"

MLLegion = class("MLLegion", MGLayer)

function MLLegion:ctor()

end

function MLLegion:init()
    local pWidget = MGRCManager:widgetFromJsonFile("MLLegion","legion_ui_1.ExportJson");
    self:addChild(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);

    local Panel_1 = pWidget:getChildByName("Panel_1");
    local Panel_2 = pWidget:getChildByName("Panel_2");
    Panel_1:addTouchEventListener(handler(self,self.onButtonClick));
    
    self.ListView = Panel_2:getChildByName("ListView");
    self.ListView:setScrollBarVisible(false);
    -- self.ListView:setItemsMargin(10);

    self.Button_close = Panel_2:getChildByName("Button_close");
    self.Button_close:addTouchEventListener(handler(self,self.onButtonClick));

end

function MLLegion:setData(data)
    self.data = data;

    self.gmList = {};
    self.generalIDs = getefflist(self.data.war.general);
    self.liveGeneralIDs = getefflist(self.data.war.live_general);

    for i=1,#self.generalIDs do
        local isLive = false;
        for j=1,#self.generalIDs do
            if self.generalIDs[i].id == self.liveGeneralIDs[i].id then--武将是否存活
                isLive = true;
                break;
            end
        end
        local gm = GENERAL:getGeneralModel(self.generalIDs[i].id);
        table.insert(self.gmList,{gm=gm,isLive=isLive});
    end

    if #self.gmList <= 0 then
        return;
    end
    self.totalNum = #self.gmList;
    self.queues = {};
    self.queues = newline(self.totalNum,5);

    self.ListView:removeAllItems();
    local itemLay = ccui.Layout:create();
    itemLay:setSize(cc.size(self.ListView:getContentSize().width, self.queues[self.totalNum].row*125));
    self.ListView:pushBackCustomItem(itemLay);
    for i=1,#self.gmList do
        local item = MLLegionItem.create(self);
        item:setData(self.gmList[i]);
        item:setPosition(cc.p(self.queues[i].col*100+4+item:getContentSize().width/2,
                itemLay:getContentSize().height-self.queues[i].row*125+item:getContentSize().height/2+10));
        itemLay:addChild(item);
    end
end

function MLLegion:onButtonClick(sender, eventType)
    if sender == self.Button_close then
        buttonClickScale(sender, eventType);
    end

    if eventType == ccui.TouchEventType.ended then
        self:removeFromParent();
    end
end

function MLLegion:onEnter()

end

function MLLegion:onExit()
    MGRCManager:releaseResources("MLLegion");
end

function MLLegion.create()
    local layer = MLLegion:new()
    layer:init()
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

function MLLegion.showBox()
    local layer = MLLegion.create();
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
