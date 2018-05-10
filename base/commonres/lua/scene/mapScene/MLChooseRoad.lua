require "MLChooseRoadItem"

MLChooseRoad = class("MLChooseRoad", MGLayer)

function MLChooseRoad:ctor()
    self.roadDatas = {};
    self:init();
end

function MLChooseRoad:init()
    MGRCManager:cacheResource("MLChooseRoad", "checkpoint_choose_bg.png");
    local pWidget = MGRCManager:widgetFromJsonFile("MLChooseRoad","checkpoint_choose_road_ui_2.ExportJson");
    self:addChild(pWidget);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:addTouchEventListener(handler(self,self.onBackClick));

    local Panel_2 = pWidget:getChildByName("Panel_2");
    self.Panel_btn = Panel_2:getChildByName("Panel_btn");

end

function MLChooseRoad:setData(checkpointList,curCityId,tablePassMark)
    self.checkpointList = checkpointList;
    self.next = self.checkpointList[curCityId].next;
    self.items = {};

    for i=1,#self.next do
        self.next[i].x = self.checkpointList[self.next[i].nextId].pos.x;
    end
    table.sort(self.next,function (a,b) return a.x < b.x; end)

    for i=1,#self.next do
        local isShow = true;
        for j=1,#tablePassMark do
            if curCityId == tablePassMark[j].curCityId and self.next[i].nextId == tablePassMark[j].nextCityId then
                isShow = not tablePassMark[j].isPass;
                break;
            end
        end
        local item = MLChooseRoadItem.create(self);
        item:setAnchorPoint(cc.p(0.5,0.5));
        item:setPosition(cc.p(self.Panel_btn:getContentSize().width/2-item:getContentSize().width/2,0));
        item:setData(checkpointList,self.next[i],i,isShow);
        self.Panel_btn:addChild(item);
        table.insert(self.items,item);
    end

    local width = self.Panel_btn:getContentSize().width/2-self.items[1]:getContentSize().width/2;
    if #self.items == 2 then
        self.items[1]:setPosition(cc.p(width-self.items[1]:getContentSize().width,0));
        self.items[2]:setPosition(cc.p(width+self.items[1]:getContentSize().width,0));
    elseif #self.items == 3 then
        self.items[1]:setPosition(cc.p(width-self.items[1]:getContentSize().width*2,0));
        self.items[2]:setPosition(cc.p(width,0));
        self.items[3]:setPosition(cc.p(width+self.items[1]:getContentSize().width*2,0));
    elseif #self.items == 4 then
        self.items[1]:setPosition(cc.p(width-self.items[1]:getContentSize().width/4*10,0));
        self.items[2]:setPosition(cc.p(width-self.items[1]:getContentSize().width/8*7+7,0));
        self.items[3]:setPosition(cc.p(width+self.items[1]:getContentSize().width/8*7-7,0));
        self.items[4]:setPosition(cc.p(width+self.items[1]:getContentSize().width/4*10,0));
    end
end

function MLChooseRoad:runAction(nextId)
    if self.delegate and self.delegate.setNextCityId then
        self.delegate:setNextCityId(nextId);
        self:removeFromParent();
    end
end

function MLChooseRoad:onBackClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        self:removeFromParent();
    end
end

function MLChooseRoad:onEnter()
    
end

function MLChooseRoad:onExit()
    MGRCManager:releaseResources("MLChooseRoad")
end

function MLChooseRoad.create(delegate)
    local layer = MLChooseRoad:new()
    layer.delegate = delegate;
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

function MLChooseRoad.showBox(delegate)
    local layer = MLChooseRoad.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
