-----------------------将领属性界面------------------------

mailInfo = class("mailInfo", MGLayer)

function mailInfo:ctor()
    self:init();
end

function mailInfo:init()
    local pWidget = MGRCManager:widgetFromJsonFile("mailInfo","mail_ui_3.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);--设置描边或者阴影
    
    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));
    local Panel_2 = pWidget:getChildByName("Panel_2");
    local Image_mailInfo = Panel_2:getChildByName("Image_mailInfo");
    self.Button_close = Panel_2:getChildByName("Button_close");
    self.Button_close:addTouchEventListener(handler(self,self.onButtonClick));



    local Panel_mid = Panel_2:getChildByName("Panel_mid");
    self.Panel_mid = Panel_mid;
    self.Button_ok = Panel_mid:getChildByName("Button_ok");
    self.Button_ok:addTouchEventListener(handler(self,self.onButtonClick));
    local Label_ok = self.Button_ok:getChildByName("Label_ok");
    Label_ok:setText(MG_TEXT_COCOS("mail_ui_6"));

    self.Button_replay = Panel_mid:getChildByName("Button_replay");
    self.Button_replay:addTouchEventListener(handler(self,self.onButtonClick));
    local Label_replay = self.Button_replay:getChildByName("Label_replay");
    Label_replay:setText(MG_TEXT_COCOS("mail_ui_12"));

    local Label_subject_name = Panel_mid:getChildByName("Label_subject_name");
    Label_subject_name:setText(MG_TEXT_COCOS("mail_ui_9"));
    local Label_sender_name = Panel_mid:getChildByName("Label_sender_name");
    Label_sender_name:setText(MG_TEXT_COCOS("mail_ui_10"));
    self.Label_subject = Panel_mid:getChildByName("Label_subject");
    self.Label_sender = Panel_mid:getChildByName("Label_sender");
    self.Label_time = Panel_mid:getChildByName("Label_time");
    local Label_context = Panel_mid:getChildByName("Label_context");
    Label_context:setText("");

    self.list = Panel_mid:getChildByName("ListView");
    self.Button_get = Panel_mid:getChildByName("Button_get");
    self.Button_get:addTouchEventListener(handler(self,self.onButtonClick));
    self.Label_get = self.Button_get:getChildByName("Label_get");
    self.Label_get:setText(MG_TEXT_COCOS("mail_ui_7"));
    self:setVisible(false);

    self.Label_context = MGColorLabel:label()
    self.Label_context:setAnchorPoint(cc.p(0,1));
    self.Label_context:setPosition(Label_context:getPosition());
    Panel_mid:addChild(self.Label_context)
end


function mailInfo:setData(type,id)
    --@Input    type Int 邮件类型 id Int 邮件记录ID
    local str = string.format("&type=%d&id=%d",type,id);
    NetHandler:sendData(Post_readMail, str);
end

function mailInfo:onButtonClick(sender, eventType)
    buttonClickScale(sender, eventType);
    if eventType == ccui.TouchEventType.ended then
        if sender == self.Panel_1 then
            self:removeFromParent();
        elseif sender == self.Button_close then
            self:removeFromParent();
        elseif sender == self.Button_ok then
            self:removeFromParent();
        elseif sender == self.Button_get then
            if self.data.is_affix == 1 then
                if self.delegate and self.delegate.sendgetAffix then
                    self.delegate:sendgetAffix();
                end
            end
            self:removeFromParent();
        elseif sender == self.Button_replay then
            if self.delegate and self.delegate.replayMail then
                self.delegate:replayMail(unicode_to_utf8(self.data.send_u_name));
            end
            self:removeFromParent();
        end
    end
end

function mailInfo:updata()
    if self.delegate and self.delegate.mailInfoRead then
        self.delegate:mailInfoRead();
    end
    self:setVisible(true);

    self.Label_subject:setText(unicode_to_utf8(self.data.subject));
    self.Label_context:clear();
    self.Label_context:appendStringAutoWrap(unicode_to_utf8(self.data.content),26,1,cc.c3b(255,255,255),22);
    if self.data.type == 2 then
        self.Label_sender:setText(MG_TEXT_COCOS("mail_ui_8"));
    else
        self.Label_sender:setText(unicode_to_utf8(self.data.send_u_name));
    end
    if self.data.affix == "" or tostring(self.data.affix) == "0" then
        self.list:setVisible(false);
        self.list:setTouchEnabled(false);
        self.Button_get:setEnabled(false);
        self.Button_ok:setEnabled(true);
        if self.data.type == 1 then
            self.Button_replay:setEnabled(true);
            self.Button_replay:setPositionX(self.Panel_mid:getSize().width/2-150);
            self.Button_ok:setPositionX(self.Panel_mid:getSize().width/2+150);
        else
            self.Button_replay:setEnabled(false);
        end
    else
        self.list:setVisible(true);
        self.list:setTouchEnabled(true);
        self.Button_get:setEnabled(true);
        self.Button_ok:setEnabled(false);
        self.Button_replay:setEnabled(false);
        if self.data.is_affix == 0 then
            self.Label_get:setText(MG_TEXT_COCOS("mail_ui_6"));
        else
            self.Label_get:setText(MG_TEXT_COCOS("mail_ui_7"));
        end

        local affix = getneedlist(self.data.affix);

        self.list:removeAllItems();
        local itemLay = ccui.Layout:create();
        local _width = 0;
        local _hight = self.list:getSize().height;
        for i=1,#affix do

            local gm = ResourceModel:create(affix[i].id,true);
            local item = resItem.create(self);
            item:setData(affix[i].type,affix[i].id);
            item:setNum(affix[i].num);
            item:setPosition(cc.p(item:getContentSize().width/2+(15+item:getContentSize().width)*(i-1),_hight/2));
            itemLay:addChild(item);
            _width=item:getContentSize().width+(15+item:getContentSize().width)*(i-1);
        end
        itemLay:setSize(cc.size(_width, _hight));
        self.list:pushBackCustomItem(itemLay);
        if  self.list:getSize().width > _width then
            self.list:setSize(cc.size(_width, _hight));
            self.list:setPositionX((self.Panel_mid:getSize().width-_width)/2);
        end
    end
    self.Label_time:setText(MGDataHelper:secToMonDay(self.data.send_time));
end


function mailInfo:onReciveData(MsgID, NetData)
    print("mailInfo onReciveData MsgID:"..MsgID)
    
    if MsgID == Post_readMail then
        local ackData = NetData
        if ackData.state == 1  then
            self.data  =  ackData.readmail.info;
            self:updata();

        else
            NetHandler:showFailedMessage(ackData)
            self:removeFromParent();
        end
    end
end

function mailInfo:pushAck()
    NetHandler:addAckCode(self,Post_readMail);
end

function mailInfo:popAck()
    NetHandler:delAckCode(self,Post_readMail);
end

function mailInfo:onEnter()
    self:pushAck();
end

function mailInfo:onExit()
    MGRCManager:releaseResources("mailInfo");
    self:popAck();
end

function mailInfo.create(delegate)
    local layer = mailInfo:new()
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


function mailInfo.showBox(delegate)
    local layer = mailInfo.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
