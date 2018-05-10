----------------------未获得的武将图鉴-----------------------
require "heroDetailsLayer"

local jumpItem = require "jumpItem";
unGetGeneral = class("unGetGeneral", MGLayer)

function unGetGeneral:ctor()
    self:init();
end

function unGetGeneral:init()
    MGRCManager:cacheResource("unGetGeneral", "package_bg.jpg");
    MGRCManager:cacheResource("unGetGeneral", "tips_bg.jpg");
    local pWidget = MGRCManager:widgetFromJsonFile("unGetGeneral","GeneralMap_unGet_ui.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);

    if not self.jumpItemWidget then
        MGRCManager:cacheResource("unGetGeneral", "jump_ui.png","jump_ui.plist");
        self.jumpItemWidget = MGRCManager:widgetFromJsonFile("unGetGeneral", "jump_ui_1.ExportJson",false);
        self.jumpItemWidget:retain();
    end

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));

    local Panel_2 = pWidget:getChildByName("Panel_2");
    local Panel_right = Panel_2:getChildByName("Panel_right");
    
    self.ListView = Panel_right:getChildByName("ListView");
    self.ListView:setScrollBarVisible(false);--true添加滚动条
    self.ListView:setItemsMargin(10);

    local Panel_center = Panel_2:getChildByName("Panel_center");
    self.bodyImg = Panel_2:getChildByName("Image_bg");
    self.bodyImg:setVisible(true);
    self.bodyImg:setPositionY(self.bodyImg:getPositionY()-30);

    self.Label_name = Panel_center:getChildByName("Label_name");--玩家名
    self.Image_atc = Panel_center:getChildByName("Image_atc");
    local debLabel = Panel_center:getChildByName("Label_deb");--碎片数量
    debLabel:setVisible(false);

    self.Label_deb = MGColorLabel:label();
    self.Label_deb:setAnchorPoint(cc.p(0, 0.5));
    self.Label_deb:setPosition(debLabel:getPosition());
    Panel_center:addChild(self.Label_deb);


    self.Label_power = Panel_center:getChildByName("Label_power");--力量
    self.Label_lead = Panel_center:getChildByName("Label_lead");--领导
    self.Label_kno = Panel_center:getChildByName("Label_kno");--知识

    self.stars = {};
    for i=1,5 do
        local Image_star = Panel_center:getChildByName("Image_star"..i);
        Image_star:setVisible(false);
        table.insert(self.stars,Image_star);
    end

    self.boxs = {};
    for i=1,3 do
        local Button_box = Panel_center:getChildByName("Button_box"..i);
        Button_box:setTag(i);
        local Image_skill = Button_box:getChildByName("Image_skill"..i);
        Image_skill:setVisible(false);
        local Label_skill = Panel_center:getChildByName("Label_skill"..i);
        Label_skill:setVisible(false);
        Button_box:addTouchEventListener(handler(self,self.onBoxClick));
        Button_box:setEnabled(false);
        table.insert(self.boxs,{box=Button_box,Image_skill=Image_skill,Label_skill=Label_skill});
    end

    self.Image_row = Panel_center:getChildByName("Image_row");
    self.Image_row:setTouchEnabled(true);
    self.Image_row:addTouchEventListener(handler(self,self.onButtonClick));
    self.Label_row = Panel_center:getChildByName("Label_row");

    self.Panel_tip = pWidget:getChildByName("Panel_tip");
    self.Image_tip = self.Panel_tip:getChildByName("Image_tip");
    self.Image_skill = self.Image_tip:getChildByName("Image_skill");
    self.skill_name = self.Image_tip:getChildByName("skill_name");
    local Panel_skill = self.Image_tip:getChildByName("Panel_skill");

    self.desLabel = MGColorLabel:label();
    self.desLabel:setAnchorPoint(cc.p(0, 1));
    self.desLabel:setPosition(cc.p(0, Panel_skill:getContentSize().height-5));
    Panel_skill:addChild(self.desLabel);
end

