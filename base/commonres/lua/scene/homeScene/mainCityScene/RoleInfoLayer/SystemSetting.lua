------------------------系统设置界面-------------------------

SystemSetting = class("SystemSetting", MGLayer)

function SystemSetting:ctor()
    self.isOpen1 = true;--当前状态开
    self.isOpen2 = true;
    self:init();
end

function SystemSetting:init()
    local pWidget = MGRCManager:widgetFromJsonFile("SystemSetting","SystemSettings_ui.ExportJson");
    self:addChild(pWidget);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));

    local Panel_2 = pWidget:getChildByName("Panel_2");

    self.Slider_1 = Panel_2:getChildByName("Slider_1");
    self.Slider_1:setPercent(50);
    self.Slider_1:addEventListenerSlider(handler(self,self.percentChangedEvent));
    self.Slider_2 = Panel_2:getChildByName("Slider_2");
    self.Slider_2:setPercent(50);
    self.Slider_2:addEventListenerSlider(handler(self,self.percentChangedEvent));

    self.Button_close = Panel_2:getChildByName("Button_close");
    self.Button_close:addTouchEventListener(handler(self,self.onButtonClick));

    self.Image_Switch1 = Panel_2:getChildByName("Image_Switch1");
    self.Image_Switch2 = Panel_2:getChildByName("Image_Switch2");

    self.Image_Switch_bg1 = Panel_2:getChildByName("Image_Switch_bg1");
    self.Image_Switch_bg1:setTouchEnabled(true);
    self.Image_Switch_bg1:addTouchEventListener(handler(self,self.onButtonClick));

    self.Image_Switch_bg2 = Panel_2:getChildByName("Image_Switch_bg2");
    self.Image_Switch_bg2:setTouchEnabled(true);
    self.Image_Switch_bg2:addTouchEventListener(handler(self,self.onButtonClick));

    local Label_Music = Panel_2:getChildByName("Label_Music");
    Label_Music:setText(MG_TEXT_COCOS("SystemSettings_ui_1"));

    local Label_SoundEffect = Panel_2:getChildByName("Label_SoundEffect");
    Label_SoundEffect:setText(MG_TEXT_COCOS("SystemSettings_ui_2"));

    local Label_Warn = Panel_2:getChildByName("Label_Warn");
    Label_Warn:setText(MG_TEXT_COCOS("SystemSettings_ui_3"));

    local Label_open1 = Panel_2:getChildByName("Label_open1");
    Label_open1:setText(MG_TEXT_COCOS("SystemSettings_ui_4"));

    local Label_close1 = Panel_2:getChildByName("Label_close1");
    Label_close1:setText(MG_TEXT_COCOS("SystemSettings_ui_5"));

    local Label_NightPush = Panel_2:getChildByName("Label_NightPush");
    Label_NightPush:setText(MG_TEXT_COCOS("SystemSettings_ui_6"));

    local Label_open2 = Panel_2:getChildByName("Label_open2");
    Label_open2:setText(MG_TEXT_COCOS("SystemSettings_ui_4"));

    local Label_close2 = Panel_2:getChildByName("Label_close2");
    Label_close2:setText(MG_TEXT_COCOS("SystemSettings_ui_5"));

end

function SystemSetting:setData()
    
end

function SystemSetting:percentChangedEvent(sender,eventType)
    if eventType == ccui.SliderEventType.percentChanged then
        self.slider = sender;
        self.percent = self.slider:getPercent();
    end
end

function SystemSetting:onButtonClick(sender, eventType)
    if sender == self.Button_close then
        buttonClickScale(sender, eventType);
    end

    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_close or sender == self.Panel_1 then
            self:removeFromParent();
        elseif sender == self.Image_Switch_bg1 then
            self.isOpen1 = not self.isOpen1;
            if self.isOpen1 == true then
                local moveTo = cc.MoveTo:create(0.1,cc.p(294,80))
                self.Image_Switch1:runAction(moveTo);
            else
                local moveTo = cc.MoveTo:create(0.1,cc.p(246,80))
                self.Image_Switch1:runAction(moveTo);
            end
        elseif sender == self.Image_Switch_bg2 then
            self.isOpen2 = not self.isOpen2;
            if self.isOpen2 == true then
                local moveTo = cc.MoveTo:create(0.1,cc.p(598,80))
                self.Image_Switch2:runAction(moveTo);
            else
                local moveTo = cc.MoveTo:create(0.1,cc.p(550,80))
                self.Image_Switch2:runAction(moveTo);
            end
        end
    end
end

-- function SystemSetting:onReciveData(MsgID, NetData)
--     print("LoadingPanel onReciveData MsgID:"..MsgID)
--     if MsgID == Post_doGetRandName then
--         local ackData = NetData;
--         if ackData.state == 1 then
--             self.editBox:setText(unicode_to_utf8(ackData.dogetrandname.name));
--             self.nameLabel = self.editBox:getText();
--         else
--             NetHandler:showFailedMessage(ackData)
--         end
--     end
-- end

-- function SystemSetting:sendReq()
--     NetHandler:sendData(Post_doGetRandName, "");
-- end

-- function SystemSetting:pushAck()
--     NetHandler:addAckCode(self,Post_doGetRandName);
-- end

-- function SystemSetting:popAck()
--     NetHandler:delAckCode(self,Post_doGetRandName);
-- end

function SystemSetting:onEnter()
    -- self:pushAck();
end

function SystemSetting:onExit()
    MGRCManager:releaseResources("SystemSetting");
    -- self:popAck();
end

function SystemSetting.create(delegate)
    local layer = SystemSetting:new()
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

function SystemSetting.showBox(delegate)
    local layer = SystemSetting.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
