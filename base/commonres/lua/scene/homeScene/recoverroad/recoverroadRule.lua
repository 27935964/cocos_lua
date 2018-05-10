-----------------------光复之路中的规则界面------------------------

recoverroadRule = class("recoverroadRule", MGLayer)

function recoverroadRule:ctor()

end

function recoverroadRule:init(delegate)
    self.delegate = delegate
    MGRCManager:cacheResource("recoverroadRule", "rule_ui0.png", "rule_ui0.plist");
    local pWidget = MGRCManager:widgetFromJsonFile("recoverroadRule","rule_ui.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);--设置描边或者阴影
    
    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));
    local Panel_2 = pWidget:getChildByName("Panel_2");
    local Image_rule = Panel_2:getChildByName("Image_rule");
    self.Button_close = Panel_2:getChildByName("Button_close");
    self.Button_close:addTouchEventListener(handler(self,self.onButtonClick));

    self.ListView = Panel_2:getChildByName("ListView");
    self.ListView:setItemsMargin(-15);
    self.ListView:setScrollBarVisible(false);
end

function recoverroadRule:setData(data)
    self.data = data;
    
    self.ListView:removeAllItems();
    for i=1,3 do
        local item = self:createItem(i);
        self.ListView:pushBackCustomItem(item);
    end
end

function recoverroadRule:createItem(i)
    local layout = ccui.Layout:create();
    layout:setSize(cc.size(self.ListView:getContentSize().width, 200));

    local posY = 0;
    local height = 0;
    local str = "";
    --标题
    local titleSpr = cc.Sprite:create();
    posY = layout:getContentSize().height-titleSpr:getContentSize().height/2-10;
    titleSpr:setPosition(cc.p(layout:getContentSize().width/2, posY));
    layout:addChild(titleSpr);

    local descLabel = MGColorLabel:label();
    descLabel:setAnchorPoint(cc.p(0, 1));
    posY = posY-titleSpr:getContentSize().height/2-20;
    descLabel:setPosition(cc.p(20, posY));
    layout:addChild(descLabel);

    descLabel:clear();
    if i == 1 then
        str = string.format(MG_TEXT("recoverroadLayer_1"),40);
        titleSpr:setSpriteFrame("rule_condition.png");
    elseif i == 2 then
        str = "远征重置次数不足";
        titleSpr:setSpriteFrame("rule_target.png");
    elseif i == 3 then
        str = "远征重置次数不足远征重置次数不足远征重置次数不足远征重置次数不足";
        titleSpr:setSpriteFrame("rule_rule.png");
    end
    descLabel:appendStringAutoWrap(str,21,1,cc.c3b(255,255,255),22);

    height = titleSpr:getContentSize().height+descLabel:getContentSize().height+50;
    layout:setSize(cc.size(self.ListView:getContentSize().width, height));
    posY = layout:getContentSize().height-titleSpr:getContentSize().height/2-10;
    titleSpr:setPositionY(posY);
    posY = posY-titleSpr:getContentSize().height/2-20;
    descLabel:setPositionY(posY);

    return layout;
end

function recoverroadRule:onButtonClick(sender, eventType)
    buttonClickScale(sender, eventType);
    if eventType == ccui.TouchEventType.ended then
        if sender == self.Panel_1 or sender == self.Button_close then
            self:removeFromParent();
        end
    end
end


function recoverroadRule:onEnter()

end

function recoverroadRule:onExit()
    MGRCManager:releaseResources("recoverroadRule");
end

function recoverroadRule.create(delegate)
    local layer = recoverroadRule:new()
    layer: init(delegate);
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

function recoverroadRule.showBox(delegate)
    local layer = recoverroadRule.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
