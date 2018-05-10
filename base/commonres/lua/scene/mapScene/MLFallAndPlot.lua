require "Item"

MLFallAndPlot = class("MLFallAndPlot", MGLayer)

function MLFallAndPlot:ctor()

end

function MLFallAndPlot:init()
    local pWidget = MGRCManager:widgetFromJsonFile("MLFallAndPlot","reward_ui_1.ExportJson");
    self:addChild(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);

    local Panel_1 = pWidget:getChildByName("Panel_1");
    local Panel_2 = pWidget:getChildByName("Panel_2");
    Panel_1:addTouchEventListener(handler(self,self.onButtonClick));

    local Panel_desc = Panel_2:getChildByName("Panel_desc");

    self.descLabel = cc.Label:createWithTTF("",ttf_msyh,22);
    self.descLabel:setAlignment(cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_TOP);
    self.descLabel:setDimensions(485, 0);
    self.descLabel:setAnchorPoint(cc.p(0, 1));
    self.descLabel:setPosition(cc.p(10,Panel_desc:getContentSize().height));
    Panel_desc:addChild(self.descLabel);
    
    self.ListView = Panel_2:getChildByName("ListView");
    self.ListView:setScrollBarVisible(false);
    self.ListView:setItemsMargin(10);

    self.Button_close = Panel_2:getChildByName("Button_close");
    self.Button_close:addTouchEventListener(handler(self,self.onButtonClick));

end

function MLFallAndPlot:setData(checkpointId)
    local sql = string.format("select * from stage_list where id=%d", checkpointId);
    local DBData = LUADB.select(sql, "id:desc:reward_show");

    self.DBDatas = {};
    local str = "";
    local str_list = {};
    local str_list1 = {};
    self.DBDatas.id = DBData.info.id;
    self.DBDatas.desc = DBData.info.desc;
    self.DBDatas.reward_show = {};
    str = DBData.info.reward_show;
    if tonumber(str) == 0 then
        self.DBDatas.reward_show = 0;
    else
        str_list = spliteStr(str,'|');
        for i=1,#str_list do
            self.DBDatas.reward_show[i] = {};
            if tonumber(str_list[i]) == 0 then
                self.DBDatas.reward_show[i].type = 0;
                self.DBDatas.reward_show[i].Id = 0;
            else
                str_list1 = {};
                str_list1 = spliteStr(str_list[i],':');
                self.DBDatas.reward_show[i].type = tonumber(str_list1[1]);
                self.DBDatas.reward_show[i].Id = tonumber(str_list1[2]);
            end
        end
    end
    self.descLabel:setString(self.DBDatas.desc);

    self.ListView:removeAllItems();
    for i=1,#self.DBDatas.reward_show do
        local item = resItem.create(self);
        item:setData(self.DBDatas.reward_show[i].type,self.DBDatas.reward_show[i].Id);
        item:setNumVisible(false);
        -- item:setShowTip(false);
        self.ListView:pushBackCustomItem(item);
    end
end

function MLFallAndPlot:onButtonClick(sender, eventType)
    if sender == self.Button_close then
        buttonClickScale(sender, eventType);
    end

    if eventType == ccui.TouchEventType.ended then
        self:removeFromParent();
    end
end

function MLFallAndPlot:onEnter()

end

function MLFallAndPlot:onExit()
    MGRCManager:releaseResources("MLFallAndPlot");
end

function MLFallAndPlot.create()
    local layer = MLFallAndPlot:new()
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

function MLFallAndPlot.showBox()
    local layer = MLFallAndPlot.create();
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
