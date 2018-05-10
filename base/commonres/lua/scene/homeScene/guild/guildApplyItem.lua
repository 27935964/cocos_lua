--------------------------公会申请-----------------------

local guildApplyItem = class("guildApplyItem", MGWidget)

function guildApplyItem:init(delegate,widget)
    self.delegate=delegate;
    self:addChild(widget);
    self.pWidget = widget;

    local Panel_2 = self.pWidget:getChildByName("Panel_2");
    self:setContentSize(Panel_2:getContentSize());

    self.Image_cup = Panel_2:getChildByName("Image_cup");
    self.BitmapLabel = Panel_2:getChildByName("BitmapLabel");

    self.Label_name = Panel_2:getChildByName("Label_name");
    self.Label_power = Panel_2:getChildByName("Label_power");

    self.Label_num = Panel_2:getChildByName("Label_num");
    self.Label_limit = Panel_2:getChildByName("Label_limit");

    self.Label_tip = Panel_2:getChildByName("Label_tip");
    self.Image_apply = Panel_2:getChildByName("Image_apply");

    self.Button_apply = Panel_2:getChildByName("Button_apply");--申请
    self.Button_apply:addTouchEventListener(handler(self,self.onButtonClick));

    self.Label_apply = self.Button_apply:getChildByName("Label_apply");
    self.Label_apply:setText(MG_TEXT_COCOS("guild_item_ui_1"));
end

function guildApplyItem:setData(data,index)
    self.data = data;
    self.index = index;

    self.BitmapLabel:setVisible(false);
    self.Image_cup:setVisible(true);
    self.BitmapLabel:setText(self.index);
    if self.index == 1 or self.index == 2 or self.index == 3 then
        self.Image_cup:loadTexture(string.format("com_rank_cup_%d.png",self.index),ccui.TextureResType.plistType);
    else
        self.BitmapLabel:setVisible(true);
        self.Image_cup:setVisible(false);
    end
    self.Label_name:setText(unicode_to_utf8(self.data.name));
    self.Label_power:setText(self.data.score);
    self.Label_num:setText(self.data.num);
    if tonumber(self.data.join_limit) == 1 then--1所有人可加入(等级限制) 2任何人都不可加入 3需要同意才可加入
        self.Label_limit:setText(string.format(MG_TEXT("guildLayer_5"),tonumber(self.data.need_lv)));
    elseif tonumber(self.data.join_limit) == 2 then
        self.Label_limit:setText(MG_TEXT("guildLayer_6"));
    elseif tonumber(self.data.join_limit) == 3 then
        self.Label_limit:setText(MG_TEXT("guildLayer_7"));
    end
    
    self:setState(self.data.state);
end

function guildApplyItem:setState(state)
    self.Button_apply:setEnabled(false);
    self.Label_tip:setVisible(false);
    self.Image_apply:setVisible(false);
    if state == 0 then--state：0表示未申请，1表示已申请，2已满员，3任何人都无法加入
        self.Button_apply:setEnabled(true);
    elseif state == 1 then
        self.Image_apply:setVisible(true);
        self.Image_apply:loadTexture("guild_applied.png",ccui.TextureResType.plistType);
    elseif state == 2 then
        self.Image_apply:setVisible(true);
        self.Image_apply:loadTexture("guild_was_full.png",ccui.TextureResType.plistType);
    elseif state == 3 then
        self.Label_tip:setVisible(true);
    end
end

function guildApplyItem:onButtonClick(sender, eventType)
    buttonClickScale(sender, eventType, 0.8);

    if eventType == ccui.TouchEventType.ended then
        if self.delegate and self.delegate.apply then
            self.delegate:apply(self);
        end
    end
end

function guildApplyItem:onEnter()
    
end

function guildApplyItem:onExit()
    MGRCManager:releaseResources("guildApplyItem")
end

function guildApplyItem.create(delegate,widget)
    local layer = guildApplyItem:new()
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

return guildApplyItem