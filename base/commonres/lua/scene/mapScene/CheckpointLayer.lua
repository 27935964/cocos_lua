require "getItem"
require "CheckpointItem"
require "MGMapScrollView"
require "MLChooseRoad"
require "PanelTop"
require "MLCityInfo"
require "MLFallAndPlot"
require "MLFightResult"
require "MLLegion"
require "MLTeam"
require "MLRetreat"
require "MLReward"
require "MLForeignLayer"
require "fanPaiLayer"
require "MLsweep"
require "ItemJump"

CheckpointLayer = class("CheckpointLayer", MGLayer)

function CheckpointLayer:ctor()
    self.scrollView = nil;
    self.mapPanel = nil;
    self.sprite = nil;
    self.icout = 0;
    self.curCityId = 0;
    self.cityInfos = nil;
    self.isMarch = false;
    self.checkpointId = 0;
    self.c_id = 0;
    self.btnType = 1;
    self.totalNum = 0;
    self.totalStarNum = 0;
    self.angles = {};
    self.cityItems = {};
    self.tablePaths = {};
    self.tipItems = {};
    self.mercenary = "";--佣兵阵容
    self.rline = 0--1扫荡需要记录路线
end

function CheckpointLayer:init(delegate,scenetype)
    self.delegate = delegate;
    self.scenetype = scenetype;
    MGRCManager:cacheResource("CheckpointLayer", "Checkpoint_ui0.png","Checkpoint_ui0.plist");
    local pWidget = MGRCManager:widgetFromJsonFile("CheckpointLayer","checkpoint_ui_1.ExportJson");
    self:addChild(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);

    self.panelTop = PanelTop.create(self)
    self.panelTop:setData("checkpoint_war_title.png");
    self:addChild(self.panelTop,10);

    self.mapPanel = pWidget:getChildByName("mapPanel");
    CommonMethod:setVisibleSize(self.mapPanel);

    local Panel_up = pWidget:getChildByName("Panel_up");
    self.Panel_go = pWidget:getChildByName("Panel_go");
    local Panel_down = pWidget:getChildByName("Panel_down");
    self.Panel_down = Panel_down;

    self.Image_flag = Panel_up:getChildByName("Image_flag");
    self.Image_flag:setTouchEnabled(true);
    self.Image_flag:addTouchEventListener(handler(self,self.onButtonClick));

    self.Label_warName = Panel_up:getChildByName("Label_warName");--战场名
    self.tables = {};
    for i=1,3 do
        local Image_plate = self.Image_flag:getChildByName("Image_plate"..i);

        local Image_bg = Panel_up:getChildByName("Image_bg"..i);
        local Image_icon = Image_bg:getChildByName("Image_icon"..i);
        Image_bg:setTouchEnabled(true);
        Image_bg:addTouchEventListener(handler(self,self.onButtonClick));

        table.insert(self.tables,{Image_plate=Image_plate,btn=Image_bg,icon=Image_icon});
    end
    self.oldHeadProgram = self.tables[1].icon:getSprit():getShaderProgram();

    self.Label_value2 = self.tables[2].btn:getChildByName("Label_value2");
    self.Label_value3 = self.tables[3].btn:getChildByName("Label_value3");
    local Image_bg4 = Panel_up:getChildByName("Image_bg4");
    self.Label_value4 = Image_bg4:getChildByName("Label_value4");

    self.Image_trea2 = self.tables[2].btn:getChildByName("Image_trea2");--宝箱
    self.Image_trea2:setTouchEnabled(true);
    self.Image_trea2:addTouchEventListener(handler(self,self.onButtonClick));

    self.Image_trea3 = self.tables[3].btn:getChildByName("Image_trea3");--宝箱
    self.Image_trea3:setTouchEnabled(true);
    self.Image_trea3:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_foreign = Panel_up:getChildByName("Button_foreign");--外交按钮
    self.Button_foreign:addTouchEventListener(handler(self,self.onButtonClick));
    self.Button_foreign:setEnabled(false);

    self.head = CheckpointHeadItem.create(self,"checkpoint_head_prismatic.png");--外交按钮
    self.head:setPosition(self.Button_foreign:getPosition());
    self.head:setEnabled(false);
    Panel_up:addChild(self.head);

    self.Button_teams = Panel_down:getChildByName("Button_teams");--组队或者撤军
    self.Button_teams:addTouchEventListener(handler(self,self.onButtonClick));
    self.Image_teams = self.Button_teams:getChildByName("Image_teams");

    self.Button_legion = Panel_down:getChildByName("Button_legion");--军团
    self.Button_legion:setEnabled(false);
    self.Button_legion:addTouchEventListener(handler(self,self.onButtonClick));
    self.Image_legion = self.Button_legion:getChildByName("Image_legion");

    self.Button_war = Panel_down:getChildByName("Panel_war");--开始征战
    local Button_war = self.Button_war:getChildByName("Button_war");--开始征战
    self.Button_war:addTouchEventListener(handler(self,self.onButtonClick));
    self.Image_war = Button_war:getChildByName("Image_war");

    self.Button_sweep = Panel_down:getChildByName("Button_sweep");--扫荡
    self.Button_sweep:addTouchEventListener(handler(self,self.onButtonClick));
    self.Image_sweep = self.Button_sweep:getChildByName("Image_sweep");

    self.CheckBox = Panel_down:getChildByName("CheckBox");--复选框
    self.CheckBox:setSelectedState(true);
    self.CheckBox:addEventListenerCheckBox(handler(self,self.onCheckBoxClick));

    -- self.Panel_go:setVisible(false);
    self.Button_go = self.Panel_go:getChildByName("Button_go");--前往
    self.Button_go:addTouchEventListener(handler(self,self.onButtonClick));
    local Label_go = self.Panel_go:getChildByName("Label_go");

    local Label_tip1 = self.Panel_go:getChildByName("Label_tip1");
    Label_tip1:setVisible(false);

    self.tipLabel = MGColorLabel:label();
    self.tipLabel:setAnchorPoint(cc.p(1, 0.5));
    self.tipLabel:setPosition(Label_tip1:getPosition());
    self.Panel_go:addChild(self.tipLabel);
       
    self:initView();
end

function CheckpointLayer:initView()
    self.mapSpr = cc.Sprite:createWithSpriteFrameName("stage_bg_1.jpg");
    local pContainerNode = cc.Node:create();
    pContainerNode:setContentSize(self.mapSpr:getContentSize());
    self.mapSpr:setPosition(pContainerNode:getContentSize().width/2 , pContainerNode:getContentSize().height/2);
    pContainerNode:addChild(self.mapSpr);

    local sc = self.mapPanel:getContentSize().height/self.mapSpr:getContentSize().height;
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

end

