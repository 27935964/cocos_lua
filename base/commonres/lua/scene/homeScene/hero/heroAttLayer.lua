-----------------------将领属性界面------------------------
require "Item"
require "heroUpgradeLayer"
require "heroIntroduceLayer"
require "heroAdvanceLayer"
require "heroDetailsLayer"
require "heroEquipLayer"
require "heroComLayer"

SodierCocos = require "SodierCocos"
heroAttLayer = class("heroAttLayer", MGLayer)

function heroAttLayer:ctor()
    self.pos = 0;
    self.isAll = 0;--0穿一件，1一键装备
    self.equipInfo = nil;
    self.state = 1;--0一键装备状态 1进阶状态
    self.curLayer = nil;
    self.curPageIndex = 0;
    self.isCanWear = false;--是否可以一键装备
    self:init();
end

function heroAttLayer:init()
    local pWidget = MGRCManager:widgetFromJsonFile("heroAttLayer","hero_attribute_ui_1.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);--设置tag=1000~2000阴影或者2000~3000描边

    self.heroComLayer = heroComLayer.create(self);
    self:addChild(self.heroComLayer,-1);
    
    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:setAnchorPoint(cc.p(0.5, 0.5));
    CommonMethod:setFullBgScale(self.Panel_1);

    local Panel_2 = pWidget:getChildByName("Panel_2");
    local Panel_right = Panel_2:getChildByName("Panel_right");

    local Label_atc = Panel_right:getChildByName("Label_atc");
    local Label_def = Panel_right:getChildByName("Label_def");
    local Label_speed = Panel_right:getChildByName("Label_speed");
    local Label_forces = Panel_right:getChildByName("Label_forces");
    Label_atc:setText(MG_TEXT_COCOS("hero_attribute_ui_1"));
    Label_def:setText(MG_TEXT_COCOS("hero_attribute_ui_2"));
    Label_speed:setText(MG_TEXT_COCOS("hero_attribute_ui_3"));
    Label_forces:setText(MG_TEXT_COCOS("hero_attribute_ui_4"));

    self.Image_hero = Panel_right:getChildByName("Image_hero");
    self.Image_hero:setVisible(false);
    self.sodier=SodierCocos.new();
    self.sodier:init(Panel_right,Sodier.KCavalry,Sodier.DLeft);
    self.sodier:setPosition(self.Image_hero:getPosition());

    self.Label_level = Panel_right:getChildByName("Label_level");--等级
    self.ProgressBar = Panel_right:getChildByName("ProgressBar");--进度条
    self.Label_bar = Panel_right:getChildByName("Label_bar");--进度条值
    -- self.ProgressBar:setPercent(10)

    self.Label_atcNum = Panel_right:getChildByName("Label_atcNum");--攻击值
    self.Label_defNum = Panel_right:getChildByName("Label_defNum");--防御值
    self.Label_speedNum = Panel_right:getChildByName("Label_speedNum");--速度值
    self.Label_forcesNum = Panel_right:getChildByName("Label_forcesNum");--兵力值

    self.boxs = {};
    for i=1,4 do
        local Image_box = Panel_right:getChildByName("Image_box"..i);
        Image_box:setTag(i);
        Image_box:setTouchEnabled(true);
        Image_box:addTouchEventListener(handler(self,self.onBoxClick));

        local Panel_head = Image_box:getChildByName("Panel_head"..i);
        local Label_lv = Image_box:getChildByName("Label_lv"..i);
        Label_lv:setVisible(false);
        local Label_num = Image_box:getChildByName("Label_num"..i);
        Label_num:setVisible(false);
        local Image_add = Image_box:getChildByName("Image_add"..i);

        Image_add:setOpacity(100);
        local action1 = cc.FadeIn:create(1);
        local action1Back = action1:reverse();
        local sequence = cc.Sequence:create(action1, action1Back);
        Image_add:runAction(cc.RepeatForever:create(sequence));

        local item = Item.create(self);
        item:setTouchEnabled(false);
        item:setPosition(cc.p(Panel_head:getContentSize().width/2,Panel_head:getContentSize().height/2));
        Panel_head:addChild(item);
        table.insert(self.boxs,{box=Image_box, item=item, Panel_head=Panel_head, Label_lv=Label_lv, 
            Label_num=Label_num, Image_add=Image_add});
    end

    self.Button_wear = Panel_right:getChildByName("Button_wear");--一键装备按钮
    self.Button_wear:addTouchEventListener(handler(self,self.onButtonClick));
    self.Label_btn = self.Button_wear:getChildByName("Label_btn");

    self.Button_upgrade = Panel_right:getChildByName("Button_upgrade");--升级按钮
    self.Button_upgrade:addTouchEventListener(handler(self,self.onButtonClick));

    self.Image_arr1 = Panel_right:getChildByName("Image_arr1");
    self.Image_arr1:setTouchEnabled(true);
    self.Image_arr1:addTouchEventListener(handler(self,self.onButtonClick));
    self.Image_arr1:setVisible(false);

    self.Image_arr2 = Panel_right:getChildByName("Image_arr2");
    self.Image_arr2:setTouchEnabled(true);
    self.Image_arr2:addTouchEventListener(handler(self,self.onButtonClick));
    self.Image_arr2:setVisible(true);

    self.PageView = Panel_right:getChildByName("PageView");
    self.PageView:addEventListenerPageView(handler(self,self.pageViewEvent));
    
    self.skill_name = Panel_right:getChildByName("Label_skill_name");--技能名
    self.skill_level = Panel_right:getChildByName("Label_skill_level");--技能等级
    self.descLabel = cc.Label:createWithTTF("",ttf_msyh,22);--技能描述
    self.descLabel:setAlignment(cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_TOP);
    self.descLabel:setDimensions(360, 0);
    -- self.descLabel:setColor(cc.c3b(207, 203, 202));
    self.descLabel:setAnchorPoint(cc.p(0, 1));
    self.descLabel:setPosition(cc.p(self.skill_name:getPositionX(),90));
    Panel_right:addChild(self.descLabel);
end

function heroAttLayer:setData(gm)
    self.gm = gm;
    self.heroComLayer:setHero(gm);
    self:setHeroData(gm);
end

function heroAttLayer:setHeroData(gm)
    self.Label_level:setText(string.format("Lv.%d",gm:getLevel()));
    self.Label_atcNum:setText(gm:getAttack());
    self.Label_defNum:setText(gm:getDefense());
    self.Label_speedNum:setText(gm:getSpeed());
    self.Label_forcesNum:setText(gm:getForce());
    self.skill_level:setText(string.format("Lv.%d",gm:getSkillLv()));
    self.sodier:setKind(gm:soldierid());

    self.Infos = {};
    local skillList = gm:getSkill();
    for i=1,#skillList do
        local info = SkillLevelData:getSkillLevelInfo(skillList[i]:value(),gm:getSkillLv());
        table.insert(self.Infos,info);
    end
    self.PageView:removeAllChildren();
    for i=1,#self.Infos do
        self:createSkillItem(self.Infos[i]);
    end

    self.PageView:scrollToPage(0);
    self.equipInfo = EquipData:getEquipInfo(GeneralData:getGeneralInfo(gm:getId()):soldierid(),gm:getQuality());
    self.isCanWear = false;
    for i=1,#self.equipInfo:getEquipItem() do
        self:setBox(i);
    end
    self:updataData();
end

function heroAttLayer:setBox(tag)
    self.equipInfo = EquipData:getEquipInfo(GeneralData:getGeneralInfo(self.gm:getId()):soldierid(),self.gm:getQuality());
    local generalLv = self.gm:getLevel();
    local state = self.gm:getEquipState(tag);
    self.boxs[tag].item:setIsGray(true);
    self.equipData = self.equipInfo:getEquipItem()[tag];
    self.boxs[tag].item:setData(RESOURCE:getDBResourceListByItemId(self.equipData:getItemId()));
    self.boxs[tag].item.numLabel:setVisible(false);
    self.boxs[tag].Image_add:setVisible(false);
    self.boxs[tag].Label_num:setVisible(false);
    self.boxs[tag].Label_lv:setVisible(false);
    if state == 0 then--还未装备
        if generalLv < self.equipData:getLevel() then
            self.boxs[tag].Label_lv:setVisible(true);
            self.boxs[tag].Label_lv:setText(string.format(MG_TEXT("heroAttLayer_6"),self.equipData:getLevel()));
        elseif generalLv >= self.equipData:getLevel() then
            local equipNum = 0;
            if RESOURCE:getResModelByItemId(self.equipData:getItemId()) then
                equipNum = RESOURCE:getResModelByItemId(self.equipData:getItemId()):getNum();
            end
            local disNum = self.equipData:getNum() - equipNum;
            self.boxs[tag].Label_num:setVisible(true);
            self.boxs[tag].Image_add:setVisible(true);
            self.boxs[tag].Label_num:setText(string.format(MG_TEXT("heroAttLayer_12"),disNum));
            if equipNum < self.equipData:getNum() then
                self.boxs[tag].Image_add:loadTexture("hero_add1.png",ccui.TextureResType.plistType);
            else
                self.isCanWear = true;
                self.boxs[tag].Label_num:setVisible(false);
                self.boxs[tag].Image_add:loadTexture("hero_add2.png",ccui.TextureResType.plistType);
            end
        end
    elseif state == 1 then--已装备
        self.boxs[tag].item:setIsGray(false);
    end
end

function heroAttLayer:updataData()
    self.state = 1;
    for i=1,4 do
        if self.gm:getEquipState(i) == 0 then
            self.state = 0;
            break;
        end
    end

    if self.equipInfo:nextQuilt() == 0 then--已满阶
        self.Label_btn:setText(MG_TEXT("heroAttLayer_13"));
    else
        if self.state == 0 then
            self.Label_btn:setText(MG_TEXT("heroAttLayer_10"));
        elseif self.state == 1 then
            self.Label_btn:setText(MG_TEXT("heroAttLayer_11"));
        end
    end

    local value = 0;
    if self.gm:getLevel() < 100 then
        local DBData = LUADB.select(string.format("select need_exp from general_lv where lv=%d",self.gm:getLevel()+1), "need_exp");
        value = math.ceil(self.gm:getExp()*100/DBData.info.need_exp);
    else
        value = 100;
    end
    self.Label_bar:setText(string.format("%s%%",value));
    self.ProgressBar:setPercent(value);

end

function heroAttLayer:createSkillItem(info)
    if info then
        local layout = ccui.Layout:create();
        layout:setSize(cc.size(500, 130));
        self.PageView:addPage(layout);

        local boxSpr = cc.Sprite:createWithSpriteFrameName("com_icon_circle_box.png");
        boxSpr:setPosition(cc.p(boxSpr:getContentSize().width/2+5,layout:getContentSize().height/2));
        layout:addChild(boxSpr);

        local picName = info:getPic();
        MGRCManager:cacheResource("heroAttLayer", picName);
        local imageView = ccui.ImageView:create(picName,ccui.TextureResType.localType);
        imageView:setPosition(cc.p(boxSpr:getContentSize().width/2,boxSpr:getContentSize().height/2));
        boxSpr:addChild(imageView);

        local listView = ccui.ListView:create();
        listView:setDirection(ccui.ScrollViewDir.vertical);
        listView:setBounceEnabled(false);
        listView:setAnchorPoint(cc.p(0,0.5));
        listView:setSize(cc.size(400, 110));
        listView:setScrollBarVisible(false);--true添加滚动条
        listView:setPosition(cc.p(100,layout:getContentSize().height/2+5));
        layout:addChild(listView);

        listView:removeAllItems();
        local itemLay = ccui.Layout:create();
        itemLay:setSize(cc.size(listView:getContentSize().width, listView:getContentSize().height));
        listView:pushBackCustomItem(itemLay);

        local nameLabel = cc.Label:createWithTTF(MG_TEXT("heroAttLayer_15"),ttf_msyh,22);--技能名
        nameLabel:setAnchorPoint(cc.p(0, 1));
        nameLabel:setPosition(cc.p(105,120));
        itemLay:addChild(nameLabel);

        local lvLabel = cc.Label:createWithTTF(string.format("Lv.%d",info:getLevel()),ttf_msyh,22);--技能等级
        lvLabel:setAnchorPoint(cc.p(0, 1));
        lvLabel:setPosition(cc.p(nameLabel:getPositionX()+nameLabel:getContentSize().width+20,nameLabel:getPositionY()));
        itemLay:addChild(lvLabel);

        local desLabel = MGColorLabel:label();
        desLabel:setAnchorPoint(cc.p(0, 1));
        desLabel:setPosition(cc.p(nameLabel:getPositionX(), nameLabel:getPositionY()-30));
        itemLay:addChild(desLabel);
        desLabel:clear();
        desLabel:appendStringAutoWrap(string.format("%s",info:getDesc()),18,1,cc.c3b(255,255,255),20);

        local h = nameLabel:getContentSize().height+desLabel:getContentSize().height+5;
        itemLay:setSize(cc.size(listView:getContentSize().width, h));
        local posY = h;
        nameLabel:setPosition(cc.p(0,posY));
        lvLabel:setPosition(cc.p(nameLabel:getPositionX()+nameLabel:getContentSize().width+20,nameLabel:getPositionY()));
        posY = posY-nameLabel:getContentSize().height;
        desLabel:setPosition(cc.p(nameLabel:getPositionX(),posY));
    end
end

function heroAttLayer:pageViewEvent(sender, eventType)
    if eventType == ccui.PageViewEventType.turning then
        self.Image_arr1:setVisible(true);
        self.Image_arr2:setVisible(true);
        if sender:getCurPageIndex() == 0 then
            self.Image_arr1:setVisible(false);
        elseif sender:getCurPageIndex() == #self.Infos-1 then
            self.Image_arr2:setVisible(false);
        end
        if #self.Infos<= 1 then
            self.Image_arr1:setVisible(false);
            self.Image_arr2:setVisible(false);
        end
        self.curPageIndex = sender:getCurPageIndex();
    end
end

function heroAttLayer:onBoxClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        self.pos = sender:getTag();
        self.isAll = 0;

        self:setBox(sender:getTag());
        if self.curLayer == nil then
            self.curLayer = heroEquipLayer.showBox(self);
        end
        self.curLayer:setData(self.gm,sender:getTag());
    end
end

function heroAttLayer:onButtonClick(sender, eventType)
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
        if sender == self.Button_wear then
            if self.state == 0 then--一键装备
                self.isAll = 1;
                if self.isCanWear == true then
                    self:sendReq();
                else
                    MGMessageTip:showFailedMessage(MG_TEXT("heroAttLayer_14"));
                end
            elseif self.state == 1 then--进阶
                self.curLayer = heroAdvanceLayer.showBox(self);
                self.curLayer:setData(self.gm);
            end
        elseif sender == self.Button_upgrade then--升级
            self.curLayer = heroUpgradeLayer.showBox(self);
            self.curLayer:setData(self.gm);
        elseif sender == self.Image_arr1 then
            self.PageView:scrollToPage(self.curPageIndex-1);
        elseif sender == self.Image_arr2 then
            self.PageView:scrollToPage(self.curPageIndex+1);
        end
    end
end

function heroAttLayer:upData()
    if self.delegate and self.delegate.upData then
        self.delegate:upData();
    end
end

function heroAttLayer:onReciveData(MsgID, NetData)
    print("heroAttLayer onReciveData MsgID:"..MsgID)

    if MsgID == Post_doUseEquip then
        local ackData = NetData
        if ackData.state == 1 then
            self:setData(self.gm);
            self:upData();
        else
            NetHandler:showFailedMessage(ackData)
        end
    elseif MsgID == Post_addExp then
        local ackData = NetData
        if ackData.state == 1 then
            self:setData(self.gm);
            self.curLayer:setData(self.gm);
            self:upData();
        else
            NetHandler:showFailedMessage(ackData)
        end
    elseif MsgID == Post_doUpQuality then
        local ackData = NetData
        if ackData.state == 1 then
            self:setData(self.gm);
            self:upData();
        else
            NetHandler:showFailedMessage(ackData)
        end
    end
end

function heroAttLayer:sendReq()
    local str = string.format("&g_id=%d&pos=%d&is_all=%d",self.gm:getId(),self.pos,self.isAll);
    NetHandler:sendData(Post_doUseEquip, str);
end

function heroAttLayer:pushAck()
    NetHandler:addAckCode(self,Post_doUseEquip);
    NetHandler:addAckCode(self,Post_addExp);
    NetHandler:addAckCode(self,Post_doUpQuality);
end

function heroAttLayer:popAck()
    NetHandler:delAckCode(self,Post_doUseEquip);
    NetHandler:delAckCode(self,Post_addExp);
    NetHandler:delAckCode(self,Post_doUpQuality);
end

function heroAttLayer:removeChildrenLayer()
    if self.curLayer then
        self.curLayer:removeFromParent();
        self.curLayer = nil;
    end
end

function heroAttLayer:onEnter()
    self:pushAck();
end

function heroAttLayer:onExit()
    MGRCManager:releaseResources("heroAttLayer");
    self:popAck();
end

function heroAttLayer.create(delegate,type)
    local layer = heroAttLayer:new()
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
