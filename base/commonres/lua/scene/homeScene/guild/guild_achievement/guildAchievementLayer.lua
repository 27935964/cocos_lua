-----------------------公会成就界面------------------------

local guildAchievementItem = require "guildAchievementItem"
guildAchievementLayer = class("guildAchievementLayer", MGLayer)

function guildAchievementLayer:ctor()
    self.curItem = nil;
    self.getId = 1;
    self:init();
end

function guildAchievementLayer:init()
    MGRCManager:cacheResource("guildAchievementLayer", "GuildAchievement_Hero.png");
    MGRCManager:cacheResource("guildAchievementLayer", "GuildAchievement_item_bg.png");
    local pWidget = MGRCManager:widgetFromJsonFile("guildAchievementLayer","GuildAchievement_ui.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);

    self.pPanelTop = PanelTop.create(self)
    self.pPanelTop:setData("guild_achievement_title.png");
    self:addChild(self.pPanelTop,10);
    self.pPanelTop:showRankCoin(false);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:setAnchorPoint(cc.p(0.5, 0.5));
    CommonMethod:setFullBgScale(self.Panel_1);

    local Panel_2 = pWidget:getChildByName("Panel_2");
    self.Label_num = Panel_2:getChildByName("Label_num");--当前攻占城池数

    self.ListView = Panel_2:getChildByName("ListView");
    self.ListView:setScrollBarVisible(false);


    local Label_CurrentCapture = Panel_2:getChildByName("Label_CurrentCapture");
    Label_CurrentCapture:setText(MG_TEXT_COCOS("GuildAchievement_ui_1"));

    if not self.itemWidget then
        self.itemWidget = MGRCManager:widgetFromJsonFile("guildMercenaryLayer", "GuildAchievement_ui_item.ExportJson",false);
        self.itemWidget:retain();
    end

    -- local sql = string.format("select value from config where id=117");
    -- local DBData = LUADB.select(sql, "value");
    -- self.value = tonumber(DBData.info.value);

    self:readSql();
end

function guildAchievementLayer:readSql()--解析数据库数据
    self.union_achievement = {};
    local sql = string.format("select * from union_achievement");
    local DBDataList = LUADB.selectlist(sql, "id:city_num:reward");
    table.sort(DBDataList.info,function(a,b) return a.id < b.id; end);

    for index=1,#DBDataList.info do
        local DBData = {};
        DBData.id = tonumber(DBDataList.info[index].id);
        DBData.city_num = tonumber(DBDataList.info[index].city_num);
        DBData.reward = getDataList(DBDataList.info[index].reward);

        self.union_achievement[DBData.id]=DBData;
    end
end

function guildAchievementLayer:setData(data)
    self.data = data;

    self.Label_num:setText(string.format(MG_TEXT("guildAchievementLayer_1"),tonumber(self.data.city_num)));
    self:creatItem();
end

function guildAchievementLayer:creatItem()
    self.ListView:removeAllItems();
    self.totalNum = #self.union_achievement;

    local itemIndex = 1
    local function loadEachItem(dt)
        if itemIndex > self.totalNum then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
        else
            local item = guildAchievementItem.create(self,self.itemWidget:clone());
            item:setData(self.data,self.union_achievement[itemIndex]);
            self.ListView:pushBackCustomItem(item);
            self.ListView:setItemsMargin(10);

            itemIndex = itemIndex+1;
        end
    end

    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
    end
    self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(loadEachItem, 0.1, false);
end

function guildAchievementLayer:back()
    self:removeFromParent();
end

function guildAchievementLayer:onReciveData(MsgID, NetData)
    print("guildAchievementLayer onReciveData MsgID:"..MsgID)

    if MsgID == Post_Union_Achievement_getAchievement then
        if NetData.state == 1 then
            self:setData(NetData.getachievement);
        else
            NetHandler:showFailedMessage(NetData);
        end
    elseif MsgID == Post_Union_Achievement_getAReward then
        if NetData.state == 1 then
            getItem.showBox(NetData.getareward.get_item);
            self.data.achievement = self.data.achievement..":"..self.getId;
            self:setData(self.data);
        else
            NetHandler:showFailedMessage(NetData);
        end
    end
end

function guildAchievementLayer:sendReq(item)
    self.getId = item.achievementData.id;
    local str = "&id="..self.getId;
    NetHandler:sendData(Post_Union_Achievement_getAReward, str);
end

function guildAchievementLayer:pushAck()
    NetHandler:addAckCode(self,Post_Union_Achievement_getAchievement);
    NetHandler:addAckCode(self,Post_Union_Achievement_getAReward);
end

function guildAchievementLayer:popAck()
    NetHandler:delAckCode(self,Post_Union_Achievement_getAchievement);
    NetHandler:delAckCode(self,Post_Union_Achievement_getAReward);
end

function guildAchievementLayer:onEnter()
    self:pushAck();
    NetHandler:sendData(Post_Union_Achievement_getAchievement, "");
end

function guildAchievementLayer:onExit()
    self:popAck();
    MGRCManager:releaseResources("guildAchievementLayer");
    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
    end
    if self.itemWidget then
        self.itemWidget:release();
    end
end

function guildAchievementLayer.create(delegate)
    local layer = guildAchievementLayer:new()
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

function guildAchievementLayer.showBox(delegate)
    local layer = guildAchievementLayer.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
