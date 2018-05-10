-----------------------试炼战报-----------------
require "userHead"

enemyInfo = class("enemyInfo", MGLayer)

function enemyInfo:ctor()
    self:init();
end

function enemyInfo:init()
    MGRCManager:cacheResource("enemyInfo", "HemitIsland_defensive_lineup.png");
    local pWidget = MGRCManager:widgetFromJsonFile("enemyInfo","recoverroad_enemy_info.ExportJson");
    self:addChild(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));
    self.Panel_1:setAnchorPoint(cc.p(0.5, 0.5));
    CommonMethod:setFullBgScale(self.Panel_1);

    local Panel_2 = pWidget:getChildByName("Panel_2");
    self.Image_title = Panel_2:getChildByName("Image_title");

    self.ListView = Panel_2:getChildByName("ListView");
    -- self.ListView:setItemsMargin(5);
    self.ListView:setScrollBarVisible(false);

    self.Button_close = Panel_2:getChildByName("Button_close");
    self.Button_close:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_challenge = Panel_2:getChildByName("Button_challenge");--挑战
    self.Button_challenge:addTouchEventListener(handler(self,self.onButtonClick));
    

    local Image_infoBg = Panel_2:getChildByName("Image_infoBg");
    self.Label_name = Image_infoBg:getChildByName("Label_name");
    self.Label_lv = Image_infoBg:getChildByName("Label_lv");
    self.BitmapLabel = Image_infoBg:getChildByName("BitmapLabel");
    local Panel_head = Image_infoBg:getChildByName("Panel_head");

    self.heroHead = userHead.create(self);
    self.heroHead:setAnchorPoint(cc.p(0.5, 0.5));
    self.heroHead:setPosition(cc.p(Panel_head:getContentSize().width/2,Panel_head:getContentSize().height/2));
    Panel_head:addChild(self.heroHead,2);

    local Label_power = Image_infoBg:getChildByName("Label_power");
    local Label_challenge = self.Button_challenge:getChildByName("Label_challenge");

    Label_power:setText(MG_TEXT_COCOS("recoverroad_enemy_info_1"));
    Label_challenge:setText(MG_TEXT_COCOS("recoverroad_enemy_info_2"));

end

function enemyInfo:setData(data,isNpc)
    self.data = data;

    self.isNpc = false;
    if isNpc == true then--如果是Npc
        self.isNpc = true;
        self:setNpcData();
    else
        self:setPlayerData();
    end
    
end

function enemyInfo:setPlayerData()
    self.dfd_corps = self.data.dfd_corp;

    local gm = GENERAL:getAllGeneralModel(self.data.dfd_head);
    if gm then
        self.heroHead:setData(gm)
    end
    self.Label_name:setText(unicode_to_utf8(self.data.dfd_name));
    self.BitmapLabel:setText(self.data.dfd_score);
    self.Label_lv:setText(string.format("Lv.%d",self.data.dfd_lv));
    self.Image_title:loadTexture(self.fileName,ccui.TextureResType.plistType);
    self.Label_lv:setPositionX(self.Label_name:getPositionX()+self.Label_name:getContentSize().width+20);

    self:creatItem();
end

function enemyInfo:setNpcData()
    self.dfd_corps = {};
    for i=1,#self.data.corps do
        local corps = {};
        corps.g_id = self.data.corps[i].value2;
        table.insert(self.dfd_corps,corps);
    end

    self.heroHead:setHeadData(self.data.head);
    self.Label_name:setText(self.data.name);
    self.BitmapLabel:setText(self.data.score);
    self.Label_lv:setText(string.format("Lv.%d",self.data.lv));
    self.Image_title:loadTexture(self.fileName,ccui.TextureResType.plistType);
    self.Label_lv:setPositionX(self.Label_name:getPositionX()+self.Label_name:getContentSize().width+20);

    self:creatItem();
end

function enemyInfo:creatItem()
    self.ListView:removeAllItems();
    local itemLay = ccui.Layout:create();
    itemLay:setSize(cc.size(self.ListView:getContentSize().width, self.ListView:getContentSize().height));
    if #self.dfd_corps > 5 then
        itemLay:setSize(cc.size(#self.dfd_corps*130, self.ListView:getContentSize().height));
    end
    self.ListView:pushBackCustomItem(itemLay);

    self.items = {};
    for i=1,#self.dfd_corps do
        local item = HeroHeadEx.create(self);
        if self.isNpc == false then
            item:setEnemyData(self.dfd_corps[i].g_id,self.dfd_corps[i].lv,self.dfd_corps[i].quality,self.dfd_corps[i].star);
        else
            local gm = NPCGeneralModel:create(self.dfd_corps[i].g_id);
            item:setData(gm,true);
        end
        itemLay:addChild(item);
        item:setPosition(cc.p(item:getContentSize().width/2+(i-1)*(item:getContentSize().width+20),itemLay:getContentSize().height/2));
        table.insert(self.items,item);
    end

    if #self.items <= 5 and #self.items > 0 then
        local pos = getItemPositionX(self.items,itemLay:getContentSize().width/2);
        for i=1,#self.items do
            self.items[i]:setPositionX(pos[i]);
        end
    end
end

function enemyInfo:onButtonClick(sender, eventType)
    if sender ~= self.Panel_1 then
        buttonClickScale(sender, eventType);
    end

    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_challenge then
            if self.delegate and self.delegate.challenge then
                self.delegate:challenge(self);
            end
        end
        self:removeFromParent();
    end
end

function enemyInfo:onEnter()

end

function enemyInfo:onExit()
    MGRCManager:releaseResources("enemyInfo");
    if self.itemWidget then
        self.itemWidget:release();
    end
end

function enemyInfo.create(delegate,fileName)
    local layer = enemyInfo:new()
    layer.delegate = delegate
    layer.fileName = fileName
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

function enemyInfo.showBox(delegate,fileName)
    local layer = enemyInfo.create(delegate,fileName);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
