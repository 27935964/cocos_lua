----------------------武将头像版本2-----------------------

HeroHeadEx = class("HeroHeadEx", function()
    return ccui.ImageView:create();
end)

HeroHeadEx.WIDTH=88;
HeroHeadEx.HEIGHT=88;

function HeroHeadEx:ctor(delegate,type)
    self.delegate = delegate;
    self.type = type;--type=1方框头像，2是长形框头像
    self.gid = 0;
    self.isNPC = false;
    self.gm = nil;
    self.isGray = false;
    self.nodes = {};
    self.itemInfo = {};
    self:init();
end

function HeroHeadEx:init()
    --背景
    self:loadTexture("com_item_bg.png",ccui.TextureResType.plistType);
    self:setPosition(cc.p(self:getContentSize().width/2, self:getContentSize().height/2));
    if self.type == 2 then
        self:loadTexture("com_item_bg_1.png",ccui.TextureResType.plistType);
    end
    self:setTouchEnabled(true);
    self:addTouchEventListener(handler(self,self.onBtnClick));
    self.size = self:getContentSize();

    --头像
    self.headSpr = cc.Sprite:create();
    self.headSpr:setPosition(cc.p(self:getContentSize().width/2, self:getContentSize().height/2));
    self:addChild(self.headSpr);
    self.oldHeadProgram = self.headSpr:getShaderProgram();
    table.insert(self.nodes,self.headSpr);

    --头像框
    self.boxSpr = ccui.ImageView:create("com_item_kuan_1.png", ccui.TextureResType.plistType);
    self.boxSpr:setPosition(cc.p(self:getContentSize().width/2, self:getContentSize().height/2));
    if self.type == 2 then
        self.boxSpr:setScale9Enabled(true);
    else
        self.boxSpr:setScale9Enabled(false);
    end
    self.boxSpr:setCapInsets(cc.rect(46, 46, 1, 1));
    self.boxSpr:setSize(cc.size(133, 160));
    self:addChild(self.boxSpr,1);

    --星星背景
    self.starBg = cc.Sprite:createWithSpriteFrameName("com_star_bg.png");
    self.starBg:setPosition(cc.p(self:getContentSize().width/2, 10));
    self:addChild(self.starBg);
    table.insert(self.nodes,self.starBg);
    if self.type == 2 then
        self.starBg:setVisible(true);
    else
        self.starBg:setVisible(false);
    end

    self.starSprs = {};
    for i=1,5 do
        local pSpr = cc.Sprite:createWithSpriteFrameName("com_lit_star1.png");
        pSpr:setPosition(cc.p(self.size.width/2-48+i*16, 10));
        self:addChild(pSpr);
        pSpr:setVisible(false);
        table.insert(self.starSprs, pSpr);
        table.insert(self.nodes,pSpr);
    end

    self.dotSprs = {};
    for i=1,3 do
        local pSpr = cc.Sprite:createWithSpriteFrameName("com_qdot_1.png");
        pSpr:setPosition(cc.p(self.size.width/2-36+i*18, self.size.height-3));
        self:addChild(pSpr,30);
        pSpr:setVisible(false);
        table.insert(self.dotSprs, pSpr);
        table.insert(self.nodes,pSpr);
    end

    --等级
    self.lvLabel = cc.Label:createWithTTF("1", ttf_msyh, 22);
    self.lvLabel:setAnchorPoint(cc.p(1,0.5))
    self.lvLabel:setPosition(cc.p(self.size.width-7, self.size.height-18));
    self.lvLabel:setColor(cc.c3b(255,230,116));
    self.lvLabel:enableOutline(Color4B.BLACK,2);
    self:addChild(self.lvLabel,2);
    self.lvLabel:setAdditionalKerning(-2);
end

