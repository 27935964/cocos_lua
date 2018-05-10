require "HeroHeadEx"

MLTeam = class("MLTeam", MGLayer)

function MLTeam:ctor()
    self.tag = 1;
    self.emptyPos = 0;--空位数量
    self:init();
end

function MLTeam:init()
    local pWidget = MGRCManager:widgetFromJsonFile("MLTeam","team_ui_1.ExportJson");
    self:addChild(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    local Panel_2 = pWidget:getChildByName("Panel_2");
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));

    self.CheckBoxs={};
    self.CheckBox_1 = Panel_2:getChildByName("CheckBox_1");
    self.CheckBox_1:setTag(1);
    self.CheckBox_1:setSelectedState(true);
    self.CheckBox_1:addEventListenerCheckBox(handler(self,self.selectedEvent));
    table.insert(self.CheckBoxs,self.CheckBox_1);

    self.CheckBox_2 = Panel_2:getChildByName("CheckBox_2");
    self.CheckBox_2:setTag(2);
    self.CheckBox_2:addEventListenerCheckBox(handler(self,self.selectedEvent));
    table.insert(self.CheckBoxs,self.CheckBox_2);

    self.CheckBox_1 = Panel_2:getChildByName("CheckBox_1");
    self.CheckBox_2 = Panel_2:getChildByName("CheckBox_2");

    self.ListView_1 = Panel_2:getChildByName("ListView_1");
    self.ListView_1:setScrollBarVisible(false);

    self.ListView_2 = Panel_2:getChildByName("ListView_2");
    self.ListView_2:setScrollBarVisible(false);

    self.Button_close = Panel_2:getChildByName("Button_close");
    self.Button_close:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_team = Panel_2:getChildByName("Button_team");--一键编队
    self.Button_team:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_save = Panel_2:getChildByName("Button_save");--保存
    self.Button_save:addTouchEventListener(handler(self,self.onButtonClick));

    local Label_name1 = self.CheckBox_1:getChildByName("Label_name1");
    Label_name1:setText(MG_TEXT_COCOS("team_ui_1_1"));

    local Label_name2 = self.CheckBox_2:getChildByName("Label_name1");
    Label_name2:setText(MG_TEXT_COCOS("team_ui_1_2"));

    local Label_team = self.Button_team:getChildByName("Label_team");
    Label_team:setText(MG_TEXT_COCOS("team_ui_1_3"));

    local Label_save = self.Button_save:getChildByName("Label_save");
    Label_save:setText(MG_TEXT_COCOS("team_ui_1_4"));

    local sql = string.format("select value from config where id=109");
    local DBData = LUADB.select(sql, "value");
    self.lv = tonumber(DBData.info.value);
end

function MLTeam:setData(data,unionData)
    self.data = data;
    self.unionData = unionData;--联盟武将列表
    self.myLegionList = {};--我的军团里的武将
    self.unionGm = nil;--联盟武将
    
    local corp = self.data.corp;
    if corp and corp.corps then
        local str = spliteStr(corp.corps,'|');
        for i=1,#str do
            local gm = GENERAL:getGeneralModel(tonumber(str[i]));
            table.insert(self.myLegionList,gm);
        end
    end
    table.sort(self.myLegionList,function(a,b) return a:getWarScore() > b:getWarScore(); end);

    self.unionList = {};--我的联盟里的武将
    self.myGmList = {};--除军团里的武将外的所有武将
    local gmList = GENERAL:getGeneralList();
    if gmList then
        for i=1,#gmList do
            local isLegion = false;
            for j=1,#self.myLegionList do
                if self.myLegionList[j]:getId() == gmList[i]:getId() then
                    isLegion = true;
                end
            end

            if isLegion == false then
                table.insert(self.myGmList,gmList[i]);
            end
        end
    end
    table.sort(self.myGmList,function(a,b) return a:getWarScore() > b:getWarScore(); end);

    if self.unionData then
        table.sort(self.unionData.mercenary_general,function(a,b) return tonumber(a.war_score) > tonumber(b.war_score); end);
        local index_1 = 0;
        local index_2 = 0;
        for i=1,#self.unionData.mercenary_general do
            local mercenary_general = self.unionData.mercenary_general[i];
            self.unionData.mercenary_general[i].byFlag = 1;--1.表示可雇佣，2.表示金币不足，3.表示等级不够
            if ME:Lv() < tonumber(mercenary_general.lv) then--等级不够
                self.unionData.mercenary_general[i].byFlag = 3;
                table.insert(self.unionList,mercenary_general);
            else
                if ME:getCoin() < tonumber(mercenary_general.gold) then--表示金币不足
                    index_2 = index_2 + 1;
                    self.unionData.mercenary_general[i].byFlag = 2;
                    table.insert(self.unionList,index_2,mercenary_general);
                else
                    index_1 = index_1 + 1;
                    index_2 = index_2 + 1;
                    self.unionData.mercenary_general[i].byFlag = 1;
                    table.insert(self.unionList,index_1,mercenary_general);
                end
            end
        end
    end
    
    self:createGeneralListItem(self.myGmList);
    self:createTeamListItem();
