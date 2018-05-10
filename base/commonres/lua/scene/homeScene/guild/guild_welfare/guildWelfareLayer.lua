-----------------------公会福利----发红包界面------------------------
require "ResourceTip"
require "guildWelfareDetails"

local guildWelfareItem = require "guildWelfareItem"
guildWelfareLayer = class("guildWelfareLayer", MGLayer)

function guildWelfareLayer:ctor()
    self.curLayer = nil;
    self.curItem = nil;
    self.iCount = 0;--计算可领红包个数
    self:init();
end

function guildWelfareLayer:init()
    local pWidget = MGRCManager:widgetFromJsonFile("guildWelfareLayer","guild_welfare_ui.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);

    self.pPanelTop = PanelTop.create(self)
    self.pPanelTop:setData("guild_welfare_title.png");
    self:addChild(self.pPanelTop,10);
    self.pPanelTop:showRankCoin(false);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:setAnchorPoint(cc.p(0.5, 0.5));
    CommonMethod:setFullBgScale(self.Panel_1);

    local Panel_2 = pWidget:getChildByName("Panel_2");
    self.Panel_3 = Panel_2:getChildByName("Panel_3");

    self.ListView = Panel_2:getChildByName("ListView");
    self.ListView:setScrollBarVisible(false);
    self.ListView:setItemsMargin(60);

    self.Label_num1 = self.Panel_3:getChildByName("Label_num1");
    self.Label_num2 = self.Panel_3:getChildByName("Label_num2");
    self.Label_num3 = self.Panel_3:getChildByName("Label_num3");

    self.Label_tip = Panel_2:getChildByName("Label_tip");
    self.Label_tip:setVisible(false);

    local Label_hongb1 = self.Panel_3:getChildByName("Label_hongb1");
    Label_hongb1:setText(MG_TEXT_COCOS("guild_welfare_ui_1"));

    local Label_hongb2 = self.Panel_3:getChildByName("Label_hongb2");
    Label_hongb2:setText(MG_TEXT_COCOS("guild_welfare_ui_2"));

    local Label_hongb3 = self.Panel_3:getChildByName("Label_hongb3");
    Label_hongb3:setText(MG_TEXT_COCOS("guild_welfare_ui_3"));

    if not self.itemWidget then
        self.itemWidget = MGRCManager:widgetFromJsonFile("guildMercenaryLayer", "guild_welfare_item_ui.ExportJson",false);
        self.itemWidget:retain();
    end

    local sql = string.format("select value from config where id=105");
    local DBData = LUADB.select(sql, "value");
    self.value = tonumber(DBData.info.value);

end

function guildWelfareLayer:setData(data)
    self.data = data;

    if self.data.red_list and #self.data.red_list <= 0 then
        self.Label_tip:setVisible(true);
        self.Panel_3:setVisible(false);
        return;
    end
    self.ListView:removeAllItems();
    for i=1,#self.data.red_list do
        local item = guildWelfareItem.create(self,self.itemWidget:clone());
        item:setData(self.data.red_list[i]);
        self.ListView:pushBackCustomItem(item);

        if tonumber(self.data.red_list[i].is_get) == 0 then--是否领取 1领取 0没有
            self.iCount = self.iCount + 1;
        end
    end

    self.Label_num1:setText(#self.data.red_list);
    self.Label_num2:setText(self.iCount);
    self.Label_num3:setText(string.format("%d/%d",self.data.get_red_num_day,self.value));
end


function guildWelfareLayer:ItemSelect(item)
    self.curItem = item;
    if tonumber(item.data.get_num) < tonumber(item.data.num) and tonumber(self.data.get_red_num_day) < self.value 
        and tonumber(item.data.is_get) == 0 then
        self:sendReq(tonumber(item.data.id));
    else
        self:sendGetUserRedInfoReq(tonumber(item.data.id));
    end
end

function guildWelfareLayer:back()
    self:removeFromParent();
end

function guildWelfareLayer:onReciveData(MsgID, NetData)
    print("guildWelfareLayer onReciveData MsgID:"..MsgID)

    if MsgID == Post_Union_Red_getUnionRedList then
        local ackData = NetData
        if ackData.state == 1 then
            self:setData(ackData.getunionredlist);
        else
            NetHandler:showFailedMessage(ackData);
        end
    elseif MsgID == Post_Union_Red_getUnionRed then
        local ackData = NetData
        if ackData.state == 1 then
            ResourceTip.getInstance():show();
            self:setData(ackData.getunionredlist);
        else
            NetHandler:showFailedMessage(ackData);
        end
    elseif MsgID == Post_Union_Red_getUnionRedInfo then
        local ackData = NetData
        if ackData.state == 1 then
            if self.curItem then
                ackData.getunionredinfo.totalMoney = tonumber(self.curItem.data.money);
                ackData.getunionredinfo.get_num = tonumber(self.curItem.data.get_num);
                ackData.getunionredinfo.num = tonumber(self.curItem.data.num);
                ackData.getunionredinfo.type = tonumber(self.curItem.data.type);
            end
            local guildWelfareDetails = guildWelfareDetails.showBox(self);
            guildWelfareDetails:setData(ackData.getunionredinfo);
        else
            NetHandler:showFailedMessage(ackData);
        end
    end
end

function guildWelfareLayer:sendReq(id)
    ResourceTip.getInstance():init();
    local str = "&id="..id;
    NetHandler:sendData(Post_Union_Red_getUnionRed, str);
end

function guildWelfareLayer:sendGetUserRedInfoReq(id)
    local str = "&id="..id;
    NetHandler:sendData(Post_Union_Red_getUnionRedInfo, str);
end

function guildWelfareLayer:pushAck()
    NetHandler:addAckCode(self,Post_Union_Red_getUnionRedList);
    NetHandler:addAckCode(self,Post_Union_Red_getUnionRed);
    NetHandler:addAckCode(self,Post_Union_Red_getUnionRedInfo);
    
end

function guildWelfareLayer:popAck()
    NetHandler:delAckCode(self,Post_Union_Red_getUnionRedList);
    NetHandler:delAckCode(self,Post_Union_Red_getUnionRed);
    NetHandler:delAckCode(self,Post_Union_Red_getUnionRedInfo);
end

function guildWelfareLayer:onEnter()
    self:pushAck();
    NetHandler:sendData(Post_Union_Red_getUnionRedList, "");
end

function guildWelfareLayer:onExit()
    self:popAck();
    MGRCManager:releaseResources("guildWelfareLayer");
    if self.itemWidget then
        self.itemWidget:release();
    end
end

function guildWelfareLayer.create(delegate)
    local layer = guildWelfareLayer:new()
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
