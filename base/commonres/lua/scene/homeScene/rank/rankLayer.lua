-----------------------将领属性界面------------------------
require "PanelTop"
require "rankItem"
require "rankleftItem"
require "playerInfo"
require "dialog"

local rank=require "rank"

rankLayer = class("rankLayer", MGLayer)

function rankLayer:ctor()
    self:init();
end

function rankLayer:init()
    MGRCManager:cacheResource("rankLayer", "package_bg.jpg");
    MGRCManager:cacheResource("rankLayer", "rank_head_bg.png");
    MGRCManager:cacheResource("rankLayer", "rank_bottom_Bg.png");
    local size = cc.Director:getInstance():getWinSize();
    local bgSpr = cc.Sprite:create("package_bg.jpg");
    bgSpr:setPosition(cc.p(size.width/2, size.height));
    bgSpr:setAnchorPoint(cc.p(0.5,1));
    self:addChild(bgSpr);


    local pWidget = MGRCManager:widgetFromJsonFile("rankLayer","rank_ui_1.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);--设置描边或者阴影


    self.pPanelTop = PanelTop.create(self)
    self.pPanelTop:setData("rank_title.png");
    self:addChild(self.pPanelTop,10);
    
    local Panel_2 = pWidget:getChildByName("Panel_2");
    local Panel_left = Panel_2:getChildByName("Panel_left");
    self.list = Panel_left:getChildByName("ListView_left");

    local Panel_mid = Panel_2:getChildByName("Panel_mid");
    self.listrank = Panel_mid:getChildByName("ListView");
    self.Image_head = Panel_mid:getChildByName("Image_head");
    local Image_bottom = Panel_mid:getChildByName("Image_bottom");
    local m_panel=ccui.Layout:create();
    m_panel:setSize(cc.size(1123,60));
    Image_bottom:addChild(m_panel);

    self.Label_rank1 = MGColorLabel:label();
    m_panel:addChild(self.Label_rank1);

    self.Label_rank2 = MGColorLabel:label();
    m_panel:addChild(self.Label_rank2);

    self.Label_rank3 = MGColorLabel:label();
    m_panel:addChild(self.Label_rank3);

    self:createlist();
end

function rankLayer:createlist()
    self.list:removeAllItems();
    for i=1,#rank do
        local rankleftItem = rankleftItem.create(self);
        rankleftItem:setData(rank[i]);
        self.list:pushBackCustomItem(rankleftItem);
        if i==1 then
            self:rankleftItemSelect(rankleftItem);
        end
    end


end

function rankLayer:back()
    self:removeFromParent();
end

function rankLayer:rankleftItemSelect(item)
    if  self.selItem~=item then
        if self.selItem then
            self.selItem:Select(false);
        end
        self.selItem = item;
        self.selItem:Select(true);

        local pic = string.format("rank_head_%d.png",self.selItem.info.id);
        self.Image_head:loadTexture(pic,ccui.TextureResType.plistType);
        self.listrank:removeAllItems();
        self.Label_rank1:setVisible(false);
        self.Label_rank2:setVisible(false);
        self.Label_rank3:setVisible(false);
        self:sendReq();
    end
end

function rankLayer:rankItemSelect(item)
    local playerInfo = playerInfo.create(self);
    playerInfo:setData(item.info.uid,item.info.name);
    cc.Director:getInstance():getRunningScene():addChild(playerInfo,ZORDER_MAX);
end


function rankLayer:showRank()
    for i=1,#self.getrank.ranklist do
        local rankItem = rankItem.create(self);
        rankItem:setData(self.selItem.info.id,self.getrank.ranklist[i]);
        self.listrank:pushBackCustomItem(rankItem);
    end

    if self.selItem.info.id == 1 then
        self.Label_rank1:setVisible(true);
        self.Label_rank2:setVisible(true);

        self.Label_rank1:clear();
        self.Label_rank1:setPosition(cc.p(432,30));
        self.Label_rank1:appendString(MG_TEXT("rank_1"), cc.c3b(186, 167, 100), ttf_msyh, 22);
        self.Label_rank1:appendString(string.format(" %d",self.getrank.self.rank), Color3B.WHITE, ttf_msyh, 22)

        self.Label_rank2:clear();
        self.Label_rank2:setPosition(cc.p(666,30));
        self.Label_rank2:appendString(MG_TEXT("rank_2"), cc.c3b(186, 167, 100), ttf_msyh, 22);
        self.Label_rank2:appendString(string.format(" %d",self.getrank.self.score), Color3B.WHITE, ttf_msyh, 22)
    elseif self.selItem.info.id == 2 then
        self.Label_rank1:setVisible(true);
        self.Label_rank2:setVisible(true);
        self.Label_rank3:setVisible(true);

        self.Label_rank1:clear();
        self.Label_rank1:setPosition(cc.p(319,30));
        self.Label_rank1:appendString(MG_TEXT("rank_1"), cc.c3b(186, 167, 100), ttf_msyh, 22);
        self.Label_rank1:appendString(string.format(" %d",self.getrank.self.rank), Color3B.WHITE, ttf_msyh, 22)

        self.Label_rank2:clear();
        self.Label_rank2:setPosition(cc.p(531,30));
        self.Label_rank2:appendString(MG_TEXT("rank_3"), cc.c3b(186, 167, 100), ttf_msyh, 22);
        self.Label_rank2:appendString(unicode_to_utf8(self.getrank.self.g_name), Color3B.WHITE, ttf_msyh, 22)

        self.Label_rank3:clear();
        self.Label_rank3:setPosition(cc.p(806,30));
        self.Label_rank3:appendString(MG_TEXT("rank_4"), cc.c3b(186, 167, 100), ttf_msyh, 22);
        self.Label_rank3:appendString(string.format(" %d",self.getrank.self.g_score), Color3B.WHITE, ttf_msyh, 22)
    elseif self.selItem.info.id == 3 then
        self.Label_rank1:setVisible(true);

        self.Label_rank1:clear();
        self.Label_rank1:setPosition(cc.p(579,30));
        self.Label_rank1:appendString(MG_TEXT("rank_1"), cc.c3b(186, 167, 100), ttf_msyh, 22);
        self.Label_rank1:appendString(string.format(" %d",self.getrank.self.rank), Color3B.WHITE, ttf_msyh, 22)
    elseif self.selItem.info.id == 4 then
        self.Label_rank1:setVisible(true);
        self.Label_rank2:setVisible(true);

        self.Label_rank1:clear();
        self.Label_rank1:setPosition(cc.p(432,30));
        self.Label_rank1:appendString(MG_TEXT("rank_1"), cc.c3b(186, 167, 100), ttf_msyh, 22);
        self.Label_rank1:appendString(string.format(" %d",self.getrank.self.rank), Color3B.WHITE, ttf_msyh, 22)

        self.Label_rank2:clear();
        self.Label_rank2:setPosition(cc.p(666,30));
        self.Label_rank2:appendString(MG_TEXT("rank_4"), cc.c3b(186, 167, 100), ttf_msyh, 22);
        self.Label_rank2:appendString(string.format(" %d",self.getrank.self.score), Color3B.WHITE, ttf_msyh, 22)
    elseif self.selItem.info.id == 5 then
        self.Label_rank1:setVisible(true);
        self.Label_rank2:setVisible(true);
        self.Label_rank3:setVisible(true);

        self.Label_rank1:clear();
        self.Label_rank1:setPosition(cc.p(319,30));
        self.Label_rank1:appendString(MG_TEXT("rank_1"), cc.c3b(186, 167, 100), ttf_msyh, 22);
        self.Label_rank1:appendString(string.format(" %d",self.getrank.self.rank), Color3B.WHITE, ttf_msyh, 22)

        self.Label_rank2:clear();
        self.Label_rank2:setPosition(cc.p(531,30));
        self.Label_rank2:appendString(MG_TEXT("rank_5"), cc.c3b(186, 167, 100), ttf_msyh, 22);
        self.Label_rank2:appendString(string.format(" %d",self.getrank.self.full_star), Color3B.WHITE, ttf_msyh, 22)

        self.Label_rank3:clear();
        self.Label_rank3:setPosition(cc.p(806,30));
        self.Label_rank3:appendString(MG_TEXT("rank_6"), cc.c3b(186, 167, 100), ttf_msyh, 22);
        self.Label_rank3:appendString(string.format(" %d",self.getrank.self.star_num), Color3B.WHITE, ttf_msyh, 22)
     elseif self.selItem.info.id == 6 then
        self.Label_rank1:setVisible(true);

        self.Label_rank1:clear();
        self.Label_rank1:setPosition(cc.p(579,30));
        self.Label_rank1:appendString(MG_TEXT("rank_1"), cc.c3b(186, 167, 100), ttf_msyh, 22);
        self.Label_rank1:appendString(string.format(" %d",self.getrank.self.rank), Color3B.WHITE, ttf_msyh, 22)
    end
end


function rankLayer:sendReq()
    --@Input     type Int 排行榜类型(1总战力榜,2最强战力榜,3英雄榜,4疆土榜)
    if self.selItem.info.type>0 then
        local str = string.format("&type=%d",self.selItem.info.type);
        NetHandler:sendData(Post_getRank, str);
    else
         MGMessageTip:showFailedMessage(MG_TEXT("Unopen"));
    end
end

function rankLayer:onReciveData(MsgID, NetData)
    print("rankLayer onReciveData MsgID:"..MsgID)
    
    if MsgID == Post_getRank then
        local ackData = NetData
        if ackData.state == 1 then
            self.getrank = ackData.getrank;
            self:showRank();
        else
            NetHandler:showFailedMessage(ackData)
        end
    end
    
end



function rankLayer:pushAck()
    NetHandler:addAckCode(self,Post_getRank);
end

function rankLayer:popAck()
    NetHandler:delAckCode(self,Post_getRank);
end

function rankLayer:onEnter()
    self:pushAck();
end

function rankLayer:onExit()
    MGRCManager:releaseResources("rankLayer");
    self:popAck();
end

function rankLayer.create(delegate)
    local layer = rankLayer:new()
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


function rankLayer.showBox(delegate)
    local layer = rankLayer.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
