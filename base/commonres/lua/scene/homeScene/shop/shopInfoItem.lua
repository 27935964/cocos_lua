require "HeroHeadEx"

shopInfoItem = class("shopInfoItem",function()  
    return ccui.Layout:create(); 
end)

function shopInfoItem:ctor()

end

function shopInfoItem:init()
    self:setSize(cc.size(250, 110));
    self:setAnchorPoint(cc.p(0.5,0.5));
    -- self:setBackGroundColorType(1);
    -- self:setBackGroundColor(cc.c3b(0,255,250));

    self.heroHead = HeroHeadEx.create(self);
    self.heroHead:setPosition(cc.p(self.heroHead:getContentSize().width/2,self:getSize().height/2));
    self:addChild(self.heroHead);

    self.nameLabel = cc.Label:createWithTTF("设置描边或者阴",ttf_msyh,22);
    self.nameLabel:setAlignment(cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_TOP);
    self.nameLabel:setDimensions(360, 0);
    self.nameLabel:setAnchorPoint(cc.p(0, 0.5));
    self.nameLabel:setPosition(cc.p(self.heroHead:getContentSize().width+5,self:getSize().height/2+20));
    self:addChild(self.nameLabel);

    self.numLabel = MGColorLabel:label();
    self.numLabel:setAnchorPoint(cc.p(0, 0.5));
    self.numLabel:setPosition(cc.p(self.nameLabel:getPositionX(),self:getSize().height/2-20));
    self:addChild(self.numLabel);
end

function shopInfoItem:setData(gm)
    self.gm = gm;

    self.heroHead:setData(gm);
    self.nameLabel:setString(gm:name());


    local resNum,totNum = getGeneralNeedDebrisNum(gm,true);
    local str = "";
    if resNum >= totNum then
        str = string.format("%d/%d",resNum,totNum);
    else
        str = string.format("<c=255,000,000>%d</c>/%d",resNum,totNum);
    end
    self.numLabel:clear();
    self.numLabel:appendStringAutoWrap(str,16,1,cc.c3b(255,255,255),22);
end

function shopInfoItem:onEnter()

end

function shopInfoItem:onExit()
    MGRCManager:releaseResources("shopInfoItem");
end

function shopInfoItem.create()
    local layer = shopInfoItem:new()
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
