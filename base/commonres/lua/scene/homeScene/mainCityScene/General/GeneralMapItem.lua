----------------------武将图鉴-----------------------
require "HeroHeadEx"
require "heroEquipLayer"
require "Item"

local GeneralMapItem = class("GeneralMapItem", function()
    return ccui.Layout:create();
end)

GeneralMapItem.WIDTH = 410;
GeneralMapItem.HEIGHT = 235;

function GeneralMapItem:ctor()
    self.width = GeneralMapItem.WIDTH;
    self.height = GeneralMapItem.HEIGHT;
    self.isGet = true;--true表示已获得
    self.curLayer = nil;
    self.pos = 0;
    self.id = 0;
    self:init();
end

function GeneralMapItem:init()
    self:setAnchorPoint(cc.p(0.5,0.5));
    self:setSize(cc.size(self.width,self.height));

    self.bgSpr = cc.Sprite:createWithSpriteFrameName("general_item_bg.png");
    self.bgSpr:setPosition(cc.p(self.width/2, self.height/2));
    self:addChild(self.bgSpr);

    self.layoutBtn = ccui.Layout:create();
    self.layoutBtn:setTouchEnabled(true);
    self.layoutBtn:setAnchorPoint(cc.p(0.5,0.5));
    self.layoutBtn:setSize(cc.size(self.bgSpr:getContentSize().width, self.bgSpr:getContentSize().height));
    self.layoutBtn:setPosition(self.bgSpr:getPosition());
    self:addChild(self.layoutBtn);
    self.layoutBtn:addTouchEventListener(handler(self,self.onButtonClick));

    self.titleBgSpr = cc.Sprite:createWithSpriteFrameName("general_white.png");
    self.titleBgSpr:setPosition(cc.p(205,195));
    self:addChild(self.titleBgSpr);

    self.armSpr = cc.Sprite:createWithSpriteFrameName("com_hero_type_1.png");
    self.armSpr:setPosition(cc.p(self.titleBgSpr:getContentSize().width-50,self.titleBgSpr:getContentSize().height/2+5));
    self.titleBgSpr:addChild(self.armSpr);

    self.nameLabel = cc.Label:createWithTTF("", ttf_msyh, 22);
    self.nameLabel:setAnchorPoint(cc.p(0,0.5));
    self.nameLabel:setPosition(cc.p(20, self.armSpr:getPositionY()));
    self.nameLabel:enableShadow(cc.c4b(  0,   0,   0, 191), cc.size(2, -2),2);
    self.titleBgSpr:addChild(self.nameLabel);

    self.armLabel = cc.Label:createWithTTF("", ttf_msyh, 22);
    self.armLabel:setAnchorPoint(cc.p(1,0.5));
    self.armLabel:setPosition(cc.p(self.armSpr:getPositionX()-30, self.armSpr:getPositionY()));
    self.armLabel:enableShadow(cc.c4b(  0,   0,   0, 191), cc.size(2, -2),2);
    self.titleBgSpr:addChild(self.armLabel);

    self.heroHead = HeroHeadEx.create(self,2);
    self.heroHead:setAnchorPoint(cc.p(0.5, 0.5));
    self.heroHead:setPosition(cc.p(88, 92));
    self:addChild(self.heroHead);

    local debriSpr = cc.Sprite:createWithSpriteFrameName("com_general_icon_debris.png");
    debriSpr:setPosition(cc.p(173,152));
    self:addChild(debriSpr);

    self.numLabel = cc.Label:createWithTTF("0", ttf_msyh, 22);
    self.numLabel:setAnchorPoint(cc.p(0,0.5));
    self.numLabel:setPosition(cc.p(193,152));
    self.numLabel:setColor(cc.c3b(107,75,36));
    self:addChild(self.numLabel);

    self.layout = ccui.Layout:create();
    self.layout:setPosition(cc.p(160, 7));
    self.layout:setSize(cc.size(230, 80));
    self:addChild(self.layout);

    self.boxs = {};
    for i=1,4 do
        local boxImg = ccui.ImageView:create("general_icon_box.png", ccui.TextureResType.plistType);
        boxImg:setPosition(cc.p(boxImg:getContentSize().width/2+(boxImg:getContentSize().width+5)*(i-1),
            boxImg:getContentSize().height/2+5));
        boxImg:setTag(i);
        self.layout:addChild(boxImg);
        boxImg:setTouchEnabled(true);
        boxImg:addTouchEventListener(handler(self,self.onButtonClick));

        local item = Item.create(self);
        item:setTouchEnabled(false);
        item:setScale(0.48);
        item:setPosition(boxImg:getPosition());
        self.layout:addChild(item);

        local addSpr = cc.Sprite:createWithSpriteFrameName("general_add.png");
        addSpr:setPosition(boxImg:getPosition());
        self.layout:addChild(addSpr);
        addSpr:setOpacity(100);
        local action1 = cc.FadeIn:create(1);
        local action1Back = action1:reverse();
        local sequence = cc.Sequence:create(action1, action1Back);
        addSpr:runAction(cc.RepeatForever:create(sequence));

        table.insert(self.boxs,{box=boxImg,item=item,addSpr=addSpr});
    end

    local barSpr = cc.Sprite:createWithSpriteFrameName("general_progress_bar_bg.png");
    barSpr:setPosition(cc.p(self.layout:getContentSize().width/2-5,self.layout:getContentSize().height-10));
    self.layout:addChild(barSpr);

    self.progressBar = cc.ProgressTimer:create(cc.Sprite:createWithSpriteFrameName("general_progress_bar.png"));
    self.progressBar:setType(cc.PROGRESS_TIMER_TYPE_BAR);
    self.progressBar:setBarChangeRate(cc.p(1,0));
    self.progressBar:setMidpoint(cc.p(0,0));
    self.progressBar:setPosition(barSpr:getPosition());
    self.progressBar:setAnchorPoint(cc.p(0.5,0.5));
    self.layout:addChild(self.progressBar,1);
    self.progressBar:setPercentage(100);

    self.coverSpr = cc.Sprite:createWithSpriteFrameName("general_item_cover.png");
    self.coverSpr:setPosition(cc.p(self.width/2-1, self.height/2+2));
    self:addChild(self.coverSpr,10);
    self.coverSpr:setVisible(false);

    self.nameLabel1 = cc.Label:createWithTTF("", ttf_msyh, 22);
    self.nameLabel1:setAnchorPoint(cc.p(0.5,0.5));
    self.nameLabel1:enableOutline(Color4B.BLACK,2);
    self.nameLabel1:setPosition(cc.p(self.coverSpr:getContentSize().width/2, self.coverSpr:getContentSize().height/2+20));
    self.coverSpr:addChild(self.nameLabel1);
    self.nameLabel1:setAdditionalKerning(-2);

    local debriSpr1 = cc.Sprite:createWithSpriteFrameName("com_general_icon_debris.png");
    debriSpr1:setPosition(cc.p(self.nameLabel1:getPositionX()-40,self.coverSpr:getContentSize().height/2-20));
    self.coverSpr:addChild(debriSpr1);

    self.numLabel1 = cc.Label:createWithTTF("", ttf_msyh, 22);
    self.numLabel1:setAnchorPoint(cc.p(0,0.5));
    self.numLabel1:enableOutline(Color4B.BLACK,2);
    self.numLabel1:setPosition(cc.p(debriSpr1:getPositionX()+20, self.coverSpr:getContentSize().height/2-20));
    self.coverSpr:addChild(self.numLabel1);
    self.numLabel1:setAdditionalKerning(-2);

    self.previewBtn = ccui.Button:create();
    self.previewBtn:setPosition(cc.p(self.coverSpr:getContentSize().width-40, 50));
    self.previewBtn:loadTextureNormal("general_preview_button.png", ccui.TextureResType.plistType);
    self.previewBtn:loadTexturePressed("general_preview_button.png", ccui.TextureResType.plistType);
    self.previewBtn:loadTextureDisabled("general_preview_button.png", ccui.TextureResType.plistType);
    self.coverSpr:addChild(self.previewBtn);
    self.previewBtn:addTouchEventListener(handler(self,self.onButtonClick));
