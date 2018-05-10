-----------------------公会福利----红包详情界面------------------------

local guildWelfareDetailsItem = require "guildWelfareDetailsItem";
guildWelfareDetails = class("guildWelfareDetails", MGLayer)

function guildWelfareDetails:ctor()
    self.surplusMoney = 0;
    self.isOver = false;--红包是否抢完
    self.maxNum = 0;
    self.timeNum = 0;
    self:init();
end

function guildWelfareDetails:init()
    local pWidget = MGRCManager:widgetFromJsonFile("guildWelfareDetails","guild_welfare_details_ui.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:setAnchorPoint(cc.p(0.5, 0.5));
    CommonMethod:setFullBgScale(self.Panel_1);

    local Panel_2 = pWidget:getChildByName("Panel_2");
    self.ListView = Panel_2:getChildByName("ListView");
    self.ListView:setScrollBarVisible(false);
    -- self.ListView:setItemsMargin(60);

    self.Label_num1 = Panel_2:getChildByName("Label_num1");
    self.Label_num2 = Panel_2:getChildByName("Label_num2");
    self.Image_gold = Panel_2:getChildByName("Image_gold");

    self.Button_close = Panel_2:getChildByName("Button_close");
    self.Button_close:addTouchEventListener(handler(self,self.onButtonClick));

    local Label_tip1 = Panel_2:getChildByName("Label_tip1");
    Label_tip1:setText(MG_TEXT_COCOS("guild_welfare_details_ui_1"));

    local Label_tip2 = Panel_2:getChildByName("Label_tip2");
    Label_tip2:setText(MG_TEXT_COCOS("guild_welfare_details_ui_2"));

    if not self.itemWidget then
        self.itemWidget = MGRCManager:widgetFromJsonFile("guildMercenaryLayer", "guild_welfare_details_item_ui.ExportJson",false);
        self.itemWidget:retain();
    end

    -- local sql = string.format("select value from config where id=103");
    -- local DBData = LUADB.select(sql, "value");
    -- self.value = tonumber(DBData.info.value);
    -- Label_tip:setText(string.format(MG_TEXT("guildWelfareDetails_2"),self.value));
end

function guildWelfareDetails:setData(data)
    self.data = data;
    self.surplusMoney = self.data.totalMoney;

    if tonumber(self.data.type) == 1 then--钻石红包
        self.Image_gold:loadTexture("main_icon_masonry.png",ccui.TextureResType.plistType);
    elseif tonumber(self.data.type) == 2 then--金币红包
        self.Image_gold:loadTexture("main_icon_gold.png",ccui.TextureResType.plistType);
    end
    self.Label_num2:setText(string.format("%d/%d",self.data.get_num,self.data.num));

    if self.surplusMoney == 0 and self.data.get_num == self.data.num then
        self.isOver = true;
    end

    self.ListView:removeAllItems();
    for i=1,#self.data.red_info do
        if self.isOver == true then--红包已经抢完
            if self.maxNum < tonumber(self.data.red_info[i].get_num) then
                self.maxNum = tonumber(self.data.red_info[i].get_num);
                self.timeNum = tonumber(self.data.red_info[i].timeNum);
            elseif self.maxNum == tonumber(self.data.red_info[i].get_num) then
                if self.timeNum > tonumber(self.data.red_info[i].get_time) then
                    self.timeNum = tonumber(self.data.red_info[i].get_time)
                end
            end
        end

        self.data.red_info[i].isOver = self.isOver;
        self.data.red_info[i].maxNum = self.maxNum;
        self.data.red_info[i].timeNum = self.timeNum;

        local item = guildWelfareDetailsItem.create(self,self.itemWidget:clone());
        item:setData(self.data.red_info[i]);
        self.ListView:pushBackCustomItem(item);
        self.surplusMoney = self.surplusMoney - self.data.red_info[i].get_num;
    end

    self.Label_num1:setText(self.surplusMoney);
end

function guildWelfareDetails:onButtonClick(sender, eventType)
    if sender ~= self.Panel_btn1 and sender ~= self.Panel_btn2 then
        buttonClickScale(sender, eventType);
    end
    if eventType == ccui.TouchEventType.ended then
        if sender == self.Panel_btn1 then
            self.Image_select:setPositionY(self.posY_1);
            self.Label_btn1:setColor(cc.c3b(255,255,255));
            self.Label_btn2:setColor(cc.c3b(130,130,111));
        elseif sender == self.Panel_btn2 then
            self.Image_select:setPositionY(self.posY_2);
            self.Label_btn2:setColor(cc.c3b(255,255,255));
            self.Label_btn1:setColor(cc.c3b(130,130,111));
        elseif sender == self.Button_hongb then--我的红包

        elseif sender == self.Button_close then
            self:removeFromParent();
        end
    end
end

function guildWelfareDetails:onReciveData(MsgID, NetData)
    print("guildWelfareDetails onReciveData MsgID:"..MsgID)

    if MsgID == Post_union_getStorage then
    --     local ackData = NetData
    --     if ackData.state == 1 then
    --         self:setData(ackData.upunionstorageitem);
    --     else
    --         NetHandler:showFailedMessage(ackData);
    --     end
    -- elseif MsgID == Post_applyItem then
    --     local ackData = NetData
    --     if ackData.state == 1 then
    --         if ackData.upunionstorageitem then
    --             self:setData(ackData.upunionstorageitem);
    --         end
    --         MGMessageTip:showFailedMessage(MG_TEXT("guildWelfareDetails_5"));
    --     else
    --         NetHandler:showFailedMessage(ackData);
    --     end
    end
end

function guildWelfareDetails:sendReq()
    local str = string.format("&id=%s&num=%d",self.id,self.goodsNum);
    NetHandler:sendData(Post_applyItem, str);
end

function guildWelfareDetails:pushAck()
    NetHandler:addAckCode(self,Post_union_getStorage);
    NetHandler:addAckCode(self,Post_applyItem);
    
end

function guildWelfareDetails:popAck()
    NetHandler:delAckCode(self,Post_union_getStorage);
    NetHandler:delAckCode(self,Post_applyItem);
end

function guildWelfareDetails:onEnter()
    self:pushAck();
    -- NetHandler:sendData(Post_union_getStorage, "");
end

function guildWelfareDetails:onExit()
    self:popAck();
    MGRCManager:releaseResources("guildWelfareDetails");
    if self.itemWidget then
        self.itemWidget:release();
    end
end

function guildWelfareDetails.create(delegate)
    local layer = guildWelfareDetails:new()
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

function guildWelfareDetails.showBox(delegate)
    local layer = guildWelfareDetails.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
