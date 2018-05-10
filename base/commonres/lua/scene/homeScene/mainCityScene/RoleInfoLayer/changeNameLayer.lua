------------------------改名界面-------------------------

changeNameLayer = class("changeNameLayer", MGLayer)

function changeNameLayer:ctor()
    self.nameLabel = "";
    self:init();
end

function changeNameLayer:init()
    MGRCManager:cacheResource("chatLayer", "chat_ui.png", "chat_ui.plist");
    local pWidget = MGRCManager:widgetFromJsonFile("changeNameLayer","ChangeNameUi.ExportJson");
    self:addChild(pWidget);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));

    local Panel_2 = pWidget:getChildByName("Panel_2");
    local Panel_3 = Panel_2:getChildByName("Panel_3");

    self.Button_Dice = Panel_3:getChildByName("Button_Dice");
    self.Button_Dice:addTouchEventListener(handler(self,self.onButtonClick));

    local Image_InputBox = Panel_3:getChildByName("Image_InputBox");
    self.editBox = self:createEditBox(Image_InputBox);

    self.Label_num = Panel_3:getChildByName("Label_ComsuneNumber");

    self.Button_cancel = Panel_2:getChildByName("Button_cancel");
    self.Button_cancel:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_ok = Panel_2:getChildByName("Button_ok");
    self.Button_ok:addTouchEventListener(handler(self,self.onButtonClick));

    local Label_ChangeName = Panel_3:getChildByName("Label_ChangeName");
    Label_ChangeName:setText(MG_TEXT_COCOS("ChangeNameUi_1"));

    local Label_Consume = Panel_3:getChildByName("Label_Consume");
    Label_Consume:setText(MG_TEXT_COCOS("ChangeNameUi_2"));

    local Label_cancel = self.Button_cancel:getChildByName("Label_cancel");
    Label_cancel:setText(MG_TEXT_COCOS("ChangeNameUi_3"));

    local Label_ok = self.Button_ok:getChildByName("Label_ok");
    Label_ok:setText(MG_TEXT_COCOS("ChangeNameUi_4"));

    local sql = "select value from config where id=181";
    local DBData = LUADB.select(sql, "value");
    self.value = spliteStr(DBData.info.value,':');


    self:setData();---临时
end

function changeNameLayer:onButtonClick(sender, eventType)
    buttonClickScale(sender, eventType);
    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_Dice then
            self:sendReq();
        elseif sender == self.Button_ok then
            if self.nameLabel == "" then
                MGMessageTip:showFailedMessage(MG_TEXT("changeNameLayer_1"));
            else
                self:sendNameReq();
            end
        elseif sender == self.Button_cancel or sender == self.Panel_1 then
            self:removeFromParent();
        end
    end
end

function changeNameLayer:setData()
    local num = 0;
    local gm = RESOURCE:getResModelByItemId(tonumber(self.value[2]));
    if gm then
        num = gm:getNum();
    end
    self.Label_num:setText(string.format("%d/%d",num,tonumber(self.value[3])));
end

function changeNameLayer:createEditBox(imageView)
    local sp = cc.Scale9Sprite:create();
    local editBox = cc.EditBox:create(cc.size(imageView:getSize().width * 0.95, imageView:getSize().height), sp);
    editBox:setFontSize(26);
    editBox:setFontColor(cc.c3b(118,118,118));
    editBox:setFontName(ttf_msyh);
    editBox:setAnchorPoint(cc.p(0.5, 0.5));
    editBox:setPosition(cc.p(imageView:getSize().width/2, imageView:getSize().height / 2));
    editBox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE);
    editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_SEARCH);
    editBox:registerScriptEditBoxHandler(handler(self,self.editBoxTextEventHandler));
    imageView:addChild(editBox);

    editBox:setMaxLength(20);
    editBox:setPlaceHolder(MG_TEXT("changeNameLayer_1"));

    return editBox;
end

function changeNameLayer:editBoxTextEventHandler(strEventName,sender)
    if strEventName == "began" then

    elseif strEventName == "return" then
        self.nameLabel = self.editBox:getText();
    end
end

function changeNameLayer:onReciveData(MsgID, NetData)
    print("LoadingPanel onReciveData MsgID:"..MsgID)
    local ackData = NetData;
    if MsgID == Post_doGetRandName then
        if ackData.state == 1 then
            self.editBox:setText(unicode_to_utf8(ackData.dogetrandname.name));
            self.nameLabel = self.editBox:getText();
        else
            NetHandler:showFailedMessage(ackData)
        end
    elseif MsgID == Post_User_setUserName then
        if ackData.state == 1 then
            if self.delegate and self.delegate.setName then
                self.delegate:setName(self.nameLabel);
            end
            MGMessageTip:showFailedMessage(MG_TEXT("changeNameLayer_2"));
            self:removeFromParent();
            NetHandler:sendData(Post_getUserMain, "");--刷新主界面
        else
            NetHandler:showFailedMessage(ackData)
        end
    end
end

function changeNameLayer:sendReq()
    NetHandler:sendData(Post_doGetRandName, "");
end

function changeNameLayer:sendNameReq()
    local str = string.format("&name=%s",self.nameLabel);
    NetHandler:sendData(Post_User_setUserName, str);
end

function changeNameLayer:pushAck()
    NetHandler:addAckCode(self,Post_doGetRandName);
    NetHandler:addAckCode(self,Post_User_setUserName);
end

function changeNameLayer:popAck()
    NetHandler:delAckCode(self,Post_doGetRandName);
    NetHandler:delAckCode(self,Post_User_setUserName);
end

function changeNameLayer:onEnter()
    self:pushAck();
end

function changeNameLayer:onExit()
    MGRCManager:releaseResources("changeNameLayer");
    self:popAck();
end

function changeNameLayer.create(delegate)
    local layer = changeNameLayer:new()
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

function changeNameLayer.showBox(delegate)
    local layer = changeNameLayer.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
