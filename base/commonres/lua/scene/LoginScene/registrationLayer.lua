------------------------注册界面管理-------------------------

local registrationLayer = class("registrationLayer", MGLayer)

function registrationLayer:ctor(delegate)
    self.delegate = delegate;
    self:init();
end

function registrationLayer:init()
    local pWidget = MGRCManager:widgetFromJsonFile("registrationLayer","login_ui_2.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:setAnchorPoint(cc.p(0.5, 0.5));
    CommonMethod:setFullBgScale(self.Panel_1);

    local Panel_2 = pWidget:getChildByName("Panel_2");

    local Panel_3 = Panel_2:getChildByName("Panel_3");
    self.textImg_1 = Panel_3:getChildByName("Image_box1");
    self.editBox_1 = self:createEditBox(self.textImg_1);

    self.textImg_2 = Panel_3:getChildByName("Image_box2");
    self.editBox_2 = self:createEditBox(self.textImg_2);

    self.textImg_3 = Panel_3:getChildByName("Image_box3");
    self.editBox_3 = self:createEditBox(self.textImg_3);

    --注 册
    self.Button_register = Panel_3:getChildByName("Button_login");
    self.Button_register:addTouchEventListener(handler(self,self.onButtonClick));
    local Label_login = self.Button_register:getChildByName("Label_login");
    Label_login:setText(MG_TEXT_COCOS("login_ui_2_3"));

    --关 闭
    self.Button_close = Panel_3:getChildByName("Button_close");
    self.Button_close:addTouchEventListener(handler(self,self.onButtonClick));

    self.CheckBox_1 = Panel_3:getChildByName("CheckBox_1");
    self.CheckBox_1:addEventListenerCheckBox(handler(self,self.selectedEvent));

    local Label_tip1 = Panel_3:getChildByName("Label_tip1");
    Label_tip1:setText(MG_TEXT_COCOS("login_ui_2_1"));

    local Label_tip2 = Panel_3:getChildByName("Label_tip2");
    Label_tip2:setText(MG_TEXT_COCOS("login_ui_2_2"));

    NodeListener(self);
end

function registrationLayer:upData()
    

end

function registrationLayer:createEditBox(imageView)
    local sp = cc.Scale9Sprite:create();
    local editBox = cc.EditBox:create(cc.size(imageView:getSize().width * 0.90, imageView:getSize().height), sp);
    editBox:setFontSize(26);
    editBox:setFontColor(Color3B.WHITE);
    editBox:setFontName(ttf_msyh);
    editBox:setAnchorPoint(cc.p(0.5, 0.5));
    editBox:setPosition(cc.p(imageView:getSize().width/2, imageView:getSize().height / 2));
    editBox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE);
    editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_SEARCH);
    editBox:registerScriptEditBoxHandler(handler(self,self.editBoxTextEventHandler));
    imageView:addChild(editBox);

    if imageView == self.textImg_1 then
        editBox:setMaxLength(7);
        editBox:setPlaceHolder(MG_TEXT("registrationLayer_1"));
    elseif imageView == self.textImg_2 then
        -- editBox:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD);
        editBox:setPlaceHolder(MG_TEXT("registrationLayer_2"));
        editBox:setMaxLength(16);
    elseif imageView == self.textImg_3 then
        editBox:setPlaceHolder(MG_TEXT("registrationLayer_3"));
        editBox:setMaxLength(16);
    end

    return editBox;
end

function registrationLayer:editBoxTextEventHandler(strEventName,sender)
    if strEventName == "began" then

    elseif strEventName == "return" then
        if sender == self.editBox_1 then
            -- self.nameLabel = self.editBox_1:getText();
        elseif sender == self.editBox_2 then
            -- self.pswLabel = self.editBox_2:getText();
        elseif sender == self.editBox_3 then
            -- self.pswLabel_1 = self.editBox_2:getText();
        end
    end
end

function registrationLayer:selectedEvent(sender,eventType)
    if sender == self.CheckBox_1 then
        self.state = self.CheckBox_1:getSelectedState();
    end
end

