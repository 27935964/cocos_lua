------------------------主线界面-------------------------

local MainLineCity = require "MainLineCity"
MainLineLayer = class("MainLineLayer", MGLayer)

function MainLineLayer:ctor()
    self.scrollView = nil;
    self.mapPanel = nil;
    self.icout = 1;
    self.sprite = nil;
    self.isUpdata = false;--是否调用刷新方法刷新主界面
    self.exploreImg = nil;
    self.isUp = true;--是否弹升级
end

function MainLineLayer:init(delegate,scenetype)
    self.delegate = delegate;
    self.scenetype = scenetype;
    MGRCManager:cacheResource("MainLineLayer", "GuildWar_FightEffect.png", "GuildWar_FightEffect.plist");
    MGRCManager:cacheResource("MainLineLayer", "guild_flag.png","guild_flag.plist");
    local pWidget = MGRCManager:widgetFromJsonFile("MainLineLayer","MainLineLayer_Ui_1.ExportJson");
    self:addChild(pWidget);

    self.mapPanel = pWidget:getChildByName("mapPanel");
    self.mapPanel:setAnchorPoint(cc.p(0.5, 0.5));
    CommonMethod:setVisibleSize(self.mapPanel);

    self.Button_back = pWidget:getChildByName("Button_back");
    self.Button_back:setEnabled(false);
    self.Button_back:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_war = pWidget:getChildByName("Button_war");
    self.Button_war:setEnabled(false);

    if not self.itemWidget then
        self.itemWidget = MGRCManager:widgetFromJsonFile("MainLineLayer", "mainLine_city_item_ui_1.ExportJson",false);
        self.itemWidget:retain();
    end

    if not self.itemUnlockWidget then
        self.itemUnlockWidget = MGRCManager:widgetFromJsonFile("MainLineLayer", "MainLineLayer_unlock_Ui.ExportJson",false);
        self.itemUnlockWidget:retain();
    end

    self:readSql()--解析数据库数据
end

