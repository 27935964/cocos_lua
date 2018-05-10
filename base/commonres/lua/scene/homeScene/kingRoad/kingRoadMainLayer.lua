-----------------------君王之路主界面------------------------
require "PanelTop"


local kingRoadBtn = require "kingRoadBtn";
local kingRoadItem = require "kingRoadItem";
local kingRoadTaskItem = require "kingRoadTaskItem"
kingRoadMainLayer = class("kingRoadMainLayer", MGLayer);

function kingRoadMainLayer:ctor()
    self.curParentBtn = nil;
    self.btns = {};
    self.openTag = 0;--当前展开的按钮的标签
    self.itemTag = 1;--小按钮的标签
    self.isJump = false;
    self:init();
end

function kingRoadMainLayer:init()
    MGRCManager:cacheResource("kingRoadMainLayer", "package_bg.jpg");
    MGRCManager:cacheResource("kingRoadMainLayer", "TheRoadOfKings_Button_Frame_bg.png");
    MGRCManager:cacheResource("kingRoadMainLayer", "king_road_ui.png", "king_road_ui.plist");
    local pWidget = MGRCManager:widgetFromJsonFile("kingRoadMainLayer","TheRoadOfKings_Crown_Main_Ui.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);

    self.pPanelTop = PanelTop.create(self)
    self.pPanelTop:setData("TheRoadOfKings_title.png");
    self:addChild(self.pPanelTop,10);
    self.pPanelTop:showRankCoin(false);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:setAnchorPoint(cc.p(0.5, 0.5));
    CommonMethod:setFullBgScale(self.Panel_1);

    local Panel_2 = pWidget:getChildByName("Panel_2");
    local Panel_left = Panel_2:getChildByName("Panel_left");
    local Panel_Right = Panel_2:getChildByName("Panel_Right");

    self.ListView_btn = Panel_left:getChildByName("ListView_btn");
    self.ListView_btn:setScrollBarVisible(false);

    self.Button_Rank = Panel_Right:getChildByName("Button_Rank");--排行
    self.Button_Rank:addTouchEventListener(handler(self,self.onButtonClick));

    self.ListView = Panel_Right:getChildByName("ListView");
    self.ListView:setScrollBarVisible(false);

    self.Label_Achievement = Panel_Right:getChildByName("Label_Achievement");
    self.ProgressBar = Panel_Right:getChildByName("ProgressBar");
    self.ProgressBar:setPercent(0);

    self.Image_mark = Panel_Right:getChildByName("Image_mark");
    self.Image_name = Panel_Right:getChildByName("Image_name");

    self.Label_tip = Panel_Right:getChildByName("Label_tip");
    self.Label_tip:setVisible(false);
    
    local Label_TotalAchievement = Panel_Right:getChildByName("Label_TotalAchievement");
    Label_TotalAchievement:setText(MG_TEXT_COCOS("TheRoadOfKings_Crown_Main_Ui_1"));

    local Label_Rank = Panel_Right:getChildByName("Label_Rank");
    Label_Rank:setText(MG_TEXT_COCOS("TheRoadOfKings_Crown_Main_Ui_2"));

    if not self.itemWidget then
        self.itemWidget = MGRCManager:widgetFromJsonFile("kingRoadMainLayer", "TheRoadOfKings_item_ui.ExportJson",false);
        self.itemWidget:retain();
    end

    if not self.itemTaskWidget then
        self.itemTaskWidget = MGRCManager:widgetFromJsonFile("kingRoadMainLayer", "TheRoadOfKings_Task_Ui.ExportJson",false);
        self.itemTaskWidget:retain();
    end

    self:readSql();
end

function kingRoadMainLayer:readSql()--解析数据库数据
    self.kingRoadInfos = {};
    self.king_lv = {};
    self.achievement = {};

    local sql = string.format("select * from achievement_type");
    local DBDataList = LUADB.selectlist(sql, "line_type:line_name:type:type_name:show_order");
    table.sort(DBDataList.info,function(a,b) return a.line_type < b.line_type; end);

    for index=1,#DBDataList.info do
        local DBData = {};
        DBData.line_type = tonumber(DBDataList.info[index].line_type);
        DBData.line_name = DBDataList.info[index].line_name;
        DBData.type = tonumber(DBDataList.info[index].type);
        DBData.type_name = DBDataList.info[index].type_name;
        DBData.show_order = tonumber(DBDataList.info[index].show_order);

        if DBData.line_type > #self.kingRoadInfos then
            self.kingRoadInfos[DBData.line_type]={};
        end
        table.insert(self.kingRoadInfos[DBData.line_type],DBData);
    end

    local sql_1 = string.format("select * from king_lv");
    local DBDataList_1 = LUADB.selectlist(sql_1, "lv:need_achievement:effect:name_pic:pic:des");

    for index=1,#DBDataList_1.info do
        local DBData = {};
        DBData.lv = tonumber(DBDataList_1.info[index].lv);
        DBData.need_achievement = tonumber(DBDataList_1.info[index].need_achievement);
        DBData.name_pic = DBDataList_1.info[index].name_pic;
        DBData.pic = DBDataList_1.info[index].pic;
        DBData.des = DBDataList_1.info[index].des;

        DBData.effect = spliteStr(DBDataList_1.info[index].effect, ':');
        self.king_lv[DBData.lv] = DBData;
    end

    local sql_2 = string.format("select * from achievement");
    local DBDataList_2 = LUADB.selectlist(sql_2,"id:line_type:type:reward:name:pic:des:max_num");
    --id:unlock:condition:show_serial

    local line_type = 0;
    local ach_type = 0;
    for index=1,#DBDataList_2.info do
        local DBData = {};
        DBData.id = tonumber(DBDataList_2.info[index].id);
        DBData.line_type = tonumber(DBDataList_2.info[index].line_type);
        DBData.type = tonumber(DBDataList_2.info[index].type);
        DBData.max_num = tonumber(DBDataList_2.info[index].max_num);
        DBData.name = DBDataList_2.info[index].name;
        DBData.pic = DBDataList_2.info[index].pic..".png";
        DBData.des = DBDataList_2.info[index].des;

        DBData.reward = getneedlist(DBDataList_2.info[index].reward);

        if line_type ~= DBData.line_type and nil == self.achievement[DBData.line_type] then
            line_type = DBData.line_type;
            self.achievement[DBData.line_type] = {};
        end

        table.insert(self.achievement[DBData.line_type],DBData);
    end
end

function kingRoadMainLayer:setData(data)
    self.data = data;

    self.unlockInfos = {};---已解锁的成就类型
    for i=1,#self.kingRoadInfos do
        self.unlockInfos[i] = {};
    end
    local str_list = {};
    if self.data.a_unlock_type and #self.data.a_unlock_type > 0 then
        str_list = spliteStr(self.data.a_unlock_type,':');
    end
    
    for i=1,#str_list do
        for m=1,#self.kingRoadInfos do
            local kingRoadInfo = self.kingRoadInfos[m];
            local isUnlock = false;
            for n=1,#kingRoadInfo do
                if kingRoadInfo[n].type == tonumber(str_list[i]) then
                    table.insert(self.unlockInfos[m],kingRoadInfo[n]);
                    isUnlock = true;
                    break;
                end
            end
            if isUnlock then
                break;
            end
        end
    end
    
    local curLv = tonumber(data.a_lv);
    self.Image_mark:loadTexture(self.king_lv[curLv].pic..".png",ccui.TextureResType.plistType);
    self.Image_name:loadTexture(self.king_lv[curLv].name_pic..".png",ccui.TextureResType.plistType);
    
    local num = tonumber(data.a_point);
    if curLv < #self.king_lv then
        local total = self.king_lv[curLv+1].need_achievement;
        self.ProgressBar:setPercent(num*100/total);
        self.Label_Achievement:setText(string.format("%d/%d",num,total));
    else
        self.Label_Achievement:setText(num);
        self.ProgressBar:setPercent(100);
    end

    
    self:createBtn();

    if self.jumpId and self.jumpId > 0 then
        self.isJump = true;
        self:jump(self.jumpId);
        self.jumpId = 0;
    else
        self:createItem();
    end
end

function kingRoadMainLayer:createItem()
    self.ListView:removeAllItems();
    self.Label_tip:setVisible(false);
    self.ListView:setDirection(ccui.ScrollViewDir.horizontal);
    self.totalNum = #self.king_lv;
    if self.totalNum == 0 then
        self.Label_tip:setVisible(true);
        return;
    end

    local itemIndex = 1;
    local function loadEachItem(dt)
        if itemIndex > self.totalNum then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
        else
            local item = kingRoadItem.create(self,self.itemWidget:clone());
            item:setData(self.data,self.king_lv[itemIndex]);
            self.ListView:pushBackCustomItem(item);

            itemIndex = itemIndex+1;
        end
    end

    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
    end
    self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(loadEachItem, 0.001, false);
end

function kingRoadMainLayer:createTaskItem(data)
    self.itemTask = {};
    self.ListView:removeAllItems();
    self.ListView:setDirection(ccui.ScrollViewDir.vertical);
    local totalNum = #data;
    if totalNum == 0 then
        self.Label_tip:setVisible(true);
        return;
    end

    local itemIndex = 1;
    local function loadEachItem(dt)
        if itemIndex > totalNum then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
        else
            local item = kingRoadTaskItem.create(self,self.itemTaskWidget:clone());
            item:setTag(tonumber(data[itemIndex].id));
            item:setData(data[itemIndex]);
            self.ListView:pushBackCustomItem(item);

            self.ListView:setItemsMargin(5);
            itemIndex = itemIndex+1;
            
            table.insert(self.itemTask,item);
        end
    end

    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
    end
    self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(loadEachItem, 0.001, false);
end

function kingRoadMainLayer:createBtn()
    self.btns = {};
    self.ListView_btn:removeAllItems();
    local item1 = kingRoadBtn.new(self);
    item1:setTag(1000);
    self.ListView_btn:pushBackCustomItem(item1);
    self.curParentBtn = item1;
    self.curParentBtn:setSelectImgVisible(true);

    for i=1,#self.kingRoadInfos do
        local item = kingRoadBtn.new(self);
        item:setTag(i);
        item:setData(self.unlockInfos[i],i);--unlockInfos
        self.ListView_btn:pushBackCustomItem(item);
        self.ListView_btn:setItemsMargin(10);
        table.insert(self.btns,item);
    end
end

function kingRoadMainLayer:onSelect(item)
    if self.curParentBtn then
        if self.openTag > 0 then--已经展开的要删除
            self.btns[self.openTag]:removeItems();
            self.ListView_btn:refreshView();
        end
        if self.openTag == item:getTag() then
            self.openTag = 0;
            return;
        end
        self.openTag = 0;
        
        self.curParentBtn:setSelectImgVisible(false);
        if item:getTag() < 1000 then
            if self.isJump then
                self.isJump = false;
            else
                if self.curParentBtn ~= item and item.kingRoadInfos and #item.kingRoadInfos > 0 then
                    self.itemTag = item.kingRoadInfos[1].type;
                end
            end
        end
    end

    self.curParentBtn = item;
    self.curParentBtn:setSelectImgVisible(true);
    if item:getTag() < 1000 then
        self.openTag = item:getTag();
        if nil == item.kingRoadInfos or #item.kingRoadInfos <= 0 then
            if self.schedulerID then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
            end
            self.ListView:removeAllItems();
            self.Label_tip:setVisible(true);
        else
            self.Label_tip:setVisible(false);
            self.curParentBtn:createItem(item.kingRoadInfos,self.itemTag);
            self.ListView_btn:refreshView();
        end
        
    else
        self:createItem();
    end
end

function kingRoadMainLayer:creatTaskList(item,type)
    self.itemTag = type;
    self.index = item.index;
    self:sendReq(type);
end

function kingRoadMainLayer:parseData(data)
    self.taskDatas = data;

    self.achDatas = {};
    local index_1 = 0;
    local index_2 = 0;
    for i=1,#self.taskDatas do
        local arr = {};
        for j=1,#self.achievement[self.index] do
            local arr = self.achievement[self.index][j];
            if self.achievement[self.index][j].id == tonumber(self.taskDatas[i].a_id) then
                arr.a_id = tonumber(self.taskDatas[i].a_id);
                arr.finish_time = tonumber(self.taskDatas[i].finish_time);
                arr.status = tonumber(self.taskDatas[i].status);
                arr.completion_status = self.taskDatas[i].completion_status;
                
                if arr.status == 1 then--状态(0未完成,1完成,2已领取奖励)
                    index_1 = index_1 + 1;
                    index_2 = index_2 + 1;
                    table.insert(self.achDatas,index_1,arr);
                elseif arr.status == 2 then
                    index_2 = index_2 + 1;
                    table.insert(self.achDatas,index_2,arr);
                else
                    table.insert(self.achDatas,arr);
                end
            end
        end
    end
    self:createTaskItem(self.achDatas);
end

function kingRoadMainLayer:jump(id)
    local curData = {};
    for i=1,#self.achievement do
        local isHave = false;
        for j=1,#self.achievement[i] do
            if self.achievement[i][j].id == id then
                curData = self.achievement[i][j];
                isHave = true;
                break;
            end
        end

        if isHave then
            break;
        end
    end

    if curData then
        self.itemTag = curData.type;
        self.btns[curData.line_type]:onClick(curData.type);
    end
end

function kingRoadMainLayer:updataTask(data)
    for i=1,#self.achDatas do
        if tonumber(self.achDatas[i].a_id) == tonumber(data.a_id) then
            table.remove(self.achDatas,i);
            table.insert(self.achDatas,data);
        end
    end
    self:createTaskItem(self.achDatas);
end

function kingRoadMainLayer:onButtonClick(sender, eventType)
    buttonClickScale(sender, eventType);
    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_Rank then--排行
            self:sendReqRank();
        end
    end
end

function kingRoadMainLayer:back()
    self:removeFromParent();
end

function kingRoadMainLayer:onReciveData(MsgID, NetData)
    print("kingRoadMainLayer onReciveData MsgID:"..MsgID)
    print_lua_table(NetData);
    if MsgID == Post_Achievement_getKingInfo then
        if NetData.state == 1 then
            self:setData(NetData.getkinginfo);
        else
            NetHandler:showFailedMessage(NetData);
        end
    elseif MsgID == Post_Achievement_getAchievement then
        if NetData.state == 1 then
            self:parseData(NetData.getachievement.achievement);
        else
            NetHandler:showFailedMessage(NetData);
        end
    elseif MsgID == Post_getRank then
        if NetData.state == 1 then
            require "kingRoadRankLayer"
            local kingRoadRankLayer = kingRoadRankLayer.showBox(self);
            kingRoadRankLayer:setData(NetData.getrank,self.king_lv);
        else
            NetHandler:showFailedMessage(NetData);
        end
    elseif MsgID == Post_Achievement_getReward then
        if NetData.state == 1 then
            getItem.showBox(NetData.getReward);
            -- self:updataTask(data);--刷新列表
        else
            NetHandler:showFailedMessage(NetData);
        end
    end
end

function kingRoadMainLayer:sendReq(type)
    local str = "&type="..type;
    NetHandler:sendData(Post_Achievement_getAchievement, str);
end

function kingRoadMainLayer:sendReqRank()
    local str = "&type="..6;
    NetHandler:sendData(Post_getRank, str);
end

function kingRoadMainLayer:sendReqGetReward(id)
    local str = "&id="..id;
    NetHandler:sendData(Post_Achievement_getReward, str);
end

function kingRoadMainLayer:pushAck()
    NetHandler:addAckCode(self,Post_Achievement_getKingInfo);
    NetHandler:addAckCode(self,Post_Achievement_getAchievement);
    NetHandler:addAckCode(self,Post_getRank);
    NetHandler:addAckCode(self,Post_Achievement_getReward);
end

function kingRoadMainLayer:popAck()
    NetHandler:delAckCode(self,Post_Achievement_getKingInfo);
    NetHandler:delAckCode(self,Post_Achievement_getAchievement);
    NetHandler:delAckCode(self,Post_getRank);
    NetHandler:delAckCode(self,Post_Achievement_getReward);
end

function kingRoadMainLayer:onEnter()
    self:pushAck();
    NetHandler:sendData(Post_Achievement_getKingInfo, "");
    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
    end
end

function kingRoadMainLayer:onExit()
    self:popAck();
    MGRCManager:releaseResources("kingRoadMainLayer");
    if self.itemWidget then
        self.itemWidget:release();
    end

    if self.itemTaskWidget then
        self.itemTaskWidget:release();
    end

    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
    end
end

function kingRoadMainLayer.create(delegate,scenetype,jumpId)
    local layer = kingRoadMainLayer:new()
    layer.delegate = delegate
    layer.scenetype = scenetype
    layer.jumpId = jumpId
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

function kingRoadMainLayer.showBox(delegate,scenetype,jumpId)
    local layer = kingRoadMainLayer.create(delegate,scenetype,jumpId);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
