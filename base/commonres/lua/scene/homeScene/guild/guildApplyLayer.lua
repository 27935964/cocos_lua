-----------------------公会申请界面------------------------

local guildApplyItem = require "guildApplyItem";
guildApplyLayer = class("guildApplyLayer", MGLayer)

function guildApplyLayer:ctor()
    self.name = "";
    self.isFind = false;
    self.unionId = 0;--公会ID
    self.index = 0;
    self.curItem = nil;
    self.applyType = 0;--1表示单个申请，2表示快速申请
    self:init();
end

function guildApplyLayer:init()
    local pWidget = MGRCManager:widgetFromJsonFile("guildApplyLayer","guild_list_ui.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:setAnchorPoint(cc.p(0.5, 0.5));
    CommonMethod:setFullBgScale(self.Panel_1);
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));

    local Panel_2 = pWidget:getChildByName("Panel_2");
    self.Panel_2 = Panel_2;

    self.Button_close = Panel_2:getChildByName("Button_close");
    self.Button_close:addTouchEventListener(handler(self,self.onButtonClick));

    local Panel_3 = Panel_2:getChildByName("Panel_3");
    self.Label_guild = Panel_3:getChildByName("Label_guild");

    self.ListView = Panel_3:getChildByName("ListView");
    self.ListView:setItemsMargin(5);
    self.ListView:setScrollBarVisible(false);

    self.Label_tip = Panel_2:getChildByName("Label_tip");
    self.Label_tip:setText(MG_TEXT("guildLayer_10"));
    self.Label_tip:setVisible(false);

    local Image_editBox = Panel_3:getChildByName("Image_editBox");
    self.editBox = self:createEditBox(Image_editBox);
    -- self.editBox:setText(MG_TEXT("guildLayer_2"));

    self.Button_find = Panel_3:getChildByName("Button_find");--查找
    self.Button_find:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_join = Panel_3:getChildByName("Button_join");--快速加入
    self.Button_join:addTouchEventListener(handler(self,self.onButtonClick));

    local Label_join = self.Button_join:getChildByName("Label_join");
    Label_join:setText(MG_TEXT_COCOS("guild_list_ui_1"));

    if not self.itemWidget then
        self.itemWidget = MGRCManager:widgetFromJsonFile("guildApplyLayer", "guild_item_ui.ExportJson",false);
        self.itemWidget:retain();
    end

    self:readSql();
end

function guildApplyLayer:readSql()--解析数据库数据
    self.union_lv = {};
    local sql = string.format("select * from union_lv");
    local DBDataList = LUADB.selectlist(sql, "lv:max_num");
    table.sort(DBDataList.info,function(a,b) return a.lv < b.lv; end);

    for index=1,#DBDataList.info do
        local DBData = {};
        DBData.lv = tonumber(DBDataList.info[index].lv);
        DBData.max_num = tonumber(DBDataList.info[index].max_num);

        self.union_lv[DBData.lv]=DBData;
    end
end

function guildApplyLayer:createEditBox(imageView)
    local sp = cc.Scale9Sprite:create();
    local editBox = cc.EditBox:create(cc.size(imageView:getSize().width * 0.95, imageView:getSize().height), sp);
    editBox:setFontSize(22);
    editBox:setFontColor(cc.c3b(82,82,82));
    editBox:setFontName(ttf_msyh);
    editBox:setAnchorPoint(cc.p(0.5, 0.5));
    editBox:setPosition(cc.p(imageView:getSize().width/2, imageView:getSize().height / 2));
    editBox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE);
    editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_SEARCH);
    editBox:registerScriptEditBoxHandler(handler(self,self.editBoxTextEventHandler));
    imageView:addChild(editBox);

    editBox:setMaxLength(6);
    editBox:setPlaceholderFontColor(cc.c3b(82,82,82));
    editBox:setPlaceholderFontSize(22);
    editBox:setPlaceHolder(MG_TEXT("guildLayer_2"));

    return editBox;
end

