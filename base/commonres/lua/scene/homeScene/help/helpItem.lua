--------------------------帮助item-----------------------

local helpItem = class("helpItem", MGWidget)

function helpItem:init(delegate,widget,info)
    self.delegate=delegate;
    self:addChild(widget);
    self.pWidget = widget;

    local Panel_2 = self.pWidget:getChildByName("Panel_2");
    self:setContentSize(Panel_2:getContentSize());
end

function helpItem:onEnter()
    
end

function helpItem:onExit()
    MGRCManager:releaseResources("helpItem")
end

function helpItem.create(delegate,widget)
    local layer = helpItem:new()
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

return helpItem