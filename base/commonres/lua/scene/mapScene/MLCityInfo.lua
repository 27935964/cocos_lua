require "Item"

MLCityInfo = class("MLCityInfo", MGLayer)

function MLCityInfo:ctor()

end

function MLCityInfo:init()
    local pWidget = MGRCManager:widgetFromJsonFile("MLCityInfo","cityInfo_ui_1.ExportJson");
    self:addChild(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);

    local Panel_1 = pWidget:getChildByName("Panel_1");
    local Panel_2 = pWidget:getChildByName("Panel_2");
    Panel_1:addTouchEventListener(handler(self,self.onButtonClick));

    self.Label_title = Panel_2:getChildByName("Label_title");
    self.ListView = Panel_2:getChildByName("ListView");
    self.ListView:setScrollBarVisible(false);

    self.Button_close = Panel_2:getChildByName("Button_close");
    self.Button_close:addTouchEventListener(handler(self,self.onButtonClick));

end

function MLCityInfo:setData(checkpointList,c_id,checkpointId)
    self.checkpointList = checkpointList;
    self.checkpointId = checkpointId;--城池Id
    self.c_id = c_id;--关卡Id
    self.nexts = self.checkpointList[self.c_id].next;
    self.reward_shows = self.checkpointList[self.c_id].reward_show;
    self.flipRewards = self.checkpointList[self.c_id].reward_flip_show;
    local sql = string.format("select * from stage_corps where s_id=%d and c_id=%d",checkpointId,self.checkpointList[self.c_id].c_id);
    local DBDataList = LUADB.selectlist(sql, "camp:npc_id");
    self.npcDatas = {};
    if DBDataList then
        for i=1,#DBDataList.info do
            if tonumber(DBDataList.info[i].camp) == 1 then
                table.insert(self.npcDatas,DBDataList.info[i]);
            end
        end
    end

    self.ListView:removeAllItems();
    if self.nexts ~= 0 then
        local item1 = self:createItemFront();
        self.ListView:pushBackCustomItem(item1);
    end

    if #self.npcDatas > 0 then
        local item2 = self:createItemEnemy();
        self.ListView:pushBackCustomItem(item2);
    end

    if self.reward_shows ~= 0 then
        local item3 = self:createItemReward();
        self.ListView:pushBackCustomItem(item3);
    end

    if self.flipRewards ~= 0 then
        local item4 = self:createItemFanpaiReward();
        self.ListView:pushBackCustomItem(item4);
    end
end

function MLCityInfo:setDescribe(next)
    self.next = next;
    local id = self.next.type;
    local sql = string.format("select * from stage_pass_condition where id=%d", id);
    local DBData = LUADB.select(sql, "id:desc");

    local DBData1 = nil;
    local str = MG_TEXT("MainLineLayer_1");
    if id == 1 then
        DBData1 = LUADB.select(string.format("select * from soldier_list where id=%d", self.next.value), "id:name");
        str = string.format(DBData.info.desc,DBData1.info.name,self.next.needValue);
    elseif id == 2 then
        str = string.format(DBData.info.desc,MG_TEXT("sex_"..self.next.value),self.next.needValue);
    elseif id == 4 then
        DBData1 = LUADB.select(string.format("select * from quality where id=%d", self.next.value), "id:desc");
        str = string.format(DBData.info.desc,DBData1.info.desc,self.next.needValue);
    elseif id == 5 then
        str = string.format(DBData.info.desc,self.next.needValue);
    elseif id == 3 or id == 6 or id == 7 or id == 8 or id == 9 or id == 10 or id == 11 or id == 12 or id == 13 then
        str = string.format(DBData.info.desc,self.next.value,self.next.needValue);
    elseif id == 14 then
        str = string.format(DBData.info.desc,MG_TEXT("hero_type_"..self.next.value),self.next.needValue);
    elseif id == 15 then
        DBData1 = LUADB.select(string.format("select * from general_list where id=%d", self.next.needValue), "id:name");
        str = string.format(DBData.info.desc,DBData1.info.name);
    end
    
    return str;
end