function registrationLayer:onButtonClick(sender, eventType)
    buttonClickScale(sender, eventType);
    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_register then
            if self.editBox_1:getText() == "" then
                MGMessageTip:showFailedMessage(MG_TEXT("registrationLayer_6"));
                return;
            end
            if self.editBox_2:getText() == "" then
                MGMessageTip:showFailedMessage(MG_TEXT("registrationLayer_2"));
                return;
            end
            if self.editBox_3:getText() == "" then
                MGMessageTip:showFailedMessage(MG_TEXT("registrationLayer_3"));
                return;
            end

            if self.editBox_2:getText() == self.editBox_3:getText() then
                if self.state then
                    self:sendReq();
                else
                    MGMessageTip:showFailedMessage(MG_TEXT("registrationLayer_5"));
                end
            else
                MGMessageTip:showFailedMessage(MG_TEXT("registrationLayer_4"));
            end
        elseif sender == self.Button_close then
            self:removeFromParent();
        end
    end
end

function registrationLayer:onReciveData(MsgID, NetData)
    print("registrationLayer onReciveData MsgID:"..MsgID)

    -- 【注册用户】
    -- URL/index.php?c=Mobile_App&a=doRegister&v=json
    -- @Input
    --     act String 帐号
    --     pwd String 密码
    -- @Output
    --     ret Int 返回值 (1成功、-1参数错误、-2帐号已存在、-3帐号只能是子母和数字、-4长度小于6、-5长度大于20、-6账号首位不能是数字、-7检查帐号是否可用错误、 -8密码长度小于6、-9密码长度大于20、-10有屏蔽字符、-11检查密码是否可用错误、-12获取密码强度错误、-13注册帐号错误)
    --     uid Int 用户ID
    --     token String 验证串
    -- 测试地址 http://dev.97wanwan.com

    if MsgID == Post_Mobile_App_doRegister then
        if NetData.state == 1 then
            if NetData.ret == 1 then
                if self.delegate and self.delegate.setData then
                    self.delegate:setData();
                end
                self:removeFromParent();
                MGMessageTip:showFailedMessage(MG_TEXT("registrationLayer_7"));
            elseif NetData.ret == -1 then
                MGMessageTip:showFailedMessage(MG_TEXT("registrationLayer_8"));
            elseif NetData.ret == -2 then
                MGMessageTip:showFailedMessage(MG_TEXT("registrationLayer_9"));
            elseif NetData.ret == -3 then
                MGMessageTip:showFailedMessage(MG_TEXT("registrationLayer_10"));
            elseif NetData.ret == -4 then
                MGMessageTip:showFailedMessage(MG_TEXT("registrationLayer_11"));
            elseif NetData.ret == -5 then
                MGMessageTip:showFailedMessage(MG_TEXT("registrationLayer_12"));
            elseif NetData.ret == -6 then
                MGMessageTip:showFailedMessage(MG_TEXT("registrationLayer_13"));
            elseif NetData.ret == -7 then
                MGMessageTip:showFailedMessage(MG_TEXT("registrationLayer_14"));
            elseif NetData.ret == -8 then
                MGMessageTip:showFailedMessage(MG_TEXT("registrationLayer_15"));
            elseif NetData.ret == -9 then
                MGMessageTip:showFailedMessage(MG_TEXT("registrationLayer_16"));
            elseif NetData.ret == -10 then
                MGMessageTip:showFailedMessage(MG_TEXT("registrationLayer_17"));
            elseif NetData.ret == -11 then
                MGMessageTip:showFailedMessage(MG_TEXT("registrationLayer_18"));
            elseif NetData.ret == -12 then
                MGMessageTip:showFailedMessage(MG_TEXT("registrationLayer_19"));    
            elseif NetData.ret == -13 then
                MGMessageTip:showFailedMessage(MG_TEXT("registrationLayer_20"));
            end
        else
            NetHandler:showFailedMessage(NetData);
        end
    end
end

function registrationLayer:sendReq()
    local str = string.format("&act=%s&pwd=%s",self.editBox_1:getText(),self.editBox_2:getText());
    NetHandler:sendData(Post_Mobile_App_doRegister, str);
end

function registrationLayer:pushAck()
    NetHandler:addAckCode(self,Post_Mobile_App_doRegister);
end

function registrationLayer:popAck()
    NetHandler:delAckCode(self,Post_Mobile_App_doRegister);
end

function registrationLayer:onEnter()
    self:pushAck();
end

function registrationLayer:onExit()
    self:popAck();
    MGRCManager:releaseResources("registrationLayer");
end

return registrationLayer;