function MainLineLayer:readSql()--解析数据库数据
    self.mapList = {};
    self.unlockList = {};
    local sql = string.format("select * from stage_list");
    local DBDataList = LUADB.selectlist(sql,
        "id:name:icon:pic:need_s_id:next_id:desc:reward_show:pos:all_pass_reward:full_star_reward:c_reward_show:visit:visit_reward:max_road_strength:rotate:type:army_num:reward:seize_city_pic");
    table.sort(DBDataList.info,function(a,b) return a.id < b.id; end);

    local str = "";
    local str_list = {};
    local str_list1 = {};
    for index=1,#DBDataList.info do
        local DBData_next = {}
        local DBData = {};
        DBData.id = tonumber(DBDataList.info[index].id);
        DBData.name = DBDataList.info[index].name;
        DBData.icon = DBDataList.info[index].icon..".png";
        DBData.pic = DBDataList.info[index].pic..".jpg";
        DBData.need_s_id = tonumber(DBDataList.info[index].need_s_id);
        DBData.next_id = tonumber(DBDataList.info[index].next_id);
        DBData.desc = DBDataList.info[index].desc;
        DBData.max_road_strength = tonumber(DBDataList.info[index].max_road_strength) or 0;
        DBData.rotate = tonumber(DBDataList.info[index].rotate);
        DBData.city_type = tonumber(DBDataList.info[index].type);--1城,2郡,3乡,4关,5主城,6公会金字塔,7其他备用
        DBData.army_num = tonumber(DBDataList.info[index].army_num);
        DBData.seize_city_pic = DBDataList.info[index].seize_city_pic..".png";
        DBData.isCreate = 0;--0未创建，1已创建
        DBData.pass_reward = DBDataList.info[index].all_pass_reward;
        DBData.star_reward = DBDataList.info[index].full_star_reward;

        DBData.pos = {};
        str = DBDataList.info[index].pos;
        if tonumber(str) == 0 then
            DBData.pos.x = 0;
            DBData.pos.y = 0;
        else
            str_list = spliteStr(str,',');
            DBData.pos.x = tonumber(str_list[1]);
            DBData.pos.y = tonumber(str_list[2]);
        end

        DBData.reward_show = {};
        str_list = {};
        str = DBDataList.info[index].reward_show;
        if tonumber(str) == 0 then
            DBData.reward_show = 0;
        else
            str_list = spliteStr(str,'|');
            for i=1,#str_list do
                DBData.reward_show[i] = {};
                if tonumber(str_list[i]) == 0 then
                    DBData.reward_show[i].type = 0;
                    DBData.reward_show[i].id = 0;
                else
                    str_list1 = {};
                    str_list1 = spliteStr(str_list[i],':');
                    DBData.reward_show[i].type = tonumber(str_list1[1]);
                    DBData.reward_show[i].id = tonumber(str_list1[2]);
                end
            end
        end

        DBData.all_pass_reward = getneedlist(DBDataList.info[index].all_pass_reward);
        DBData.full_star_reward = getneedlist(DBDataList.info[index].full_star_reward);
        DBData.visit = getneedlist(DBDataList.info[index].visit);
        DBData.visit_reward = getneedlist(DBDataList.info[index].visit_reward);
        DBData.c_reward_show = getDataList(DBDataList.info[index].c_reward_show);
        DBData.reward = getDataList(DBDataList.info[index].reward);


        table.insert(self.mapList, DBData);
    end

    local sql1 = string.format("select * from stage_area");
    local DBDataList1 = LUADB.selectlist(sql1,"id:next_id:lv:need_s_id:need:s_ids:cloud_id:cloud_pos:first_s_id");
    for index=1,#DBDataList1.info do
        local DBData = {};
        DBData.id = tonumber(DBDataList1.info[index].id);
        DBData.next_id = tonumber(DBDataList1.info[index].next_id);
        DBData.lv = tonumber(DBDataList1.info[index].lv);
        DBData.need_s_id = tonumber(DBDataList1.info[index].need_s_id);
        DBData.first_s_id = tonumber(DBDataList1.info[index].first_s_id);
        
        DBData.cloud_id = spliteStr(DBDataList1.info[index].cloud_id,":");
        DBData.need = spliteStr(DBDataList1.info[index].need,":");
        DBData.s_ids = spliteStr(DBDataList1.info[index].s_ids,":");

        DBData.cloud_pos = {};
        local str_list = {};
        local str = DBDataList1.info[index].cloud_pos;
        if tonumber(str) == 0 then
            DBData.cloud_pos = 0;
        else
            str_list = spliteStr(str,':');
            for i=1,#str_list do
                DBData.cloud_pos[i] = {};
                if tonumber(str_list[i]) == 0 then
                    DBData.cloud_pos[i].x = 0;
                    DBData.cloud_pos[i].y = 0;
                else
                    local str_list1 = {};
                    str_list1 = spliteStr(str_list[i],',');
                    DBData.cloud_pos[i].x = tonumber(str_list1[1]);
                    DBData.cloud_pos[i].y = tonumber(str_list1[2]);
                end
            end
        end
        table.insert(self.unlockList, DBData);
    end
end

function MainLineLayer:onButtonClick(sender, eventType)
    if eventType == ccui.TouchEventType.began then
        local sc = cc.ScaleTo:create(0.1, 1.1)
        sender:runAction(cc.EaseOut:create(sc ,2))
    end
    if eventType == ccui.TouchEventType.canceled then
        local sc = cc.ScaleTo:create(0.1, 1)
        sender:runAction(sc)
    end
    if eventType == ccui.TouchEventType.ended then
        local sc = cc.ScaleTo:create(0.1, 1)
        sender:runAction(sc)
        if sender == self.Button_back then
            enterLuaScene(SCENEINFO.LOGIN_SCENE);
        end
    end
end

function MainLineLayer:setData(data)
    self.unLockInfo = data;
    table.sort(self.unLockInfo.stage, function(data1,data2) return data1 > data2 end)
    table.sort(self.unLockInfo.area, function(data1,data2) return data1 > data2 end)
    self:initView();
end

