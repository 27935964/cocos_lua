-----------------------兵种进阶界面------------------------
require "Item"
require "heroAccessLayer"

heroEquipLayer = class("heroEquipLayer", MGLayer)

function heroEquipLayer:ctor()
    self.state = 0;--0无状态，1等级不够，2数量不足，3数量够
    self.resData = nil;
    self:init();
end

function heroEquipLayer:init()
    MGRCManager:cacheResource("heroMainLayer", "soldier_1.png");
    local pWidget = MGRCManager:widgetFromJsonFile("heroEquipLayer","hero_equip_ui_1.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);
    
    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:setTouchEnabled(true);
    self.Panel_1:addTouchEventListener(handler(self,self.onBackClick));

    local Panel_2 = pWidget:getChildByName("Panel_2");
    self.Button_close = Panel_2:getChildByName("Button_close");
    self.Button_close:addTouchEventListener(handler(self,self.onButtonClick));

    local Image_box = Panel_2:getChildByName("Image_box");
    self.equip = Item.create(self);
    self.equip:setNumVisible(false)
    self.equip:setTouchEnabled(false);
    self.equip:setPosition(Image_box:getSize().width/2,Image_box:getSize().height/2);
    Image_box:addChild(self.equip);

    self.Label_name = Panel_2:getChildByName("Label_name");--武将名
    self.Label_atc = Panel_2:getChildByName("Label_atc");--属性
    self.Label_atcNum = Panel_2:getChildByName("Label_atcNum");--属性值

    self.Label_needNum = Panel_2:getChildByName("Label_needNum");
    self.Label_needNum:setVisible(false);
    self.Label_tip = Panel_2:getChildByName("Label_tip");

    self.Button_eq = Panel_2:getChildByName("Button_eq");
    self.Button_eq:addTouchEventListener(handler(self,self.onButtonClick));
    self.Label_eq = self.Button_eq:getChildByName("Label_eq");
    
    local Panel_des = Panel_2:getChildByName("Panel_des");
    self.descLabel = cc.Label:createWithTTF("",ttf_msyh,22);
    self.descLabel:setAlignment(cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_TOP);
    self.descLabel:setDimensions(340, 0);
    -- self.descLabel:setColor(cc.c3b(207, 203, 202));
    self.descLabel:setAnchorPoint(cc.p(0, 1));
    self.descLabel:setPosition(cc.p(10,Panel_des:getContentSize().height-10));
    Panel_des:addChild(self.descLabel);

    self.tipLabel = MGColorLabel:label();
    self.tipLabel:setAnchorPoint(cc.p(0,0.5));
    self.tipLabel:setPosition(self.Label_needNum:getPosition());
    Panel_2:addChild(self.tipLabel);

    local Label_need = Panel_2:getChildByName("Label_need");
    Label_need:setText(MG_TEXT_COCOS("hero_equip_ui_1_1"));
end

function heroEquipLayer:setData(gm,tag)
    local generalLv = gm:getLevel();
    self.equipInfo = EquipData:getEquipInfo(GeneralData:getGeneralInfo(gm:getId()):soldierid(),gm:getQuality());
    local resData = RESOURCE:getDBResourceListByItemId(self.equipInfo:getEquipItem()[tag]:getItemId());
    self.resData =resData;
    local id = self.equipInfo:getPutEffItem()[tag]:getItemId();
    local DBData = LUADB.select(string.format("select * from effect where id=%d",id), "id:name");
    
    self.equip:setData(resData);
    self.Label_name:setText(resData:name());
    self.Label_name:setColor(ResourceData:getTitleColor(resData:getQuality()));
    self.Label_atc:setText(DBData.info.name);
    self.Label_atcNum:setText("+"..self.equipInfo:getPutEffItem()[tag]:getNum());
    self.Label_atcNum:setPositionX(self.Label_atc:getPositionX()+self.Label_atc:getContentSize().width+20);
    self.descLabel:setString(resData:desc());

    local state = gm:getEquipState(tag);
    local str = "";
    if state == 0 then--还未装备
        if generalLv < self.equipInfo:getEquipItem()[tag]:getLevel() then
            self.Label_eq:setText(string.format(MG_TEXT("heroAttLayer_6"),self.equipInfo:getEquipItem()[tag]:getLevel()));
            self.state = 1;
        else
            if resData:getNum() < self.equipInfo:getEquipItem()[tag]:getNum() then
                self.state = 2;
                self.Label_eq:setText(MG_TEXT("heroAttLayer_8"));
                str = string.format("<c=255,000,000>%d</c>/%d",resData:getNum(),self.equipInfo:getEquipItem()[tag]:getNum());
            else
                self.state = 3;
                self.Label_eq:setText(MG_TEXT("heroAttLayer_7"));
                str = string.format("<c=000,255,000>%d</c>/%d",resData:getNum(),self.equipInfo:getEquipItem()[tag]:getNum());
            end
        end
        self.tipLabel:clear();
        self.tipLabel:appendStringAutoWrap(string.format("%s",str),18,1,cc.c3b(255,255,255),22);
    elseif state == 1 then--已装备
        self.Label_eq:setText(MG_TEXT("heroAttLayer_8"));
    end
end

function heroEquipLayer:onBackClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        self:remove();
    end
end

function heroEquipLayer:onButtonClick(sender, eventType)
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
            self:remove();
        elseif sender == self.Button_eq then
            if self.state == 1 then
                MGMessageTip:showFailedMessage(MG_TEXT("heroAttLayer_9"));
            elseif self.state == 2 then
                print("========获取=========")
                local accessLayer = heroAccessLayer.showBox(self);
                accessLayer:setData(gm,self.resData);
            elseif self.state == 3 then
                if self.delegate and self.delegate.sendReq then
                    self.delegate:sendReq();
                    self:remove();
                end
            end
        end
    end
end

function heroEquipLayer:remove()
    if self.delegate and self.delegate.removeChildrenLayer then
        self.delegate:removeChildrenLayer();
    end
end

function heroEquipLayer:onEnter()

end

function heroEquipLayer:onExit()
    MGRCManager:releaseResources("heroEquipLayer");
end

function heroEquipLayer.create(delegate)
    local layer = heroEquipLayer:new()
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

function heroEquipLayer.showBox(delegate)
    local layer = heroEquipLayer.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
