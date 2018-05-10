-----------------------兵种进阶界面------------------------

SodierCocos = require "SodierCocos"

heroAdvanceLayer = class("heroAdvanceLayer", MGLayer)

function heroAdvanceLayer:ctor()
    self:init();
end

function heroAdvanceLayer:init()
    local pWidget = MGRCManager:widgetFromJsonFile("heroAdvanceLayer","hero_advance_ui_1.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);
    
    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:setTouchEnabled(true);
    self.Panel_1:addTouchEventListener(handler(self,self.onBackClick));

    local Panel_2 = pWidget:getChildByName("Panel_2");
    self.Button_close = Panel_2:getChildByName("Button_close");
    self.Button_close:addTouchEventListener(handler(self,self.onButtonClick));

    self.Label_name = Panel_2:getChildByName("Label_name");--武将名
    self.Label_kind = Panel_2:getChildByName("Label_kind");--兵名
    self.Image_soldierBg = Panel_2:getChildByName("Image_soldierBg");--兵图底
    self.sodier=SodierCocos.new();
    self.sodier:init(self.Image_soldierBg,Sodier.KCavalry,Sodier.DLeft);
    self.sodier:setPosition(cc.p(self.Image_soldierBg:getContentSize().width/2,self.Image_soldierBg:getContentSize().height/2+20));

    local Image_bg = Panel_2:getChildByName("Image_bg");
    self.atcFront = Image_bg:getChildByName("Label_atcNum1");--进阶前攻击力
    self.atcEnd = Image_bg:getChildByName("Label_atcNum2");--进阶后攻击力
    self.defFront = Image_bg:getChildByName("Label_defNum1");--进阶前防御力
    self.defEnd = Image_bg:getChildByName("Label_defNum2");--进阶后防御力
    self.speedFront = Image_bg:getChildByName("Label_speedNum1");--进阶前速度
    self.speedEnd = Image_bg:getChildByName("Label_speedNum2");--进阶后速度
    self.forcesFront = Image_bg:getChildByName("Label_forcesNum1");--进阶前兵力
    self.forcesEnd = Image_bg:getChildByName("Label_forcesNum2");--进阶后兵力
    
    self.Label_gold = Panel_2:getChildByName("Label_gold");
    self.Button_advance = Panel_2:getChildByName("Button_advance");
    self.Button_advance:addTouchEventListener(handler(self,self.onButtonClick));

    self.Label_atc = Image_bg:getChildByName("Label_atc");
    self.Label_atc:setText(MG_TEXT_COCOS("hero_advance_ui_1"));
    self.Label_def = Image_bg:getChildByName("Label_def");
    self.Label_def:setText(MG_TEXT_COCOS("hero_advance_ui_2"));
    self.Label_speed = Image_bg:getChildByName("Label_speed");
    self.Label_speed:setText(MG_TEXT_COCOS("hero_advance_ui_3"));
    self.Label_forces = Image_bg:getChildByName("Label_forces");
    self.Label_forces:setText(MG_TEXT_COCOS("hero_advance_ui_4"));
    self.Label_tip1 = Panel_2:getChildByName("Label_tip1");
    self.Label_tip1:setText(MG_TEXT_COCOS("hero_advance_ui_5"));
    self.Label_tip2 = Panel_2:getChildByName("Label_tip2");
    self.Label_tip2:setText(MG_TEXT_COCOS("hero_advance_ui_6"));
end

function heroAdvanceLayer:setData(gm)
    self.gm = gm;
    self.equipInfo = EquipData:getEquipInfo(gm:soldierid(),gm:getQuality()+1);

    self.Label_name:setText(gm:name());
    local DBData = LUADB.select(string.format("select * from soldier_list where id=%d",gm:soldierid()), "id:name");
    self.Label_kind:setText(DBData.info.name);
    self.atcFront:setText(gm:getAttack());
    self.defFront:setText(gm:getDefense());
    self.speedFront:setText(gm:getSpeed());
    self.forcesFront:setText(gm:getForce());

    self.atcEnd:setText(self.equipInfo:getEffectItem()[1]:getNum()+gm:getAttack());
    self.defEnd:setText(self.equipInfo:getEffectItem()[2]:getNum()+gm:getDefense());
    self.speedEnd:setText(self.equipInfo:getEffectItem()[4]:getNum()+gm:getSpeed());
    self.forcesEnd:setText(self.equipInfo:getEffectItem()[3]:getNum()+gm:getForce());
    self.Label_gold:setText(self.equipInfo:getUpNeedItem()[1]:getNum());

    self.Label_tip2:setPositionX(self.Label_gold:getPositionX()+self.Label_gold:getContentSize().width+10);
end

function heroAdvanceLayer:onBackClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        self:remove();
    end
end

function heroAdvanceLayer:onButtonClick(sender, eventType)
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
        elseif sender == self.Button_advance then
            self:sendReq();
            self:remove();
        end
    end
end

function heroAdvanceLayer:remove()
    if self.delegate and self.delegate.removeChildrenLayer then
        self.delegate:removeChildrenLayer();
    end
end

function heroAdvanceLayer:sendReq()
    local str = string.format("&g_id=%d",self.gm:getId());
    NetHandler:sendData(Post_doUpQuality, str);
end

function heroAdvanceLayer:onEnter()
end

function heroAdvanceLayer:onExit()
    MGRCManager:releaseResources("heroAdvanceLayer");
end

function heroAdvanceLayer.create(delegate)
    local layer = heroAdvanceLayer:new()
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

function heroAdvanceLayer.showBox(delegate)
    local layer = heroAdvanceLayer.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
