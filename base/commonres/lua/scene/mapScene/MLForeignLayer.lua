------------------------外交------------------------
require "Item"
require "fanPaiLayer"

MLForeignLayer = class("MLForeignLayer", MGLayer)

function MLForeignLayer:ctor()
    self:init();
end

function MLForeignLayer:init()
    MGRCManager:cacheResource("MLForeignLayer", "package_bg.jpg");
    MGRCManager:cacheResource("MLForeignLayer", "foreign_ui.png","foreign_ui.plist");
    local pWidget = MGRCManager:widgetFromJsonFile("MLForeignLayer","foreign_ui.ExportJson");
    self:addChild(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    local Panel_2 = pWidget:getChildByName("Panel_2");
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));

    self.Image_general = Panel_2:getChildByName("Image_general");--武将图
    local Panel_center = Panel_2:getChildByName("Panel_center");
    self.Label_name = Panel_center:getChildByName("Label_name");
    self.Label_lv = Panel_center:getChildByName("Label_lv");

    local Label_deb = Panel_center:getChildByName("Label_deb");--碎片数量
    Label_deb:setVisible(false);
    self.debNum = MGColorLabel:label();
    self.debNum:setAnchorPoint(cc.p(0, 0.5));
    self.debNum:setPosition(Label_deb:getPosition());
    Panel_center:addChild(self.debNum);

    self.Label_power = Panel_center:getChildByName("Label_power");
    self.Label_lead = Panel_center:getChildByName("Label_lead");
    self.Label_kno = Panel_center:getChildByName("Label_kno");

    self.stars = {};
    for i=1,5 do
        local Image_star = Panel_center:getChildByName("Image_star"..i);
        -- Image_star:setVisible(false)
        table.insert(self.stars,Image_star);
    end


    local Panel_right = Panel_2:getChildByName("Panel_right");
    self.Label_desc1 = Panel_right:getChildByName("Label_desc1");
    self.Label_desc1:setVisible(false);

    local Label_num2 = Panel_right:getChildByName("Label_num2");
    Label_num2:setVisible(false);
    self.numLabel = MGColorLabel:label();
    self.numLabel:setAnchorPoint(cc.p(0, 0.5));
    self.numLabel:setPosition(Label_num2:getPosition());
    Panel_right:addChild(self.numLabel);

    local Label_num1 = Panel_right:getChildByName("Label_num1");
    Label_num1:setVisible(false);
    self.Label_num = MGColorLabel:label();
    self.Label_num:setAnchorPoint(cc.p(0, 0.5));
    self.Label_num:setPosition(self.Label_desc1:getPosition());
    Panel_right:addChild(self.Label_num);
    self.Panel_right = Panel_right;

    self.Image_foreign = Panel_right:getChildByName("Image_foreign");--外交
    self.Image_foreign:setTouchEnabled(true);
    self.Image_foreign:addTouchEventListener(handler(self,self.onButtonClick));
    self.oldHeadProgram = self.Image_foreign:getSprit():getShaderProgram();

    local Label_tip = Panel_right:getChildByName("Label_tip");
    local Label_tip_1 = Panel_right:getChildByName("Label_tip_1");
    self.Label_foreign = self.Image_foreign:getChildByName("Label_foreign");
    Label_tip:setText(MG_TEXT_COCOS("foreign_ui_1"));
    Label_tip_1:setText(MG_TEXT_COCOS("foreign_ui_2"));
    self.Label_foreign:setText(MG_TEXT_COCOS("foreign_ui_3"));
    
    self.ListView = Panel_right:getChildByName("ListView");
    self.ListView:setScrollBarVisible(false);

    self.hearts = {};
    for i=1,5 do
        local Image_heart = Panel_right:getChildByName("Image_heart"..i);
        Image_heart:setVisible(false);
        table.insert(self.hearts,Image_heart);
    end

    local Panel_5 = Panel_2:getChildByName("Panel_5");
    self.Button_close = Panel_5:getChildByName("Button_close");
    self.Button_close:addTouchEventListener(handler(self,self.onButtonClick));
end

