-----------------------公会佣兵营界面------------------------
require "guildStationedLayer"

local guildMercenaryItem = require "guildMercenaryItem"
guildMercenaryLayer = class("guildMercenaryLayer", MGLayer)

function guildMercenaryLayer:ctor()
    self:init();
end

function guildMercenaryLayer:init()
    MGRCManager:cacheResource("guildMercenaryLayer", "guild_mercenary_slot.png");
    MGRCManager:cacheResource("guildMercenaryLayer", "guild_mercenary_ui.png", "guild_mercenary_ui.plist");
    local pWidget = MGRCManager:widgetFromJsonFile("guildMercenaryLayer","guild_mercenary_ui.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);

    self.pPanelTop = PanelTop.create(self)
    self.pPanelTop:setData("guild_mercenary_button_title.png");
    self:addChild(self.pPanelTop,10);
    self.pPanelTop:showRankCoin(false);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:setAnchorPoint(cc.p(0.5, 0.5));
    CommonMethod:setFullBgScale(self.Panel_1);

    local Panel_2 = pWidget:getChildByName("Panel_2");

    self.ListView = Panel_2:getChildByName("ListView");
    self.ListView:setScrollBarVisible(false);
    self.ListView:setItemsMargin(90);
    self.ListView:setClippingType(1);--使用裁切方式，如果采用蒙版方式，多个子节点使用蒙版无法关闭，渲染bug

    local Label_tip = Panel_2:getChildByName("Label_tip");
    Label_tip:setText(MG_TEXT_COCOS("guild_mercenary_ui_1"));

    if not self.itemWidget then
        self.itemWidget = MGRCManager:widgetFromJsonFile("guildMercenaryLayer", "guild_mercenary_item_ui.ExportJson",false);
        self.itemWidget:retain();
    end

    self:readSql();
end

function guildMercenaryLayer:readSql()--解析数据库数据
    self.mercenary = {};
    local sql = string.format("select value from config where id=110");
    local DBData = LUADB.select(sql, "value");
    self.mercenary.union_mercenary = getDataList(DBData.info.value);

end

function guildMercenaryLayer:setData(data)
    self.data = data;

    self.g_ids = {}--已驻扎的佣兵ID
    for i=1,#self.data.mercenary do
        table.insert(self.g_ids,tonumber(self.data.mercenary[i].g_id));
    end

    self.ListView:removeAllItems();
    for i=1,#self.mercenary.union_mercenary do
        local item = guildMercenaryItem.create(self,self.itemWidget:clone());
        item:setData(self.data,self.mercenary,i);
        self.ListView:pushBackCustomItem(item);
    end
end

function guildMercenaryLayer:back()
    self:removeFromParent();
end

function guildMercenaryLayer:addGuildStationedLayer(item)
    local guildStationedLayer = guildStationedLayer.showBox(self);
    guildStationedLayer:setData(item.index,self.g_ids);
end

function guildMercenaryLayer:onReciveData(MsgID, NetData)
    print("guildMercenaryLayer onReciveData MsgID:"..MsgID)
    local ackData = NetData;
    if MsgID == Post_union_mercenary_index then
        if ackData.state == 1 then
            self:setData(ackData.index);
        else
            NetHandler:showFailedMessage(ackData);
        end
    elseif MsgID == Post_union_mercenary_doStation then
        if ackData.state == 1 then
            self:setData(ackData.index);
        else
            NetHandler:showFailedMessage(ackData);
        end
    elseif MsgID == Post_union_mercenary_closeStation then
        if ackData.state == 1 then
            self:setData(ackData.index);
        else
            NetHandler:showFailedMessage(ackData);
        end
    elseif MsgID == Post_union_mercenary_getReward then
        if ackData.state == 1 then
            getItem.showBox(ackData.getreward.get_item);
        else
            NetHandler:showFailedMessage(ackData);
        end
    end
end

function guildMercenaryLayer:sendDoStationReq(id,g_id)--驻扎佣兵
    local str = string.format("&id=%d&g_id=%d",id,g_id);
    NetHandler:sendData(Post_union_mercenary_doStation, str);
end

function guildMercenaryLayer:sendCloseStationReq(id)--取消驻扎佣兵
    local str = "&id="..id;
    NetHandler:sendData(Post_union_mercenary_closeStation, str);
end

function guildMercenaryLayer:sendGetRewardReq(id)--领取奖励
    local str = "&id="..id;
    NetHandler:sendData(Post_union_mercenary_getReward, str);
end

function guildMercenaryLayer:pushAck()
    NetHandler:addAckCode(self,Post_union_mercenary_index);
    NetHandler:addAckCode(self,Post_union_mercenary_doStation);
    NetHandler:addAckCode(self,Post_union_mercenary_closeStation);
    NetHandler:addAckCode(self,Post_union_mercenary_getReward);
end

function guildMercenaryLayer:popAck()
    NetHandler:delAckCode(self,Post_union_mercenary_index);
    NetHandler:delAckCode(self,Post_union_mercenary_doStation);
    NetHandler:delAckCode(self,Post_union_mercenary_closeStation);
    NetHandler:delAckCode(self,Post_union_mercenary_getReward);
    
end

function guildMercenaryLayer:onEnter()
    self:pushAck();
    NetHandler:sendData(Post_union_mercenary_index, "");
end

function guildMercenaryLayer:onExit()
    self:popAck();
    MGRCManager:releaseResources("guildMercenaryLayer");
    if self.itemWidget then
        self.itemWidget:release();
    end
end

function guildMercenaryLayer.create(delegate,type)
    local layer = guildMercenaryLayer:new()
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

function guildMercenaryLayer.showBox(delegate,type)
    local layer = guildMercenaryLayer.create(delegate,type);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
