-----------------------兵种详情界面------------------------

heroDetailsLayer = class("heroDetailsLayer", MGLayer)

function heroDetailsLayer:ctor()
    self:init();
end

function heroDetailsLayer:init()
    local pWidget = MGRCManager:widgetFromJsonFile("heroDetailsLayer","hero_details_ui_1.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);
    
    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:setTouchEnabled(true);
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));

    local Panel_2 = pWidget:getChildByName("Panel_2");
    self.Button_close = Panel_2:getChildByName("Button_close");
    self.Button_close:addTouchEventListener(handler(self,self.onButtonClick));

    self.Label_title = Panel_2:getChildByName("Label_title");
    self.Label_speed2 = Panel_2:getChildByName("Label_speed2");
    self.Label_atc2 = Panel_2:getChildByName("Label_atc2");

    self.Label_speed1 = Panel_2:getChildByName("Label_speed1");
    self.Label_speed1:setText(MG_TEXT_COCOS("hero_details_ui_1"));
    self.Label_atc1 = Panel_2:getChildByName("Label_atc1");
    self.Label_atc1:setText(MG_TEXT_COCOS("hero_details_ui_2"));

    self.floors = {}
    for i=1,16 do
        local Image_floor = Panel_2:getChildByName("Image_floor"..i);
        table.insert(self.floors,Image_floor);
    end

    self.sodier1=SodierCocos.new();
    self.sodier1:init(Panel_2,Sodier.KCavalry,Sodier.DLeft);
    self.sodier1:setPosition(self.floors[1]:getPosition());

    self.sodier2=SodierCocos.new();
    self.sodier2:init(Panel_2,Sodier.KSpear,Sodier.DRight);
    self.sodier2:setPosition(self.floors[16]:getPosition());
    -- self.sodier2:setRotation(180);
end

function heroDetailsLayer:setData(gm)
    local str = "";
    local curPosY = 0;
    self.ListView:removeAllItems();
    local itemLay = ccui.Layout:create();
    itemLay:setSize(cc.size(560,580));
    self.ListView:pushBackCustomItem(itemLay);

    -- itemLay:setBackGroundColorType(1);
    -- itemLay:setBackGroundColor(cc.c3b(0,0,250));

    local colorLabel1 = MGColorLabel:label();
    colorLabel1:setAnchorPoint(cc.p(0, 1));
    itemLay:addChild(colorLabel1);
    colorLabel1:clear();
    str = string.format(MG_TEXT("heroAttLayer_1"),gm:getForce());
    colorLabel1:appendStringAutoWrap(str,18,1,cc.c3b(255,255,255),22);
    curPosY = itemLay:getSize().height-10;
    colorLabel1:setPosition(cc.p(20,curPosY));

    local colorLabel2 = MGColorLabel:label();
    colorLabel2:setAnchorPoint(cc.p(0, 1));
    itemLay:addChild(colorLabel2);
    colorLabel2:clear();
    str = string.format(MG_TEXT("heroAttLayer_2"),gm:getCommand());
    colorLabel2:appendStringAutoWrap(str,18,1,cc.c3b(255,255,255),22);
    curPosY = curPosY-colorLabel1:getContentSize().height-10;
    colorLabel2:setPosition(cc.p(20,curPosY));

    local colorLabel3 = MGColorLabel:label();
    colorLabel3:setAnchorPoint(cc.p(0, 1));
    itemLay:addChild(colorLabel3);
    colorLabel3:clear();
    str = string.format(MG_TEXT("heroAttLayer_3"),gm:getStrategy());
    colorLabel3:appendStringAutoWrap(str,18,1,cc.c3b(255,255,255),22);
    curPosY = curPosY-colorLabel2:getContentSize().height-10;
    colorLabel3:setPosition(cc.p(20,curPosY));

    local titleSpr1 = cc.Sprite:createWithSpriteFrameName("hero_positioning.png");
    itemLay:addChild(titleSpr1);
    curPosY = curPosY-colorLabel3:getContentSize().height-40;
    titleSpr1:setPosition(cc.p(itemLay:getSize().width/2, curPosY));

    local desLabel1 = cc.Label:createWithTTF(gm:getTypeDesc(),ttf_msyh,22);
    desLabel1:setAlignment(cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_TOP);
    desLabel1:setDimensions(530, 0);
    desLabel1:setAnchorPoint(cc.p(0, 1));
    itemLay:addChild(desLabel1);
    curPosY = curPosY-titleSpr1:getContentSize().height;
    desLabel1:setPosition(cc.p(20,curPosY));

    local titleSpr2 = cc.Sprite:createWithSpriteFrameName("hero_introduce.png");
    itemLay:addChild(titleSpr2);
    curPosY = curPosY-desLabel1:getContentSize().height-40;
    titleSpr2:setPosition(cc.p(itemLay:getSize().width/2, curPosY));

    local desLabel2 = cc.Label:createWithTTF(gm:desc(),ttf_msyh,22);
    desLabel2:setAlignment(cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_TOP);
    desLabel2:setDimensions(530, 0);
    desLabel2:setAnchorPoint(cc.p(0, 1));
    itemLay:addChild(desLabel2);
    curPosY = curPosY-titleSpr2:getContentSize().height;
    desLabel2:setPosition(cc.p(20,curPosY));

    curPosY = 0;
    local height = colorLabel1:getContentSize().height*3+titleSpr1:getContentSize().height*2+
        desLabel1:getContentSize().height+desLabel2:getContentSize().height+150;
    curPosY = itemLay:getSize().height-10;
    colorLabel1:setPosition(cc.p(20,curPosY));
    curPosY = curPosY-colorLabel1:getContentSize().height-10;
    colorLabel2:setPosition(cc.p(20,curPosY));
    curPosY = curPosY-colorLabel2:getContentSize().height-10;
    colorLabel3:setPosition(cc.p(20,curPosY));
    curPosY = curPosY-colorLabel3:getContentSize().height-40;
    titleSpr1:setPosition(cc.p(itemLay:getSize().width/2, curPosY));
    curPosY = curPosY-titleSpr1:getContentSize().height;
    desLabel1:setPosition(cc.p(20,curPosY));
    curPosY = curPosY-desLabel1:getContentSize().height-40;
    titleSpr2:setPosition(cc.p(itemLay:getSize().width/2, curPosY));
    curPosY = curPosY-titleSpr2:getContentSize().height;
    desLabel2:setPosition(cc.p(20,curPosY));
    
