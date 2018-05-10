arena_awardItem = class("arena_awardItem", function()
    return ccui.Layout:create();
end)

function arena_awardItem:ctor()
    self:init();
end

function arena_awardItem:init()
    --背景
    self:setSize(cc.size(532,78));

    local boxSpr = ccui.ImageView:create("common_three_box.png", ccui.TextureResType.plistType);
    boxSpr:setPosition(cc.p(self:getContentSize().width/2, self:getContentSize().height/2));
    boxSpr:setScale9Enabled(true);
    boxSpr:setCapInsets(cc.rect(19, 17, 1, 1));
    boxSpr:setSize(cc.size(532, 78));
    self:addChild(boxSpr);
end

function arena_awardItem:setData(info)
    self.info = info;
    if info.min_rank <4 then
        local pic = string.format("com_rank_cup_%d.png",info.min_rank)
        local rankSpr = cc.Sprite:createWithSpriteFrameName(pic);
        rankSpr:setPosition(cc.p(83,40));
        self:addChild(rankSpr,1);
    else
        
        local strrank = ""..info.min_rank;
        if info.min_rank >10 then
            strrank = ""..info.min_rank.."～"..info.max_rank;
        end

        local rankLabel = cc.Label:createWithTTF(strrank, ttf_msyh, 22);
        rankLabel:setPosition(cc.p(83,40));
        self:addChild(rankLabel,1);
        rankLabel:setColor(cc.c3b(188,169,102));
    end

    local aLabel = cc.Label:createWithTTF(MG_TEXT_COCOS("arena_ui_21"), ttf_msyh, 22);
    aLabel:setPosition(cc.p(206,40));
    self:addChild(aLabel,1);
    aLabel:setColor(cc.c3b(188,169,102));

    local  reward = getneedlist(info.reward);

    local rankmoneySpr = cc.Sprite:createWithSpriteFrameName("com_rank_money.png");
    rankmoneySpr:setPosition(cc.p(288,40));
    self:addChild(rankmoneySpr,1);

    local rankmoneyLabel = cc.Label:createWithTTF(""..reward[1].num, ttf_msyh, 22);
    rankmoneyLabel:setPosition(cc.p(318,40));
    rankmoneyLabel:setAnchorPoint(cc.p(0,0.5))
    self:addChild(rankmoneyLabel,1);
    
    local rankmoneySpr = cc.Sprite:createWithSpriteFrameName("main_icon_masonry.png");
    rankmoneySpr:setPosition(cc.p(415,40));
    self:addChild(rankmoneySpr,1);

    local rankmoneyLabel = cc.Label:createWithTTF(""..reward[2].num, ttf_msyh, 22);
    rankmoneyLabel:setPosition(cc.p(444,40));
    rankmoneyLabel:setAnchorPoint(cc.p(0,0.5))
    self:addChild(rankmoneyLabel,1);
end


function arena_awardItem:onEnter()

end

function arena_awardItem:onExit()
    MGRCManager:releaseResources("arena_awardItem")
end

function arena_awardItem.create(delegate)
    local layer = arena_awardItem:new()
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
