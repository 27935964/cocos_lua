scienceItem = class("scienceItem", MGWidget)


function scienceItem:init(delegate)
	self.delegate=delegate;

    self.pWidget = MGRCManager:widgetFromJsonFile("scienceLayer", "science_ui_2.ExportJson");
    MGRCManager:changeWidgetTextFont(self.pWidget,true);--设置描边或者阴影
    self:addChild(self.pWidget);

    self.Panel_2 = self.pWidget:getChildByName("Panel_2");
    self.Panel_2:addTouchEventListener(handler(self,self.onButtonClick));
    self:setContentSize(self.Panel_2:getContentSize())

    self.Label_title = self.Panel_2:getChildByName("Label_title");
    self.Label_info = self.Panel_2:getChildByName("Label_info");
    self.Label_desc = self.Panel_2:getChildByName("Label_desc");
    self.Image_kind= self.Panel_2:getChildByName("Image_kind");
    self.Image_lock= self.Panel_2:getChildByName("Image_lock");
end


function scienceItem:onButtonClick(sender, eventType)
    if eventType == ccui.TouchEventType.began then
        if self.headSpr==nil then
            self.headSpr = cc.Sprite:createWithSpriteFrameName(self.data.pic..".jpg")
            self.headSpr:setPosition(self.Image_kind:getPosition());
            self.Panel_2:addChild(self.headSpr,1);
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
                if self.delegate and self.delegate.EnterSci then
                    self.delegate:EnterSci(self);
                end
            else
                MGMessageTip:showFailedMessage(string.format(MG_TEXT("lockneed"),self.data.open_lv));
            end
        end
    end
end

function scienceItem:setData(data)
	self.data = data;
    self.Label_title:setText(data.name);
    self.Label_info:setText(data.introduce);
    self.Label_desc:setText(data.des);
    self.Image_kind:loadTexture(data.pic..".jpg", ccui.TextureResType.plistType)
    data.open_lv = tonumber(data.open_lv);
    data.science_id = tonumber(data.science_id);
    if  ME:Lv() >=  data.open_lv then
        --self.Image_kind:setColor(Color3B.WHITE);
        self.Image_lock:setVisible(false);
    else
        self.Image_kind:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
        self.Image_lock:setVisible(true);
    end
end



function scienceItem:onEnter()
    
end

function scienceItem:onExit()
    MGRCManager:releaseResources("scienceItem")
end

function scienceItem.create(delegate)
    local layer = scienceItem:new()
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