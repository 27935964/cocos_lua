-----------------------公会驻扎英雄界面------------------------
require "Item"

local guildStationedItem = require "guildStationedItem"
guildStationedLayer = class("guildStationedLayer", MGLayer)

function guildStationedLayer:ctor()
    self.curItem = nil;
    self:init();
end

function guildStationedLayer:init()
    local pWidget = MGRCManager:widgetFromJsonFile("guildStationedLayer","guild_stationed_ui.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:setAnchorPoint(cc.p(0.5, 0.5));
    CommonMethod:setFullBgScale(self.Panel_1);
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));

    local Panel_2 = pWidget:getChildByName("Panel_2");

    self.ListView = Panel_2:getChildByName("ListView_14");
    self.ListView:setScrollBarVisible(false);
    self.ListView:setItemsMargin(90);

    local Label_tip = Panel_2:getChildByName("Label_tip");
    -- Label_tip:setText(MG_TEXT_COCOS("guild_mercenary_ui_1"));

    self.Button_ok = Panel_2:getChildByName("Button_ok");
    self.Button_ok:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_close = Panel_2:getChildByName("Button_close");
    self.Button_close:addTouchEventListener(handler(self,self.onButtonClick));

    local Label_ok = self.Button_ok:getChildByName("Label_ok");
    Label_ok:setText(MG_TEXT_COCOS("guild_stationed_ui_1"));

    local sql = string.format("select value from config where id=113");
    local DBData = LUADB.select(sql, "value");
    local h = tonumber(DBData.info.value)/24/24;
    Label_tip:setText(string.format(MG_TEXT("guildStationedLayer_1"),h));
end

function guildStationedLayer:setData(id,g_ids)
    self.id = id;
    self.g_ids = g_ids;--已驻扎的佣兵ID

    self.gmList = {};
    self.gmList = GENERAL:getGeneralList();
    for i=1,#self.g_ids do
        for j=1,#self.gmList do
            if self.g_ids[i] == self.gmList[j]:getId() then
                table.remove(self.gmList,j);
                break;
            end
        end
    end
    
    table.sort(self.gmList,function(gm1,gm2)
        if gm1:getStar()  == gm2:getStar() and gm1:getQuality() == gm1:getQuality() then
            return gm1:getWarScore() > gm2:getWarScore();
        end

        if gm1:getStar()  == gm2:getStar() then
            return gm1:getQuality() > gm2:getQuality();
        end

        return gm1:getStar() > gm2:getStar();
    end)

    self:createListItem();
end

function guildStationedLayer:createListItem()
    self.ListView:removeAllItems();
    self.items = {};
    self.totalNum = #self.gmList;
    if self.totalNum <= 0 then
        return;
    end

    self.queues = {};
    self.queues = newline(self.totalNum,5);

    local itemIndex = 1;
    local itemLay = ccui.Layout:create();
    itemLay:setSize(cc.size(self.ListView:getContentSize().width, self.queues[self.totalNum].row*185));
    self.ListView:pushBackCustomItem(itemLay);

    local function loadEachItem(dt)
        if itemIndex > self.totalNum then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
        else
            local item = guildStationedItem.create(self);
            item:setTag(itemIndex);
            item:setData(self.gmList[itemIndex]);
            item:setPosition(cc.p(self.queues[itemIndex].col*180+20+item:getContentSize().width/2,
                itemLay:getContentSize().height-self.queues[itemIndex].row*185+item:getContentSize().height/2+20));
            itemLay:addChild(item);
            table.insert(self.items,item);

            if itemIndex == 1 then
                self.curItem = item:getItem();
                self.curItem:setSel(true);
            end

            itemIndex = itemIndex+1;
        end
    end

    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
    end
    self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(loadEachItem, 0.001, false);
end

function guildStationedLayer:onButtonClick(sender, eventType)
    if sender ~= self.Panel_1 then
        buttonClickScale(sender, eventType);
    end
    
    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_ok then
            if self.delegate and self.delegate.sendDoStationReq then
                self.delegate:sendDoStationReq(self.id,self.curItem.gm:getId());
                self:removeFromParent();
            end
        else
            self:removeFromParent();
        end
    end
end

function guildStationedLayer:HeroHeadSelect(item)
    if self.curItem then
        if self.curItem == item then
            return;
        end
        self.curItem:setSel(false);
    end
    self.curItem = item;
    item:setSel(true);
end

function guildStationedLayer:onEnter()

end

function guildStationedLayer:onExit()
    MGRCManager:releaseResources("guildStationedLayer");
    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
    end
end

function guildStationedLayer.create(delegate,type)
    local layer = guildStationedLayer:new()
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

function guildStationedLayer.showBox(delegate,type)
    local layer = guildStationedLayer.create(delegate,type);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
