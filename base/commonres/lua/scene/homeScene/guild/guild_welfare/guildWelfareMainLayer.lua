-----------------------公会福利主界面------------------------

require "guildWelfareLayer"
require "guildHairWelfare"
require "guildMyWelfare"
require "guildWelfareRank"

guildWelfareMainLayer = class("guildWelfareMainLayer", MGLayer)

function guildWelfareMainLayer:ctor()
    self.curLayer = nil;
    self.curBtn = nil;
    self:init();
end

function guildWelfareMainLayer:init()
    MGRCManager:cacheResource("guildWelfareMainLayer", "guild_welfare_item_bg.png");
    MGRCManager:cacheResource("guildWelfareMainLayer", "guild_welfare_head_title.png");
    MGRCManager:cacheResource("guildWelfareMainLayer", "guild_welfare_ui.png", "guild_welfare_ui.plist");
    local pWidget = MGRCManager:widgetFromJsonFile("guildWelfareMainLayer","guild_welfare_main_ui.ExportJson");
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
    -- self.Panel_3 = Panel_2:getChildByName("Panel_3");

    -- self.ListView = Panel_2:getChildByName("ListView");
    -- self.ListView:setScrollBarVisible(false);
    -- self.ListView:setItemsMargin(60);

    self.Panel_btn1 = Panel_2:getChildByName("Panel_btn1");
    self.Panel_btn1:addTouchEventListener(handler(self,self.onButtonClick));
    self.posY_1 = self.Panel_btn1:getPositionY()+self.Panel_btn1:getContentSize().height/2;

    self.Panel_btn2 = Panel_2:getChildByName("Panel_btn2");
    self.Panel_btn2:addTouchEventListener(handler(self,self.onButtonClick));
    self.posY_2 = self.Panel_btn2:getPositionY()+self.Panel_btn2:getContentSize().height/2;

    self.Button_hongb = Panel_2:getChildByName("Button_hongb");
    self.Button_hongb:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_rank = Panel_2:getChildByName("Button_rank");
    self.Button_rank:addTouchEventListener(handler(self,self.onButtonClick));

    self.Image_select = Panel_2:getChildByName("Image_select");

    self.Label_btn1 = self.Panel_btn1:getChildByName("Label_btn1");
    self.Label_btn1:setText(MG_TEXT_COCOS("guild_welfare_main_ui_1"));
    self.Label_btn1:setColor(cc.c3b(255,255,255));

    self.Label_btn2 = self.Panel_btn2:getChildByName("Label_btn2");
    self.Label_btn2:setText(MG_TEXT_COCOS("guild_welfare_main_ui_2"));
    self.Label_btn2:setColor(cc.c3b(130,130,111));

    local Label_hongb = Panel_2:getChildByName("Label_hongb");
    Label_hongb:setText(MG_TEXT_COCOS("guild_welfare_main_ui_3"));

    local Label_rank = Panel_2:getChildByName("Label_rank");
    Label_rank:setText(MG_TEXT_COCOS("guild_welfare_main_ui_4"));

    self:onButtonClick(self.Panel_btn1, ccui.TouchEventType.ended);
end

function guildWelfareMainLayer:setData(data)
    self.data = data;
end


-- function guildWelfareMainLayer:ItemSelect(item)
    
-- end

function guildWelfareMainLayer:back()
    self:removeFromParent();
end

function guildWelfareMainLayer:onButtonClick(sender, eventType)
    if sender ~= self.Panel_btn1 and sender ~= self.Panel_btn2 then
        buttonClickScale(sender, eventType);
    end
    if eventType == ccui.TouchEventType.ended then
        if sender == self.Panel_btn1 then
            if self.curLayer then
                if self.curBtn == sender then
                    return;
                else
                    self.curLayer:removeFromParent();
                    self.curLayer = nil;
                end
            end
            self.Image_select:setPositionY(self.posY_1);
            self.Label_btn1:setColor(cc.c3b(255,255,255));
            self.Label_btn2:setColor(cc.c3b(130,130,111));
            self.curLayer = guildWelfareLayer.create(self);
            self:addChild(self.curLayer);
            self.curBtn = sender;
        elseif sender == self.Panel_btn2 then
            if self.curLayer then
                if self.curBtn == sender then
                    return;
                else
                    self.curLayer:removeFromParent();
                    self.curLayer = nil;
                end
            end
            self.Image_select:setPositionY(self.posY_2);
            self.Label_btn2:setColor(cc.c3b(255,255,255));
            self.Label_btn1:setColor(cc.c3b(130,130,111));
            self.curLayer = guildHairWelfare.create(self);
            self:addChild(self.curLayer);
            self.curBtn = sender;
        elseif sender == self.Button_hongb then--我的红包
            self:sendReq();
        elseif sender == self.Button_rank then--排行
            local guildWelfareRank = guildWelfareRank.showBox(self);
        end
    end
end

function guildWelfareMainLayer:onReciveData(MsgID, NetData)
    print("guildWelfareMainLayer onReciveData MsgID:"..MsgID)

    if MsgID == Post_Union_Red_getUserRedInfo then
        local ackData = NetData
        if ackData.state == 1 then
            local guildMyWelfare = guildMyWelfare.showBox(self);
            guildMyWelfare:setData(ackData.getuserredinfo);
        else
            NetHandler:showFailedMessage(ackData);
        end
    end
end

function guildWelfareMainLayer:sendReq()
    local str = "&id="..tonumber(self.data.union_id);
    NetHandler:sendData(Post_Union_Red_getUserRedInfo, str);
end

function guildWelfareMainLayer:pushAck()
    NetHandler:addAckCode(self,Post_Union_Red_getUserRedInfo);
end

function guildWelfareMainLayer:popAck()
    NetHandler:delAckCode(self,Post_Union_Red_getUserRedInfo);
end

function guildWelfareMainLayer:onEnter()
    self:pushAck();
end

function guildWelfareMainLayer:onExit()
    self:popAck();
    MGRCManager:releaseResources("guildWelfareMainLayer");
end

function guildWelfareMainLayer.create(delegate)
    local layer = guildWelfareMainLayer:new()
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

function guildWelfareMainLayer.showBox(delegate)
    local layer = guildWelfareMainLayer.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
