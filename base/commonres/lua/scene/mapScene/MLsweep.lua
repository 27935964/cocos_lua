----------------------扫荡界面-------------------------

MLsweep = class("MLsweep", MGLayer)

function MLsweep:ctor()
    self.btnType = 1;
    self.sweepNum = 1;
    self:init();
end

function MLsweep:init()
    MGRCManager:cacheResource("MLsweep", "user_card_get_bg.png");
    local pWidget = MGRCManager:widgetFromJsonFile("MLsweep","sweeping_ui.ExportJson");
    self:addChild(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));
    local Panel_2 = pWidget:getChildByName("Panel_2");

    local Panel_3 = Panel_2:getChildByName("Panel_3");
    self.Panel_5 = Panel_3:getChildByName("Panel_5");
    self.Panel_6 = Panel_3:getChildByName("Panel_6");

    self.Label_action1 = self.Panel_6:getChildByName("Label_action1");
    self.Label_sweep = self.Panel_5:getChildByName("Label_sweep");
    
    self.Button_min = self.Panel_5:getChildByName("Button_min");--减
    self.Button_min:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_add = self.Panel_5:getChildByName("Button_add");--加
    self.Button_add:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_1 = Panel_2:getChildByName("Button_1");--选择路线
    self.Button_1:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_2 = Panel_2:getChildByName("Button_2");--选择路线或者再次扫荡
    self.Button_2:addTouchEventListener(handler(self,self.onButtonClick));
    self.Label_2 = self.Button_2:getChildByName("Label_2");

    self.Button_3 = Panel_2:getChildByName("Button_3");--再次扫荡
    self.Button_3:addTouchEventListener(handler(self,self.onButtonClick));
    
    self.Panel_4 = Panel_3:getChildByName("Panel_4");
    self.Label_action2 = self.Panel_4:getChildByName("Label_action2");

    self.Button_close = Panel_2:getChildByName("Button_close");--关闭
    self.Button_close:addTouchEventListener(handler(self,self.onButtonClick));

    local Label_tip1 = self.Panel_6:getChildByName("Label_tip1");
    local Label_tip2 = self.Panel_4:getChildByName("Label_tip2");
    self.Label_tip3 = Panel_3:getChildByName("Label_tip3");
    local Label_26 = self.Panel_5:getChildByName("Label_26");
    self.Label_tip4 = Panel_2:getChildByName("Label_tip4");
    self.Label_tip5 = Panel_2:getChildByName("Label_tip5");

    Label_tip1:setText(MG_TEXT_COCOS("sweeping_ui_1"));
    Label_tip2:setText(MG_TEXT_COCOS("sweeping_ui_2"));
    self.Label_tip3:setText(MG_TEXT_COCOS("sweeping_ui_3"));
    Label_26:setText(MG_TEXT_COCOS("sweeping_ui_4"));
    self.Label_tip4:setText(MG_TEXT_COCOS("sweeping_ui_5"));
    self.Label_tip5:setText(MG_TEXT_COCOS("sweeping_ui_5"));

    self:readSql();
end

function MLsweep:readSql()--解析数据库数据
    local sql = "select * from config where id=18";
    local DBData = LUADB.select(sql, "value");
    self.stage_action = tonumber(DBData.info.value);
end

