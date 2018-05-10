-----------------------公会福利----我的红包详情界面------------------------

local guildMyWelfareItem = require "guildMyWelfareItem";
guildMyWelfare = class("guildMyWelfare", MGLayer)

function guildMyWelfare:ctor()
    self:init();
end

function guildMyWelfare:init()
    MGRCManager:cacheResource("guildWelfareMainLayer", "com_union_bg.png");
    local pWidget = MGRCManager:widgetFromJsonFile("guildMyWelfare","guild_my_welfare_ui.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:setAnchorPoint(cc.p(0.5, 0.5));
    CommonMethod:setFullBgScale(self.Panel_1);

    local Panel_2 = pWidget:getChildByName("Panel_2");
    local Panel_3 = Panel_2:getChildByName("Panel_3");

    local Image_bg1 = Panel_3:getChildByName("Image_bg1");
    self.Label_num1 = Image_bg1:getChildByName("Label_num1");
    self.Label_diamond_num1 = Image_bg1:getChildByName("Label_diamond_num1");
    self.Label_gold_num1 = Image_bg1:getChildByName("Label_gold_num1");

    local Image_bg2 = Panel_3:getChildByName("Image_bg2");
    self.Label_num2 = Image_bg2:getChildByName("Label_num2");
    self.Label_diamond_num2 = Image_bg2:getChildByName("Label_diamond_num2");
    self.Label_gold_num2 = Image_bg2:getChildByName("Label_gold_num2");

    self.ListView = Panel_3:getChildByName("ListView");
    self.ListView:setScrollBarVisible(false);

    self.Label_tip = Panel_3:getChildByName("Label_tip");
    self.Label_tip:setText(MG_TEXT_COCOS("guild_my_welfare_ui_10"));

    self.Button_close = Panel_2:getChildByName("Button_close");
    self.Button_close:addTouchEventListener(handler(self,self.onButtonClick));

    local Label_dates = Panel_3:getChildByName("Label_dates");
    Label_dates:setText(MG_TEXT_COCOS("guild_my_welfare_ui_1"));

    local Label_source = Panel_3:getChildByName("Label_source");
    Label_source:setText(MG_TEXT_COCOS("guild_my_welfare_ui_2"));

    local Label_amount = Panel_3:getChildByName("Label_amount");
    Label_amount:setText(MG_TEXT_COCOS("guild_my_welfare_ui_3"));

    local Label_get1 = Image_bg1:getChildByName("Label_get1");
    Label_get1:setText(MG_TEXT_COCOS("guild_my_welfare_ui_4"));

    local Label_diamond1 = Image_bg1:getChildByName("Label_diamond1");
    Label_diamond1:setText(MG_TEXT_COCOS("guild_my_welfare_ui_5"));

    local Label_gold1 = Image_bg1:getChildByName("Label_gold1");
    Label_gold1:setText(MG_TEXT_COCOS("guild_my_welfare_ui_6"));

    local Label_get2 = Image_bg2:getChildByName("Label_get2");
    Label_get2:setText(MG_TEXT_COCOS("guild_my_welfare_ui_7"));

    local Label_diamond2 = Image_bg2:getChildByName("Label_diamond2");
    Label_diamond2:setText(MG_TEXT_COCOS("guild_my_welfare_ui_8"));

    local Label_gold2 = Image_bg2:getChildByName("Label_gold2");
    Label_gold2:setText(MG_TEXT_COCOS("guild_my_welfare_ui_9"));

    if not self.itemWidget then
        self.itemWidget = MGRCManager:widgetFromJsonFile("guildMercenaryLayer", "guild_my_welfare_item_ui.ExportJson",false);
        self.itemWidget:retain();
    end

end

function guildMyWelfare:setData(data)
    self.data = data;


    self.Label_num1:setText(tonumber(self.data.get_red_num));
    self.Label_diamond_num1:setText(tonumber(self.data.get_gold));
    self.Label_gold_num1:setText(tonumber(self.data.get_coin));

    self.Label_num2:setText(tonumber(self.data.send_red_num));
    self.Label_diamond_num2:setText(tonumber(self.data.send_gold));
    self.Label_gold_num2:setText(tonumber(self.data.send_coin));

    if #self.data.user_red_list > 0 then
        self.Label_tip:setVisible(false);
    end

    self.ListView:removeAllItems();
    for i=1,#self.data.user_red_list do
        local item = guildMyWelfareItem.create(self,self.itemWidget:clone());
        item:setData(self.data.user_red_list[i]);
        self.ListView:pushBackCustomItem(item);
    end
end

function guildMyWelfare:onButtonClick(sender, eventType)
    buttonClickScale(sender, eventType);
    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_close then
            self:removeFromParent();
        end
    end
end

function guildMyWelfare:onEnter()

end

function guildMyWelfare:onExit()
    MGRCManager:releaseResources("guildMyWelfare");
    if self.itemWidget then
        self.itemWidget:release();
    end
end

function guildMyWelfare.create(delegate)
    local layer = guildMyWelfare:new()
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

function guildMyWelfare.showBox(delegate)
    local layer = guildMyWelfare.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
