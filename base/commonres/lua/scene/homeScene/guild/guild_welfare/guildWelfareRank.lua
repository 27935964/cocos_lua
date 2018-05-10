-----------------------公会福利----红包排行界面------------------------

local guildWelfareRankItem = require "guildWelfareRankItem";
guildWelfareRank = class("guildWelfareRank", MGLayer)

function guildWelfareRank:ctor()
    self.curCheckBox = nil;
    self:init();
end

function guildWelfareRank:init()
    local pWidget = MGRCManager:widgetFromJsonFile("guildWelfareRank","guild_rank_ui.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:setAnchorPoint(cc.p(0.5, 0.5));
    CommonMethod:setFullBgScale(self.Panel_1);
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));

    local Panel_2 = pWidget:getChildByName("Panel_2");
    local Panel_3 = Panel_2:getChildByName("Panel_3");

    self.CheckBox_1 = Panel_3:getChildByName("CheckBox_1");
    self.CheckBox_1:setTag(1);
    self.CheckBox_1:setSelectedState(true);
    self.CheckBox_1:addEventListenerCheckBox(handler(self,self.selectedEvent));
    self.curCheckBox = self.CheckBox_1;

    self.Label_name1 = self.CheckBox_1:getChildByName("Label_name1");
    self.Label_name1:setColor(cc.c3b(255,255,255));
    self.Label_name1:setText(MG_TEXT_COCOS("guild_rank_ui_1"));

    self.CheckBox_2 = Panel_3:getChildByName("CheckBox_2");
    self.CheckBox_2:setTag(2);
    self.CheckBox_2:addEventListenerCheckBox(handler(self,self.selectedEvent));

    self.Label_name2 = self.CheckBox_2:getChildByName("Label_name2");
    self.Label_name2:setColor(cc.c3b(130,130,110));
    self.Label_name2:setText(MG_TEXT_COCOS("guild_rank_ui_2"));

    self.ListView = Panel_3:getChildByName("ListView");
    self.ListView:setScrollBarVisible(false);

    self.Label_tip = Panel_3:getChildByName("Label_tip");
    self.Label_tip:setText(MG_TEXT_COCOS("guild_rank_ui_3"));

    self.Button_close = Panel_2:getChildByName("Button_close");
    self.Button_close:addTouchEventListener(handler(self,self.onButtonClick));

    if not self.itemWidget then
        self.itemWidget = MGRCManager:widgetFromJsonFile("guildMercenaryLayer", "guild_rank_item_ui.ExportJson",false);
        self.itemWidget:retain();
    end

end

function guildWelfareRank:setData(data)
    self.data = data;

    if #self.data.red_rank <= 0 then
        return;
    end
    -- table.sort(self.data.red_rank,function(data1,data2)
    --     if tonumber(data1.red_num) == tonumber(data2.red_num) and tonumber(data1.gold) == tonumber(data2.gold) then
    --         return tonumber(data1.coin) > tonumber(data2.coin);
    --     end

    --     if tonumber(data1.red_num)  == tonumber(data2.red_num) then
    --         return tonumber(data2.gold) > tonumber(data2.gold);
    --     end

    --     return tonumber(data1.red_num) > tonumber(data2.red_num);
    -- end)
    self.Label_tip:setVisible(false);
    self.ListView:removeAllItems();
    for i=1,#self.data.red_rank do
        local item = guildWelfareRankItem.create(self,self.itemWidget:clone());
        item:setData(self.data.red_rank[i]);
        self.ListView:pushBackCustomItem(item);
    end
end

function guildWelfareRank:selectedEvent(sender,eventType)
    sender:setSelectedState(true);
    if sender == self.curCheckBox then
        return;
    else
        self.curCheckBox:setSelectedState(false);
        if sender == self.CheckBox_1 then
            self:sendReq(1);
        elseif sender == self.CheckBox_2 then
            self:sendReq(2);
        end
        self.curCheckBox = sender;
    end
end

function guildWelfareRank:onButtonClick(sender, eventType)
    buttonClickScale(sender, eventType);
    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_close then
            self:removeFromParent();
        end
    end
end

function guildWelfareRank:onReciveData(MsgID, NetData)
    print("guildWelfareRank onReciveData MsgID:"..MsgID)

    if MsgID == Post_Union_Red_getRedRank then
        local ackData = NetData
        if ackData.state == 1 then
            self:setData(ackData.getredrank);
        else
            NetHandler:showFailedMessage(ackData);
        end
    end
end

function guildWelfareRank:sendReq(type)--排行榜类型 1抢红包排行榜 2发红包排行榜
    local str = "&type="..type;
    NetHandler:sendData(Post_Union_Red_getRedRank, str);
end

function guildWelfareRank:pushAck()
    NetHandler:addAckCode(self,Post_Union_Red_getRedRank);
end

function guildWelfareRank:popAck()
    NetHandler:delAckCode(self,Post_Union_Red_getRedRank);
end

function guildWelfareRank:onEnter()
    self:pushAck();
    self:sendReq(1);
end

function guildWelfareRank:onExit()
    self:popAck();
    MGRCManager:releaseResources("guildWelfareRank");
    if self.itemWidget then
        self.itemWidget:release();
    end
end

function guildWelfareRank.create(delegate)
    local layer = guildWelfareRank:new()
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

function guildWelfareRank.showBox(delegate)
    local layer = guildWelfareRank.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