function CheckpointLayer:readSql()--解析数据库数据
    self.checkpointList = {}
    local sql = string.format("select * from stage_c_list where s_id=%d", self.checkpointId);
    local DBDataList = LUADB.selectlist(sql, "s_id:c_id:npc_id:name:pic:pos:is_start:next:reward_limit:reward:reward_show:reward_flip_show");
    table.sort(DBDataList.info,function(a,b) return a.c_id < b.c_id; end);

    local str = "";
    local str_list = {};
    local str_list1 = {};
    for index=1,#DBDataList.info do
        local DBData = {};
        DBData.s_id = tonumber(DBDataList.info[index].s_id);
        DBData.c_id = tonumber(DBDataList.info[index].c_id);
        DBData.npc_id = tonumber(DBDataList.info[index].npc_id);
        DBData.name = DBDataList.info[index].name;
        DBData.pic = DBDataList.info[index].pic..".png";
        DBData.is_start = tonumber(DBDataList.info[index].is_start);
        DBData.reward_limit = tonumber(DBDataList.info[index].reward_limit);

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

        DBData.next = {};
        str_list = {};
        str = DBDataList.info[index].next;
        if tonumber(str) == 0 then
            DBData.next = 0;
        else
            str_list = spliteStr(str,'|');
            for i=1,#str_list do
                DBData.next[i] = {};
                if tonumber(str_list[i]) == 0 then
                    DBData.next[i].nextId = 0;
                    DBData.next[i].type = 0;
                    DBData.next[i].value = 0;
                    DBData.next[i].needValue = 0;
                else
                    str_list1 = {};
                    str_list1 = spliteStr(str_list[i],':');
                    DBData.next[i].nextId = tonumber(str_list1[1]);
                    DBData.next[i].type = tonumber(str_list1[2]);
                    DBData.next[i].value = tonumber(str_list1[3]);
                    DBData.next[i].needValue = tonumber(str_list1[4]);
                end
            end
        end

        DBData.reward = {};
        str_list = {};
        str = DBDataList.info[index].reward;
        if tonumber(str) == 0 then
            DBData.reward = 0;
        else
            str_list = spliteStr(str,'|');
            for i=1,#str_list do
                DBData.reward[i] = {};
                if tonumber(str_list[i]) == 0 then
                    DBData.reward[i].type = 0;
                    DBData.reward[i].min = 0;
                    DBData.reward[i].max = 0;
                    DBData.reward[i].probability = 0;
                else
                    str_list1 = {};
                    str_list1 = spliteStr(str_list[i],':');
                    DBData.reward[i].type = tonumber(str_list1[1]);
                    DBData.reward[i].min = tonumber(str_list1[2]);
                    DBData.reward[i].max = tonumber(str_list1[3]);
                    DBData.reward[i].probability = tonumber(str_list1[4]);
                end
            end
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
                    DBData.reward_show[i].Id = 0;
                else
                    str_list1 = {};
                    str_list1 = spliteStr(str_list[i],':');
                    DBData.reward_show[i].type = tonumber(str_list1[1]);
                    DBData.reward_show[i].Id = tonumber(str_list1[2]);
                end
            end
        end

        DBData.reward_flip_show = {};
        str_list = {};
        str = DBDataList.info[index].reward_flip_show;
        if tonumber(str) == 0 then
            DBData.reward_flip_show = 0;
        else
            str_list = spliteStr(str,'|');
            for i=1,#str_list do
                DBData.reward_flip_show[i] = {};
                if tonumber(str_list[i]) == 0 then
                    DBData.reward_flip_show[i].type = 0;
                    DBData.reward_flip_show[i].Id = 0;
                else
                    str_list1 = {};
                    str_list1 = spliteStr(str_list[i],':');
                    DBData.reward_flip_show[i].type = tonumber(str_list1[1]);
                    DBData.reward_flip_show[i].Id = tonumber(str_list1[2]);
                end
            end
        end

        table.insert(self.checkpointList, DBData);
    end

    self.passConditions = {};
    local sql1 = string.format("select * from stage_pass_condition");
    local DBDataList1 = LUADB.selectlist(sql1, "id:desc");
    for i=1,#DBDataList1.info do
        local passConditions = {};
        passConditions.id = tonumber(DBDataList1.info[i].id);
        passConditions.desc = DBDataList1.info[i].desc;
        table.insert(self.passConditions, passConditions);
    end
end

function CheckpointLayer:onCheckBoxClick(sender, eventType)
    print(">>>>>>>>>>复选框>>>>>>>>>>>>>>>>>")
end

function CheckpointLayer:upData()
    NetHandler:sendData(Post_getUserMain, "");
    self.panelTop:upData();
    self:setData(self.ackData,self.mapInfo);
end

