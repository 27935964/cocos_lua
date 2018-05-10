-----------------------公会仓库-----审批界面------------------------

guildPackageApprove = class("guildPackageApprove", MGLayer)

function guildPackageApprove:ctor()
    self.isAll = false;
    self.icount = 0;
    self:init();
end

function guildPackageApprove:init()
    local pWidget = MGRCManager:widgetFromJsonFile("guildPackageApprove","guild_package_approve_ui.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);

    local Panel_2 = pWidget:getChildByName("Panel_2");
    self.ListView = Panel_2:getChildByName("ListView");
    self.ListView:setScrollBarVisible(false);

    self.Button_approve = Panel_2:getChildByName("Button_approve");
    self.Button_approve:addTouchEventListener(handler(self,self.onButtonClick));

    local Label_tip = Panel_2:getChildByName("Label_tip");
    Label_tip:setText(MG_TEXT_COCOS("guild_package_approve_ui_1"));

    local Label_approve = self.Button_approve:getChildByName("Label_approve");
    Label_approve:setText(MG_TEXT_COCOS("guild_package_approve_ui_2"));

end

function guildPackageApprove:setData(data)
    self.data = data;

    self.ListView:removeAllItems();
    for i=1,#self.data.apply_info do
        local item = self:createItem(self.data.apply_info[i]);
        self.ListView:pushBackCustomItem(item);
    end
end

function guildPackageApprove:createItem(applyData)
    local h = 0;
    local layout = ccui.Layout:create();
    layout:setSize(cc.size(self.ListView:getContentSize().width, 200));

    local timeLabel = cc.Label:createWithTTF(applyData.date, ttf_msyh, 22);
    timeLabel:setAnchorPoint(cc.p(0,0.5));
    timeLabel:setColor(cc.c3b(0,216,255));
    timeLabel:setPosition(cc.p(90,layout:getContentSize().height-30));
    layout:addChild(timeLabel);
    h = timeLabel:getContentSize().height+30;

    local lineSpr = ccui.ImageView:create("com_left_line3.png", ccui.TextureResType.plistType);
    lineSpr:setPosition(cc.p(layout:getContentSize().width/2, timeLabel:getPositionY()-timeLabel:getContentSize().height));
    lineSpr:setScale9Enabled(true);
    lineSpr:setCapInsets(cc.rect(5, 1, 1, 1));
    lineSpr:setSize(cc.size(952, 3));
    layout:addChild(lineSpr);
    h = h + lineSpr:getContentSize().height;

    local posY = lineSpr:getPositionY()-lineSpr:getContentSize().height-20;
    h = h + 20;
    self.items = {};
    self.ids = {};
    for i=1,#applyData.data do
        local descLabel = MGColorLabel:label();
        descLabel:setAnchorPoint(cc.p(0, 1));
        descLabel:setPosition(cc.p(250,posY));
        layout:addChild(descLabel);

        local str = self:getLogString(applyData.data[i]);
        descLabel:clear();
        descLabel:appendStringAutoWrap(str,28,1,cc.c3b(255,255,255),22);

        local timeLabel_1 = cc.Label:createWithTTF(applyData.data[i].apply_time, ttf_msyh, 22);
        timeLabel_1:setAnchorPoint(cc.p(0,1));
        timeLabel_1:setPosition(cc.p(descLabel:getPositionX()-120,descLabel:getPositionY()));
        layout:addChild(timeLabel_1);

        local btnImg1 = ccui.ImageView:create("guild_package_button_2.png", ccui.TextureResType.plistType);
        btnImg1:setPosition(cc.p(layout:getContentSize().width-200, timeLabel_1:getPositionY()-30));
        btnImg1:setTouchEnabled(true);
        layout:addChild(btnImg1);
        btnImg1:setTag(tonumber(applyData.data[i].id));
        btnImg1:addTouchEventListener(handler(self,self.onButtonClick));

        local btnImg2 = ccui.ImageView:create("guild_package_button_1.png", ccui.TextureResType.plistType);
        btnImg2:setPosition(cc.p(layout:getContentSize().width-140, timeLabel_1:getPositionY()-30));
        btnImg2:setTouchEnabled(true);
        layout:addChild(btnImg2);
        btnImg2:setTag(tonumber(applyData.data[i].id));
        btnImg2:addTouchEventListener(handler(self,self.onButtonClick));

        posY = posY - descLabel:getContentSize().height-30;
        h = h + (descLabel:getContentSize().height+30);

        table.insert(self.items,{descLabel=descLabel,timeLabel_1=timeLabel_1,btn1=btnImg1,btn2=btnImg2});
        table.insert(self.ids,tonumber(applyData.data[i].id));
    end

    layout:setSize(cc.size(self.ListView:getContentSize().width, h));
    timeLabel:setPositionY(layout:getContentSize().height-30);
    lineSpr:setPositionY(timeLabel:getPositionY()-timeLabel:getContentSize().height);
    posY = lineSpr:getPositionY()-lineSpr:getContentSize().height-20;
    for i=1,#self.items do
        self.items[i].descLabel:setPositionY(posY);
        self.items[i].timeLabel_1:setPositionY(self.items[i].descLabel:getPositionY());
        self.items[i].btn1:setPositionY(self.items[i].timeLabel_1:getPositionY()-10);
        self.items[i].btn2:setPositionY(self.items[i].timeLabel_1:getPositionY()-10);
        posY = posY - self.items[i].descLabel:getContentSize().height-30;
    end

    return layout;
end

function guildPackageApprove:onButtonClick(sender, eventType)
    buttonClickScale(sender, eventType);
    if eventType == ccui.TouchEventType.began then
        if sender == self.Button_approve then
            self.isAll = true;
            self.icount = 1;
            self:sendReq(self.ids[1]);
        else
            for i=1,#self.items do
                if sender == self.items[i].btn1 then
                    self.isAll = false;
                    self:sendReq(sender:getTag());
                    break;
                elseif sender == self.items[i].btn2 then
                    self:sendReq(sender:getTag());
                    break;
                end
            end
        end
    end
end

function guildPackageApprove:getLogString(data)
    -- ,guildPackageLayer_log_1:"<c=187,170,100>%s</c> 申请了 <c=255,220,000>%sx%d</c>"
    -- ,guildPackageLayer_log_2:"<c=187,170,100>%s</c> 捐赠了 <c=255,220,000>%sx%d</c>"
    -- ,guildPackageLayer_log_3:"<c=187,170,100>%s</c> 捐赠了 <c=255,220,000>%sx%d，公会资金增加%d</c>"
    local str = "";
    local gm = RESOURCE:getResModelByItemId(tonumber(data.item_id));
    str = string.format(MG_TEXT("guildPackageLayer_log_1"),unicode_to_utf8(data.u_name),gm:name(),tonumber(data.item_num));

    return str;
end

function guildPackageApprove:onReciveData(MsgID, NetData)
    print("guildPackageApprove onReciveData MsgID:"..MsgID)

    if MsgID == Post_union_getApply then
        local ackData = NetData
        if ackData.state == 1 then
            self:setData(ackData.getapply);
        else
            NetHandler:showFailedMessage(ackData);
        end
    elseif MsgID == Post_union_agreeApply then
        local ackData = NetData
        if ackData.state == 1 then
            if self.isAll == true then--一键审批
                self.icount = self.icount + 1;
                if self.icount > #self.ids then
                    self.icount = 0;
                    self.isAll = false;
                    if ackData.getapply then
                        self:setData(ackData.getapply);
                    end
                    MGMessageTip:showFailedMessage(MG_TEXT("guildPackageApprove_1"));
                else
                    self:sendReq(self.ids[self.icount]);
                end
            else
                self:setData(ackData.getapply);
            end
        else
            if self.isAll == true and ackData.state == -2 then--一键审批
                self.icount = self.icount + 1;
                if self.icount > #self.ids then
                    self.icount = 0;
                    self.isAll = false;
                    if ackData.getapply then
                        self:setData(ackData.getapply);
                    end
                    MGMessageTip:showFailedMessage(MG_TEXT("guildPackageApprove_1"));
                else
                    self:sendReq(self.ids[self.icount]);
                end
            else
                NetHandler:showFailedMessage(ackData);
            end
        end
    elseif MsgID == Post_union_cancelApply then
        local ackData = NetData
        if ackData.state == 1 then
            self:setData(ackData.getapply);
        else
            NetHandler:showFailedMessage(ackData);
        end
    end
end

function guildPackageApprove:sendReq(id)
    local str = "&id="..id;
    NetHandler:sendData(Post_union_agreeApply, str);
end

function guildPackageApprove:sendCancelApplyReq(id)
    local str = "&id="..id;
    NetHandler:sendData(Post_union_cancelApply, str);
end

function guildPackageApprove:pushAck()
    NetHandler:addAckCode(self,Post_union_getApply);
    NetHandler:addAckCode(self,Post_union_agreeApply);
    NetHandler:addAckCode(self,Post_union_cancelApply);
end

function guildPackageApprove:popAck()
    NetHandler:delAckCode(self,Post_union_getApply);
    NetHandler:delAckCode(self,Post_union_agreeApply);
    NetHandler:delAckCode(self,Post_union_cancelApply);
end

function guildPackageApprove:onEnter()
    self:pushAck();
    NetHandler:sendData(Post_union_getApply, "");
end

function guildPackageApprove:onExit()
    self:popAck();
    MGRCManager:releaseResources("guildPackageApprove");
end

function guildPackageApprove.create(delegate)
    local layer = guildPackageApprove:new()
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
