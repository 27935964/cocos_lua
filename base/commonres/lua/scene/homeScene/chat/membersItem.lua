--------------------------公会成员界面Item-----------------------

local membersItem = class("membersItem", MGWidget)

function membersItem:init(delegate,widget)
    self.delegate=delegate;
    self:addChild(widget);
    self.pWidget = widget;

    self.Panel_2 = self.pWidget:getChildByName("Panel_2");
    self:setContentSize(self.Panel_2:getContentSize());
    self.Panel_2:addTouchEventListener(handler(self,self.onButtonClick));

    self.Panel_head = self.Panel_2:getChildByName("Panel_head");
    self.heroHead = userHead.create(self);
    self.heroHead:setAnchorPoint(cc.p(0.5, 0.5));
    self.heroHead:setPosition(cc.p(self.Panel_head:getContentSize().width/2,self.Panel_head:getContentSize().height/2));
    self.Panel_head:addChild(self.heroHead);

    self.Label_name = self.Panel_2:getChildByName("Label_name");
    self.Label_lv = self.Panel_2:getChildByName("Label_lv");
    self.Label_title = self.Panel_2:getChildByName("Label_title");
end

function membersItem:setData(data)
    self.data = data;

    local gm = GENERAL:getGeneralModel(tonumber(self.data.head));
    if gm then
        self.heroHead:setData(gm);
    end
    self.Label_name:setText(unicode_to_utf8(self.data.name));
    self.Label_lv:setText(ME:Lv());
    
    if tonumber(self.data.post) == 10 then--会长
        self.Label_title:setText(MG_TEXT("Union_10"));
    elseif tonumber(self.data.post) == 9 then--副会长
        self.Label_title:setText(MG_TEXT("Union_9"));
    elseif tonumber(self.data.post) == 8 then--精英
        self.Label_title:setText(MG_TEXT("Union_8"));
    else
        self.Label_title:setText(MG_TEXT("Union_0"));
    end
end

function membersItem:onButtonClick(sender, eventType)
    -- buttonClickScale(sender, eventType);
    if eventType == ccui.TouchEventType.ended then
        if self.delegate and self.delegate.select then
            self.delegate:select(self)
        end
    end
end

function membersItem:onEnter()
    
end

function membersItem:onExit()
    MGRCManager:releaseResources("membersItem");
end

function membersItem.create(delegate,widget)
    local layer = membersItem:new()
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

return membersItem