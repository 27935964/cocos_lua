-----------------------公会议会厅--公告信息界面------------------------
require "guildCreateLayer"
require "guildExitTip"
require "guilddisbandTip"

guildInfoLayer = class("guildInfoLayer", MGLayer)

function guildInfoLayer:ctor()
    self.no_lose = 0;
    self:init();
end

function guildInfoLayer:init()
    MGRCManager:cacheResource("guildInfoLayer", "big_bg.png");
    local pWidget = MGRCManager:widgetFromJsonFile("guildInfoLayer","guild_hall_ui_6.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);

    local Panel_2 = pWidget:getChildByName("Panel_2");
    local Panel_3 = Panel_2:getChildByName("Panel_3");
    local Panel_4 = Panel_2:getChildByName("Panel_4");

    self.Image_flag = Panel_3:getChildByName("Image_flag");
    self.posY = self.Image_flag:getPositionY();
    self.Image_flag_totem = self.Image_flag:getChildByName("Image_flag_totem");
    self.Label_name1 = Panel_3:getChildByName("Label_name1");
    self.Label_president_1 = Panel_3:getChildByName("Label_president_1");
    self.Label_fund_1 = Panel_3:getChildByName("Label_fund_1");
    self.Label_people_number_1 = Panel_3:getChildByName("Label_people_number_1");
    self.Label_level_1 = Panel_3:getChildByName("Label_level_1");
    self.Label_total_capability_1 = Panel_3:getChildByName("Label_total_capability_1");
    self.Label_rank_1 = Panel_3:getChildByName("Label_rank_1");
    self.ProgressBar = Panel_3:getChildByName("ProgressBar");
    self.Label_exp_numeber = Panel_3:getChildByName("Label_exp_numeber");
    self.Label_capital_1 = Panel_3:getChildByName("Label_capital_1");
    self.Label_city_revenue_2 = Panel_3:getChildByName("Label_city_revenue_2");
    self.Label_city_number_0 = Panel_3:getChildByName("Label_city_number_0");

    self.Button_change_flag = Panel_3:getChildByName("Button_change_flag");
    self.Button_change_flag:addTouchEventListener(handler(self,self.onButtonClick));
    self.Button_change_flag:setEnabled(false);

    self.Button_quit = Panel_3:getChildByName("Button_quit");
    self.Button_quit:addTouchEventListener(handler(self,self.onButtonClick));

    self.Label_quit = self.Button_quit:getChildByName("Label_quit");
    self.Label_quit:setText(MG_TEXT("guildInfoLayer_3"));

    self.Button_look = Panel_3:getChildByName("Button_look");
    self.Button_look:addTouchEventListener(handler(self,self.onButtonClick));

    self.Label_look = self.Button_look:getChildByName("Label_look");
    self.Label_look:setText(MG_TEXT("guildInfoLayer_6"));

    local Label_declare_war_1 = Panel_4:getChildByName("Label_declare_war_1");
    Label_declare_war_1:setVisible(false);
    self.declareLabel = MGColorLabel:label();
    self.declareLabel:setAnchorPoint(cc.p(0.5, 0.5));
    self.declareLabel:setPosition(Label_declare_war_1:getPosition());
    Panel_4:addChild(self.declareLabel);
    self.declareLabel:clear();
    self.declareLabel:appendStringAutoWrap(MG_TEXT("guildInfoLayer_1"),10,1,cc.c3b(255,255,255),22);

    local Label_tax = Panel_4:getChildByName("Label_tax");
    Label_tax:setVisible(false);
    self.taxLabel = MGColorLabel:label();
    self.taxLabel:setAnchorPoint(cc.p(0.5, 0.5));
    self.taxLabel:setPosition(Label_tax:getPosition());
    Panel_4:addChild(self.taxLabel);
    self.taxLabel:clear();
    self.taxLabel:appendStringAutoWrap(MG_TEXT("guildInfoLayer_2"),10,1,cc.c3b(255,255,255),22);

    local Label_name = Panel_3:getChildByName("Label_name");
    Label_name:setText(MG_TEXT_COCOS("guild_hall_ui_6_1"));
    local Label_president = Panel_3:getChildByName("Label_president");
    Label_president:setText(MG_TEXT_COCOS("guild_hall_ui_6_2"));
    local Label_people_number = Panel_3:getChildByName("Label_people_number");
    Label_people_number:setText(MG_TEXT_COCOS("guild_hall_ui_6_3"));
    local Label_total_capability = Panel_3:getChildByName("Label_total_capability");
    Label_total_capability:setText(MG_TEXT_COCOS("guild_hall_ui_6_4"));
    local Label_fund = Panel_3:getChildByName("Label_fund");
    Label_fund:setText(MG_TEXT_COCOS("guild_hall_ui_6_5"));
    local Label_level = Panel_3:getChildByName("Label_level");
    Label_level:setText(MG_TEXT_COCOS("guild_hall_ui_6_6"));
    local Label_rank = Panel_3:getChildByName("Label_rank");
    Label_rank:setText(MG_TEXT_COCOS("guild_hall_ui_6_7"));
    local Label_capital = Panel_3:getChildByName("Label_capital");
    Label_capital:setText(MG_TEXT_COCOS("guild_hall_ui_6_8"));
    local Label_city_revenue = Panel_3:getChildByName("Label_city_revenue");
    Label_city_revenue:setText(MG_TEXT_COCOS("guild_hall_ui_6_9"));
    local Label_city_number = Panel_3:getChildByName("Label_city_number");
    Label_city_number:setText(MG_TEXT_COCOS("guild_hall_ui_6_10"));
    local Label_change_flag = self.Button_change_flag:getChildByName("Label_change_flag");
    Label_change_flag:setText(MG_TEXT_COCOS("guild_hall_ui_6_11"));
    local Label_declare_war = Panel_4:getChildByName("Label_declare_war");
    local Label_occupy_flag = Panel_4:getChildByName("Label_occupy_flag");
    Label_occupy_flag:setText(MG_TEXT_COCOS("guild_hall_ui_6_12"));
    local Label_none = Panel_4:getChildByName("Label_none");
    Label_none:setText(MG_TEXT_COCOS("guild_hall_ui_6_13"));
    Label_declare_war:setText(MG_TEXT_COCOS("guild_hall_ui_6_14"));
    local Label_war_start = Panel_4:getChildByName("Label_war_start");
    Label_war_start:setText(MG_TEXT_COCOS("guild_hall_ui_6_15"));
    local Label_war_start_1 = Panel_4:getChildByName("Label_war_start_1");
    Label_war_start_1:setText(MG_TEXT_COCOS("guild_hall_ui_6_16"));
    
end

function guildInfoLayer:setData(data)
    self.data = data;
    print_lua_table(data);
    self.Label_name1:setText(unicode_to_utf8(data.name));
    self.Label_president_1:setText(unicode_to_utf8(data.owner));
    self.Label_people_number_1:setText(string.format("%d/%d",tonumber(data.num),tonumber(data.max_num)));
    self.Label_total_capability_1:setText(tonumber(data.score));
    self.Label_fund_1:setText(tonumber(data.money));
    self.Label_level_1:setText(string.format("Lv%d",data.lv));
    self.Label_rank_1:setText(tonumber(data.rank));
    self.Image_flag:loadTexture(string.format("guild_flag_%d.png",tonumber(data.flag_bg)),ccui.TextureResType.plistType);
    self.Image_flag_totem:loadTexture(string.format("guild_totem_%d.png",tonumber(data.flag)),ccui.TextureResType.plistType);
    self.Label_exp_numeber:setText(string.format("%d/%d",tonumber(data.exp),tonumber(data.max_exp)));
    self.ProgressBar:setPercent(tonumber(data.exp)*100/tonumber(data.max_exp));

    if self.delegate and self.delegate.setPost then
        self.delegate:setPost(tonumber(data.post));
    end

    if tonumber(data.post) == 10 then
        self.Label_quit:setText(MG_TEXT("guildInfoLayer_4"));
    else
        self.Label_quit:setText(MG_TEXT("guildInfoLayer_3"));
    end

    --当玩家不为公会官员、没有更换公会旗帜的权限时,没有设立、变更公会首都的权限时
    self.Button_change_flag:setEnabled(false);
    self.Image_flag:setPositionY(self.posY-50);
    self.Label_look:setText(MG_TEXT("guildInfoLayer_5"));
    if tonumber(data.post) >= 9 then
        self.Button_change_flag:setEnabled(true);
        self.Image_flag:setPositionY(self.posY);
        self.Label_look:setText(MG_TEXT("guildInfoLayer_6"));
    end
end

function guildInfoLayer:updateFlag(flagId,totemId)
    self.Image_flag:loadTexture(string.format("guild_flag_%d.png",flagId),ccui.TextureResType.plistType);
    self.Image_flag_totem:loadTexture(string.format("guild_totem_%d.png",totemId),ccui.TextureResType.plistType);
end

function guildInfoLayer:callBack(item)
    if item.state == true then--无损退出
        self.no_lose = 1;
    else
        self.no_lose = 0;
    end
    self:sendReq();
end

function guildInfoLayer:disband(item)--解散公会（会长退出公会就是解散）
    self.no_lose = 1;
    self:sendReq();
end

function guildInfoLayer:onButtonClick(sender, eventType)
    buttonClickScale(sender, eventType);
    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_change_flag then--更换旗帜
            local guildCreateLayer = guildCreateLayer.showBox(self);
            guildCreateLayer:setData(2);
        elseif sender == self.Button_quit then--退出/解散公会
            if tonumber(self.data.post) == 10 then--解散公会
                local guilddisbandTip = guilddisbandTip.showBox(self);
            else
                local guildExitTip = guildExitTip.showBox(self);
            end
        elseif sender == self.Button_look then--设立/查看
            
        end
    end
end

function guildInfoLayer:onReciveData(MsgID, NetData)
    print("guildInfoLayer onReciveData MsgID:"..MsgID)
    print_lua_table(NetData);
    if MsgID == Post_index then
        local ackData = NetData
        if ackData.state == 1 then
            self:setData(ackData.index);
        else
            NetHandler:showFailedMessage(ackData)
        end
    elseif MsgID == Post_fireMem then
        local ackData = NetData
        if ackData.state == 1 then

        else
            NetHandler:showFailedMessage(ackData)
        end
    end
end

function guildInfoLayer:sendReq()
    local str = string.format("&id=%s&no_lose=%d",ME:getUid(),self.no_lose);
    NetHandler:sendData(Post_fireMem, str);
end

function guildInfoLayer:pushAck()
    NetHandler:addAckCode(self,Post_index);
    NetHandler:addAckCode(self,Post_fireMem);
    -- NetHandler:addAckCode(self,Post_applyAddUnion);
end

function guildInfoLayer:popAck()
    NetHandler:delAckCode(self,Post_index);
    NetHandler:delAckCode(self,Post_fireMem);
    -- NetHandler:delAckCode(self,Post_applyAddUnion);
end

function guildInfoLayer:onEnter()
    self:pushAck();
    NetHandler:sendData(Post_index, "");
end

function guildInfoLayer:onExit()
    self:popAck();
    MGRCManager:releaseResources("guildInfoLayer");
end

function guildInfoLayer.create(delegate,type)
    local layer = guildInfoLayer:new()
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

function guildInfoLayer.showBox(delegate,type)
    local layer = guildInfoLayer.create(delegate,type);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
