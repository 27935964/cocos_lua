------------------------更换头像界面管理-------------------------

ChangeHeadLayer = class("ChangeHeadLayer", MGLayer)

ChangeHeadLayer.H_c = 5;
function ChangeHeadLayer:ctor()
    self:init();
end

function ChangeHeadLayer:init()
    local pWidget = MGRCManager:widgetFromJsonFile("ChangeHeadLayer","RoleInfoLayer_ui_2.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:addTouchEventListener(handler(self,self.onBackClick));

    local Panel_2 = pWidget:getChildByName("Panel_2");
    self.Button_close = Panel_2:getChildByName("Button_close");
    self.Button_close:addTouchEventListener(handler(self,self.onButtonClick));

    self.ListView = Panel_2:getChildByName("ListView");
    -- self.ListView:setBackGroundColorType(1);
    -- self.ListView:setBackGroundColor(cc.c3b(0,0,250));
end

function ChangeHeadLayer:onBackClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        self:removeFromParent();
    end
end

function ChangeHeadLayer:onButtonClick(sender, eventType)
    if eventType == ccui.TouchEventType.began then
        local sc = cc.ScaleTo:create(0.1, 1.1)
        sender:runAction(cc.EaseOut:create(sc ,2))
    end
    if eventType == ccui.TouchEventType.canceled then
        local sc = cc.ScaleTo:create(0.1, 1)
        sender:runAction(sc)
    end
    if eventType == ccui.TouchEventType.ended then
        local sc = cc.ScaleTo:create(0.1, 1)
        sender:runAction(sc)
        if sender == self.Button_close then
            self:removeFromParent();
        end
    end
end

function ChangeHeadLayer:setData(data)
    self.data = data;

    self.cell_num = #self.data.head;
    self.queues = {};
    self.queues = newline(self.cell_num,5);
    self:createItem();
end

function ChangeHeadLayer:createItem()
    self.ListView:removeAllItems();
    local itemIndex = 1;
    local itemLay = ccui.Layout:create();
    itemLay:setSize(cc.size(self.ListView:getContentSize().width, self.queues[#self.queues].row*130));
    self.ListView:pushBackCustomItem(itemLay);
    local function loadEachItem(dt)
        if itemIndex > #self.queues then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
        else
            local item = userHead.create(self);
            item:setAnchorPoint(cc.p(0, 0));
            item:setPosition(cc.p(10+self.queues[itemIndex].col*130,
                itemLay:getContentSize().height-self.queues[itemIndex].row*130+20));
            itemLay:addChild(item);

            local gm = GENERAL:getAllGeneralModel(self.data.head[itemIndex]);
            item:setData(gm,1);

            itemIndex = itemIndex+1;
        end
    end

    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
    end
    self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(loadEachItem, 0.001, false);
end

function ChangeHeadLayer:HeroHeadSelect(head)
    if self.delegate and self.delegate.HeroHeadSelect then
        self.delegate:HeroHeadSelect(head);
    end
    self:removeFromParent();
end

function ChangeHeadLayer:onEnter()

end

function ChangeHeadLayer:onExit()
    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
    end
    MGRCManager:releaseResources("ChangeHeadLayer");
end

function ChangeHeadLayer.create(delegate)
    local layer = ChangeHeadLayer:new()
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

function ChangeHeadLayer.showBox(delegate)
    local layer = ChangeHeadLayer.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
