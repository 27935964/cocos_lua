--------------------------公会红包详情Item-----------------------

local guildWelfareDetailsItem = class("guildWelfareDetailsItem", MGWidget)

function guildWelfareDetailsItem:init(delegate,widget)
    self.delegate=delegate;
    self:addChild(widget);
    self.pWidget = widget;

    local Panel_2 = self.pWidget:getChildByName("Panel_2");
    self:setContentSize(Panel_2:getContentSize());

    self.Image_luck = Panel_2:getChildByName("Image_luck");
    self.Image_luck:setVisible(false);

    self.Label_num = Panel_2:getChildByName("Label_num");
    self.Image_gold = Panel_2:getChildByName("Image_gold");
    self.Label_name = Panel_2:getChildByName("Label_name");
    self.Label_time = Panel_2:getChildByName("Label_time");

end

function guildWelfareDetailsItem:setData(data)
    self.data = data;

    if tonumber(self.data.type) == 1 then--钻石红包
        self.Image_gold:loadTexture("main_icon_masonry.png",ccui.TextureResType.plistType);
    elseif tonumber(self.data.type) == 2 then--金币红包
        self.Image_gold:loadTexture("main_icon_gold.png",ccui.TextureResType.plistType);
    end
    self.Label_num:setText(tonumber(self.data.get_num));
    self.Label_name:setText(unicode_to_utf8(self.data.name));

    if self.data.isOver == true then--红包已经抢完
        if self.data.maxNum == tonumber(self.data.get_num) and self.data.timeNum == tonumber(self.data.get_time) then
            self.Image_luck:setVisible(true);
        end
    end

    local time = MGDataHelper:secToTimeStringNoYear2(tonumber(self.data.get_time));
    self.Label_time:setText(time);
end

function guildWelfareDetailsItem:onEnter()
    
end

function guildWelfareDetailsItem:onExit()
    MGRCManager:releaseResources("guildWelfareDetailsItem");
end

function guildWelfareDetailsItem.create(delegate,widget)
    local layer = guildWelfareDetailsItem:new()
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

return guildWelfareDetailsItem