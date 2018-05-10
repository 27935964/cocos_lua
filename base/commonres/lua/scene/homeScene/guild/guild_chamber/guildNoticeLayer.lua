-----------------------公会议会厅--公告界面------------------------

guildNoticeLayer = class("guildNoticeLayer", MGLayer)

function guildNoticeLayer:ctor()
    self.descLabel = "";
    self.descLabel_qq = "";
    self.descLabel_wechat = "";
    self.myPost = 0;
    self:init();
end

function guildNoticeLayer:init()
    local pWidget = MGRCManager:widgetFromJsonFile("guildNoticeLayer","guild_hall_ui_4.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);

    local Panel_2 = pWidget:getChildByName("Panel_2");
    self.Button_save = Panel_2:getChildByName("Button_save");
    self.Button_save:addTouchEventListener(handler(self,self.onButtonClick));

    self.Image_editBox = Panel_2:getChildByName("Image_frame_notice");
    self.editBox = self:createEditBox(self.Image_editBox);
    -- self.editBox:setEnabled(false);
    self.Label_desc = self.Image_editBox:getChildByName("Label_desc");

    self.Image_frame_qq = Panel_2:getChildByName("Image_frame_qq");
    self.editBox_qq = self:createEditBox(self.Image_frame_qq);
    self.Button_qq_copy = self.Image_frame_qq:getChildByName("Button_qq_copy");
    self.Button_qq_copy:addTouchEventListener(handler(self,self.onButtonClick));
    self.Label_qq_number = self.Image_frame_qq:getChildByName("Label_qq_number");

    self.Image_frame_wechat = Panel_2:getChildByName("Image_frame_wechat");
    self.editBox_wechat = self:createEditBox(self.Image_frame_wechat);
    self.Button_wechat_copy = self.Image_frame_wechat:getChildByName("Button_wechat_copy");
    self.Button_wechat_copy:addTouchEventListener(handler(self,self.onButtonClick));
    self.Label_wechat_number = self.Image_frame_wechat:getChildByName("Label_wechat_number");


    local Label_tip = self.Image_editBox:getChildByName("Label_tip");
    Label_tip:setText(MG_TEXT_COCOS("guild_hall_ui_4_1"));

    local Label_qq_group = self.Image_frame_qq:getChildByName("Label_qq_group");
    Label_qq_group:setText(MG_TEXT_COCOS("guild_hall_ui_4_2"));

    local Label_wechat_group = self.Image_frame_wechat:getChildByName("Label_wechat_group");
    Label_wechat_group:setText(MG_TEXT_COCOS("guild_hall_ui_4_3"));

    local Label_qq_copy = self.Button_qq_copy:getChildByName("Label_qq_copy");
    Label_qq_copy:setText(MG_TEXT_COCOS("guild_hall_ui_4_4"));

    local Label_wechat_copy = self.Button_wechat_copy:getChildByName("Label_wechat_copy");
    Label_wechat_copy:setText(MG_TEXT_COCOS("guild_hall_ui_4_4"));

    local Label_save = self.Button_save:getChildByName("Label_save");
    Label_save:setText(MG_TEXT_COCOS("guild_hall_ui_4_5"));
end

function guildNoticeLayer:createEditBox(imageView)
    local sp = cc.Scale9Sprite:create();
    local editBox = cc.EditBox:create(cc.size(imageView:getSize().width * 0.95, imageView:getSize().height), sp);
    editBox:setFontSize(22);
    -- editBox:setFontColor(cc.c3b(82,82,82));
    editBox:setFontName(ttf_msyh);
    editBox:setAnchorPoint(cc.p(0.5, 0.5));
    editBox:setPosition(cc.p(imageView:getSize().width/2, imageView:getSize().height / 2));
    editBox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE);
    editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_SEARCH);
    editBox:registerScriptEditBoxHandler(handler(self,self.editBoxTextEventHandler));
    imageView:addChild(editBox);

    
    if imageView == self.Image_editBox then
        editBox:setMaxLength(50);
    elseif imageView == self.Image_frame_qq then
        editBox:setMaxLength(12);
    elseif imageView == self.Image_frame_wechat then
        editBox:setMaxLength(12);
    end

    return editBox;
end

