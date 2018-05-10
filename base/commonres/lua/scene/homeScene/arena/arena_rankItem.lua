require "utf8"
arena_rankItem = class("arena_rankItem", function()
    return ccui.Layout:create();
end)

function arena_rankItem:ctor()
    self:init();
end

function arena_rankItem:init()
    --背景
    self:setTouchEnabled(true);
    self:addTouchEventListener(handler(self,self.onBtnClick));
    self:setSize(cc.size(939,54));
end

function arena_rankItem:setData(info,index)
    self.info = info;
    info.name = unicode_to_utf8(info.name);
    info.union = unicode_to_utf8(info.union);
    info.ranking = tonumber(info.ranking);

    if math.mod(index,2) == 1 then
        local bgImg = ccui.ImageView:create("com_rank_bg.png", ccui.TextureResType.plistType);
        bgImg:setPosition(cc.p(self:getContentSize().width/2, self:getContentSize().height/2));
        bgImg:setScale9Enabled(true);
        bgImg:setCapInsets(cc.rect(30, 26, 1, 1));
        bgImg:setSize(cc.size(939,54));
        self:addChild(bgImg);
    end

    if info.ranking <4 then
        local pic = string.format("com_rank_cup_%d.png",info.ranking)
        local rankSpr = cc.Sprite:createWithSpriteFrameName(pic);
        rankSpr:setPosition(cc.p(103,23));
        self:addChild(rankSpr,1);
    else
        local strrank = ""..info.ranking;
        local rankLabel = cc.Label:createWithTTF(strrank, ttf_msyh, 22);
        rankLabel:setPosition(cc.p(103, 28));
        self:addChild(rankLabel,1);
        rankLabel:setColor(cc.c3b(188,169,102));
    end


    self.nameLabel = cc.Label:createWithTTF(info.name, ttf_msyh, 22);
    self.nameLabel:setPosition(cc.p(273, 28));
    self:addChild(self.nameLabel,1);

    self.unionLabel = cc.Label:createWithTTF(info.union, ttf_msyh, 22);
    self.unionLabel:setPosition(cc.p(656, 28));
    self:addChild(self.unionLabel,1);

    local strlv = "Lv."..info.lv;
    local lvLabel = cc.Label:createWithTTF(strlv, ttf_msyh, 22);
    lvLabel:setPosition(cc.p(461, 28));
    self:addChild(lvLabel,1);

    local strscore = ""..info.score;
    local scoreLabel = cc.Label:createWithTTF(strscore, ttf_msyh, 22);
    scoreLabel:setPosition(cc.p(835, 28));
    self:addChild(scoreLabel,1);

end


function arena_rankItem:onBtnClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        if self.delegate and self.delegate.rankItemSelect then
            self.delegate:rankItemSelect(self);
        end
    end
end

function arena_rankItem:onEnter()

end

function arena_rankItem:onExit()
    MGRCManager:releaseResources("arena_rankItem")
end

function arena_rankItem.create(delegate)
    local layer = arena_rankItem:new()
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
