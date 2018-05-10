require "utf8"
mailItem = class("mailItem", MGWidget)

function mailItem:ctor()

end

function mailItem:init(delegate,widget)
    self.delegate=delegate;
    self:addChild(widget);
    self.pWidget = widget;

    local Panel_1 = self.pWidget:getChildByName("Panel_1");
    self:setContentSize(Panel_1:getContentSize())
    self.Panel = Panel_1;
    self.Panel:addTouchEventListener(handler(self,self.onButtonClick));

    self.Image_mail= Panel_1:getChildByName("Image_mail");
    self.Label_name = Panel_1:getChildByName("Label_name");
    self.Label_title = Panel_1:getChildByName("Label_title");
    self.Label_time = Panel_1:getChildByName("Label_time");
    self.Image_attch = Panel_1:getChildByName("Image_attch");
    self.CheckBox = Panel_1:getChildByName("CheckBox")

    --self.CheckBox:getSelectedState()
end


function mailItem:setData(id,info)
    self.info = info;
    self.id = id;
    self:upData();
end

function mailItem:upData()
    if self.id ==1 then
        self.Label_name:setText(MG_TEXT_COCOS("mail_ui_8"));
    else
        
        self.Label_name:setText(unicode_to_utf8(self.info.send_u_name));
    end
    self.Label_title:setText(unicode_to_utf8(self.info.subject));
    if self.info.is_affix==0 then
        self.Image_attch:setVisible(false);
    else
        self.Image_attch:setVisible(true);
    end 

    if self.info.is_read==0 then
        self.Image_mail:loadTexture("mail_not_read.png", ccui.TextureResType.plistType)
    else
        
        self.Image_mail:loadTexture("mail_have_read.png", ccui.TextureResType.plistType)
    end 

    if self.id ==2 then
        self.CheckBox:setVisible(true);
    else
        self.CheckBox:setVisible(false);
    end

    self.Label_time:setText(MGDataHelper:secToMonDay(self.info.send_time));
end

function mailItem:onButtonClick(sender, eventType)
    if eventType == ccui.TouchEventType.began then
        self.Label_title:setColor(Color3B.MAGENTA);
    end
    if eventType == ccui.TouchEventType.canceled then
        self.Label_title:setColor(Color3B.WHITE);
    end
    if eventType == ccui.TouchEventType.ended then
        self.Label_title:setColor(Color3B.WHITE);
    end
    if eventType == ccui.TouchEventType.ended then
        if self.delegate and self.delegate.mailItemSelect then
            self.delegate:mailItemSelect(self);
        end
    end
end

function mailItem:onEnter()

end

function mailItem:onExit()
    MGRCManager:releaseResources("mailItem")
end

function mailItem.create(delegate,widget)
    local layer = mailItem:new()
    layer:init(delegate,widget);
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
