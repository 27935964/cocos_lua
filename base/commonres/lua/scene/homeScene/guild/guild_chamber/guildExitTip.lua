-----------------------退出公会提示弹框-----------------

guildExitTip = class("guildExitTip", MGLayer)

function guildExitTip:ctor()
    self:init();
end

function guildExitTip:init()
    local pWidget = MGRCManager:widgetFromJsonFile("guildExitTip","leave_ui.ExportJson");
    self:addChild(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));
    self.Panel_1:setAnchorPoint(cc.p(0.5, 0.5));
    CommonMethod:setFullBgScale(self.Panel_1);

    local Panel_2 = pWidget:getChildByName("Panel_2");
    NodeShow(Panel_2);

    self.Panel_3 = Panel_2:getChildByName("Panel_3");
    self.CheckBox = self.Panel_3:getChildByName("CheckBox");
    self.CheckBox:addEventListenerCheckBox(handler(self,self.selectedEvent));
    self.Label_num = self.Panel_3:getChildByName("Label_num");

    self.Button_cancel = Panel_2:getChildByName("Button_cancel");
    self.Button_cancel:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_ok = Panel_2:getChildByName("Button_ok");
    self.Button_ok:addTouchEventListener(handler(self,self.onButtonClick));

    local Label_tip1 = self.Panel_3:getChildByName("Label_tip1");
    local Label_tip2 = self.Panel_3:getChildByName("Label_tip2");
    local Label_tip3 = self.Panel_3:getChildByName("Label_tip3");
    local Label_tip4 = self.Panel_3:getChildByName("Label_tip4");

    local Label_cancel = self.Button_cancel:getChildByName("Label_cancel");
    local Label_ok = self.Button_ok:getChildByName("Label_ok");

    Label_tip1:setText(MG_TEXT_COCOS("leave_ui_1"));
    Label_tip2:setText(MG_TEXT_COCOS("leave_ui_2"));
    Label_tip3:setText(MG_TEXT_COCOS("leave_ui_3"));
    Label_tip4:setText(MG_TEXT_COCOS("leave_ui_4"));
    Label_cancel:setText(MG_TEXT_COCOS("leave_ui_5"));
    Label_ok:setText(MG_TEXT_COCOS("leave_ui_6"));

    local sql = string.format("select value from config where id=97");
    local DBData = LUADB.select(sql, "value");
    self.Label_num:setText(tonumber(DBData.info.value));
    Label_tip4:setPositionX(self.Label_num:getPositionX()+self.Label_num:getContentSize().width+10);
end

function guildExitTip:setData(data)
    self.data = data;
end

function guildExitTip:selectedEvent(sender,eventType)
    self.state = self.CheckBox:getSelectedState();
end

function guildExitTip:onButtonClick(sender, eventType)
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

function guildExitTip:onEnter()

end

function guildExitTip:onExit()
    MGRCManager:releaseResources("guildExitTip");
end

function guildExitTip.create(delegate)
    local layer = guildExitTip:new()
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

function guildExitTip.showBox(delegate)
    local layer = guildExitTip.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