function MLCityInfo:createItemFront()
    local layout = ccui.Layout:create();
    layout:setSize(cc.size(self.ListView:getContentSize().width, 200));
    -- layout:setBackGroundColorType(1);
    -- layout:setBackGroundColor(cc.c3b(0,255,250));

    local posY = 0;
    local height = 0;
    local str = "";
    --标题
    local titleSpr = cc.Sprite:createWithSpriteFrameName("checkpoint_front_line.png");
    posY = layout:getContentSize().height-20;
    titleSpr:setPosition(cc.p(layout:getContentSize().width/2, posY));
    layout:addChild(titleSpr);

    --背景框
    local boxImg = ccui.ImageView:create("common_two_box.png", ccui.TextureResType.plistType);
    boxImg:setScale9Enabled(true);
    boxImg:setCapInsets(cc.rect(73, 52, 1, 1));
    boxImg:setSize(cc.size(536, 150));
    posY = posY-titleSpr:getContentSize().height/2-boxImg:getContentSize().height/2-10;
    boxImg:setPosition(cc.p(layout:getContentSize().width/2, posY));
    layout:addChild(boxImg,1);

    self.cityInfos = {};
    for i=1,#self.nexts do
        str = i.."."..self.checkpointList[self.nexts[i].nextId].name;
        local cityName = cc.Label:createWithTTF(str, ttf_msyh, 22);
        cityName:setAnchorPoint(cc.p(0,1));
        cityName:setColor(cc.c3b(190,170,100));
        cityName:setPositionX(10);
        boxImg:addChild(cityName);

        str = self:setDescribe(self.nexts[i]);
        local descLabel = cc.Label:createWithTTF(str,ttf_msyh,22);
        descLabel:setAlignment(cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_TOP);
        descLabel:setDimensions(520, 0);
        descLabel:setAnchorPoint(cc.p(0, 1));
        descLabel:setPositionX(10);
        boxImg:addChild(descLabel);
        table.insert(self.cityInfos,{name=cityName,desc=descLabel});
    end


    for i=1,#self.cityInfos do
        height=height+self.cityInfos[i].name:getContentSize().height+self.cityInfos[i].desc:getContentSize().height+20
    end
    if height < 150 then
        height = 150;
    end
    boxImg:setSize(cc.size(536, height));

    local h = height-10;
    for i=1,#self.cityInfos do
        if i > 1 then
            h = h-self.cityInfos[i-1].desc:getContentSize().height-10;
        end
        self.cityInfos[i].name:setPositionY(h);
        h = h-self.cityInfos[i].name:getContentSize().height-10;
        self.cityInfos[i].desc:setPositionY(h);
    end

    height = height+titleSpr:getContentSize().height+30;
    layout:setSize(cc.size(self.ListView:getContentSize().width, height));

    posY = height-20;
    titleSpr:setPosition(cc.p(layout:getContentSize().width/2, posY));

    posY = posY-titleSpr:getContentSize().height/2-boxImg:getContentSize().height/2-10;
    boxImg:setPosition(cc.p(layout:getContentSize().width/2, posY));

    return layout;
end

