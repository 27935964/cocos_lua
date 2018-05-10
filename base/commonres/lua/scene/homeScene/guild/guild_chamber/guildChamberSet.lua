-----------------------公会议会厅设置界面------------------------

guildChamberSet = class("guildChamberSet", MGLayer)

function guildChamberSet:ctor()
    self.limit = 1;
    self.level = 18;
    self.index = 0;
    self:init();
end

function guildChamberSet:init()
    local pWidget = MGRCManager:widgetFromJsonFile("guildChamberSet","guild_hall_ui_2.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:setAnchorPoint(cc.p(0.5, 0.5));
    CommonMethod:setFullBgScale(self.Panel_1);
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));

    local Panel_2 = pWidget:getChildByName("Panel_2");

    self.Label_anyone = Panel_2:getChildByName("Label_anyone");
    self.Label_level = Panel_2:getChildByName("Label_level");

    self.Button_arrow1 = Panel_2:getChildByName("Button_arrow1");
    self.Button_arrow1:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_arrow2 = Panel_2:getChildByName("Button_arrow2");
    self.Button_arrow2:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_arrow3 = Panel_2:getChildByName("Button_arrow3");
    self.Button_arrow3:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_arrow4 = Panel_2:getChildByName("Button_arrow4");
    self.Button_arrow4:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_save = Panel_2:getChildByName("Button_save");
    self.Button_save:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_close = Panel_2:getChildByName("Button_close");
    self.Button_close:addTouchEventListener(handler(self,self.onButtonClick));


    local Label_add_limit = Panel_2:getChildByName("Label_add_limit");
    Label_add_limit:setText(MG_TEXT_COCOS("guild_hall_ui_2_1"));

    local Label_level_condition = Panel_2:getChildByName("Label_level_condition");
    Label_level_condition:setText(MG_TEXT_COCOS("guild_hall_ui_2_2"));

    local Label_save = self.Button_save:getChildByName("Label_save");
    Label_save:setText(MG_TEXT_COCOS("guild_hall_ui_2_3"));
end

function guildChamberSet:setData(data)
    self.limit = tonumber(data.join_limit);
    self.level = tonumber(data.need_lv);

    self.Label_level:setText(MG_TEXT("Null"));
    self.Label_anyone:setText(MG_TEXT("guildChamberSet_"..self.limit));
    if self.limit == 1 then
        self.Label_level:setText(string.format(MG_TEXT("trialEntranceItem_1"),self.level));
    end
end

function guildChamberSet:setLimit(index)
    self.limit = self.limit + index;
    if self.limit < 1 then
        self.limit = 3;
    elseif self.limit > 3 then
        self.limit = 1;
    end

    self.Label_level:setText(MG_TEXT("Null"));
    self.Label_anyone:setText(MG_TEXT("guildChamberSet_"..self.limit));
    if self.limit == 1 then
        self.Label_level:setText(string.format(MG_TEXT("trialEntranceItem_1"),self.level));
    end
end

function guildChamberSet:setLevel()
    if self.limit ~= 1 then
        return;
    end

    self.level = self.level + self.index;
    if self.level <= 1 then
        self.level = 1;
    elseif self.level >= ME:getMaxUserLv() then
        self.level = ME:getMaxUserLv();
    end
    self.Label_level:setText(string.format(MG_TEXT("trialEntranceItem_1"),self.level));
end

function guildChamberSet:onButtonClick(sender, eventType)
    if sender ~= self.Panel_1 then
        buttonClickScale(sender, eventType);
    end

    if eventType == ccui.TouchEventType.began then
        if sender == self.Button_arrow3 or sender == self.Button_arrow4 then
            if sender == self.Button_arrow3 then
                self.index = -1;
            elseif sender == self.Button_arrow4 then
                self.index = 1;
            end
            local seq = cc.Sequence:create(cc.CallFunc:create(function() self:setLevel() end),cc.DelayTime:create(0.2));
            self.action = self:runAction(cc.RepeatForever:create(seq));
        end
    elseif eventType == ccui.TouchEventType.canceled then
        if sender == self.Button_arrow3 or sender == self.Button_arrow4 then
            self:stopAction(self.action);
        end
    elseif eventType == ccui.TouchEventType.ended then
        if sender == self.Button_arrow1 then
            self:setLimit(-1);
        elseif sender == self.Button_arrow2 then
            self:setLimit(1);
        elseif sender == self.Button_arrow3 then
            self:stopAction(self.action);
        elseif sender == self.Button_arrow4 then
            self:stopAction(self.action);
        elseif sender == self.Button_save then
            self:sendReq();
        else
            self:removeFromParent();
        end
    end
end

function guildChamberSet:onReciveData(MsgID, NetData)
    print("guildChamberSet onReciveData MsgID:"..MsgID)
    if MsgID == Post_getCheckType then
        local ackData = NetData;
        if ackData.state == 1 then
            self:setData(ackData.getchecktype);
        else
            NetHandler:showFailedMessage(ackData);
        end
    elseif MsgID == Post_changeCheckType then
        local ackData = NetData
        if ackData.state == 1 then
            MGMessageTip:showFailedMessage(MG_TEXT("guildChamberSet_4"));
        else
            NetHandler:showFailedMessage(ackData);
        end
    end
end

function guildChamberSet:sendReq()
    local str = "";
    if self.limit == 1 then
        str = string.format("&type=%d&need_lv=%d",self.limit,self.level);
    else
        str = string.format("&type=%d",self.limit);
    end
    NetHandler:sendData(Post_changeCheckType, str);
end

function guildChamberSet:pushAck()
    NetHandler:addAckCode(self,Post_getCheckType);
    NetHandler:addAckCode(self,Post_changeCheckType);
end

function guildChamberSet:popAck()
    NetHandler:delAckCode(self,Post_getCheckType);
    NetHandler:delAckCode(self,Post_changeCheckType);
end

function guildChamberSet:onEnter()
    self:pushAck();
    NetHandler:sendData(Post_getCheckType, "");
end

function guildChamberSet:onExit()
    self:popAck();
    MGRCManager:releaseResources("guildChamberSet");
end

function guildChamberSet.create(delegate,type)
    local layer = guildChamberSet:new()
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

function guildChamberSet.showBox(delegate,type)
    local layer = guildChamberSet.create(delegate,type);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
