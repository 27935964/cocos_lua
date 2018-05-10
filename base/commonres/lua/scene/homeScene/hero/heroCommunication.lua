----------------------交际界面-------------------------

local heroCommunicationItem = require "heroCommunicationItem"
heroCommunication = class("heroCommunication", MGLayer)

function heroCommunication:ctor()
    self:init();
end

function heroCommunication:init()
    MGRCManager:cacheResource("heroCommunication", "hero_communication_ui.png", "hero_communication_ui.plist");
    local pWidget = MGRCManager:widgetFromJsonFile("heroCommunication","hero_communication_ui.ExportJson");
    self:addChild(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);

    self.heroComLayer = heroComLayer.create(self);
    self:addChild(self.heroComLayer,-1);

    local Panel_2 = pWidget:getChildByName("Panel_2");
    self.ListView = Panel_2:getChildByName("ListView");
    self.ListView:setAnchorPoint(cc.p(0,0));
    self.ListView:setScrollBarVisible(false);
    self.ListView:setItemsMargin(5);

    self.Label_tip = Panel_2:getChildByName("Label_tip");
    self.Label_tip:setVisible(false);
    self.Label_tip:setText(MG_TEXT_COCOS("hero_communication_ui_1"));

    if not self.itemWidget then
        self.itemWidget = MGRCManager:widgetFromJsonFile("heroCommunication", "hero_communication_item_ui.ExportJson",false);
        self.itemWidget:retain();
    end

    self:readSql();
end

function heroCommunication:readSql()--解析数据库数据
    local sql = "select value from config where id=61";
    local DBData = LUADB.select(sql, "value");
    self.maxLevel = tonumber(DBData.info.value);

    sql = string.format("select desc from quality");
    local DBDataList = LUADB.selectlist(sql, "desc");
    self.qualityList = DBDataList.info;
end

function heroCommunication:getFriendshipIdToReadSql(id)
    local sql = string.format("select friendship from general_list where id=%d",id);
    local DBData = LUADB.select(sql, "friendship");
    local friendshipIds = {};
    friendshipIds = getDataList(DBData.info.friendship);
    return friendshipIds;
end

function heroCommunication:getFriendshipToReadSql(f_s_id)
    local sql = string.format("select * from friendship where f_s_id=%d",f_s_id);
    local DBDataList = LUADB.selectlist(sql, "id:f_s_id:lv:need:effect:need_g_id:need_g_lv:need_g_quality:need_g_star:need_treasure_id:talk");
    self.friendships = {};
    for i=1,#DBDataList.info do
        local DBData = {};
        DBData.id = tonumber(DBDataList.info[i].id);
        DBData.f_s_id = tonumber(DBDataList.info[i].f_s_id);
        DBData.lv = tonumber(DBDataList.info[i].lv);

        DBData.need = {};
        DBData.need = getDataList(DBDataList.info[i].need);

        DBData.effect = {};
        DBData.effect = getDataList(DBDataList.info[i].effect);

        DBData.need_g_id = tonumber(DBDataList.info[i].need_g_id);
        DBData.need_g_lv = tonumber(DBDataList.info[i].need_g_lv);
        DBData.need_g_quality = tonumber(DBDataList.info[i].need_g_quality);
        DBData.need_g_star = tonumber(DBDataList.info[i].need_g_star);
        DBData.need_treasure_id = tonumber(DBDataList.info[i].need_treasure_id);
        DBData.talk = tonumber(DBDataList.info[i].talk);

        table.insert(self.friendships,DBData);
    end
    return self.friendships;
end

function heroCommunication:setData(gm)
    self.gm = gm;

    self.heroComLayer:setHero(gm);
    self.f_s_ids = self:getFriendshipIdToReadSql(self.gm:getId());

    self:sendReq();
end

function heroCommunication:initData(data)
    self.friendshipData = data;

    self.ListView:removeAllItems();
    self.items = {};
    for i=1,#self.f_s_ids do
        local friendshipData = nil;--未激活
        local friendships = self:getFriendshipToReadSql(self.f_s_ids[i].value1);
        local isFriendship = true;--有交际
        for j=1,#friendships do
            if friendships[j].need_g_id == 0 then
                isFriendship = false;--没交际
                break;
            end
        end
        if isFriendship == true then
            for j=1,#self.friendshipData.friendship do
                if self.friendshipData.friendship[j].f_s_id == self.f_s_ids[i].value1 then
                    friendshipData = self.friendshipData.friendship[j];--已激活
                    break;
                end
            end
            local item = heroCommunicationItem.create(self,self.itemWidget:clone());
            item:setData(friendships,self.maxLevel,self.qualityList,friendshipData);
            self.ListView:pushBackCustomItem(item);
            table.insert(self.items,item);
        end
    end

    if #self.items <= 0 then
        self.Label_tip:setVisible(true);
    end
end

function heroCommunication:upData(data)
    local friendship = {};
    friendship.uid = data.new_info[1];
    friendship.g_id = data.new_info[2];
    friendship.f_s_id = data.new_info[3];
    friendship.lv = data.new_info[4];

    local isAddFriendship = true;
    for j=1,#self.friendshipData.friendship do
        if self.friendshipData.friendship[j].f_s_id == friendship.f_s_id then
            self.friendshipData.friendship[j] = friendship;
            isAddFriendship = false;
            break;
        end
    end
    if isAddFriendship == true then
        table.insert(self.friendshipData.friendship,friendship);
    end

    self:initData(self.friendshipData);

    if self.delegate and self.delegate.upData then
        self.delegate:upData();
    end
end

function heroCommunication:onReciveData(MsgID, NetData)
    print("heroCommunication onReciveData MsgID:"..MsgID)

    if MsgID == Post_getFriendship then
        local ackData = NetData
        if ackData.state == 1 then
            self:initData(ackData.getfriendship);
        else
            NetHandler:showFailedMessage(ackData)
        end
    elseif MsgID == Post_doUpFriendship then
        local ackData = NetData
        if ackData.state == 1 then
            -- self:initData(ackData.getfriendship);
            self:upData(ackData.doupfriendship);
        else
            NetHandler:showFailedMessage(ackData)
        end
    end
end

function heroCommunication:sendReq()
    local str = string.format("&g_id=%d",self.gm:getId());
    NetHandler:sendData(Post_getFriendship, str);
end

function heroCommunication:upSendReq(g_id,f_s_id)
    local str = string.format("&g_id=%d&f_s_id=%d",g_id,f_s_id);
    NetHandler:sendData(Post_doUpFriendship, str);
end

function heroCommunication:pushAck()
    NetHandler:addAckCode(self,Post_getFriendship);
    NetHandler:addAckCode(self,Post_doUpFriendship);
end

function heroCommunication:popAck()
    NetHandler:delAckCode(self,Post_getFriendship);
    NetHandler:delAckCode(self,Post_doUpFriendship);
end

function heroCommunication:onEnter()
    self:pushAck();
end

function heroCommunication:onExit()
    self:popAck();
    MGRCManager:releaseResources("heroCommunication");
    if self.itemWidget then
        self.itemWidget:release();
    end
end

function heroCommunication.create(delegate)
    local layer = heroCommunication:new()
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

function heroCommunication.showBox(delegate)
    local layer = heroCommunication.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
