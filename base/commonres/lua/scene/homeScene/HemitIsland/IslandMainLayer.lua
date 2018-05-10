------------------------主线界面-------------------------
require "MGMapScrollView"
require "PanelTop"
require "enemyInfo"
require "showTip"
require "shopLayer"
require "fanPaiLayer"

IslandMainLayer = class("IslandMainLayer", MGLayer)

function IslandMainLayer:ctor()
    self.scrollView = nil;
    self.mapPanel = nil;
    self.sprite = nil;
    self.curCityId = 0;
    self.touchCityId = 0;
    self.dashNum = 0;--突击关卡数
    self.isAssault = false;--是否突击
    -- self.assaultType = 0;--0无，1突击按钮触发，2点第一关触发

end

function IslandMainLayer:init(delegate,scenetype)
    self.delegate = delegate;
    self.scenetype = scenetype;
    MGRCManager:cacheResource("IslandMainLayer", "HemitIsland_bg.jpg");
    MGRCManager:cacheResource("IslandMainLayer", "HemitIsland_ui0.png", "HemitIsland_ui0.plist");
    local pWidget = MGRCManager:widgetFromJsonFile("IslandMainLayer","hemit_island_main_ui.ExportJson");
    self:addChild(pWidget);

    self.mapPanel = pWidget:getChildByName("mapPanel");
    CommonMethod:setVisibleSize(self.mapPanel);

    self.pPanelTop = PanelTop.create(self)
    self.pPanelTop:setData("HemitIsland_title.png");
    self:addChild(self.pPanelTop,10);
    self.pPanelTop:showRankCoin(true);
    self.pPanelTop:setRankCoinPic("com_icon_crusade_coin.png");

    local Panel_2 = pWidget:getChildByName("Panel_2");
    local Panel_left = Panel_2:getChildByName("Panel_left");

    self.Button_assault = Panel_2:getChildByName("Button_assault");--突击
    self.Button_assault:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_shop = Panel_2:getChildByName("Button_shop");--商店
    self.Button_shop:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_reset = Panel_2:getChildByName("Button_reset");--重置
    self.Button_reset:addTouchEventListener(handler(self,self.onButtonClick));

    local Image_surplus_bg = Panel_2:getChildByName("Image_surplus_bg");
    self.Label_num = Image_surplus_bg:getChildByName("Label_surplus2");
    self.Button_add = Image_surplus_bg:getChildByName("Button_add");
    self.Button_add:addTouchEventListener(handler(self,self.onButtonClick));

    local Label_assault = Panel_2:getChildByName("Label_assault");
    local Label_shop = Panel_2:getChildByName("Label_shop");
    local Label_reset = Panel_2:getChildByName("Label_reset");
    local Label_surplus1 = Image_surplus_bg:getChildByName("Label_surplus1");

    Label_assault:setText(MG_TEXT_COCOS("hemit_island_main_ui_1"));
    Label_shop:setText(MG_TEXT_COCOS("hemit_island_main_ui_2"));
    Label_reset:setText(MG_TEXT_COCOS("hemit_island_main_ui_3"));
    Label_surplus1:setText(MG_TEXT_COCOS("hemit_island_main_ui_4"));

    self:readSql()--解析数据库数据
    self:initView();
end

function IslandMainLayer:upData()
    self.pPanelTop:upData();
end

function IslandMainLayer:readSql()--解析数据库数据
    self.mapList = {};
    local sql = string.format("select * from expedition_stage");
    local DBDataList = LUADB.selectlist(sql, "id:name:pic:city_pos:box_pos:road_pos");
    table.sort(DBDataList.info,function(a,b) return a.id < b.id; end);

    for index=1,#DBDataList.info do
        local DBData = {};
        DBData.id = tonumber(DBDataList.info[index].id);
        DBData.name = DBDataList.info[index].name;
        DBData.pic = DBDataList.info[index].pic..".png";

        DBData.city_pos = getDataList(DBDataList.info[index].city_pos);
        DBData.box_pos = getDataList(DBDataList.info[index].box_pos);
        DBData.road_pos = getDataList(DBDataList.info[index].road_pos);

        self.mapList[DBData.id+1]=DBData;
    end

    local sql1 = string.format("select value from config where id=56");
    local DBData = LUADB.select(sql1, "value");
    self.needLevel = tonumber(DBData.info.value);
