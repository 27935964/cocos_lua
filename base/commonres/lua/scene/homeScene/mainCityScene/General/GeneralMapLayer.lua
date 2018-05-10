----------------------武将图鉴-----------------------
require "heroMainLayer"
require "unGetGeneral"
require "usercardGetHero"

local GeneralMapItem = require "GeneralMapItem";
GeneralMapLayer = class("GeneralMapLayer", MGLayer)

function GeneralMapLayer:ctor()
    self.iCount = 0;--记录位招募中满足合成武将的个数
    self.curGm = nil;
    self:init();
end

function GeneralMapLayer:init()
    MGRCManager:cacheResource("GeneralMapLayer", "role_info_VIP_number.png");
    MGRCManager:cacheResource("GeneralMapLayer", "GeneralMapLayer_ui0.png","GeneralMapLayer_ui0.plist");
    local pWidget = MGRCManager:widgetFromJsonFile("GeneralMapLayer","GeneralMapLayer_ui_1.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:addTouchEventListener(handler(self,self.onBackClick));

    local Panel_2 = pWidget:getChildByName("Panel_2");
    self.ListView = Panel_2:getChildByName("ListView");
    self.ListView:setScrollBarVisible(false);--true添加滚动条

    self.Button_close = Panel_2:getChildByName("Button_close");
    self.Button_close:addTouchEventListener(handler(self,self.onButtonClick));

    self:readSql();
    self:setData();
end

function GeneralMapLayer:upData()
    self:setData();
end

function GeneralMapLayer:setData()
    self.iCount = 0;
    self.gmMyList ={};
    self.gmMyList = GENERAL:getGeneralList();
    local temList = GENERAL:getDBGeneralList();
    
    self.unRecruitList={}
    for k,v in pairs(temList) do--根据数据库配置是否在图鉴里选显示
        if v:isShow() then
                table.insert(self.unRecruitList,v);
        end
    end

    table.sort(self.gmMyList,function(gm1,gm2) return gm1:getWarScore() > gm2:getWarScore(); end)
    table.sort(self.unRecruitList,function(gm1,gm2) return gm1:getWarScore() > gm2:getWarScore(); end)

    for i=#self.unRecruitList,1,-1 do---如果未招募的武将中碎片已经够合成武将要放到已招募的武将列表最前面
        local resNum,totNum = getGeneralNeedDebrisNum(self.unRecruitList[i],false);
        if resNum >= totNum then
            self.iCount = self.iCount + 1;
            table.insert(self.gmMyList,1,self.unRecruitList[i]);
            table.remove(self.unRecruitList,i);
        end
    end
    
    self.queues1 = {};
    self.queues2 = {};
    self.queues1 = newline(#self.gmMyList,3);
    self.queues2 = newline(#self.unRecruitList,3);

    if #self.gmMyList <= 0 then
        self.ListView:removeAllItems();
        local itemLay = ccui.Layout:create();
        local height = self.queues2[#self.queues2].row*GeneralMapItem.HEIGHT+(self.queues2[#self.queues2].row-1)*20+130;
        itemLay:setSize(cc.size(self.ListView:getContentSize().width, height));
        self.ListView:pushBackCustomItem(itemLay);
        self:createUnRecruitGeneral(itemLay);
    else
        self:createMyGeneral();
    end
end

function GeneralMapLayer:readSql()
    local sql = string.format("select name from soldier_list");
    local DBDataList = LUADB.selectlist(sql, "name");
    self.soldierList = DBDataList.info;
end

function GeneralMapLayer:createMyGeneral()
    self.ListView:removeAllItems();

    local itemIndex = 1;
    local itemLay = ccui.Layout:create();
    local height = self.queues1[#self.queues1].row*GeneralMapItem.HEIGHT+(self.queues1[#self.queues1].row-1)*20+130;
    if #self.unRecruitList > 0 then
        height = self.queues1[#self.queues1].row*GeneralMapItem.HEIGHT+(self.queues1[#self.queues1].row-1)*20+
        self.queues2[#self.queues2].row*GeneralMapItem.HEIGHT+(self.queues2[#self.queues2].row-1)*20+130;
    end
    itemLay:setSize(cc.size(self.ListView:getContentSize().width, height));
    self.ListView:pushBackCustomItem(itemLay);

    local function loadEachItem(dt)
        if itemIndex > #self.queues1 then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
            if #self.unRecruitList > 0 then
                self:createUnRecruitGeneral(itemLay);
            end
        else
            local item = GeneralMapItem.create(self);
            item:setAnchorPoint(cc.p(0, 0));
            self.curPosY = itemLay:getContentSize().height-self.queues1[itemIndex].row*GeneralMapItem.HEIGHT-(self.queues1[itemIndex].row-1)*20;
            item:setPosition(cc.p(8+self.queues1[itemIndex].col*GeneralMapItem.WIDTH,self.curPosY));
            itemLay:addChild(item);
            if itemIndex > self.iCount then--已招募的
                item:setData(self.gmMyList[itemIndex],self.soldierList,true);
            else--未招募
                item:setData(self.gmMyList[itemIndex],self.soldierList,false);
            end

            itemIndex = itemIndex+1;
        end
    end

    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
    end
    self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(loadEachItem, 0.001, false);
end

function GeneralMapLayer:createUnRecruitGeneral(itemLay)--未招募的武将
    self.curPosY = self.curPosY - 60;
    local lineSpr1 = cc.Sprite:createWithSpriteFrameName("general_line.png");
    lineSpr1:setPosition(cc.p(lineSpr1:getContentSize().width/2+30, self.curPosY));
    itemLay:addChild(lineSpr1);

    local lineSpr2 = cc.Sprite:createWithSpriteFrameName("general_line.png");
    lineSpr2:setPosition(cc.p(itemLay:getContentSize().width-lineSpr2:getContentSize().width/2-30, self.curPosY));
    lineSpr2:setScaleX(-1);--setFlippedX
    itemLay:addChild(lineSpr2);

    local titSpr = cc.Sprite:createWithSpriteFrameName("general_unRecruit_title.png");
    titSpr:setPosition(cc.p(itemLay:getContentSize().width/2, self.curPosY));
    itemLay:addChild(titSpr);

    local itemIndex = 1;
    self.curPosY = self.curPosY - 20;
    local function loadEachItem(dt)
        if itemIndex > #self.queues2 then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
        else
            local item = GeneralMapItem.create(self);
            item:setAnchorPoint(cc.p(0, 0));
            item:setPosition(cc.p(8+self.queues2[itemIndex].col*GeneralMapItem.WIDTH,
                self.curPosY-self.queues2[itemIndex].row*(GeneralMapItem.HEIGHT+20)));
            itemLay:addChild(item);
            item:setData(self.unRecruitList[itemIndex],self.soldierList,false);
            -- item:setIsGray(true);
            
            itemIndex = itemIndex+1;
        end
    end

    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
    end
    self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(loadEachItem, 0.001, false);
end

function GeneralMapLayer:HeroHeadSelect(head)
    self.curGm = head.gm;
    if head.isGet == true then--已获得的武将点击事件
        local _Layer = heroMainLayer.showBox(self,self.type,head.gm);
        if self.delegate and self.delegate.removeCurLayer then
            -- self.delegate:removeCurLayer();
            -- self:removeFromParent();
        end
    else
        local resNum,totNum = getGeneralNeedDebrisNum(head.gm,false);
        if resNum >= totNum then--招募武将
            self:sendDoRecruitReq(self.curGm:getId());
        else--进入未获得武将详情
            local _unGetGeneral = unGetGeneral.showBox(self);
            _unGetGeneral:setData(head.gm);
        end
        
    end
end

function GeneralMapLayer:onBackClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        self:removeFromParent();
    end
end

function GeneralMapLayer:onButtonClick(sender, eventType)
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
        if sender == self.Button_close then
            self:removeFromParent();
        end
    end
end

function GeneralMapLayer:onReciveData(MsgID, NetData)
    print("LoadingPanel onReciveData MsgID:"..MsgID)
    
    local ackData = NetData;
    if MsgID == Post_doUseEquip then
        if ackData.state == 1 then
            
        else
            NetHandler:showFailedMessage(ackData)
        end
    elseif MsgID == Post_General_doRecruit then
        if ackData.state == 1 then
            local usercardGetHero = usercardGetHero.create(self);
            usercardGetHero:setData(self.curGm);
            cc.Director:getInstance():getRunningScene():addChild(usercardGetHero,ZORDER_MAX+1);
            self:setData();
            self.curGm = nil;
        else
            NetHandler:showFailedMessage(ackData)
        end
    end
    
end

function GeneralMapLayer:sendReq(id,pos)
    local str = string.format("&g_id=%d&pos=%d&is_all=%d",id,pos,0);
    NetHandler:sendData(Post_doUseEquip, str);
end

function GeneralMapLayer:sendDoRecruitReq(id)
    local str = "&g_id="..id;
    NetHandler:sendData(Post_General_doRecruit, str);
end

function GeneralMapLayer:pushAck()
    NetHandler:addAckCode(self,Post_doUseEquip);
    NetHandler:addAckCode(self,Post_General_doRecruit);
end

function GeneralMapLayer:popAck()
    NetHandler:delAckCode(self,Post_doUseEquip);
    NetHandler:delAckCode(self,Post_General_doRecruit);
end

function GeneralMapLayer:onEnter()
    self:pushAck();
end

function GeneralMapLayer:onExit()
    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
    end
    MGRCManager:releaseResources("GeneralMapLayer");
    self:popAck();
end

function GeneralMapLayer.create(delegate,type)
    local layer = GeneralMapLayer:new()
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

function GeneralMapLayer.showBox(delegate,type)
    local layer = GeneralMapLayer.create(delegate,type);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
