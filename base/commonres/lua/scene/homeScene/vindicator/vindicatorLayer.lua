--------------------------维护者之誓( 草船借箭)系统-----------------------
require "vindicatorReport"
require "tip"
require "playerInfo"

vindicatorLayer = class("vindicatorLayer", MGLayer)

function vindicatorLayer:ctor()

end

function vindicatorLayer:init(delegate,scenetype)
    self.delegate = delegate;
    self.scenetype = scenetype;
    MGRCManager:cacheResource("vindicatorLayer", "package_bg.jpg");
    MGRCManager:cacheResource("vindicatorLayer", "character.png");
    MGRCManager:cacheResource("vindicatorLayer", "vindicatorLayer_ui.png", "vindicatorLayer_ui.plist");
    local pWidget = MGRCManager:widgetFromJsonFile("vindicatorLayer","oath_of_maintainer_ui.ExportJson");
    self:addChild(pWidget);

    local Panel_1 = pWidget:getChildByName("Panel_1");
    Panel_1:setAnchorPoint(cc.p(0.5, 0.5));
    CommonMethod:setFullBgScale(Panel_1);

    self.pPanelTop = PanelTop.create(self)
    self.pPanelTop:setData("vindicator_title.png");
    self:addChild(self.pPanelTop,10);

    local Panel_2 = pWidget:getChildByName("Panel_2");
    local Panel_right = Panel_2:getChildByName("Panel_right");

    self.ListView = Panel_right:getChildByName("ListView_reward");
    -- self.ListView:setItemsMargin(10);
    self.ListView:setScrollBarVisible(false);

    self.Label_time = Panel_right:getChildByName("Label_time");
    self.Label_instruction = Panel_right:getChildByName("Label_instruction");

    local Image_high = Panel_right:getChildByName("Image_high");
    self.Label_score1 = Image_high:getChildByName("Label_score1");
    self.Label_score2 = Image_high:getChildByName("Label_score2");
    
    self.Image_stage_box = Panel_right:getChildByName("Image_stage_box");
    self.Image_stage_box:setTouchEnabled(true);
    self.Image_stage_box:addTouchEventListener(handler(self,self.onButtonClick));

    self.Label_target = self.Image_stage_box:getChildByName("Label_target");
    self.Image_diamond = self.Image_stage_box:getChildByName("Image_diamond");
    self.Label_num = self.Image_stage_box:getChildByName("Label_num");
    self.Label_num:getLabel():setAdditionalKerning(-2);

    self.Button_add = Panel_right:getChildByName("Button_add");
    self.Button_add:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_start = Panel_right:getChildByName("Button_start");--开始布阵
    self.Button_start:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_report = Panel_right:getChildByName("Button_report");--最强战报
    self.Button_report:addTouchEventListener(handler(self,self.onButtonClick));

    local Label_condition_1 = Panel_right:getChildByName("Label_condition_1");
    Label_condition_1:setVisible(false);
    self.conditonLabel1 = MGColorLabel:label();
    self.conditonLabel1:setAnchorPoint(cc.p(0, 0.5));
    self.conditonLabel1:setPosition(Label_condition_1:getPosition());
    Panel_right:addChild(self.conditonLabel1);
    self.conditonLabel1:clear();
    self.conditonLabel1:appendStringAutoWrap(MG_TEXT("vindicatorLayer_1"),16,1,cc.c3b(255,255,255),22);

    local Label_condition_2 = Panel_right:getChildByName("Label_condition_2");
    Label_condition_2:setVisible(false);
    self.conditonLabel2 = MGColorLabel:label();
    self.conditonLabel2:setAnchorPoint(cc.p(0, 0.5));
    self.conditonLabel2:setPosition(Label_condition_2:getPosition());
    Panel_right:addChild(self.conditonLabel2);
    self.conditonLabel2:clear();
    self.conditonLabel2:appendStringAutoWrap(MG_TEXT("vindicatorLayer_2"),16,1,cc.c3b(255,255,255),22);

    local Label_stage_1 = self.Image_stage_box:getChildByName("Label_stage_1");
    Label_stage_1:setText(MG_TEXT_COCOS("oath_of_maintainer_ui_6"));
    Label_stage_1:setVisible(false);
    self.stageLabel = MGColorLabel:label();
    self.stageLabel:setAnchorPoint(cc.p(0, 0.5));
    self.stageLabel:setPosition(Label_stage_1:getPosition());
    self.Image_stage_box:addChild(self.stageLabel);
    self.stageLabel:clear();
    self.stageLabel:appendStringAutoWrap(string.format(MG_TEXT("vindicatorLayer_3"),1),16,1,cc.c3b(188,169,102),22);

    local Label_combat_instructions = Panel_right:getChildByName("Label_combat_instructions");
    local Label_combat_conditon = Panel_right:getChildByName("Label_combat_conditon");
    local Label_reward = Panel_right:getChildByName("Label_reward");
    local Label_history_high = Image_high:getChildByName("Label_history_high");
    local Label_today_high = Image_high:getChildByName("Label_today_high");
    
    local Label_stage_2 = self.Image_stage_box:getChildByName("Label_stage_2");
    local Label_surplus = Panel_right:getChildByName("Label_surplus");
    local Label_start = self.Button_start:getChildByName("Label_start");
    local Label_report = self.Button_report:getChildByName("Label_report");

    Label_combat_instructions:setText(MG_TEXT_COCOS("oath_of_maintainer_ui_1"));
    Label_combat_conditon:setText(MG_TEXT_COCOS("oath_of_maintainer_ui_2"));
    Label_reward:setText(MG_TEXT_COCOS("oath_of_maintainer_ui_3"));
    Label_history_high:setText(MG_TEXT_COCOS("oath_of_maintainer_ui_4"));
    Label_today_high:setText(MG_TEXT_COCOS("oath_of_maintainer_ui_5"));
    Label_stage_2:setText(MG_TEXT_COCOS("oath_of_maintainer_ui_7"));
    Label_surplus:setText(MG_TEXT_COCOS("oath_of_maintainer_ui_8"));
    Label_start:setText(MG_TEXT_COCOS("oath_of_maintainer_ui_9"));
    Label_report:setText(MG_TEXT_COCOS("oath_of_maintainer_ui_10"));

    self:readSql()--解析数据库数据
