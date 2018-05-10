------------------------登录界面管理-------------------------

LoginLayer = class("LoginLayer", MGLayer)

function LoginLayer:ctor()
    self.nameLabel = "husong1"--"dys0001" husong1
    self.pswLabel = "admins"--"123456" admins
    self.height = 60;
    self.state_1 = false;
    self.state_2 = false;
    self:init();
end

function LoginLayer:init()
    MGRCManager:cacheResource("LoginLayer", "login_bg_1.png");

    MGRCManager:cacheResource("LoginLayer", "login_bg.jpg");
    MGRCManager:cacheResource("LoginLayer", "login_box.jpg");
    MGRCManager:cacheResource("LoginLayer", "LoginLayer_ui0.png","LoginLayer_ui0.plist");
    local pWidget = MGRCManager:widgetFromJsonFile("LoginLayer","login_ui_1.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:setAnchorPoint(cc.p(0.5, 0.5));
    CommonMethod:setFullBgScale(self.Panel_1);

    local Panel_2 = pWidget:getChildByName("Panel_2");
    local Image_bg1 = Panel_2:getChildByName("Image_bg1");

    self.Panel_account = Panel_2:getChildByName("Panel_account");
    self.Panel_account:setVisible(false);
    self.Panel_account:setAnchorPoint(cc.p(0,1));
    self.Panel_account:setPositionY(self.Panel_account:getPositionY()+self.Panel_account:getContentSize().height)

    self.Image_line1 = self.Panel_account:getChildByName("Image_line1");
    self.Image_line2 = self.Panel_account:getChildByName("Image_line2");

    self.ListView = self.Panel_account:getChildByName("ListView");
    self.ListView:setScrollBarVisible(false);
    self.ListView:setTouchEnabled(false);

    local Panel_3 = Panel_2:getChildByName("Panel_3");
    self.textImg_1 = Panel_3:getChildByName("Image_box1");
    self.editBox_1 = self:createEditBox(self.textImg_1);

    self.textImg_2 = Panel_3:getChildByName("Image_box2");
    self.editBox_2 = self:createEditBox(self.textImg_2);

    if SAVESET:getUser() ~= "" and SAVESET:getPsw() ~= "" then
        self.editBox_1:setText(SAVESET:getUser());
        self.editBox_2:setText(SAVESET:getPsw());
        self.nameLabel = SAVESET:getUser();
        self.pswLabel = SAVESET:getPsw();
    end

    --登 录
    self.Button_login = Panel_3:getChildByName("Button_login");
    self.Button_login:addTouchEventListener(handler(self,self.onButtonClick));
    local Label_login = self.Button_login:getChildByName("Label_login");
    Label_login:setText(MG_TEXT_COCOS("login_ui_1"));

    --注 册
    self.Button_register = Panel_3:getChildByName("Button_register");
    self.Button_register:addTouchEventListener(handler(self,self.onButtonClick));
    local Label_register = self.Button_register:getChildByName("Label_register");
    Label_register:setText(MG_TEXT_COCOS("login_ui_2"));

    --下 拉
    self.Panel_down = Panel_3:getChildByName("Panel_down");
    -- self.Panel_down:setTouchEnabled(true);

    -- self.Panel_down:setBackGroundColorType(1);
    -- self.Panel_down:setBackGroundColor(cc.c3b(0,255,250));

    self.Button_down = self.Panel_down:getChildByName("Button_down");
    -- self.Button_down:setTouchEnabled(false);
    self.Button_down:addTouchEventListener(handler(self,self.onButtonClick));

    self.Panel_close = Panel_2:getChildByName("Panel_close");
    self.Panel_close:setTouchEnabled(false);
    self.Panel_close:addTouchEventListener(handler(self,self.onButtonClick));

    self.CheckBox_1 = Panel_3:getChildByName("CheckBox_1");
    self.CheckBox_1:addEventListenerCheckBox(handler(self,self.selectedEvent));
    self.CheckBox_1:setSelectedState(true);

    self.CheckBox_2 = Panel_3:getChildByName("CheckBox_2");
    self.CheckBox_2:addEventListenerCheckBox(handler(self,self.selectedEvent));
    self.CheckBox_2:setSelectedState(true);

    local Label_tip1 = Panel_3:getChildByName("Label_tip1");
    Label_tip1:setText(MG_TEXT_COCOS("login_ui_3"));

    local Label_tip2 = Panel_3:getChildByName("Label_tip2");
    Label_tip2:setText(MG_TEXT_COCOS("login_ui_4"));
    
    
end

function LoginLayer:setData(info)
    self:upData();
    self.editBox_1:setText("");
    self.editBox_2:setText("");
    self.info = info;
    if nil == self.info then
        return;
    end
    print_lua_table(info);
    if self.info.isAutoLogin then
        self.CheckBox_1:setSelectedState(true);
        self.CheckBox_2:setSelectedState(true);
        self.editBox_1:setText(self.info.name);
        self.editBox_2:setText(self.info.psw);
    else
        if self.info.isSave then
            self.CheckBox_1:setSelectedState(true);
            self.CheckBox_2:setSelectedState(false);
            self.editBox_1:setText(self.info.name);
            self.editBox_2:setText(self.info.psw);
        else
            self.CheckBox_1:setSelectedState(false);
            self.CheckBox_2:setSelectedState(false);
            self.editBox_1:setText(self.info.name);
        end
    end

end

function LoginLayer:upData()
    self.data = self:gerUserName();

    self.items = {};
    self.ListView:removeAllItems();
    if self.data and #self.data > 0 then
        local itemLay = ccui.Layout:create();
        itemLay:setSize(cc.size(self.ListView:getContentSize().width,self.height*#self.data));
        self.ListView:pushBackCustomItem(itemLay);

        itemLay:setBackGroundColorType(1);
        itemLay:setBackGroundColor(cc.c3b(128,128,128));
        itemLay:setBackGroundColorOpacity(200);

        posY = itemLay:getContentSize().height-self.height/2;
        for i=1,#self.data do
            local item = self:createItem(i);
            item:setTag(i);
            item:setPosition(cc.p(itemLay:getContentSize().width/2,posY));
            itemLay:addChild(item);
            posY = posY-item:getContentSize().height;
        end
    end
end

function LoginLayer:createItem(i)
    local modNum = math.mod(i,2);

    local layout = ccui.Layout:create();
    layout:setAnchorPoint(cc.p(0.5,0.5));
    layout:setSize(cc.size(self.Panel_account:getContentSize().width,self.height));
    layout:setTouchEnabled(false);
    layout:addTouchEventListener(handler(self,self.onClick));

    if modNum == 1 then
        layout:setBackGroundColorType(1);
        layout:setBackGroundColor(cc.c3b(0,0,0));
        layout:setBackGroundColorOpacity(180);
    end

    local nameLabel = cc.Label:createWithTTF("",ttf_msyh,22);
    nameLabel:setPosition(cc.p(layout:getContentSize().width/2,layout:getContentSize().height/2));
    layout:addChild(nameLabel);

    local str = self.data[i].name;
    nameLabel:setString(str);

    if i == 1 then
        local lineImg1 = ccui.ImageView:create("login_top_line.png", ccui.TextureResType.plistType);
        lineImg1:setPosition(cc.p(layout:getContentSize().width/2, layout:getContentSize().height-3));
        layout:addChild(lineImg1,1);
    end

    if i == #self.data then
        local lineImg2 = ccui.ImageView:create("login_top_line.png", ccui.TextureResType.plistType);
        lineImg2:setPosition(cc.p(layout:getContentSize().width/2, 5));
        lineImg2:setScaleY(-1);
        layout:addChild(lineImg2,1);
    end

    table.insert(self.items,{item=layout,data=self.data[i]});

    return layout;
end

function LoginLayer:createEditBox(imageView)
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
        editBox:setPlaceHolder(MG_TEXT("LoginLayer_tip_1"));
    elseif imageView == self.textImg_2 then
        editBox:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD);
        editBox:setPlaceHolder(MG_TEXT("LoginLayer_tip_2"));
        editBox:setMaxLength(16);
    end

    return editBox;
end

function LoginLayer:editBoxTextEventHandler(strEventName,sender)
    if strEventName == "began" then

    elseif strEventName == "return" then
        if sender == self.editBox_1 then
            self.nameLabel = self.editBox_1:getText();
        elseif sender == self.editBox_2 then
            self.pswLabel = self.editBox_2:getText();
        end
    end
end

function LoginLayer:selectedEvent(sender,eventType)
    if sender == self.CheckBox_1 then
        if self.CheckBox_1:getSelectedState() == false then
            self.CheckBox_2:setSelectedState(false);
        end
    elseif sender == self.CheckBox_2 then
        if self.CheckBox_2:getSelectedState() == true then
            self.CheckBox_1:setSelectedState(true);
        end
    end
end

function LoginLayer:getUserInfo(sess_id,account)
    local userDefault=cc.UserDefault:getInstance();
    local data=nil;
    local dataKey="UserInfo".."_"..tostring(sess_id).."_"..tostring(account);
    local dataStr=userDefault:getStringForKey(dataKey);
    
    if dataStr==nil or dataStr=="" then
        return;
    else

    end
end

--取本地登录信息
function LoginLayer:gerUserName()
    local userDefault=cc.UserDefault:getInstance();
    local data={};
    local dataKey="user_login";
    local dataStr=userDefault:getStringForKey(dataKey);
    if dataStr==nil or dataStr=="" then
        return data;
    else
        data=cjson.decode(dataStr);
        return data;
    end
    return data;
end

function LoginLayer:onClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        for i=1,#self.items do
            if sender == self.items[i].item then
                self.editBox_1:setText(self.items[i].data.name);
                break;
            end
        end
        self:setData(self.data[sender:getTag()]);
        self.Panel_close:setTouchEnabled(false);
        self.Panel_account:setVisible(false);
        self.ListView:setTouchEnabled(false);
        self.ListView:removeAllItems();
    end
end

function LoginLayer:onButtonClick(sender, eventType)
    buttonClickScale(sender, eventType);
    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_login then--登 录
            if self.editBox_1:getText() == "" then
                MGMessageTip:showFailedMessage(MG_TEXT("LoginLayer_tip_1"));
                return;
            elseif self.editBox_2:getText() == "" then
                MGMessageTip:showFailedMessage(MG_TEXT("LoginLayer_tip_2"));
                return;
            else
                NetHandler:addAckCode(self,Post_doPassportLogin);
                self:sendReq(self.editBox_1:getText(),self.editBox_2:getText());
            end
        
        elseif sender == self.Button_register then--注 册
            local registrationLayer = require "registrationLayer";
            local registration = registrationLayer.new(self);
            self:addChild(registration);
        elseif sender == self.Panel_down or sender == self.Button_down then--下 拉
            self:upData();
            self.Panel_account:setVisible(true);
            self.Panel_close:setTouchEnabled(true);
            self.ListView:setTouchEnabled(true);
            for i=1,#self.items do
                self.items[i].item:setTouchEnabled(true);
            end
        elseif sender == self.Panel_close then
            self.Panel_close:setTouchEnabled(false);
            self.Panel_account:setVisible(false);
            self.ListView:setTouchEnabled(false);
            for i=1,#self.items do
                self.items[i].item:setTouchEnabled(false);
            end
            self.ListView:removeAllItems();
        end
    end
end

function LoginLayer:onReciveData(MsgID, NetData)
    print("LoginLayer onReciveData MsgID:"..MsgID)
    if MsgID == Post_doPassportLogin then
        if NetData.state == 1 then
            NetHandler:delAckCode(self,Post_doPassportLogin);
            local function login()--延时调用（因为苹果电脑输入框无法马上获取输入的值）
                require "EnterLogin"
                local enterLogin = EnterLogin.showBox(self);
                self.state_1 = self.CheckBox_1:getSelectedState();
                self.state_2 = self.CheckBox_2:getSelectedState();
                enterLogin:setData(self.editBox_1:getText(),self.editBox_2:getText(),2,self.state_1,self.state_2);
                
                enterLogin:sendReqDoLogin(NetData.dopassportlogin.account,NetData.dopassportlogin.sess_id);

            end
            local time = cc.DelayTime:create(0.1);
            local func = cc.CallFunc:create(login);
            local sq = cc.Sequence:create(time,func);
            self:runAction(sq);
        else
            NetHandler:showFailedMessage(NetData);
        end
    end
end

function LoginLayer:sendReq(nameLabel,pswLabel)
    local str = string.format("&account=%s&pwd=%s&sid=%d",nameLabel,pswLabel,1);
    NetHandler:sendData(Post_doPassportLogin, str);
end

function LoginLayer:onEnter()
end

function LoginLayer:onExit()
    MGRCManager:releaseResources("LoginLayer");
end

function LoginLayer.create(delegate)
    local layer = LoginLayer:new()
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

function LoginLayer.showBox(delegate)
    local layer = LoginLayer.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