end

function MLTeam:createGeneralListItem(gmList)
    self.ListView_1:removeAllItems();
    local totalNum = #gmList;
    if totalNum <= 0 then
        return;
    end
    local queues = {};
    queues = newline(totalNum,4);

    -- table.remove(gmList,1);

    local itemLay = ccui.Layout:create();
    itemLay:setSize(cc.size(self.ListView_1:getContentSize().width, queues[totalNum].row*135));
    self.ListView_1:pushBackCustomItem(itemLay);

    local itemIndex = 1;
    local function loadEachItem(dt)
        if itemIndex > totalNum then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
        else
            local layout = ccui.Layout:create();
            layout:setSize(cc.size(92, 92));
            layout:setAnchorPoint(cc.p(0.5,0.5));
            layout:setPosition(cc.p(queues[itemIndex].col*110+18+layout:getContentSize().width/2,
                    itemLay:getContentSize().height-queues[itemIndex].row*130+layout:getContentSize().height/2+25));
            itemLay:addChild(layout);

            local boxSpr = cc.Sprite:createWithSpriteFrameName("checkpoint_box_bg.png");
            boxSpr:setPosition(cc.p(layout:getContentSize().width/2,layout:getContentSize().height/2));
            boxSpr:setScaleY(92/boxSpr:getContentSize().height);
            layout:addChild(boxSpr,1);

            if self.tag == 1 then--自己的武将
                if gmList[itemIndex] then
                    local item = HeroHeadEx.create(self);
                    item:setTag(self.tag);
                    item:setPosition(cc.p(layout:getContentSize().width/2,layout:getContentSize().height/2));
                    item:setData(gmList[itemIndex]);
                    layout:addChild(item,1);
                end
            end

            if self.tag == 2 then--如果是联盟英雄加金币和数量显示
                local item = HeroHeadEx.create(self);
                item:setTag(self.tag);
                item:setPosition(cc.p(layout:getContentSize().width/2,layout:getContentSize().height/2));
                item:setEnemyData(tonumber(gmList[itemIndex].g_id),tonumber(gmList[itemIndex].lv),
                    tonumber(gmList[itemIndex].quality),tonumber(gmList[itemIndex].star));
                layout:addChild(item,1);

                local goldSpr = cc.Sprite:createWithSpriteFrameName("main_icon_gold.png");
                goldSpr:setPosition(cc.p(goldSpr:getContentSize().width/2,-goldSpr:getContentSize().height/2));
                layout:addChild(goldSpr,1);

                local goldNum = cc.Label:createWithTTF(tonumber(gmList[itemIndex].gold),ttf_msyh,22);
                goldNum:setAnchorPoint(0,0.5);
                goldNum:setPosition(cc.p(goldSpr:getPositionX()+goldSpr:getContentSize().width/2,goldSpr:getPositionY()));
                layout:addChild(goldNum,1);

                if gmList[itemIndex].byFlag == 3 then
                    item:setIsGray(true);
                    goldNum:setColor(cc.c3b(128,128,128));
                    goldSpr:setShaderProgram(MGGraySprite:getGrayShaderProgram());
                elseif gmList[itemIndex].byFlag == 2 then
                    goldNum:setColor(cc.c3b(255,000,000));
                end
            end

            itemIndex = itemIndex+1;
        end
    end

    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
    end
    self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(loadEachItem, 0.001, false);
