-----------------------邮件界面------------------------


mailLayer = class("mailLayer", MGLayer)

function mailLayer:ctor()
    self.mailItemWidget = nil;
    self.allAffix = false;
    self:init();
    self.sender= nil;
    self.subject= nil;
    self.context= nil;
end

function mailLayer:init()
    MGRCManager:cacheResource("mailLayer", "package_bg.jpg");
    MGRCManager:cacheResource("mailLayer", "rank_head_bg.png");
    MGRCManager:cacheResource("mailLayer", "rank_bottom_Bg.png");
    
    local size = cc.Director:getInstance():getWinSize();
    local bgSpr = cc.Sprite:create("package_bg.jpg");
    bgSpr:setPosition(cc.p(size.width/2, size.height));
    bgSpr:setAnchorPoint(cc.p(0.5,1));
    self:addChild(bgSpr);
    CommonMethod:setFullBgScale(bgSpr);


    local pWidget = MGRCManager:widgetFromJsonFile("mailLayer","mail_ui_1.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);--设置描边或者阴影

    if not self.mailItemWidget then
        self.mailItemWidget = MGRCManager:widgetFromJsonFile("mailLayer", "mail_ui_2.ExportJson");
        self.mailItemWidget:retain()
    end

    require "PanelTop";
    self.pPanelTop = PanelTop.create(self)
    self.pPanelTop:setData("mail_title.png");
    self:addChild(self.pPanelTop,10);
    
    local Panel_2 = pWidget:getChildByName("Panel_2");
    local Panel_left = Panel_2:getChildByName("Panel_left");
    self.list = Panel_left:getChildByName("ListView_left");
    local Label_tip = Panel_left:getChildByName("Label_tip");
    Label_tip:setText(MG_TEXT_COCOS("mail_ui_1"));

    local Panel_mid = Panel_2:getChildByName("Panel_mid");
    self.Panel_mid =  Panel_mid;
    self.listmail = Panel_mid:getChildByName("ListView");
    self.Image_head = Panel_mid:getChildByName("Image_head");
    local Image_bottom = Panel_mid:getChildByName("Image_bottom");
    self.Label_null = Panel_mid:getChildByName("Label_null");
    self.Label_null:setText(MG_TEXT_COCOS("mail_ui_2"));
    self.Button_do  = Panel_mid:getChildByName("Button_do");
    self.Button_do:addTouchEventListener(handler(self,self.onBtnClick));
    self.Label_btn = self.Button_do:getChildByName("Label_btn");
    self.Label_btn:setText(MG_TEXT_COCOS("mail_ui_3"));
    self.CheckBox = Panel_mid:getChildByName("CheckBox")
    local Label_check = self.CheckBox:getChildByName("Label_check");
    Label_check:setText(MG_TEXT_COCOS("mail_ui_5"));
    self.CheckBox:addEventListenerCheckBox(handler(self,self.selectedEvent));

    local Panel_send = Panel_2:getChildByName("Panel_send");
    self.Panel_send =  Panel_send;
    self.Panel_send:setVisible(false);

    local Label_subject_name = Panel_send:getChildByName("Label_subject_name");
    Label_subject_name:setText(MG_TEXT_COCOS("mail_ui_9"));
    local Label_sender_name = Panel_send:getChildByName("Label_sender_name");
    Label_sender_name:setText(MG_TEXT_COCOS("mail_ui_10"));
    self.Button_send  = Panel_send:getChildByName("Button_send");
    self.Button_send:addTouchEventListener(handler(self,self.onBtnClick));
    self.Label_send = self.Button_send:getChildByName("Label_send");
    self.Label_send:setText(MG_TEXT_COCOS("mail_ui_11"));
    self.Button_sel  = Panel_send:getChildByName("Button_sel");
    self.Button_sel:addTouchEventListener(handler(self,self.onBtnClick));
    
    self.Image_subject = Panel_send:getChildByName("Image_subject");
    self.editBox_subject = self:createEditBox(self.Image_subject);
    self.Image_sender = Panel_send:getChildByName("Image_sender");
    self.editBox_sender = self:createEditBox(self.Image_sender);
    self.Image_context = Panel_send:getChildByName("Image_context");
    self.editBox_context = self:createEditBox(self.Image_context);

    self.Panel_txt = self.Image_context:getChildByName("Panel_txt");
    self.Label_txt = self.Panel_txt:getChildByName("Label_txt");

    self:createlist();
end

function mailLayer:createEditBox(imageView)
    local sp = cc.Scale9Sprite:create();
    local editBox = cc.EditBox:create(cc.size(imageView:getSize().width * 0.96, imageView:getSize().height), sp);
    editBox:setFontSize(22);
    editBox:setFontColor(Color3B.WHITE);
    editBox:setFontName(ttf_msyh);
    editBox:setAnchorPoint(cc.p(0.5, 0.5));
    editBox:setPosition(cc.p(imageView:getSize().width/2, imageView:getSize().height / 2));
    editBox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE);
    editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_SEARCH);
    editBox:registerScriptEditBoxHandler(handler(self,self.editBoxTextEventHandler));
    imageView:addChild(editBox);

    if imageView == self.Image_subject then
        editBox:setMaxLength(32);
    elseif imageView == self.Image_sender then--UTF8_COMPUTE 计数字符串长度 没长度返回-1
        editBox:setMaxLength(32);
    elseif imageView == self.Image_context then--UTF8_COMPUTE 计数字符串长度 没长度返回-1
        editBox:setMaxLength(250);
    end

    return editBox;
