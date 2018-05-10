--------------------------选区Item-----------------------

local loginDistrictItem = class("loginDistrictItem", MGWidget)

function loginDistrictItem:init(delegate,widget)
    self.delegate=delegate;
    self:addChild(widget);
    self.pWidget = widget;

    local Panel_2 = self.pWidget:getChildByName("Panel_2");
    self:setContentSize(Panel_2:getContentSize());

    self.Image_bg = Panel_2:getChildByName("Image_bg");
    self.Image_bg:setTouchEnabled(true);
    self.Image_bg:addTouchEventListener(handler(self,self.onButtonClick));

    self.Label_zone = Panel_2:getChildByName("Label_zone");
    self.Label_zone_name = Panel_2:getChildByName("Label_zone_name");
    self.Label_name = Panel_2:getChildByName("Label_name");
    self.Label_lv = Panel_2:getChildByName("Label_lv");
    
    local Panel_head = Panel_2:getChildByName("Panel_head");
    require "userHead";
    self.heroHead = userHead.create(self);
    self.heroHead:setPosition(cc.p(Panel_head:getContentSize().width/2,Panel_head:getContentSize().height/2));
    Panel_head:addChild(self.heroHead,2);
end

function loginDistrictItem:setData(data)
    self.data = data;
    
    -- self.Label_zone:setText(MG_TEXT("loginDistrictItem_1"));
    -- self.Label_zone_name:setText(MG_TEXT("loginDistrictItem_1"));
    -- self.Label_name:setText(MG_TEXT("loginDistrictItem_1"));
    -- self.Label_lv:setText(MG_TEXT("loginDistrictItem_1"));
    -- local gm = GENERAL:getGeneralModel(ME:getHeadId());
    -- if gm then
    --     self.heroHead:setData(gm);
    -- end
end

function loginDistrictItem:onButtonClick(sender, eventType)
    -- buttonClickScale(sender, eventType);
    if eventType == ccui.TouchEventType.ended then
        if sender == self.Image_headbox then
            
        end
    end
end

function loginDistrictItem:onEnter()
    
end

function loginDistrictItem:onExit()
    MGRCManager:releaseResources("loginDistrictItem");
end

function loginDistrictItem.create(delegate,widget)
    local layer = loginDistrictItem:new()
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

return loginDistrictItem