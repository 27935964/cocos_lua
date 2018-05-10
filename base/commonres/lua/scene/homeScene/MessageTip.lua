-----------------------弹框-----------------

MessageTip = class("MessageTip", MGLayer)

function MessageTip:ctor()
    self:init();
end

function MessageTip:init()
    local pWidget = MGRCManager:widgetFromJsonFile("MessageTip","com_tip_ui_1.ExportJson");
    self:addChild(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));
    self.Panel_1:setAnchorPoint(cc.p(0.5, 0.5));
    CommonMethod:setFullBgScale(self.Panel_1);

    local Panel_2 = pWidget:getChildByName("Panel_2");
    NodeShow(Panel_2);

    self.Panel_3 = Panel_2:getChildByName("Panel_3");
    self.Label_tip = self.Panel_3:getChildByName("Label_tip");
    self.Label_tip:setVisible(false);

    self.Button_cancel = Panel_2:getChildByName("Button_cancel");
    self.Button_cancel:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_ok = Panel_2:getChildByName("Button_ok");
    self.Button_ok:addTouchEventListener(handler(self,self.onButtonClick));

    self.Label_cancel = self.Button_cancel:getChildByName("Label_cancel");
    self.Label_ok = self.Button_ok:getChildByName("Label_ok");

    self.Label_cancel:setText(MG_TEXT("Cancel1"));
    self.Label_ok:setText(MG_TEXT("Ok1"));
end

function MessageTip:setData()

end

function MessageTip:setText(str)
    self.descLabel = MGColorLabel:label();
    self.descLabel:setAnchorPoint(cc.p(0.5, 0.5));
    self.descLabel:setPosition(self.Label_tip:getPosition());
    self.Panel_3:addChild(self.descLabel);

    self.descLabel:clear();
    self.descLabel:appendStringAutoWrap(str,16,1,cc.c3b(255,255,255),22);
end

function MessageTip:onButtonClick(sender, eventType)
    if sender ~= self.Panel_1 then
        buttonClickScale(sender, eventType);
    end

    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_ok then
            if self.delegate and self.delegate.callBack then
                self.delegate:callBack(self);
            end
        else
            self:removeFromParent();
        end
    end
end

function MessageTip:onEnter()

end

function MessageTip:onExit()
    MGRCManager:releaseResources("MessageTip");
end

function MessageTip.create(delegate)
    local layer = MessageTip:new()
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

function MessageTip.showBox(delegate)
    local layer = MessageTip.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