function CheckpointLayer:setData(ackData,mapInfo)
    self.checkpointId = mapInfo.id;
    self.mapInfo = mapInfo;
    self.ackData = ackData;
    self.data = self.ackData.getstage;

    self.gids = {};
    self.liveGeneralIds = {};
    if self.data.corp and self.data.corp.corps then
        local corps = getefflist(self.data.corp.corps);
        for i=1,#corps do
            table.insert(self.gids,corps[i].id);
            table.insert(self.liveGeneralIds,corps[i].id);
        end
    else
        local corps = getefflist(self.data.war.general);
        for i=1,#corps do
            table.insert(self.gids,corps[i].id);
        end

        local liveGeneral = getefflist(self.data.war.live_general);
        for i=1,#liveGeneral do
            table.insert(self.liveGeneralIds,liveGeneral[i].id);
        end
    end
    
    self:readSql();
    if self.data.war and self.data.war.c_id then
        self.curCityId = tonumber(self.data.war.c_id);
    else
        self.curCityId = 1;
    end

    self:initMap(checkpointId);
    self.mapSpr:setSpriteFrame(self.mapInfo.pic);
    self:setBtnType(1);
    self:CheckIsGo();
    
    self.totalNum = #self.checkpointList-1;
    self.totalStarNum = self.totalNum*3;
    -- local per = self.data.percent*100/self.totalNum;
    self.Label_value2:setText(string.format("%d%%",self.data.percent));
    self.Label_value3:setText(string.format("%d/%d",self.data.star,self.totalStarNum));
    local starNum = 0;
    if self.data.stage_c_info then--满星数后端要征战玩一条线路才下发，前端自己累计
        for i=1,#self.data.stage_c_info do
            starNum = starNum + tonumber(self.data.stage_c_info[i].star);
        end
    end
    self.Label_value3:setText(string.format("%d/%d",starNum,self.totalStarNum));

    local sql = "select value from config where id=57";
    local DBData = LUADB.select(sql, "value");
    self.Label_value4:setText(string.format(MG_TEXT("ML_CheckpointLayer_1"),DBData.info.value));

    if #self.mapInfo.visit == 0 or self.mapInfo.visit[1].type == 0 then
        self.head:setEnabled(false);
    else
        self.head:setEnabled(true);
        self.head:setForeignData(self.mapInfo.visit[1].type);
        self.head:setGray(true);
        if self.data.stage_c_info then
            for i=1,#self.data.stage_c_info do
                if tonumber(self.data.stage_c_info[i].c_id) == self.mapInfo.visit[1].id then
                    self.head:setGray(false);
                    break;
                end
            end
        end
    end

    self.Image_trea2:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
    self.Image_trea3:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
    for i=1,#self.tables do
        self.tables[i].icon:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
        self.tables[i].Image_plate:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
    end
    if tonumber(self.data.is_full_star) == 1 then--满星
        self.Image_trea2:getSprit():setShaderProgram(self.oldHeadProgram);
        self.Image_trea3:getSprit():setShaderProgram(self.oldHeadProgram);
        for i=1,#self.tables do
            self.tables[i].icon:getSprit():setShaderProgram(self.oldHeadProgram);
            self.tables[i].Image_plate:getSprit():setShaderProgram(self.oldHeadProgram);
        end
    else
        if self.data.percent == 100 then
            self.Image_trea2:getSprit():setShaderProgram(self.oldHeadProgram);
            for i=1,2 do
                self.tables[i].icon:getSprit():setShaderProgram(self.oldHeadProgram);
                self.tables[i].Image_plate:getSprit():setShaderProgram(self.oldHeadProgram);
            end
        else
            if self.data.is_npc == 1 then
                self.tables[1].icon:getSprit():setShaderProgram(self.oldHeadProgram);
                self.tables[1].Image_plate:getSprit():setShaderProgram(self.oldHeadProgram);
            end
        end
    end

    if tonumber(self.data.get_full_reward) == 1 then--0未领取 or 1 是否已领取满星奖励
        self.Image_trea3:setTouchEnabled(false);
        self.tables[3].btn:setTouchEnabled(false);
        self.Image_trea3:loadTexture("checkpoint_icon_treasure_open_box.png",ccui.TextureResType.plistType);
    end

    if tonumber(self.data.get_percent_reward) == 1 then--0 or 1 是否已领取完成度奖励
        self.Image_trea2:setTouchEnabled(false);
        self.tables[2].btn:setTouchEnabled(false);
        self.Image_trea2:loadTexture("checkpoint_icon_treasure_open_box.png",ccui.TextureResType.plistType);
    end

    if self.data.war and self.data.war.pass_c_stage and self.checkpointId == tonumber(self.data.war.s_id) then--绘制当前走过路线
        self.passRoadIds = getDataList(self.data.war.pass_c_stage);
        if #self.passRoadIds >= 2 then
            self:setRoad(self.passRoadIds[1].value1,self.passRoadIds[2].value1,2,1);
        end
    end

    if self.data.sweep_line then--绘制上次扫荡路线
        self.sweepLineIds = getDataList(self.data.sweep_line);
        if #self.sweepLineIds >= 2 then
            self:setRoad(self.sweepLineIds[1].value1,self.sweepLineIds[2].value1,2,2);
        end
    end

    if self.ackData.getflipreward then
        local fanPai = fanPaiLayer.showBox(self);
        fanPai:setData(self.ackData.getflipreward);
    end
end

function CheckpointLayer:CheckIsGo()
    self.Panel_go:setVisible(false);
    self.Button_go:setEnabled(false);
    self.Panel_down:setVisible(true);
    self.Button_teams:setEnabled(true);
    self.Button_legion:setEnabled(false);
    self.Button_sweep:setEnabled(true);
    self.Button_war:setEnabled(true);
    -- self.sprite:setVisible(true);
    -- if nil == self.data.sweep_line or self.data.sweep_line == "" then--没扫荡过
    --     self.Button_sweep:setEnabled(false);
    -- end

    if self.data.war and self.data.war.s_id then
        if self.checkpointId ~= tonumber(self.data.war.s_id) then--不在本关卡需要跳转
            self.Panel_go:setVisible(true);
            self.Button_go:setEnabled(true);
            self.Panel_down:setVisible(false);
            self.Button_teams:setEnabled(false);
            self.Button_legion:setEnabled(false);
            self.Button_sweep:setEnabled(false);
            self.Button_war:setEnabled(false);
            -- self.sprite:setVisible(false);

            local sql = string.format("select name from stage_list where id=%d", tonumber(self.data.war.s_id));
            local DBData = LUADB.select(sql, "name")

            self.tipLabel:clear();
            self.tipLabel:appendStringAutoWrap(string.format(MG_TEXT("ML_CheckpointLayer_5"),DBData.info.name),16,1,cc.c3b(255,255,255),22);
            return;
        else
            self:setBtnType(2);
        end
    end

    self:createHeroEffect();--创建马的动画
    if self.curCityId == 1 then
        self.sprite:setVisible(false);
    else
        self.sprite:setVisible(true);
    end
end

function CheckpointLayer:createHeroEffect()
    if self.sprite==nil then
        self.sprite=ccs.Armature:create("Champion01");
        self.sprite:setPosition(cc.p(self.checkpointList[self.curCityId].pos.x,self.checkpointList[self.curCityId].pos.y));
        self.sprite:setScale(0.6);
        self.sprite:getAnimation():playWithIndex(0,-1,1) --播放动画
        self.scrollView:getContainer():addChild(self.sprite,5);
    end
end

function CheckpointLayer:initMap(checkpointId)
    if self.cityItems and #self.cityItems > 0 then
        for i=1,#self.cityItems do
            self.cityItems[i]:removeFromParent();
        end
    end
    if self.tablePaths and #self.tablePaths > 0 then
        for i=1,#self.tablePaths do
            for j=1,#self.tablePaths[i] do
                if nil ~= self.tablePaths[i][j].sp then
                    self.tablePaths[i][j].sp:removeFromParent();
                end
            end
        end
    end

    self.angles = {};
    self.cityItems = {};
    self.tablePaths = {};
    self.tablePassMark = {};
    if self.tipItems then
        for i=1,#self.tipItems do
            if self.tipItems[i].markSpr then
                self.tipItems[i].markSpr:removeFromParent();
            end

            if self.tipItems[i].desLabel then
                self.tipItems[i].desLabel:removeFromParent();
            end 
        end
        self.tipItems = {};
    end

    for i=1,#self.checkpointList do
        local cityImg = CheckpointItem.create(self);
        cityImg:setData(self.checkpointList[i],self.checkpointList[i].c_id,self.data);
        cityImg:setPosition(cc.p(self.checkpointList[i].pos.x,self.checkpointList[i].pos.y));
        self.scrollView:getContainer():addChild(cityImg,3);
        -- table.insert(self.cityItems, cityImg);
        self.cityItems[self.checkpointList[i].c_id] = cityImg;

        self:checkPassage(self.checkpointList[i].c_id);
        if self.checkpointList[i].next ~= 0 then
            for j=1,#self.checkpointList[i].next do
                local next = self.checkpointList[i].next[j];
                self:createRoadLine(self.checkpointList[i].pos,self.checkpointList[next.nextId].pos,j,next.nextId);
            end
        end

    end
