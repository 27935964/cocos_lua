-----------------------将领界面左半侧------------------------
require "Item"
require "heroUpgradeLayer"
require "heroIntroduceLayer"
require "heroAdvanceLayer"
require "heroDetailsLayer"
require "heroEquipLayer"

SodierCocos = require "SodierCocos"
heroComLayer = class("heroComLayer", MGLayer)

function heroComLayer:ctor()
    self:init();
end

function heroComLayer:init()
    MGRCManager:cacheResource("heroComLayer", "main_ui_big_number.png");
    local pWidget = MGRCManager:widgetFromJsonFile("heroComLayer","hero_com_ui_1.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);--设置tag=1000~2000阴影或者2000~3000描边

    local Panel_2 = pWidget:getChildByName("Panel_2");

    local Panel_center = Panel_2:getChildByName("Panel_center");
    local Label_pow = Panel_center:getChildByName("Label_pow");
    local Label_introduce = Panel_center:getChildByName("Label_introduce");
    local Label_fetter = Panel_center:getChildByName("Label_fetter");
    local Label_methods = Panel_center:getChildByName("Label_methods");
    Label_pow:setText(MG_TEXT_COCOS("hero_attribute_ui_5"));
    Label_introduce:setText(MG_TEXT_COCOS("hero_attribute_ui_6"));
    Label_fetter:setText(MG_TEXT_COCOS("hero_attribute_ui_7"));
    Label_methods:setText(MG_TEXT_COCOS("hero_attribute_ui_8"));

    self.Label_name = Panel_center:getChildByName("Label_name");--玩家名
    self.Image_atc = Panel_center:getChildByName("Image_atc");
    self.BitmapLabel = Panel_center:getChildByName("BitmapLabel");--战斗力

    self.Button_introduce = Panel_center:getChildByName("Button_introduce");--介绍按钮
    self.Button_introduce:addTouchEventListener(handler(self,self.onButtonClick));
    self.Button_fetter = Panel_center:getChildByName("Button_fetter");--羁绊按钮
    self.Button_fetter:addTouchEventListener(handler(self,self.onButtonClick));
    self.Button_methods = Panel_center:getChildByName("Button_methods");--战法按钮
    self.Button_methods:addTouchEventListener(handler(self,self.onButtonClick));

    self.Label_power = Panel_center:getChildByName("Label_power");--力量
    self.Label_lead = Panel_center:getChildByName("Label_lead");--领导
    self.Label_kno = Panel_center:getChildByName("Label_kno");--知识

    self.stars = {};
    for i=1,5 do
        local Image_star = Panel_center:getChildByName("Image_star"..i);
        Image_star:setVisible(false);
        table.insert(self.stars,Image_star);
    end

    local Panel_3 = pWidget:getChildByName("Panel_3");
    Panel_3:setVisible(true);
    self.bodyImg = Panel_3:getChildByName("Image_bg");
    self.bodyImg:setPositionY(self.bodyImg:getPositionY()-30);

    local Panel_4 = pWidget:getChildByName("Panel_4");
    self.Image_row = Panel_4:getChildByName("Image_row");
    self.Image_row:setTouchEnabled(true);
    self.Image_row:addTouchEventListener(handler(self,self.onButtonClick));
    self.Label_row = Panel_4:getChildByName("Label_row");
end

function heroComLayer:setHero(gm)
    self.gm = gm;
    self.Label_name:setText(gm:name());
    self.Label_name:setColor(GeneralData:getTitleColor(gm:getQuality()));
    self.BitmapLabel:setText(gm:getWarScore());
    self.Label_power:setText(gm:getPower());
    self.Label_lead:setText(gm:getCommand());
    self.Label_kno:setText(gm:getStrategy());
    self.Image_atc:loadTexture(string.format("com_hero_type_%d.png",gm:getType()),ccui.TextureResType.plistType);
    self.Image_atc:setPositionX(self.Label_name:getPositionX()+self.Label_name:getContentSize().width+30);
    MGRCManager:cacheResource("heroComLayer",gm:pic());
    self.bodyImg:loadTexture(gm:pic(),ccui.TextureResType.plistType);
    for i=1,#self.stars do
        self.stars[i]:setVisible(false);
        if i <= gm:getStar() then
            self.stars[i]:setVisible(true);
            self.stars[i]:loadTexture(string.format("com_big_star%d.png",gm:getRare()),ccui.TextureResType.plistType); 
        end
    end

    local sql = string.format("select * from soldier_list where id=%d",gm:soldierid());
    local DBData = LUADB.select(sql, "atk_range");
    if tonumber(DBData.info.atk_range) > 1 then--后排
        self.Image_row:loadTexture("hero_back_row.png",ccui.TextureResType.plistType);
        self.Label_row:setText(MG_TEXT("heroAttLayer_4"));
    else
        self.Image_row:loadTexture("hero_front_row.png",ccui.TextureResType.plistType);
        self.Label_row:setText(MG_TEXT("heroAttLayer_5"));
    end
end

function heroComLayer:onButtonClick(sender, eventType)
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

        if sender == self.Button_introduce then
            print("-----------------介绍按钮-----------------")
            local introduceLayer = heroIntroduceLayer.showBox(self);
            introduceLayer:setData(self.gm);
        elseif sender == self.Button_fetter then
            print("-----------------羁绊按钮-----------------")
        elseif sender == self.Button_methods then
            print("-----------------战法按钮-----------------")
        elseif sender == self.Image_row then
            local detailsLayer = heroDetailsLayer.showBox(self);
        end
    end
end

function heroComLayer:onEnter()

end

function heroComLayer:onExit()
    MGRCManager:releaseResources("heroComLayer");
end

function heroComLayer.create(delegate)
    local layer = heroComLayer:new()
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
