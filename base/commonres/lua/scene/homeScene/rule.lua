-----------------------将领属性界面------------------------

rule = class("rule", MGLayer)

function rule:ctor()

end

function rule:init(delegate,type)
    self.delegate = delegate
    self.type = type
    local pWidget = MGRCManager:widgetFromJsonFile("rule","rule_ui.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);--设置描边或者阴影
    
    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));
    local Panel_2 = pWidget:getChildByName("Panel_2");
    local Image_rule = Panel_2:getChildByName("Image_rule");
    self.Button_close = Panel_2:getChildByName("Button_close");
    self.Button_close:addTouchEventListener(handler(self,self.onButtonClick));

    -- local Panel_mid = Panel_2:getChildByName("Panel_mid");
    -- self.Panel_mid = Panel_mid;
    -- self.Label_name = Panel_mid:getChildByName("Label_name");
    -- local Label_lv_name = Panel_mid:getChildByName("Label_lv_name");
    -- Label_lv_name:setText(MG_TEXT_COCOS("arena_ui_16"));
    -- local Label_score_name = Panel_mid:getChildByName("Label_score_name");
    -- Label_score_name:setText(MG_TEXT_COCOS("arena_ui_1"));
    -- local Label_union_name = Panel_mid:getChildByName("Label_union_name");
    -- Label_union_name:setText(MG_TEXT_COCOS("arena_ui_17"));

    -- self.Label_lv = Panel_mid:getChildByName("Label_lv");
    -- self.Label_score = Panel_mid:getChildByName("Label_score");
    -- self.Label_union = Panel_mid:getChildByName("Label_union");

    -- self.list = Panel_mid:getChildByName("ListView");

    -- local Image_head = Panel_mid:getChildByName("Image_head");
    -- Image_head:setVisible(false);
    -- self.heroHead = userHead.create(self);
    -- self.heroHead:setAnchorPoint(Image_head:getAnchorPoint());
    -- self.heroHead:setPosition(Image_head:getPosition());
    -- Panel_mid:addChild(self.heroHead,2);



end


function rule:setData(data)
    self.data = data;
    self.Label_name:setText(data.name);
    self.Label_lv:setText(data.lv);
    self.Label_union:setText(data.union);
    self.Label_score:setText(data.score);
    local gm = GENERAL:getAllGeneralModel(data.head);
    if gm then
        self.heroHead:setData(gm)
    end
    if data.is_worship ==0 then
        self.Label_ok:setText(MG_TEXT_COCOS("arena_ui_3"));
    else
        
        self.Label_ok:setText(MG_TEXT_COCOS("arena_ui_4"));
    end
end

function rule:onButtonClick(sender, eventType)
    buttonClickScale(sender, eventType);
    if eventType == ccui.TouchEventType.ended then
        if sender == self.Panel_1 then
            self:removeFromParent();
        elseif sender == self.Button_close then
            self:removeFromParent();
        elseif sender == self.Button_ok then
            if self.data.is_affix == 1 then
                if self.delegate and self.delegate.sendgetAffix then
                    self.delegate:sendgetAffix();
                end
            end
            self:removeFromParent();
        end
    end
end


function rule:onEnter()

end

function rule:onExit()
    MGRCManager:releaseResources("rule");
end

function rule.create(delegate,type)
    local layer = rule:new()
    layer: init(delegate,type);
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
