heroFeaturesInfo = class("heroFeaturesInfo", MGWidget)


function heroFeaturesInfo:init(delegate,widget)
	self.delegate=delegate;

    self:addChild(widget);
    self.pWidget = widget;
    local Panel_1 = self.pWidget:getChildByName("Panel_1");
    self:setContentSize(Panel_1:getContentSize())

    self.hintLabel = MGColorLabel:label()
    self.hintLabel:setPosition(self:getContentSize().width/2, self:getContentSize().height/2)
    self.hintLabel:setAnchorPoint(cc.p(0.5,0.5))
    self:addChild(self.hintLabel,1)
end

function heroFeaturesInfo:setData(data,index)
    self.index=index;
    self.data = data;
    self.hintLabel:clear();
    self.hintLabel:appendStringAutoWrap(self.data.f_info, 16, 1, cc.c3b(255,255,255), 22);
end

function heroFeaturesInfo:upData()
    self.hintLabel:clear();
    self.hintLabel:appendStringAutoWrap(self.data.f_info, 16, 1, cc.c3b(255,255,255), 22);
end

function heroFeaturesInfo:onEnter()
    
end

function heroFeaturesInfo:onExit()
    MGRCManager:releaseResources("heroFeaturesInfo")
end

function heroFeaturesInfo.create(delegate,widget)
    local layer = heroFeaturesInfo:new()
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