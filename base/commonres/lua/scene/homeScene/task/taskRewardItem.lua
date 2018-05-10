require "Item"

local taskRewardItem = class("taskRewardItem",function()  
    return ccui.Layout:create(); 
end)

function taskRewardItem:ctor()
    self:init();
end

function taskRewardItem:init()
    self:setSize(cc.size(140, 65));
    self:setAnchorPoint(cc.p(0.5,0.5));

    self.itemHead = resItem.create(self);
    self.itemHead:setAnchorPoint(cc.p(0.5,0.5));
    self.itemHead:setScale(0.5);
    self.itemHead:setPosition(cc.p(self.itemHead:getContentSize().width/4, self:getContentSize().height/2));
    self.itemHead:setData(1,1,1);
    self.itemHead:setNumVisible(false);
    self:addChild(self.itemHead);

    self.numLabel = cc.Label:createWithTTF("x10", ttf_msyh, 22);
    self.numLabel:setAnchorPoint(cc.p(0,0.5));
    self.numLabel:setPosition(cc.p(self.itemHead:getPositionX()+self.itemHead:getContentSize().width/4+10, self:getContentSize().height/2));
    self.numLabel:setColor(cc.c3b(107,75,36));
    self:addChild(self.numLabel);
end

function taskRewardItem:setData(data)
    self.data = data;
    self.itemHead:setData(data.type,data.id,data.num);
    self.itemHead:setNumVisible(false);
    self.numLabel:setString(data.num);
end

function taskRewardItem:onButtonClick(sender, eventType)

end

function taskRewardItem:onEnter()

end

function taskRewardItem:onExit()
    MGRCManager:releaseResources("taskRewardItem");
end

return taskRewardItem;