end

function GeneralMapItem:setData(gm,soldierList,isGet)
    self.gm = gm;
    self.soldierList = soldierList;
    if nil == isGet then
        self.isGet = true;
    else
        self.isGet = isGet;
    end
    self.heroHead:setData(gm);
    self.nameLabel:setString(self.gm:name());
    self.armSpr:setSpriteFrame(string.format("com_hero_type_%d.png",gm:getType()));

    self.armLabel:setString(self.soldierList[gm:soldierid()].name);
    self.titleBgSpr:setSpriteFrame(self:setTitleBg(gm:getQuality()));
    if self.isGet == true then--已获得武将的显示
        self.coverSpr:setVisible(false);
        self.id = self.gm:getId();
        resNum,totNum = getGeneralNeedDebrisNum(self.gm,true);
        if self.gm:getStar() < ME:getMaxStar() then
            self.numLabel:setString(string.format("%d/%d",resNum,totNum));
            self.progressBar:setPercentage(resNum*100/totNum);
        else
            self.numLabel:setString(resNum);
            self.progressBar:setPercentage(100);
        end
    else
        self.coverSpr:setVisible(true);
        resNum,totNum = getGeneralNeedDebrisNum(self.gm,false);
        self.numLabel:setString(string.format("%d/%d",resNum,totNum));
        self.numLabel1:setString(string.format("%d/%d",resNum,totNum));
        self.nameLabel1:setString(self.gm:name());
        self.progressBar:setPercentage(100);
        if resNum < totNum then
            self.progressBar:setPercentage(resNum*100/totNum);
        end
    end

    if self.isGet == true then--已获得武将的显示
        self.equipInfo = EquipData:getEquipInfo(GeneralData:getGeneralInfo(gm:getId()):soldierid(),gm:getQuality());
        for i=1,#self.equipInfo:getEquipItem() do
            self:setBox(i);
        end
    end
