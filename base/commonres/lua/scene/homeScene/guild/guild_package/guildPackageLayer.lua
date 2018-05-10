-----------------------公会仓库界面------------------------

guildPackageLayer = class("guildPackageLayer", MGLayer)

function guildPackageLayer:ctor()
    self.goodsNum = 1;
    self.index = 0;
    self.id = 0;
    self.maxNum = 1;
    self.tag = 1;
    self.curGm = nil;
    self.feats = 0;
    self.my_feats = 0;
    self.guildInfo = nil;
    self:init();
end

function guildPackageLayer:init()
    local pWidget = MGRCManager:widgetFromJsonFile("guildPackageLayer","guild_package_ui.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:setAnchorPoint(cc.p(0.5, 0.5));
    CommonMethod:setFullBgScale(self.Panel_1);

    local Panel_2 = pWidget:getChildByName("Panel_2");
    self.ListView = Panel_2:getChildByName("ListView");
    self.ListView:setScrollBarVisible(false);

    local Panel_right = Panel_2:getChildByName("Panel_right");
    self.Panel_3 = Panel_right:getChildByName("Panel_3");
    self.Label_tip5 = Panel_right:getChildByName("Label_tip5");
    self.Label_tip5:setVisible(false);
    
    self.Image_box = self.Panel_3:getChildByName("Image_box");
    self.Label_name = self.Panel_3:getChildByName("Label_name");
    self.Label_kind = self.Panel_3:getChildByName("Label_kind");
    self.Label_num = self.Panel_3:getChildByName("Label_num");

    local Panel_label = self.Panel_3:getChildByName("Panel_label");
    self.descLabel = MGColorLabel:label();
    self.descLabel:setAnchorPoint(cc.p(0.5, 0.5));
    self.descLabel:setPosition(cc.p(Panel_label:getContentSize().width/2,Panel_label:getContentSize().height/2));
    Panel_label:addChild(self.descLabel);

    self.Panel_use = self.Panel_3:getChildByName("Panel_use");
    self.Label_num2 = self.Panel_use:getChildByName("Label_num2");
    self.Label_num3 = self.Panel_use:getChildByName("Label_num3");
    self.Label_num4 = self.Panel_use:getChildByName("Label_num4");
    self.Image_editBox = self.Panel_use:getChildByName("Image_editBox");
    self.Label_num1 = self.Image_editBox:getChildByName("Label_num1");
    local Label_tip = self.Panel_use:getChildByName("Label_tip");

    self.Button_minus = self.Panel_use:getChildByName("Button_minus");
    self.Button_minus:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_add = self.Panel_use:getChildByName("Button_add");
    self.Button_add:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_max = self.Panel_use:getChildByName("Button_max");
    self.Button_max:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_apply = self.Panel_use:getChildByName("Button_apply");
    self.Button_apply:addTouchEventListener(handler(self,self.onButtonClick));

    self.curItem = Item.create();
    self.curItem:setPosition(self.Image_box:getPosition());
    self.Panel_3:addChild(self.curItem,2);

    local Label_kindNmae = self.Panel_3:getChildByName("Label_kindNmae");
    Label_kindNmae:setText(MG_TEXT_COCOS("guild_package_ui_1"));

    local Label_numName = self.Panel_3:getChildByName("Label_numName");
    Label_numName:setText(MG_TEXT_COCOS("guild_package_ui_2"));

    local Label_apply1 = self.Panel_use:getChildByName("Label_apply1");
    Label_apply1:setText(MG_TEXT_COCOS("guild_package_ui_3"));

    local Label_apply2 = self.Panel_use:getChildByName("Label_apply2");
    Label_apply2:setText(MG_TEXT_COCOS("guild_package_ui_4"));

    local Label_feats = self.Panel_use:getChildByName("Label_feats");
    Label_feats:setText(MG_TEXT_COCOS("guild_package_ui_5"));

    local Label_btn = self.Button_apply:getChildByName("Label_btn");
    Label_btn:setText(MG_TEXT_COCOS("guild_package_ui_6"));

    local sql = string.format("select value from config where id=103");
    local DBData = LUADB.select(sql, "value");
    self.value = tonumber(DBData.info.value);
    Label_tip:setText(string.format(MG_TEXT("guildPackageLayer_2"),self.value));
end

function guildPackageLayer:setData(data)
    if self.delegate and self.delegate.getGuildInfo then
        self.guildInfo = self.delegate:getGuildInfo();
        self.feats = tonumber(self.guildInfo.day_use_feats);
        self.my_feats = tonumber(self.guildInfo.my_feats);
    end
    
    self.data = data;
    self.datas = {};
    for i=1,5 do
        self.datas[i] = {};
    end

    for i=1,#self.data.unionstorageitem do
        local gm = RESOURCE:getDBResourceListByItemId(self.data.unionstorageitem[i].item_id);
        if gm then
            if tonumber(self.data.unionstorageitem[i].item_type) == 13 then--印记
                table.insert(self.datas[1], gm);
            elseif tonumber(self.data.unionstorageitem[i].item_type) == 10 then--将魂
                table.insert(self.datas[2], gm);
            elseif tonumber(self.data.unionstorageitem[i].item_type) == 11 then--宝物
                table.insert(self.datas[3], gm);
            elseif tonumber(self.data.unionstorageitem[i].item_type) == 12 then--军械
                table.insert(self.datas[4], gm);
            else--消耗品
                table.insert(self.datas[5], gm);
            end
        end
    end

    table.sort(self.datas[1],function(gm1,gm2) return gm1:getQuality() > gm2:getQuality(); end)
    table.sort(self.datas[2],function(gm1,gm2) return gm1:getQuality() > gm2:getQuality(); end)
    table.sort(self.datas[3],function(gm1,gm2) return gm1:getQuality() > gm2:getQuality(); end)
    table.sort(self.datas[4],function(gm1,gm2) return gm1:getQuality() > gm2:getQuality(); end)
    table.sort(self.datas[5],function(gm1,gm2) return gm1:getQuality() > gm2:getQuality(); end)

    self.gmList = {};
    for j=1,5 do
        for i=1,#self.datas[j] do
            table.insert(self.gmList,self.datas[j][i]);
        end
    end
    
    self:createListItem();
end

function guildPackageLayer:createListItem()
    -- self.ListView:jumpToTop();
    if #self.gmList <= 0 then
        self.Label_tip5:setVisible(true);
        self.Panel_3:setVisible(false)
    else
        self.Label_tip5:setVisible(false);
        self.Panel_3:setVisible(true)
        self:createItem(self.gmList[1]);--物品图
    end
    if self.selSpr and self.selSpr:getParent() then
        self.selSpr:removeFromParent();
        self.selSpr = nil;
    end
    self.ListView:removeAllItems();
    self.items = {};
    self.totalNum = #self.gmList;
    if self.totalNum <= 0 then
        return;
    end

    self.queues = {};
    self.queues = newline(self.totalNum,5);

    local itemIndex = 1;
    local itemLay = ccui.Layout:create();
    itemLay:setSize(cc.size(self.ListView:getContentSize().width, self.queues[self.totalNum].row*125));
    self.ListView:pushBackCustomItem(itemLay);

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
            item:setData(self.gmList[itemIndex]);
            item:setNum(self.data.unionstorageitem[itemIndex].item_num);
            item:setShowTip(false);
            imgBox:addChild(item);
            table.insert(self.items,{imgBox=imgBox,item=item});

            if self.gmList[itemIndex]:isUse() == 1 then
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

function guildPackageLayer:createItem(gm)
    if gm then
        self.curGm = gm;
        self.curItem:setData(gm);
        self.curItem:setNum(self.data.unionstorageitem[self.tag].item_num);
        self.id = tonumber(self.data.unionstorageitem[self.tag].id);

        self.Label_name:setText(gm:name());
        self.Label_name:setColor(ResourceData:getTitleColor(gm:getQuality()));
        self.Label_num:setText(self.data.unionstorageitem[self.tag].item_num);
        self.maxNum = tonumber(self.data.unionstorageitem[self.tag].item_num);
        self.goodsNum = 1;
        self.Label_num1:setText(self.goodsNum);
        self.Label_num4:setText(string.format("%d/%d",self.goodsNum*gm:unionFeatsExp()+self.feats,self.value));

        self.descLabel:clear();
        local str_list = spliteStr(gm:desc(),"\\n");
        local str1 = str_list[1];
        local str2 = str_list[2];
        self.descLabel:appendStringAutoWrap(str1,18,1,cc.c3b(255,255,255),22);
        self.descLabel:appendLine(10);
        self.descLabel:appendStringAutoWrap(str2,18,1,cc.c3b(255,255,255),22);
        
        local isHave = false;
        for i=1,#self.data.apply_info do
            if self.id == tonumber(self.data.apply_info[i].id) then
                self.Label_num2:setText(tonumber(self.data.apply_info[i].user));
                self.Label_num3:setText(tonumber(self.data.apply_info[i].num));
                isHave = true;
                break;
            end
        end
        if isHave == false then
            self.Label_num2:setText(0);
            self.Label_num3:setText(0);
        end
        
    end
end

function guildPackageLayer:ItemSelect(item)
    self.tag = item:getTag();
    self:createItem(item.gm);
    if self.selSpr then
        self.selSpr:setPosition(self.items[self.tag].imgBox:getPosition());
    end
end

function guildPackageLayer:setGoodsNum()
    self.goodsNum = self.goodsNum + self.index;
    if self.curGm:unionFeatsExp()*self.goodsNum + self.feats > self.value then
        self.goodsNum = self.goodsNum-1;
    end
    if self.goodsNum <= 1 then
        self.goodsNum = 1;
    elseif self.goodsNum >= self.maxNum then
        self.goodsNum = self.maxNum;
    end
    self.Label_num1:setText(self.goodsNum);
    self.Label_num4:setText(string.format("%d/%d",self.curGm:unionFeatsExp()*self.goodsNum + self.feats,self.value));
end

function guildPackageLayer:onButtonClick(sender, eventType)
    buttonClickScale(sender, eventType);

    if eventType == ccui.TouchEventType.began then
        if sender == self.Button_add then
            self.index = 1;
            local seq = cc.Sequence:create(cc.CallFunc:create(function() self:setGoodsNum() end),
                cc.DelayTime:create(0.2));
            self.action = self:runAction(cc.RepeatForever:create(seq));
        elseif sender == self.Button_minus then
            self.index = -1;
            local seq = cc.Sequence:create(cc.CallFunc:create(function() self:setGoodsNum() end),
                cc.DelayTime:create(0.2));
            self.action = self:runAction(cc.RepeatForever:create(seq));
        end
    elseif eventType == ccui.TouchEventType.canceled then
        if sender == self.Button_add or sender == self.Button_minus then
            self:stopAction(self.action);
        end
    elseif eventType == ccui.TouchEventType.ended then
        if sender == self.Button_add or sender == self.Button_minus then--加/减
            self:stopAction(self.action);
        elseif sender == self.Button_max then--最大
            if self.curGm:getNum()*self.curGm:unionFeatsExp() + self.feats < self.value then
                self.goodsNum = self.data.unionstorageitem[self.tag].item_num;
            else
                self.goodsNum = math.floor((self.value-self.feats)/self.curGm:unionFeatsExp());
            end
            self.Label_num1:setText(self.goodsNum);
            self.Label_num4:setText(string.format("%d/%d",self.curGm:unionFeatsExp()*self.goodsNum+self.feats,self.value));
        elseif self.Button_apply then--申请
            if self.my_feats < self.curGm:unionFeatsExp()*self.goodsNum then
                MGMessageTip:showFailedMessage(MG_TEXT("guildPackageLayer_3"));
            elseif self.feats > self.value then
                MGMessageTip:showFailedMessage(MG_TEXT("guildPackageLayer_4"));
            else
                self:sendReq();
            end
        end
    end
end

function guildPackageLayer:onReciveData(MsgID, NetData)
    print("guildPackageLayer onReciveData MsgID:"..MsgID)

    if MsgID == Post_union_getStorage then
        local ackData = NetData
        if ackData.state == 1 then
            self:setData(ackData.upunionstorageitem);
        else
            NetHandler:showFailedMessage(ackData);
        end
    elseif MsgID == Post_applyItem then
        local ackData = NetData
        if ackData.state == 1 then
            if ackData.upunionstorageitem then
                self:setData(ackData.upunionstorageitem);
            end
            MGMessageTip:showFailedMessage(MG_TEXT("guildPackageLayer_5"));
        else
            NetHandler:showFailedMessage(ackData);
        end
    end
end

function guildPackageLayer:sendReq()
    local str = string.format("&id=%s&num=%d",self.id,self.goodsNum);
    NetHandler:sendData(Post_applyItem, str);
end

function guildPackageLayer:pushAck()
    NetHandler:addAckCode(self,Post_union_getStorage);
    NetHandler:addAckCode(self,Post_applyItem);
    
end

function guildPackageLayer:popAck()
    NetHandler:delAckCode(self,Post_union_getStorage);
    NetHandler:delAckCode(self,Post_applyItem);
end

function guildPackageLayer:onEnter()
    self:pushAck();
    NetHandler:sendData(Post_union_getStorage, "");
end

function guildPackageLayer:onExit()
    self:popAck();
    MGRCManager:releaseResources("guildPackageLayer");
    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
    end
end

function guildPackageLayer.create(delegate)
    local layer = guildPackageLayer:new()
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
