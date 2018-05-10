-----------------------公会主界面------------------------
require "PanelTop"
require "guildNobilityLayer"
require "guildChamberLayer"
require "guildPackageMainLayer"
require "guildMercenaryLayer"
require "guildWelfareMainLayer"
require "guildBoxLayer"
require "guildAchievementLayer"
require "guildBuildingLayer"
require "guildTroopsLayer"
require "guildMainBuildingItem"
require "chatInstance"

local UnionMainInfo = require "UnionMainInfo";
guildMainLayer = class("guildMainLayer", MGLayer)

function guildMainLayer:ctor()
    self:init();
end

function guildMainLayer:init()
    MGRCManager:cacheResource("guildMainLayer", "GulidView_bg.jpg");
    MGRCManager:cacheResource("guildMainLayer", "package_bg.jpg");
    MGRCManager:cacheResource("guildMainLayer", "guild_flag.png", "guild_flag.plist");
    MGRCManager:cacheResource("guildMainLayer", "guild_main_house_ui.png", "guild_main_house_ui.plist");
    local pWidget = MGRCManager:widgetFromJsonFile("guildMainLayer","guild_main_ui.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:setAnchorPoint(cc.p(0.5, 0.5));
    CommonMethod:setFullBgScale(self.Panel_1);

    self.Button_war = self.Panel_1:getChildByName("Button_war");
    self.Button_war:addTouchEventListener(handler(self,self.onButtonClick));

    local Panel_2 = pWidget:getChildByName("Panel_2");
    local Panel_bottom = pWidget:getChildByName("Panel_bottom");

    self.Panel_btn = Panel_2:getChildByName("Panel_btn");
    self.Panel_btn:addTouchEventListener(handler(self,self.onButtonClick));

    self.Label_name = Panel_2:getChildByName("Label_GuildName");
    self.Label_level = Panel_2:getChildByName("Label_GuildLevel");
    self.ProgressBar = Panel_2:getChildByName("ProgressBar");
    self.Label_exp = Panel_2:getChildByName("Label_exp");
    self.Label_rank = Panel_2:getChildByName("Label_GuildRank");
    self.Label_power = Panel_2:getChildByName("Label_TotalCE_number");
    self.Label_ChairmanName = Panel_2:getChildByName("Label_ChairmanName");
    self.Image_flag = Panel_2:getChildByName("Image_flag");
    self.Image_totem = self.Image_flag:getChildByName("Image_totem");

    self.Panel_chat = Panel_bottom:getChildByName("Panel_chat");
    self.Panel_chat:addTouchEventListener(handler(self,self.onButtonClick));

    self.ListView_chat = Panel_bottom:getChildByName("ListView_chat");
    self.Label_Online_number = Panel_bottom:getChildByName("Label_Online_number");

    for i=1,#UnionMainInfo do
        local item = guildMainBuildingItem.create(self);
        item:setPosition(cc.p(UnionMainInfo[i].x,UnionMainInfo[i].y));
        item:setData(UnionMainInfo[i]);
        self.Panel_1:addChild(item);
    end

    local chatInstance = chatInstance:createInstance();
    self.ListView_chat:removeAllItems();
    self.ListView_chat:pushBackCustomItem(chatInstance);

    self.value = LUADB.readConfig(89);
    self.value1 = tonumber(LUADB.readConfig(196));--聊天系统开启等级
end

function guildMainLayer:setData(data)
    self.Label_name:setText(unicode_to_utf8(data.union_name ));
    self.Label_level:setText(string.format("Lv%d",tonumber(data.union_lv)));
    self.Label_rank:setText("");
    self.Label_power:setText(tonumber(data.union_score));
    self.Label_ChairmanName:setText(unicode_to_utf8(data.owner_name));
    self.Label_Online_number:setText(string.format(MG_TEXT("guildMainLayer_1"),tonumber(data.union_online)));
    self.Image_flag:loadTexture(string.format("guild_flag_%d.png",tonumber(data.union_falg_bg)),ccui.TextureResType.plistType);
    self.Image_totem:loadTexture(string.format("guild_totem_%d.png",tonumber(data.union_falg)),ccui.TextureResType.plistType);

    if tonumber(data.union_lv) < tonumber(self.value) then
        local sql = "select need_exp from union_lv where lv="..tonumber(data.union_lv)+1;
        local DBData = LUADB.select(sql, "need_exp");
        local value=tonumber(data.union_exp)*100/tonumber(DBData.info.need_exp);
        self.Label_exp:setText(string.format("%d%%",value));
        self.ProgressBar:setPercent(value);
    else
        self.Label_exp:setText(string.format("%d%%",100));
        self.ProgressBar:setPercent(100);
    end

    self.Button_war:setEnabled(false);
    if tonumber(data.my_post) >= 9 then
        self.Button_war:setEnabled(true);
    end
end

function guildMainLayer:onSelect(id)
    if UnionMainInfo[id].openlv >= 999 then
        MGMessageTip:showFailedMessage(MG_TEXT("Unopen"));
        return;
    end

    chatLayer:dispose();
    if id == 1 then--议会厅
        local guildChamberLayer = guildChamberLayer.showBox(self);
    elseif id == 2 then--爵位
        local guildNobilityLayer = guildNobilityLayer.showBox(self);
    elseif id == 3 then--战争作坊/宝箱
        local guildBoxLayer = guildBoxLayer.showBox(self);
        guildBoxLayer:setData(self.guildInfo);
    elseif id == 4 then--仓库
        local guildPackageMainLayer = guildPackageMainLayer.showBox(self);
        guildPackageMainLayer:setData(self.guildInfo);
    elseif id == 5 then--公会福利
        local guildWelfareMainLayer = guildWelfareMainLayer.showBox(self);
        guildWelfareMainLayer:setData(self.guildInfo);
    elseif id == 6 then--成就
        local guildAchievementLayer = guildAchievementLayer.showBox(self);
    elseif id == 7 then--公会建设 
        local guildBuildingLayer = guildBuildingLayer.showBox(self);
    elseif id == 8 then--佣兵营
        local guildMercenaryLayer = guildMercenaryLayer.showBox(self);
    elseif id == 9 then--攻城部队
        local guildTroopsLayer = guildTroopsLayer.showBox(self,self.scenetype);
    elseif id == 10 then--维蓝金字塔
        print(">>>>>>>>>>>维蓝金字塔>>>>>>>>>>>>")
    elseif id == 11 then--列王争霸
        local guildTroopsLayer = guildTroopsLayer.showBox(self,self.scenetype);
    end
end

function guildMainLayer:onButtonClick(sender, eventType)
    buttonClickScale(sender, eventType);
    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_war then--宣战
            local MapManager = MapManager.getInstance();
            MapManager:jump();
            self:removeFromParent();
        elseif sender == self.Panel_btn then--返回
            self:removeFromParent();
        elseif sender == self.Panel_chat then--聊天界面
            if ME:Lv() < self.value1 then
                MGMessageTip:showFailedMessage(string.format(MG_TEXT("chatLayer_14"),self.value1));
            else
                chatLayer:createInstance();
            end
        end
    end
end

function guildMainLayer:back()
    self:removeFromParent();
end

function guildMainLayer:onReciveData(MsgID, NetData)
    print("guildMainLayer onReciveData MsgID:"..MsgID)

    if MsgID == Post_union_main then
        local ackData = NetData
        if ackData.state == 1 then
            self.guildInfo = ackData.main;
            self:setData(self.guildInfo);
        else
            NetHandler:showFailedMessage(ackData);
        end
    end
end

function guildMainLayer:pushAck()
    NetHandler:addAckCode(self,Post_union_main);
end

function guildMainLayer:popAck()
    NetHandler:delAckCode(self,Post_union_main);
end

function guildMainLayer:onEnter()
    self:pushAck();
    NetHandler:sendData(Post_union_main, "");
end

function guildMainLayer:onExit()
    self:popAck();
    MGRCManager:releaseResources("guildMainLayer");
    chatLayer:dispose();
    chatInstance:dispose();
end

function guildMainLayer.create(delegate,scenetype)
    local layer = guildMainLayer:new()
    layer.delegate = delegate
    layer.scenetype = scenetype
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

function guildMainLayer.showBox(delegate,scenetype)
    local layer = guildMainLayer.create(delegate,scenetype);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
