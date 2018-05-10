-----------------------公会爵位界面------------------------
require "Item"

local guildNobilityItem = require "guildNobilityItem"
guildNobilityLayer = class("guildNobilityLayer", MGLayer)

function guildNobilityLayer:ctor()
    self:init();
end

function guildNobilityLayer:init()
    MGRCManager:cacheResource("guildNobilityLayer", "guild_nobility_ui.png", "guild_nobility_ui.plist");
    local pWidget = MGRCManager:widgetFromJsonFile("guildNobilityLayer","guild_nobility_ui.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);

    self.pPanelTop = PanelTop.create(self)
    self.pPanelTop:setData("guild_nobility_title.png");
    self:addChild(self.pPanelTop,10);
    self.pPanelTop:setRankCoinPic("com_icon_prestige.png");

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:setAnchorPoint(cc.p(0.5, 0.5));
    CommonMethod:setFullBgScale(self.Panel_1);

    local Panel_2 = pWidget:getChildByName("Panel_2");
    self.Panel_2 = Panel_2;

    self.ListView_1 = Panel_2:getChildByName("ListView_1");
    self.ListView_1:setScrollBarVisible(false);
    self.ListView_1:setItemsMargin(-110);

    self.ListView_2 = Panel_2:getChildByName("ListView_2");
    self.ListView_2:setScrollBarVisible(false);

    self.ListView_3 = Panel_2:getChildByName("ListView_3");
    self.ListView_3:setScrollBarVisible(false);

    self.Button_receive = Panel_2:getChildByName("Button_receive");
    self.Button_receive:addTouchEventListener(handler(self,self.onButtonClick));

    local Label_1 = Panel_2:getChildByName("Label_1");
    local Label_2 = Panel_2:getChildByName("Label_2");
    local Label_3 = Panel_2:getChildByName("Label_3");

    self.Image_medal = Panel_2:getChildByName("Image_medal");
    self.Image_ribbon = Panel_2:getChildByName("Image_ribbon");
    self.Image_prestige_name = Panel_2:getChildByName("Image_prestige_name");

    self.Label_receive = self.Button_receive:getChildByName("Label_receive");
    self.Label_receive:setText(MG_TEXT("receive"));

    Label_1:setText(MG_TEXT_COCOS("guild_nobility_ui_2"));
    Label_2:setText(MG_TEXT_COCOS("guild_nobility_ui_3"));
    Label_3:setText(MG_TEXT_COCOS("guild_nobility_ui_4"));

    if not self.itemWidget then
        self.itemWidget = MGRCManager:widgetFromJsonFile("guildNobilityLayer", "guild_nobility_item_ui.ExportJson",false);
        self.itemWidget:retain();
    end

    self:readSql();
end

function guildNobilityLayer:readSql()--解析数据库数据
    self.union_peerages = {};
    local sql = string.format("select * from union_peerages");
    local DBDataList = LUADB.selectlist(sql, "id:name:exp:union_lv:num:plus_type:plus_target:plus_num:salary:revenue_weight:pic:pic_star:soldier_pic");
    table.sort(DBDataList.info,function(a,b) return a.id < b.id; end);

    for index=1,#DBDataList.info do
        local DBData = {};
        DBData.id = tonumber(DBDataList.info[index].id);
        DBData.name = DBDataList.info[index].name;
        DBData.exp = tonumber(DBDataList.info[index].exp);
        DBData.union_lv = tonumber(DBDataList.info[index].union_lv);
        DBData.num = tonumber(DBDataList.info[index].num);
        DBData.plus_type = tonumber(DBDataList.info[index].plus_type);
        DBData.revenue_weight = tonumber(DBDataList.info[index].revenue_weight);
        DBData.pic = DBDataList.info[index].pic;
        DBData.pic_star = DBDataList.info[index].pic_star;
        DBData.soldier_pic = DBDataList.info[index].soldier_pic;

        DBData.plus_target = spliteStr(DBDataList.info[index].plus_target,'|');
        DBData.plus_num = getDataList(DBDataList.info[index].plus_num);
        DBData.salary = spliteStr(DBDataList.info[index].salary,':');

        self.union_peerages[DBData.id]=DBData;
    end
end

function guildNobilityLayer:setData(data)
    self.data = data;

    self.pPanelTop:setRankCoin(tonumber(self.data.my_exp));
    local pic = self.union_peerages[tonumber(self.data.my_peerages)].pic;
    local picName = string.format("guild_name_icon_%d.png",tonumber(self.data.my_peerages));
    local pic_star = self.union_peerages[tonumber(self.data.my_peerages)].pic_star;

    self.Image_medal:loadTexture(pic..".png",ccui.TextureResType.plistType);
    self.Image_prestige_name:loadTexture(picName,ccui.TextureResType.plistType);
    if pic_star == "" or pic_star == "0" then
        self.Image_ribbon:setVisible(false);
    else
        self.Image_ribbon:loadTexture(pic_star..".png",ccui.TextureResType.plistType);
    end
    if tonumber(self.data.is_get_salary) == 1 then
        self.Button_receive:setBright(false);
        self.Button_receive:setTouchEnabled(false);
        self.Label_receive:setText(MG_TEXT("Get"));
    end

    local item2 = resItem.create(self);
    item2:setData(4,1,tonumber(self.data.my_revenue));
    self.ListView_2:pushBackCustomItem(item2);

    self.my_salary = getDataList(self.data.my_salary);
    self.ListView_3:removeAllItems();
    for i=1,#self.my_salary do
        local item = resItem.create(self);
        item:setData(self.my_salary[i].value1,self.my_salary[i].value2);
        item:setNum(self.my_salary[i].value3);
        self.ListView_3:pushBackCustomItem(item);
    end

    self:createItem();
end

function guildNobilityLayer:createItem()
    self.ListView_1:removeAllItems();
    local totalNum = #self.union_peerages;
    local itemIndex = 2;
    local function loadEachItem(dt)
        if itemIndex > totalNum then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
        else
            local item = guildNobilityItem.create(self,self.itemWidget:clone());
            item:setData(self.data,self.union_peerages,itemIndex);
            self.ListView_1:pushBackCustomItem(item);

            itemIndex = itemIndex+1;
        end
    end

    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
    end
    self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(loadEachItem, 0.01, false);
end

function guildNobilityLayer:onButtonClick(sender, eventType)
    buttonClickScale(sender, eventType);

    if eventType == ccui.TouchEventType.ended then
        NetHandler:sendData(Post_union_getSalary, "");
    end
end

function guildNobilityLayer:back()
    self:removeFromParent();
end

function guildNobilityLayer:onReciveData(MsgID, NetData)
    print("guildNobilityLayer onReciveData MsgID:"..MsgID)

    if MsgID == Post_union_index then
        local ackData = NetData
        if ackData.state == 1 then
            self:setData(ackData.index);
        else
            NetHandler:showFailedMessage(ackData)
        end
    elseif MsgID == Post_union_getSalary then
        local ackData = NetData
        if ackData.state == 1 then
            -- self:setData(ackData.index);
            getItem.showBox(self.data.my_salary);
        else
            NetHandler:showFailedMessage(ackData)
        end
    end
end

function guildNobilityLayer:pushAck()
    NetHandler:addAckCode(self,Post_union_index);
    NetHandler:addAckCode(self,Post_union_getSalary);
end

function guildNobilityLayer:popAck()
    NetHandler:delAckCode(self,Post_union_index);
    NetHandler:delAckCode(self,Post_union_getSalary);
end

function guildNobilityLayer:onEnter()
    self:pushAck();
    NetHandler:sendData(Post_union_index, "");
end

function guildNobilityLayer:onExit()
    self:popAck();
    MGRCManager:releaseResources("guildNobilityLayer");
    if self.itemWidget then
        self.itemWidget:release();
    end
    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
    end
end

function guildNobilityLayer.create(delegate,type)
    local layer = guildNobilityLayer:new()
    layer.delegate = delegate
    layer.scenetype = type
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

function guildNobilityLayer.showBox(delegate,type)
    local layer = guildNobilityLayer.create(delegate,type);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