function MLForeignLayer:setData(mapList,checkpointList,data)
    self.data = data;
    self.mapList = mapList;
    self.checkpointList = checkpointList;
    self.itemDatas = self.mapList.visit_reward;

    local generalId = self.mapList.visit[1].type;
    local checkpointId = self.mapList.visit[1].id;
    self.gm = GENERAL:getGeneralModel(generalId);--已获得
    self.isGet = true;
    if nil == self.gm then
        self.isGet = false;
        self.gm = GENERAL:getDBGeneralModel(generalId);--未获得
        self.Label_lv:setVisible(false);
    end

    self.Label_name:setText(self.gm:name());
    self.Label_lv:setText(string.format("Lv.%d",self.gm:getLevel()));
    self.Label_lv:setPositionX(self.Label_name:getPositionX()+self.Label_name:getContentSize().width+20);
    self.Label_power:setText(self.gm:getPower());
    self.Label_lead:setText(self.gm:getCommand());
    self.Label_kno:setText(self.gm:getStrategy());
    MGRCManager:cacheResource("MLForeignLayer",self.gm:pic());
    self.Image_general:loadTexture(self.gm:pic(),ccui.TextureResType.plistType);
    self.Image_general:setScale(0.8);
    for i=1,self.gm:getStar() do
        self.stars[i]:setVisible(true);
    end
    local resNum, totNum = getGeneralNeedDebrisNum(self.gm,self.isGet);
    self.debNum:clear();
    if self.isGet == true then--已获得的武将
        if self.gm:getStar() < ME:getMaxStar() then--未满星
            if resNum < totNum then
                self.debNum:appendStringAutoWrap(string.format("<c=255,000,000>%d</c>/%d",resNum,totNum),18,1,cc.c3b(255,255,255),22);
            else
                self.debNum:appendStringAutoWrap(string.format("%d/%d",resNum,totNum),18,1,cc.c3b(255,255,255),22);
            end
        else
            self.debNum:appendStringAutoWrap(string.format("%d",resNum),18,1,cc.c3b(255,255,255),22);
        end
    elseif self.isGet == false then--未获得的武将
        if resNum < totNum then
            self.debNum:appendStringAutoWrap(string.format("<c=255,000,000>%d</c>/%d",resNum,totNum),18,1,cc.c3b(255,255,255),22);
        else
            self.debNum:appendStringAutoWrap(string.format("%d/%d",resNum,totNum),18,1,cc.c3b(255,255,255),22);
        end
    end

    local str = "";
    str = string.format(MG_TEXT("ML_MLForeignLayer_1"),self.mapList.name,self.checkpointList[checkpointId].name);
    self.Label_num:clear();
    if tonumber(self.data.visit_status) == 0 then
        self.Label_num:appendStringAutoWrap(string.format("%s  <c=255,000,000>%d</c>/%d",str,0,1),16,1,cc.c3b(255,255,255),22);
    elseif tonumber(self.data.visit_status) == 1 then
        self.Label_num:appendStringAutoWrap(string.format("%s  <c=000,255,000>%s</c>",str,MG_TEXT("complete")),16,1,cc.c3b(255,255,255),22);
    end

    local sql = "select * from config where id=31";
    local DBData = LUADB.select(sql, "value");
    local values = getneedlist(DBData.info.value);
    totNum = values[1].num;
    local resInfo = RESOURCE:getResModelByItemId(values[1].id);
    resNum = 0;
    if resInfo then
        resNum = resInfo:getNum();
    end
    self.numLabel:clear();
    if resNum < totNum then
        self.numLabel:appendStringAutoWrap(string.format("<c=255,000,000>%d</c>/%d",resNum,totNum),18,1,cc.c3b(255,255,255),22);
    else
        self.numLabel:appendStringAutoWrap(string.format("%d/%d",resNum,totNum),18,1,cc.c3b(255,255,255),22);
    end

    if tonumber(self.data.num) >= 5 then
        self.Label_foreign:setText(MG_TEXT_COCOS("foreign_ui_4"));
    else
        self.Label_foreign:setText(MG_TEXT_COCOS("foreign_ui_3"));
    end

    if tonumber(self.data.visit_status) == 0 then
        self:setBtnGray(false);
    elseif tonumber(self.data.visit_status) == 1 then
        self:setBtnGray(true);
    end

    for i=1,#self.hearts do
        self.hearts[i]:setVisible(false);
        if i <= tonumber(self.data.num) then
            self.hearts[i]:setVisible(true);
        end
    end
    
    self:createItem();
end

function MLForeignLayer:setBtnGray(isGray)
    if isGray == false then
        self.Image_foreign:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
        self.Label_foreign:setColor(Color3B.GRAY);
    else
        self.Image_foreign:getSprit():setShaderProgram(self.oldHeadProgram);
        self.Label_foreign:setColor(Color3B.WHITE);
    end
end

