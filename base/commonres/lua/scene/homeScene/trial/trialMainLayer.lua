--------------------------试炼主界面-----------------------
require "PanelTop"
require "Item"
require "trialEntranceLayer"

trialMainLayer = class("trialMainLayer", MGLayer)

function trialMainLayer:ctor()
    self.isTouch = true;
    self.curTag = 1;
    self.centerTag = 0;
    self:init();
end

function trialMainLayer:init()
    MGRCManager:cacheResource("trialMainLayer", "trial_ui0.png", "trial_ui0.plist");
    MGRCManager:cacheResource("trialMainLayer", "trial_right_bg.png");
    MGRCManager:cacheResource("trialMainLayer", "package_bg.jpg");
    local pWidget = MGRCManager:widgetFromJsonFile("trialMainLayer","trial_main_ui.ExportJson");
    self:addChild(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);

    self.pPanelTop = PanelTop.create(self)
    self.pPanelTop:setData("trial_main_title.png");
    self:addChild(self.pPanelTop,10);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    -- self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));
    self.Panel_1:setAnchorPoint(cc.p(0.5, 0.5));
    CommonMethod:setFullBgScale(self.Panel_1);

    local Panel_2 = pWidget:getChildByName("Panel_2");
    self.Label_number = Panel_2:getChildByName("Label_number");

    self.Panel_3 = Panel_2:getChildByName("Panel_3");
    self.posX = self.Panel_3:getContentSize().width/2;

    self.ListView = Panel_2:getChildByName("ListView");
    self.ListView:setScrollBarVisible(false);

    local Label_remain = Panel_2:getChildByName("Label_remain");
    local Image_frame = Panel_2:getChildByName("Image_frame");
    local Label_title = Image_frame:getChildByName("Label_title");
    Label_remain:setText(MG_TEXT_COCOS("trial_main_ui_1"));
    Label_title:setText(MG_TEXT_COCOS("trial_main_ui_2"));

    self:readSql();
end

function trialMainLayer:readSql()
    local sql = string.format("select * from practice_stage");
    local DBDataList = LUADB.selectlist(sql, "s_id:num:open_day:need_lv:need_soldier_id:name:pic:des:reward_show");
    table.sort(DBDataList.info,function(a,b) return a.s_id < b.s_id; end);

    self.cityInfoList = {};
    local str = "";
    local str_list = {};
    local str_list1 = {};
    for i=1,#DBDataList.info do
        local DBData = {};
        DBData.s_id = tonumber(DBDataList.info[i].s_id);
        DBData.num = tonumber(DBDataList.info[i].num);
        DBData.open_day = getDataList(DBDataList.info[i].open_day);
        DBData.need_lv = tonumber(DBDataList.info[i].need_lv);
        DBData.need_soldier_id = getDataList(DBDataList.info[i].need_soldier_id);
        DBData.name = DBDataList.info[i].name;
        DBData.pic = DBDataList.info[i].pic;
        DBData.des = DBDataList.info[i].des;
        DBData.reward_show = getDataList(DBDataList.info[i].reward_show);
        table.insert(self.cityInfoList,DBData);
    end

end

function trialMainLayer:initData(data)
    self.data = data;
    table.sort(data,function(a,b) return a.s_id < b.s_id; end);
    self.Label_number:setText(string.format(MG_TEXT("trialMainLayer_1"),data.num[self.curTag].num));
end

function trialMainLayer:setData()
    self:creatBtn();
end

function trialMainLayer:creatBtn()
    self.btns = {};
    self.fileNames = {};
    for i=1,#self.cityInfoList do
        local file = self.cityInfoList[i].pic..".png";
        MGRCManager:cacheResource("trialMainLayer", file);
        local btnSp = ccui.ImageView:create(file, ccui.TextureResType.localType);
        btnSp:setAnchorPoint(cc.p(0.5,0.5));
        btnSp:setPosition(cc.p(self.Panel_3:getContentSize().width/2,self.Panel_3:getContentSize().height/2));
        btnSp:setTag(self.cityInfoList[i].s_id);
        -- btnSp:setTouchEnabled(true);
        -- btnSp:addTouchEventListener(handler(self,self.onTouchClick));
        self.Panel_3:addChild(btnSp);

        local listener = cc.EventListenerTouchOneByOne:create();
        listener:setSwallowTouches(true);
        listener:registerScriptHandler(handler(self,self.onTouchBegin),cc.Handler.EVENT_TOUCH_BEGAN);
        listener:registerScriptHandler(handler(self,self.onTouchMove),cc.Handler.EVENT_TOUCH_MOVED);
        listener:registerScriptHandler(handler(self,self.onTouchEnd),cc.Handler.EVENT_TOUCH_ENDED);
        self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener,btnSp);

        table.insert(self.btns,btnSp);
        table.insert(self.fileNames,file);
    end
    self:initBtnPosition();
end

