-----------------------公会议会厅设置界面------------------------

guildLogLayer = class("guildLogLayer", MGLayer)

function guildLogLayer:ctor()
    self:init();
end

function guildLogLayer:init()
    --创建listView
    self.listView = ccui.ListView:create();
    self.listView:setDirection(ccui.ScrollViewDir.vertical);
    self.listView:setBounceEnabled(false);
    self.listView:setAnchorPoint(cc.p(0,0));
    self.listView:setSize(cc.size(1000, 660));
    self.listView:setScrollBarVisible(false);--true添加滚动条
    self.listView:setPosition(cc.p(273,12));
    self.listView:setItemsMargin(-10);
    self:addChild(self.listView);

end

function guildLogLayer:setData(data)
    self.data = data;
    self.listView:removeAllItems();
    for i=1,#self.data.union_log do
        local item = self:createItem(self.data.union_log[i]);
        self.listView:pushBackCustomItem(item);
    end
end

function guildLogLayer:createItem(logData)
    local h = 0;
    local layout = ccui.Layout:create();
    layout:setSize(cc.size(self.listView:getContentSize().width, 200));

    local timeLabel = cc.Label:createWithTTF(logData.date, ttf_msyh, 22);
    timeLabel:setAnchorPoint(cc.p(0,0.5));
    timeLabel:setColor(cc.c3b(0,216,255));
    timeLabel:setPosition(cc.p(25,layout:getContentSize().height-30));
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

    layout:setSize(cc.size(self.listView:getContentSize().width, h));
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

function guildLogLayer:getLogString(data)
    --type Int 操作类型(1增加军团经验(name|value),2创建军团(name),3加入军团(操作name|加入name),4退出军团(name),
    --5逐出军团(操作name|权限|逐出name),6放弃职位(name|权限),7撤消职位(操作name|操作权限|撤消name|撤消权限),
    --8禅让团长(操作name|禅让name),9提升职位(操作name|操作权限|提升name|提升权限),10修改公告(name|权限),
    --16修改验证方式(name|权限),17弹劾团长(操作name|团长name),18禅让(新会长name|旧会长name))
    local str = "";
    local contents = spliteStr(data.content, '|');
    if tonumber(data.type) == 1 then

    elseif tonumber(data.type) == 2 then
        str = string.format(MG_TEXT("Union_Log_2"),contents[1]);
    elseif tonumber(data.type) == 3 then
        str = string.format(MG_TEXT("Union_Log_3"),contents[1]);
    elseif tonumber(data.type) == 4 then

    elseif tonumber(data.type) == 5 then
        local str1 = MG_TEXT("Union_"..contents[2])..contents[1];
        str = string.format(MG_TEXT("Union_Log_5"),str1,contents[3]);
    elseif tonumber(data.type) == 6 then

    elseif tonumber(data.type) == 7 then
        local str1 = MG_TEXT("Union_"..contents[2])..contents[1];
        local str2 = MG_TEXT("Union_"..contents[4]);
        str = string.format(MG_TEXT("Union_Log_7"),str1,contents[3],str2);
    elseif tonumber(data.type) == 8 then
        str = string.format(MG_TEXT("Union_Log_8"),contents[1],contents[2]);
    elseif tonumber(data.type) == 9 then
        local str1 = MG_TEXT("Union_"..contents[2])..contents[1];
        local str2 = MG_TEXT("Union_"..contents[4]);
        str = string.format(MG_TEXT("Union_Log_9"),str1,contents[3],str2);
    elseif tonumber(data.type) == 10 then
        local str1 = MG_TEXT("Union_"..contents[2])..contents[1];
        str = string.format(MG_TEXT("Union_Log_10"),str1);
    elseif tonumber(data.type) == 11 then

    elseif tonumber(data.type) == 12 then

    elseif tonumber(data.type) == 13 then

    elseif tonumber(data.type) == 14 then

    elseif tonumber(data.type) == 15 then

    elseif tonumber(data.type) == 16 then
        local str1 = MG_TEXT("Union_"..contents[2])..contents[1];
        str = string.format(MG_TEXT("Union_Log_16"),str1);
    elseif tonumber(data.type) == 17 then
        str = string.format(MG_TEXT("Union_Log_17"),contents[2],contents[1]);
    elseif tonumber(data.type) == 18 then
        str = string.format(MG_TEXT("Union_Log_18"),contents[2],contents[1]);
    end

    return str;
end

function guildLogLayer:onReciveData(MsgID, NetData)
    print("guildLogLayer onReciveData MsgID:"..MsgID)

    if MsgID == Post_getLog then
        local ackData = NetData
        if ackData.state == 1 then
            self:setData(ackData.getlog);
        else
            NetHandler:showFailedMessage(ackData)
        end
    end
end

function guildLogLayer:pushAck()
    NetHandler:addAckCode(self,Post_getLog);
end

function guildLogLayer:popAck()
    NetHandler:delAckCode(self,Post_getLog);
end

function guildLogLayer:onEnter()
    self:pushAck();
    NetHandler:sendData(Post_getLog, "");
end

function guildLogLayer:onExit()
    self:popAck();
    MGRCManager:releaseResources("guildLogLayer");
end

function guildLogLayer.create(delegate)
    local layer = guildLogLayer:new()
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
