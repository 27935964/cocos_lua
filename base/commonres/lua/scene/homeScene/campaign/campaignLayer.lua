-----------------------征战主界面------------------------

campaignLayer = class("campaignLayer", MGLayer)

function campaignLayer:ctor()
    require "campaignItem";
    self.layoutWidth = 0;
    self.maxPosX = 0;
    self:init();
end

function campaignLayer:init()
    self.timer = CCTimer:new();
    local pWidget = MGRCManager:widgetFromJsonFile("campaignLayer","campaign_ui_1.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));

    self.Panel_2 = pWidget:getChildByName("Panel_2");
    self.Panel_2:addTouchEventListener(handler(self,self.onButtonClick));
    self.list = self.Panel_2:getChildByName("ListView");
    self:createlist();

    self.Image_left = self.Panel_2:getChildByName("Image_left");
    self.Image_left:setVisible(false);
    self.Image_right = self.Panel_2:getChildByName("Image_right");

    local function sliding()
        self.list:getInnerContainer():setPositionX(-self.layoutWidth);
        self.list:refreshView();
        self.maxPosX = self.list:getInnerContainer():getPositionX();
    end
    local function reSliding()
        self.list:getInnerContainer():setPositionX(0);
        self.list:refreshView();
    end
    local time = cc.DelayTime:create(0.01);
    local func = cc.CallFunc:create(sliding);
    local func1 = cc.CallFunc:create(reSliding);
    local sq = cc.Sequence:create(time,func,time,func1);
    self:runAction(sq);
    self.timer:startTimer(10,handler(self,self.updateTime),false);--每秒回调一次
end

function campaignLayer:createlist()
    self.list:removeAllItems();
    local DBDataList = LUADB.selectlist("select id,name,des,pic,reward,open_lv from campaign order by show", "id:name:des:pic:reward:open_lv");

    local itemLay = ccui.Layout:create();
    local _width = 0;
    local _hight = 0;
    for i=1,#DBDataList.info do
        local campaignItem = campaignItem.create(self);
        MGRCManager:cacheResource("campaignLayer",DBDataList.info[i].pic..".png");
        campaignItem:setData(DBDataList.info[i]);
        campaignItem:setPosition(cc.p(campaignItem:getContentSize().width/2+(campaignItem:getContentSize().width+38)*(i-1),campaignItem:getContentSize().height/2));
        itemLay:addChild(campaignItem);
        _width=campaignItem:getContentSize().width;
        _hight=campaignItem:getContentSize().height;
    end
    itemLay:setSize(cc.size((_width+83)*#DBDataList.info, _hight));
    if itemLay:getSize().width<self.list:getSize().width then
        self.list:setSize(itemLay:getSize());
        self.list:setPositionX((self.Panel_2:getSize().width - self.list:getSize().width)/2);
    end
    self.list:pushBackCustomItem(itemLay);
    self.layoutWidth = itemLay:getContentSize().width;
end

function campaignLayer:updateTime()
    if self.list:getInnerContainer():getPositionX() <= self.maxPosX+20 then
        self.Image_left:setVisible(true);
        self.Image_right:setVisible(false);
    elseif self.list:getInnerContainer():getPositionX() >= -10 then
        self.Image_left:setVisible(false);
        self.Image_right:setVisible(true);
    else
        self.Image_left:setVisible(true);
        self.Image_right:setVisible(true);
    end
end

function campaignLayer:onButtonClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        if sender == self.Panel_2  or sender == self.Panel_1 then
            self:removeFromParent();
        end
    end
end

function campaignLayer:EnterItem(item)
    self.selItemData = item.data;
    print(self.selItemData.id);
    if self.selItemData.id ==1 then
        require "arenaLayer";
        local arenaLayer = arenaLayer.showBox(self,self.scenetype);
    elseif self.selItemData.id ==2 then
        require "IslandMainLayer";
        local IslandMainLayer = IslandMainLayer.showBox(self,self.scenetype);
        IslandMainLayer:setData();
    elseif self.selItemData.id ==3 then
        require "trialMainLayer";
        local trialMainLayer = trialMainLayer.showBox(self,self.scenetype);
        trialMainLayer:setData();
    elseif self.selItemData.id ==4 then
        require "vindicatorLayer";
        local vindicatorLayer = vindicatorLayer.showBox(self,self.scenetype);
        -- vindicatorLayer:setData();
    elseif self.selItemData.id ==5 then
        require "recoverroadLayer";
        local recoverroadLayer = recoverroadLayer.showBox(self,self.scenetype);
        -- recoverroadLayer:setData();
    end
end

function campaignLayer:onEnter()

end

function campaignLayer:onExit()
    MGRCManager:releaseResources("campaignLayer");
    if self.timer~=nil then
        self.timer:stopTimer();
    end
end

function campaignLayer.create(delegate,type)
    local layer = campaignLayer:new()
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

function campaignLayer.showBox(delegate,type)
    local layer = campaignLayer.create(delegate,type);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
