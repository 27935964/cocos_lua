------------------------取名界面-------------------------

intileNameLayer = class("intileNameLayer", MGLayer)

function intileNameLayer:ctor()
    self.sess_id = 0;
    self:init();
end

function intileNameLayer:init()
    MGRCManager:cacheResource("intileNameLayer", "login_bg.jpg");
    MGRCManager:cacheResource("LoginLayer", "intitle_name_box_scroll.png");
    MGRCManager:cacheResource("intileNameLayer", "intileName.png","intileName.plist");
    local pWidget = MGRCManager:widgetFromJsonFile("intileNameLayer","Name_call_ui_1.ExportJson");
    self:addChild(pWidget);

    local Panel_1 = pWidget:getChildByName("Panel_1");

    local Image_scroll = Panel_1:getChildByName("Image_scroll");
    self.Button_dice = Image_scroll:getChildByName("Button_dice");
    self.Button_dice:addTouchEventListener(handler(self,self.onButtonClick));

    local Image_text = Image_scroll:getChildByName("Image_text");
    self.editBox = self:createEditBox(Image_text);

    -- local Image_bg1 = Panel_2:getChildByName("Image_bg1");
    -- self.Button_close = Panel_2:getChildByName("Button_close");
    -- self.Button_close:addTouchEventListener(handler(self,self.onBackClick));

    -- local Panel_3 = Panel_2:getChildByName("Panel_3");
    -- self.textImg_1 = Panel_3:getChildByName("Image_box1");
    -- self.editBox_1 = self:createEditBox(self.textImg_1);

    -- self.textImg_2 = Panel_3:getChildByName("Image_box2");
    -- self.editBox_2 = self:createEditBox(self.textImg_2);

    self.Button_begin = Panel_1:getChildByName("Button_begin");
    self.Button_begin:addTouchEventListener(handler(self,self.onButtonClick));

    -- self.Button_register = Panel_3:getChildByName("Button_register");
    -- self.Button_register:addTouchEventListener(handler(self,self.onButtonClick));
end

function intileNameLayer:onBackClick(sender, eventType)
    if eventType == ccui.TouchEventType.began then

    end

    if eventType == ccui.TouchEventType.ended then
        self:removeFromParent();
    end
end

function intileNameLayer:onButtonClick(sender, eventType)
    if eventType == ccui.TouchEventType.began then
        local sc = cc.ScaleTo:create(0.1, 1.1)
        sender:runAction(cc.EaseOut:create(sc ,2))
    end
    if eventType == ccui.TouchEventType.canceled then
        local sc = cc.ScaleTo:create(0.1, 1)
        sender:runAction(sc)
    end
    if eventType == ccui.TouchEventType.ended then
        local sc = cc.ScaleTo:create(0.1, 1)
        sender:runAction(sc)
        if sender == self.Button_dice then
            self:sendReq();
        elseif sender == self.Button_begin then
            -- self:removeFromParent();
            self:sendDoActivationReq();
        end
    end
end

function intileNameLayer:setData()

end

function intileNameLayer:createEditBox(imageView)
    local sp = cc.Scale9Sprite:create();
    local editBox = cc.EditBox:create(cc.size(imageView:getSize().width * 0.90, imageView:getSize().height), sp);
    editBox:setFontSize(26);
    editBox:setFontColor(Color3B.BLACK);
    editBox:setFontName(ttf_msyh);
    editBox:setAnchorPoint(cc.p(0.5, 0.5));
    editBox:setPosition(cc.p(imageView:getSize().width/2, imageView:getSize().height / 2));
    editBox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE);
    editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_SEARCH);
    editBox:registerScriptEditBoxHandler(handler(self,self.editBoxTextEventHandler));
    imageView:addChild(editBox);

    editBox:setMaxLength(20);
    -- editBox:setPlaceHolder("请输入用户名");

    return editBox;
end

function intileNameLayer:editBoxTextEventHandler(strEventName,sender)
    if strEventName == "began" then

    elseif strEventName == "return" then
        self.nameLabel = self.editBox:getText();
    end
end

function intileNameLayer:onReciveData(MsgID, NetData)
    print("LoadingPanel onReciveData MsgID:"..MsgID)
    if MsgID == Post_doGetRandName then
        local ackData = NetData;
        if ackData.state == 1 then
            self.editBox:setText(ackData.dogetrandname.name);
        else
            NetHandler:showFailedMessage(ackData)
        end
    elseif MsgID == Post_doActivation then
        local ackData = NetData;
        if ackData.state == 1 then
            enterLuaScene(SCENEINFO.MAP_SCENE);
        else
            NetHandler:showFailedMessage(ackData)
        end
    end
end

function intileNameLayer:sendReq()
    NetHandler:sendData(Post_doGetRandName, "");
end

function intileNameLayer:sendDoActivationReq()
    if self.delegate and self.delegate.sess_id then
        self.sess_id = self.delegate.sess_id;
    end
    local str = string.format("&sess_id=%s&name=%s&from=%s&mac=%s",self.sess_id,self.editBox:getText(),"1","1");
    NetHandler:sendData(Post_doActivation, str);
end

function intileNameLayer:pushAck()
    NetHandler:addAckCode(self,Post_doGetRandName);
    NetHandler:addAckCode(self,Post_doActivation);
end

function intileNameLayer:popAck()
    NetHandler:delAckCode(self,Post_doGetRandName);
    NetHandler:delAckCode(self,Post_doActivation);
end

function intileNameLayer:onEnter()
    self:pushAck();
    self:sendReq();
end

function intileNameLayer:onExit()
    MGRCManager:releaseResources("intileNameLayer")

    self:popAck();
end

function intileNameLayer.create(delegate)
    local layer = intileNameLayer:new()
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

function intileNameLayer.showBox(delegate)
    local layer = intileNameLayer.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
