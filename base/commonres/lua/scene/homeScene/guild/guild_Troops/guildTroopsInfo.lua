-----------------------公会攻城部队信息-----------------
require "userHead"

guildTroopsInfo = class("guildTroopsInfo", MGLayer)

function guildTroopsInfo:ctor()
    self:init();
end

function guildTroopsInfo:init()
    -- MGRCManager:cacheResource("guildTroopsInfo", "HemitIsland_defensive_lineup.png");
    local pWidget = MGRCManager:widgetFromJsonFile("guildTroopsInfo","SiegeTroops_info_ui.ExportJson");
    self:addChild(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));
    self.Panel_1:setAnchorPoint(cc.p(0.5, 0.5));
    CommonMethod:setFullBgScale(self.Panel_1);

    local Panel_2 = pWidget:getChildByName("Panel_2");

    self.ListView = Panel_2:getChildByName("ListView");
    -- self.ListView:setItemsMargin(5);
    self.ListView:setScrollBarVisible(false);

    self.Button_close = Panel_2:getChildByName("Button_close");
    self.Button_close:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_retreat = Panel_2:getChildByName("Button_retreat");--撤军
    self.Button_retreat:addTouchEventListener(handler(self,self.onButtonClick));
    self.Button_retreat:setEnabled(false);

    self.Label_name = Panel_2:getChildByName("Label_Name");
    self.Label_Level_num = Panel_2:getChildByName("Label_Level_num");
    self.Label_CE_num = Panel_2:getChildByName("Label_CE_num");
    self.Label_GuildName = Panel_2:getChildByName("Label_GuildName");

    local Panel_head = Panel_2:getChildByName("Panel_Head");
    self.heroHead = userHead.create(self);
    self.heroHead:setAnchorPoint(cc.p(0.5, 0.5));
    self.heroHead:setPosition(cc.p(Panel_head:getContentSize().width/2,Panel_head:getContentSize().height/2));
    Panel_head:addChild(self.heroHead,2);

    local Label_Level = Panel_2:getChildByName("Label_Level");
    local Label_CE = Panel_2:getChildByName("Label_CE");
    local Label_Guild = Panel_2:getChildByName("Label_Guild");
    local Label_retreat = self.Button_retreat:getChildByName("Label_retreat");

    Label_Level:setText(MG_TEXT_COCOS("SiegeTroops_info_ui_1"));
    Label_CE:setText(MG_TEXT_COCOS("SiegeTroops_info_ui_2"));
    Label_Guild:setText(MG_TEXT_COCOS("SiegeTroops_info_ui_3"));
    Label_retreat:setText(MG_TEXT_COCOS("SiegeTroops_info_ui_4"));

end

function guildTroopsInfo:setData(data)
    self.data = data;
    self.Label_name:setText(unicode_to_utf8(self.data.name));
    self.Label_Level_num:setText(self.data.lv);
    self.Label_CE_num:setText(self.data.score);
    self.Label_GuildName:setText(unicode_to_utf8(self.data.union_name));

    local gm = GENERAL:getAllGeneralModel(tonumber(self.data.head));
    if gm then
        self.heroHead:setHeadData(gm:head());
    end

    if ME:getUid() == self.data.uid then
        self.Button_retreat:setEnabled(true);
    end

    self:creatItem();
end

function guildTroopsInfo:creatItem()
    self.ListView:removeAllItems();
    local itemLay = ccui.Layout:create();
    itemLay:setSize(cc.size(self.ListView:getContentSize().width, self.ListView:getContentSize().height));
    if #self.data.general_info > 5 then
        itemLay:setSize(cc.size(#self.data.general_info*130, self.ListView:getContentSize().height));
    end
    self.ListView:pushBackCustomItem(itemLay);

    self.items = {};
    for i=1,#self.data.general_info do
        local general_info = self.data.general_info[i];
        local item = HeroHeadEx.create(self);
        item:setEnemyData(tonumber(general_info.g_id),tonumber(general_info.lv),tonumber(general_info.quality),tonumber(general_info.star));
        itemLay:addChild(item);
        item:setPosition(cc.p(item:getContentSize().width/2+(i-1)*(item:getContentSize().width+20),itemLay:getContentSize().height/2));
        table.insert(self.items,item);
    end

    if #self.items <= 5 and #self.items > 0 then
        local pos = getItemPositionX(self.items,itemLay:getContentSize().width/2);
        for i=1,#self.items do
            self.items[i]:setPositionX(pos[i]);
        end
    end
end

function guildTroopsInfo:onButtonClick(sender, eventType)
    if sender ~= self.Panel_1 then
        buttonClickScale(sender, eventType);
    end

    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_retreat then
            if self.delegate and self.delegate.sendReq then
                self.delegate:sendReq(self);
            end
        end
        self:removeFromParent();
    end
end

function guildTroopsInfo:onEnter()

end

function guildTroopsInfo:onExit()
    MGRCManager:releaseResources("guildTroopsInfo");
    if self.itemWidget then
        self.itemWidget:release();
    end
end

function guildTroopsInfo.create(delegate,fileName)
    local layer = guildTroopsInfo:new()
    layer.delegate = delegate
    layer.fileName = fileName
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

function guildTroopsInfo.showBox(delegate,fileName)
    local layer = guildTroopsInfo.create(delegate,fileName);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
