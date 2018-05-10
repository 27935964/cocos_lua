--------------------------公会------我的红包详情Item-----------------------

local guildMyWelfareItem = class("guildMyWelfareItem", MGWidget)

function guildMyWelfareItem:init(delegate,widget)
    self.delegate=delegate;
    self:addChild(widget);
    self.pWidget = widget;

    local Panel_2 = self.pWidget:getChildByName("Panel_2");
    self:setContentSize(Panel_2:getContentSize());

    self.Image_icon = Panel_2:getChildByName("Image_icon");
    self.Label_amount = Panel_2:getChildByName("Label_amount");
    self.Label_source = Panel_2:getChildByName("Label_source");
    self.Label_time = Panel_2:getChildByName("Label_dates");

end

function guildMyWelfareItem:setData(data)
    self.data = data;
    self.redData = spliteStr(self.data, ":");--1名称:2时间:3数量:4类型(1金币2银币)
    
    if tonumber(self.redData[4]) == 1 then--钻石红包
        self.Image_icon:loadTexture("main_icon_masonry.png",ccui.TextureResType.plistType);
    elseif tonumber(self.redData[4]) == 2 then--金币红包
        self.Image_icon:loadTexture("main_icon_gold.png",ccui.TextureResType.plistType);
    end
    self.Label_amount:setText(tonumber(self.redData[3]));
    self.Label_source:setText(unicode_to_utf8(self.redData[1]));

    local time = MGDataHelper:secToMonDay(tonumber(self.redData[2]));
    self.Label_time:setText(time);
end

function guildMyWelfareItem:onEnter()
    
end

function guildMyWelfareItem:onExit()
    MGRCManager:releaseResources("guildMyWelfareItem");
end

function guildMyWelfareItem.create(delegate,widget)
    local layer = guildMyWelfareItem:new()
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

return guildMyWelfareItem