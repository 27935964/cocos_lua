-----------------------解散公会提示弹框-----------------

guilddisbandTip = class("guilddisbandTip", MGLayer)

function guilddisbandTip:ctor()
    self:init();
end

function guilddisbandTip:init()
    local pWidget = MGRCManager:widgetFromJsonFile("guilddisbandTip","dissolution_ui.ExportJson");
    self:addChild(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));
    self.Panel_1:setAnchorPoint(cc.p(0.5, 0.5));
    CommonMethod:setFullBgScale(self.Panel_1);

    local Panel_2 = pWidget:getChildByName("Panel_2");
    NodeShow(Panel_2);

    self.Panel_3 = Panel_2:getChildByName("Panel_3");
    self.ListView = self.Panel_3:getChildByName("ListView_condition");
    self.ListView:setScrollBarVisible(false);

    self.Button_cancel = Panel_2:getChildByName("Button_cancel");
    self.Button_cancel:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_ok = Panel_2:getChildByName("Button_ok");
    self.Button_ok:addTouchEventListener(handler(self,self.onButtonClick));

    local Label_tip1 = self.Panel_3:getChildByName("Label_tip1");
    local Label_condition = self.Panel_3:getChildByName("Label_condition");

    local Label_cancel = self.Button_cancel:getChildByName("Label_cancel");
    local Label_ok = self.Button_ok:getChildByName("Label_ok");

    Label_tip1:setText(MG_TEXT_COCOS("dissolution_ui_1"));
    Label_condition:setText(MG_TEXT_COCOS("dissolution_ui_2"));
    Label_cancel:setText(MG_TEXT_COCOS("dissolution_ui_3"));
    Label_ok:setText(MG_TEXT_COCOS("dissolution_ui_4"));


    self.ListView:removeAllItems();
    for i=1,10 do
        local item = self:createItem(i);
        self.ListView:pushBackCustomItem(item);
    end
end

function guilddisbandTip:setData(data)
    self.data = data;
end

function guilddisbandTip:createItem(i)
    local layout = ccui.Layout:create();
    layout:setAnchorPoint(cc.p(0.5,0.5));
    layout:setSize(cc.size(self.ListView:getContentSize().width, 40));

    local img = ccui.ImageView:create("com_checkbox_tick.png", ccui.TextureResType.plistType);
    img:setPosition(cc.p(20, layout:getContentSize().height/2));
    layout:addChild(img);

    local descLabel = cc.Label:createWithTTF("", ttf_msyh, 22);
    descLabel:setAnchorPoint(cc.p(0,0.5));
    descLabel:setPosition(cc.p(60, layout:getContentSize().height/2));
    layout:addChild(descLabel);
    
    if i == 1 then
        descLabel:setString(MG_TEXT("dismiss_guild_tip_1"));
    elseif i == 2 then
        descLabel:setString(MG_TEXT("dismiss_guild_tip_2"));
    else
        descLabel:setString(MG_TEXT("dismiss_guild_tip_1"));
    end

    return layout;
end

function guilddisbandTip:onButtonClick(sender, eventType)
    if sender ~= self.Panel_1 then
        buttonClickScale(sender, eventType);
    end

    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_ok then
            if self.delegate and self.delegate.disband then
                self.delegate:disband(self);
            end
        else
            self:removeFromParent();
        end
    end
end

function guilddisbandTip:onEnter()

end

function guilddisbandTip:onExit()
    MGRCManager:releaseResources("guilddisbandTip");
end

function guilddisbandTip.create(delegate)
    local layer = guilddisbandTip:new()
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

function guilddisbandTip.showBox(delegate)
    local layer = guilddisbandTip.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
