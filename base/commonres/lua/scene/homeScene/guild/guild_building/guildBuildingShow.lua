-----------------------公会建设界面------------------------

guildBuildingShow = class("guildBuildingShow", MGLayer)

function guildBuildingShow:ctor()
    self:init();
end

function guildBuildingShow:init()
    local pWidget = MGRCManager:widgetFromJsonFile("guildBuildingShow","GuildBuilding_tip_ui.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:setAnchorPoint(cc.p(0.5, 0.5));
    CommonMethod:setFullBgScale(self.Panel_1);
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));

    local Panel_2 = pWidget:getChildByName("Panel_2");

    self.ListView = Panel_2:getChildByName("ListView");
    self.ListView:setScrollBarVisible(false);

    self.Label_tip = Panel_2:getChildByName("Label_tip");

end

function guildBuildingShow:setData(data)
    self.data = data;

    self.Label_tip:setText(string.format(MG_TEXT("guildBuildingLayer_3"),tonumber(self.data.exp)));
    self.ListView:removeAllItems();
    
    self:creatItem();
end

function guildBuildingShow:creatItem()
    self.ListView:removeAllItems();
    local itemLay = ccui.Layout:create();
    itemLay:setSize(cc.size(self.ListView:getContentSize().width, self.ListView:getContentSize().height));
    if #self.data.reward > 3 then
        itemLay:setSize(cc.size(#self.data.reward*150, self.ListView:getContentSize().height));
    end
    self.ListView:pushBackCustomItem(itemLay);

    self.items = {};
    for i=1,#self.data.reward do
        local item = resItem.create(self);
        item:setData(self.data.reward[i].value1,self.data.reward[i].value2,self.data.reward[i].value3);
        
        itemLay:addChild(item);
        item:setPosition(cc.p(item:getContentSize().width/2+(i-1)*(item:getContentSize().width+20),itemLay:getContentSize().height/2));
        table.insert(self.items,item);
    end

    if #self.items <= 3 and #self.items > 0 then
        local pos = getItemPositionX(self.items,itemLay:getContentSize().width/2,20);
        for i=1,#self.items do
            self.items[i]:setPositionX(pos[i]);
        end
    end
end

function guildBuildingShow:onButtonClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        self:removeFromParent();
    end
end

function guildBuildingShow:onEnter()

end

function guildBuildingShow:onExit()
    MGRCManager:releaseResources("guildBuildingShow");
end

function guildBuildingShow.create(delegate)
    local layer = guildBuildingShow:new()
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

function guildBuildingShow.showBox(delegate)
    local layer = guildBuildingShow.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