end

function CheckpointLayer:createRoadLine(pos1,pos2,index,nextId)--路径
    local tan = (pos2.y-pos1.y)/(pos2.x-pos1.x);
    local angle = 0;
    local pathPos = {};
    if pos2.x >= pos1.x and pos2.y >= pos1.y then--第一象限
        angle = math.deg(math.atan(tan));
    elseif pos2.x < pos1.x and pos2.y > pos1.y then--第二象限
        angle = 180+math.deg(math.atan(tan));
    elseif pos2.x <= pos1.x and pos2.y <= pos1.y then--第三象限
        angle = 180+math.deg(math.atan(tan));
    elseif pos2.x > pos1.x and pos2.y < pos1.y then--第四象限
        angle = 360+math.deg(math.atan(tan));
    end

    angle = 360-angle;--游戏里顺时针旋转所以要360-angle
    local dis = math.sqrt((pos2.y-pos1.y)*(pos2.y-pos1.y)+(pos2.x-pos1.x)*(pos2.x-pos1.x));--两点间的距离
    local average = 40;
    local rate = math.floor(dis/average);--向下取整
    if (dis-rate*average) > average/2 then--如果超出的距离大于平均每段距离的一半，等分数+1
        rate = rate + 1;
        average = dis/rate;
    end

    for i=1,rate do
        local pos = {};
        pos.x = (pos2.x-pos1.x)*i/rate+pos1.x;
        pos.y = (pos2.y-pos1.y)*i/rate+pos1.y;
        table.insert(pathPos,pos);
    end

    local pathTables = {}
    table.insert(pathTables,{pos=pos1,sp=nil});
    for i=1,#pathPos do
        local sp=cc.Sprite:createWithSpriteFrameName("checkpoint_path_point.png");--checkpoint_path_point
        sp:setPosition(pathPos[i].x,pathPos[i].y);
        sp:setRotation(angle);
        self.scrollView:getContainer():addChild(sp,1);
        table.insert(pathTables,{pos=pathPos[i],sp=sp});
    end
    table.insert(pathTables,{pos=pos2,sp=nil});
    table.insert(self.tablePaths,pathTables);
    table.insert(self.angles,{angle=angle,nextId=nextId});
end

function CheckpointLayer:checkRoad(rline)--检测是否多条路
    self.rline = rline;
    if self.data.war and tonumber(self.data.war.is_next) == 0 then--当前关卡未打
        if self.curCityId > 1 then
            self:starWar(self.curCityId);
            return;
        end
    end

    --多条路
    if self.checkpointList[self.curCityId].next ~= 0 and #self.checkpointList[self.curCityId].next > 1 then
        local chooseRoad = MLChooseRoad.showBox(self);
        chooseRoad:setData(self.checkpointList,self.curCityId,self.tablePassMark);
    elseif self.checkpointList[self.curCityId].next ~= 0 and #self.checkpointList[self.curCityId].next == 1 then
        self:setNextCityId(self.checkpointList[self.curCityId].next[1].nextId);
    else
        local teamdata = "";
        local fightdata = "";
        FightOP:setTeam(self.scenetype,Fight_common,teamdata,fightdata,self.checkpointList[self.curCityId].name);
    end
end

function CheckpointLayer:starWar(cityId)
    if #self.data.stage_c_info <= 0 then
        local teamdata = "";
        local fightdata = "";
        FightOP:setTeam(self.scenetype,Fight_common,teamdata,fightdata,self.checkpointList[self.curCityId].name);
        return;
    end

    local isWar = false;--是否已经战斗过
    for i=1,#self.data.stage_c_info do
        if cityId == tonumber(self.data.stage_c_info[i].c_id) then
            if tonumber(self.data.stage_c_info[i].star) == 3 then--3星扫荡
                NetHandler:sendData(Post_Pve_embattle_1, "");
            else
                local teamdata = "";
                local fightdata = "";
                FightOP:setTeam(self.scenetype,Fight_common,teamdata,fightdata,self.checkpointList[self.curCityId].name);
            end
            isWar = true;
            return;
        end
    end

    if isWar == false then
        self.curCityId = cityId;
        local teamdata = "";
        local fightdata = "";
        FightOP:setTeam(self.scenetype,Fight_common,teamdata,fightdata,self.checkpointList[self.curCityId].name);
    end
end

function CheckpointLayer:setNextCityId(nextCityId)
    if nil == self.rline then
        self.rline = 0;
    end

    self.nextCityId = nextCityId;
    if self.data.war and tonumber(self.data.war.is_next) == 1 then--移到下一关
        self:movePointSendReq();
    else
       self:sendReq(self.rline);
    end
end