function MainLineLayer:initView()
    local size = cc.Director:getInstance():getWinSize();
    local pContainerNode = cc.Node:create();
    pContainerNode:setContentSize(5336,3102);
    local mapSpr = nil

    local index = 0
    for i=1,2 do
        for j=1,4 do
            index = index + 1;
            local x = pContainerNode:getContentSize().width/8+(j-1)*pContainerNode:getContentSize().width/4;
            local y = pContainerNode:getContentSize().height*3/4-(i-1)*pContainerNode:getContentSize().height/2;
            mapSpr = cc.Sprite:createWithSpriteFrameName(string.format("MainLine_map_%d.jpg",index));
            mapSpr:setPosition(x,y);
            pContainerNode:addChild(mapSpr);
        end
    end

    require "MGMapScrollView";
    local sc = self.mapPanel:getContentSize().height/mapSpr:getContentSize().height;
    local scrollView = MGMapScrollView.create();
    scrollView:setMinMaxScale(sc,1);
    scrollView:setZoomScale(0.8,true);
    scrollView:setContainer(pContainerNode);
    scrollView:setViewSize(self.mapPanel:getContentSize());
    -- scrollView:setContentOffset(cc.p(-5336/2,-3102/2));
    scrollView:setContentOffset(cc.p(-3800/2-50,-2300/2-25));--中点,区间x[-100,-3800],Y[-50,-2300]
    scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_BOTH);
    scrollView:setBounceable(false);
    scrollView:setMapDelegate(self);
    self.mapPanel:addChild(scrollView);
    self.scrollView = scrollView;

    self:initMap();
end

function MainLineLayer:initMap()
    self.cityItems = {};
    self.cloudItems = {};

    for i=1,#self.mapList do
        local winSize = cc.Director:getInstance():getWinSize();
        local mapInfo = self.mapList[i];
        mapInfo.isCreate = 0;
        local pos = self.scrollView:getContainer():convertToWorldSpace(cc.p(mapInfo.pos.x+2668,mapInfo.pos.y+1551));
        
        if #self.unLockInfo.stage <= 0 and mapInfo.id == 20101 then--20101是起始城池
            self.scrollView:setContentOffset(cc.p(-(mapInfo.pos.x+2668)+768-50,-(mapInfo.pos.y+1551)+400-25));
        end
        if tonumber(self.unLockInfo.stage[1]) == mapInfo.id then
            self.scrollView:setContentOffset(cc.p(-(mapInfo.pos.x+2668)+768-50,-(mapInfo.pos.y+1551)+400-25));
        end

        if pos.x >= -150 and pos.x <= winSize.width+150 and pos.y >= -100 and pos.y <= winSize.height+100 
            and 0 == mapInfo.isCreate then
            self:createCity(mapInfo);
            self.mapList[i].isCreate = 1;
        end
    end
    self:mapScrollViewkMove();

    self:createCloud();
    self:createUnlock();
    self:showLastLayer();
end

--显示跳转界面
function MainLineLayer:showLastLayer()
    if _G.sceneData.layerType==LAYERTAG.LAYER_CHECKPOINT then
        self.checkpointId = _G.sceneData.layerData.checkpointId;
        self.mapInfo = _G.sceneData.layerData.mapInfo;
        self:sendStageReq();
    end
end

function MainLineLayer:createUnlock()--创建解锁区域按钮
    if self.exploreImg then
        self.exploreImg:removeFromParent();
        self.exploreImg = nil;
    end

    if tonumber(self.unLockInfo.area[1]) < #self.unlockList then
        local index = tonumber(self.unLockInfo.area[1])+1;
        local unlockInfo = self.unlockList[index];
        if unlockInfo.first_s_id > 0 then
            for i=1,#self.cloudItems do
                if self.cloudItems[i].a_id == unlockInfo.id then
                    local MainLineUnlock = require "MainLineUnlock";
                    self.exploreImg = MainLineUnlock.create(self,self.itemUnlockWidget:clone());
                    self.exploreImg:setData(unlockInfo,self.unLockInfo,self.mapList);
                    self.exploreImg:setPosition(self.cloudItems[i].cloudSpr:getPosition());
                    self.scrollView:getContainer():addChild(self.exploreImg,5);
                    break;
                end
            end
        end
    end
end

