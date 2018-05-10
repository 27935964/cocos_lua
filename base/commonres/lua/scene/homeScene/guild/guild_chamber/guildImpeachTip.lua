-----------------------弹劾会长提示弹框-----------------

guildImpeachTip = class("guildImpeachTip", MGLayer)

function guildImpeachTip:ctor()
    self:init();
end

function guildImpeachTip:init()
    local pWidget = MGRCManager:widgetFromJsonFile("guildImpeachTip","impeach_ui.ExportJson");
    self:addChild(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));
    self.Panel_1:setAnchorPoint(cc.p(0.5, 0.5));
    CommonMethod:setFullBgScale(self.Panel_1);

    local Panel_2 = pWidget:getChildByName("Panel_2");
    NodeShow(Panel_2);

    self.Panel_3 = Panel_2:getChildByName("Panel_3");
    self.Label_diamond = self.Panel_3:getChildByName("Label_diamond");

    self.Button_cancel = Panel_2:getChildByName("Button_cancel");
    self.Button_cancel:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_ok = Panel_2:getChildByName("Button_ok");
    self.Button_ok:addTouchEventListener(handler(self,self.onButtonClick));

    local Label_tip1 = self.Panel_3:getChildByName("Label_tip1");
    local Label_tip2 = self.Panel_3:getChildByName("Label_tip2");
    local Label_tip3 = self.Panel_3:getChildByName("Label_tip3");

    local Label_cancel = self.Button_cancel:getChildByName("Label_cancel");
    local Label_ok = self.Button_ok:getChildByName("Label_ok");

    Label_tip1:setText(MG_TEXT_COCOS("impeach_ui_1"));
    Label_tip2:setText(MG_TEXT_COCOS("impeach_ui_2"));
    Label_tip3:setText(MG_TEXT_COCOS("impeach_ui_3"));
    Label_cancel:setText(MG_TEXT_COCOS("impeach_ui_4"));
    Label_ok:setText(MG_TEXT_COCOS("impeach_ui_5"));


    local sql = string.format("select value from config where id=99");
    local DBData = LUADB.select(sql, "value");
    self.Label_diamond:setText(tonumber(DBData.info.value));
    Label_tip2:setPositionX(self.Label_diamond:getPositionX()+self.Label_diamond:getContentSize().width+10);
end

function guildImpeachTip:setData(data)
    self.data = data;
    
end

function guildImpeachTip:onButtonClick(sender, eventType)
    if sender ~= self.Panel_1 then
        buttonClickScale(sender, eventType);
    end

    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_ok then
            if self.delegate and self.delegate.impeach then
                self.delegate:impeach(self);
            end
        else
            self:removeFromParent();
        end
    end
end

function guildImpeachTip:onEnter()

end

function guildImpeachTip:onExit()
    MGRCManager:releaseResources("guildImpeachTip");
end

function guildImpeachTip.create(delegate)
    local layer = guildImpeachTip:new()
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

function guildImpeachTip.showBox(delegate)
    local layer = guildImpeachTip.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
