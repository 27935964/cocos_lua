-----------------------公会建设界面------------------------
require "guildBuildingBoxItem"
require "guildBuildingShow"

local guildBuildingItem = require "guildBuildingItem"
guildBuildingLayer = class("guildBuildingLayer", MGLayer)

function guildBuildingLayer:ctor()
    self:init();
end

function guildBuildingLayer:init()
    MGRCManager:cacheResource("guildBuildingLayer", "GuildBuilding_Hero.png");
    local pWidget = MGRCManager:widgetFromJsonFile("guildBuildingLayer","GuildBuilding_Ui.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);

    self.pPanelTop = PanelTop.create(self)
    self.pPanelTop:setData("guild_building_title.png");
    self:addChild(self.pPanelTop,10);
    self.pPanelTop:showRankCoin(false);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:setAnchorPoint(cc.p(0.5, 0.5));
    CommonMethod:setFullBgScale(self.Panel_1);

    local Panel_2 = pWidget:getChildByName("Panel_2");
    self.Panel_2 = Panel_2;
    self.Panel_Reward = Panel_2:getChildByName("Panel_Reward");

    self.Label_Level = Panel_2:getChildByName("Label_Level");
    self.Label_EXP_number = Panel_2:getChildByName("Label_EXP_number");
    self.Label_Constrution_number = Panel_2:getChildByName("Label_Constrution_number");
    self.Label_Limit_number = Panel_2:getChildByName("Label_Limit_number");
    self.Label_Occupy_Limit = Panel_2:getChildByName("Label_Occupy_Limit");
    self.Label_Order = Panel_2:getChildByName("Label_Order");
    self.ProgressBar = Panel_2:getChildByName("ProgressBar");
    self.ProgressBar_exp = Panel_2:getChildByName("ProgressBar_exp");
    self.Label_Surplus_number = Panel_2:getChildByName("Label_Surplus_number");
    self.Image_flag = Panel_2:getChildByName("Image_flag");
    self.Image_totem = self.Image_flag:getChildByName("Image_totem");

    local Label_GuildLevel = Panel_2:getChildByName("Label_GuildLevel");
    Label_GuildLevel:setText(MG_TEXT_COCOS("GuildBuilding_Ui_1"));

    local Label_Construction = Panel_2:getChildByName("Label_Construction");
    Label_Construction:setText(MG_TEXT_COCOS("GuildBuilding_Ui_2"));

    local Label_PeopleLimit = Panel_2:getChildByName("Label_PeopleLimit");
    Label_PeopleLimit:setText(MG_TEXT_COCOS("GuildBuilding_Ui_3"));

    local Label_OccupyLimit = Panel_2:getChildByName("Label_OccupyLimit");
    Label_OccupyLimit:setText(MG_TEXT_COCOS("GuildBuilding_Ui_4"));

    local Label_HighestOrder = Panel_2:getChildByName("Label_HighestOrder");
    Label_HighestOrder:setText(MG_TEXT_COCOS("GuildBuilding_Ui_5"));

    local Label_Surplus = Panel_2:getChildByName("Label_Surplus");
    Label_Surplus:setText(MG_TEXT_COCOS("GuildBuilding_Ui_6"));

    if not self.itemWidget then
        self.itemWidget = MGRCManager:widgetFromJsonFile("guildBuildingLayer", "GuildBuilding_item_ui.ExportJson",false);
        self.itemWidget:retain();
    end

    local sql = string.format("select value from config where id=120");
    local DBData = LUADB.select(sql, "value");
    self.value = tonumber(DBData.info.value);

    local sql1 = string.format("select value from config where id=89");
    local DBData = LUADB.select(sql1, "value");
    self.maxLv = tonumber(DBData.info.value);

    self:readSql();
end

function guildBuildingLayer:readSql()--解析数据库数据
    self.union_build = {};
    local sql = string.format("select * from union_build_donation");
    local DBDataList = LUADB.selectlist(sql, "id:name:reward:need");
    table.sort(DBDataList.info,function(a,b) return a.id < b.id; end);

    for index=1,#DBDataList.info do
        local DBData = {};
        DBData.id = tonumber(DBDataList.info[index].id);
        DBData.name = DBDataList.info[index].name;
        DBData.reward = getDataList(DBDataList.info[index].reward);
        DBData.need = spliteStr(DBDataList.info[index].need,':');

        self.union_build[DBData.id]=DBData;
    end

    self.union_reward = {};
    local sql_1 = string.format("select * from union_build_reward");
    local DBDataList_1 = LUADB.selectlist(sql_1, "exp:reward:pic");

    for index=1,#DBDataList_1.info do
        local DBData = {};
        DBData.exp = tonumber(DBDataList_1.info[index].exp);
        DBData.pic = DBDataList_1.info[index].pic..".png";
        DBData.reward = getDataList(DBDataList_1.info[index].reward);
        DBData.get_item = DBDataList_1.info[index].reward;

        table.insert(self.union_reward,DBData);
    end
end

function guildBuildingLayer:setData(data)
    self.data = data;

    self.Label_Level:setText(self.data.union_lv);
    -- self.Label_Constrution_number:setText(self.data.day_exp);
    self.Image_flag:loadTexture(string.format("guild_flag_%d.png",tonumber(self.data.flag_bg)),ccui.TextureResType.plistType);
    self.Image_totem:loadTexture(string.format("guild_totem_%d.png",tonumber(self.data.flag)),ccui.TextureResType.plistType);
    -- self.Label_Surplus_number:setText(string.format("%d/%d",tonumber(self.data.num),self.value));
    
    --查找同等级公会中爵位最大的
    local sql1 = "select *,max(name) from union_peerages where union_lv="..tonumber(self.data.union_lv);
    local DBData1 = LUADB.select(sql1, "name");
    self.Label_Order:setText(DBData1.info.name);
    
    self:creatItem();
    self:creatBoxItem();
    self:upData();
end

function guildBuildingLayer:creatItem()
    for i=1,#self.union_build do
        local item = guildBuildingItem.create(self,self.itemWidget:clone());
        item:setData(self.union_build[i],self.data);
        item:setPosition(cc.p(item:getContentSize().width/2+(i-1)*(item:getContentSize().width+20),
            self.Panel_Reward:getContentSize().height/2));
        self.Panel_Reward:addChild(item);
    end
end

function guildBuildingLayer:creatBoxItem()
    if #self.union_reward <= 0 then
        return;
    end
    
    self.items = {};
    local scale = self.ProgressBar:getScaleX();
    local x = self.ProgressBar:getPositionX()-self.ProgressBar:getContentSize().width/2*scale;
    local y = self.ProgressBar:getPositionY();
    for i=1,#self.union_reward do
        local percent = self.union_reward[i].exp/self.union_reward[#self.union_reward].exp;
        local item = guildBuildingBoxItem.create(self);
        item:setData(self.data,self.union_reward[i]);
        item:setPosition(cc.p(x+percent*self.ProgressBar:getContentSize().width*scale,y));
        self.Panel_2:addChild(item);
        table.insert(self.items,item);
    end
end

function guildBuildingLayer:upData()
    self.ProgressBar:setPercent(0);
    -- self.ProgressBar_exp:setPercent(100);
    self.Label_Constrution_number:setText(self.data.day_exp);
    local disNum = self.value - tonumber(self.data.num);
    self.Label_Surplus_number:setText(string.format("%d/%d",disNum,self.value));
    
    if #self.union_reward > 0 then
        local taotalExp = self.union_reward[#self.union_reward].exp;
        self.ProgressBar:setPercent(tonumber(self.data.day_exp)*100/taotalExp);
    end

    local sql = "select * from union_lv where lv="..tonumber(self.data.union_lv);
    local DBData = LUADB.select(sql, "need_exp:max_num:city_num");
    self.Label_Limit_number:setText(tonumber(DBData.info.max_num));
    self.Label_Occupy_Limit:setText(tonumber(DBData.info.city_num));
    if self.maxLv > tonumber(self.data.union_lv) then
        sql = "select need_exp from union_lv where lv="..tonumber(self.data.union_lv)+1;
        DBData = LUADB.select(sql, "need_exp");
        self.Label_EXP_number:setText(string.format("%d/%d",tonumber(self.data.union_exp),tonumber(DBData.info.need_exp)));
        self.ProgressBar_exp:setPercent(tonumber(self.data.union_exp)*100/tonumber(DBData.info.need_exp));
    else
        self.Label_EXP_number:setText(string.format("%d/%d",tonumber(self.data.union_exp),tonumber(DBData.info.need_exp)));
    end

    for i=1,#self.union_reward do
        if self.items[i] then
            self.items[i]:setData(self.data,self.union_reward[i]);
        end
    end
end

function guildBuildingLayer:back()
    self:removeFromParent();
end

function guildBuildingLayer:response(item)
    if item.isCanGet == true then
        self.rewardData = item.rewardData;
        self:sendGetRewardReq(item);
    else
        local guildBuildingShow = guildBuildingShow.showBox(self);
        guildBuildingShow:setData(item.rewardData);
    end
end

function guildBuildingLayer:onReciveData(MsgID, NetData)
    print("guildBuildingLayer onReciveData MsgID:"..MsgID)

    if MsgID == Post_Union_Build_index then
        if NetData.state == 1 then
            self:setData(NetData.index);
        else
            NetHandler:showFailedMessage(NetData);
        end
    elseif MsgID == Post_Union_Build_doDonation then
        if NetData.state == 1 then
            MGMessageTip:showFailedMessage(MG_TEXT("guildBuildingLayer_1"));
            self.pPanelTop:upData();
            self.data.day_exp = NetData.getunionexp.union_day_exp;
            self.data.union_exp = NetData.getunionexp.union_exp;
            self.data.union_lv = NetData.getunionexp.union_lv;
            self.data.num = NetData.dodonation.num;
            self:upData();
        else
            NetHandler:showFailedMessage(NetData);
        end
    elseif MsgID == Post_Union_Build_getReward then
        if NetData.state == 1 then
            self.data.get_reward = NetData.getreward.get_reward;
            getItem.showBox(self.rewardData.get_item);
            self:upData();
        else
            NetHandler:showFailedMessage(NetData);
        end
    end
end

function guildBuildingLayer:sendReq(item)
    if tonumber(self.data.num) > self.value then
        MGMessageTip:showFailedMessage(MG_TEXT("guildBuildingLayer_2"));
        return;
    end
    local str = "&id="..item.data.id;
    NetHandler:sendData(Post_Union_Build_doDonation, str);
end

function guildBuildingLayer:sendGetRewardReq(item)
    local str = "&exp="..item.rewardData.exp;
    NetHandler:sendData(Post_Union_Build_getReward, str);
end

function guildBuildingLayer:pushAck()
    NetHandler:addAckCode(self,Post_Union_Build_index);
    NetHandler:addAckCode(self,Post_Union_Build_doDonation);
    NetHandler:addAckCode(self,Post_Union_Build_getReward);
end

function guildBuildingLayer:popAck()
    NetHandler:delAckCode(self,Post_Union_Build_index);
    NetHandler:delAckCode(self,Post_Union_Build_doDonation);
    NetHandler:delAckCode(self,Post_Union_Build_getReward);
end

function guildBuildingLayer:onEnter()
    self:pushAck();
    NetHandler:sendData(Post_Union_Build_index, "");
end

function guildBuildingLayer:onExit()
    self:popAck();
    MGRCManager:releaseResources("guildBuildingLayer");
    if self.itemWidget then
        self.itemWidget:release();
    end
end

function guildBuildingLayer.create(delegate)
    local layer = guildBuildingLayer:new()
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

function guildBuildingLayer.showBox(delegate)
    local layer = guildBuildingLayer.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