function MainLineLayer:runAction(pos1,pos2,rate)
    self.icout = self.icout + 1;

    if nil == rate then
        rate = 500;
    end
    local sqrt = math.sqrt((pos1.x-pos2.x)*(pos1.x-pos2.x)+(pos1.y-pos2.y)*(pos1.y-pos2.y));
    local time = sqrt/rate;

    if nil == self.sprite then
        self.sprite=cc.Sprite:create("city.png");
        self.scrollView:getContainer():addChild(self.sprite,2);
    end
    self.sprite:setPosition(cc.p(pos1.x,pos1.y));
    local function checkAction()
        if self.icout < #self.pos then
            self:runAction(self.curPos,self.pos[self.icout+1],500);
        else
            self.sprite:removeFromParent();
            self.sprite = nil;
        end
    end
    local mv = cc.MoveTo:create(time, pos2);
    local func = cc.CallFunc:create(checkAction);
    self.sprite:runAction(cc.Sequence:create(mv,func));
    self.curPos = pos2;
end

function MainLineLayer:addCheckpointLayer(data)
    self.checkpointId = tonumber(data.id);
    self.mapInfo = data;

    if self.mapInfo.city_type <= 4 then--1城,2郡,3乡,4关,5主城,6公会金字塔,7其他备用
        self:sendStageReq();--进入城池
    elseif self.mapInfo.city_type == 5 then
        enterLuaScene(SCENEINFO.MAIN_SCENE);
    elseif self.mapInfo.city_type == 6 then
        print(">>>>>>>>>>进公会金字塔>>>>>>>>>>>>");
    end
end

function MainLineLayer:goCheckpointLayer(checkpointId)
    for i=1,#self.mapList do
        if self.mapList[i].id == checkpointId then
            self:addCheckpointLayer(self.mapList[i]);
        end
    end
end

function MainLineLayer:mapScrollViewkMove(item)
    for i=1,#self.mapList do
        local winSize = cc.Director:getInstance():getWinSize();
        local mapInfo = self.mapList[i];
        local pos = self.scrollView:getContainer():convertToWorldSpace(cc.p(mapInfo.pos.x+2668,mapInfo.pos.y+1551));

        if pos.x >= -150 and pos.x <= winSize.width+150 and pos.y >= -100 and pos.y <= winSize.height+100  
            and 0 == mapInfo.isCreate then
            self:createCity(mapInfo);
            self.mapList[i].isCreate = 1;
        end
    end
end

function MainLineLayer:updataCityInfo(data)
    self.unLockInfo = data;
    table.sort(self.unLockInfo.stage, function(data1,data2) return data1 > data2 end)
    table.sort(self.unLockInfo.area, function(data1,data2) return data1 > data2 end)

    self:removeAllItem();
    self.cityItems = {};
    for i=1,#self.mapList do
        local winSize = cc.Director:getInstance():getWinSize();
        local mapInfo = self.mapList[i];
        mapInfo.isCreate = 0;
        local pos = self.scrollView:getContainer():convertToWorldSpace(cc.p(mapInfo.pos.x+2668,mapInfo.pos.y+1551));

        if pos.x >= -150 and pos.x <= winSize.width+150 and pos.y >= -100 and pos.y <= winSize.height+100 
            and 0 == mapInfo.isCreate then
            self.mapList[i].isCreate = 1;
            self:createCity(mapInfo);
        end
    end

    self:createCloud();
    self:createUnlock();
end

function MainLineLayer:createCity(mapInfo)
    local cityImg = MainLineCity.create(self,self.itemWidget:clone());
    cityImg:setData(self.unLockInfo,mapInfo,self.unlockList);
    cityImg:setPosition(cc.p(mapInfo.pos.x+2668,mapInfo.pos.y+1551));
    self.scrollView:getContainer():addChild(cityImg,1);
    table.insert(self.cityItems, {cityImg=cityImg,mapInfo=mapInfo});
end