end

function heroDetailsLayer:createLine()
    local layout = ccui.Layout:create();
    layout:setSize(cc.size(self.ListView:getSize().width,70));

    local titleSpr = cc.Sprite:createWithSpriteFrameName("hero_positioning.png");
    titleSpr:setPosition(cc.p(layout:getSize().width/2, layout:getSize().height/2));
    layout:addChild(titleSpr);

    local lineSpr1 = cc.Sprite:createWithSpriteFrameName("hero_line1.png");
    lineSpr1:setPosition(cc.p(titleSpr:getPositionX()-50, titleSpr:getPositionY()));
    layout:addChild(lineSpr1);

    local lineSpr2 = cc.Sprite:createWithSpriteFrameName("hero_line1.png");
    lineSpr2:setPosition(cc.p(titleSpr:getPositionX()+50, titleSpr:getPositionY()));
    layout:addChild(lineSpr2);
    

    local lineImg1 = ccui.ImageView:create("hero_line2.png", ccui.TextureResType.plistType);
    lineImg1:setAnchorPoint(cc.p(1,0.5))
    -- lineImg1:setPosition(cc.p(titleSpr:getPositionX()-150, titleSpr:getPositionY()));
    lineImg1:setPosition(lineSpr1:getPosition());
    lineImg1:setScale9Enabled(true);
    lineImg1:setCapInsets(cc.rect(8, 1, 1, 1));
    lineImg1:setSize(cc.size(250, 4));
    layout:addChild(lineImg1);

    return layout;
end

function heroDetailsLayer:onButtonClick(sender, eventType)
    if eventType == ccui.TouchEventType.began then
        if sender == self.Button_close then
            local sc = cc.ScaleTo:create(0.1, 1.1)
            sender:runAction(cc.EaseOut:create(sc ,2))
        end
        
    end
    if eventType == ccui.TouchEventType.canceled then
        if sender == self.Button_close then
            local sc = cc.ScaleTo:create(0.1, 1)
            sender:runAction(sc)
        end
    end
    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_close then
            local sc = cc.ScaleTo:create(0.1, 1)
            sender:runAction(sc)
        end
        self:removeFromParent();
    end
end

function heroDetailsLayer:onEnter()
end

function heroDetailsLayer:onExit()
    MGRCManager:releaseResources("heroDetailsLayer");
end

function heroDetailsLayer.create(delegate)
    local layer = heroDetailsLayer:new()
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

function heroDetailsLayer.showBox(delegate)
    local layer = heroDetailsLayer.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end