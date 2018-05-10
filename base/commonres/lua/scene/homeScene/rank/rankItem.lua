require "utf8"
rankItem = class("rankItem", function()
    return ccui.Layout:create();
end)

function rankItem:ctor()
    self:init();
end

function rankItem:init()
    --背景
    self:setTouchEnabled(true);
    self:addTouchEventListener(handler(self,self.onBtnClick));
    self:setSize(cc.size(1123,54));
end

function rankItem:setData(id,info)
    self.info = info;
    info.name = unicode_to_utf8(info.name);
    if math.mod(info.rank,2) == 1 then
        local bgImg = ccui.ImageView:create("com_rank_bg.png", ccui.TextureResType.plistType);
        bgImg:setPosition(cc.p(self:getContentSize().width/2, self:getContentSize().height/2));
        bgImg:setScale9Enabled(true);
        bgImg:setCapInsets(cc.rect(30, 26, 1, 1));
        bgImg:setSize(cc.size(939,54));
        self:addChild(bgImg);
    end

    if info.rank <4 then
        local pic = string.format("com_rank_cup_%d.png",info.rank)
        local rankSpr = cc.Sprite:createWithSpriteFrameName(pic);
        rankSpr:setPosition(cc.p(154,23));
        self:addChild(rankSpr,1);
    else
        local strrank = ""..info.rank;
        local rankLabel = cc.Label:createWithTTF(strrank, ttf_msyh, 22);
        rankLabel:setPosition(cc.p(154, 28));
        self:addChild(rankLabel,1);
        rankLabel:setColor(cc.c3b(219,198,123));
    end

    if id == 1 then
        self.nameLabel = cc.Label:createWithTTF(info.name, ttf_msyh, 22);
        self.nameLabel:setPosition(cc.p(398, 28));
        self:addChild(self.nameLabel,1);

        local strlv = ""..info.lv;
        local lvLabel = cc.Label:createWithTTF(strlv, ttf_msyh, 22);
        lvLabel:setPosition(cc.p(694, 28));
        self:addChild(lvLabel,1);

        local strscore = ""..info.score;
        local scoreLabel = cc.Label:createWithTTF(strscore, ttf_msyh, 22);
        scoreLabel:setPosition(cc.p(950, 28));
        self:addChild(scoreLabel,1);
    elseif id == 2 then
        self.nameLabel = cc.Label:createWithTTF(info.name, ttf_msyh, 22);
        self.nameLabel:setPosition(cc.p(340, 28));
        self:addChild(self.nameLabel,1);

        local heroLabel = cc.Label:createWithTTF(unicode_to_utf8(info.g_name), ttf_msyh, 22);
        heroLabel:setPosition(cc.p(567, 28));
        self:addChild(heroLabel,1);

        local strlv = ""..info.g_lv;
        local lvLabel = cc.Label:createWithTTF(strlv, ttf_msyh, 22);
        lvLabel:setPosition(cc.p(740, 28));
        self:addChild(lvLabel,1);

        local strscore = ""..info.g_score;
        local scoreLabel = cc.Label:createWithTTF(strscore, ttf_msyh, 22);
        scoreLabel:setPosition(cc.p(950, 28));
        self:addChild(scoreLabel,1);
    elseif id == 4 then
        self.nameLabel = cc.Label:createWithTTF(info.name, ttf_msyh, 22);
        self.nameLabel:setPosition(cc.p(398, 28));
        self:addChild(self.nameLabel,1);

        local strlv = ""..info.lv;
        local lvLabel = cc.Label:createWithTTF(strlv, ttf_msyh, 22);
        lvLabel:setPosition(cc.p(694, 28));
        self:addChild(lvLabel,1);

        local strscore = ""..info.score;
        local scoreLabel = cc.Label:createWithTTF(strscore, ttf_msyh, 22);
        scoreLabel:setPosition(cc.p(950, 28));
        self:addChild(scoreLabel,1);
    elseif id == 5 then
        self.nameLabel = cc.Label:createWithTTF(info.name, ttf_msyh, 22);
        self.nameLabel:setPosition(cc.p(398, 28));
        self:addChild(self.nameLabel,1);

        local strlv = ""..info.full_star;
        local lvLabel = cc.Label:createWithTTF(strlv, ttf_msyh, 22);
        lvLabel:setPosition(cc.p(694, 28));
        self:addChild(lvLabel,1);

        local strscore = ""..info.star_num;
        local scoreLabel = cc.Label:createWithTTF(strscore, ttf_msyh, 22);
        scoreLabel:setPosition(cc.p(950, 28));
        self:addChild(scoreLabel,1);
    end

    self.lineLabel = cc.Label:createWithTTF("_", ttf_msyh, 22);
    self.lineLabel:setScaleX(self.nameLabel:getContentSize().width/self.lineLabel:getContentSize().width);
    self.lineLabel:setPosition(cc.p(self.nameLabel:getPositionX(), 27));
    self:addChild(self.lineLabel);
end


function rankItem:onBtnClick(sender, eventType)
    -- if eventType == ccui.TouchEventType.began then
    --     self.nameLabel:setColor(Color3B.MAGENTA);
    --     self.lineLabel:setColor(Color3B.MAGENTA);
    -- end
    -- if eventType == ccui.TouchEventType.canceled then
    --     self.nameLabel:setColor(Color3B.WHITE);
    --     self.lineLabel:setColor(Color3B.WHITE);
    -- end
    -- if eventType == ccui.TouchEventType.ended then
    --     self.nameLabel:setColor(Color3B.WHITE);
    --     self.lineLabel:setColor(Color3B.WHITE);
    -- end
    if eventType == ccui.TouchEventType.ended then
        if self.delegate and self.delegate.rankItemSelect then
            self.delegate:rankItemSelect(self);
        end
    end
end

function rankItem:onEnter()

end

function rankItem:onExit()
    MGRCManager:releaseResources("rankItem")
end

function rankItem.create(delegate)
    local layer = rankItem:new()
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