function MLsweep:setData(data,mapInfo,type)
    self.data = data;
    self.checkpointId = mapInfo.id;
    self.mapInfo = mapInfo;
    self.type = type;
    if nil == type then
        self.type = 1;
    end

    self.Label_action1:setText(self.mapInfo.max_road_strength);
    if self.type == 1 then
        if nil == self.data.sweep_line or self.data.sweep_line == "" then
            self.Panel_4:setVisible(false);
            self.Label_tip3:setVisible(true);

            self.Button_1:setEnabled(false);
            self.Button_2:setEnabled(true);
            self.Button_3:setEnabled(false);
            self.Label_tip4:setEnabled(false);
            self.Label_tip5:setEnabled(false);
            self.Label_2:setText(MG_TEXT("ML_MLsweep_1"));
            self.btnType = 1;
        else
            self.sweep_lines = getDataList(self.data.sweep_line);
            self.oneAction = (#self.sweep_lines-1)*self.stage_action;
            self.Label_action2:setText(self.oneAction);

            self.Panel_4:setVisible(true);
            self.Label_tip3:setVisible(false);

            self.Button_1:setEnabled(true);
            self.Button_2:setEnabled(false);
            self.Button_3:setEnabled(true);
            self.Label_tip4:setEnabled(true);
            self.Label_tip5:setEnabled(false);
        end
    elseif self.type == 2 or self.type == 3 then
        self.Button_1:setEnabled(false);
        self.Button_2:setEnabled(true);
        self.Button_3:setEnabled(false);
        self.Label_tip4:setEnabled(false);
        self.Label_tip5:setEnabled(false);
        self.Panel_5:setVisible(true);
        self.Button_min:setEnabled(true);
        self.Button_add:setEnabled(true);

        if self.type == 2 then--重新选路
            self.btnType = 1;
            self.Label_2:setText(MG_TEXT("ML_MLsweep_1"));
        elseif self.type == 3 then--再次扫荡
            self.btnType = 2;
            self.Label_tip5:setEnabled(true);
            self.Label_2:setText(MG_TEXT("ML_MLsweep_2"));
        end

        if nil == self.data.sweep_line or self.data.sweep_line == "" then
            self.Label_tip3:setVisible(true);
            self.Label_tip5:setEnabled(false);
            self.Panel_4:setVisible(false);
            self.Panel_5:setVisible(false);
            self.Button_min:setEnabled(false);
            self.Button_add:setEnabled(false);
            self.Panel_6:setPositionY(100);
            self.Label_tip3:setPositionY(80);
            self.btnType = 1;
            self.Label_2:setText(MG_TEXT("ML_MLsweep_1"));
        else
            self.Label_tip3:setVisible(false);
            self.Panel_4:setVisible(true);
        end
    end
end

function MLsweep:onButtonClick(sender, eventType)
    if sender ~= self.Panel_1 then
        buttonClickScale(sender, eventType);
    end

    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_min then--减
            self:setSweepNum(sender);
        elseif sender == self.Button_add then--加
            self:setSweepNum(sender);
        elseif sender == self.Button_1 then--选择路线
            self:chooseRoad();
        elseif sender == self.Button_2 then--选择路线或者再次扫荡
            if self.btnType == 1 then--选择路线
                self:chooseRoad();
            elseif self.btnType == 2 then--再次扫荡
                self:sweepAgain();
            end
        elseif sender == self.Button_3 then--再次扫荡
            self:sweepAgain();
        elseif sender == self.Panel_1 or sender == self.Button_close then--关闭
            self:removeFromParent();
        end
    end
end

function MLsweep:setSweepNum(sender)
    if sender == self.Button_min then--减
        self.sweepNum = self.sweepNum - 1;
        if self.sweepNum <= 1 then
            self.sweepNum = 1;
        end
    elseif sender == self.Button_add then--加
        self.sweepNum = self.sweepNum + 1;
    end
    self.Label_sweep:setText(self.sweepNum);
    self.Label_action1:setText(self.mapInfo.max_road_strength*self.sweepNum);
    self.Label_action2:setText(self.oneAction*self.sweepNum);
end

function MLsweep:chooseRoad()
    if ME:getAction() >= self.mapInfo.max_road_strength then
        if self.delegate and self.delegate.checkRoad then
            self.delegate:checkRoad(1);
        end
        self:removeFromParent();
    else
        MGMessageTip:showFailedMessage(MG_TEXT("ML_MLsweep_3"));
    end
end

function MLsweep:sweepAgain()
    if ME:getAction() >= self.oneAction*self.sweepNum then
        self:sendReq();
        -- self:removeFromParent();
    else
        MGMessageTip:showFailedMessage(MG_TEXT("ML_MLsweep_3"));
    end
end

function MLsweep:onReciveData(MsgID, NetData)
    print("MLsweep onReciveData MsgID:"..MsgID)
    
    if MsgID == Post_doSweep then
        local ackData = NetData
        if ackData.state == 1 then
            if self.delegate and self.delegate.initSweepFlip then
                self.delegate:initSweepFlip(ackData.dosweep);
                self:removeFromParent();
            end
        else
            NetHandler:showFailedMessage(ackData)
        end
    end
end

function MLsweep:sendReq()
    local str = string.format("&sid=%d&num=%d",self.checkpointId,self.sweepNum);
    NetHandler:sendData(Post_doSweep, str);
end

function MLsweep:pushAck()
    NetHandler:addAckCode(self,Post_doSweep);
end

function MLsweep:popAck()
    NetHandler:delAckCode(self,Post_doSweep);
end

function MLsweep:onEnter()
    self:pushAck();
end

function MLsweep:onExit()
    self:popAck();
    MGRCManager:releaseResources("MLsweep");
end

function MLsweep.create(delegate)
    local layer = MLsweep:new()
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

function MLsweep.showBox(delegate)
    local layer = MLsweep.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
