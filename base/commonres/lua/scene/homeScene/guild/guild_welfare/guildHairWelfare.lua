-----------------------公会福利————发红包------------------------

local guildHairWelfareItem = require "guildHairWelfareItem";
guildHairWelfare = class("guildHairWelfare", MGLayer)

function guildHairWelfare:ctor()
    self.myPost = 0;
    self.curItem = nil;
    self.memberNum1 = 0;--副会长数量
    self.memberNum2 = 0;--精英数量

    self:init();
end

function guildHairWelfare:init()
    --创建ListView
    self.ListView = ccui.ListView:create();
    self.ListView:setDirection(ccui.ScrollViewDir.vertical);
    self.ListView:setBounceEnabled(false);
    self.ListView:setAnchorPoint(cc.p(0,0));
    self.ListView:setSize(cc.size(1100, 660));
    self.ListView:setScrollBarVisible(false);--true添加滚动条
    self.ListView:setPosition(cc.p(223,10));
    self.ListView:setItemsMargin(5);
    self:addChild(self.ListView);

    if not self.itemWidget then
        self.itemWidget = MGRCManager:widgetFromJsonFile("guildHairWelfare", "guild_hair_welfare_item.ExportJson",false);
        self.itemWidget:retain();
    end

    local sql = string.format("select value from config where id=108");
    local DBData = LUADB.select(sql, "value");
    self.value = tonumber(DBData.info.value);

    self:readSql();
end

function guildHairWelfare:readSql()--解析数据库数据
    self.unionRed_1 = {};
    self.unionRed_2 = {};
    local sql = string.format("select * from union_red");
    local DBDataList = LUADB.selectlist(sql, "id:name:rand_num:type:num:is_system:need:need_vip:reward");
    table.sort(DBDataList.info,function(a,b) return a.id < b.id; end);

    for index=1,#DBDataList.info do
        local DBData = {};
        DBData.id = tonumber(DBDataList.info[index].id);
        DBData.name = DBDataList.info[index].name;
        DBData.rand_num = tonumber(DBDataList.info[index].rand_num);
        DBData.type = tonumber(DBDataList.info[index].type);
        DBData.num = tonumber(DBDataList.info[index].num);
        DBData.is_system = tonumber(DBDataList.info[index].is_system);
        DBData.need_vip = tonumber(DBDataList.info[index].need_vip);

        DBData.need = spliteStr(DBDataList.info[index].need,':');
        DBData.reward = getDataList(DBDataList.info[index].reward);

        if DBData.type == 1 and DBData.is_system ~= 1 then
            table.insert(self.unionRed_1, DBData);
        elseif DBData.type == 2 and DBData.is_system ~= 1 then
            table.insert(self.unionRed_2, DBData);
        end
    end
end

function guildHairWelfare:setData(data)
    self.data = data;
    self.send_num_day = tonumber(self.data.send_num_day);

    self.ListView:removeAllItems();
    local item = self:createItem(self.unionRed_1,1);
    self.ListView:pushBackCustomItem(item);

    local item = self:createItem(self.unionRed_2,2);
    self.ListView:pushBackCustomItem(item);
end

function guildHairWelfare:createItem(data,type)
    local totalNum = #data;
    local itemIndex = 1;
    local layout = ccui.Layout:create();
    layout:setAnchorPoint(cc.p(0.5,0.5));
    layout:setSize(cc.size(self.ListView:getContentSize().width, 137*totalNum+50));
    
    local titleSpr = cc.Sprite:createWithSpriteFrameName("guild_welfare_diamond_title.png");
    local posY = layout:getContentSize().height-titleSpr:getContentSize().height/2-15;
    titleSpr:setPosition(cc.p(layout:getContentSize().width/2, posY));
    layout:addChild(titleSpr);

    if type == 1 then
        self.numLabel = MGColorLabel:label();
        self.numLabel:setAnchorPoint(cc.p(1, 0.5));
        self.numLabel:setPosition(cc.p(layout:getContentSize().width-10,titleSpr:getPositionY()));
        layout:addChild(self.numLabel);

        self.numLabel:clear();
        self.numLabel:appendStringAutoWrap(string.format(MG_TEXT("guildHairWelfare_1"),self.send_num_day
            ,self.value),16,1,cc.c3b(255,255,255),22);
    else
        titleSpr:setSpriteFrame("guild_welfare_gold_title.png");
    end

    local schedulerID = nil;
    local function loadEachItem(dt)
        if itemIndex > totalNum then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schedulerID);
            self.ListView:jumpToTop();
        else
            local item = guildHairWelfareItem.create(self,self.itemWidget:clone());
            item:setData(data[itemIndex]);
            item:setPosition(cc.p(layout:getContentSize().width/2,posY-titleSpr:getContentSize().height/2-20-
                itemIndex*item:getContentSize().height/2-(itemIndex-1)*(item:getContentSize().height/2+10)));
            layout:addChild(item);

            itemIndex = itemIndex+1;
        end
    end

    if schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schedulerID);
    end
    schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(loadEachItem, 0.001, false);

    return layout;
end

function guildHairWelfare:updateData()
    self.send_num_day = self.send_num_day + 1;
    self.numLabel:clear();
    self.numLabel:appendStringAutoWrap(string.format(MG_TEXT("guildHairWelfare_1"),self.send_num_day
        ,self.value),16,1,cc.c3b(255,255,255),22);
end

function guildHairWelfare:onReciveData(MsgID, NetData)
    print("guildHairWelfare onReciveData MsgID:"..MsgID)

    if MsgID == Post_Union_Red_getSendRedNumDay then
        local ackData = NetData
        if ackData.state == 1 then
            self:setData(ackData.getsendrednumday);
        else
            NetHandler:showFailedMessage(ackData)
        end
    elseif MsgID == Post_Union_Red_sendRed then
        local ackData = NetData
        if ackData.state == 1 then
            self:updateData(ackData.getsendrednumday);
            MGMessageTip:showFailedMessage(MG_TEXT("guildHairWelfare_3"));
        else
            NetHandler:showFailedMessage(ackData)
        end
    end
end

function guildHairWelfare:sendReq(id)
    local str = "&id="..id;
    NetHandler:sendData(Post_Union_Red_sendRed, str);
end

function guildHairWelfare:pushAck()
    NetHandler:addAckCode(self,Post_Union_Red_getSendRedNumDay);
    NetHandler:addAckCode(self,Post_Union_Red_sendRed);
end

function guildHairWelfare:popAck()
    NetHandler:delAckCode(self,Post_Union_Red_getSendRedNumDay);
    NetHandler:delAckCode(self,Post_Union_Red_sendRed);
end

function guildHairWelfare:onEnter()
    self:pushAck();
    NetHandler:sendData(Post_Union_Red_getSendRedNumDay, "");
end

function guildHairWelfare:onExit()
    self:popAck();
    MGRCManager:releaseResources("guildHairWelfare");
    if self.itemWidget then
        self.itemWidget:release();
    end
end

function guildHairWelfare.create(delegate)
    local layer = guildHairWelfare:new()
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