function unGetGeneral:setData(gm)
    self.gm = gm;
    self.Label_name:setText(gm:name());
    self.Label_power:setText(gm:getPower());
    self.Label_lead:setText(gm:getCommand());
    self.Label_kno:setText(gm:getStrategy());
    -- self.Image_row

    local resId = gm:getNeedDebris()[1]:getItemId();
    local resInfo = RESOURCE:getResModelByItemId(resId);
    local resNum = 0;
    if resInfo then
        local resNum = resInfo:getNum();
    end
    local totNum = gm:getNeedDebris()[1]:getNum();
    self.Label_deb:clear();
    if resNum < totNum then
        self.Label_deb:appendStringAutoWrap(string.format("<c=255,000,000>%d</c>/%d",resNum,totNum),18,1,cc.c3b(255,255,255),22);
    else
        self.Label_deb:appendStringAutoWrap(string.format("%d/%d",resNum,totNum),18,1,cc.c3b(255,255,255),22);
    end

    self.Image_atc:loadTexture(string.format("com_hero_type_%d.png",gm:getType()),ccui.TextureResType.plistType);
    MGRCManager:cacheResource("unGetGeneral", string.format("general_pic_%d.png",gm:getId()));
    self.bodyImg:loadTexture(string.format("general_pic_%d.png",gm:getId()),ccui.TextureResType.plistType);
    for i=1,gm:getStar() do
        self.stars[i]:setVisible(true);
    end

    self.Infos = {};
    local skillList = gm:getSkill();
    for i=1,#skillList do
        local info = SkillLevelData:getSkillLevelInfo(skillList[i]:value(),gm:getSkillLv());
        table.insert(self.Infos,info);
    end
    for i=1,#self.Infos do
        if i > #self.boxs then
            break;
        end
        MGRCManager:cacheResource("unGetGeneral", self.Infos[i]:getPic());
        self.boxs[i].Image_skill:loadTexture(self.Infos[i]:getPic(),ccui.TextureResType.plistType);
        self.boxs[i].Label_skill:setText(self.Infos[i]:getName());
        self.boxs[i].Image_skill:setVisible(true);
        self.boxs[i].Label_skill:setVisible(true);
        self.boxs[i].box:setEnabled(true);
        self.boxs[i].skillInfo = self.Infos[i];
    end

    for i=1,#gm:getsourceItem() do
        local item = jumpItem.create(self,self.jumpItemWidget:clone());
        item:setData(gm:getsourceItem()[i]:getItemId());
        self.ListView:pushBackCustomItem(item);
    end

    self.Image_atc:setPositionX(self.Label_name:getPositionX()+self.Label_name:getContentSize().width+20);
end

function unGetGeneral:setSkillTip(tag)
    self.Panel_tip:setVisible(true);
    local infos = {};
    local skillList = self.gm:getSkill();
    for i=1,#skillList do
        local info = SkillLevelData:getSkillLevelInfo(skillList[i]:value(),self.gm:getSkillLv());
        table.insert(infos,info);
    end

    MGRCManager:cacheResource("unGetGeneral", infos[tag]:getPic());
    self.Image_skill:loadTexture(infos[tag]:getPic(),ccui.TextureResType.plistType);
    self.skill_name:setText(infos[tag]:getName());
    self.desLabel:clear();
    self.desLabel:appendStringAutoWrap(infos[tag]:getDesc(),16,1,cc.c3b(255,255,255),20);
end

function unGetGeneral:onBoxClick(sender, eventType)
    buttonClickScale(sender, eventType);
    self:setSkillTip(sender:getTag());
    if eventType == ccui.TouchEventType.began then
        self.Panel_tip:setVisible(true);
    elseif eventType == ccui.TouchEventType.canceled then
        self.Panel_tip:setVisible(false);
    elseif eventType == ccui.TouchEventType.ended then
        self.Panel_tip:setVisible(false);
    end
end

function unGetGeneral:onButtonClick(sender, eventType)
    if sender == self.Image_row then
        buttonClickScale(sender, eventType);
    end

    if eventType == ccui.TouchEventType.ended then
        if sender == self.Image_row then
            local detailsLayer = heroDetailsLayer.showBox(self);
        elseif sender == self.Panel_1 then
            self:removeFromParent();
        end
    end
end

function unGetGeneral:onEnter()

end

function unGetGeneral:onExit()
    MGRCManager:releaseResources("unGetGeneral");
    if self.jumpItemWidget then
        self.jumpItemWidget:release()
    end
end

function unGetGeneral.create(delegate,type)
    local layer = unGetGeneral:new()
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

function unGetGeneral.showBox(delegate,type)
    local layer = unGetGeneral.create(delegate,type);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
