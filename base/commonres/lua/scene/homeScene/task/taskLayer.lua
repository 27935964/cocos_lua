---------------------日常任务----------------------

local taskLayer = class("taskLayer", MGLayer)

function taskLayer:ctor(delegate,type)
    self.delegate = delegate;
    self.type = type;
    self.curId = 0;
    self:init();
end

function taskLayer:init()
    MGRCManager:cacheResource("taskLayer", "task_item_bg.png");
    MGRCManager:cacheResource("taskLayer", "task_title.png");
    local pWidget = MGRCManager:widgetFromJsonFile("taskLayer","task_ui.ExportJson");
    self:addChild(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    local Panel_2 = pWidget:getChildByName("Panel_2");
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));

    self.ListView = Panel_2:getChildByName("ListView");
    self.ListView:setScrollBarVisible(false);

    self.Button_close = Panel_2:getChildByName("Button_close");
    self.Button_close:addTouchEventListener(handler(self,self.onButtonClick));

    self:readSql();
    NodeListener(self);
end

function taskLayer:readSql()--解析数据库数据
    self.taskList = {};
    local sql = string.format("select * from errand");
    local DBDataList = LUADB.selectlist(sql, "id:type:need_lv:is_special:need_num:reward:name:des:pic:get_go:show");
    table.sort(DBDataList.info,function(a,b) return a.id < b.id; end);

    for index=1,#DBDataList.info do
        local DBData = {};
        DBData.id = tonumber(DBDataList.info[index].id);
        DBData.name = DBDataList.info[index].name;
        DBData.type = tonumber(DBDataList.info[index].type);
        DBData.need_lv = tonumber(DBDataList.info[index].need_lv);
        DBData.is_special = tonumber(DBDataList.info[index].is_special);
        DBData.need_num = tonumber(DBDataList.info[index].need_num);
        DBData.show = tonumber(DBDataList.info[index].show);
        DBData.pic = DBDataList.info[index].pic..".png";
        DBData.des = DBDataList.info[index].des;

        DBData.get_go = spliteStr(DBDataList.info[index].get_go,'|');
        DBData.reward = getneedlist(DBDataList.info[index].reward);

        self.taskList[tostring(DBData.id)]=DBData;
    end
end

function taskLayer:setData(data)
    self.data = data;

    self.taskDatas = {};
    local index_1 = 0;--已完成
    local index_2 = 0;--未完成
    for i=1,#self.data.erranditem do
        if tonumber(self.data.erranditem[i].status) == 1 then--状态(0未完成,1已完成,2已领奖)
            index_1 = index_1 + 1;
            index_2 = index_2 + 1;
            table.insert(self.taskDatas,index_1,self.data.erranditem[i]);
        elseif tonumber(self.data.erranditem[i].status) == 0 then
            index_2 = index_2 + 1;
            table.insert(self.taskDatas,index_2,self.data.erranditem[i]);
        else
            table.insert(self.taskDatas,self.data.erranditem[i]);
        end
    end

    self:createGeneralListItem();
end

function taskLayer:createGeneralListItem()
    self.ListView:removeAllItems();
    local totalNum = #self.taskDatas;

    local itemLay = ccui.Layout:create();
    itemLay:setSize(cc.size(self.ListView:getContentSize().width, totalNum*195));
    self.ListView:pushBackCustomItem(itemLay);

    require "taskItem";
    local itemIndex = 1;
    local function loadEachItem(dt)
        if itemIndex > totalNum then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
        else
            local taskData = self.taskList[tostring(self.taskDatas[itemIndex].e_id)];
            local item = taskItem.create(self);
            item:setPosition(cc.p(itemLay:getContentSize().width/2,itemLay:getContentSize().height-
                item:getContentSize().height/2-((item:getContentSize().height+5)*(itemIndex-1))));
            item:setData(self.taskDatas[itemIndex],taskData);
            itemLay:addChild(item);

            itemIndex = itemIndex+1;
        end
    end

    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
    end
    self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(loadEachItem, 0.001, false);
end

function taskLayer:onButtonClick(sender, eventType)
    if sender ~= self.Panel_1 then
        buttonClickScale(sender, eventType);
    end

    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_team then
            self:checkAll();
        elseif sender == self.Button_save then
            self:sendLegionReq();
        else
            self:removeFromParent();
        end
    end
end

function taskLayer:onReciveData(MsgID, NetData)
    print("taskLayer onReciveData MsgID:"..MsgID)

    if MsgID == Post_Errand_getErrand then
        if NetData.state == 1 then
            self:setData(NetData.uperranditem);
        else
            NetHandler:showFailedMessage(NetData)
        end
    elseif MsgID == Post_Errand_doOverErrand then
        if NetData.state == 1 then
            if 0 == tonumber(NetData.uperranditem.is_new) then --0 or 1 是否全新数据
                for i=1,#NetData.uperranditem.erranditem do
                    if self.curId == NetData.uperranditem.erranditem[i].e_id then
                        for i=1,#self.taskDatas do
                            if self.curId == self.taskDatas[i].e_id then
                                local taskData = self.taskDatas[i];
                                if NetData.uperranditem.erranditem[i].status then
                                    taskData.status = NetData.uperranditem.erranditem[i].status;
                                end
                                if NetData.uperranditem.erranditem[i].completion_status then
                                    taskData.completion_status = NetData.uperranditem.erranditem[i].completion_status;
                                end
                                table.remove(self.taskDatas,i);
                                table.insert(self.taskDatas,taskData);
                                self.curId = 0;
                                break;
                            end
                        end
                        break;
                    end
                end
                getItem.showBox(NetData.doovererrand.get_item);
                self:createGeneralListItem();
            elseif 1 == tonumber(NetData.uperranditem.erranditem) then
                self:setData(NetData.uperranditem);
            end
        else
            NetHandler:showFailedMessage(NetData)
        end
    end
end

function taskLayer:sendReq(id)
    self.curId = id;
    local str = "&id="..id;
    NetHandler:sendData(Post_Errand_doOverErrand, str);
end

function taskLayer:pushAck()
    NetHandler:addAckCode(self,Post_Errand_getErrand);
    NetHandler:addAckCode(self,Post_Errand_doOverErrand);
end

function taskLayer:popAck()
    NetHandler:delAckCode(self,Post_Errand_getErrand);
    NetHandler:delAckCode(self,Post_Errand_doOverErrand);
end

function taskLayer:onEnter()
    NetHandler:sendData(Post_Errand_getErrand, "");
    self:pushAck();
end

function taskLayer:onExit()
    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
    end
    self:popAck();
    MGRCManager:releaseResources("taskLayer");
end

return taskLayer;