end

function GeneralMapItem:setBox(tag)
    self.equipInfo = EquipData:getEquipInfo(GeneralData:getGeneralInfo(self.gm:getId()):soldierid(),self.gm:getQuality());
    local generalLv = self.gm:getLevel();
    local state = self.gm:getEquipState(tag);
    self.boxs[tag].item:setIsGray(true);
    self.equipData = self.equipInfo:getEquipItem()[tag];
    self.boxs[tag].item:setData(RESOURCE:getDBResourceListByItemId(self.equipData:getItemId()));
    self.boxs[tag].item.numLabel:setVisible(false);
    self.boxs[tag].addSpr:setVisible(false);
    -- self.boxs[tag].Label_num:setVisible(false);
    -- self.boxs[tag].Label_lv:setVisible(false);
    if state == 0 then--还未装备
        if generalLv < self.equipData:getLevel() then
            -- self.boxs[tag].Label_lv:setVisible(true);
        elseif generalLv >= self.equipData:getLevel() then
            local equipNum = 0;
            if RESOURCE:getResModelByItemId(self.equipData:getItemId()) then
                equipNum = RESOURCE:getResModelByItemId(self.equipData:getItemId()):getNum();
            end
            local disNum = self.equipData:getNum() - equipNum;
            if equipNum >= self.equipData:getNum() then
                self.boxs[tag].addSpr:setVisible(true);
            end
        end
    elseif state == 1 then--已装备
        self.boxs[tag].item:setIsGray(false);
    end
end

function GeneralMapItem:setTitleBg(id)
    local picName = "general_white.png";
    local DBData = LUADB.select(string.format("select color from quality where id=%d",id), "color");
    if tonumber(DBData.info.color) == 1 then
        picName = "general_white.png";
    elseif tonumber(DBData.info.color) == 2 then
        picName = "general_green.png";
    elseif tonumber(DBData.info.color) == 3 then
        picName = "general_blue.png";
    elseif tonumber(DBData.info.color) == 4 then
        picName = "general_purple.png";
    elseif tonumber(DBData.info.color) == 5 then
        picName = "general_orange.png";
    elseif tonumber(DBData.info.color) == 6 then
        picName = "general_red.png";
    end

    return picName;
end

function GeneralMapItem:setIsGray(isGray)
    self.heroHead:setIsGray(isGray);
    self.layout:setVisible(false);
    for i=1,4 do
        self.boxs[i].box:setTouchEnabled(false);
    end
    self.nameLabel:setColor(Color3B.GRAY);
    self.armLabel:setColor(Color3B.GRAY);
end

function GeneralMapItem:HeroHeadSelect(head)
    if self.delegate and self.delegate.HeroHeadSelect then
        self.delegate:HeroHeadSelect(self);
    end
end

function GeneralMapItem:onButtonClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        if sender == self.layoutBtn or sender == self.previewBtn then
            if self.delegate and self.delegate.HeroHeadSelect then
                self.delegate:HeroHeadSelect(self);
            end
        else
            self.curLayer = heroEquipLayer.showBox(self);
            self.curLayer:setData(self.gm,sender:getTag());
            self.pos = sender:getTag();
        end
    end
end

function GeneralMapItem:removeChildrenLayer()
    if self.curLayer then
        self.curLayer:removeFromParent();
        self.curLayer = nil;
    end
end

function GeneralMapItem:sendReq()
    if self.delegate and self.delegate.sendReq then
        self.delegate:sendReq(self.id,self.pos);
    end
end

function GeneralMapItem:onEnter()

end

function GeneralMapItem:onExit()
    MGRCManager:releaseResources("GeneralMapItem")
end

function GeneralMapItem.create(delegate)
    local layer = GeneralMapItem:new()
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

return GeneralMapItem;
