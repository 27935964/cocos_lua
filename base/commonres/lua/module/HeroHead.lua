----------------------武将头像（NPC，我方，敌方）-----------------------
HeroHead = class("HeroHead", function()
    return ccui.ImageView:create();
end)

HeroHead.WIDTH = 92;
HeroHead.HEIGHT = 109;

function HeroHead:ctor()
    self.gid = 0;
    self.isNPC = false;
    self.quality = 0;
    self.gm = nil;
    self.isGray = false;
    self.nodes = {};
    self:init();
end

function HeroHead:init()
    MGRCManager:cacheResource("HeroHead", "herohead.png","herohead.plist");

    self:loadTexture("herohead_bg.png",ccui.TextureResType.plistType);
    self:setTouchEnabled(true);
    self:addTouchEventListener(handler(self,self.onBtnClick));
    self.size = self:getContentSize();

    self.headSpr = cc.Sprite:create();
    self.headSpr:setPosition(cc.p(self:getContentSize().width/2, self:getContentSize().height/2+9));
    self:addChild(self.headSpr);
    self.oldHeadProgram = self.headSpr:getShaderProgram();
    table.insert(self.nodes,self.headSpr);

    self.boxSpr = cc.Sprite:createWithSpriteFrameName("herohead_kuan_1.png");
    self.boxSpr:setPosition(cc.p(self:getContentSize().width/2, self:getContentSize().height/2));
    self:addChild(self.boxSpr,1);
    table.insert(self.nodes,self.boxSpr);

    self.starSprs = {};
    for i=1,5 do
        local pSpr = cc.Sprite:createWithSpriteFrameName("com_lit_star1.png");
        pSpr:setPosition(cc.p(self.size.width/2-48+i*16, self.size.height/2-22));
        self:addChild(pSpr);
        pSpr:setVisible(false);
        table.insert(self.starSprs, pSpr);
        table.insert(self.nodes,pSpr);
    end

    self.dotSprs = {};
    for i=1,3 do
        local pSpr = cc.Sprite:createWithSpriteFrameName("com_qdot_1.png");
        pSpr:setPosition(cc.p(self.size.width/2-36+i*18, self.size.height/2+50));
        self:addChild(pSpr,3);
        pSpr:setVisible(false);
        table.insert(self.dotSprs, pSpr);
        table.insert(self.nodes,pSpr);
    end

    self.lvLabel = cc.Label:createWithTTF("1", ttf_msyh, 22);
    self.lvLabel:setPosition(cc.p(self.size.width/2+25, self.size.height/2+30));
    self.lvLabel:setColor(cc.c3b(255,230,116));
    self.lvLabel:enableOutline(Color4B.BLACK,1);
    self:addChild(self.lvLabel,2);
    self.lvLabel:setAdditionalKerning(-2);

    local AngerSpr = cc.Sprite:createWithSpriteFrameName("herohead_hp_bg.png");
    AngerSpr:setPosition(cc.p(self.size.width/2,self.size.height/2-44));
    self:addChild(AngerSpr,1);

    self.progressAnger = cc.ProgressTimer:create(cc.Sprite:createWithSpriteFrameName("herohead_anger.png"));
    self.progressAnger:setType(cc.PROGRESS_TIMER_TYPE_BAR);
    self.progressAnger:setBarChangeRate(cc.p(1,0));
    self.progressAnger:setMidpoint(cc.p(0,0));
    self.progressAnger:setPosition(cc.p(self.size.width/2,self.size.height/2-44));
    self.progressAnger:setAnchorPoint(cc.p(0.5,0.5));
    self:addChild(self.progressAnger,2);
    self.progressAnger:setPercentage(100);
    table.insert(self.nodes,self.progressAnger);

    local HPSpr = cc.Sprite:createWithSpriteFrameName("herohead_hp_bg.png");
    HPSpr:setPosition(cc.p(self.size.width/2,self.size.height/2-37));
    self:addChild(HPSpr,1);

    self.progressHP = cc.ProgressTimer:create(cc.Sprite:createWithSpriteFrameName("herohead_hp.png"));
    self.progressHP:setType(cc.PROGRESS_TIMER_TYPE_BAR);
    self.progressHP:setBarChangeRate(cc.p(1,0));
    self.progressHP:setMidpoint(cc.p(0,0));
    self.progressHP:setPosition(cc.p(self.size.width/2,self.size.height/2-37));
    self.progressHP:setAnchorPoint(cc.p(0.5,0.5));
    self.progressHP:setPercentage(100);
    self:addChild(self.progressHP,2);
    table.insert(self.nodes,self.progressHP);
    