end

function IslandMainLayer:initView()
   local mapSpr = cc.Sprite:createWithSpriteFrameName("HemitIsland_bg.jpg");
    local pContainerNode = cc.Node:create();
    pContainerNode:setContentSize(mapSpr:getContentSize());
    mapSpr:setPosition(pContainerNode:getContentSize().width/2 , pContainerNode:getContentSize().height/2);
    pContainerNode:addChild(mapSpr);

    local sc = self.mapPanel:getContentSize().height/mapSpr:getContentSize().height;
    local scrollView = MGMapScrollView.create();
    scrollView:setMinMaxScale(sc,2);
    scrollView:setZoomScale(sc,true);
    scrollView:setContainer(pContainerNode);
    scrollView:setViewSize(self.mapPanel:getContentSize());
    scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_BOTH);
    scrollView:setBounceable(false);
    scrollView:setMapDelegate(self);
    self.mapPanel:addChild(scrollView);
    self.scrollView = scrollView;

    self:initMap();
end

function IslandMainLayer:initMap()
    self.cityItems = {};
    self.boxItems = {};
    for i=1,#self.mapList do
        if i > 1 then
            local boxImg = ccui.ImageView:create("HemitIsland_icon_treasure_box.png", ccui.TextureResType.plistType);
            boxImg:setPosition(cc.p(self.mapList[i].box_pos[1].value1,self.mapList[i].box_pos[1].value2));
            boxImg:setLocalZOrder(#self.mapList-i+1);
            boxImg:setTag(i);
            self.scrollView:getContainer():addChild(boxImg);
            boxImg:setTouchEnabled(false);
            boxImg:addTouchEventListener(handler(self,self.onTouchClick));
            if i == 4 or i == 5 or i == 9 then
                boxImg:setLocalZOrder(#self.mapList-i+2);
            end
            boxImg:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
            table.insert(self.boxItems, boxImg);
        end

        local cityImg = ccui.ImageView:create(self.mapList[i].pic, ccui.TextureResType.plistType);
        cityImg:setLocalZOrder(#self.mapList-i+1);
        cityImg:setTag(i);
        cityImg:setPosition(cc.p(self.mapList[i].city_pos[1].value1,self.mapList[i].city_pos[1].value2));
        self.scrollView:getContainer():addChild(cityImg);
        if i > 1 then
            cityImg:setTouchEnabled(false);
            cityImg:addTouchEventListener(handler(self,self.onTouchClick));
            self.oldHeadProgram = cityImg:getSprit():getShaderProgram();
            cityImg:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
        end
        table.insert(self.cityItems, cityImg);
        
    end
end

function IslandMainLayer:setData()
    -- self.Label_num:setText(string.format(MG_TEXT("trialMainLayer_1"),4));
end

function IslandMainLayer:initData(data)
    self.data = data;
    self.curCityId = tonumber(self.data.cur_stage);
    self.pPanelTop:setRankCoin(self.data.expedition_coin);
    self.Label_num:setText(string.format(MG_TEXT("trialMainLayer_1"),tonumber(self.data.surplus_num)));
    local num = 0;
    if tonumber(self.data.status) == 1 then--1进行中,2已结束
        num = tonumber(self.data.cur_stage);
        self.cityItems[tonumber(self.data.cur_stage)+1]:setTouchEnabled(true);
    elseif tonumber(self.data.status) == 2 then
        num = tonumber(self.data.cur_stage)+1;
        self.cityItems[tonumber(self.data.cur_stage)+2]:setTouchEnabled(true);
    end

    for i=2,#self.cityItems do
        self.cityItems[i]:setTouchEnabled(false);
        self.cityItems[i]:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
        self.boxItems[i-1]:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
        if i <= num+1 then
            self.cityItems[i]:getSprit():setShaderProgram(self.oldHeadProgram);
            self.boxItems[i-1]:getSprit():setShaderProgram(self.oldHeadProgram);
        end
        if i == num+1 then
            self.cityItems[i]:setTouchEnabled(true);
        end
    end

    if self.isAssault == true then
        for i=2,#self.cityItems do
            self.cityItems[i]:setTouchEnabled(false);
        end

        if self.curCityId == 0 then
            self.cityItems[2]:setTouchEnabled(true);
        end
    end

    self:createHeroEffect();--创建马的动画
    -- if self.sprite == nil then
    --     self.sprite=cc.Sprite:createWithSpriteFrameName("enemy_10.png");
    --     self.scrollView:getContainer():addChild(self.sprite,100);
    -- end
    -- self.sprite:stopAction();
    -- self.sprite:setRotation(self.mapList[self.curCityId+1].road_pos[1].value3);
    -- self.sprite:setPosition(cc.p(self.mapList[self.curCityId+1].road_pos[1].value1,self.mapList[self.curCityId+1].road_pos[1].value2));
end

function IslandMainLayer:createHeroEffect()
    if self.sprite==nil then
        self.sprite=ccs.Armature:create("Champion01");
        self.sprite:setPosition(cc.p(self.mapList[self.curCityId+1].road_pos[1].value1,self.mapList[self.curCityId+1].road_pos[1].value2));
        self.sprite:setScale(0.6);
        self.sprite:setRotation(self.mapList[self.curCityId+1].road_pos[1].value3);
        self.sprite:getAnimation():playWithIndex(0,-1,1) --播放动画
        self.scrollView:getContainer():addChild(self.sprite,100);
    end
end

function IslandMainLayer:goRun()
    if tonumber(self.data.status) == 1 then
        if self.isAssault == true then
            self:stageInfoSendReq(self.dashNum);
        end
        return;
    end


    self.icout = 1;
    self.road_pos = {};
    self.road_pos = self.mapList[self.curCityId+1].road_pos;

    self:runAction(self.road_pos[1],self.road_pos[2]);
end

function IslandMainLayer:runAction(pos1,pos2)
    self.icout = self.icout + 1;
    local rate = 100;
    local sqrt = math.sqrt((pos1.value1-pos2.value1)*(pos1.value1-pos2.value1)+(pos1.value2-pos2.value2)*(pos1.value2-pos2.value2));
    local time = sqrt/rate;

    self.sprite:setPosition(cc.p(pos1.value1,pos1.value2));
    self.sprite:setRotation(pos1.value3);
    self.sprite:setVisible(true);
    local function checkAction()
        if self.icout < #self.road_pos then
            self:runAction(pos2,self.road_pos[self.icout+1]);
        else
            if self.isAssault == true then
                self:stageInfoSendReq(self.dashNum);
            else
                if tonumber(self.data.status) == 2 then
                    self.data.status = 1;
                    self.data.cur_stage = tonumber(self.data.cur_stage)+1;
                    self.curCityId = self.data.cur_stage;
                end
            end
        end
    end
    local mv = cc.MoveTo:create(time, cc.p(pos2.value1,pos2.value2));
    local func = cc.CallFunc:create(checkAction);
    self.sprite:runAction(cc.Sequence:create(mv,func));
end

function IslandMainLayer:onTouchClick(sender, eventType)
    buttonClickScale(sender, eventType);

    if eventType == ccui.TouchEventType.ended then
        if sender == self.cityItems[sender:getTag()] then--村庄
            print("----------村庄----------")
            self.touchCityId = sender:getTag();
            if self.isAssault == true then
                local showTip = showTip.showBox(self);
                showTip:setData(nil,1,3);
                showTip:setTipText(string.format(MG_TEXT("IslandMainLayer_8"),tonumber(self.data.max_stage),tonumber(self.data.dash_id)));
            else
                self:move(sender:getTag()-1);
            end
        elseif sender == self.boxItems[sender:getTag()] then--宝箱
            print("----------宝箱----------")
        end
    end
end

function IslandMainLayer:onButtonClick(sender, eventType)
    buttonClickScale(sender, eventType);

    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_assault then--突击
            -- if ME:Lv() >= self.needLevel then
                -- if self.isAssault == true then--可突击
                    local showTip = showTip.showBox(self);
                    showTip:setData(nil,1,3);
                    showTip:setTipText(string.format(MG_TEXT("IslandMainLayer_8"),tonumber(self.data.max_stage),tonumber(self.data.dash_id)));
                    -- self.assaultType = 1;
                -- else
                --     MGMessageTip:showFailedMessage(MG_TEXT("IslandMainLayer_7"));
                -- end
            -- else
            --     MGMessageTip:showFailedMessage(string.format(MG_TEXT("IslandMainLayer_5"),self.needLevel));
            -- end
        elseif sender == self.Button_shop then--商店
            local shopLayer = shopLayer.showBox(self,7);
        elseif sender == self.Button_reset then--重置
            if tonumber(self.data.surplus_num) < 1 then
                MGMessageTip:showFailedMessage(MG_TEXT("IslandMainLayer_9"));
            else
                local showTip = showTip.showBox(self);
                showTip:setData(nil,1,1);
                showTip:setTipText(MG_TEXT("IslandMainLayer_1"));
            end
        elseif sender == self.Button_add then
            local showTip = showTip.showBox(self);
            showTip:setData(self.data,2,2);
        end
    end
end

function IslandMainLayer:challenge(item)--挑战
    local teamdata = "";
    local fightdata = "&is_dash=0";
    FightOP:setTeam(self.scenetype,Fight_Expedition,teamdata,fightdata,self.mapList[self.touchCityId].name);
end

function IslandMainLayer:move(tag)
    if tonumber(self.data.status) == 2 then
        self:goRun();
    end
    self:stageInfoSendReq(tag);
end

function IslandMainLayer:back()
    self:removeFromParent();
end

function IslandMainLayer:callBack(item)
    if item.eventType == 1 then--重置隐士岛提示
        print(">>>>>>>>>重置隐士岛>>>>>>>>>>")
        NetHandler:sendData(Post_reSetExpedition, "");
    elseif item.eventType == 2 then--增加重置次数提示
        print(">>>>>>>>>增加重置次数>>>>>>>>>>")
        if ME:getGold() >= tonumber(self.data.next_reset_use) then
            NetHandler:sendData(Post_payReSet, "");
        else
            MGMessageTip:showFailedMessage(MG_TEXT("IslandMainLayer_4"));
        end
    elseif item.eventType == 3 then--突击提示
        self:flipCallBack();
    end
end

function IslandMainLayer:flipCallBack(item)--翻牌回调  进行突击
    if self.isAssault == true then--可突击
        if self.dashNum >= tonumber(self.data.dash_id) then
            if tonumber(self.data.status) == 1 then--1进行中,2已结束
                self.cityItems[tonumber(self.data.cur_stage)+1]:setTouchEnabled(true);
            elseif tonumber(self.data.status) == 2 then
                self.cityItems[tonumber(self.data.cur_stage)+2]:setTouchEnabled(true);
            end

            MGMessageTip:showFailedMessage(MG_TEXT("IslandMainLayer_6"));
            self.isAssault = false;
            self.dashNum = 0;
            return;
        end

        self.dashNum = self.dashNum + 1;
        self:goRun();
    end
end

function IslandMainLayer:onReciveData(MsgID, NetData)
    print("IslandMainLayer onReciveData MsgID:"..MsgID)

    local ackData = NetData;
    if MsgID == Post_getUserExpeditionCoin then
        if ackData.state == 1 then
            self.pPanelTop:setRankCoin(ackData.getuserexpeditioncoin.expedition_coin);
            NetHandler:sendData(Post_getUserExpedition, "");
        else
            NetHandler:showFailedMessage(ackData)
        end
    elseif MsgID == Post_getUserExpedition then--获取用户远征信息
        if ackData.state == 1 then
            self:initData(ackData.getuserexpedition);
            if (tonumber(self.data.cur_stage) == 0 and tonumber(self.data.dash_id) >= 1) or 
            (tonumber(self.data.cur_stage) == 1 and tonumber(self.data.status) == 1 and 
            tonumber(self.data.dash_id) >= 1) then--可突击
                self.isAssault = true;
            end
        else
            NetHandler:showFailedMessage(ackData)
        end
    elseif MsgID == Post_stageInfo then--关卡信息
        if ackData.state == 1 then
            if self.isAssault == true then--可突击
                NetHandler:sendData(Post_Expedition_embattle_1, "");
            else
                local enemyInfo = enemyInfo.showBox(self,"HemitIsland_challenge_title.png");
                enemyInfo:setData(ackData.stageinfo);
            end
        else
            NetHandler:showFailedMessage(ackData)
        end
    elseif MsgID == Post_Expedition_embattle_1 then--布阵
        if ackData.state == 1 then
            if self.isAssault == true then--可突击
                self:sendReq(1);
            end
        else
            NetHandler:showFailedMessage(ackData)
        end
    elseif MsgID == Post_entryStage_1 then--进入关卡点 战斗
        if ackData.state == 1 then
            self:initData(ackData.getuserexpedition);
            local fanPai = fanPaiLayer.showBox(self);
            fanPai:setData(ackData.getflipreward);
        else
            NetHandler:showFailedMessage(ackData)
        end
    elseif MsgID == Post_payReSet then--购买重置次数
        if ackData.state == 1 then
            self.data.surplus_num = tonumber(ackData.payreset.surplus_num);
            self.data.next_reset_use = tonumber(ackData.payreset.next_reset_use);
            self.data.buy_num = tonumber(ackData.payreset.buy_num);
            self.Label_num:setText(string.format(MG_TEXT("trialMainLayer_1"),tonumber(self.data.surplus_num)));
            self:upData();
        else
            NetHandler:showFailedMessage(ackData)
        end
    elseif MsgID == Post_reSetExpedition then--重置远征
        if ackData.state == 1 then
            self.isAssault = true;
            self:initData(ackData.getuserexpedition);
        else
            NetHandler:showFailedMessage(ackData)
        end
    end
end

function IslandMainLayer:sendReq(isDash)
    local str = string.format("&is_dash=%d",isDash);
    NetHandler:sendData(Post_entryStage_1, str);
end

function IslandMainLayer:stageInfoSendReq(nextId)
    local str = string.format("&id=%d",nextId);
    NetHandler:sendData(Post_stageInfo, str);
end

function IslandMainLayer:pushAck()
    NetHandler:addAckCode(self,Post_getUserExpeditionCoin);
    NetHandler:addAckCode(self,Post_getUserExpedition);
    NetHandler:addAckCode(self,Post_stageInfo);
    NetHandler:addAckCode(self,Post_entryStage_1);
    NetHandler:addAckCode(self,Post_payReSet);
    NetHandler:addAckCode(self,Post_reSetExpedition);
    NetHandler:addAckCode(self,Post_Expedition_embattle_1);
end

function IslandMainLayer:popAck()
    NetHandler:delAckCode(self,Post_getUserExpeditionCoin);
    NetHandler:delAckCode(self,Post_getUserExpedition);
    NetHandler:delAckCode(self,Post_stageInfo);
    NetHandler:delAckCode(self,Post_entryStage_1);
    NetHandler:delAckCode(self,Post_payReSet);
    NetHandler:delAckCode(self,Post_reSetExpedition);
    NetHandler:delAckCode(self,Post_Expedition_embattle_1);
    
end

function IslandMainLayer:onEnter()
    self:pushAck();
    NetHandler:sendData(Post_getUserExpeditionCoin, "");
end

function IslandMainLayer:onExit()
    self.scrollView:destroy();
    MGRCManager:releaseResources("IslandMainLayer");
    self:popAck();
end

function IslandMainLayer.create(delegate,scenetype)
    local layer = IslandMainLayer:new()
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

function IslandMainLayer.showBox(delegate,scenetype)
    local layer = IslandMainLayer.create(delegate,scenetype);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
