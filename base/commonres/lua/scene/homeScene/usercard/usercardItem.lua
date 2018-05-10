usercardItem = class("usercardItem", MGWidget)


function usercardItem:init(delegate)
	self.delegate=delegate;

    self.pWidget = MGRCManager:widgetFromJsonFile("usercardLayer", "usercard_ui_3.ExportJson");
    MGRCManager:changeWidgetTextFont(self.pWidget,true);--设置描边或者阴影
    self:addChild(self.pWidget);

    local Panel_1 = self.pWidget:getChildByName("Panel_1");
    self:setContentSize(Panel_1:getContentSize())

    self.Label_title = Panel_1:getChildByName("Label_title");
    local Label_get = Panel_1:getChildByName("Label_get");
    Label_get:setVisible(false);
    self.Label_free= Panel_1:getChildByName("Label_free");
    
    self.Label_get = MGColorLabel:label()
    self.Label_get:setAnchorPoint(Label_get:getAnchorPoint());
    self.Label_get:setPosition(Label_get:getPosition());
    Panel_1:addChild(self.Label_get,2)

    self.Button_do = Panel_1:getChildByName("Button_do")
    self.Button_do:addTouchEventListener(handler(self,self.onButtonClick));
    local Label_do = self.Button_do:getChildByName("Label_do");
    Label_do:setText(MG_TEXT_COCOS("usercard_ui_3"));
    self.Button_look = Panel_1:getChildByName("Button_look")
    self.Button_look:addTouchEventListener(handler(self,self.onButtonClick));

    local  Image_num= Panel_1:getChildByName("Image_num");
    self.Image_icon= Image_num:getChildByName("Image_icon");

    self.Label_need = MGColorLabel:label()
    self.Label_need:setAnchorPoint(cc.p(0,0.5));
    self.Label_need:setPosition(cc.p(self.Image_icon:getPositionX()+self.Image_icon:getContentSize().width/2+10,self.Image_icon:getPositionY()));
    Image_num:addChild(self.Label_need,2)

    self.Image_bg= Panel_1:getChildByName("Image_bg");
end


function usercardItem:onButtonClick(sender, eventType)
    buttonClickScale(sender, eventType)

    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_do then
            if self.delegate and self.delegate.cardDo then
                self.delegate:cardDo(self);
            end
        elseif  sender == self.Button_look then
            if self.delegate and self.delegate.cardlook then
                self.delegate:cardlook(self);
            end
        end
    end
end

function usercardItem:setData(data,usercb)
	self.data = data;
    self.Label_title:setText(data.name);
    self.Image_bg:loadTexture(data.pic..".png", ccui.TextureResType.plistType)

    self.Label_get:clear();
    local num = tonumber(data.num)
    if usercb then
        num = usercb.num
    end
    if  num == 1 then
        self.Label_get:appendStringAutoWrap(string.format("%s",data.desc),18,1,Color3B.WHITE,22);
    else
        self.Label_get:appendStringAutoWrap(string.format(MG_TEXT("usercard_1"),num,data.desc),18,1,Color3B.WHITE,22);
    end



    local  str = data.need;
    local str_list = spliteStr(data.need,':');  
    local havenum = 0;
    local item =  RESOURCE:getResModelByItemId(tonumber(str_list[2]));
    if item then
        havenum = item:getNum();
    end
    local neednum = tonumber(str_list[3]);
    self.Label_need:clear()
    if neednum<=havenum then
        self.Label_need:appendString(string.format("%d",havenum), Color3B.GREEN, ttf_msyh, 22);
    else
        self.Label_need:appendString(string.format("%d",havenum), Color3B.RED, ttf_msyh, 22);
    end
    self.Label_need:appendString(string.format("/%d",neednum), Color3B.WHITE, ttf_msyh, 22)
    self.Image_icon:loadTexture(string.format("user_card_icon_%s.png",str_list[2]), ccui.TextureResType.plistType)

    if usercb then
        self.is_free_time = usercb.is_free_time;
        self.free_time = usercb.free_time;
        if usercb.is_free_time==1 then
            self.Label_free:setVisible(true);
            if usercb.free_time==0 then
                self.Label_free:setVisible(false);
                self.Label_free:setText(MG_TEXT("usercard_2"));
                self.Label_need:clear();
                self.Label_need:appendString(MG_TEXT("usercard_2"), Color3B.GREEN, ttf_msyh, 22);
            else
                self.Label_free:setText(string.format(MG_TEXT("usercard_3"),MGDataHelper:secToString(usercb.free_time)));
            end
        else
            self.Label_free:setVisible(false);
        end
    else
        self.Label_free:setVisible(false);
        self.Label_free:setText(MG_TEXT("usercard_2"));
        self.Label_need:clear();
        self.Label_need:appendString(MG_TEXT("usercard_2"), Color3B.GREEN, ttf_msyh, 22);
    end
end

function usercardItem:setlv(lv)
    self.data.lv = lv
    self.Label_lv:setText(string.format("Lv.%d",lv));
end

function usercardItem:updata()
    if self.is_free_time==1 then
        if self.free_time==0 then
            self.Label_free:setText(MG_TEXT("usercard_2"));
        else
            self.free_time = self.free_time-1;
            self.Label_free:setText(string.format(MG_TEXT("usercard_3"),MGDataHelper:secToString(self.free_time)));
        end
    end
end

function usercardItem:onEnter()
    
end

function usercardItem:onExit()
    MGRCManager:releaseResources("usercardItem")
end

function usercardItem.create(delegate)
    local layer = usercardItem:new()
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