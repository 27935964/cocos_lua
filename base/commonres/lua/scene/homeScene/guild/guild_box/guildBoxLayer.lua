-----------------------公会战争作坊界面------------------------
require "guildBoxItem"
require "guildBoxObtain"

guildBoxLayer = class("guildBoxLayer", MGLayer)

function guildBoxLayer:ctor()
    self.curItem = nil;
    self:init();
end

function guildBoxLayer:init()
    MGRCManager:cacheResource("guildBoxLayer", "guild_box_bg.png");
    MGRCManager:cacheResource("guildBoxLayer", "guild_box_ui.png", "guild_box_ui.plist");
    local pWidget = MGRCManager:widgetFromJsonFile("guildBoxLayer","WarWorkshopUi_1.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);

    self.pPanelTop = PanelTop.create(self)
    self.pPanelTop:setData("guild_box_title_3.png");
    self:addChild(self.pPanelTop,10);
    self.pPanelTop:showRankCoin(true);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:setAnchorPoint(cc.p(0.5, 0.5));
    CommonMethod:setFullBgScale(self.Panel_1);

    local Panel_2 = pWidget:getChildByName("Panel_2");

    self.ListView_1 = Panel_2:getChildByName("ListView_1");
    self.ListView_1:setScrollBarVisible(false);

    self.ListView_2 = Panel_2:getChildByName("ListView_2");
    self.ListView_2:setScrollBarVisible(false);
    
    self.ListView_3 = Panel_2:getChildByName("ListView_3");
    self.ListView_3:setScrollBarVisible(false);

    self.extraction = Panel_2:getChildByName("Button_LotteryDraw");--抽取
    self.extraction:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_get = Panel_2:getChildByName("Button_GetRareTreasure");--获得秘宝
    self.Button_get:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_GetExploit = Panel_2:getChildByName("Button_GetExploit");--获得功勋
    self.Button_GetExploit:addTouchEventListener(handler(self,self.onButtonClick));

    self.Image_box = Panel_2:getChildByName("Image_box");
    self.posY = self.Image_box:getPositionY();
    self.Label_Exploit = Panel_2:getChildByName("Label_Exploit");

    local Label_4 = Panel_2:getChildByName("Label_4");
    Label_4:setText(MG_TEXT_COCOS("WarWorkshopUi_1_1"));

    local Label_LotteryDraw = self.extraction:getChildByName("Label_LotteryDraw");
    Label_LotteryDraw:setText(MG_TEXT_COCOS("WarWorkshopUi_1_2"));

    local Label_GetRareTreasure = self.Button_get:getChildByName("Label_GetRareTreasure");
    Label_GetRareTreasure:setText(MG_TEXT_COCOS("WarWorkshopUi_1_3"));

    local Label_GetExploit = self.Button_GetExploit:getChildByName("Label_GetExploit");
    Label_GetExploit:setText(MG_TEXT_COCOS("WarWorkshopUi_1_4"));

    local sql = string.format("select value from config where id=117");
    local DBData = LUADB.select(sql, "value");
    self.value = tonumber(DBData.info.value);

    self:readSql()--解析数据库数据
end

function guildBoxLayer:readSql()--解析数据库数据
    self.union_box = {};
    local sql = string.format("select * from union_box");
    local DBDataList = LUADB.selectlist(sql, "id:name:pic:quality:is_need_box");
    table.sort(DBDataList.info,function(a,b) return a.id < b.id; end);

    for index=1,#DBDataList.info do
        local DBData = {};
        DBData.id = tonumber(DBDataList.info[index].id);
        DBData.name = DBDataList.info[index].name;
        DBData.pic = DBDataList.info[index].pic;
        DBData.quality = tonumber(DBDataList.info[index].quality);
        DBData.is_need_box = tonumber(DBDataList.info[index].is_need_box);

        self.union_box[DBData.id]=DBData;
    end
end

function guildBoxLayer:setData(data)
    self.data = data;

    self.Label_Exploit:setText(string.format("%d/%d",self.value,tonumber(self.data.my_feats)));
    self.pPanelTop:setRankCoin(tonumber(self.data.my_feats));
    self.Image_box:setVisible(false);
end

function guildBoxLayer:updataData(data)
    self.boxinfo = data;
    self:creatItem();
    self:createLogItem();
end

function guildBoxLayer:creatItem()
    self.ListView_1:removeAllItems();
    local itemLay = ccui.Layout:create();
    itemLay:setSize(cc.size(self.ListView_1:getContentSize().width, self.ListView_1:getContentSize().height));
    if #self.union_box > 5 then
        itemLay:setSize(cc.size(#self.union_box*150, self.ListView_1:getContentSize().height));
    end
    self.ListView_1:pushBackCustomItem(itemLay);

    self.items = {};
    for i=1,#self.union_box do
        local item = guildBoxItem.create(self);
        item:setData(21,self.union_box[i].id);
        
        itemLay:addChild(item);
        item:setPosition(cc.p(item:getContentSize().width/2+(i-1)*(item:getContentSize().width+40),itemLay:getContentSize().height/2));
        table.insert(self.items,item);

        for j=1,#self.boxinfo.union_box do
            if self.union_box[i].id == tonumber(self.boxinfo.union_box[j].b_id) then
                item:setNum(5);
                break;
            end
        end
        if self.union_box[i].id == 1 then
            item:numHide();
            -- item:setSel(true);
            self.curItem = item;
        end
    end

    if #self.items <= 5 and #self.items > 0 then
        local pos = getItemPositionX(self.items,itemLay:getContentSize().width/2,40);
        for i=1,#self.items do
            self.items[i]:setPositionX(pos[i]);
        end
    end
end

function guildBoxLayer:drawAnimation(data)
    self.getbox = data;

    self.totalNum = #self.items*2+tonumber(self.getbox.b_id);
    local itemIndex = 1
    local function loadEachItem(dt)
        if itemIndex > self.totalNum then
            self:runBoxAction();
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
        else
            local remainder = 1;
            if math.mod(itemIndex,#self.items) == 0 then--整除
                remainder = #self.items;
            else
                remainder = math.mod(itemIndex,#self.items);
            end
            
            self:setSel(remainder);
            itemIndex = itemIndex+1;
            
        end
    end

    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
    end
    self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(loadEachItem, 0.1, false);
end

function guildBoxLayer:setSel(tag)
    self.curItem:setSel(false);
    self.items[tag]:setSel(true);
    self.curItem = self.items[tag];
end

function guildBoxLayer:runBoxAction()
    MGRCManager:cacheResource("guildBoxLayer", string.format("union_box%d.png",tonumber(self.getbox.b_id)));
    self.Image_box:loadTexture(string.format("union_box%d.png",tonumber(self.getbox.b_id)),ccui.TextureResType.plistType);
    self.Image_box:setVisible(true);
    self.Image_box:setVisible(true);
    self.Image_box:setPositionY(self.posY + 400);
    local function callFunc()
        self:createRewardItem();
    end
    local function remove()
        self.ListView_3:removeAllItems();
        self.Image_box:setVisible(false);
    end
    local moveTo = cc.MoveTo:create(0.1, cc.p(self.Image_box:getPositionX(),self.posY));
    local func = cc.CallFunc:create(callFunc);
    local func1 = cc.CallFunc:create(remove);
    local delayTime=cc.DelayTime:create(0.5);
    local delayTime1=cc.DelayTime:create(1.5);
    self.Image_box:runAction(cc.Sequence:create(moveTo,delayTime,func,delayTime1,func1));
end

function guildBoxLayer:createRewardItem()
    self.get_item = getDataList(self.getbox.get_item);
    self.ListView_3:removeAllItems();
    for i=1,#self.get_item do
        local item = resItem.create(self);
        item:setData(self.get_item[i].value1,self.get_item[i].value2,self.get_item[i].value3);
        self.ListView_3:pushBackCustomItem(item);
    end
end

function guildBoxLayer:createLogItem()
    self.new_get = self.boxinfo.new_get;
    self.ListView_2:removeAllItems();
    for i=1,#self.new_get do
        local layout = ccui.Layout:create();
        layout:setAnchorPoint(cc.p(0.5,0.5));
        layout:setSize(cc.size(self.ListView_2:getContentSize().width, 30));

        layout:setBackGroundColorType(1);
        layout:setBackGroundColor(cc.c3b(0,255,250));

        local descLabel = MGColorLabel:label();
        descLabel:setAnchorPoint(cc.p(0, 0.5));
        descLabel:setPosition(cc.p(17, layout:getContentSize().height/2));
        layout:addChild(descLabel);

        local str_list = spliteStr(self.new_get[i],':');
        local itemInfo = itemInfo(21,tonumber(str_list[2]));
        local str = getColorTitle(itemInfo.name,itemInfo.quality);
        local str1 = string.format(MG_TEXT("guildBoxLayer_1"),unicode_to_utf8(str_list[1]),str);
        
        descLabel:clear();
        descLabel:appendStringAutoWrap(str1,14,1,cc.c3b(255,255,255),22);

        layout:setSize(cc.size(self.ListView_2:getContentSize().width, descLabel:getContentSize().height));
        descLabel:setPosition(cc.p(17, layout:getContentSize().height/2));

        self.ListView_2:pushBackCustomItem(layout);
    end
end

function guildBoxLayer:back()
    self:removeFromParent();
end

function guildBoxLayer:onButtonClick(sender, eventType)
    if sender == self.extraction then
        buttonClickScale(sender, eventType);
    end
    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_get then--获得秘宝
            local guildBoxObtain = guildBoxObtain:showBox(self);
            guildBoxObtain:setData(1);
            guildBoxObtain:setTitle("guild_box_title_2.png");
        elseif sender == self.Button_GetExploit then--获得功勋
            local guildBoxObtain = guildBoxObtain:showBox(self);
            guildBoxObtain:setData(2);
            guildBoxObtain:setTitle("guild_box_title_1.png");
        elseif sender == self.extraction then--抽取
            NetHandler:sendData(Post_Union_Box_getBox, "");
        end
    end
end

function guildBoxLayer:onReciveData(MsgID, NetData)
    print("guildBoxLayer onReciveData MsgID:"..MsgID)

    if MsgID == Post_Union_Box_getBoxInfo then
        if NetData.state == 1 then
            self:updataData(NetData.getboxinfo);
        else
            NetHandler:showFailedMessage(NetData);
        end
    elseif MsgID == Post_Union_Box_getBox then
        if NetData.state == 1 then
            self:drawAnimation(NetData.getbox);
            self.pPanelTop:upData();
            if self.delegate and self.delegate.updataMoney then
                self.delegate:updataMoney();
            end
        else
            NetHandler:showFailedMessage(NetData);
        end
    end
end

function guildBoxLayer:sendReq()
    local str = "&id="..tonumber(self.data.union_id);
    NetHandler:sendData(Post_Union_Box_getBox, str);
end

function guildBoxLayer:pushAck()
    NetHandler:addAckCode(self,Post_Union_Box_getBoxInfo);
    NetHandler:addAckCode(self,Post_Union_Box_getBox);
end

function guildBoxLayer:popAck()
    NetHandler:delAckCode(self,Post_Union_Box_getBoxInfo);
    NetHandler:delAckCode(self,Post_Union_Box_getBox);
end

function guildBoxLayer:onEnter()
    self:pushAck();
    NetHandler:sendData(Post_Union_Box_getBoxInfo, "");
end

function guildBoxLayer:onExit()
    self:popAck();
    MGRCManager:releaseResources("guildBoxLayer");
    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
    end
end

function guildBoxLayer.create(delegate)
    local layer = guildBoxLayer:new()
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

function guildBoxLayer.showBox(delegate)
    local layer = guildBoxLayer.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
