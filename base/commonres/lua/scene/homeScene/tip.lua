-----------------------弹框-----------------

tip = class("tip", MGLayer)

function tip:ctor()
    self:init();
end

function tip:init()
    -- MGRCManager:cacheResource("tip", "main_ui_big_number.png");
    local pWidget = MGRCManager:widgetFromJsonFile("tip","com_tip_ui.ExportJson");
    self:addChild(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));
    self.Panel_1:setAnchorPoint(cc.p(0.5, 0.5));
    CommonMethod:setFullBgScale(self.Panel_1);

    local Panel_2 = pWidget:getChildByName("Panel_2");
    NodeShow(Panel_2);

    self.Label_num = Panel_2:getChildByName("Label_num");
    self.Label_mas = Panel_2:getChildByName("Label_mas");

    self.Button_buy = Panel_2:getChildByName("Button_buy");
    self.Button_buy:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_cancel = Panel_2:getChildByName("Button_cancel");
    self.Button_cancel:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_ok = Panel_2:getChildByName("Button_ok");
    self.Button_ok:addTouchEventListener(handler(self,self.onButtonClick));

    self.Label_tip = Panel_2:getChildByName("Label_tip");
    self.Label_tip:setText(MG_TEXT("tip_1"));

    local Label_tip2 = Panel_2:getChildByName("Label_tip2");
    self.Label_buy = self.Button_buy:getChildByName("Label_buy");

    Label_tip2:setText(MG_TEXT_COCOS("com_tip_ui_2"));
    self.Label_buy:setText(MG_TEXT_COCOS("com_tip_ui_3"));
end

function tip:setData(data)--英雄试炼系统接口
    self.data = data;
    self.Label_num:setText(string.format("%d/%d",tonumber(self.data.num),9999));
    self.Label_mas:setText(tonumber(self.data.next_buy_use));
    self.Button_cancel:setEnabled(false);
    self.Button_ok:setEnabled(false);
end

function tip:setVindicatorData(data)--维护者系统接口
    self.data = data;
    self.Label_mas:setText(tonumber(self.data.use_gold));
    self.Label_num:setText(tonumber(self.data.surplus_num));
    self.Label_tip:setText(MG_TEXT("tip_2"));
    self.Button_buy:setEnabled(false);
end

function tip:onButtonClick(sender, eventType)
    if sender ~= self.Panel_1 then
        buttonClickScale(sender, eventType);
    end

    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_buy or sender == self.Button_ok then
            if self.delegate and self.delegate.buy then
                self.delegate:buy(self);
            end
        end
        self:removeFromParent();
    end
end

function tip:onEnter()

end

function tip:onExit()
    MGRCManager:releaseResources("tip");
end

function tip.create(delegate)
    local layer = tip:new()
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

function tip.showBox(delegate)
    local layer = tip.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
