-----------------------将领属性界面------------------------
require "treasureInfo"
treasureLayer = class("treasureLayer", MGLayer)

function treasureLayer:ctor()
    self:init();
    self.getPositionY =nil;
end

function treasureLayer:init()
    
    MGRCManager:cacheResource("treasureLayer","treasure_fazhen_1.png");
    local pWidget = MGRCManager:widgetFromJsonFile("treasureLayer","treasure_ui_1.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);--设置描边或者阴影
    
    local Panel_2 = pWidget:getChildByName("Panel_2");
    local Panel_mid = Panel_2:getChildByName("Panel_mid");

    self.Button_tabs = {};
    for i=1,6 do
        local Button_tab = Panel_mid:getChildByName("Button_tab_"..i);
        Button_tab:addTouchEventListener(handler(self,self.onButtonClick));
        table.insert(self.Button_tabs,Button_tab);
    end
    self.posy0 = self.Button_tabs[1]:getPositionY();
    self.posy1 = self.posy0 - 11;
    self.Button_tabs[1]:setPositionY(self.posy1);
    self.tab = 1;

    self.Image_zhen_bg = Panel_mid:getChildByName("Image_zhen_bg");
    self.Image_zhen = self.Image_zhen_bg:getChildByName("Image_zhen");
    self.Button_goods = {};
    self.attojs = {};
    for i=1,4 do
        local Button_good = self.Image_zhen_bg:getChildByName("Button_goods_"..i);
        Button_good:addTouchEventListener(handler(self,self.onButtonClick));
        table.insert(self.Button_goods,Button_good);

        local Image_att = self.Image_zhen_bg:getChildByName("Image_att_"..i);
        local attoj = {};
        attoj.Label_name =  Image_att:getChildByName("Label_name");
        attoj.Label_att_name_1 =  Image_att:getChildByName("Label_att_name_1");
        attoj.Label_att_name_2 =  Image_att:getChildByName("Label_att_name_2");
        attoj.Label_att_num1 =  Image_att:getChildByName("Label_att_num1");
        attoj.Label_att_num2 =  Image_att:getChildByName("Label_att_num2");
        table.insert(self.attojs,attoj);
    end

    local  Image_right_bg = Panel_mid:getChildByName("Image_right_bg");
    self.Label_tao = Image_right_bg:getChildByName("Label_tao");
    local  Label_tip = Image_right_bg:getChildByName("Label_tip");
    Label_tip:setText(MG_TEXT_COCOS("treasure_ui_1"));
    self.Label_gold = Image_right_bg:getChildByName("Label_gold");
    self.Button_active = Image_right_bg:getChildByName("Button_active");
    self.Button_active:addTouchEventListener(handler(self,self.onButtonClick));
    self.Label_active = Image_right_bg:getChildByName("Label_active");
    self.Label_active:setText(MG_TEXT_COCOS("treasure_ui_2"));

    local  Image_att = Image_right_bg:getChildByName("Image_att");
    self.tao_attoj = {};
    self.tao_attoj.Label_att_name_1 =  Image_att:getChildByName("Label_att_name_1");
    self.tao_attoj.Label_att_name_2 =  Image_att:getChildByName("Label_att_name_2");
    self.tao_attoj.Label_att_num1 =  Image_att:getChildByName("Label_att_num1");
    self.tao_attoj.Label_att_num2 =  Image_att:getChildByName("Label_att_num2");

    self:changeTab();
    --self:sendReq();
end

function treasureLayer:setData(gm)
    self.gm = gm;
    local treasureStates = self.gm:getTreasurelist();
    print("1111"..#treasureStates )
    for i=1,6 do
        local Image_lock = self.Button_tabs[i]:getChildByName("Image_lock");
        Image_lock:setVisible(true);
    end

    for i=1,#treasureStates do
        local x = treasureStates[i]:id();
        local Image_lock = self.Button_tabs[x]:getChildByName("Image_lock");
        Image_lock:setVisible(false);
    end
    self:setTreasureState();
end

function treasureLayer:setTreasureState()
    self.treasureState = self.gm:getTreasure(self.tab);
    if self.treasureState then
        if self.treasureState:isactive()==1 then
            self.Button_active:setEnabled(false);
            self.Label_active:setText(MG_TEXT_COCOS("treasure_ui_3"));
        elseif self.treasureState:canactive()==1 then
            self.Button_active:setEnabled(true);
            self.Label_active:setText(MG_TEXT_COCOS("treasure_ui_2"));
        else
            self.Button_active:setEnabled(false);
            self.Label_active:setText(MG_TEXT_COCOS("treasure_ui_4"));
        end
        local treasureInfos = self.treasureSuit:getTreasureInfo();
        for i=1,#treasureInfos do

            local  Image_goods =  self.Button_goods[i]:getChildByName("Image_goods");
            if self.treasureState:gettreasure(treasureInfos[i]:id())==0 then
                Image_goods:setColor(Color3B.GRAY);
            else
                Image_goods:setColor(Color3B.WHITE);
            end
        end
    else
        self.Button_active:setEnabled(false);
        self.Label_active:setText(MG_TEXT_COCOS("treasure_ui_5"));
        for i=1,#self.Button_goods do
            local  Image_goods =  self.Button_goods[i]:getChildByName("Image_goods");
            Image_goods:setColor(Color3B.GRAY);
        end
    end
end

function treasureLayer:onButtonClick(sender, eventType)
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
        -- if sender == self.Button_minus or sender == self.Button_add or sender == self.Button_max then
        --     self:setNum(sender);
        -- else
            for i=1,#self.Button_tabs do
                if sender == self.Button_tabs[i] and self.tab~=i then
                    self.Button_tabs[self.tab]:setPositionY(self.posy0);
                    self.Button_tabs[i]:setPositionY(self.posy1);
                    self.tab = i;
                    self:changeTab();
                    return;
                end
            end
            for i=1,#self.Button_goods do
                if sender == self.Button_goods[i] then
                    local infopanel = treasureInfo.create(self);
                    local treasureInfos = self.treasureSuit:getTreasureInfo();
                    infopanel:setData(self.gm:getId(),treasureInfos[i],self.treasureSuit:needlv(),self.treasureState);
                    cc.Director:getInstance():getRunningScene():addChild(infopanel,ZORDER_MAX);
                    return;
                end
            end
            if sender == self.Button_active then
                self:sendReq();
            end
        -- end
    end
end

function treasureLayer:sendReq()
    -- @Summary    激活宝物套装
    -- @Input    g_id Int 将领ID
    -- suit_id Int 套装ID
    local str = string.format("&g_id=%d&suit_id=%d",self.gm:getId(),self.treasureSuit:id());
    NetHandler:sendData(Post_doActivationSuit, str);
end

function treasureLayer:setTreasure(t_id)
    -- @Summary  装备宝物
    -- @Input    g_id Int 将领ID
    -- t_id Int 宝物ID
    -- suit_id Int 套装ID
    -- @Output    is_ok Int 成功
    local str = string.format("&g_id=%d&t_id=%d&suit_id=%d",self.gm:getId(),t_id,self.treasureSuit:id())
    NetHandler:sendData(Post_doSetTreasure, str);
end

function treasureLayer:changeTab()
    self.treasureSuit = treasureData:gettreasureSuit(self.tab)
    self.Label_tao:setText(self.treasureSuit:name());
    local treasureInfos = self.treasureSuit:getTreasureInfo();
    for i=1,#self.attojs do
        MGRCManager:cacheResource("treasureLayer", treasureInfos[i]:pic());
        local  Image_goods =  self.Button_goods[i]:getChildByName("Image_goods");
        Image_goods:loadTexture(treasureInfos[i]:pic(),ccui.TextureResType.plistType);
        self.attojs[i].Label_name:setText(treasureInfos[i]:name());

        local attInfo= treasureInfos[i]:getAttInfo()

        self.attojs[i].Label_att_name_1:setText(string.format("%s",attInfo[1]:name())); 
        self.attojs[i].Label_att_name_2:setText(string.format("%s",attInfo[2]:name())); 
        self.attojs[i].Label_att_num1:setText(string.format("%d",attInfo[1]:getAttCount()));
        self.attojs[i].Label_att_num2:setText(string.format("%d",attInfo[2]:getAttCount()));

    end
    local needItem = self.treasureSuit:getNeedItem()
    self.Label_gold:setText(string.format("%d",needItem:getNum()));

    local attInfo= self.treasureSuit:getAttInfo()
    self.tao_attoj.Label_att_name_1:setText(string.format("%s",attInfo[1]:name())); 
    self.tao_attoj.Label_att_name_2:setText(string.format("%s",attInfo[2]:name())); 
    self.tao_attoj.Label_att_num1:setText(string.format("%d",attInfo[1]:getAttCount()));
    self.tao_attoj.Label_att_num2:setText(string.format("%d",attInfo[2]:getAttCount()));
    
    local fazhen = "treasure_fazhen_"..self.tab..".png";
    MGRCManager:cacheResource("treasureLayer", fazhen);
    self.Image_zhen_bg:loadTexture(fazhen,ccui.TextureResType.plistType);
    if self.tab ==1 then
        self.Label_tao:setColor(Color3B.WHITE);
    elseif self.tab ==2 then
        self.Label_tao:setColor(Color3B.GREEN);
    elseif self.tab ==3 then
        self.Label_tao:setColor(cc.c3b(  0,   252, 255));
    elseif self.tab ==4 then
        self.Label_tao:setColor(Color3B.MAGENTA);
    elseif self.tab ==5 then
        self.Label_tao:setColor(Color3B.ORANGE);
    elseif self.tab ==6 then
        self.Label_tao:setColor(Color3B.RED);
   end
   if self.gm then
        self:setTreasureState();
   end
end

function treasureLayer:onReciveData(MsgID, NetData)
    print("LoadingPanel onReciveData MsgID:"..MsgID)
    
    if MsgID == Post_doSetTreasure then
        local ackData = NetData
        if ackData.state == 1 then
            self.treasureState:setNewTreasure(ackData.dosettreasure.new_treasure);
            self:setTreasureState();
            if self.delegate and self.delegate.upData then
                self.delegate:upData();
            end
        else
            NetHandler:showFailedMessage(ackData)
        end
    elseif  MsgID == Post_doActivationSuit then
        local ackData = NetData
        if ackData.state == 1  then
            self.treasureState:setActive();
            self:setTreasureState();
            if self.delegate and self.delegate.upData then
                self.delegate:upData();
            end
        else
            NetHandler:showFailedMessage(ackData)
        end
    end
    
end



function treasureLayer:pushAck()
    NetHandler:addAckCode(self,Post_doSetTreasure);
    NetHandler:addAckCode(self,Post_doActivationSuit);

end

function treasureLayer:popAck()
    NetHandler:delAckCode(self,Post_doSetTreasure);
    NetHandler:delAckCode(self,Post_doActivationSuit);
end

function treasureLayer:onEnter()
    self:pushAck();
end

function treasureLayer:onExit()
    MGRCManager:releaseResources("treasureLayer");
    self:popAck();
end

function treasureLayer.create(delegate)
    local layer = treasureLayer:new()
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
