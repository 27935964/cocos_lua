--------------------------光复之路-----------------------
-- require "recoverroadRule"
require "milestoneLayer"
require "getItem"
require "enemyInfo"
require "fanPaiLayer"
require "help"

local recoverroadItem = require "recoverroadItem"
recoverroadLayer = class("recoverroadLayer", MGLayer)

function recoverroadLayer:ctor()
    self.milestoneLayer = nil;
    self.curLid = 2;
end

function recoverroadLayer:init(delegate,scenetype)
    self.delegate = delegate;
    self.scenetype = scenetype;
    MGRCManager:cacheResource("recoverroadLayer", "recovery_map1.jpg");
    MGRCManager:cacheResource("recoverroadLayer", "recovery_map2.jpg");
    MGRCManager:cacheResource("recoverroadLayer", "recovery_map3.jpg");
    MGRCManager:cacheResource("recoverroadLayer", "main_top_bg.png");
    MGRCManager:cacheResource("recoverroadLayer", "recoverroad_ui0.png", "recoverroad_ui0.plist");
    local pWidget = MGRCManager:widgetFromJsonFile("recoverroadLayer","recoverroad.ExportJson");
    self:addChild(pWidget);

    if not self.itemWidget then
        self.itemWidget = MGRCManager:widgetFromJsonFile("recoverroadLayer", "recoverroad_item.ExportJson",false);
        self.itemWidget:retain();
    end

    local Panel_2 = pWidget:getChildByName("Panel_2");

    self.items = {};
    for i=1,3 do
        local Image_bg = Panel_2:getChildByName("Image_bg"..i);
        local item = recoverroadItem.create(self,self.itemWidget:clone());
        item:setPosition(cc.p(Image_bg:getContentSize().width/2,Image_bg:getContentSize().height/2));
        Image_bg:addChild(item);
        table.insert(self.items,item);
    end

    self.Button_back = Panel_2:getChildByName("Button_back");--返回
    self.Button_back:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_rule = Panel_2:getChildByName("Button_rule");--规则
    self.Button_rule:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_milestone = Panel_2:getChildByName("Button_milestone");--里程碑
    self.Button_milestone:addTouchEventListener(handler(self,self.onButtonClick));

    local Label_rule = Panel_2:getChildByName("Label_rule");
    local Label_smilestone = Panel_2:getChildByName("Label_smilestone");

    Label_rule:setText(MG_TEXT_COCOS("recoverroad_1"));
    Label_smilestone:setText(MG_TEXT_COCOS("recoverroad_2"));

    self:readSql()--解析数据库数据
end

function recoverroadLayer:readSql()--解析数据库数据
    self.loadList = {};
    local sql = string.format("select * from load");
    local DBDataList = LUADB.selectlist(sql, "l_id:name:need:soldier_id");

    for index=1,#DBDataList.info do
        local DBData = {};
        DBData.l_id = tonumber(DBDataList.info[index].l_id);
        DBData.name = DBDataList.info[index].name;

        DBData.need = getDataList(DBDataList.info[index].need);
        DBData.soldier_id = getDataList(DBDataList.info[index].soldier_id);

        self.loadList[DBData.l_id]=DBData;
    end
end

function recoverroadLayer:setData()
    
end

function recoverroadLayer:initData(data)
    self.data = data;
    table.sort(self.data.loadinfo,function(a,b) return a.lid < b.lid; end)

    for i=1,#self.data.loadinfo do
        local index = tonumber(self.data.loadinfo[i].lid);
        self.items[index]:setData(self.data.loadinfo[i]);
    end
end

function recoverroadLayer:openEnemyInfo(data)
    local enemyInfo = enemyInfo.showBox(self,"recovery_enemy_title.png");
    enemyInfo:setData(data,true);
end

function recoverroadLayer:challenge(item)--挑战
    local teamdata = string.format("&lid=%d&npc=%d",tonumber(item.data.l_id),tonumber(item.data.sort));
    local fightdata = string.format("&lid=%d&npc=%d",tonumber(item.data.l_id),tonumber(item.data.sort));
    FightOP:setTeam(self.scenetype,Fight_load,teamdata,fightdata,"");
end

function recoverroadLayer:onButtonClick(sender, eventType)
    if sender ~= self.Button_back then
        buttonClickScale(sender, eventType);
    end

    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_back then--返回
            self:removeFromParent();
        elseif sender == self.Button_rule then--规则
            -- local rule = recoverroadRule.showBox(self);
            -- rule:setData();
            local help = help.showBox(self);
        elseif sender == self.Button_milestone then--里程碑
            self.milestoneLayer = milestoneLayer.showBox(self);
            self.milestoneLayer:setData(self.data,self.loadList);
        end
    end
end

