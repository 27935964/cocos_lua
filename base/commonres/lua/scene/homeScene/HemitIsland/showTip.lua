-----------------------弹框-----------------

showTip = class("showTip", MGLayer)

function showTip:ctor()
    self:init();
end

function showTip:init()
    -- MGRCManager:cacheResource("showTip", "main_ui_big_number.png");
    local pWidget = MGRCManager:widgetFromJsonFile("showTip","com_tip_ui2.ExportJson");
    self:addChild(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));
    self.Panel_1:setAnchorPoint(cc.p(0.5, 0.5));
    CommonMethod:setFullBgScale(self.Panel_1);

    local Panel_2 = pWidget:getChildByName("Panel_2");
    NodeShow(Panel_2);

    local Panel_3 = Panel_2:getChildByName("Panel_3");
    self.Label_tip2 = Panel_2:getChildByName("Label_tip");
    self.Label_tip2:setVisible(false);
    self.Panel_tip1 = Panel_3:getChildByName("Panel_tip1");
    -- self.Panel_tip1:setVisible(false);

    self.Label_tip = self.Panel_tip1:getChildByName("Label_tip");
    self.Label_tip:setVisible(false);
    self.tipLabel = MGColorLabel:label();
    self.tipLabel:setAnchorPoint(cc.p(0.5, 0.5));
    self.tipLabel:setPosition(self.Label_tip:getPosition());
    self.Panel_tip1:addChild(self.tipLabel);


    self.Label_num = self.Panel_tip1:getChildByName("Label_num");

    self.Button_cancel = Panel_2:getChildByName("Button_cancel");
    self.Button_cancel:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_ok = Panel_2:getChildByName("Button_ok");
    self.Button_ok:addTouchEventListener(handler(self,self.onButtonClick));

    self.Label_cancel = self.Button_cancel:getChildByName("Label_cancel");
    self.Label_ok = self.Button_ok:getChildByName("Label_ok");

    self.Label_cancel:setText(MG_TEXT("Cancel1"));
    self.Label_ok:setText(MG_TEXT("Ok1"));

    self.Label_tip1 = MGColorLabel:label();
    self.Label_tip1:setVisible(false);
    self.Label_tip1:setAnchorPoint(cc.p(0.5, 0.5));
    self.Label_tip1:setPosition(cc.p(Panel_3:getContentSize().width/2,Panel_3:getContentSize().height/2));
    Panel_3:addChild(self.Label_tip1);
    
end

function showTip:setData(data,type,eventType)
    self.data = data;
    self.eventType = eventType;
    if nil == eventType then
        self.eventType = 1;
    end

    if type == 1 then--纯文字
        self.Panel_tip1:setVisible(false);
        self.Label_tip1:setVisible(true);
        self.Label_tip1:clear();
        self.Label_tip1:appendStringAutoWrap("",18,1,cc.c3b(255,255,255),22);
    elseif type == 2 then--文字+图+文字
        self.Panel_tip1:setVisible(true);
        self.Label_tip1:setVisible(false);
        self.Label_tip2:setVisible(true);
        self.Label_tip2:setText(string.format(MG_TEXT("IslandMainLayer_10"),tonumber(self.data.buy_num)));
        self.tipLabel:clear();
        self.tipLabel:appendStringAutoWrap(MG_TEXT("IslandMainLayer_2"),14,1,cc.c3b(255,255,255),22);
    end

    if self.data then
        self.Label_num:setText(tonumber(self.data.next_reset_use));
        self.Label_num:setColor(cc.c3b(255,230,0));
    end
end

function showTip:setTipText(msg)
    self.Label_tip1:clear();
    self.Label_tip1:appendStringAutoWrap(msg,18,1,cc.c3b(255,255,255),22);
end

function showTip:onButtonClick(sender, eventType)
    if sender ~= self.Panel_1 then
        buttonClickScale(sender, eventType);
    end

    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_ok then
            if self.delegate and self.delegate.callBack then
                self.delegate:callBack(self);
            end
        end
        self:removeFromParent();
    end
end

function showTip:onEnter()

end

function showTip:onExit()
    MGRCManager:releaseResources("showTip");
end

function showTip.create(delegate)
    local layer = showTip:new()
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

function showTip.showBox(delegate)
    local layer = showTip.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
