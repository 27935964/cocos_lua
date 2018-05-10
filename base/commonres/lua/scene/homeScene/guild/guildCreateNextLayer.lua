-----------------------公会创建界面------------------------

guildCreateNextLayer = class("guildCreateNextLayer", MGLayer)

function guildCreateNextLayer:ctor()
    self.name = "";
    self.flagId = 0;
    self.totemId = 0;
    self:init();
end

function guildCreateNextLayer:init()
    local pWidget = MGRCManager:widgetFromJsonFile("guildCreateNextLayer","guild_create_ui_1.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:setAnchorPoint(cc.p(0.5, 0.5));
    CommonMethod:setFullBgScale(self.Panel_1);
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));

    local Panel_2 = pWidget:getChildByName("Panel_2");
    self.Panel_2 = Panel_2;

    self.Button_close = Panel_2:getChildByName("Button_close");
    self.Button_close:addTouchEventListener(handler(self,self.onButtonClick));

    local Panel_3 = Panel_2:getChildByName("Panel_3");
    self.Image_flag = Panel_3:getChildByName("Image_flag");
    self.Image_totem = Panel_3:getChildByName("Image_totem");
    self.Label_mas = Panel_3:getChildByName("Label_mas");

    local Image_editBox = Panel_3:getChildByName("Image_editBox");
    self.editBox = self:createEditBox(Image_editBox);

    self.Button_back = Panel_3:getChildByName("Button_back");
    self.Button_back:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_create = Panel_3:getChildByName("Button_create");
    self.Button_create:addTouchEventListener(handler(self,self.onButtonClick));

    local Label_back = self.Button_back:getChildByName("Label_back");
    local Label_create = self.Button_create:getChildByName("Label_create");
    local Label_tip = Panel_3:getChildByName("Label_tip");
    
    Label_back:setText(MG_TEXT_COCOS("guild_create_ui_1_1"));
    Label_create:setText(MG_TEXT_COCOS("guild_create_ui_1_2"));
    Label_tip:setText(MG_TEXT_COCOS("guild_create_ui_1_3"));

end

function guildCreateNextLayer:createEditBox(imageView)
    local sp = cc.Scale9Sprite:create();
    local editBox = cc.EditBox:create(cc.size(imageView:getSize().width * 0.95, imageView:getSize().height), sp);
    editBox:setFontSize(22);
    editBox:setFontColor(cc.c3b(82,82,82));
    editBox:setFontName(ttf_msyh);
    editBox:setAnchorPoint(cc.p(0.5, 0.5));
    editBox:setPosition(cc.p(imageView:getSize().width/2, imageView:getSize().height / 2));
    editBox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE);
    editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_SEARCH);
    editBox:registerScriptEditBoxHandler(handler(self,self.editBoxTextEventHandler));
    imageView:addChild(editBox);

    editBox:setMaxLength(1);
    editBox:setPlaceholderFontColor(cc.c3b(82,82,82));
    editBox:setPlaceholderFontSize(22);
    editBox:setPlaceHolder(MG_TEXT("guildLayer_1"));

    return editBox;
end

function guildCreateNextLayer:setData(flagId,totemId)
    self.flagId = flagId;
    self.totemId = totemId;
    self.Image_flag:loadTexture(string.format("guild_flag_%d.png",flagId),ccui.TextureResType.plistType);
    self.Image_totem:loadTexture(string.format("guild_totem_%d.png",totemId),ccui.TextureResType.plistType);
end

function guildCreateNextLayer:editBoxTextEventHandler(strEventName,sender)
    if strEventName == "began" then

    elseif strEventName == "return" then
        self.name = self.editBox:getText();
    end
end

function guildCreateNextLayer:onButtonClick(sender, eventType)
    if sender ~= self.Panel_1 then
        buttonClickScale(sender, eventType);
    end

    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_create then
            self:sendReq();
        else
            self:removeFromParent();
        end
    end
end

function guildCreateNextLayer:onReciveData(MsgID, NetData)
    print("guildCreateNextLayer onReciveData MsgID:"..MsgID)

    if MsgID == Post_createUnion then
        local ackData = NetData
        if ackData.state == 1 then
            if self.delegate and self.delegate.remove then
                self.delegate:remove();
            end
            self:removeFromParent();
        else
            NetHandler:showFailedMessage(ackData)
        end
    end
end

function guildCreateNextLayer:sendReq()
    local str = string.format("&name=%s&flag=%d&flag_bg=%d",self.name,self.flagId,self.totemId);
    NetHandler:sendData(Post_createUnion, str);
end

function guildCreateNextLayer:pushAck()
    NetHandler:addAckCode(self,Post_createUnion);
end

function guildCreateNextLayer:popAck()
    NetHandler:delAckCode(self,Post_createUnion);
end

function guildCreateNextLayer:onEnter()
    self:pushAck();
end

function guildCreateNextLayer:onExit()
    MGRCManager:releaseResources("guildCreateNextLayer");
    self:popAck();
end

function guildCreateNextLayer.create(delegate,type)
    local layer = guildCreateNextLayer:new()
    layer.delegate = delegate
    layer.scenetype = type
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

function guildCreateNextLayer.showBox(delegate,type)
    local layer = guildCreateNextLayer.create(delegate,type);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