end


function mailLayer:editBoxTextEventHandler(strEventName,sender)
    if strEventName == "began" then
        if sender == self.editBox_context then
            --self.Panel_txt:setVisible(false);
            self.editBox_context:setText(self.Label_txt:getStringValue())
        end
    elseif strEventName == "return" then
        if sender == self.editBox_subject then
            self.subject = self.editBox_subject:getText();
        elseif sender == self.editBox_sender then
            self.sender = self.editBox_sender:getText();
        elseif sender == self.editBox_context then
            self.context = self.editBox_context:getText();
            self.editBox_context:setText("")
            --self.Panel_txt:setVisible(true);
            self.Label_txt:setText(self.context)
        end
    end
end

function mailLayer:onBtnClick(sender, eventType)
    buttonClickScale(sender, eventType);
    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_do then
            if self.selItem.info.id == 1 then
                self.allAffix = true;
                self:getallAffix();
            elseif self.selItem.info.id == 2 or self.selItem.info.id == 3 then
                self:senddelMail()
            end
        elseif sender == self.Button_send then
            if nil == self.sender or string.len(self.sender) <= 0 then
                MGMessageTip:showFailedMessage(MG_TEXT("mail_send_1"));
            elseif nil == self.subject or string.len(self.subject) <= 0  then
                MGMessageTip:showFailedMessage(MG_TEXT("mail_send_2"));
            elseif nil == self.context or string.len(self.context) <= 0  then
                MGMessageTip:showFailedMessage(MG_TEXT("mail_send_3"));
            else
                self:sendMail();
            end
        elseif sender == self.Button_sel then
            require "mailSel";
            local mailSel = mailSel.create(self);
            cc.Director:getInstance():getRunningScene():addChild(mailSel,ZORDER_MAX);
        end
    end
end


function mailLayer:selectedEvent(sender,eventType)
    local maillist = self.listmail:getItems();
    for i=1,#maillist do
        maillist[i].CheckBox:setSelectedState(self.CheckBox:getSelectedState())
    end
end

function mailLayer:getallAffix()
    local maillist = self.listmail:getItems();
    for i=1,#maillist do
        if maillist[i].info.is_affix==1 then
            self.mailItem = maillist[i];
            self:sendgetAffix();
            break;
        end
    end
    self.allgetAffix = false;
end

function mailLayer:createlist()
    self.list:removeAllItems();
    require "mailleftItem";
    local mail=require "mail";
    for i=1,#mail do
        local mailleftItem = mailleftItem.create(self);
        mailleftItem:setData(mail[i]);
        self.list:pushBackCustomItem(mailleftItem);
        if i==1 then
            self:mailleftItemSelect(mailleftItem);
        end
        if i==4 then
            self.sendItem = mailleftItem;
        end
    end
end

function mailLayer:back()
    self:removeFromParent();
end

function mailLayer:mailleftItemSelect(item)
    if  self.selItem~=item then
        if self.selItem then
            self.selItem:Select(false);
        end
        self.selItem = item;
        self.selItem:Select(true);

        
        self.page = 1;
        self:getmail();
        
    end
end

function mailLayer:getmail()

    if self.selItem.info.id == 4 then
        self.Panel_send:setVisible(true);
        self.Panel_send:setScale(1);
        self.Panel_mid:setVisible(false);
        self.Panel_mid:setScale(0);
        --self.editBox_subject:setText("");
        --self.editBox_sender:setText("");
        --self.editBox_context:setText("");
    else
        self.Panel_send:setVisible(false);
        self.Panel_send:setScale(0);
        self.Panel_mid:setVisible(true);
        self.Panel_mid:setScale(1);
        self.listmail:removeAllItems();
        self.CheckBox:setVisible(false);
        self.Button_do:setEnabled(false);
        self.Label_null:setVisible(false);
        self:sendReq();
    end
end

function mailLayer:mailItemSelect(item)
    self.mailItem = item;
    require "mailInfo";
    local mailInfo = mailInfo.create(self);
    mailInfo:setData(item.info.type,item.info.id);
    cc.Director:getInstance():getRunningScene():addChild(mailInfo,ZORDER_MAX);
end

function mailLayer:mailInfoRead()
    if self.mailItem.info.is_read ==0 then
        self.mailItem.info.is_read = 1;
        self.mailItem:upData();
    end
end


