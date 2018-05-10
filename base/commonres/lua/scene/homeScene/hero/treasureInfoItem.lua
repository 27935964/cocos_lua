----------------------宝物信息头像-----------------------

treasureInfoItem = class("treasureInfoItem", MGLayer)


function treasureInfoItem:ctor()
    self:init();
end

function treasureInfoItem:init()
    self.size = self:setContentSize(cc.size(251,112));

    --数量
    self.numLabel = MGColorLabel:label()
    self.numLabel:setAnchorPoint(cc.p(0,0.5))
    self.numLabel:setPosition(107, 36)
    self:addChild(self.numLabel)

    self.nameLabel = cc.Label:createWithTTF("", ttf_msyh, 22);
    self.nameLabel:setAnchorPoint(cc.p(0,0.5))
    self.nameLabel:setPosition(cc.p(107,73));
    self:addChild(self.nameLabel);
end

function treasureInfoItem:setData(gm,neednum,havenum)
    if nil == self.item then
        item = HeroHeadEx.create(self);
        item:setData(gm);
        item:setPosition(cc.p(48,50));
        self:addChild(item);
        self.nameLabel:setString(gm:name());
    end
    self.numLabel:clear()
    if neednum<=havenum then
        self.numLabel:appendString(string.format("%d",havenum), Color3B.GREEN, ttf_msyh, 22);
    else
        self.numLabel:appendString(string.format("%d",havenum), Color3B.RED, ttf_msyh, 22);
    end
    self.numLabel:appendString(string.format("/%d",neednum), Color3B.WHITE, ttf_msyh, 22)
end

function treasureInfoItem:onEnter()

end

function treasureInfoItem:onExit()
    MGRCManager:releaseResources("treasureInfoItem")
end

function treasureInfoItem.create()
    local layer = treasureInfoItem:new()
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