function MainLineLayer:createCloud()
    self.cloudItems = {};
    for i=1,#self.unlockList do
        local isUnlock = false;--区域是否解锁
        for index=1,#self.unLockInfo.area do
            if tonumber(self.unLockInfo.area[index]) == self.unlockList[i].id then
                isUnlock = true;
                break;
            end
        end

        if isUnlock == false then
            for j=1,#self.unlockList[i].cloud_id do
                local name = string.format("cloud_%d.png",tonumber(self.unlockList[i].cloud_id[j]));
                local x = tonumber(self.unlockList[i].cloud_pos[j].x);
                local y = tonumber(self.unlockList[i].cloud_pos[j].y);
                local cloudSpr = cc.Sprite:createWithSpriteFrameName(name);
                cloudSpr:setPosition(cc.p(x+2668,y+1551));
                self.scrollView:getContainer():addChild(cloudSpr,2);

                table.insert(self.cloudItems, {cloudSpr=cloudSpr,a_id=self.unlockList[i].id});
            end
        end
    end
end

function MainLineLayer:jump()
    --玩家点击宣战时如果成员等级满足且处于可宣战时间段内,则跳转到大地图城池处
    --默认帮玩家定位到可以宣战的城池位置;
    --如果有多个可宣战城池,则优先定位到无人占领的城池处,如果都为无人占领或者有人占领的城池
    --则定位优先级为:城>郡>乡>关;
    
    local unOccupy = {}--未占领的城池
    local occupy = {}--被别的公会占领的城池
    if #self.unLockInfo.declare_city == 1 then
        for i=1,#self.mapList do
            local mapInfo = self.mapList[i];
            if mapInfo.id == tonumber(self.unLockInfo.declare_city[1]) then
                self.scrollView:setContentOffset(cc.p(-(mapInfo.pos.x+2668)+768-50,-(mapInfo.pos.y+1551)+400-25));
                break;
            end
        end
    elseif #self.unLockInfo.declare_city > 1 then
        for i=1,#self.unLockInfo.declare_city do
            for j=1,#self.unLockInfo.city_flag do--被占领的城池
                if 0 == self.unLockInfo.city_flag[j].is_npc then--不为NPC占领
                    if ME:getUnionId() == tonumber(self.unLockInfo.city_flag[j].union_id) then--不为自己公会占领
                        if tonumber(self.unLockInfo.declare_city[j]) == tonumber(self.unLockInfo.city_flag[j].city_id) then
                            table.insert(occupy,tonumber(self.unLockInfo.declare_city[j]));
                        end
                    end
                elseif 1 == self.unLockInfo.city_flag[j].is_npc then--被别的公会占领
                    if tonumber(self.unLockInfo.declare_city[j]) == tonumber(self.unLockInfo.city_flag[j].city_id) then
                        table.insert(unOccupy,tonumber(self.unLockInfo.declare_city[j]));
                    end
                end
            end
        end

        if #unOccupy >= 1 then--NPC占领
            local mapInfo = self:getCityId(unOccupy);
            self.scrollView:setContentOffset(cc.p(-(mapInfo.pos.x+2668)+768-50,-(mapInfo.pos.y+1551)+400-25));
        elseif #occupy >= 1 then--被别的公会占领
            local mapInfo = self:getCityId(occupy);
            self.scrollView:setContentOffset(cc.p(-(mapInfo.pos.x+2668)+768-50,-(mapInfo.pos.y+1551)+400-25));
        else--全部自己公会占领
            for i=1,#self.mapList do
                local mapInfo = self.mapList[i];
                if mapInfo.id == tonumber(self.unLockInfo.stage[1]) then
                    self.scrollView:setContentOffset(cc.p(-(mapInfo.pos.x+2668)+768-50,-(mapInfo.pos.y+1551)+400-25));
                    break;
                end
            end
        end
    else
        for i=1,#self.mapList do
            local mapInfo = self.mapList[i];
            if mapInfo.id == tonumber(self.unLockInfo.stage[1]) then
                self.scrollView:setContentOffset(cc.p(-(mapInfo.pos.x+2668)+768-50,-(mapInfo.pos.y+1551)+400-25));
                break;
            end
        end
    end
    self:mapScrollViewkMove();
end

function MainLineLayer:getCityId(data)
    local mapInfos = {};
    for i=1,#self.mapList do
        for j=1,#data do
            if data[j] == self.mapList[i].id then
                table.insert(mapInfos,self.mapList[i]);
            end
        end
    end
    table.sort(mapInfos, function (a,b) return a.city_type < b.city_type end)

    return mapInfos[1];