function trialMainLayer:initBtnPosition()
    local average = math.ceil(#self.btns/2);
    self.rightPosX = self.posX+2*300;
    self.leftPosX = self.posX-2*300;
    self.btnInfos = {}
    for k,v in pairs(self.btns) do
        if k < average then
            v:setPositionX(self.posX-(average-k)*300);
        elseif k == average then
            v:setPositionX(self.posX);
            -- v:setTouchEnabled(true);
            self:creatItem(average);
        else
            v:setPositionX(self.posX+(k-average)*300);
        end

        if k <= average then
            v:setLocalZOrder(k);
            v:setScale(1-(average-k)*0.25);
            v:setOpacity(255-(average-k)*150);
        else
            v:setLocalZOrder(average-(k-average));
            v:setScale(1-(k-average)*0.25);
            v:setOpacity(255-(k-average)*150);
        end
        table.insert(self.btnInfos,{d1=v:getPositionX(),d2=v:getLocalZOrder(),d3=v:getScale(),d4=v:getOpacity()});
        
        if #self.btns > 5 then
            if v:getPositionX() > self.rightPosX or v:getPositionX() < self.leftPosX then
                v:setVisible(false);
            else
                v:setVisible(true);
            end
        end
    end

    self.curTag = average;
    self.centerTag = average;
end

function trialMainLayer:creatItem(tag)
    local reward_shows = self.cityInfoList[tag].reward_show;
    self.ListView:removeAllItems();
    local itemLay = ccui.Layout:create();
    itemLay:setSize(cc.size(self.ListView:getContentSize().width, self.ListView:getContentSize().height));
    if #reward_shows > 5 then
        itemLay:setSize(cc.size(#reward_shows*130, self.ListView:getContentSize().height));
    end
    self.ListView:pushBackCustomItem(itemLay);

    self.items = {};
    for i=1,#reward_shows do
        local item = resItem.create(self);
        item:setData(reward_shows[i].value1,reward_shows[i].value2);
        itemLay:addChild(item);
        item.numLabel:setVisible(false);
        item:setPosition(cc.p(item:getContentSize().width/2+(i-1)*(item:getContentSize().width+20),itemLay:getContentSize().height/2));
        table.insert(self.items,item);
    end

    if #self.items <= 5 then
        local pos = getItemPositionX(self.items,itemLay:getContentSize().width/2);
        for i=1,#self.items do
            self.items[i]:setPositionX(pos[i]);
        end
    end
end

function trialMainLayer:onTouchBegin(touch,event)
    -- print("-----------onTouchBegin---------------")
    if self.isTouch == false then
        return;
    end
    
    self.beginPoint = touch:getLocation();
    local target = event:getCurrentTarget();
    self.beginPoint = self.Panel_3:convertToNodeSpace(self.beginPoint);
    local locationInNode = target:convertToNodeSpace(touch:getLocation());
    local rect = cc.rect(0, 0, target:getContentSize().width, target:getContentSize().height);
    
    if cc.rectContainsPoint(rect,locationInNode) then--判断触摸点是否在目标的范围内
        return true;
    else
        return false;
    end
    return true;
end

function trialMainLayer:onTouchMove(touch,event)
    -- print("-----------onTouchMove---------------")
end

function trialMainLayer:onTouchEnd(touch,event)
    -- print("-----------onTouchEnd---------------")
    self.endPoint = touch:getLocation();
    local target = event:getCurrentTarget();
    self.endPoint = self.Panel_3:convertToNodeSpace(self.endPoint);

    local disX = self.endPoint.x - self.beginPoint.x;
    if disX >= 10 then
        self:MoveRight();
    elseif disX <= -10 then
        self:MoveLeft();
    else
        if self.endPoint.x<self.posX-self.btns[1]:getContentSize().width/2 then
            self:MoveRight();
        elseif self.endPoint.x>self.posX+self.btns[1]:getContentSize().width/2 then
            self:MoveLeft();
        else
            for i=1,#self.btns do
                if self.btns[i]:getPositionX() == self.posX then
                    self.curTag = target:getTag();
                    self:onTouchClick();
                end
            end
        end
    end
end

function trialMainLayer:MoveRight()--向右滑动
    -- print("-----------MoveRight-----------")
    self.isTouch = false;
    local tempPosX = self.btns[1]:getPositionX();
    local tempScale = self.btns[1]:getScale();
    local tempLocalZOrder = self.btns[1]:getLocalZOrder();
    local tempOpacity = self.btns[1]:getOpacity();
    for i=1,#self.btns do
        if i < #self.btns then--重置位置
            local moveBy = cc.MoveTo:create(0.2, cc.p(self.btns[i+1]:getPositionX(),self.Panel_3:getContentSize().height/2));
            local actionTo = cc.ScaleTo:create(0.2,self.btns[i+1]:getScale());
            self.btns[i]:runAction(cc.Sequence:create(moveBy,actionTo));
            self.btns[i]:setLocalZOrder(self.btns[i+1]:getLocalZOrder());
            self.btns[i]:setOpacity(self.btns[i+1]:getOpacity());

            if self.btns[i+1]:getPositionX() == self.posX then
                self.centerTag = self.btns[i]:getTag();
            end
        else
            local moveBy = cc.MoveTo:create(0.2, cc.p(tempPosX,self.Panel_3:getContentSize().height/2));
            local actionTo = cc.ScaleTo:create(0.2,tempScale);
            -- local spawn = cc.Spawn:create(moveBy,actionTo);
            -- local delayTime = cc.DelayTime:create(0.05);
            local function setTouch()
                self.isTouch = true;
            end
            local func = cc.CallFunc:create(setTouch);
            self.btns[i]:runAction(cc.Sequence:create(moveBy,actionTo,func));
            self.btns[i]:setLocalZOrder(tempLocalZOrder);
            self.btns[i]:setOpacity(tempOpacity);

            if tempPosX == self.posX then
                self.centerTag = self.btns[i]:getTag();
            end
        end
    end

    self:creatItem(self.centerTag);
end

function trialMainLayer:MoveLeft()--向左滑动
    -- print("-----------MoveLeft-----------")
    self.isTouch = false;
    local tempPosX = self.btns[#self.btns]:getPositionX();
    local tempScale = self.btns[#self.btns]:getScale();
    local tempLocalZOrder = self.btns[#self.btns]:getLocalZOrder();
    local tempOpacity = self.btns[#self.btns]:getOpacity();
    for i=#self.btns,1,-1 do
        if i > 1 then--重置位置
            local moveBy = cc.MoveTo:create(0.2, cc.p(self.btns[i-1]:getPositionX(),self.Panel_3:getContentSize().height/2));
            local actionTo = cc.ScaleTo:create(0.2,self.btns[i-1]:getScale());
            self.btns[i]:runAction(cc.Sequence:create(moveBy,actionTo));
            self.btns[i]:setLocalZOrder(self.btns[i-1]:getLocalZOrder());
            self.btns[i]:setOpacity(self.btns[i-1]:getOpacity());

            if self.btns[i-1]:getPositionX() == self.posX then
                self.centerTag = self.btns[i]:getTag();
            end
        else
            local moveBy = cc.MoveTo:create(0.2, cc.p(tempPosX,self.Panel_3:getContentSize().height/2));
            local actionTo = cc.ScaleTo:create(0.2,tempScale);
            -- local spawn = cc.Spawn:create(moveBy,actionTo);
            -- local delayTime = cc.DelayTime:create(0.05);
            local function setTouch()
                self.isTouch = true;
            end
            local func = cc.CallFunc:create(setTouch);
            self.btns[i]:runAction(cc.Sequence:create(moveBy,actionTo,func));
            -- self.btns[i]:runAction(cc.Sequence:create(moveBy,actionTo));
            self.btns[i]:setLocalZOrder(tempLocalZOrder);
            self.btns[i]:setOpacity(tempOpacity);

            if tempPosX == self.posX then
                self.centerTag = self.btns[i]:getTag();
            end
        end
    end

    self:creatItem(self.centerTag);
end

function trialMainLayer:onTouchClick()
    self:checkpointSendReq();
end

function trialMainLayer:back()
    self:removeFromParent();
end

function trialMainLayer:onButtonClick(sender, eventType)
    if sender ~= self.Panel_1 then
        buttonClickScale(sender, eventType);
    end

    if eventType == ccui.TouchEventType.ended then
        self:removeFromParent();
    end
end

function trialMainLayer:onReciveData(MsgID, NetData)
    print("trialMainLayer onReciveData MsgID:"..MsgID)
    
    if MsgID == Post_practicepInfo then
        local ackData = NetData
        if ackData.state == 1 then
            self:initData(ackData.practicepinfo);
        else
            NetHandler:showFailedMessage(ackData)
        end
    elseif MsgID == Post_getPracticepC then
        local ackData = NetData
        if ackData.state == 1 then
            local trialEntrance = trialEntranceLayer.showBox(self,self.scenetype);
            trialEntrance:setData(ackData.getpracticepc,self.cityInfoList,self.curTag);
        else
            NetHandler:showFailedMessage(ackData)
        end
    end
end

function trialMainLayer:sendReq()
    NetHandler:sendData(Post_practicepInfo, "");
end

function trialMainLayer:checkpointSendReq()
    local str = string.format("&sid=%d",self.curTag);
    NetHandler:sendData(Post_getPracticepC, str);
end

function trialMainLayer:pushAck()
    NetHandler:addAckCode(self,Post_practicepInfo);
    NetHandler:addAckCode(self,Post_getPracticepC);
end

function trialMainLayer:popAck()
    NetHandler:delAckCode(self,Post_practicepInfo);
    NetHandler:addAckCode(self,Post_getPracticepC);
end

function trialMainLayer:onEnter()
    self:pushAck();
    self:sendReq();
end

function trialMainLayer:onExit()
    self:popAck();
    MGRCManager:releaseResources("trialMainLayer");
end

function trialMainLayer.create(delegate,scenetype)
    local layer = trialMainLayer:new()
    layer.delegate = delegate
    layer.scenetype = scenetype
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

function trialMainLayer.showBox(delegate,scenetype)
    local layer = trialMainLayer.create(delegate,scenetype);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