function HeroHeadEx:setData(gm,isNPC)--type=1表示头像方形显示，type=2表示半身像长方形显示
    if nil == isNPC then
        self.isNPC = false;
    else
        self.isNPC = isNPC;
    end
    
    if self.gm then
        self.gm:release();
        self.gm = nil;
    end
    self.gm = gm;
    self.gm:retain();

    self.size = self:getContentSize();
    self.boxSpr:setPosition(cc.p(self.size.width/2, self.size.height/2));
    self.headSpr:setPosition(cc.p(self.size.width/2, self.size.height/2));

    if self.gm then
        self.gid = self.gm:getId();
        MGRCManager:cacheResource("HeroHeadEx", self.gm:head());
        self.headSpr:setSpriteFrame(self.gm:head());
        self.boxSpr:loadTexture(GeneralData:getBoxPic(self.gm:getQuality()),ccui.TextureResType.plistType);

        for i=1,self.gm:getStar() do
            if i > #self.starSprs then
                break;
            end
            self.starSprs[i]:setVisible(true);
            self.starSprs[i]:setSpriteFrame(string.format("com_lit_star%d.png",self.gm:getRare()));
            self.starSprs[i]:setPosition(cc.p(self.size.width/2-48+i*16, 10));
        end
        
        self:setStarPosition(self.gm:getStar());

        self.headSpr:setVisible(true);
        self.lvLabel:setVisible(true);
        self.lvLabel:setPosition(cc.p(self.size.width-7, self.size.height-18));
        self.lvLabel:setString(self.gm:getLevel());

        local DotNum = GeneralData:getDotNum(self.gm:getQuality());
        local Dotfile = GeneralData:getDotPic(self.gm:getQuality());
        if DotNum == 1 then
            self.dotSprs[1]:setVisible(true);
            self.dotSprs[1]:setSpriteFrame(Dotfile);
            self.dotSprs[1]:setPosition(cc.p(self.size.width/2, self.size.height-3));
        elseif DotNum == 2 then
            self.dotSprs[1]:setVisible(true);
            self.dotSprs[1]:setSpriteFrame(Dotfile);
            self.dotSprs[1]:setPosition(cc.p(self.size.width/2-9, self.size.height-3));
            self.dotSprs[2]:setVisible(true);
            self.dotSprs[2]:setSpriteFrame(Dotfile);
            self.dotSprs[2]:setPosition(cc.p(self.size.width/2+9, self.size.height-3));
        elseif DotNum == 3 then
            for i=1,#self.dotSprs do
                self.dotSprs[i]:setVisible(true);
                self.dotSprs[i]:setSpriteFrame(Dotfile);
                self.dotSprs[i]:setPosition(cc.p(self.size.width/2-36+i*18, self.size.height-3));
            end
        end

        if self.type == 2 then
            self:loadTexture(GeneralData:getBgPic(self.gm:getQuality()),ccui.TextureResType.plistType);
            local info = GeneralData:getGeneralInfo(self.gm:getId());
            if info then
                MGRCManager:cacheResource("HeroHeadEx", info:bust()..".png");
                self.headSpr:setSpriteFrame(info:bust()..".png");
            end
        end

        self:setItemInfo(self.gm);
    else
        self.gid = 0;
        self.headSpr:setVisible(false);
        for i=1,#self.starSprs do
            self.starSprs[i]:setVisible(false);
        end
        for i=1,#self.dotSprs do
            self.dotSprs[i]:setVisible(false);
        end
        self.lvLabel:setVisible(false);
        self.boxSpr:loadTexture("com_item_kuan_1.png",ccui.TextureResType.plistType);
    end
end

function HeroHeadEx:setEnemyData(id,level,quality,star)--敌军武将信息
    local gm = GENERAL:getAllGeneralModel(id);
    if self.gm then
        self.gm:release();
        self.gm = nil;
    end
    self.gm = gm;
    self.gm:retain();

    self.size = self:getContentSize();
    self.boxSpr:setPosition(cc.p(self.size.width/2, self.size.height/2));
    self.headSpr:setPosition(cc.p(self.size.width/2, self.size.height/2));

    if self.gm then
        self.gid = id;
        MGRCManager:cacheResource("HeroHeadEx", self.gm:head());
        self.headSpr:setSpriteFrame(self.gm:head());
        self.boxSpr:loadTexture(GeneralData:getBoxPic(quality),ccui.TextureResType.plistType);

        for i=1,star do
            if i > #self.starSprs then
                break;
            end
            self.starSprs[i]:setVisible(true);
            -- self.starSprs[i]:setSpriteFrame(string.format("com_lit_star%d.png",self.gm:getRare()));
            self.starSprs[i]:setPosition(cc.p(self.size.width/2-48+i*16, 10));
        end
        self:setStarPosition(star);

        self.headSpr:setVisible(true);
        self.lvLabel:setVisible(true);
        self.lvLabel:setPosition(cc.p(self.size.width-7, self.size.height-18));
        self.lvLabel:setString(level);

        local DotNum = GeneralData:getDotNum(quality);
        local Dotfile = GeneralData:getDotPic(quality);
        if DotNum == 1 then
            self.dotSprs[1]:setVisible(true);
            self.dotSprs[1]:setSpriteFrame(Dotfile);
            self.dotSprs[1]:setPosition(cc.p(self.size.width/2, self.size.height-3));
        elseif DotNum == 2 then
            self.dotSprs[1]:setVisible(true);
            self.dotSprs[1]:setSpriteFrame(Dotfile);
            self.dotSprs[1]:setPosition(cc.p(self.size.width/2-9, self.size.height-3));
            self.dotSprs[2]:setVisible(true);
            self.dotSprs[2]:setSpriteFrame(Dotfile);
            self.dotSprs[2]:setPosition(cc.p(self.size.width/2+9, self.size.height-3));
        elseif DotNum == 3 then
            for i=1,#self.dotSprs do
                self.dotSprs[i]:setVisible(true);
                self.dotSprs[i]:setSpriteFrame(Dotfile);
                self.dotSprs[i]:setPosition(cc.p(self.size.width/2-36+i*18, self.size.height-3));
            end
        end

        if self.type == 2 then
            self:loadTexture(GeneralData:getBgPic(quality),ccui.TextureResType.plistType);
            local info = GeneralData:getGeneralInfo(id);
            if info then
                MGRCManager:cacheResource("HeroHeadEx", info:bust()..".png");
                self.headSpr:setSpriteFrame(info:bust()..".png");
            end
        end
    else
        self.gid = 0;
        self.isNPC = false;
        self.headSpr:setVisible(false);
        for i=1,#self.starSprs do
            self.starSprs[i]:setVisible(false);
        end
        for i=1,#self.dotSprs do
            self.dotSprs[i]:setVisible(false);
        end
        self.lvLabel:setVisible(false);
        self.boxSpr:loadTexture("com_item_kuan_1.png",ccui.TextureResType.plistType);
    end
