--------------------------维护者之誓 战报-----------------------

local vindicatorReportItem = class("vindicatorReportItem", MGWidget)

function vindicatorReportItem:init(delegate,widget)
    self.delegate=delegate;
    self:addChild(widget);
    self.pWidget = widget;

    local Panel_2 = self.pWidget:getChildByName("Panel_2");
    self:setContentSize(Panel_2:getContentSize());

    self.Image_rank = Panel_2:getChildByName("Image_rank");
    self.Label_rank = Panel_2:getChildByName("Label_rank");
    self.Label_name = Panel_2:getChildByName("Label_name");
    self.Label_level = Panel_2:getChildByName("Label_level");
    self.Label_fighting_capacity = Panel_2:getChildByName("Label_fighting_capacity");

    self.Panel_name = Panel_2:getChildByName("Panel_name");
    self.Panel_name:setTouchEnabled(true);
    self.Panel_name:addTouchEventListener(handler(self,self.onButtonClick));

    self.Label_name = self.Panel_name:getChildByName("Label_name");
    self.Label_name:setText("");
    self.lineLabel = cc.Label:createWithTTF("_", ttf_msyh, 22);
    self.lineLabel:setColor(cc.c3b(188,169,102));
    self.lineLabel:setScaleX(self.Label_name:getContentSize().width/self.lineLabel:getContentSize().width);
    self.lineLabel:setPosition(cc.p(self.Label_name:getPositionX(),self.Label_name:getPositionY()-5));
    self.Panel_name:addChild(self.lineLabel);

    self.Button_play = Panel_2:getChildByName("Button_play");
    self.Button_play:addTouchEventListener(handler(self,self.onButtonClick));
end

function vindicatorReportItem:setData(data,index)
    self.data = data;
    self.index = index;

    self.Label_rank:setVisible(false);
    self.Image_rank:setVisible(true);
    self.Label_rank:setText(self.index);
    if self.index == 1 or self.index == 2 or self.index == 3 then
        self.Image_rank:loadTexture(string.format("com_rank_cup_%d.png",self.index),ccui.TextureResType.plistType);
    else
        self.Label_rank:setVisible(true);
        self.Image_rank:setVisible(false);
    end

    self.Label_name:setText("伊丽莎白二世");
    self.lineLabel:setScaleX(self.Label_name:getContentSize().width/self.lineLabel:getContentSize().width);
end

function vindicatorReportItem:onButtonClick(sender, eventType)
    if sender ~= self.Panel_name then
       buttonClickScale(sender, eventType);
    end

    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_play then--继续
        print(">>>>>>>>>>继续>>>>>>>>>>>")
            -- if self.delegate and self.delegate.moveSendReq then
            --     self.delegate:moveSendReq(self);
            -- end
        elseif sender == self.Panel_name then
            if self.delegate and self.delegate.reportItemSelect then
                self.delegate:reportItemSelect(self);
            end
        end
    end
end

function vindicatorReportItem:onEnter()
    
end

function vindicatorReportItem:onExit()
    MGRCManager:releaseResources("vindicatorReportItem")
end

function vindicatorReportItem.create(delegate,widget)
    local layer = vindicatorReportItem:new()
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

return vindicatorReportItem