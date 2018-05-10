--------------------------光复之路-----------------------

local SodierItem = require "SodierItem";
local recoverroadItem = class("recoverroadItem", MGWidget)

function recoverroadItem:init(delegate,widget)
    self.delegate=delegate;
    self:addChild(widget);
    self.pWidget = widget;

    local Panel_2 = self.pWidget:getChildByName("Panel_2");
    self:setContentSize(Panel_2:getContentSize());


    local Panel_soldiers = Panel_2:getChildByName("Panel_soldiers");
    -- self.sodierItem=SodierItem.new(self);
    -- self.sodierItem:setPosition(cc.p(70,0));
    -- self.sodierItem:setData(data.l_id,data.lv,data.name,false);
    -- self.sodierItem:setName(data.name);
    -- self.sodierItem:setSkinReverse();
    -- self.sodierItem:setData(2,57,"安德鲁亚当",false);
    -- Panel_soldiers:addChild(self.sodierItem);

    self.Label_miles = Panel_2:getChildByName("Label_miles");

    self.Image_tip_black = Panel_2:getChildByName("Image_tip_black");
    self.Image_tip_black:setVisible(false);

    self.Panel_enemy = Panel_2:getChildByName("Panel_enemy");
    self.Panel_enemy:setVisible(false);

    self.ListView = self.Panel_enemy:getChildByName("ListView");
    self.ListView:setScrollBarVisible(false);
    self.ListView:setItemsMargin(10);
    
    self.Panel_go = Panel_2:getChildByName("Panel_go");
    self.Panel_go:setVisible(false);
    self.Label_bigarrow2 = self.Panel_go:getChildByName("Label_bigarrow2");
    self.Image_bigarrow = self.Panel_go:getChildByName("Image_bigarrow");
    self.Image_bigarrow:setTouchEnabled(false);
    self.Image_bigarrow:addTouchEventListener(handler(self,self.onButtonClick));

    self.Panel_get = Panel_2:getChildByName("Panel_get");
    self.Panel_get:setVisible(false);
    self.ProgressBar = self.Panel_get:getChildByName("ProgressBar");
    self.Image_treasure_box = self.Panel_get:getChildByName("Image_treasure_box");
    self.Image_treasure_box:setTouchEnabled(false);
    self.Image_treasure_box:addTouchEventListener(handler(self,self.onButtonClick));

    self.Panel_save = Panel_2:getChildByName("Panel_save");
    self.Panel_save:setVisible(false);
    self.Image_village = self.Panel_save:getChildByName("Image_village");
    self.Image_village:setTouchEnabled(false);
    self.Image_village:addTouchEventListener(handler(self,self.onButtonClick));
    
    self.Panel_3 = self.pWidget:getChildByName("Panel_3");
    self.Panel_3:setVisible(true);
    self.Panel_3:setTouchEnabled(true);

    self.Panel_reward = self.Panel_3:getChildByName("Panel_reward");
    self.Panel_reward:setVisible(false);
    self.Image_light = self.Panel_reward:getChildByName("Image_light");
    local actionBy = cc.RotateBy:create(4, 360);
    self.Image_light:runAction(cc.RepeatForever:create(actionBy));

    self.Image_reward = self.Panel_reward:getChildByName("Image_reward");
    self.Image_reward:setTouchEnabled(false);
    self.Image_reward:addTouchEventListener(handler(self,self.onButtonClick));

    -- self.tipLabel = MGColorLabel:label();
    -- self.tipLabel:setAnchorPoint(cc.p(0, 1));
    -- self.tipLabel:setPosition(cc.p(self.Panel_3:getContentSize().width/2, self.Panel_3:getContentSize().height/2));
    -- self.Panel_3:addChild(self.tipLabel);

    -- self.tipLabel:clear();
    -- local str = "未解锁";
    -- self.tipLabel:appendStringAutoWrap(str,21,1,cc.c3b(255,255,255),22);
end

function recoverroadItem:readSql(id,mileage)--解析数据库数据
    self.loadInfo = {};
    local sql = string.format("select * from load_stage where l_id=%d and mileage=%d", id,mileage);
    local DBData = LUADB.select(sql, "l_id:mileage:has_npc:flip_id:box_reward:box_num:is_double");

    self.loadInfo.l_id = tonumber(DBData.info.l_id);
    self.loadInfo.mileage = tonumber(DBData.info.mileage);
    self.loadInfo.has_npc = tonumber(DBData.info.has_npc);
    self.loadInfo.flip_id = tonumber(DBData.info.flip_id);
    self.loadInfo.box_num = tonumber(DBData.info.box_num);
    self.loadInfo.is_double = tonumber(DBData.info.is_double);
    self.loadInfo.box_reward = getDataList(DBData.info.box_reward);


    self.npcInfoList = {};
    local sql1 = string.format("select * from load_npc where l_id=%d and mileage=%d", id,mileage);
    local DBDataList = LUADB.selectlist(sql1, "sort:l_id:mileage:name:score:lv:head:head_quality:corps");

    for index=1,#DBDataList.info do
        local DBData = {};
        DBData.sort         = tonumber(DBDataList.info[index].sort);
        DBData.l_id         = tonumber(DBDataList.info[index].l_id);
        DBData.mileage      = tonumber(DBDataList.info[index].mileage);
        DBData.name         = DBDataList.info[index].name;
        DBData.score        = tonumber(DBDataList.info[index].score);
        DBData.lv           = tonumber(DBDataList.info[index].lv);
        DBData.head         = DBDataList.info[index].head..".png";
        DBData.head_quality = tonumber(DBDataList.info[index].head_quality);
        DBData.corps        = getDataList(DBDataList.info[index].corps);

        table.insert(self.npcInfoList,DBData);
    end

end