end

function MLTeam:createTeamListItem()
    local totalNum = 11;
    self.emptyPos = totalNum-(#self.myLegionList)-1;
    local queues = {};
    queues = newline(totalNum,4);

    -- table.remove(self.myLegionList,1);


    self.ListView_2:removeAllItems();
    local itemLay = ccui.Layout:create();
    itemLay:setSize(cc.size(self.ListView_2:getContentSize().width, queues[totalNum].row*125));
    self.ListView_2:pushBackCustomItem(itemLay);
    for i=1,totalNum do
        local layout = ccui.Layout:create();
        layout:setSize(cc.size(92, 92));
        layout:setAnchorPoint(cc.p(0.5,0.5));
        layout:setPosition(cc.p(queues[i].col*110+18+layout:getContentSize().width/2,
                itemLay:getContentSize().height-queues[i].row*130+layout:getContentSize().height/2+25));
        itemLay:addChild(layout);

        local boxSpr = cc.Sprite:createWithSpriteFrameName("checkpoint_box_bg.png");
        boxSpr:setPosition(cc.p(layout:getContentSize().width/2,layout:getContentSize().height/2));
        boxSpr:setScaleY(92/boxSpr:getContentSize().height);
        layout:addChild(boxSpr,1);

        if i == totalNum then--联盟武将
            boxSpr:setPosition(cc.p(layout:getContentSize().width/2+5,layout:getContentSize().height/2));

            local bgImg = ccui.ImageView:create("common_three_box.png", ccui.TextureResType.plistType);
            bgImg:setScale9Enabled(true);
            bgImg:setAnchorPoint(0,0);
            bgImg:setCapInsets(cc.rect(20, 17, 1, 1));
            bgImg:setSize(cc.size(200, 102));
            bgImg:setPositionY(-5);
            layout:addChild(bgImg);

            local nameLabel = cc.Label:createWithTTF(MG_TEXT("ML_MLTeam_4"),ttf_msyh,20);
            nameLabel:setAnchorPoint(0,0.5);
            nameLabel:setColor(cc.c3b(190,170,100));
            nameLabel:setPosition(cc.p(layout:getSize().width+10,layout:getSize().height/2));
            layout:addChild(nameLabel,1);

            if self.unionGm then
                local gm = GENERAL:getAllGeneralModel(tonumber(self.unionGm.g_id));
                if gm then
                    nameLabel:setString(gm:name());
                    nameLabel:setColor(ResourceData:getTitleColor(gm:getQuality()));
                end
                nameLabel:setPositionY(layout:getSize().height*3/4-3);

                local item = HeroHeadEx.create(self);
                item:setTag(4);
                item:setPosition(boxSpr:getPosition());
                item:setEnemyData(tonumber(self.unionGm.g_id),tonumber(self.unionGm.lv),
                    tonumber(self.unionGm.quality),tonumber(self.unionGm.star));
                layout:addChild(item,1);

                local goldSpr = cc.Sprite:createWithSpriteFrameName("main_icon_gold.png");
                goldSpr:setPosition(cc.p(layout:getSize().width+goldSpr:getContentSize().width/2+8,layout:getSize().height/4+3));
                layout:addChild(goldSpr,1);

                local goldNum = cc.Label:createWithTTF(tonumber(self.unionGm.gold),ttf_msyh,20);
                goldNum:setAnchorPoint(0,0.5);
                goldNum:setPosition(cc.p(goldSpr:getPositionX()+goldSpr:getContentSize().width/2,goldSpr:getPositionY()));
                layout:addChild(goldNum,1);
            else
                local tipLabel = cc.Label:createWithTTF(MG_TEXT("ML_MLLegionItem_1"),ttf_msyh,22);
                tipLabel:setColor(cc.c3b(190,170,100));
                tipLabel:setPosition(boxSpr:getPosition());
                layout:addChild(tipLabel,1);
            end
            break;
        end

        if self.myLegionList[i] then
            local item = HeroHeadEx.create(self);
            item:setTag(3);
            item:setPosition(cc.p(layout:getContentSize().width/2,layout:getContentSize().height/2));
            item:setData(self.myLegionList[i]);
            layout:addChild(item,1);
        else
            local tipLabel = cc.Label:createWithTTF(MG_TEXT("ML_MLLegionItem_1"),ttf_msyh,22);
            tipLabel:setColor(cc.c3b(190,170,100));
            tipLabel:setPosition(cc.p(layout:getSize().width/2,layout:getSize().height/2));
            layout:addChild(tipLabel,1);
        end
    end
end

function MLTeam:HeroHeadSelect(head)
    local isUpdate = true;
    if head:getTag() == 1 then--点击的是我的英雄中武将
        if self.emptyPos == 0 then
            MGMessageTip:showFailedMessage(MG_TEXT("ML_MLTeam_2"));
            return;
        else
            for i=1,#self.myGmList do
                if self.myGmList[i]:getId() == head.gm:getId() then
                    table.insert(self.myLegionList,self.myGmList[i]);
                    table.sort(self.myLegionList,function(a,b) return a:getWarScore() > b:getWarScore(); end);
                    table.remove(self.myGmList,i);
                    break;
                end
            end
        end
    elseif head:getTag() == 2 then--点击的是我的联盟英雄中武将
        for i=1,#self.unionList do
            if tonumber(self.unionList[i].g_id) == head.gm:getId() then
                if self.unionList[i].byFlag == 1 then
                    self.unionGm = self.unionList[i];
                    table.remove(self.unionList,i);
                elseif self.unionList[i].byFlag == 2 then
                    print(">>>>>>>>>>>>>>金币不足")
                    isUpdate = false;
                elseif self.unionList[i].byFlag == 3 then
                    print(">>>>>>>>>>>>>>等级不够")
                    isUpdate = false;
                end
                break;
            end
        end
    elseif head:getTag() == 3 then--点击的是已上阵中我的英雄武将
        if self.emptyPos >= 9 then
            MGMessageTip:showFailedMessage(MG_TEXT("ML_MLTeam_3"));
            return;
        else
            for i=1,#self.myLegionList do
                if self.myLegionList[i]:getId() == head.gm:getId() then
                    table.insert(self.myGmList,self.myLegionList[i]);
                    table.sort(self.myGmList,function(a,b) return a:getWarScore() > b:getWarScore(); end);
                    table.remove(self.myLegionList,i);
                    break;
                end
            end
        end
    elseif head:getTag() == 4 then--点击的是已上阵中我的联盟英雄武将
        table.insert(self.unionList,self.unionGm);
        table.sort(self.unionList,function(a,b) return tonumber(a.war_score) > tonumber(b.war_score); end);
        self.unionGm = nil;
    end

    if isUpdate == true then
        if head:getTag() == 1 or head:getTag() == 3 then
            self:selectedEvent(self.CheckBox_1,eventType);
        elseif head:getTag() == 2 or head:getTag() == 4 then
            self:selectedEvent(self.CheckBox_2,eventType)
        end
        self:createTeamListItem();
    end
end

function MLTeam:checkAll()--一键编队
    if #self.myGmList <= 0 and #self.unionList <= 0 then
        MGMessageTip:showFailedMessage(MG_TEXT("ML_MLTeam_1"));
    else
        for i=1,#self.myLegionList do
            table.insert(self.myGmList,self.myLegionList[i]);
        end
        table.sort(self.myGmList,function(a,b) return a:getWarScore() > b:getWarScore(); end);

        self.myLegionList = {};
        for i=1,10 do
            table.insert(self.myLegionList,self.myGmList[1]);
            table.remove(self.myGmList,1);
        end
        table.sort(self.myLegionList,function(a,b) return a:getWarScore() > b:getWarScore(); end);

        --联盟武将
        self.unionGm = self.unionList[1];
        table.remove(self.unionList,1);
        if self.tag == 1 then
            self:createGeneralListItem(self.myGmList);
        elseif self.tag == 2 then
            self:createGeneralListItem(self.unionList);
        end
        self:createTeamListItem();
    end
end

function MLTeam:selectedEvent(sender,eventType)
    for k,v in pairs(self.CheckBoxs) do
        v:setSelectedState(false);
    end
    sender:setSelectedState(true);
    self.tag = sender:getTag();
    if sender:getTag() == 1 then
        self:createGeneralListItem(self.myGmList);
    elseif sender:getTag() == 2 then
        self:createGeneralListItem(self.unionList);
    end
end

function MLTeam:updataCorps()
    local corps = {};
    local mercenary = "";
    if nil == self.data.corp then
        self.data.corp = {};
    end
    self.data.corp.corps = "";
    local str = "";
    for i=1,#self.myLegionList do
        if i == 1 then
            str = self.myLegionList[i]:getId();
        elseif i > 1 and i < #self.myLegionList then
            str = str.."|"..self.myLegionList[i]:getId();
        elseif i == #self.myLegionList then
            str = str.."|"..self.myLegionList[i]:getId();
            if self.unionGm then
                -- str = str.."|"..tonumber(self.unionGm.g_id);
                -- table.insert(corps,tonumber(self.unionGm.g_id));
                mercenary = self.unionGm.id;
            end
        end
        table.insert(corps,self.myLegionList[i]:getId());
    end
    self.data.corp.corps = str;
    if self.delegate and self.delegate.updataCorps then
        self.delegate:updataCorps(corps,mercenary);
    end
end

function MLTeam:onButtonClick(sender, eventType)
    if sender ~= self.Panel_1 then
        buttonClickScale(sender, eventType);
    end

    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_team then
            self:checkAll();
        elseif sender == self.Button_save then
            self:sendLegionReq();
        else
            self:removeFromParent();
        end
    end
end

function MLTeam:onReciveData(MsgID, NetData)
    print("MLTeam onReciveData MsgID:"..MsgID)
    
    if MsgID == Post_changeUseGeneral_1 then
        local ackData = NetData
        if ackData.state == 1 then
            if ackData.changeusegeneral.is_ok == 1 then
                self.data.corp.corps = "";
                self:updataCorps();
                MGMessageTip:showFailedMessage(MG_TEXT("ML_CheckpointLayer_4"));
                self:removeFromParent();
            end
        else
            NetHandler:showFailedMessage(ackData)
        end
    end
end

function MLTeam:sendLegionReq()
    self.gids = {};
    for i=1,#self.myLegionList do
        table.insert(self.gids,self.myLegionList[i]:getId());
    end
    local str = string.format("&corps=%s&type=%d",cjson.encode(self.gids), 1);
    NetHandler:sendData(Post_changeUseGeneral_1, str);
end

function MLTeam:pushAck()
    NetHandler:addAckCode(self,Post_changeUseGeneral_1);
end

function MLTeam:popAck()
    NetHandler:delAckCode(self,Post_changeUseGeneral_1);
end

function MLTeam:onEnter()
    self:pushAck();
end

function MLTeam:onExit()
    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
    end
    self:popAck();
    MGRCManager:releaseResources("MLTeam");
end

function MLTeam.create(delegate)
    local layer = MLTeam:new()
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

function MLTeam.showBox(delegate)
    local layer = MLTeam.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
