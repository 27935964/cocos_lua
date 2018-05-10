--------------------------公会红包Item-----------------------

local guildWelfareItem = class("guildWelfareItem", MGWidget)

function guildWelfareItem:init(delegate,widget)
    self.delegate=delegate;
    self:addChild(widget);
    self.pWidget = widget;

    self.timer = CCTimer:new();
    self.timeNum = nil;

    local Panel_2 = self.pWidget:getChildByName("Panel_2");
    self:setContentSize(Panel_2:getContentSize());
    self.Panel_2 = Panel_2;
    self.Panel_2:addTouchEventListener(handler(self,self.onButtonClick));

    self.Image_bg = Panel_2:getChildByName("Image_bg");
    self.Image_gold = Panel_2:getChildByName("Image_gold");
    self.Label_num = Panel_2:getChildByName("Label_num");
    self.Image_title = Panel_2:getChildByName("Image_title");
    self.Label_time_num = Panel_2:getChildByName("Label_time_num");
    self.Label_num1 = Panel_2:getChildByName("Label_num1");
    self.Label_name = Panel_2:getChildByName("Label_name");
    self.Image_mark = Panel_2:getChildByName("Image_mark");

    local Label_time = self.Panel_2:getChildByName("Label_time");
    Label_time:setText(MG_TEXT_COCOS("guild_welfare_item_ui_1"));

end

function guildWelfareItem:setData(data,mercenary,index)
    self.data = data;

    if tonumber(self.data.type) == 1 then--钻石红包
        self.Image_gold:loadTexture("main_icon_masonry.png",ccui.TextureResType.plistType);
        self.Image_title:loadTexture("guild_welfare_diamond.png",ccui.TextureResType.plistType);
    elseif tonumber(self.data.type) == 2 then--金币红包
        self.Image_gold:loadTexture("main_icon_gold.png",ccui.TextureResType.plistType);
        self.Image_title:loadTexture("guild_welfare_gold.png",ccui.TextureResType.plistType);
    end
    self.Label_num:setText(tonumber(self.data.money));
    self.Label_name:setText(unicode_to_utf8(self.data.name));
    self.Label_num1:setText(string.format("%d/%d",tonumber(self.data.get_num),tonumber(self.data.num)));

    if tonumber(self.data.is_get) == 1 then--是否领取 1领取 0没有
        self.Image_mark:setVisible(true);
        self.Image_mark:loadTexture("guild_welfare_receive.png",ccui.TextureResType.plistType);
        if tonumber(self.data.get_num) == tonumber(self.data.num) then--已抢光
            self.Image_mark:loadTexture("guild_welfare_gone.png",ccui.TextureResType.plistType);
        end
    else
        self.Image_mark:setVisible(false);
    end

    local systemTime = UserData:instance():getServerTime();
    self.timeNum = tonumber(self.data.end_time)-systemTime;
    if self.timeNum <= 0 then
        self.timeNum = 0;
    end
    local time = MGDataHelper:secToString(self.timeNum);
    self.Label_time_num:setText(time);
    self.timer:startTimer(1000,handler(self,self.updateTime),false);--每秒回调一次
end

function guildWelfareItem:updateTime()
    if self.timeNum ~= nil and self.timeNum > 0 then
        self.timeNum = self.timeNum-1;
        local time =MGDataHelper:secToString(self.timeNum);
        self.Label_time_num:setText(time);
    else
        if self.timer~=nil then
            self.timer:stopTimer();
        end
    end
end

function guildWelfareItem:onButtonClick(sender, eventType)
    if eventType == ccui.TouchEventType.began then
        if self.btnSpr==nil then
            self.btnSpr = cc.Sprite:create();
            self.btnSpr:setSpriteFrame("guild_welfare_item_bg.png");
            self.btnSpr:setPosition(self.Image_bg:getPosition());
            self.Panel_2:addChild(self.btnSpr);
            self.btnSpr:setShaderProgram(MGGraySprite:getLightShaderProgram(3));
        end
    end
    if eventType == ccui.TouchEventType.canceled then
        if self.btnSpr then
            self.btnSpr:removeFromParent();
            self.btnSpr = nil;
        end
    end
    if eventType == ccui.TouchEventType.ended then
        if self.btnSpr then
            self.btnSpr:removeFromParent();
            self.btnSpr = nil;
        end

        if self.delegate and self.delegate.ItemSelect then
            self.delegate:ItemSelect(self);
        end
    end
end

function guildWelfareItem:onEnter()
    
end

function guildWelfareItem:onExit()
    MGRCManager:releaseResources("guildWelfareItem");
    if self.timer~=nil then
        self.timer:stopTimer();
    end
end

function guildWelfareItem.create(delegate,widget)
    local layer = guildWelfareItem:new()
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

return guildWelfareItem