end

function vindicatorLayer:readSql()--解析数据库数据
    self.rewardList = {};
    local sql = string.format("select * from maintainers_reward");
    local DBDataList = LUADB.selectlist(sql, "id:num:reward");

    for index=1,#DBDataList.info do
        local DBData = {};
        DBData.id = tonumber(DBDataList.info[index].id);
        DBData.num = tonumber(DBDataList.info[index].num);

        DBData.reward = getDataList(DBDataList.info[index].reward);

        self.rewardList[DBData.id]=DBData;
    end
end

function vindicatorLayer:setData()

end

function vindicatorLayer:initData(data)
    self.data = data;

    self.Label_score1:setText(tonumber(self.data.best_num));
    self.Label_score2:setText(tonumber(self.data.day_num));
    self.Label_time:setText(string.format(MG_TEXT("trialMainLayer_1"),tonumber(self.data.surplus_num)));

    self.ListView:removeAllItems();
    local item = resItem.create(self);
    item:setData(4,1);
    item:setNumVisible(false);
    self.ListView:pushBackCustomItem(item);

    for i=1,#self.rewardList do
        if self.rewardList[i].num > tonumber(self.data.best_num) then
            self.stageLabel:clear();
            self.stageLabel:appendStringAutoWrap(string.format(MG_TEXT("vindicatorLayer_3"),i),16,1,cc.c3b(188,169,102),22);
            self.Label_target:setText(self.rewardList[i].num);
            self.Label_num:setText(self.rewardList[i].reward[1].value3);
            local info = itemInfo(self.rewardList[i].reward[1].value1,self.rewardList[i].reward[1].value2);
            if info then
                MGRCManager:cacheResource("vindicatorLayer",info.item_pic);
                self.Image_diamond:loadTexture(info.item_pic,ccui.TextureResType.plistType);
            end
            break;
        end
    end
    
end

