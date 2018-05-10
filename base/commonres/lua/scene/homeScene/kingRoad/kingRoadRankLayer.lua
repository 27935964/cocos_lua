--------------------------君王之路任务Item-----------------------
require "playerInfo"

local kingRoadRankItem = require "kingRoadRankItem";
kingRoadRankLayer = class("kingRoadRankLayer", MGLayer);

function kingRoadRankLayer:ctor()
    self:init();
end

function kingRoadRankLayer:init()
    local pWidget = MGRCManager:widgetFromJsonFile("kingRoadRankLayer","TheRoadOfKings_Rank_Ui.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:setAnchorPoint(cc.p(0.5, 0.5));
    CommonMethod:setFullBgScale(self.Panel_1);
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));

    local Panel_2 = pWidget:getChildByName("Panel_2");

    self.Label_num = Panel_2:getChildByName("Label_MyachievementPoint2");
    self.Image_class = Panel_2:getChildByName("Image_class");
    self.Image_crown = Panel_2:getChildByName("Image_crown");
    self.Image_name = Panel_2:getChildByName("Image_name");
    self.Image_null = Panel_2:getChildByName("Image_null");
    self.Image_null:setVisible(false);
    self.Label_Name = Panel_2:getChildByName("Label_Name");
    self.Label_Level = Panel_2:getChildByName("Label_Level");
    self.Label_Point = Panel_2:getChildByName("Label_Point");
    self.Image_myRank = Panel_2:getChildByName("Image_myRank");
    self.Label_MyRank = Panel_2:getChildByName("Label_MyRank");
    self.Label_MyRank:setVisible(false);
    self.Label_tip = Panel_2:getChildByName("Label_tip");

    self.Button_close = Panel_2:getChildByName("Button_close");
    self.Button_close:addTouchEventListener(handler(self,self.onButtonClick));

    self.Image_Flag = Panel_2:getChildByName("Image_Flag");
    self.Image_Flag:setTouchEnabled(true);
    self.Image_Flag:addTouchEventListener(handler(self,self.onButtonClick));

    self.ListView = Panel_2:getChildByName("ListView");
    self.ListView:setScrollBarVisible(false);

    local Image_HeadBox = Panel_2:getChildByName("Image_HeadBox");
    local HeroCircleHead=require "HeroCircleHead";--菱形头像
    self.circleHead=HeroCircleHead.new("THeRoadofKings_Rank_HeadPortraitShade.png",0.98);
    self.circleHead:setPosition(cc.p(Image_HeadBox:getContentSize().width/2,Image_HeadBox:getContentSize().height/2));
    Image_HeadBox:addChild(self.circleHead,1);

    local Label_Tips = Panel_2:getChildByName("Label_Tips");
    Label_Tips:setText(MG_TEXT_COCOS("TheRoadOfKings_Rank_Ui_1"));

    if not self.itemWidget then
        self.itemWidget = MGRCManager:widgetFromJsonFile("kingRoadRankLayer", "TheRoadOfKings_Rank_Item_Ui.ExportJson",false);
        self.itemWidget:retain();
    end
end

function kingRoadRankLayer:setData(data,king_lv)
    self.data = data;
    self.ranklist = data.ranklist;
    self.king_lv = king_lv;

    if #self.ranklist >= 1 then
        local rankData = self.ranklist[1];
        local lv = tonumber(rankData.a_lv);
        self.Image_crown:loadTexture(self.king_lv[lv].pic..".png",ccui.TextureResType.plistType);
        self.Image_name:loadTexture(self.king_lv[lv].name_pic..".png",ccui.TextureResType.plistType);
        self.Label_Name:setText(unicode_to_utf8(rankData.name));
        self.Label_Level:setText(string.format("Lv.%d",tonumber(rankData.lv)));
        self.Label_Point:setText(tonumber(rankData.a_point));

        local gm = GENERAL:getAllGeneralModel(tonumber(rankData.head));
        if gm then
            self.circleHead:setHeroFace(gm:bust());
            self.circleHead:setHeadScale(1.2);
        end
        self.Label_tip:setVisible(false);
    else
        self.Image_null:setVisible(true);
        self.Image_Flag:setTouchEnabled(false);
        self.Label_Name:setVisible(false);
        self.Label_Level:setVisible(false);
        self.Label_tip:setVisible(true);
    end

    self.Label_MyRank:setVisible(true);
    self.Image_myRank:setVisible(false);
    if tonumber(self.data.self.rank) <= 3 then
        self.Image_myRank:setVisible(true);
        self.Label_MyRank:setVisible(false);
        self.Image_myRank:loadTexture(string.format("com_rank_cup_%d.png",tonumber(self.data.self.rank)),
            ccui.TextureResType.plistType);
    elseif tonumber(self.data.self.rank) > 3 and tonumber(self.data.self.rank) <= 999 then
        self.Label_MyRank:setText(self.data.self.rank);
    else
        self.Label_MyRank:setText(MG_TEXT("kingRoadMainLayer_2"));
    end

    self:createItem();
end

function kingRoadRankLayer:createItem()
    self.ListView:removeAllItems();
    local totalNum = #self.ranklist;
    if totalNum == 0 then
        return;
    end

    local itemIndex = 2;
    local function loadEachItem(dt)
        if itemIndex > totalNum then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
        else
            local item = kingRoadRankItem.create(self,self.itemWidget:clone());
            item:setData(self.ranklist[itemIndex],self.king_lv);
            self.ListView:pushBackCustomItem(item);

            self.ListView:setItemsMargin(5);
            itemIndex = itemIndex+1;
        end
    end

    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
    end
    self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(loadEachItem, 0.001, false);
end

function kingRoadRankLayer:onButtonClick(sender, eventType)
    if sender == self.Button_close then
        buttonClickScale(sender, eventType);
    end
    if eventType == ccui.TouchEventType.ended then
        if sender == self.Image_Flag then
            if #self.ranklist >= 1 then
                require "playerInfo";
                local rankData = self.ranklist[1];
                local playerInfo = playerInfo.create(self);
                playerInfo:setData(rankData.uid,unicode_to_utf8(rankData.name));
                cc.Director:getInstance():getRunningScene():addChild(playerInfo,ZORDER_MAX);
            end
        else
            self:removeFromParent();
        end
    end
end

function kingRoadRankLayer:onEnter()
    
end

function kingRoadRankLayer:onExit()
    MGRCManager:releaseResources("kingRoadRankLayer");
    if self.itemWidget then
        self.itemWidget:release();
    end
    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
    end
end

function kingRoadRankLayer.create(delegate)
    local layer = kingRoadRankLayer:new()
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

function kingRoadRankLayer.showBox(delegate)
    local layer = kingRoadRankLayer.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end