function MLCityInfo:createItemEnemy()
    local layout = ccui.Layout:create();
    layout:setSize(cc.size(self.ListView:getContentSize().width, 200));

    local posY = 0;
    local height = 0;
    local str = "";
    --标题
    local titleSpr = cc.Sprite:createWithSpriteFrameName("checkpoint_enemy_line.png");
    posY = layout:getContentSize().height-20;
    titleSpr:setPosition(cc.p(layout:getContentSize().width/2, posY));
    layout:addChild(titleSpr);

    --背景框
    local boxImg = ccui.ImageView:create("common_two_box.png", ccui.TextureResType.plistType);
    boxImg:setScale9Enabled(true);
    boxImg:setCapInsets(cc.rect(73, 52, 1, 1));
    boxImg:setSize(cc.size(536, 150));
    posY = posY-titleSpr:getContentSize().height/2-boxImg:getContentSize().height/2-10;
    boxImg:setPosition(cc.p(layout:getContentSize().width/2, posY));
    layout:addChild(boxImg,1);

    self.enemyInfos = {};
    for i=1,#self.npcDatas do
        local sql = string.format("select * from npc where id=%d",self.npcDatas[i].npc_id);
        local DBData = LUADB.select(sql, "name:lv:star:soldier_id");

        str = DBData.info.name;
        local heroName = cc.Label:createWithTTF(str, ttf_msyh, 22);
        heroName:setAnchorPoint(cc.p(0,1));
        heroName:setColor(cc.c3b(0,180,240));
        heroName:setPositionX(10);
        boxImg:addChild(heroName);

        str = DBData.info.lv;
        local levelLabel = cc.Label:createWithTTF("100级", ttf_msyh, 22);
        levelLabel:setAnchorPoint(cc.p(0,1));
        levelLabel:setColor(cc.c3b(0,180,240));
        levelLabel:setPositionX(185);
        boxImg:addChild(levelLabel);

        local stars = {};
        for i=1,tonumber(DBData.info.star) do
            local starSpr = cc.Sprite:createWithSpriteFrameName("com_big_star.png");
            starSpr:setAnchorPoint(cc.p(0,0.5));
            starSpr:setScale(0.7);
            starSpr:setPosition(cc.p(265+(i-1)*30,-10));
            layout:addChild(starSpr,1);
            table.insert(stars,starSpr);
        end

        sql = string.format("select * from soldier_list where id=%d",DBData.info.soldier_id);
        DBData = LUADB.select(sql, "name");

        str = DBData.info.name;
        local nameLabel = cc.Label:createWithTTF(str, ttf_msyh, 22);
        nameLabel:setAnchorPoint(cc.p(0,1));
        nameLabel:setColor(cc.c3b(0,180,240));
        nameLabel:setPositionX(430);
        boxImg:addChild(nameLabel);


        table.insert(self.enemyInfos,{heroName=heroName,levelLabel=levelLabel,stars=stars,nameLabel=nameLabel});
    end

    height=height+self.enemyInfos[1].heroName:getContentSize().height*(#self.enemyInfos)+(#self.enemyInfos)*10;
    if height < 150 then
        height = 150;
    end
    boxImg:setSize(cc.size(536, height));

    local h = height-10;
    for i=1,#self.enemyInfos do
        if i > 1 then
            h = h-self.enemyInfos[i-1].heroName:getContentSize().height-10;
        end
        self.enemyInfos[i].heroName:setPositionY(h);
        self.enemyInfos[i].levelLabel:setPositionY(h);
        self.enemyInfos[i].nameLabel:setPositionY(h);

        for j=1,#self.enemyInfos[i].stars do
            self.enemyInfos[i].stars[j]:setPositionY(h+5);
        end
    end

    height = height+titleSpr:getContentSize().height+30;
    layout:setSize(cc.size(self.ListView:getContentSize().width, height));

    posY = height-20;
    titleSpr:setPosition(cc.p(layout:getContentSize().width/2, posY));

    posY = posY-titleSpr:getContentSize().height/2-boxImg:getContentSize().height/2-10;
    boxImg:setPosition(cc.p(layout:getContentSize().width/2, posY));

    return layout;
end

function MLCityInfo:createItemReward()
    local layout = ccui.Layout:create();
    layout:setSize(cc.size(self.ListView:getContentSize().width, 160));

    local posY = 0;
    local height = 0;
    --标题
    local titleSpr = cc.Sprite:createWithSpriteFrameName("checkpoint_reward_line.png");
    posY = layout:getContentSize().height-20;
    titleSpr:setPosition(cc.p(layout:getContentSize().width/2, posY));
    layout:addChild(titleSpr);

    --创建listView
    local list = ccui.ListView:create();
    list:setDirection(ccui.ScrollViewDir.horizontal);
    list:setBounceEnabled(false);
    list:setAnchorPoint(cc.p(0,1));
    list:setSize(cc.size(self.ListView:getContentSize().width, 110));
    list:setScrollBarVisible(false);
    posY = posY-titleSpr:getContentSize().height/2-10;
    list:setPosition(cc.p(0, posY));
    layout:addChild(list);

    list:removeAllItems();
    for i=1,#self.reward_shows do
        local item = resItem.create();
        item:setData(self.reward_shows[i].type,self.reward_shows[i].Id);
        -- item:setShowTip(false);
        list:pushBackCustomItem(item);
    end

    return layout;
end

function MLCityInfo:createItemFanpaiReward()
    local layout = ccui.Layout:create();
    layout:setSize(cc.size(self.ListView:getContentSize().width, 160));

    local posY = 0;
    local height = 0;
    --标题
    local titleSpr = cc.Sprite:createWithSpriteFrameName("checkpoint_fanpai_line.png");
    posY = layout:getContentSize().height-20;
    titleSpr:setPosition(cc.p(layout:getContentSize().width/2, posY));
    layout:addChild(titleSpr);

    --创建listView
    local list = ccui.ListView:create();
    list:setDirection(ccui.ScrollViewDir.horizontal);
    list:setBounceEnabled(false);
    list:setAnchorPoint(cc.p(0,1));
    list:setSize(cc.size(self.ListView:getContentSize().width, 110));
    list:setScrollBarVisible(false);
    posY = posY-titleSpr:getContentSize().height/2-10;
    list:setPosition(cc.p(0, posY));
    layout:addChild(list);


    list:removeAllItems();
    for i=1,#self.flipRewards do
        local item = resItem.create();
        item:setData(self.flipRewards[i].type,self.flipRewards[i].Id);
        item:setShowTip(false);
        list:pushBackCustomItem(item);
    end

    return layout;
end

function MLCityInfo:onButtonClick(sender, eventType)
    if sender == self.Button_close then
        buttonClickScale(sender, eventType);
    end

    if eventType == ccui.TouchEventType.ended then
        self:removeFromParent();
    end
end

function MLCityInfo:onEnter()

end

function MLCityInfo:onExit()
    MGRCManager:releaseResources("MLCityInfo");
end

function MLCityInfo.create()
    local layer = MLCityInfo:new()
    layer:init()
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

function MLCityInfo.showBox()
    local layer = MLCityInfo.create();
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