function mailLayer:showmail()
    require "mailItem";
    local count = 0;
    local is_affix = false;
    for i=1,#self.maillist do
        local mailItem = mailItem.create(self,self.mailItemWidget:clone());
        mailItem:setData(self.selItem.info.id,self.maillist[i]);
        self.listmail:pushBackCustomItem(mailItem);
        count = count+1;
        if self.maillist[i].is_affix==1 then
            is_affix = true;
        end
    end

    if count>0 then
        self.Label_null:setVisible(false);
        self.Button_do:setEnabled(true);
        if self.selItem.info.id ==1 then
            self.Label_btn:setText(MG_TEXT_COCOS("mail_ui_3"));
        else
            self.CheckBox:setVisible(true);
            self.Label_btn:setText(MG_TEXT_COCOS("mail_ui_4"));
        end

        if self.selItem.info.id == 1 then
            if is_affix then
                self.Button_do:setEnabled(true);
            else
                self.Button_do:setEnabled(false);
            end
        else
            self.Button_do:setEnabled(true);
        end
    else
        self.Label_null:setVisible(true);
    end
end

function mailLayer:replayMail(u_name)
    self:mailleftItemSelect(self.sendItem);
    self.editBox_sender:setText(u_name);
    self.sender =  u_name;
end

function mailLayer:mailSelItemSelect(u_name)
    self.editBox_sender:setText(u_name);
    self.sender =  u_name;
end

function mailLayer:sendReq()
    --@@Input    type Int 邮件类型  c_page Int 当前页数
    local str = string.format("&type=%d&c_page=%d",self.selItem.info.type,self.page);
    NetHandler:sendData(Post_getMailInfo, str);
end

function mailLayer:sendMail()
    --@Input    name String 接收方用户名 subject String 邮件标题 content String 邮件内容
    local str = string.format("&name=%s&subject=%s&content=%s",self.sender,self.subject,self.context);
    NetHandler:sendData(Post_sendMail, str);
end


function mailLayer:sendgetAffix()
    -- @Input    id Int 邮件记录ID del 0 or 1 default 1 是否删除邮件
    local str = string.format("&id=%d&del=0",self.mailItem.info.id);
    NetHandler:sendData(Post_getAffix, str);
end

function mailLayer:senddelMail()
    -- @Input type Int 邮件类型 ids Array or Int 删除邮件记录ID all 0 or 1 default 0 是否清空邮件
    local ids = {}
    local maillist = self.listmail:getItems();
    for i=1,#maillist do
        if maillist[i].CheckBox:getSelectedState() then
            table.insert( ids, maillist[i].info.id );
        end
    end
    if #ids>0 then
        local strids = cjson.encode(ids)
        local str = string.format("&type=%d&ids=%s&del=0",self.selItem.info.type,strids);
        NetHandler:sendData(Post_delMail, str);
    end
end


function mailLayer:onReciveData(MsgID, NetData)
    print("mailLayer onReciveData MsgID:"..MsgID)
    
    if MsgID == Post_getMailInfo then
        local ackData = NetData
        if ackData.state == 1 then
            self.maillist = ackData.getmailinfo.info;
            self:showmail();
        else
            NetHandler:showFailedMessage(ackData)
        end
    elseif MsgID == Post_getAffix then
        local ackData = NetData
        if ackData.state == 1  then
            self.mailItem.info.is_affix = 0;
            self.mailItem:upData();
            self.pPanelTop:upData()
            if self.allAffix then
                self:getallAffix();
            end
        else
            NetHandler:showFailedMessage(ackData)
        end
    elseif MsgID == Post_delMail then
        local ackData = NetData
        if ackData.state == 1  then
            self:getmail();
        else
            NetHandler:showFailedMessage(ackData)
        end
    elseif MsgID == Post_sendMail then
        local ackData = NetData
        if ackData.state == 1  then
            
            self.editBox_subject:setText("");
            --self.editBox_sender:setText("");
            self.editBox_context:setText("");
            --self.sender= nil;
            self.subject= nil;
            self.context= nil;
            MGMessageTip:showFailedMessage(MG_TEXT("mail_send_suc"));
        else

            NetHandler:showFailedMessage(ackData)
        end
    end
    
end



function mailLayer:pushAck()
    NetHandler:addAckCode(self,Post_getMailInfo);
    NetHandler:addAckCode(self,Post_getAffix);
    NetHandler:addAckCode(self,Post_delMail);
    NetHandler:addAckCode(self,Post_sendMail);

end

function mailLayer:popAck()
    NetHandler:delAckCode(self,Post_getMailInfo);
    NetHandler:delAckCode(self,Post_getAffix);
    NetHandler:delAckCode(self,Post_delMail);
    NetHandler:delAckCode(self,Post_sendMail);
end

function mailLayer:onEnter()
    self:pushAck();
end

function mailLayer:onExit()
    if self.mailItemWidget then
        self.mailItemWidget:release()
    end
    MGRCManager:releaseResources("mailLayer");
    self:popAck();
end

function mailLayer.create(delegate)
    local layer = mailLayer:new()
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


function mailLayer.showBox(delegate)
    local layer = mailLayer.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