end

function MainLineLayer:removeAllItem()
    if self.cityItems then
        for i=1,#self.cityItems do
            self.cityItems[i].cityImg:removeFromParent();
        end
    end

    if self.cloudItems then
        for i=1,#self.cloudItems do
            self.cloudItems[i].cloudSpr:removeFromParent();
        end
    end

    self.cityItems = {};
    self.cloudItems = {};
end

function MainLineLayer:isUpLevel()
    self.isUp = false;
end

function MainLineLayer:upLevel()
    print(">>>>>>>>>>升级>>>>>>>>")
end

function MainLineLayer:onReciveData(MsgID, NetData)
    print("MainLineLayer onReciveData MsgID:"..MsgID)
    
    local ackData = NetData;
    if MsgID == Post_getStage then
        if ackData.state == 1 then
            _G.sceneData.layerData.checkpointId = self.checkpointId;
            _G.sceneData.layerData.mapInfo = self.mapInfo;
            require "CheckpointLayer";
            local checkpointLayer = CheckpointLayer.showBox(self,self.scenetype);
            checkpointLayer:setData(ackData,self.mapInfo);
        else
            NetHandler:showFailedMessage(ackData)
        end
    elseif MsgID == Post_unlockstage then
        if ackData.state == 1 then
            if ackData.unlockstage.is_ok == 1 then
                self:sendStageReq();
            end
        else
            NetHandler:showFailedMessage(ackData)
        end
    elseif MsgID == Post_getCityInfo then
        if ackData.state == 1 then
            if self.isUpdata then
                self:updataCityInfo(ackData.getcityinfo);
                self.isUpdata = false;
            else
                self:setData(ackData.getcityinfo);
            end
        else
            NetHandler:showFailedMessage(ackData)
        end
    elseif MsgID == Post_Pve_unlockArea then
        if ackData.state == 1 then
            self:updataCityInfo(ackData.getcityinfo);
        else
            NetHandler:showFailedMessage(ackData)
        end
    end
end

function MainLineLayer:setUpdataState(isUpdata)
    self.isUpdata = isUpdata;
end

function MainLineLayer:sendStageReq()
    local str = string.format("&sid=%d",self.checkpointId);
    NetHandler:sendData(Post_getStage, str);
end

function MainLineLayer:sendReq()--解锁城池
    local str = string.format("&sid=%d",self.checkpointId);
    NetHandler:sendData(Post_unlockstage, str);
end

function MainLineLayer:sendUnlockAreaReq(aid)--解锁区域
    local str = "&aid="..aid;
    NetHandler:sendData(Post_Pve_unlockArea, str);
end

function MainLineLayer:pushAck()
    NetHandler:addAckCode(self,Post_getStage);
    NetHandler:addAckCode(self,Post_unlockstage);
    NetHandler:addAckCode(self,Post_getCityInfo);
    NetHandler:addAckCode(self,Post_Pve_unlockArea);
end

function MainLineLayer:popAck()
    NetHandler:delAckCode(self,Post_getStage);
    NetHandler:delAckCode(self,Post_unlockstage);
    NetHandler:delAckCode(self,Post_getCityInfo);
    NetHandler:delAckCode(self,Post_Pve_unlockArea);
end

function MainLineLayer:onEnter()
    self:pushAck();
    NetHandler:sendData(Post_getCityInfo, "");
end

function MainLineLayer:onExit()
    self.scrollView:destroy();
    self:removeAllItem();
    MGRCManager:releaseResources("MainLineLayer");
    self:popAck();

    if self.itemWidget then
        self.itemWidget:release();
    end

    if self.itemUnlockWidget then
        self.itemUnlockWidget:release();
    end
end

function MainLineLayer.create(delegate,scenetype)
    local layer = MainLineLayer:new()
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

function MainLineLayer.showBox(delegate,scenetype)
    local layer = MainLineLayer.create(delegate,scenetype);
    layer:setTag(5201);
    cc.Director:getInstance():getRunningScene():addChild(layer);
    return layer;
end
