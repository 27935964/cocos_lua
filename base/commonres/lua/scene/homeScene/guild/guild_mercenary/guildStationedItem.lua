--------------------------公会驻扎英雄Item-----------------------

local guildStationedItem = class("guildStationedItem", function()
    return ccui.Layout:create();
end)

function guildStationedItem:init(delegate)
    self.delegate = delegate;
    
    self:setSize(cc.size(150, 170));
    self:setAnchorPoint(cc.p(0.5,0.5));
    
    self.itemHero = HeroHeadEx.create(self);
    self.itemHero:setPosition(cc.p(self:getContentSize().width/2,
        self:getContentSize().height-self.itemHero:getContentSize().height/2-10));
    self:addChild(self.itemHero);

    self.nameLabel = cc.Label:createWithTTF("",ttf_msyh,22);
    self.nameLabel:setPosition(cc.p(self:getContentSize().width/2,50));
    self:addChild(self.nameLabel);

    self.powerLabel = MGColorLabel:label();
    self.powerLabel:setPosition(cc.p(self:getContentSize().width/2,20));
    self:addChild(self.powerLabel);
end

function guildStationedItem:setData(gm)
    self.gm = gm;
    self.itemHero:setData(self.gm);

    self.nameLabel:setString(gm:name());
    self.powerLabel:clear();
    self.powerLabel:appendStringAutoWrap(string.format(MG_TEXT("guildStationedItem_1"),gm:getPower()),32,1,cc.c3b(255,255,255),22);
end

function guildStationedItem:getItem()
    return self.itemHero;
end

function guildStationedItem:HeroHeadSelect(item)
    if self.delegate and self.delegate.HeroHeadSelect then
        self.delegate:HeroHeadSelect(item);
    end
end

function guildStationedItem:onButtonClick(sender, eventType)
    if sender ~= self.Image_headbox then
        buttonClickScale(sender, eventType);
    end

    if eventType == ccui.TouchEventType.ended then
        if sender == self.Image_headbox then
            if ME:Lv() >= self.mercenaryData.value2 then--已开放
                if self.isStationed == true then--已驻扎

                else

                end
            else
                MGMessageTip:showFailedMessage(MG_TEXT("heroAttLayer_9"));
            end
        elseif sender == self.Button_delete then

        end
    end
end

function guildStationedItem:onEnter()
    
end

function guildStationedItem:onExit()
    MGRCManager:releaseResources("guildStationedItem");
    if self.timer~=nil then
        self.timer:stopTimer();
    end
end

function guildStationedItem.create(delegate)
    local layer = guildStationedItem:new()
    layer:init(delegate)
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

return guildStationedItem