--------------------------撤军----------------------------

MLRetreat = class("MLRetreat", MGLayer)

function MLRetreat:ctor()
    self:init();
end

function MLRetreat:init()
    local pWidget = MGRCManager:widgetFromJsonFile("MLRetreat","retreat_ui.ExportJson");
    self:addChild(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));
    local Panel_2 = pWidget:getChildByName("Panel_2");

    self.Button_close = Panel_2:getChildByName("Button_close");
    self.Button_close:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_cancel = Panel_2:getChildByName("Button_cancel");
    self.Button_cancel:addTouchEventListener(handler(self,self.onButtonClick));
    local Label_cancel = self.Button_cancel:getChildByName("Label_cancel");
    Label_cancel:setText(MG_TEXT_COCOS("retreat_ui_1"));

    self.Button_retreat = Panel_2:getChildByName("Button_retreat");
    self.Button_retreat:addTouchEventListener(handler(self,self.onButtonClick));
    local Label_retreat = self.Button_retreat:getChildByName("Label_retreat");
    Label_retreat:setText(MG_TEXT_COCOS("retreat_ui_2"));

    local Label_tip = Panel_2:getChildByName("Label_tip");
    Label_tip:setText(MG_TEXT_COCOS("retreat_ui_3"));
    
end

function MLRetreat:setData(data)
    self.data = data;
end

function MLRetreat:onButtonClick(sender, eventType)
    if sender ~= self.Panel_1 then
        buttonClickScale(sender, eventType);
    end

    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_retreat then
            NetHandler:sendData(Post_closeWar, "");
        end
        self:removeFromParent();
    end
end

function MLRetreat:onEnter()

end

function MLRetreat:onExit()
    MGRCManager:releaseResources("MLRetreat");
end

function MLRetreat.create(delegate)
    local layer = MLRetreat:new()
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

function MLRetreat.showBox(delegate)
    local layer = MLRetreat.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
