-----------------------将领属性界面------------------------

arena_buy = class("arena_buy", MGLayer)

function arena_buy:ctor()
    self:init();
end

function arena_buy:init()
    local pWidget = MGRCManager:widgetFromJsonFile("arena_buy","arena_ui_9.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);--设置描边或者阴影
    
    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));
    local Panel_2 = pWidget:getChildByName("Panel_2");
    local Image_arena_buy = Panel_2:getChildByName("Image_arena_buy");

    self.Button_close = Panel_2:getChildByName("Button_close");
    self.Button_close:addTouchEventListener(handler(self,self.onButtonClick));
    local Label_close = self.Button_close:getChildByName("Label_close");
    Label_close:setText(MG_TEXT("Cancel1"));

    self.Button_ok = Panel_2:getChildByName("Button_ok");
    self.Button_ok:addTouchEventListener(handler(self,self.onButtonClick));
    self.Label_ok = self.Button_ok:getChildByName("Label_ok");
    self.Label_ok:setText(MG_TEXT("Ok1"));


    local Panel_mid = Panel_2:getChildByName("Panel_mid");
    local Label_tip = Panel_mid:getChildByName("Label_tip");
    Label_tip:setText(MG_TEXT_COCOS("arena_ui_20"));

    self.Label_times = Panel_mid:getChildByName("Label_times");
    self.Label_gold = Panel_mid:getChildByName("Label_gold");

end

function arena_buy:setData(sports_pay_times,pay_use)
    self.Label_times:setText(sports_pay_times);
    self.Label_gold:setText(pay_use);

end

function arena_buy:onButtonClick(sender, eventType)
    buttonClickScale(sender, eventType);
    if eventType == ccui.TouchEventType.ended then
        if sender == self.Panel_1 then
            self:removeFromParent();
        elseif sender == self.Button_close then
            self:removeFromParent();
        elseif sender == self.Button_ok then
            if self.delegate and self.delegate.payAtkNum then
                self.delegate:payAtkNum();
            end
            self:removeFromParent();
        end
    end
end


function arena_buy:onEnter()

end

function arena_buy:onExit()
    MGRCManager:releaseResources("arena_buy");
end

function arena_buy.create(delegate)
    local layer = arena_buy:new()
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