end

function HeroHeadEx:setStarPosition(starNum)
    local average = math.ceil(starNum/2);
    local mod = math.mod(starNum,2);
    local posX = self:getContentSize().width/2;
    if mod == 0 then
        posX = posX-self.starSprs[1]:getContentSize().width/2;
        for i=1,starNum do
            if i < average then
                self.starSprs[i]:setPositionX(posX-(average-i)*(self.starSprs[i]:getContentSize().width));
            elseif i == average then
                self.starSprs[i]:setPositionX(posX);
            else
                self.starSprs[i]:setPositionX(posX+(i-average)*(self.starSprs[i]:getContentSize().width));
            end
        end
    elseif mod == 1 then
        for i=1,starNum do
            if i < average then
                self.starSprs[i]:setPositionX(posX-(average-i)*(self.starSprs[i]:getContentSize().width));
            elseif i == average then
                self.starSprs[i]:setPositionX(posX);
            else
                self.starSprs[i]:setPositionX(posX+(i-average)*(self.starSprs[i]:getContentSize().width));
            end
        end
    end
end

function HeroHeadEx:setItemInfo(gm)
    self.itemInfo = {};
    self.itemInfo.type = 8;
    self.itemInfo.id = gm:getId();
    self.itemInfo.num = 1;
    self.itemInfo.name = gm:name();
    if self.isNPC == false then
        self.itemInfo.desc = gm:desc();
    end
    self.itemInfo.pic = gm:head();
    self.itemInfo.quality = gm:getQuality();
    self.itemInfo.get_go = {};
end

function HeroHeadEx:getItemInfo()
    return self.itemInfo;
end

function HeroHeadEx:setIsGray(isGray)
    self.isGray = isGray;
    if isGray then
        self.boxSpr:loadTexture("com_item_kuan_1.png",ccui.TextureResType.plistType);
        self.boxSpr:setColor(Color3B.GRAY);
        self.lvLabel:setColor(Color3B.GRAY);
        for i=1,#self.nodes do
            self.nodes[i]:setShaderProgram(MGGraySprite:getGrayShaderProgram());
        end
    else
        self.boxSpr:setColor(Color3B.WHITE);
        self.lvLabel:setColor(cc.c3b(255,230,116));
        for i=1,#self.nodes do
            self.nodes[i]:setShaderProgram(self.oldHeadProgram);
        end
    end
end

function HeroHeadEx:setSel(isel)
    if isel then
        if self.selspr==nil then
            self.selspr = cc.Sprite:createWithSpriteFrameName("com_selected_box.png");
            self.selspr:setPosition(cc.p(self:getContentSize().width/2, self:getContentSize().height/2));
            self.selspr:setScale(self:getContentSize().width/self.selspr:getContentSize().width);
            self:addChild(self.selspr,10);
        else
            self.selspr:setVisible(true);
        end
    else
        if self.selspr then
            self.selspr:setVisible(false);
        end
    end
end

function HeroHeadEx:showname()
    self.nameLabel = cc.Label:createWithTTF(self.gm:name(), ttf_msyh, 22);
    self.nameLabel:setAnchorPoint(cc.p(0.5,1))
    self.nameLabel:setPosition(cc.p(self.size.width/2, -5));
    self.nameLabel:setColor(QualityDB:getColor3B(self.gm:getQuality()));
    self:addChild(self.nameLabel,2);
end

function HeroHeadEx:onBtnClick(sender, eventType)
    -- if eventType == ccui.TouchEventType.began then
    --     local sc = cc.ScaleTo:create(0.1, 1.1)
    --     sender:runAction(cc.EaseOut:create(sc ,2))
    -- end
    -- if eventType == ccui.TouchEventType.canceled then
    --     local sc = cc.ScaleTo:create(0.1, 1)
    --     sender:runAction(sc)
    -- end
    if eventType == ccui.TouchEventType.ended then
        -- local sc = cc.ScaleTo:create(0.1, 1)
        -- sender:runAction(sc)
        if self.delegate and self.delegate.HeroHeadSelect then
            self.delegate:HeroHeadSelect(self);
        end
    end
end

function HeroHeadEx:onEnter()

end

function HeroHeadEx:onExit()
    if self.gm then
        self.gm:release();
        self.gm = nil;
    end
    MGRCManager:releaseResources("HeroHeadEx")
end

function HeroHeadEx.create(delegate,type)
    local layer = HeroHeadEx.new(delegate,type)
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
