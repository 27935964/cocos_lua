--------------------------君王之路排行Item-----------------------

local kingRoadRankItem = class("kingRoadRankItem", MGWidget);

function kingRoadRankItem:init(delegate,widget)
    self.delegate=delegate;
    self:addChild(widget);
    self.pWidget = widget;

    local Panel_2 = self.pWidget:getChildByName("Panel_2");
    self:setContentSize(Panel_2:getContentSize());

    self.Panel_2 = Panel_2;
    self.Panel_2:addTouchEventListener(handler(self,self.onButtonClick));

    self.Image_rank = Panel_2:getChildByName("Image_rank");
    self.Label_rank = Panel_2:getChildByName("Label_rank");
    self.Label_name = Panel_2:getChildByName("Label_name");

    self.Label_num = Panel_2:getChildByName("Label_num");
    self.Label_lv = Panel_2:getChildByName("Label_lv");
    self.Image_crown = Panel_2:getChildByName("Image_crown");
    self.Image_class = Panel_2:getChildByName("Image_class");
    
    local Panel_head = Panel_2:getChildByName("Panel_head");
    self.itemHead = userHead.create(self);
    self.itemHead:setScale(0.75);
    self.itemHead:setPosition(cc.p(Panel_head:getContentSize().width/2,Panel_head:getContentSize().height/2));
    Panel_head:addChild(self.itemHead);
    
end

function kingRoadRankItem:setData(rankData,king_lv)
    self.rankData = rankData;
    self.king_lv = king_lv;

    local lv = tonumber(self.rankData.a_lv);
    self.Image_crown:loadTexture(self.king_lv[lv].pic..".png",ccui.TextureResType.plistType);
    self.Image_class:loadTexture(self.king_lv[lv].name_pic..".png",ccui.TextureResType.plistType);
    self.Label_name:setText(unicode_to_utf8(self.rankData.name));
    self.Label_num:setText(self.rankData.a_point);
    self.Label_lv:setText(string.format("Lv.%d",tonumber(self.rankData.lv)));

    local gm = GENERAL:getAllGeneralModel(tonumber(self.rankData.head));
    if gm then
        self.itemHead:setData(gm)
    end
    
    if tonumber(self.rankData.rank) <= 3 then
        self.Label_rank:setVisible(false);
        self.Image_rank:setVisible(true);
        self.Image_rank:loadTexture(string.format("com_rank_cup_%d.png",tonumber(self.rankData.rank)),
            ccui.TextureResType.plistType);
    else
        self.Label_rank:setVisible(true);
        self.Image_rank:setVisible(false);
        self.Label_rank:setText(self.rankData.rank);
    end
end

function kingRoadRankItem:onButtonClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        require "playerInfo";
        local playerInfo = playerInfo.create(self);
        playerInfo:setData(self.rankData.uid,unicode_to_utf8(self.rankData.name));
        cc.Director:getInstance():getRunningScene():addChild(playerInfo,ZORDER_MAX);
    end
end

function kingRoadRankItem:onEnter()
    
end

function kingRoadRankItem:onExit()
    MGRCManager:releaseResources("kingRoadRankItem");
end

function kingRoadRankItem.create(delegate,widget)
    local layer = kingRoadRankItem:new()
    layer:init(delegate,widget)
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

return kingRoadRankItem