campaignItem = class("campaignItem", MGWidget)


function campaignItem:init(delegate)
	self.delegate=delegate;

    self.pWidget = MGRCManager:widgetFromJsonFile("campaignLayer", "campaign_ui_2.ExportJson");
    MGRCManager:changeWidgetTextFont(self.pWidget,true);--设置描边或者阴影
    self:addChild(self.pWidget);

    self.Panel_2 = self.pWidget:getChildByName("Panel_2");
    self.Panel_2:addTouchEventListener(handler(self,self.onButtonClick));
    self:setContentSize(self.Panel_2:getContentSize())

    self.Label_title = self.Panel_2:getChildByName("Label_title");
    self.Label_times_name = self.Panel_2:getChildByName("Label_times_name");
    self.Label_times = self.Panel_2:getChildByName("Label_times");
    self.Label_desc = self.Panel_2:getChildByName("Label_desc");
    self.Image_kind= self.Panel_2:getChildByName("Image_kind");
    self.Image_lock= self.Panel_2:getChildByName("Image_lock");
    self.Image_lock= self.Panel_2:getChildByName("Image_lock");
    self.list= self.Panel_2:getChildByName("ListView");
end


function campaignItem:onButtonClick(sender, eventType)
    if eventType == ccui.TouchEventType.began then
        if self.headSpr==nil then
            self.headSpr = cc.Sprite:createWithSpriteFrameName(self.data.pic..".png")
            self.headSpr:setPosition(self.Image_kind:getPosition());
            self.Panel_2:addChild(self.headSpr,3);
            self.headSpr:setShaderProgram(MGGraySprite:getLightShaderProgram(3));
        end
    end
    if eventType == ccui.TouchEventType.canceled then
        if self.headSpr then
            self.headSpr:removeFromParent();
            self.headSpr = nil;
        end
    end
    if eventType == ccui.TouchEventType.ended then
        if self.headSpr then
            self.headSpr:removeFromParent();
            self.headSpr = nil;
        end
    end
        


    if eventType == ccui.TouchEventType.ended then
        if sender == self.Panel_2 then
            if  ME:Lv() >=  self.data.open_lv then
                if self.delegate and self.delegate.EnterItem then
                    self.delegate:EnterItem(self);
                end
            else
                MGMessageTip:showFailedMessage(string.format(MG_TEXT("lockneed"),self.data.open_lv));
            end
        end
    end
end

function campaignItem:setData(data)
	self.data = data;
    self.Label_title:setText(data.name);
    self.Label_desc:setText(data.des);
    self.Image_kind:loadTexture(data.pic..".png", ccui.TextureResType.plistType)
    data.open_lv = tonumber(data.open_lv);
    data.id = tonumber(data.id);
    if  ME:Lv() >=  data.open_lv then
        --self.Image_kind:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
        self.Image_lock:setVisible(false);
    else
        self.Image_kind:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
        self.Image_lock:setVisible(true);
    end

    local reward = getrewardlist(data.reward);
    self.list:removeAllItems();
    local itemLay = ccui.Layout:create();
    local _width = 0;
    local _hight = self.list:getSize().height;
    for i=1,#reward do
        local item = resItem.create();
        item:setData(reward[i].type,reward[i].id);
        item:setScale(0.7);
        item.numLabel:setVisible(false);
        item:setPosition(cc.p(item:getContentSize().width*0.7/2+(3+item:getContentSize().width*0.7)*(i-1),_hight/2));
        itemLay:addChild(item);
        _width=item:getContentSize().width;
    end
    itemLay:setSize(cc.size(_width*0.7+(3+_width*0.7)*(#reward-1), _hight));
    self.list:pushBackCustomItem(itemLay);
end



function campaignItem:onEnter()
    
end

function campaignItem:onExit()
    MGRCManager:releaseResources("campaignItem")
end

function campaignItem.create(delegate)
    local layer = campaignItem:new()
    layer:init(delegate)
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