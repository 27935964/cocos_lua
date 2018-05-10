-----------------------公会攻城部队界面------------------------
require "recoverroadRule"
require "guildTroopsInfo"

local SodierItem=require "SodierItem";
guildTroopsLayer = class("guildTroopsLayer", MGLayer)

function guildTroopsLayer:ctor()
    self.curItemData = nil;
    self:init();
end

function guildTroopsLayer:init()
    local pWidget = MGRCManager:widgetFromJsonFile("guildTroopsLayer","SiegeTroops_ui.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);

    self.pPanelTop = PanelTop.create(self)
    self.pPanelTop:setData("guild_siege_title.png");
    self:addChild(self.pPanelTop,10);
    self.pPanelTop:showRankCoin(false);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:setAnchorPoint(cc.p(0.5, 0.5));
    CommonMethod:setFullBgScale(self.Panel_1);

    local Panel_2 = pWidget:getChildByName("Panel_2");

    self.Label_SendTips = Panel_2:getChildByName("Label_SendTips");
    self.Label_SendTips:setVisible(false);
    self.tipLabel_1 = MGColorLabel:label();
    self.tipLabel_1:setPosition(self.Label_SendTips:getPosition());
    Panel_2:addChild(self.tipLabel_1);

    self.Label_AwaitTips = Panel_2:getChildByName("Label_AwaitTips");
    self.Label_AwaitTips:setVisible(false);
    self.tipLabel_2 = MGColorLabel:label();
    self.tipLabel_2:setPosition(self.Label_AwaitTips:getPosition());
    Panel_2:addChild(self.tipLabel_2);

    self.PageView = Panel_2:getChildByName("PageView");
    self.PageView:addEventListenerPageView(handler(self,self.pageViewEvent));

    self.Button_Left = Panel_2:getChildByName("Button_Left");
    self.Button_Left:addTouchEventListener(handler(self,self.onButtonClick));
    -- self.Button_Left:setEnabled(false);

    self.Button_Right = Panel_2:getChildByName("Button_Right");
    self.Button_Right:addTouchEventListener(handler(self,self.onButtonClick));
    -- self.Button_Right:setEnabled(false);

    self.Image_Help = Panel_2:getChildByName("Image_Help");
    self.Image_Help:setTouchEnabled(true);
    self.Image_Help:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_send = Panel_2:getChildByName("Button_send");
    self.Button_send:addTouchEventListener(handler(self,self.onButtonClick));

    self.Label_tip = Panel_2:getChildByName("Label_tip");
    self.Label_tip:setText(MG_TEXT_COCOS("SiegeTroops_ui_3"));
    self.Label_tip:setVisible(false);

    local Label_Tips = Panel_2:getChildByName("Label_Tips");
    Label_Tips:setText(MG_TEXT_COCOS("SiegeTroops_ui_1"));

    local Label_send = self.Button_send:getChildByName("Label_send");
    Label_send:setText(MG_TEXT_COCOS("SiegeTroops_ui_2"));

    self:readSql();
end

function guildTroopsLayer:readSql()--解析数据库数据
    self.union_achievement = {};
    local sql = string.format("select * from union_achievement");
    local DBDataList = LUADB.selectlist(sql, "id:city_num:reward");
    table.sort(DBDataList.info,function(a,b) return a.id < b.id; end);

    for index=1,#DBDataList.info do
        local DBData = {};
        DBData.id = tonumber(DBDataList.info[index].id);
        DBData.city_num = tonumber(DBDataList.info[index].city_num);
        DBData.reward = getDataList(DBDataList.info[index].reward);

        self.union_achievement[DBData.id]=DBData;
    end
end

function guildTroopsLayer:setData(data)
    self.data = data;

    self.tipLabel_1:clear();
    self.tipLabel_1:appendStringAutoWrap(string.format(MG_TEXT("guildTroopsLayer_1"),
        tonumber(self.data.user_num)),18,1,cc.c3b(188,169,102),22);

    self.tipLabel_2:clear();
    self.tipLabel_2:appendStringAutoWrap(string.format(MG_TEXT("guildTroopsLayer_2"),
        tonumber(self.data.corps_num)),18,1,cc.c3b(188,169,102),22);

    self.totalNum = #self.data.corps;
    self.ceil = math.ceil(self.totalNum/10);
    
    self:refreshButton();
    self:creatItem();
end

function guildTroopsLayer:creatItem()
    if self.layoutItems and #self.layoutItems > 0 then
        for i=1,#self.layoutItems do
            if self.layoutItems[i] then
                self.layoutItems[i]:removeFromParent();
                self.layoutItems = {};
            end
        end
    end

    self.Label_tip:setVisible(false);
    if self.totalNum <= 0 then
        self.Label_tip:setVisible(true);
        return;
    end

    self.layoutItems = {};
    for i=1,self.ceil do
        local layout = ccui.Layout:create();
        layout:setSize(cc.size(self.PageView:getContentSize().width,self.PageView:getContentSize().height));
        self.PageView:addPage(layout);
        table.insert(self.layoutItems,layout);
    end

    local index = 1;
    local itemIndex = 1;
    local i,j = 1,1;
    local function loadEachItem(dt)
        if itemIndex > self.totalNum then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
        else

            local layout = self.layoutItems[index];
            local data = self.data.corps[itemIndex];
            item=SodierItem.new(self);
            item:setTag(itemIndex);
            item:setData(tonumber(data.head),tonumber(data.lv),data.name,false);
            item:setTouch(true,1);

            local x = 125+190*(j-1);
            local y = layout:getContentSize().height/2+30-(i-1)*layout:getContentSize().height/2;
            item:setPosition(cc.p(x,y));
            self.layoutItems[index]:addChild(item);

            local mod1 = math.mod(itemIndex,10);
            local mod2 = math.mod(itemIndex,5);

            if mod2 == 0 then
                i = i+1;
                j = 0;
            end
            if mod1 == 0 then
                index = index+1;
                i = 1;
            end
            itemIndex = itemIndex+1;
            j = j+1;
            
        end
    end

    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
    end
    self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(loadEachItem, 0.1, false);
end

function guildTroopsLayer:refreshButton()
    self.Button_Left:setEnabled(true);
    self.Button_Right:setEnabled(true);
    if self.ceil <= 1 then
        self.Button_Left:setEnabled(false);
        self.Button_Right:setEnabled(false);
    else
        if self.PageView:getCurPageIndex() == 0 then
            self.Button_Left:setEnabled(false);
            self.Button_Right:setEnabled(true);
        elseif self.PageView:getCurPageIndex() == self.ceil-1 then
            self.Button_Left:setEnabled(true);
            self.Button_Right:setEnabled(false);
        end
    end
end

function guildTroopsLayer:onSelect(item)
    local guildTroopsInfo = guildTroopsInfo.showBox(self);
    guildTroopsInfo:setData(self.data.corps[item:getTag()]);
end

function guildTroopsLayer:onButtonClick(sender, eventType)
    buttonClickScale(sender, eventType);

    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_send then--派遣部队
            FightOP:setTeam(self.scenetype,Fight_union_troops,"");
        elseif sender == self.Image_Help then
            local rule = recoverroadRule.showBox(self);
            rule:setData();
        elseif sender == self.Button_Right then
            self.PageView:scrollToPage(self.curPageIndex+1);
        elseif sender == self.Button_Left then
            self.PageView:scrollToPage(self.curPageIndex-1);
        end
    end
end

function guildTroopsLayer:pageViewEvent(sender, eventType)
    if eventType == ccui.PageViewEventType.turning then
        self.curPageIndex = sender:getCurPageIndex();
        self:refreshButton();
    end
end

function guildTroopsLayer:back()
    self:removeFromParent();
end

function guildTroopsLayer:onReciveData(MsgID, NetData)
    print("guildTroopsLayer onReciveData MsgID:"..MsgID)
    if MsgID == Post_Union_Troops_index then
        if NetData.state == 1 then
            self:setData(NetData.index);
        else
            NetHandler:showFailedMessage(NetData);
        end
    elseif MsgID == Post_Union_Troops_doClose then--撤军
        if NetData.state == 1 then
            local isSameUid = false;--判断除了撤军这只部队外还有木有相同uid的玩家
            for i=#self.data.corps,1,-1 do
                local corp = self.data.corps[i];
                if tonumber(corp.id) == tonumber(self.curItemData.id) then
                    table.remove(self.data.corps,i);
                    self.data.corps_num = tonumber(self.data.corps_num)-1;
                else
                    if corp.uid == self.curItemData.uid then
                        isSameUid = true;
                    end
                end
            end

            if isSameUid == false then
                self.data.user_num = tonumber(self.data.user_num)-1;
            end
            
            self:setData(self.data);
        else
            NetHandler:showFailedMessage(NetData);
        end
    end
end

function guildTroopsLayer:sendReq(item)
    self.curItemData = item.data;

    local str = "&id="..tonumber(self.curItemData.id);
    NetHandler:sendData(Post_Union_Troops_doClose, str);
end

function guildTroopsLayer:pushAck()
    NetHandler:addAckCode(self,Post_Union_Troops_index);
    NetHandler:addAckCode(self,Post_Union_Troops_doClose);
end

function guildTroopsLayer:popAck()
    NetHandler:delAckCode(self,Post_Union_Troops_index);
    NetHandler:delAckCode(self,Post_Union_Troops_doClose);
end

function guildTroopsLayer:onEnter()
    self:pushAck();
    NetHandler:sendData(Post_Union_Troops_index, "");
end

function guildTroopsLayer:onExit()
    self:popAck();
    MGRCManager:releaseResources("guildTroopsLayer");
    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
    end
end

function guildTroopsLayer.create(delegate,scenetype)
    local layer = guildTroopsLayer:new()
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

function guildTroopsLayer.showBox(delegate,scenetype)
    local layer = guildTroopsLayer.create(delegate,scenetype);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