function vindicatorLayer:onWar()--进入战斗
    FightOP:setTeam(self.scenetype,Fight_Maintainers,"","","");
end

function vindicatorLayer:onButtonClick(sender, eventType)
    if sender ~= self.Image_stage_box then
        buttonClickScale(sender, eventType);
    end

    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_add then
            local tip = tip.showBox(self);
            tip:setVindicatorData(self.data);
        elseif sender == self.Button_start then--开始布阵
            self:onWar();
        elseif sender == self.Button_report then--最强战报
            local vindicatorReport = vindicatorReport.showBox(self);
            vindicatorReport:setData();
        elseif sender == self.Image_stage_box then--领奖
            -- FightOP:setTeam(self.scenetype,8,MG_TEXT("vindicatorLayer_4"));
        end
    end
end

function vindicatorLayer:reportItemSelect(item)
    print(">>>>>>>>>>伊丽莎白二世>>>>>>>>>>>")
    local playerInfo = playerInfo.create(self);
    -- playerInfo:setData(item.info.uid,item.info.name);
    playerInfo:setData("61K00111CB3F68E","1500391033");
    cc.Director:getInstance():getRunningScene():addChild(playerInfo,ZORDER_MAX);
end

function vindicatorLayer:back()
    self:removeFromParent();
end

function vindicatorLayer:buy()
    if ME:getGold() < tonumber(self.data.use_gold) then
        MGMessageTip:showFailedMessage(MG_TEXT("IslandMainLayer_4"));
    else
        NetHandler:sendData(Post_Maintainers_payAtkNum, "");
    end
end

function vindicatorLayer:onReciveData(MsgID, NetData)
    print("vindicatorLayer onReciveData MsgID:"..MsgID)

    if MsgID == Post_maintainersInfo then
        local ackData = NetData
        if ackData.state == 1 then
            self:initData(ackData.maintainersinfo);
        else
            NetHandler:showFailedMessage(ackData);
        end
    elseif MsgID == Post_Maintainers_payAtkNum then
        local ackData = NetData
        if ackData.state == 1 then
            self.data.surplus_num = ackData.payatknum.surplus_num;
            self.data.buy_num = ackData.payatknum.buy_num;
            self.data.use_gold = ackData.payatknum.use_gold;
            self:initData(self.data);
            self.pPanelTop:upData();
            MGMessageTip:showFailedMessage(MG_TEXT("tip_3"));
        else
            NetHandler:showFailedMessage(ackData);
        end
    elseif MsgID == Post_Maintainers_fighting then
        local ackData = NetData
        if ackData.state == 1 then

        else
            NetHandler:showFailedMessage(ackData);
        end
    elseif MsgID == Post_getReward then
        local ackData = NetData
        if ackData.state == 1 then

        else
            NetHandler:showFailedMessage(ackData);
        end
    end
end

function vindicatorLayer:paySendReq()
    local str = string.format("&lid=%d",2);
    NetHandler:sendData(Post_Maintainers_payAtkNum, str);
end

function vindicatorLayer:pushAck()
    NetHandler:addAckCode(self,Post_maintainersInfo);
    NetHandler:addAckCode(self,Post_Maintainers_payAtkNum);
    NetHandler:addAckCode(self,Post_Maintainers_fighting);
    NetHandler:addAckCode(self,Post_getReward);
end

function vindicatorLayer:popAck()
    NetHandler:delAckCode(self,Post_maintainersInfo);
    NetHandler:delAckCode(self,Post_Maintainers_payAtkNum);
    NetHandler:delAckCode(self,Post_Maintainers_fighting);
    NetHandler:delAckCode(self,Post_getReward);
end

function vindicatorLayer:onEnter()
    self:pushAck();
    NetHandler:sendData(Post_maintainersInfo, "");
end

function vindicatorLayer:onExit()
    MGRCManager:releaseResources("vindicatorLayer");
    self:popAck();
end

function vindicatorLayer.create(delegate,scenetype)
    local layer = vindicatorLayer:new()
    layer:init(delegate,scenetype)
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

function vindicatorLayer.showBox(delegate,scenetype)
    local layer = vindicatorLayer.create(delegate,scenetype);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
