require "HeroHead"

MLLegionItem = class("MLLegionItem",function()  
    return ccui.Layout:create(); 
end)

function MLLegionItem:ctor()

end

function MLLegionItem:init()
    self:setSize(cc.size(92, 109));
    self:setAnchorPoint(cc.p(0.5,0.5));

    self.heroHead = HeroHead.create(self);
    self.heroHead:setPosition(cc.p(self:getSize().width/2,self:getSize().height/2));
    self:addChild(self.heroHead);
end

function MLLegionItem:setData(gmList)
    self.gm = gmList.gm;
    self.isLive = gmList.isLive;
    if self.gm then
        self.heroHead:setData(self.gm);
        if self.isLive == false then
            self:setIsGray(true);
        end
    end

    self.heroHead.progressHP:setPercentage(100);
    self.heroHead.lvLabel:setVisible(false);
    self.heroHead.progressHP:setVisible(true);
    self.heroHead.progressAnger:setVisible(false);
    self.heroHead.progressHP:setPosition(self.heroHead.progressAnger:getPosition());
    for i=1,#self.heroHead.starSprs do
        self.heroHead.starSprs[i]:setPositionY(self.heroHead.starSprs[i]:getPositionY()-10);
    end
end

function MLLegionItem:setIsGray(isGray)
    self.heroHead:setIsGray(isGray);
end

function MLLegionItem:onEnter()

end

function MLLegionItem:onExit()
    MGRCManager:releaseResources("MLLegionItem");
end

function MLLegionItem.create()
    local layer = MLLegionItem:new()
    layer:init()
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
