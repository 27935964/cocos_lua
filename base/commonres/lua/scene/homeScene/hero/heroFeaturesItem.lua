heroFeaturesItem = class("heroFeaturesItem", MGWidget)


function heroFeaturesItem:init(delegate,widget)
	self.delegate=delegate;
    self:addChild(widget);
    self.pWidget = widget;

    local Panel_1 = self.pWidget:getChildByName("Panel_1");
    self:setContentSize(Panel_1:getContentSize())
    self.Panel = Panel_1;
    self.Panel:addTouchEventListener(handler(self,self.onButtonClick));
    local Image_bg= Panel_1:getChildByName("Image_bg");
    self.Label_name = Image_bg:getChildByName("Label_name");
    self.Label_lv = Image_bg:getChildByName("Label_lv");
    self.Label_gold = Image_bg:getChildByName("Label_gold");
    self.Image_gold = Image_bg:getChildByName("Image_gold");
    local Label_desc = Image_bg:getChildByName("Label_desc");
    Label_desc:setVisible(false);
    self.Label_desc = MGColorLabel:label()
    self.Label_desc:setPosition(Label_desc:getPosition())
    self.Label_desc:setAnchorPoint(Label_desc:getAnchorPoint())
    self:addChild(self.Label_desc,1)

    self.Button_info = Image_bg:getChildByName("Button_info")
    self.Button_info:addTouchEventListener(handler(self,self.onButtonClick));

    self.Image_ge= Image_bg:getChildByName("Image_ge");
    
    local Image_kuan= Image_bg:getChildByName("Image_kuan");
    self.Image_features= Image_kuan:getChildByName("Image_features");
end


function heroFeaturesItem:onButtonClick(sender, eventType)
    if sender == self.Button_info then
        buttonClickScale(sender, eventType)
    end

    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_info then
            if self.delegate and self.delegate.UpFeatures then
                self.delegate:UpFeatures(self);
            end
        elseif  sender == self.Panel then
            if self.delegate and self.delegate.showInfo then
                self.delegate:showInfo(self);
            end
        end
    end
end

function heroFeaturesItem:setData(data,index)
	self.data = data
    self.index = index;
    self.Label_name:setText(data.f_name);
    self.Label_desc:clear();
    self.Label_desc:appendStringAutoWrap(data.desc, 11, 1, cc.c3b(255,255,255), 22);
    
    if data.islock == 1 then
        self.Label_lv:setVisible(false);
        self.Label_gold:setVisible(false);
        self.Image_gold:setVisible(false);
        self.Image_features:loadTexture("hero_features_ge_lock.png", ccui.TextureResType.plistType)
        self.Button_info:setEnabled(false);
    else
        self.Label_lv:setText(string.format("Lv.%d",data.lv));
        self.Image_features:loadTexture(data.pic..".png", ccui.TextureResType.plistType)
        local str_list1 = spliteStr(data.need,':');  
        self.Label_gold:setText(string.format("%d",tonumber(str_list1[3])));
    end
    local sql = string.format("select color from quality where id=%d",data.quality);
    local DBData = LUADB.select(sql, "color");
    print('quality:'..data.quality);
    print('color:'..DBData.info.color.."  "..string.format("hero_features_ge_%d.png",DBData.info.color));
    self.Image_ge:loadTexture(string.format("hero_features_ge_%d.png",DBData.info.color), ccui.TextureResType.plistType);
end

function heroFeaturesItem:setlv()
    self.Label_lv:setText(string.format("Lv.%d",self.data.lv));
    local str_list1 = spliteStr(self.data.need,':');  
    self.Label_gold:setText(string.format("%d",tonumber(str_list1[3])));
end



function heroFeaturesItem:onEnter()
    
end

function heroFeaturesItem:onExit()
    MGRCManager:releaseResources("heroFeaturesItem")
end

function heroFeaturesItem.create(delegate,widget)
    local layer = heroFeaturesItem:new()
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