function CheckpointLayer:checkPassage(c_id)--检测下一条路线是否通行
    local desc = "";
    local str = "";
    local DBData1 = nil;
    local index = 0;
    self.nexts = self.checkpointList[c_id].next;

    if 0 == self.nexts then
        return;
    end
    
    for i=1,#self.nexts do
        local isPass = true;
        local id = self.nexts[i].type;--conditionId
        local icout = 0;
        if id > 0 then
            desc = self.passConditions[id].desc;
            for j=1,#self.liveGeneralIds do
                local gm = GENERAL:getGeneralModel(self.liveGeneralIds[j])
                if id == 1 then
                    DBData1 = LUADB.select(string.format("select name from soldier_list where id=%d", self.nexts[i].value), "name");
                    str = string.format(desc,DBData1.info.name,self.nexts[i].needValue);
                    if gm then
                        if self.nexts[i].value == gm:soldierid() then
                            icout = icout + 1;
                        end
                    end
                elseif id == 2 then
                    str = string.format(desc,MG_TEXT("sex_"..self.nexts[i].value),self.nexts[i].needValue);
                    if gm then
                        if self.nexts[i].value == gm:getSex() then
                            icout = icout + 1;
                        end
                    end
                elseif id == 3 then
                    str = string.format(desc,self.nexts[i].value,self.nexts[i].needValue);
                    if gm then
                        if self.nexts[i].value <= gm:getLevel() then
                            icout = icout + 1;
                        end
                    end
                elseif id == 4 then
                    DBData1 = LUADB.select(string.format("select desc from quality where id=%d", self.nexts[i].value), "desc");
                    str = string.format(desc,DBData1.info.desc,self.nexts[i].needValue);
                    if gm then
                        if self.nexts[i].value == gm:getQuality() then
                            icout = icout + 1;
                        end
                    end
                elseif id == 5 then
                    str = string.format(desc,self.nexts[i].needValue);
                    icout = #self.liveGeneralIds;
                elseif id == 6 then
                    str = string.format(desc,self.nexts[i].value,self.nexts[i].needValue);
                    if gm then
                        if self.nexts[i].value >= gm:getStar() then
                            icout = icout + 1;
                        end
                    end
                elseif id == 7 then
                    str = string.format(desc,self.nexts[i].value,self.nexts[i].needValue);
                    if gm then
                        if self.nexts[i].value >= gm:getPower() then
                            icout = icout + 1;
                        end
                    end
                elseif id == 8 then
                    str = string.format(desc,self.nexts[i].value,self.nexts[i].needValue);
                    if gm then
                        if self.nexts[i].value >= gm:getCommand() then
                            icout = icout + 1;
                        end
                    end
                elseif id == 9 then
                    str = string.format(desc,self.nexts[i].value,self.nexts[i].needValue);
                    if gm then
                        if self.nexts[i].value >= gm:getStrategy() then
                            icout = icout + 1;
                        end
                    end
                elseif id == 10 then
                    str = string.format(desc,self.nexts[i].value,self.nexts[i].needValue);
                    if gm then
                        if self.nexts[i].value >= gm:getAttack() then
                            icout = icout + 1;
                        end
                    end
                elseif id == 11 then
                    str = string.format(desc,self.nexts[i].value,self.nexts[i].needValue);
                    if gm then
                        if self.nexts[i].value >= gm:getDefense() then
                            icout = icout + 1;
                        end
                    end
                elseif id == 12 then
                    str = string.format(desc,self.nexts[i].value,self.nexts[i].needValue);
                    if gm then
                        if self.nexts[i].value >= gm:curforces() then
                            icout = icout + 1;
                        end
                    end
                elseif id == 13 then
                    str = string.format(desc,self.nexts[i].value,self.nexts[i].needValue);
                    if gm then
                        if self.nexts[i].value >= gm:getSpeed() then
                            icout = icout + 1;
                        end
                    end
                elseif id == 14 then
                    str = string.format(desc,MG_TEXT("hero_type_"..self.nexts[i].value),self.nexts[i].needValue);
                    if gm then
                        DBData1 = LUADB.select(string.format("select type from soldier_list where id=%d", gm:soldierid()), "type");                        
                        local str_list = {};
                        str_list = spliteStr(DBData1.info.type,':');
                        for i=1,#str_list do
                            if tonumber(str_list[i]) == self.nexts[i].value then
                                icout = icout + 1;
                                break;
                            end
                        end
                    end
                elseif id == 15 then
                    DBData1 = LUADB.select(string.format("select name from general_list where id=%d", self.nexts[i].value), "name");
                    str = string.format(desc,DBData1.info.name);
                    if gm then
                        if self.nexts[i].value >= gm:getId() then
                            icout = icout + 1;
                        end
                    end
                end
            end

            index = index + 1;
            if icout < self.nexts[i].needValue then
                local pos1 = self.checkpointList[c_id].pos;
                local pos2 = self.checkpointList[self.nexts[i].nextId].pos;
                local disPos = {};
                disPos.x = pos1.x+(pos2.x-pos1.x)/2;
                disPos.y = pos1.y+(pos2.y-pos1.y)/2;
                local spr=cc.Sprite:createWithSpriteFrameName("checkpoint_no_entry.png");
                spr:setPosition(cc.p(disPos.x,disPos.y));
                self.scrollView:getContainer():addChild(spr,2);
                isPass = false;
            end

            local markSpr = cc.Sprite:createWithSpriteFrameName("com_checkbox_tick.png");
            markSpr:setPosition(cc.p(self.Panel_down:getContentSize().width*2/5-80,30+(index-1)*30));
            self.Panel_down:addChild(markSpr,2);

            local name1 = self.checkpointList[c_id].name;
            local name2 = self.checkpointList[self.nexts[i].nextId].name;
            local desLabel = MGColorLabel:label();
            desLabel:setAnchorPoint(cc.p(0, 0.5));
            desLabel:setPosition(cc.p(markSpr:getContentSize().width/2+markSpr:getPositionX(),markSpr:getPositionY()));
            self.Panel_down:addChild(desLabel,2);

            table.insert(self.tipItems,{markSpr=markSpr, desLabel=desLabel});

            local str1 = "";
            if isPass == true then
                markSpr:setSpriteFrame("com_checkbox_tick.png");
                str1 = string.format(MG_TEXT("ML_CheckpointLayer_2"),name1,name2)..string.format("<c=000,255,000>%s</c>",str); 
            elseif isPass == false then
                markSpr:setSpriteFrame("checkpoint_fault.png");
                str1 = string.format(MG_TEXT("ML_CheckpointLayer_2"),name1,name2)..string.format("<c=255,000,000>%s</c>",str);
            end
            desLabel:clear();
            desLabel:appendStringAutoWrap(str1,24,1,cc.c3b(255,255,255),22);
        end

        table.insert(self.tablePassMark,{curCityId=c_id,nextCityId=self.nexts[i].nextId,isPass=isPass});
    end

    if #self.tipItems > 0 then
        local h = self.tipItems[1].markSpr:getPositionY();
        for i=1,#self.tipItems do
            if i >= 2 then
                self.tipItems[i].markSpr:setPositionY(h);
                self.tipItems[i].desLabel:setPositionY(self.tipItems[i].markSpr:getPositionY());
            end
            h = h+self.tipItems[i].desLabel:getContentSize().height+5;
        end
    end
end