function recoverroadItem:readSqlReward(loadId,getMileage)--解析数据库数据
    self.rewardInfo = {};
    local sql = string.format("select * from load_mileage_reward where l_id=%d and mileage>%d order by mileage asc limit 1",loadId,getMileage);
    local DBData = LUADB.select(sql, "l_id:mileage:reward");

    self.rewardInfo.l_id = tonumber(DBData.info.l_id);
    self.rewardInfo.mileage = tonumber(DBData.info.mileage);
    self.rewardInfo.reward = getDataList(DBData.info.reward);

end

function recoverroadItem:setData(data)
    self.data = data;
    self:readSql(tonumber(self.data.lid),tonumber(self.data.mileage));

    self.Label_miles:setText(string.format(MG_TEXT("recoverroadLayer_3"),tonumber(self.data.mileage)));
    if tonumber(self.data.day_reward) == 0 or tonumber(self.data.mileage) <= 0 then--1可领取 0已领取
        self.Panel_3:setVisible(false);
        self.Panel_3:setTouchEnabled(false);
        self.Panel_reward:setVisible(false);
        self.Image_reward:setTouchEnabled(false);
    elseif tonumber(self.data.day_reward) == 1 then
        self.Panel_3:setVisible(true);
        self.Panel_3:setTouchEnabled(true);
        self.Panel_reward:setVisible(true);
        self.Image_reward:setTouchEnabled(true);
    end

    if tonumber(self.data.is_next) == 0 then--0 or 1 是否行进下一里程
        if self.loadInfo.has_npc == 1 then
            self:setLoadState(1);
            self:createSoldier();
        elseif self.loadInfo.flip_id > 0 then--翻牌事件
            self:setLoadState(5);
        elseif #self.loadInfo.box_reward > 0 then--宝箱事件
            self:setLoadState(4);
        end
    elseif tonumber(self.data.is_next) == 1 then
        self:readSqlReward(tonumber(self.data.lid),tonumber(self.data.mileage));
        self:setLoadState(2);
        local disMileage = self.rewardInfo.mileage - tonumber(self.data.mileage);
        self.Label_bigarrow2:setText(string.format(MG_TEXT("recoverroadLayer_7"),disMileage));
    end

    self.ProgressBar:setPercent(tonumber(self.data.box_num)*100/self.loadInfo.box_num);
    if tonumber(self.data.box_num) == 0 then
        self.ProgressBar:setPercent(100);
    end
end

function recoverroadItem:createSoldier()
    self.ListView:removeAllItems();
    if #self.npcInfoList <= 0 then
        return;
    end

    local itemLay = ccui.Layout:create();
    itemLay:setSize(cc.size(#self.npcInfoList*200,self.ListView:getContentSize().height));
    self.ListView:pushBackCustomItem(itemLay);
    
    for i=1,#self.npcInfoList do
        local data = self.npcInfoList[i];
        local item=SodierItem.new(self);
        item:setTag(i);
        item:setPosition(cc.p(125+(i-1)*200,itemLay:getContentSize().height/4));
        item:setData(data.l_id,data.lv,data.name,false);
        item:setName(data.name);
        item:setSkinReverse();
        item:setTouch(true,1);
        itemLay:addChild(item);
    end
end

function recoverroadItem:onSelect(item)
    if self.delegate and self.delegate.openEnemyInfo then
        self.delegate:openEnemyInfo(self.npcInfoList[item:getTag()]);
    end
end

function recoverroadItem:setLoadState(loadType)
    self.Panel_enemy:setVisible(false);

    self.Panel_go:setVisible(false);
    self.Image_bigarrow:setTouchEnabled(false);

    self.Image_tip_black:setVisible(false);

    self.Panel_get:setVisible(false);
    self.Image_treasure_box:setTouchEnabled(false);

    self.Panel_save:setVisible(false);
    self.Image_village:setTouchEnabled(false);

    self.ListView:removeAllItems();
    if loadType == 1 then--显示敌军事件
        self.Panel_enemy:setVisible(true);
    elseif loadType == 2 then--显示前往
        self.Panel_go:setVisible(true);
        self.Image_bigarrow:setTouchEnabled(true);
    elseif loadType == 3 then--显示已到达最大里程
        self.Image_tip_black:setVisible(true);
    elseif loadType == 4 then--显示宝箱事件
        self.Panel_get:setVisible(true);
        self.Image_treasure_box:setTouchEnabled(true);
    elseif loadType == 5 then--显示解救事件
        self.Panel_save:setVisible(true);
        self.Image_village:setTouchEnabled(true);
    end
end

function recoverroadItem:onButtonClick(sender, eventType)
    if sender == self.Image_bigarrow then
        buttonClickScale(sender, eventType);
    end

    if eventType == ccui.TouchEventType.ended then
        if sender == self.Image_bigarrow then--继续
            if self.delegate and self.delegate.moveSendReq then
                self.delegate:moveSendReq(self);
            end
        elseif sender == self.Image_treasure_box then--宝箱领取
            if self.delegate and self.delegate.boxRewardSendReq then
                self.delegate:boxRewardSendReq(self);
            end
        elseif sender == self.Image_village then--解救 翻牌
            if self.delegate and self.delegate.flipRewardSendReq then
                self.delegate:flipRewardSendReq(self);
            end
        elseif sender == self.Image_reward then--每日奖励
            if self.delegate and self.delegate.dayRewardSendReq then
                self.delegate:dayRewardSendReq(self);
            end
        end
    end
end

function recoverroadItem:onEnter()
    
end

function recoverroadItem:onExit()
    MGRCManager:releaseResources("recoverroadItem")
end

function recoverroadItem.create(delegate,widget)
    local layer = recoverroadItem:new()
    layer:init(delegate,widget)
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

return recoverroadItem