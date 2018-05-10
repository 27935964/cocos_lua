--------------------------公会福利————发红包item-----------------------
require "userHead"

local guildHairWelfareItem = class("guildHairWelfareItem", MGWidget)

function guildHairWelfareItem:init(delegate,widget)
    self.delegate=delegate;
    self:addChild(widget);
    self.pWidget = widget;

    widget:setBackGroundColorType(1);
    widget:setBackGroundColor(cc.c3b(255,255,0));

    local Panel_2 = self.pWidget:getChildByName("Panel_2");
    self:setContentSize(Panel_2:getContentSize());

    self.Image_icon = Panel_2:getChildByName("Image_icon");
    self.Label_name = Panel_2:getChildByName("Label_name");
    self.Image_icon1 = Panel_2:getChildByName("Image_icon1");
    self.Label_num1 = Panel_2:getChildByName("Label_num1");
    self.Image_icon2 = Panel_2:getChildByName("Image_icon2");
    self.Label_vip = Panel_2:getChildByName("Label_vip");

    self.Button_reject = Panel_2:getChildByName("Button_reject");--发红包
    self.Button_reject:addTouchEventListener(handler(self,self.onButtonClick));

    self.Panel_3 = Panel_2:getChildByName("Panel_3");
    self.ListView = self.Panel_3:getChildByName("ListView");
    self.ListView:setScrollBarVisible(false);
    -- self.ListView:setItemsMargin(-30);

    local Label_reject = self.Button_reject:getChildByName("Label_reject");
    Label_reject:setText(MG_TEXT_COCOS("guild_hair_welfare_item_1"));
end

function guildHairWelfareItem:setData(data)
    self.data = data;

    if self.data.type == 1 then
        self.Image_icon:loadTexture("guild_welfare_diamond_icon.png",ccui.TextureResType.plistType);
        self.Image_icon2:loadTexture("main_icon_masonry.png",ccui.TextureResType.plistType);
    elseif self.data.type == 2 then
        self.Image_icon:loadTexture("guild_welfare_gold_icon.png",ccui.TextureResType.plistType);
        self.Image_icon2:loadTexture("main_icon_gold.png",ccui.TextureResType.plistType);
    end

    self.Label_name:setText(string.format("%s%d%s",self.data.name,self.data.rand_num,MG_TEXT("Num")));
    if tonumber(self.data.need[1]) == 0 then
        self.Image_icon1:setVisible(false);
        self.Label_num1:setVisible(false);
    else
        local info = itemInfo(tonumber(self.data.need[1]),tonumber(self.data.need[2]));
        if info then
            MGRCManager:cacheResource("guildHairWelfareItem",info.samll_pic);
            self.Image_icon1:loadTexture(info.samll_pic,ccui.TextureResType.plistType);
        end
        self.Label_num1:setText(tonumber(self.data.need[3]));
    end

    if ME:vipLevel() < tonumber(self.data.need_vip) then
        self.Label_vip:setVisible(true);
        self.Label_vip:setText(string.format(MG_TEXT("guildHairWelfare_2"),tonumber(self.data.need_vip)));
        self.Button_reject:setEnabled(false);
    end

    self.ListView:removeAllItems();
    for i=1,#self.data.reward do
        if #self.data.reward == 1 and tonumber(self.data.reward[i].value1) == 0 then
            self.Panel_3:setVisible(false);
        else
            local item = self:createItem(self.data.reward[i]);
            self.ListView:pushBackCustomItem(item);
        end
    end
end

function guildHairWelfareItem:createItem(data)
    local layout = ccui.Layout:create();
    layout:setAnchorPoint(cc.p(0,0.5));
    layout:setSize(cc.size(100, self.ListView:getContentSize().height));

    local pic = "diamond.png";
    local info = itemInfo(tonumber(data.value1),tonumber(data.value2));
    if info then
        if info.isonly == 0 then
            pic = info.item_pic;
        elseif info.isonly == 1 then
            pic = info.samll_pic;
        end
    end

    MGRCManager:cacheResource("guildHairWelfareItem",pic);
    local titleSpr = cc.Sprite:createWithSpriteFrameName(pic);
    titleSpr:setAnchorPoint(cc.p(0,0.5));
    titleSpr:setPosition(cc.p(0, layout:getContentSize().height/2));
    layout:addChild(titleSpr);

    local numLabel = cc.Label:createWithTTF(data.value3,ttf_msyh,22);
    numLabel:setAnchorPoint(cc.p(0, 0.5));
    numLabel:setPosition(cc.p(titleSpr:getPositionX()+titleSpr:getContentSize().width+2,layout:getContentSize().height/2));
    layout:addChild(numLabel);

    local w = titleSpr:getContentSize().width+numLabel:getContentSize().width+20;
    if info.isonly == 0 then
        titleSpr:setScale(0.5);
        numLabel:setPosition(cc.p(titleSpr:getPositionX()+titleSpr:getContentSize().width/2+2,layout:getContentSize().height/2));
        w = titleSpr:getContentSize().width*0.5+numLabel:getContentSize().width+20;
    end
    layout:setSize(cc.size(w, self.ListView:getContentSize().height));

    titleSpr:setPositionX(0);
    numLabel:setPositionX(titleSpr:getPositionX()+titleSpr:getContentSize().width+2);
    if info.isonly == 0 then
        titleSpr:setScale(0.5);
        numLabel:setPositionX(titleSpr:getPositionX()+titleSpr:getContentSize().width/2+2);
    end

    return layout;
end

function guildHairWelfareItem:onButtonClick(sender, eventType)
    buttonClickScale(sender, eventType);
    if eventType == ccui.TouchEventType.ended then
        if ME:vipLevel() >= tonumber(self.data.need_vip) then
            if self.delegate and self.delegate.sendReq then
                self.delegate:sendReq(tonumber(self.data.id));
            end
        end
    end
end

function guildHairWelfareItem:onEnter()
    
end

function guildHairWelfareItem:onExit()
    if self.timer~=nil then
        self.timer:stopTimer();
    end
    MGRCManager:releaseResources("guildHairWelfareItem")
end

function guildHairWelfareItem.create(delegate,widget)
    local layer = guildHairWelfareItem:new()
    layer:init(delegate,widget)
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

return guildHairWelfareItem