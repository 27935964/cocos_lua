-----------------------公会仓库-----日志界面------------------------

guildPackageLog = class("guildPackageLog", MGLayer)

function guildPackageLog:ctor()
    self:init();
end

function guildPackageLog:init()
    local pWidget = MGRCManager:widgetFromJsonFile("guildPackageLog","guild_package_log_ui.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);

    local Panel_2 = pWidget:getChildByName("Panel_2");
    self.ListView = Panel_2:getChildByName("ListView");
    self.ListView:setScrollBarVisible(false);

    self.CheckBox = Panel_2:getChildByName("CheckBox");
    self.CheckBox:addEventListenerCheckBox(handler(self,self.selectedEvent));

    -- local Label_tip = Panel_2:getChildByName("Label_tip");
    -- Label_tip:setText(MG_TEXT_COCOS("guild_package_log_ui_1"));

end

function guildPackageLog:setData(data)
    self.data = data;
    self.ListView:removeAllItems();
    for i=1,#self.data.log_info do
        local item = self:createItem(self.data.log_info[i]);
        self.ListView:pushBackCustomItem(item);
    end
end

function guildPackageLog:createItem(logData)
    local h = 0;
    local layout = ccui.Layout:create();
    layout:setSize(cc.size(self.ListView:getContentSize().width, 200));

    local timeLabel = cc.Label:createWithTTF(logData.date, ttf_msyh, 22);
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
    local items = {};
    for i=1,#logData.data do
        local descLabel = MGColorLabel:label();
        descLabel:setAnchorPoint(cc.p(0, 1));
        descLabel:setPosition(cc.p(200,posY));
        layout:addChild(descLabel);

        local str = self:getLogString(logData.data[i]);
        descLabel:clear();
        descLabel:appendStringAutoWrap(str,32,1,cc.c3b(255,255,255),22);

        local timeLabel_1 = cc.Label:createWithTTF(logData.data[i].action_time, ttf_msyh, 22);
        timeLabel_1:setAnchorPoint(cc.p(0,1));
        timeLabel_1:setPosition(cc.p(descLabel:getPositionX()-120,descLabel:getPositionY()));
        layout:addChild(timeLabel_1);

        posY = posY - descLabel:getContentSize().height-30;
        h = h + (descLabel:getContentSize().height+30);

        table.insert(items,{descLabel=descLabel,timeLabel_1=timeLabel_1});
    end

    layout:setSize(cc.size(self.ListView:getContentSize().width, h));
    timeLabel:setPositionY(layout:getContentSize().height-30);
    lineSpr:setPositionY(timeLabel:getPositionY()-timeLabel:getContentSize().height);
    posY = lineSpr:getPositionY()-lineSpr:getContentSize().height-20;
    for i=1,#items do
        items[i].descLabel:setPositionY(posY);
        items[i].timeLabel_1:setPositionY(items[i].descLabel:getPositionY());
        posY = posY - items[i].descLabel:getContentSize().height-30;
    end

    return layout;
end

function guildPackageLog:selectedEvent(sender,eventType)
    if self.CheckBox:getSelectedState() == true then
        self:sendReq(1);
    else
        self:sendReq(0);
    end
end

function guildPackageLog:getLogString(data)
    -- ,guildPackageLayer_log_1:"<c=187,170,100>%s</c> 申请了 <c=255,220,000>%sx%d</c>"
    -- ,guildPackageLayer_log_2:"<c=187,170,100>%s</c> 捐赠了 <c=255,220,000>%sx%d</c>"
    -- ,guildPackageLayer_log_3:"<c=187,170,100>%s</c> 捐赠了 <c=255,220,000>%sx%d，公会资金增加%d</c>"
    local str = "";
    local gm = RESOURCE:getDBResourceListByItemId(tonumber(data.item_id));
    if tonumber(data.type) == 1 then
        str = string.format(MG_TEXT("guildPackageLayer_log_1"),unicode_to_utf8(data.u_name),gm:name(),tonumber(data.item_num));
    elseif tonumber(data.type) == 2 then
        str = string.format(MG_TEXT("guildPackageLayer_log_2"),unicode_to_utf8(data.u_name),gm:name(),tonumber(data.item_num));
    elseif tonumber(data.type) == 3 then
        local num = tonumber(data.item_num)*gm:unionMoney();
        str = string.format(MG_TEXT("guildPackageLayer_log_3"),unicode_to_utf8(data.u_name),gm:name(),tonumber(data.item_num),num);
    end

    return str;
end

function guildPackageLog:onReciveData(MsgID, NetData)
    print("guildPackageLog onReciveData MsgID:"..MsgID)
    if MsgID == Post_union_getLog then
        local ackData = NetData
        if ackData.state == 1 then
            self:setData(ackData.getlog);
        else
            NetHandler:showFailedMessage(ackData)
        end
    end
end

function guildPackageLog:sendReq(only_me)
    local str = "&only_me="..only_me;--只查看自己1  不是0
    NetHandler:sendData(Post_union_getLog, str);
end

function guildPackageLog:pushAck()
    NetHandler:addAckCode(self,Post_union_getLog);
end

function guildPackageLog:popAck()
    NetHandler:delAckCode(self,Post_union_getLog);
end

function guildPackageLog:onEnter()
    self:pushAck();
    self:sendReq(0);
end

function guildPackageLog:onExit()
    self:popAck();
    MGRCManager:releaseResources("guildPackageLog");
end

function guildPackageLog.create(delegate)
    local layer = guildPackageLog:new()
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
