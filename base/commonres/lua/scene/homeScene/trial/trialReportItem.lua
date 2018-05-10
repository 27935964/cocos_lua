--------------------------试炼战报-----------------------

local trialReportItem = class("trialReportItem", MGWidget)

function trialReportItem:init(delegate,widget)
    self.delegate=delegate;
    self:addChild(widget);
    self.pWidget = widget;

    local Panel_2 = self.pWidget:getChildByName("Panel_2");
    self:setContentSize(Panel_2:getContentSize());

    self.Image_frame2 = Panel_2:getChildByName("Image_frame2");
    self.Image_frame2:setTouchEnabled(true);
    self.Image_frame2:addTouchEventListener(handler(self,self.onButtonClick));

    self.BitmapLabel_rank = Panel_2:getChildByName("BitmapLabel_rank");
    self.Label_name = Panel_2:getChildByName("Label_name");
    self.Label_number = Panel_2:getChildByName("Label_number");
    
    self.Panel_3 = Panel_2:getChildByName("Panel_3");
    self.Panel_3:setTouchEnabled(true);
    self.Panel_3:addTouchEventListener(handler(self,self.onButtonClick));

    local Label_lineup = self.Panel_3:getChildByName("Label_lineup");
    Label_lineup:setText(MG_TEXT_COCOS("trial_report_item_ui_1"));

    self.lineLabel = cc.Label:createWithTTF("_", ttf_msyh, 22);
    self.lineLabel:setColor(cc.c3b(188,169,102));
    self.lineLabel:setScaleX(Label_lineup:getContentSize().width/self.lineLabel:getContentSize().width);
    self.lineLabel:setPosition(cc.p(Label_lineup:getPositionX(),Label_lineup:getPositionY()-5));
    self.Panel_3:addChild(self.lineLabel);
end

function trialReportItem:setData(data,index)
    self.data = data;

    self.BitmapLabel_rank:setText(index);
    self.Label_name:setText(unicode_to_utf8(self.data.name));
    self.Label_number:setText(self.data.score);
end

function trialReportItem:onButtonClick(sender, eventType)
    -- buttonClickScale(sender, eventType);

    if eventType == ccui.TouchEventType.ended then
        if sender == self.Image_frame2 then
            if self.delegate and self.delegate.callBack then
                self.delegate:callBack();
            end
        end
    end
end

function trialReportItem:onEnter()
    
end

function trialReportItem:onExit()
    MGRCManager:releaseResources("trialReportItem")
end

function trialReportItem.create(delegate,widget)
    local layer = trialReportItem:new()
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

return trialReportItem