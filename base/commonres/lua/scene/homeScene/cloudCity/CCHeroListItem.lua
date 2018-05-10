-- 武将列表
-- local CCHeroItem=require "CCHeroItem";
local CCHeroListItem=class("CCHeroListItem",function()
    return cc.Layer:create();
end);

function CCHeroListItem:ctor()
end

function CCHeroListItem:initData(delegate, datas, type)
    self:removeAllChildren();
    local CCHeroItem=require "CCHeroItem";
    for i=1,5 do
        local heroItem=CCHeroItem.new(type);
        heroItem:setPosition(cc.p((i-1)*(118),0));
        self:addChild(heroItem);
        heroItem:initData(delegate, datas[i]);
    end
end

return CCHeroListItem;