end

function HeroHead:setData(gm,isNPC)
    if nil == isNPC then
        self.isNPC = false;
    else
        self.isNPC = isNPC;
    end
    self.gm = gm;

    if self.gm then
        self.gid = self.gm:getId();
        MGRCManager:cacheResource("HeroHead", self.gm:head());
        self.headSpr:setSpriteFrame(self.gm:head());
        self.boxSpr:setSpriteFrame(GeneralData:getKuanPic(self.gm:getQuality()));

        for i=1,self.gm:getStar() do
            if i > #self.starSprs then
                break;
            end
            self.starSprs[i]:setVisible(true);
            self.starSprs[i]:setSpriteFrame(string.format("com_lit_star%d.png",self.gm:getRare()));
        end
        self:setStarPosition(self.gm:getStar());

        self.headSpr:setVisible(true);
        self.lvLabel:setVisible(true);
        self.lvLabel:setString(self.gm:getLevel());
        self.progressAnger:setVisible(true);
        self.progressHP:setVisible(true);
        self.progressAnger:setPercentage(self.gm:getAnger()*100/self.gm:getMaxAnger());
        self.progressHP:setPercentage(self.gm:getForce()*100/self.gm:getMaxforces());

        local DotNum = GeneralData:getDotNum(self.gm:getQuality());
        local Dotfile = GeneralData:getDotPic(self.gm:getQuality());
        if DotNum == 1 then
            self.dotSprs[1]:setVisible(true);
            self.dotSprs[1]:setSpriteFrame(Dotfile);
            self.dotSprs[1]:setPosition(cc.p(self.size.width/2, self.size.height/2+50));
        elseif DotNum == 2 then
            self.dotSprs[1]:setVisible(true);
            self.dotSprs[1]:setSpriteFrame(Dotfile);
            self.dotSprs[1]:setPosition(cc.p(self.size.width/2-9, self.size.height/2+50));
            self.dotSprs[2]:setVisible(true);
            self.dotSprs[2]:setSpriteFrame(Dotfile);
            self.dotSprs[2]:setPosition(cc.p(self.size.width/2+9, self.size.height/2+50));
        elseif DotNum == 3 then
            for i=1,#self.dotSprs do
                self.dotSprs[i]:setVisible(true);
                self.dotSprs[i]:setSpriteFrame(Dotfile);
                self.dotSprs[i]:setPosition(cc.p(self.size.width/2-36+i*18, self.size.height/2+50));
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
        self.progressAnger:setVisible(false);
        self.progressHP:setVisible(false);
        self.boxSpr:setSpriteFrame("herohead_kuan_1.png");
    end
end

function HeroHead:setStarPosition(starNum)
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


function HeroHead:setStar(star)
    for i=1,#self.starSprs  do
        if i<= star then
            self.starSprs[i]:setVisible(true);
        else
            self.starSprs[i]:setVisible(false);
        end
    end
end


function HeroHead:setIsGray(isGray)
    self.isGray = isGray;
    if isGray then
        self.lvLabel:setColor(Color3B.GRAY);
        for i=1,#self.nodes do
            self.nodes[i]:setShaderProgram(MGGraySprite:getGrayShaderProgram());
        end
    else
        self.lvLabel:setColor(cc.c3b(255,230,116));
        for i=1,#self.nodes do
            self.nodes[i]:setShaderProgram(self.oldHeadProgram);
        end
    end
end

function HeroHead:setSel(isel)
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

function HeroHead:onBtnClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        if self.delegate and self.delegate.HeroHeadSelect then
            self.delegate:HeroHeadSelect(self);
        end
    end
end

function HeroHead:onEnter()

end

function HeroHead:onExit()
    MGRCManager:releaseResources("HeroHead")
end

function HeroHead.create()
    local layer = HeroHead:new()
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