function guildNoticeLayer:setData(data)
    self.data = data;
    if self.delegate and self.delegate.getPost then
        self.myPost = self.delegate:getPost();
    end

    self.descLabel = unicode_to_utf8(self.data.desc);
    self.descLabel_qq = self.data.qq;
    self.descLabel_wechat = self.data.vx;

    self.Label_desc:setText(self.descLabel);
    self.Label_qq_number:setText(self.descLabel_qq);
    self.Label_wechat_number:setText(self.descLabel_wechat);
    if self.data.desc == "" then
        self.Label_desc:setText(MG_TEXT("guildNoticeLayer_6"));
        if self.myPost == 10 or self.myPost == 9 then
            self.Label_desc:setText(MG_TEXT("guildNoticeLayer_1"));
        end
    end
    if self.data.qq == "" then
        self.Label_qq_number:setText(MG_TEXT("guildNoticeLayer_2"));
        if self.myPost == 10 or self.myPost == 9 then
            self.Label_desc:setText(MG_TEXT("guildNoticeLayer_4"));
        end
    end
    if self.data.vx == "" then
        self.Label_wechat_number:setText(MG_TEXT("guildNoticeLayer_2"));
        if self.myPost == 10 or self.myPost == 9 then
            self.Label_desc:setText(MG_TEXT("guildNoticeLayer_5"));
        end
    end

    self.Button_save:setEnabled(false);
    self.editBox:setEnabled(false);
    self.editBox_qq:setEnabled(false);
    self.editBox_wechat:setEnabled(false);
    if self.myPost == 10 or self.myPost == 9 then
        self.Button_save:setEnabled(true);
        self.editBox:setEnabled(true);
        self.editBox_qq:setEnabled(true);
        self.editBox_wechat:setEnabled(true);
    end
end

function guildNoticeLayer:editBoxTextEventHandler(strEventName,sender)
    if strEventName == "began" then
        if sender == self.editBox then
            self.editBox:setText(self.Label_desc:getStringValue());
        elseif sender == self.editBox_qq then
            self.editBox_qq:setText(self.Label_qq_number:getStringValue());
        elseif sender == self.editBox_wechat then
            self.editBox_wechat:setText(self.Label_wechat_number:getStringValue());
        end
    elseif strEventName == "return" then
        if sender == self.editBox then
            self.descLabel = self.editBox:getText();
            self.editBox:setText("");
            self.Label_desc:setText(self.descLabel);
        elseif sender == self.editBox_qq then
            self.descLabel_qq = self.editBox_qq:getText();
            self.editBox_qq:setText("");
            self.Label_qq_number:setText(self.descLabel_qq);
        elseif sender == self.editBox_wechat then
            self.descLabel_wechat = self.editBox_wechat:getText();
            self.editBox_wechat:setText("");
            self.Label_wechat_number:setText(self.descLabel_wechat);
        end
    end
end

function guildNoticeLayer:onButtonClick(sender, eventType)
    buttonClickScale(sender, eventType);

    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_qq_copy then

        elseif sender == self.Button_wechat_copy then
        
        elseif sender == self.Button_save then
            if self.descLabel == "" then
                MGMessageTip:showFailedMessage(MG_TEXT("guildNoticeLayer_3"));
            else
                self:sendReq();
            end
        end
    end
end

function guildNoticeLayer:onReciveData(MsgID, NetData)
    print("guildNoticeLayer onReciveData MsgID:"..MsgID)

    if MsgID == Post_unionInfo then
        local ackData = NetData
        if ackData.state == 1 then
            self:setData(ackData.unioninfo);
        else
            NetHandler:showFailedMessage(ackData)
        end
    elseif MsgID == Post_changeUnion then
        local ackData = NetData
        if ackData.state == 1 then
            MGMessageTip:showFailedMessage(MG_TEXT("ML_CheckpointLayer_4"));
        else
            NetHandler:showFailedMessage(ackData)
        end
    end
end

function guildNoticeLayer:sendReq()
    local str = string.format("&desc=%s&qq=%d&vx=%s",self.descLabel,self.descLabel_qq,self.descLabel_wechat);
    NetHandler:sendData(Post_changeUnion, str);
end

function guildNoticeLayer:pushAck()
    NetHandler:addAckCode(self,Post_unionInfo);
    NetHandler:addAckCode(self,Post_changeUnion);
end

function guildNoticeLayer:popAck()
    NetHandler:delAckCode(self,Post_unionInfo);
    NetHandler:delAckCode(self,Post_changeUnion);
end

function guildNoticeLayer:onEnter()
    self:pushAck();
    NetHandler:sendData(Post_unionInfo, "");
end

function guildNoticeLayer:onExit()
    self:popAck();
    MGRCManager:releaseResources("guildNoticeLayer");
end

function guildNoticeLayer.create(delegate,type)
    local layer = guildNoticeLayer:new()
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

function guildNoticeLayer.showBox(delegate,type)
    local layer = guildNoticeLayer.create(delegate,type);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
