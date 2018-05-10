--------------------------试炼难度选择界面-----------------------
require "PanelTop"
require "trialEntranceItem"
require "trialReport"
require "tip"

trialEntranceLayer = class("trialEntranceLayer", MGLayer)

function trialEntranceLayer:ctor()
    self.cur_cid = 1;
    self.curLevel = 0;
    self:init();
end

function trialEntranceLayer:init()
    for i=1,6 do
        MGRCManager:cacheResource("trialEntranceLayer", string.format("trial_base_normal_%d.png",i));
        MGRCManager:cacheResource("trialEntranceLayer", string.format("trial_base_pressed_%d.png",i));
    end
    local pWidget = MGRCManager:widgetFromJsonFile("trialEntranceLayer","trial_experiment_ui.ExportJson");
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
    self.Panel_left = Panel_2:getChildByName("Panel_left");

    self.Image_skull = self.Panel_left:getChildByName("Image_skull");
    self.Label_number = self.Panel_left:getChildByName("Label_number");
    self.Label_tip = self.Panel_left:getChildByName("Label_tip");

    local Image_ribbon = self.Panel_left:getChildByName("Image_ribbon");
    self.Label_difficulty = Image_ribbon:getChildByName("Label_difficulty");

    self.ListView_item = self.Panel_left:getChildByName("ListView_item");
    self.ListView_item:setScrollBarVisible(false);

    self.Button_add = self.Panel_left:getChildByName("Button_add");
    self.Button_add:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_screen = self.Panel_left:getChildByName("Button_screen");--战报
    self.Button_screen:addTouchEventListener(handler(self,self.onButtonClick));
    

    self.ListView = Panel_2:getChildByName("ListView");
    self.ListView:setScrollBarVisible(false);

    self.Button_sweep = Panel_2:getChildByName("Button_sweep");--扫荡
    self.Button_sweep:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_challenge = Panel_2:getChildByName("Button_challenge");--挑战
    self.Button_challenge:addTouchEventListener(handler(self,self.onButtonClick));


    local Label_remain = self.Panel_left:getChildByName("Label_remain");
    local Label_drop = self.Panel_left:getChildByName("Label_drop");
    local Label_report = self.Panel_left:getChildByName("Label_report");
    local Label_sweep = self.Button_sweep:getChildByName("Label_sweep");
    local Label_challenge = self.Button_challenge:getChildByName("Label_challenge");

    Label_remain:setText(MG_TEXT_COCOS("trial_experiment_ui_1"));
    Label_drop:setText(MG_TEXT_COCOS("trial_experiment_ui_2"));
    Label_report:setText(MG_TEXT_COCOS("trial_experiment_ui_3"));
    Label_sweep:setText(MG_TEXT_COCOS("trial_experiment_ui_4"));
    Label_challenge:setText(MG_TEXT_COCOS("trial_experiment_ui_5"));
end


function trialEntranceLayer:readSql()--解析数据库数据
    self.checkpointList = {}
    local sql = string.format("select * from practice_c_stage where s_id=%d", self.checkpointId);
    local DBDataList = LUADB.selectlist(sql, "s_id:c_id:diffic:diffic_pic:pic_normal:pic_press:need_lv:reward:reward_show");
    table.sort(DBDataList.info,function(a,b) return a.c_id < b.c_id; end);

    for index=1,#DBDataList.info do
        local DBData = {};
        DBData.s_id = tonumber(DBDataList.info[index].s_id);
        DBData.c_id = tonumber(DBDataList.info[index].c_id);
        DBData.diffic = DBDataList.info[index].diffic;
        DBData.diffic_pic = DBDataList.info[index].diffic_pic;
        DBData.pic_normal = DBDataList.info[index].pic_normal;
        DBData.pic_press = DBDataList.info[index].pic_press;
        DBData.need_lv = tonumber(DBDataList.info[index].need_lv);
        DBData.reward = getDataList(DBDataList.info[index].reward);
        DBData.reward_show = getDataList(DBDataList.info[index].reward_show);
        table.insert(self.checkpointList,DBData);
    end

end