function guildApplyLayer:setData(data)
    self.data = data;

    self.unionList = {};--self.unionList.state：0表示未申请，1表示已申请，2已满员，3任何人都无法加入
    for i=1,#self.data.union_list do
        self.data.union_list[i].state = 0;
        --1所有人可加入(等级限制) 2任何人都不可加入 3需要同意才可加入
        if tonumber(self.data.union_list[i].join_limit) == 2 then
            self.data.union_list[i].state = 3;
        else
            if tonumber(self.data.union_list[i].is_apply) == 1 then
                self.data.union_list[i].state = 1;
            elseif tonumber(self.data.union_list[i].is_apply) == 0 then
                local max_num = self.union_lv[tonumber(self.data.union_list[i].id)].max_num;
                if tonumber(self.data.union_list[i].num) >= max_num then
                    self.data.union_list[i].state = 2;
                end
            end
        end
        table.insert(self.unionList,self.data.union_list[i]);
    end
    table.sort(self.unionList, function (data1,data2) return data1.score > data2.score; end );

    self.Label_guild:setText(string.format(MG_TEXT("guildLayer_11"),#self.unionList));
    self.ListView:removeAllItems();
    for i=1,#self.unionList do
        local item = guildApplyItem.create(self,self.itemWidget:clone());
        item:setData(self.unionList[i],i);
        self.ListView:pushBackCustomItem(item);
    end
end

function guildApplyLayer:editBoxTextEventHandler(strEventName,sender)
    if strEventName == "began" then

    elseif strEventName == "return" then
        self.name = self.editBox:getText();
        if self.name == "" and self.isFind == true then
            self.isFind = false;
            self.Label_tip:setVisible(false);
            self:setData(self.unionListData);
        end
    end
end

function guildApplyLayer:rapidApplication()--快速申请
    self.index = self.index + 1;
    if self.index > #self.unionListData.union_list then
        return;
    end

    for i=1,#self.unionListData.union_list do
        local id = tonumber(self.unionListData.union_list[i].id);
        local join_limit = tonumber(self.unionListData.union_list[i].join_limit);
        local num = tonumber(self.unionListData.union_list[i].num);
        --1所有人可加入(等级限制) 2任何人都不可加入 3需要同意才可加入
        if join_limit ~= 2 and num < self.union_lv[id].max_num then
            self:sendReq(id);
        else
            self:rapidApplication();
        end
    end
end

function guildApplyLayer:onButtonClick(sender, eventType)
    if sender == self.Button_close or sender == self.Button_find then
        buttonClickScale(sender, eventType);
    elseif sender == self.Button_join then
        buttonClickScale(sender, eventType,0.8);
    end

    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_find then--查找
            if self.name == "" then
                MGMessageTip:showFailedMessage(MG_TEXT("guildLayer_8"));
            else
                self:findSendReq();
            end
        elseif sender == self.Button_join then--快速加入
            self.index = 0;
            self.applyType = 2;
            self:rapidApplication();
        else
            self:removeFromParent();
        end
    end
end

function guildApplyLayer:apply(item)
    self.curItem = item;
    self.applyType = 1;
    self:sendReq(tonumber(item.data.id));
end

function guildApplyLayer:onReciveData(MsgID, NetData)
    print("guildApplyLayer onReciveData MsgID:"..MsgID)

    if MsgID == Post_getUnionList then
        local ackData = NetData
        if ackData.state == 1 then
            self.unionListData = ackData.getunionlist;
            self:setData(ackData.getunionlist);
        else
            NetHandler:showFailedMessage(ackData)
        end
    elseif MsgID == Post_applyAddUnion then
        local ackData = NetData
        if ackData.state == 1 then
            if self.applyType == 1 then--快速申请
                if ackData.applyaddunion.is_ok == 1 then
                    self.curItem:setState(1);
                elseif ackData.applyaddunion.is_ok == 2 then
                    print("----------进入公会----------")
                end
            elseif self.applyType == 2 then--单个申请
                if ackData.applyaddunion.is_ok == 1 then
                    self:rapidApplication();
                elseif ackData.applyaddunion.is_ok == 2 then
                    print("----------进入公会----------")
                end
            end
        else
            NetHandler:showFailedMessage(ackData)
        end
    elseif MsgID == Post_findUnion then
        local ackData = NetData
        if ackData.state == 1 then
            if #ackData.findunion.union_list <= 0 then
                self.Label_guild:setText(string.format(MG_TEXT("guildLayer_11"),0));
                self.Label_tip:setText(MG_TEXT("guildLayer_9"));
                self.Label_tip:setVisible(true);
                self.isFind = true;
            end
            self:setData(ackData.findunion);
        else
            NetHandler:showFailedMessage(ackData)
        end
    end
end

function guildApplyLayer:sendReq(unionId)
    local str = string.format("&id=%d",unionId);
    NetHandler:sendData(Post_applyAddUnion, str);
end

function guildApplyLayer:findSendReq()
    local str = string.format("&name=%s",self.name);
    NetHandler:sendData(Post_findUnion, str);
end

function guildApplyLayer:pushAck()
    NetHandler:addAckCode(self,Post_getUnionList);
    NetHandler:addAckCode(self,Post_findUnion);
    NetHandler:addAckCode(self,Post_applyAddUnion);
end

function guildApplyLayer:popAck()
    NetHandler:delAckCode(self,Post_getUnionList);
    NetHandler:delAckCode(self,Post_findUnion);
    NetHandler:delAckCode(self,Post_applyAddUnion);
end

function guildApplyLayer:onEnter()
    self:pushAck();
    NetHandler:sendData(Post_getUnionList, "");
end

function guildApplyLayer:onExit()
    MGRCManager:releaseResources("guildApplyLayer");
    self:popAck();
    if self.itemWidget then
        self.itemWidget:release()
    end
end

function guildApplyLayer.create(delegate,type)
    local layer = guildApplyLayer:new()
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

function guildApplyLayer.showBox(delegate,type)
    local layer = guildApplyLayer.create(delegate,type);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