--runType=2 表示扫荡走路线
function CheckpointLayer:goRun(nextCityId,runType)
    local angle = 0;
    self.icout = 0;

    local curCityId = self.curCityId;
    if runType == 2 then
        self.sweepLineNum = self.sweepLineNum + 1;
        curCityId = self.curSweepCityId;
    end

    for i=1,#self.angles do
        if self.angles[i].nextId == nextCityId then
            angle = self.angles[i].angle;
            break;
        end
    end
    local pos1 = self.checkpointList[curCityId].pos;
    local endPos = self.checkpointList[nextCityId].pos;

    local index = 0;
    for i=1,#self.tablePaths do
        if pos1 == self.tablePaths[i][1].pos and endPos == self.tablePaths[i][#self.tablePaths[i]].pos then
            index = i;
            break;
        end
    end

    local pos2 = self.tablePaths[index][2].pos;
    self:runGoAction(pos1,pos2,self.tablePaths[index],angle,nextCityId,runType);
end

function CheckpointLayer:runGoAction(pos1,pos2,pathPos,angle,nextCityId,runType)
    self.icout = self.icout + 1;
    local rate = 150;
    local sqrt = math.sqrt((pos1.x-pos2.x)*(pos1.x-pos2.x)+(pos1.y-pos2.y)*(pos1.y-pos2.y));
    local time = sqrt/rate;

    self.sprite:setPosition(cc.p(pos1.x,pos1.y));
    -- self.sprite:setRotation(angle);
    self.sprite:setVisible(true);
    local function checkAction()
        if self.icout == 1 then
            self.sprite:getAnimation():play("walk");
            self.sprite:getAnimation():setSpeedScale(0.6);
        end

        if self.icout <= #pathPos-2 then
            pathPos[self.icout+1].sp:setSpriteFrame("checkpoint_red_path_point.png");
            self:runGoAction(pos2,pathPos[self.icout+2].pos,pathPos,angle,nextCityId,runType);
        else
            self.sprite:getAnimation():playWithIndex(0,-1,1) --播放动画
            if runType == 2 then
                --------到每一关弹奖励表现---------------
                if nextCityId == self.sweepLineIds[#self.sweepLineIds].value1 then--走到最后一关弹翻牌
                    print(">>>>>>>>>>>翻牌>>>>>>>>>>>")
                    self.sprite:setVisible(false);
                    self.sprite:setPosition(cc.p(self.checkpointList[1].pos.x,self.checkpointList[1].pos.y));
                    self:flip();
                else--每到一关弹奖励表现
                    print(">>>>>>>>>弹奖励动画>>>>>>>>>>>");
                    self.curSweepCityId = nextCityId;

                    self:goRun(self.sweepLineIds[self.sweepLineNum+1].value1,2);
                    
                end
                for i=1,#self.flipData.c_item do
                    if tonumber(self.flipData.c_item[i].c_id) == self.sweepLineIds[self.sweepLineNum].value1 then
                        self:getResource(self.flipData.c_item[i].get_item,nextCityId);
                        break;
                    end
                end
            else
                print(">>>>>>>>>>>进入战斗>>>>>>>>>>>")
                self:starWar(self.nextCityId);
            end
        end
    end
    local mv = cc.MoveTo:create(time, pos2);
    local func = cc.CallFunc:create(checkAction);
    self.sprite:runAction(cc.Sequence:create(mv,func));
end

function CheckpointLayer:setRoad(curCityId,nextCityId,icout,roadType)--设置上次扫荡路线
    local pos1 = self.checkpointList[curCityId].pos;
    local endPos = self.checkpointList[nextCityId].pos;

    local index = 0;
    for i=1,#self.tablePaths do
        if pos1 == self.tablePaths[i][1].pos and endPos == self.tablePaths[i][#self.tablePaths[i]].pos then
            index = i;
            break;
        end
    end

    if index > 0 then
        for i=1,#self.tablePaths[index] do
            if nil ~= self.tablePaths[index][i].sp then
                self.tablePaths[index][i].sp:setSpriteFrame("checkpoint_red_path_point.png");
            end
        end
    end

    if roadType == 1 then--当前走过路线
        if icout < #self.passRoadIds then
            self:setRoad(nextCityId,self.passRoadIds[icout+1].value1,icout+1,1);
        end
    elseif roadType == 2 then--上次扫荡路线
        if icout < #self.sweepLineIds then
            self:setRoad(nextCityId,self.sweepLineIds[icout+1].value1,icout+1,2);
        end
    end
end

function CheckpointLayer:initSweepFlip(flipData)--扫荡弹翻牌
    self.flipData = flipData;
    self.flip_rewards = {};
    self.flipNum = 0;--翻牌次数
    self.flipAllRewards = {};--所有翻牌奖励
    for i=1,#self.flipData.flip_reward do
        table.insert(self.flip_rewards,self.flipData.flip_reward[i]);
    end
    table.sort(self.flip_rewards,function(d1,d2) return tonumber(d1.flip_time) < tonumber(d2.flip_time); end);
    self.sweepLineNum = 1;
    self.curSweepCityId = 1;
    self:goRun(self.sweepLineIds[2].value1,2);
end

function CheckpointLayer:flip()
    if #self.flip_rewards <= 0 then
        self:parseFightResultData();
        return;
    end
    self.flipNum = self.flipNum + 1;
    if self.flipNum > #self.flip_rewards then
        print(">>>>>>>>>弹征战结束界面>>>>>>>>>>>");
        self:parseFightResultData();
        return;
    end
    self:flipSendReq(self.flip_rewards[self.flipNum].flip_name,self.flip_rewards[self.flipNum].flip_type);
end

function CheckpointLayer:addReward(rewards)
    --rewards的格式  类型:id:数量
    if nil == rewards then
        return;
    end

    local rewardList = getDataList(rewards);
    for i=1,#rewardList do
        local isHave = false;
        local allReward = {}

        for j=1,#self.flipAllRewards do
            if self.flipAllRewards[j].item_id == rewardList[i].value2 and 
            self.flipAllRewards[j].item_type == rewardList[i].value1 then
                self.flipAllRewards[j].item_num = self.flipAllRewards[j].item_num + rewardList[i].value3;
                isHave = true;
                break;
            end
        end

        if isHave == false then
            allReward.item_type = rewardList[i].value1;
            allReward.item_id = rewardList[i].value2;
            allReward.item_num = rewardList[i].value3;
            table.insert(self.flipAllRewards,allReward);
        end
    end
end

function CheckpointLayer:parseFightResultData()--解析扫荡返回的征战结束数据
    self:addReward(self.flipData.get_item);
    local str = "";
    for i=1,#self.flipAllRewards do
        if i == 1 then
            str = [["]]..self.flipAllRewards[i].item_type..":"..self.flipAllRewards[i].item_id..":"..self.flipAllRewards[i].item_num;
        elseif i == #self.flipAllRewards then
            str = str.."|"..self.flipAllRewards[i].item_type..":"..self.flipAllRewards[i].item_id..":"..self.flipAllRewards[i].item_num..[["]];
        else
            str = str.."|"..self.flipAllRewards[i].item_type..":"..self.flipAllRewards[i].item_id..":"..self.flipAllRewards[i].item_num;
        end
    end
    
    if #self.flip_rewards <= 0 then
        str = self.flipData.get_item;
    end

    local fightingData = {};
    fightingData.use_action = tonumber(self.flipData.use_action);
    fightingData.user_exp = tonumber(self.flipData.user_exp);
    fightingData.is_war_win = 1;
    fightingData.war_get_item = str;
    fightingData.isSweep = 1;--0正常战斗，1扫荡

    self:addFightResultLayer(fightingData);
end

function CheckpointLayer:addSweepLayer(layerType)
    if nil == layerType then
        layerType = 1;--1从扫荡按钮进，2征战结束界面点重新选路进，3征战结束界面点再次扫荡进
    end
    local sweep = MLsweep.showBox(self);
    sweep:setData(self.data,self.mapInfo,layerType);
end

function CheckpointLayer:addCityInfoLayer(c_id)
    self.c_id = c_id;
    local cityInfo = MLCityInfo.showBox(self);
    cityInfo:setData(self.checkpointList,self.c_id,self.checkpointId);
end

function CheckpointLayer:addFightResultLayer(fightingData)
    local fightResult = MLFightResult.showBox(self);--征战结算界面
    fightResult:setData(fightingData);
    self.rline = 0;
end

function CheckpointLayer:setBtnType(btnType)
    if btnType == 1 then--编队
        self.Image_teams:loadTexture("checkpoint_button_formation.png",ccui.TextureResType.plistType);
        self.Button_legion:setEnabled(false);
        self.Button_teams:setEnabled(true);
    elseif btnType == 2 then--撤军
        self.Image_teams:loadTexture("button_withdrawal.png",ccui.TextureResType.plistType);
        self.Button_legion:setEnabled(true);--军团
        self.Button_teams:setEnabled(true);
    end
    self.btnType = btnType;
end

function CheckpointLayer:onButtonClick(sender, eventType)
    if sender ~= self.tables[1].btn and sender ~= self.tables[2].btn and sender ~= self.tables[3].btn then
        if sender == self.Button_teams then
            buttonClickScale(self.Image_teams, eventType);
        elseif sender == self.Button_legion then
            buttonClickScale(self.Image_legion, eventType);
        elseif sender == self.Button_war then
            buttonClickScale(self.Image_war, eventType);
        elseif sender == self.Button_sweep then
            buttonClickScale(self.Image_sweep, eventType);
        else
            buttonClickScale(sender, eventType);
        end
    end
    
    if eventType == ccui.TouchEventType.ended then
        local sc = cc.ScaleTo:create(0.1, 1);
        if sender == self.Button_teams then--组队或者撤军
            if self.btnType == 1 then--组队
                if ME:getUnionId() == 0 then
                    local team = MLTeam.showBox(self);
                    team:setData(self.data);
                else
                    NetHandler:sendData(Post_union_mercenary_getMercenary, "");
                end
            elseif self.btnType == 2 then--撤军
                local retreat = MLRetreat.showBox(self);--撤退
            end
        elseif sender == self.Button_legion then--军团
            local legion = MLLegion.showBox(self);
            legion:setData(self.data);
        elseif sender == self.Button_war then--开始征战
            --没有阵容（拥有的武将少于5直接帮玩家上，否则提示先去编队）
            if nil == self.gids or #self.gids <= 0 then
                local gmList = GENERAL:getGeneralList();
                if gmList then
                    if #gmList <= 5 then
                        for i=1,#gmList do
                            table.insert(self.gids,gmList[i]:getId());
                        end
                    else
                        -- local team = MLTeam.showBox(self);
                        -- team:setData(self.data);
                        MGMessageTip:showFailedMessage(MG_TEXT("ML_CheckpointLayer_6"));
                    end
                end
            else
                self.sprite:setVisible(true);
                self:checkRoad();
            end
        elseif sender == self.Button_sweep then--扫荡
            if self.data.is_full_star == 1 then--满星
                self:addSweepLayer(1);
            else
                MGMessageTip:showFailedMessage(MG_TEXT("ML_CheckpointLayer_3"));
            end
        elseif sender == self.Image_trea2 or sender == self.tables[2].btn then--宝箱1 关卡进度
            local overReward = MLReward.showBox(self);
            overReward:setData(self.mapInfo,1);
            
        elseif sender == self.Image_trea3 or sender == self.tables[3].btn then--宝箱2 满星率
            local overReward = MLReward.showBox(self);
            overReward:setData(self.mapInfo,2);
           
        elseif sender == self.Button_foreign then--外交
            
        elseif sender == self.tables[1].btn then--红旗 self.Image_flag then--红旗
            local fallAndPlot = MLFallAndPlot.showBox(self);
            fallAndPlot:setData(self.checkpointId);
        elseif sender == self.Button_go then--前往
            if self.delegate and self.delegate.goCheckpointLayer then
                self.delegate:goCheckpointLayer(tonumber(self.data.war.s_id));
            end
            self:removeFromParent();
        end
    end
end

function CheckpointLayer:ItemSelect()--外交
    local str = string.format("&sid=%d",self.checkpointId);
    NetHandler:sendData(Post_visitInfo, str);
end

function CheckpointLayer:back()
    if self.delegate and self.delegate.setUpdataState then
        self.delegate:setUpdataState(true);
    end
    NetHandler:sendData(Post_getCityInfo, "");--刷新主线主界面
    self:removeFromParent();
end

function CheckpointLayer:onReciveData(MsgID, NetData)
    print("CheckpointLayer onReciveData MsgID:"..MsgID)

    local ackData = NetData;
    if MsgID == Post_startWar then
        if ackData.state == 1 then
            self:setData(ackData,self.mapInfo);
            self.Button_legion:setEnabled(true);
            self:setBtnType(2);

            if ackData.getstage.war.is_next == 1 then
                self:movePointSendReq();
            elseif ackData.getstage.war.is_next == 0 then
                self:starWar(self.curCityId);
            end
        else
            NetHandler:showFailedMessage(ackData)
        end
    elseif MsgID == Post_movePoint then--移动到下一关
        if ackData.state == 1 then
            self:goRun(self.nextCityId);
            if self.data.war then
                self.data.war.is_next = tonumber(ackData.movepoint.is_next);
                self.data.war.c_id = tonumber(ackData.movepoint.c_id);
                self.curCityId = self.nextCityId;
            end
        else
            MGMessageTip:showFailedMessage(ackData);
        end
    elseif MsgID == Post_closeWar then--撤军
        if ackData.state == 1 then
            if ackData.closewar.is_end == 1 then--1结束讨伐战
                self:addFightResultLayer(ackData.closewar);
            end
            self:setData(ackData,self.mapInfo);
            self.sprite:setPosition(cc.p(self.checkpointList[1].pos.x,self.checkpointList[1].pos.y));
        else
            NetHandler:showFailedMessage(ackData)
        end
    elseif MsgID == Post_visitInfo then--外交
        if ackData.state == 1 then
            local foreignLayer = MLForeignLayer.showBox(self);
            foreignLayer:setData(self.mapInfo,self.checkpointList,ackData.visitinfo);
        else
            MGMessageTip:showFailedMessage(ackData);
        end
    elseif MsgID == Post_Pve_embattle_1 then--布阵
        if ackData.state == 1 then
            NetHandler:sendData(Post_fighting_1, "");
        else
            MGMessageTip:showFailedMessage(ackData);
        end
    elseif MsgID == Post_fighting_1 then--进入战斗
        if ackData.state == 1 then
            self.data.war = ackData.getstage.war;
            self.data.is_npc = ackData.getstage.is_npc;
            self.data.star = ackData.getstage.star;
            self.data.get_percent_reward = ackData.getstage.get_percent_reward;
            self.data.is_full_star = ackData.getstage.is_full_star;
            self.data.percent = ackData.getstage.percent;
            self.data.get_full_reward = ackData.getstage.get_full_reward;
            self.data.stage_c_info = ackData.getstage.stage_c_info;

            self:upData();
            if ackData.fighting.is_end == 1 then--1结束讨伐战
                self:addFightResultLayer(ackData.fighting);
                getItem.showBox(ackData.fighting.war_get_item);
            else
                self:getResource(ackData.fighting.get_item,self.curCityId);
            end

            if ackData.getflipreward then
                local fanPai = fanPaiLayer.showBox(self);
                fanPai:setData(ackData.getflipreward,1);
            end
            self:setData(ackData,self.mapInfo);
        else
            MGMessageTip:showFailedMessage(ackData);
        end
    elseif MsgID == Post_Pve_changeUseGeneral then--上阵
        if ackData.state == 1 then
            if ackData.changeusegeneral.is_ok == 1 then
                NetHandler:sendData(Post_fighting_1, "");
            end
        else
            MGMessageTip:showFailedMessage(ackData);
        end
    elseif MsgID == Post_getFlipReward then--扫荡触发的翻牌
        if ackData.state == 1 then
            local fanPai = fanPaiLayer.showBox(self);
            fanPai:setData(ackData.getflipreward,2);
            fanPai:setSweepFlip(#self.flip_rewards-self.flipNum);
        else
            MGMessageTip:showFailedMessage(ackData);
        end
    elseif MsgID == Post_union_mercenary_getMercenary then--获取佣兵列表
        if ackData.state == 1 then
            local team = MLTeam.showBox(self);
            team:setData(self.data,ackData.getmercenary);
        else
            MGMessageTip:showFailedMessage(ackData);
        end
    elseif MsgID == Post_Pve_getFullStarReward then--领取满星奖励
        if ackData.state == 1 then
            getItem.showBox(self.mapInfo.star_reward);
            self.ackData.getstage.get_full_reward = 1;
            self:setData(self.ackData,self.mapInfo);
        else
            MGMessageTip:showFailedMessage(ackData);
        end
    elseif MsgID == Post_Pve_getAllPassReward then--领取全通关奖励
        if ackData.state == 1 then
            getItem.showBox(self.mapInfo.pass_reward);
            self.ackData.getstage.get_percent_reward = 1;
            self:setData(self.ackData,self.mapInfo);
        else
            MGMessageTip:showFailedMessage(ackData);
        end
    end
end

function CheckpointLayer:updataCorps(corps,mercenary)--设置阵容
    self.mercenary = mercenary;--佣兵阵容
    self.gids = corps;--武将阵容
    local str = ""
    local dataList = getDataList(self.data.corp.use);--上阵的武将
    for i=#dataList,-1,1 do
        for j=1,#self.gids do
            if self.gids[j] == dataList[i].value2 then
                table.remove(dataList,i);
                break;
            end
        end
    end

    for i=1,#dataList do
        if i == 1 then
            str = tostring(dataList[i].value1)..":"..tostring(dataList[i].value2);
        else
            str = str.."|"..tostring(dataList[i].value1)..":"..tostring(dataList[i].value2);
        end
    end

    self.data.corp.use = str;
    self.ackData.getstage = self.data;
    self:setData(self.ackData,self.mapInfo);
end

function CheckpointLayer:getResource(get_item,curCityId)
    local itemPos = {};
    local itemlist = getneedlist(get_item);
    for i=1,#itemlist do
        local pos=self.cityItems[curCityId]:convertToWorldSpace(cc.p(self.cityItems[curCityId]:getContentSize().width/2
            +20*(i-1),self.cityItems[curCityId]:getContentSize().height/2));
        table.insert(itemPos,pos);
    end
    ItemJump:getInstance():showItemJump(get_item,self.scrollView:getContainer(),itemPos,0.65,true);
end

function CheckpointLayer:sendReq()
    local str = string.format("&sid=%d&gids=%s&rline=%d&mercenary=%s",self.checkpointId, cjson.encode(self.gids),self.rline,self.mercenary);
    NetHandler:sendData(Post_startWar, str);
end

function CheckpointLayer:flipSendReq(name,type)
    local str = string.format("&name=%s&type=%d",name,type);
    NetHandler:sendData(Post_getFlipReward, str);
end

function CheckpointLayer:movePointSendReq()
    local str = string.format("&cid=%d",self.nextCityId);
    NetHandler:sendData(Post_movePoint, str);
end

function CheckpointLayer:getFullStarRewardSendReq()
    local str = string.format("&sid=%d",self.checkpointId);
    NetHandler:sendData(Post_Pve_getFullStarReward, str);
end

function CheckpointLayer:getAllPassRewardSendReq()
    local str = string.format("&sid=%d",self.checkpointId);
    NetHandler:sendData(Post_Pve_getAllPassReward, str);
end

function CheckpointLayer:pushAck()
    NetHandler:addAckCode(self,Post_startWar);
    NetHandler:addAckCode(self,Post_closeWar);
    NetHandler:addAckCode(self,Post_visitInfo);
    NetHandler:addAckCode(self,Post_Pve_embattle_1);
    NetHandler:addAckCode(self,Post_fighting_1);
    NetHandler:addAckCode(self,Post_movePoint);
    NetHandler:addAckCode(self,Post_Pve_changeUseGeneral);
    NetHandler:addAckCode(self,Post_getFlipReward);
    NetHandler:addAckCode(self,Post_union_mercenary_getMercenary);
    NetHandler:addAckCode(self,Post_Pve_getFullStarReward);
    NetHandler:addAckCode(self,Post_Pve_getAllPassReward);
end

function CheckpointLayer:popAck()
    NetHandler:delAckCode(self,Post_startWar);
    NetHandler:delAckCode(self,Post_closeWar);
    NetHandler:delAckCode(self,Post_visitInfo);
    NetHandler:delAckCode(self,Post_Pve_embattle_1);
    NetHandler:delAckCode(self,Post_fighting_1);
    NetHandler:delAckCode(self,Post_movePoint);
    NetHandler:delAckCode(self,Post_Pve_changeUseGeneral);
    NetHandler:delAckCode(self,Post_getFlipReward);
    NetHandler:delAckCode(self,Post_union_mercenary_getMercenary);
    NetHandler:delAckCode(self,Post_Pve_getFullStarReward);
    NetHandler:delAckCode(self,Post_Pve_getAllPassReward);
end

function CheckpointLayer:onEnter()
    self:pushAck();
end

function CheckpointLayer:onExit()
    self.scrollView:destroy();
    for i=1,#self.cityItems do
        self.cityItems[i]:remove();
    end
    MGRCManager:releaseResources("CheckpointLayer");
    self:popAck();
end

function CheckpointLayer.create(delegate,scenetype)
    local layer = CheckpointLayer:new()
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

function CheckpointLayer.showBox(delegate,scenetype)
    local layer = CheckpointLayer.create(delegate,scenetype);
    layer:setTag(5200);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