function recoverroadLayer:onReciveData(MsgID, NetData)
    print("recoverroadLayer onReciveData MsgID:"..MsgID)

    if MsgID == Post_loadInfo then
        local ackData = NetData
        if ackData.state == 1 then
            self:initData(ackData.loadinfo);
        else
            NetHandler:showFailedMessage(ackData);
        end
    elseif MsgID == Post_getDayReward then--领取每日奖励
        local ackData = NetData
        if ackData.state == 1 then
            getItem.showBox(ackData.getdayreward.get_item);
            for i=1,#self.data.loadinfo do
                if tonumber(self.data.loadinfo[i].lid) == self.curLid then
                    self.data.loadinfo[i].day_reward = 0;
                    break;
                end
            end
            self:initData(self.data);
        else
            NetHandler:showFailedMessage(ackData);
        end
    elseif MsgID == Post_moveNext then--移动到下一里程
        local ackData = NetData
        if ackData.state == 1 then
            local lid = tonumber(ackData.movenext.loadinfo.lid);
            for i=1,#self.data.loadinfo do
                if tonumber(self.data.loadinfo[i].lid) == lid then
                    self.data.loadinfo[i].lid = lid;
                    self.data.loadinfo[i].is_next = ackData.movenext.loadinfo.is_next;
                    self.data.loadinfo[i].mileage = ackData.movenext.loadinfo.mileage;
                    self.data.loadinfo[i].box_num = ackData.movenext.loadinfo.box_num;
                    break;
                end
            end
            self:initData(self.data);
        else
            NetHandler:showFailedMessage(ackData);
        end
    elseif MsgID == Post_boxReward then--领取宝箱奖励
        local ackData = NetData
        if ackData.state == 1 then
            getItem.showBox(ackData.boxreward.get_item);
            local lid = tonumber(ackData.boxreward.loadinfo.lid);
            for i=1,#self.data.loadinfo do
                if tonumber(self.data.loadinfo[i].lid) == lid then
                    self.data.loadinfo[i].lid = lid;
                    self.data.loadinfo[i].is_next = ackData.boxreward.loadinfo.is_next;
                    self.data.loadinfo[i].box_num = ackData.boxreward.loadinfo.box_num;
                    break;
                end
            end
            self:initData(self.data);
        else
            NetHandler:showFailedMessage(ackData);
        end
    elseif MsgID == Post_load_flipReward then--翻牌奖励
        local ackData = NetData
        if ackData.state == 1 then
            local lid = tonumber(ackData.flipreward.loadinfo.lid);
            for i=1,#self.data.loadinfo do
                if tonumber(self.data.loadinfo[i].lid) == lid then
                    self.data.loadinfo[i].lid = lid;
                    self.data.loadinfo[i].is_next = ackData.flipreward.loadinfo.is_next;
                    break;
                end
            end
            self:initData(self.data);
            local fanPai = fanPaiLayer.showBox(self);
            fanPai:setData(ackData.getflipreward,1);
        else
            NetHandler:showFailedMessage(ackData);
        end
    elseif MsgID == Post_getMileageReward then--里程碑奖励
        local ackData = NetData
        if ackData.state == 1 then
            getItem.showBox(ackData.getmileagereward.get_item);
            local lid = tonumber(ackData.getmileagereward.loadinfo.lid);
            for i=1,#self.data.loadinfo do
                if tonumber(self.data.loadinfo[i].lid) == lid then
                    self.data.loadinfo[i].lid = lid;
                    self.data.loadinfo[i].get_mileage_reward = ackData.getmileagereward.loadinfo.get_mileage_reward;
                    break;
                end
            end
            if self.milestoneLayer then
                self.milestoneLayer:setData(self.data,self.loadList);
            end
        else
            NetHandler:showFailedMessage(ackData);
        end
    end
end

function recoverroadLayer:removeMilestoneLayer()
    if self.milestoneLayer then
        self.milestoneLayer = nil;
    end
end

function recoverroadLayer:dayRewardSendReq(item)
    self.curLid = tonumber(item.data.lid);
    local str = string.format("&lid=%d",tonumber(item.data.lid));
    NetHandler:sendData(Post_getDayReward, str);
end

function recoverroadLayer:moveSendReq(item)
    self.curLid = tonumber(item.data.lid);
    local str = string.format("&lid=%d",tonumber(item.data.lid));
    NetHandler:sendData(Post_moveNext, str);
end

function recoverroadLayer:boxRewardSendReq(item)
    self.curLid = tonumber(item.data.lid);
    local str = string.format("&lid=%d",tonumber(item.data.lid));
    NetHandler:sendData(Post_boxReward, str);
end

function recoverroadLayer:flipRewardSendReq(item)
    self.curLid = tonumber(item.data.lid);
    local str = string.format("&lid=%d",tonumber(item.data.lid));
    NetHandler:sendData(Post_load_flipReward, str);
end

function recoverroadLayer:getMileageRewardSendReq(lid)
    self.curLid = lid;
    local str = string.format("&lid=%d",lid);
    NetHandler:sendData(Post_getMileageReward, str);
end

function recoverroadLayer:pushAck()
    NetHandler:addAckCode(self,Post_loadInfo);
    NetHandler:addAckCode(self,Post_getDayReward);
    NetHandler:addAckCode(self,Post_moveNext);
    NetHandler:addAckCode(self,Post_boxReward);
    NetHandler:addAckCode(self,Post_load_flipReward);
    NetHandler:addAckCode(self,Post_getMileageReward);
    
end

function recoverroadLayer:popAck()
    NetHandler:delAckCode(self,Post_loadInfo);
    NetHandler:delAckCode(self,Post_getDayReward);
    NetHandler:delAckCode(self,Post_moveNext);
    NetHandler:delAckCode(self,Post_boxReward);
    NetHandler:delAckCode(self,Post_load_flipReward);
    NetHandler:delAckCode(self,Post_getMileageReward);
end

function recoverroadLayer:onEnter()
    self:pushAck();
    NetHandler:sendData(Post_loadInfo, "");
end

function recoverroadLayer:onExit()
    MGRCManager:releaseResources("recoverroadLayer");
    self:popAck();
    if self.itemWidget then
        self.itemWidget:release()
    end
end

function recoverroadLayer.create(delegate,scenetype)
    local layer = recoverroadLayer:new()
    layer:init(delegate,scenetype)
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

function recoverroadLayer.showBox(delegate,scenetype)
    local layer = recoverroadLayer.create(delegate,scenetype);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
