-----------------------仓库界面------------------------
require "Item"
require "PanelTop"

PackageLayer = class("PackageLayer", MGLayer)

PackageLayer.H_C = 5
function PackageLayer:ctor()
    self.panels = {};
    self.curPanelBtn = nil;
    self.goodsNum = 0;
    self.maxNum = 0;
    self.cell_num = 0;
    self.totalNum = 0;
    self.curItem = nil;
    self.items = {};
    self.type = 0;
    self.id = 0;
    self:init();
end

function PackageLayer:init()
    MGRCManager:cacheResource("PackageLayer", "package_bg.jpg");
    MGRCManager:cacheResource("PackageLayer", "package_top_bg.png");
    MGRCManager:cacheResource("PackageLayer", "packageLayer_ui0.png","packageLayer_ui0.plist");
    local pWidget = MGRCManager:widgetFromJsonFile("PackageLayer","package_ui_1.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);
    
    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:setAnchorPoint(cc.p(0.5, 0.5));
    CommonMethod:setFullBgScale(self.Panel_1);

    local Panel_2 = pWidget:getChildByName("Panel_2");
    self.Panel_tabView = Panel_2:getChildByName("Panel_tabView");
    local Panel_left = Panel_2:getChildByName("Panel_left");

    self.listView = ccui.ListView:create();
    self.listView:setDirection(ccui.ScrollViewDir.vertical);
    self.listView:setBounceEnabled(true);
    self.listView:setSize(self.Panel_tabView:getSize());
    self.listView:setScrollBarVisible(false);--true添加滚动条
    self.listView:setAnchorPoint(cc.p(0.5,0.5));
    -- self.listView:setItemsMargin(10);
    self.listView:setPosition(cc.p(self.Panel_tabView:getSize().width/2,self.Panel_tabView:getSize().height/2));
    -- self.listView:setBackGroundColorType(1);
    -- self.listView:setBackGroundColor(cc.c3b(0,0,250));
    self.Panel_tabView:addChild(self.listView);

    for i=1,5 do
        local Panel_btn = Panel_left:getChildByName("Panel_btn"..i);
        local Label_btn = Panel_btn:getChildByName("Label_btn"..i);
        Label_btn:setColor(cc.c3b(130, 130, 111));
        Panel_btn:setTag(i);
        Panel_btn:setTouchEnabled(true);
        Panel_btn:addTouchEventListener(handler(self,self.onBtnClick));
        table.insert(self.panels,{btn=Panel_btn,label=Label_btn});
        if i == 1 then
            self.curPanelBtn = Panel_btn;
            Label_btn:setColor(cc.c3b(255, 255, 255));
        end
    end

    self.panels[1].label:setText(MG_TEXT_COCOS("package_ui_4"));
    self.panels[2].label:setText(MG_TEXT_COCOS("package_ui_5"));
    self.panels[3].label:setText(MG_TEXT_COCOS("package_ui_6"));
    self.panels[4].label:setText(MG_TEXT_COCOS("package_ui_7"));
    self.panels[5].label:setText(MG_TEXT_COCOS("package_ui_8"));

    local Panel_right = Panel_2:getChildByName("Panel_right");
    self.Panel_right = Panel_right;
    self.Panel_3 = Panel_right:getChildByName("Panel_3");

    local Label_kindNmae = self.Panel_3:getChildByName("Label_kindNmae");
    Label_kindNmae:setText(MG_TEXT_COCOS("package_ui_1"));
    local Label_numName = self.Panel_3:getChildByName("Label_numName");
    Label_numName:setText(MG_TEXT_COCOS("package_ui_2"));

    self.Image_box = self.Panel_3:getChildByName("Image_box");
    self.Label_name = self.Panel_3:getChildByName("Label_name");
    self.Label_kind = self.Panel_3:getChildByName("Label_kind");
    self.Label_num = self.Panel_3:getChildByName("Label_num");

    self.Panel_use = Panel_right:getChildByName("Panel_use");
    self.Image_editBox = self.Panel_use:getChildByName("Image_editBox");
    self.Label_num1 = self.Image_editBox:getChildByName("Label_num1");

    self.Button_minus = self.Panel_use:getChildByName("Button_minus");
    self.Button_minus:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_add = self.Panel_use:getChildByName("Button_add");
    self.Button_add:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_max = self.Panel_use:getChildByName("Button_max");
    self.Button_max:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_use = self.Panel_use:getChildByName("Button_use");
    self.Button_use:addTouchEventListener(handler(self,self.onButtonClick));

    local Label_btn = self.Button_use:getChildByName("Label_btn");
    Label_btn:setText(MG_TEXT_COCOS("package_ui_3"));

    local Panel_label = self.Panel_3:getChildByName("Panel_label");
    self.descLabel = MGColorLabel:label();
    self.descLabel:setAnchorPoint(cc.p(0.5, 1));
    self.descLabel:setPosition(cc.p(Panel_label:getContentSize().width/2,Panel_label:getContentSize().height));
    Panel_label:addChild(self.descLabel);

    local panelTop = PanelTop.create(self);
    self:addChild(panelTop);
    panelTop:setData("package_title.png");

    --适配
    local Image_line2 = Panel_left:getChildByName("Image_line2");
    Panel_2:setAnchorPoint(cc.p(0.5,0.5));
    CommonMethod:setNodeScale(Panel_2,true);

end

function PackageLayer:setData(data)
    self.data = data
    self.datas = {};
    self.gmList = {};
    self.gmList = RESOURCE:getResList();

    if self.gmList then
        for i=1,5 do
            self.datas[i] = {};
        end

        for i=1,#self.gmList do
            if self.gmList[i]:getItemType() == 12 then--军械
                table.insert(self.datas[2], self.gmList[i]);
            elseif self.gmList[i]:getItemType() == 11 then--宝物
                table.insert(self.datas[3], self.gmList[i]);
            elseif self.gmList[i]:getItemType() == 10 then--将魂
                table.insert(self.datas[4], self.gmList[i]);
            elseif self.gmList[i]:getItemType() == 13 then--印记
                table.insert(self.datas[5], self.gmList[i]);
            else--消耗品
                table.insert(self.datas[1], self.gmList[i]);
            end
        end
    end

    table.sort(self.datas[1],function(gm1,gm2)
        if gm1:isUse() == 1 and gm2:isUse() == 1 and gm1:getQuality() == gm2:getQuality() then
            return gm1:getItemId() < gm2:getItemId();
        end

        if gm1:getQuality() == gm2:getQuality() then
            return gm1:getItemId() < gm2:getItemId();
        end

        return gm1:isUse() > gm2:isUse();
    end)

    table.sort(self.datas[2],function(gm1,gm2)
        if gm1:getQuality() == gm2:getQuality() then
            return gm1:getItemId() < gm2:getItemId();
        end
        return gm1:getQuality() > gm2:getQuality();
    end)

    table.sort(self.datas[3],function(gm1,gm2)
        if gm1:getQuality() == gm2:getQuality() then
            return gm1:getItemId() < gm2:getItemId();
        end
        return gm1:getQuality() > gm2:getQuality();
    end)

    table.sort(self.datas[4],function(gm1,gm2)
        if gm1:getQuality() == gm2:getQuality() then
            return gm1:getItemId() < gm2:getItemId();
        end
        return gm1:getQuality() > gm2:getQuality();
    end)

    table.sort(self.datas[5],function(gm1,gm2)
        if gm1:getQuality() == gm2:getQuality() then
            return gm1:getItemId() < gm2:getItemId();
        end
        return gm1:getQuality() > gm2:getQuality();
    end)

    self:createListItem(self.datas[1]);
end

function PackageLayer:createListItem(datas)
    self.listView:jumpToTop();
    if self.curItem then
        self.curItem:removeFromParent();
        self.curItem = nil;
    end
    if #datas <= 0 then
        self.Label_name:setText(MG_TEXT("PackageLayer_1"));
        self.Label_kind:setText(MG_TEXT("PackageLayer_1"));
        self.Label_num:setText(0);
        self.descLabel:clear();
        self.descLabel:appendStringAutoWrap("",8,1,cc.c3b(255,255,255),22);
    else
        self:createItem(datas[1]);--物品图
    end
    if self.selSpr and self.selSpr:getParent() then
        self.selSpr:removeFromParent();
        self.selSpr = nil;
    end
    self.listView:removeAllItems();
    self.items = {};
    self.totalNum = #datas;
    self:setPanelUseVisible(1);
    if self.totalNum <= 0 then
        return;
    end

    self.queues = {};
    self.queues = newline(self.totalNum,PackageLayer.H_C);

    local itemIndex = 1;
    local itemLay = ccui.Layout:create();
    itemLay:setSize(cc.size(self.listView:getContentSize().width, self.queues[self.totalNum].row*125));
    self.listView:pushBackCustomItem(itemLay);

    local function loadEachItem(dt)
        if itemIndex > self.totalNum then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
        else
            local imgBox = ccui.ImageView:create("com_icon_box.png",ccui.TextureResType.plistType);
            imgBox:setPosition(cc.p(self.queues[itemIndex].col*125+20+imgBox:getContentSize().width/2,
                itemLay:getContentSize().height-self.queues[itemIndex].row*125+imgBox:getContentSize().height/2+20));
            itemLay:addChild(imgBox);

            local item = Item.create(self);
            item:setTag(itemIndex);
            item:setPosition(cc.p(imgBox:getContentSize().width/2,imgBox:getContentSize().height/2));
            item:setData(datas[itemIndex]);
            item:setShowTip(false);
            imgBox:addChild(item);
            table.insert(self.items,{imgBox=imgBox,item=item});

            if datas[itemIndex]:isUse() == 1 then
                local pointSpr = cc.Sprite:createWithSpriteFrameName("common_change_red_dot.png");
                pointSpr:setPosition(cc.p(imgBox:getContentSize().width-15,imgBox:getContentSize().height-15));
                imgBox:addChild(pointSpr);
            end
            
            if itemIndex == 1 then
                self.selSpr = cc.Sprite:createWithSpriteFrameName("com_selected_box.png");
                self.selSpr:setPosition(imgBox:getPosition());
                itemLay:addChild(self.selSpr,3);
            end
            itemIndex = itemIndex+1;
        end
    end

    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
    end
    self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(loadEachItem, 0.001, false);
end

function PackageLayer:createItem(gm)
    if gm then
        if self.curItem then
            self.curItem:removeFromParent();
            self.curItem = nil;
        end

        self.curItem = Item.create();
        self.curItem:setPosition(self.Image_box:getPosition());
        self.curItem:setData(gm);
        self.Panel_3:addChild(self.curItem,2);
        self.Label_name:setText(gm:name());
        self.Label_num:setText(gm:getNum());
        self.maxNum = gm:getNum();
        self.goodsNum = 0;
        self.Label_num1:setText(self.goodsNum);

        self.descLabel:clear();
        local str_list = spliteStr(gm:desc(),"\\n");
        local str1 = str_list[1];
        local str2 = str_list[2];
        self.descLabel:appendStringAutoWrap(str1,18,1,cc.c3b(255,255,255),22);
        self.descLabel:appendLine(10);
        self.descLabel:appendStringAutoWrap(str2,18,1,cc.c3b(255,255,255),22);

        for i=1,#self.data.storageitem do
            if gm:getItemId() == tonumber(self.data.storageitem[i].item_id) then
                self.id = tonumber(self.data.storageitem[i].id);
                break;
            end
        end
    end
end

function PackageLayer:setPanelUseVisible(tag)
    self.Panel_use:setVisible(true);
    self.Button_minus:setEnabled(true);
    self.Button_max:setEnabled(true);
    self.Button_add:setEnabled(true);
    
    if self.totalNum <= 0 then
        self.Panel_use:setVisible(false);
        self.Button_minus:setEnabled(false);
        self.Button_max:setEnabled(false);
        self.Button_add:setEnabled(false);
    else
        if self.datas[self.curPanelBtn:getTag()][tag]:isUse() == 0 then
            self.Panel_use:setVisible(false);
            self.Button_minus:setEnabled(false);
            self.Button_max:setEnabled(false);
            self.Button_add:setEnabled(false);
        end
    end
end

function PackageLayer:ItemSelect(item)
    self.tag = item:getTag();
    self:createItem(item.gm);
    if self.selSpr then
        self.selSpr:setPosition(self.items[self.tag].imgBox:getPosition());
    end
    self:setPanelUseVisible(self.tag);
end

function PackageLayer:onBtnClick(sender, eventType)
    if self.curPanelBtn:getTag() == sender:getTag() then
        return;
    end

    if eventType == ccui.TouchEventType.ended then
        self.panels[sender:getTag()].label:setColor(cc.c3b(255, 255, 255));
        self.panels[self.curPanelBtn:getTag()].label:setColor(cc.c3b(130, 130, 111));
        self.curPanelBtn = sender;
        self:createListItem(self.datas[sender:getTag()]);
    end
end

function PackageLayer:onButtonClick(sender, eventType)
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
        if sender == self.Button_minus or sender == self.Button_add or sender == self.Button_max then
            self:setNum(sender);
        elseif sender == self.Button_use then
            -- self:sendReq();
            self.maxNum = self.maxNum - self.goodsNum;
            self.goodsNum = 0;
            self.Label_num1:setText(self.goodsNum);
        end
    end
end

function PackageLayer:back()
    if self.type == SCENEINFO.MAP_SCENE then--在征战场景
        addMap();
    elseif self.type == SCENEINFO.MAIN_SCENE then--在主城场景
        addMainCity();
    end
    self:removeFromParent();
end

function PackageLayer:setNum(sender)
    if sender == self.Button_minus then
        self.goodsNum = self.goodsNum - 1;
    elseif sender == self.Button_add then
        self.goodsNum = self.goodsNum + 1;
    elseif sender == self.Button_max then
        self.goodsNum = self.maxNum;
    end
    if self.goodsNum <= 0 then
        self.goodsNum = 0;
    elseif self.goodsNum >= self.maxNum then
        self.goodsNum = self.maxNum;
    end
    self.Label_num1:setText(self.goodsNum);
end

function PackageLayer:onReciveData(MsgID, NetData)
    print("LoadingPanel onReciveData MsgID:"..MsgID)
    
    if MsgID == Post_getStorage then
        local ackData = NetData
        if ackData.state == 1 then
            self:setData(ackData.upstorageitem);
        else
            NetHandler:showFailedMessage(ackData)
        end
    elseif MsgID == Post_doUse then
        local ackData = NetData
        if ackData.state == 1 then

        else
            NetHandler:showFailedMessage(ackData)
        end
    end
end

function PackageLayer:sendReq()
    local str = string.format("&id=%d&num=%d",self.id,self.goodsNum);
    NetHandler:sendData(Post_doUse, str);
end

function PackageLayer:pushAck()
    NetHandler:addAckCode(self,Post_getStorage);
    NetHandler:addAckCode(self,Post_doUse);
end

function PackageLayer:popAck()
    NetHandler:delAckCode(self,Post_getStorage);
    NetHandler:delAckCode(self,Post_doUse);
end

function PackageLayer:onEnter()
    self:pushAck();
    NetHandler:sendData(Post_getStorage, "");
end

function PackageLayer:onExit()
    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
    end
    MGRCManager:releaseResources("PackageLayer");
    self:popAck();
end

function PackageLayer.create(delegate,type)
    local layer = PackageLayer:new()
    layer.delegate = delegate
    layer.type = type
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

function PackageLayer.showBox(delegate,type)
    local layer = PackageLayer.create(delegate,type);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