function trialEntranceLayer:setData(data,cityInfoList,tag)
    self.data = data;
    self.cityInfoList = cityInfoList;
    self.checkpointId = tag;
    self:readSql();

    self.Label_tip:setText(cityInfoList[tag].des);
    self.Label_number:setText(string.format(MG_TEXT("trialMainLayer_1"),tonumber(data.num)));

    self.ListView:removeAllItems();
    local itemLay = ccui.Layout:create();
    itemLay:setSize(cc.size(self.ListView:getContentSize().width, self.ListView:getContentSize().height));
    if #self.checkpointList > 6 then
        itemLay:setSize(cc.size(#self.checkpointList*160, self.ListView:getContentSize().height));
    end
    self.ListView:pushBackCustomItem(itemLay);
    self.items = {};
    for i=1,#self.checkpointList do
        local item = trialEntranceItem.create(self);
        item:setData(self.data,self.checkpointList[i],i);
        itemLay:addChild(item);
        item:setPosition(cc.p(item:getContentSize().width/2+(i-1)*item:getContentSize().width,itemLay:getContentSize().height/2+10));
        table.insert(self.items,item);
    end
    self.items[1]:setBright(false);
    self:creatItem(self.checkpointList[1].c_id);
    self.pPanelTop:setData(string.format("trial_duplicate_title_%d.png",self.checkpointId));
end

function trialEntranceLayer:creatItem(tag)
    self.Image_skull:loadTexture(string.format("trial_skull_%d.png",tag),ccui.TextureResType.plistType);
    self.Label_difficulty:setText(self.checkpointList[tag].diffic);

    local reward_shows = self.checkpointList[tag].reward_show;
    self.ListView_item:removeAllItems();
    local itemLay = ccui.Layout:create();
    itemLay:setSize(cc.size(self.ListView_item:getContentSize().width, self.ListView_item:getContentSize().height));
    if #reward_shows > 2 then
        itemLay:setSize(cc.size(#reward_shows*130, self.ListView_item:getContentSize().height));
    end
    self.ListView_item:pushBackCustomItem(itemLay);

    self.rewards = {};
    for i=1,#reward_shows do
        local item = resItem.create(self);
        item:setData(reward_shows[i].value1,reward_shows[i].value2);
        itemLay:addChild(item);
        item.numLabel:setVisible(false);
        item:setPosition(cc.p(item:getContentSize().width/2+(i-1)*(item:getContentSize().width+20),itemLay:getContentSize().height/2));
        table.insert(self.rewards,item);
    end

    if #self.rewards <= 2 then
        local pos = getItemPositionX(self.rewards,itemLay:getContentSize().width/2);
        for i=1,#self.rewards do
            self.rewards[i]:setPositionX(pos[i]);
        end
    end

    self.curLevel = self.checkpointList[tag].need_lv;
    self.Button_sweep:setBright(false);
    self.Button_challenge:setBright(false);
    if ME:Lv() >= self.curLevel then
        if tonumber(self.data.star[self.cur_cid].star) >= 3 then
            self.Button_sweep:setBright(true);
        end
        self.Button_challenge:setBright(true);
    end
end

function trialEntranceLayer:callBack(item)
    self.cur_cid = item.index;
    self:creatItem(item.index);
    for i=1,#self.items do
        self.items[i]:setBright(true);
        if item == self.items[i] then
            self.items[i]:setBright(false);
            self.curLevel = item.checkpointInfo.need_lv;
        end
    end
end

function trialEntranceLayer:back()
    self:removeFromParent();
end

function trialEntranceLayer:buy(item)
    self:sendReq();
end

function trialEntranceLayer:onButtonClick(sender, eventType)
    if sender ~= self.Panel_1 then
        buttonClickScale(sender, eventType);
    end

    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_add then
            local tip = tip.showBox(self);
            tip:setData(self.data);
        elseif sender == self.Button_screen then--战报
            self:StrategySendReq();
        elseif sender == self.Button_sweep then--扫荡
            if ME:Lv() >= self.curLevel then
                if tonumber(self.data.star[self.cur_cid].star) < 3 then
                    MGMessageTip:showFailedMessage(MG_TEXT("trialMainLayer_2"));
                else
                    self:sendEmbattleReq();
                end
            else
                MGMessageTip:showFailedMessage(MG_TEXT("trialMainLayer_2"));
            end
        elseif sender == self.Button_challenge then--挑战
            if ME:Lv() >= self.curLevel then
                if tonumber(self.data.num) > 0 then
                    local teamdata = string.format("&sid=%d&cid=%d",self.checkpointId,self.cur_cid);
                    local fightdata = string.format("&sid=%d&cid=%d",self.checkpointId,self.cur_cid);
                    FightOP:setTeam(self.scenetype,Fight_Practice,teamdata,fightdata,self.cityInfoList[self.checkpointId].name);-- FightOP:setTeam(self.scenetype,6,self.checkpointId,self.cur_cid,self.cityInfoList[self.checkpointId].name);
                else
                    MGMessageTip:showFailedMessage(MG_TEXT("trialMainLayer_3"));
                end
            else
                MGMessageTip:showFailedMessage(MG_TEXT("heroAttLayer_9"));
            end
        else
            self:removeFromParent();
        end
    end
end

function trialEntranceLayer:onReciveData(MsgID, NetData)
    print("trialEntranceLayer onReciveData MsgID:"..MsgID);

    local ackData = NetData;
    if MsgID == Post_payAtkNum then
        if ackData.state == 1 then
            self.Label_number:setText(string.format(MG_TEXT("trialMainLayer_1"),tonumber(data.num)));
        else
            NetHandler:showFailedMessage(ackData);
        end
    elseif MsgID == Post_getStrategy then
        if ackData.state == 1 then
            local trialReport = trialReport.showBox(self);
            trialReport:setData(ackData.getstrategy);
        else
            NetHandler:showFailedMessage(ackData);
        end
    elseif MsgID == Post_Practice_embattle_1 then
        if ackData.state == 1 then
            self:sendFightingReq();
        else
            NetHandler:showFailedMessage(ackData);
        end
    elseif MsgID == Post_Practice_fighting_1 then
        if ackData.state == 1 then
            getItem.showBox(ackData.fighting.get_item);
            self.data.num = tonumber(self.data.num)-1;
            self.Label_number:setText(string.format(MG_TEXT("trialMainLayer_1"),tonumber(self.data.num)));
        else
            NetHandler:showFailedMessage(ackData);
        end
    end
end

function trialEntranceLayer:sendReq()
    local str = string.format("&sid=%d",self.checkpointId);
    NetHandler:sendData(Post_payAtkNum, str);
end

function trialEntranceLayer:StrategySendReq()
    local str = string.format("&sid=%d&cid=%d",self.checkpointId,self.cur_cid);
    NetHandler:sendData(Post_getStrategy, str);
end

function trialEntranceLayer:sendEmbattleReq()
    local str = string.format("&sid=%d&cid=%d",self.checkpointId,self.cur_cid);
    NetHandler:sendData(Post_Practice_embattle_1, str);
end

function trialEntranceLayer:sendFightingReq()
    local str = string.format("&sid=%d&cid=%d",self.checkpointId,self.cur_cid);
    NetHandler:sendData(Post_Practice_fighting_1, str);
end

function trialEntranceLayer:pushAck()
    NetHandler:addAckCode(self,Post_payAtkNum);
    NetHandler:addAckCode(self,Post_getStrategy);
    NetHandler:addAckCode(self,Post_Practice_embattle_1);
    NetHandler:addAckCode(self,Post_Practice_fighting_1);
end

function trialEntranceLayer:popAck()
    NetHandler:delAckCode(self,Post_payAtkNum);
    NetHandler:delAckCode(self,Post_getStrategy);
    NetHandler:addAckCode(self,Post_Practice_embattle_1);
    NetHandler:addAckCode(self,Post_Practice_fighting_1);
end

function trialEntranceLayer:onEnter()
    self:pushAck();
end

function trialEntranceLayer:onExit()
    self:popAck();
    MGRCManager:releaseResources("trialEntranceLayer");
end

function trialEntranceLayer.create(delegate,scenetype)
    local layer = trialEntranceLayer:new()
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

function trialEntranceLayer.showBox(delegate,scenetype)
    local layer = trialEntranceLayer.create(delegate,scenetype);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