function MLForeignLayer:createItem()
    self.ListView:removeAllItems();
    local itemLay = ccui.Layout:create();
    itemLay:setSize(cc.size(self.ListView:getContentSize().width, self.ListView:getContentSize().height));
    if #self.itemDatas > 3 then
        itemLay:setSize(cc.size(#self.itemDatas*130, self.ListView:getContentSize().height));
    end
    self.ListView:pushBackCustomItem(itemLay);

    self.items = {};
    for i=1,#self.itemDatas do
        local item = resItem.create(self);
        item:setData(self.itemDatas[i].type,self.itemDatas[i].id,self.itemDatas[i].num);
        itemLay:addChild(item);
        item:setNumVisible(false);
        item:setPosition(cc.p(item:getContentSize().width/2+(i-1)*(item:getContentSize().width+20),itemLay:getContentSize().height/2));
        table.insert(self.items,item);
    end

    local average = math.ceil(#self.items/2);
    local mod = math.mod(#self.items,2);
    local posX = itemLay:getContentSize().width/2;
    if mod == 0 then
        posX = posX-self.items[1]:getContentSize().width/2-10;
        for i=1,#self.items do
            if i < average then
                self.items[i]:setPositionX(posX-(average-i)*(self.items[i]:getContentSize().width+20));
            elseif i == average then
                self.items[i]:setPositionX(posX);
            else
                self.items[i]:setPositionX(posX+(i-average)*(self.items[i]:getContentSize().width+20));
            end
        end
    elseif mod == 1 then
        for i=1,#self.items do
            if i < average then
                self.items[i]:setPositionX(posX-(average-i)*(self.items[i]:getContentSize().width+20));
            elseif i == average then
                self.items[i]:setPositionX(posX);
            else
                self.items[i]:setPositionX(posX+(i-average)*(self.items[i]:getContentSize().width+20));
            end
        end
    end
end

function MLForeignLayer:onButtonClick(sender, eventType)
    if sender == self.Button_close or sender == self.Image_foreign then
        buttonClickScale(sender, eventType);
    end

    if eventType == ccui.TouchEventType.ended then
        if sender == self.Image_foreign then--外交
            if tonumber(self.data.num) >= 5 then
                self:reSetVisitSendReq();
            else
                self:sendReq();
            end
            
        elseif sender == self.Button_close or sender == self.Panel_1 then
            self:removeFromParent();
        end
    end
end

function MLForeignLayer:getItem(get_item)
    local itemPos = {};
    local needlist = getneedlist(get_item);
    local ceil = math.ceil(#needlist/2);
    for i=1,#needlist do
        local pos=cc.p(self.Image_foreign:getPositionX()-80+(i-ceil)*20,self.Image_foreign:getPositionY()+80);
        table.insert(itemPos,pos);
    end
    ItemJump:getInstance():showItemJump(get_item,self.Image_foreign,itemPos,0.8,true);
end

function MLForeignLayer:onReciveData(MsgID, NetData)
    print("MLForeignLayer onReciveData MsgID:"..MsgID)

    if MsgID == Post_doVisit then
        local ackData = NetData
        if ackData.state == 1 then
            self:setData(self.mapList,self.checkpointList,ackData.visitinfo);
            if ackData.getflipreward then
                local fanPai = fanPaiLayer.showBox(self);
                fanPai:setData(ackData.getflipreward);
            end
        else
            NetHandler:showFailedMessage(ackData);
        end
    elseif MsgID == Post_reSetVisit then
        local ackData = NetData
        if ackData.state == 1 then
            self:setData(self.mapList,self.checkpointList,ackData.visitinfo);
        else
            NetHandler:showFailedMessage(ackData);
        end
    end
end

function MLForeignLayer:sendReq()
    local str = string.format("&sid=%d",self.mapList.id);
    NetHandler:sendData(Post_doVisit, str);
end

function MLForeignLayer:reSetVisitSendReq()
    local str = string.format("&sid=%d",self.mapList.id);
    NetHandler:sendData(Post_reSetVisit, str);
end

function MLForeignLayer:pushAck()
    NetHandler:addAckCode(self,Post_doVisit);
    NetHandler:addAckCode(self,Post_reSetVisit);
    
end

function MLForeignLayer:popAck()
    NetHandler:delAckCode(self,Post_doVisit);
    NetHandler:delAckCode(self,Post_reSetVisit);
end

function MLForeignLayer:onEnter()
    self:pushAck();
end

function MLForeignLayer:onExit()
    MGRCManager:releaseResources("MLForeignLayer");
    self:popAck();
end

function MLForeignLayer.create(delegate)
    local layer = MLForeignLayer:new()
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

function MLForeignLayer.showBox(delegate)
    local layer = MLForeignLayer.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
