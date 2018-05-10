-----------------------将领属性界面------------------------

mailSel = class("mailSel", MGLayer)

function mailSel:ctor()
    self:init();
end

function mailSel:init()
    local pWidget = MGRCManager:widgetFromJsonFile("mailSel","mail_ui_4.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);--设置描边或者阴影
    
    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));
    local Panel_2 = pWidget:getChildByName("Panel_2");
    local Image_mailSel = Panel_2:getChildByName("Image_mailSel");
    self.Button_close = Panel_2:getChildByName("Button_close");
    self.Button_close:addTouchEventListener(handler(self,self.onButtonClick));
    self.list = Panel_2:getChildByName("ListView");

    self:createlist();
end


function mailSel:setData(type,id)
    --@Input    type Int 邮件类型 id Int 邮件记录ID
    local str = string.format("&type=%d&id=%d",type,id);
    NetHandler:sendData(Post_readMail, str);
end

function mailSel:onButtonClick(sender, eventType)
    buttonClickScale(sender, eventType);
    if eventType == ccui.TouchEventType.ended then
        if sender == self.Panel_1 then
            self:removeFromParent();
        elseif sender == self.Button_close then
            self:removeFromParent();
        elseif sender == self.Button_ok then
            self:removeFromParent();
        end
    end
end


function mailSel:createlist()
    self.list:removeAllItems();
    require "mailSelItem";
    for i=1,8 do
        local mailSelItem = mailSelItem.create(self);
        mailSelItem:setData(string.format("mailsel%d",i));
        self.list:pushBackCustomItem(mailSelItem);
    end
end

function mailSel:mailSelItemSelect(s_uname)
    if self.delegate and self.delegate.mailSelItemSelect then
        self.delegate:mailSelItemSelect(s_uname);
    end
    self:removeFromParent();
end



function mailSel:onReciveData(MsgID, NetData)
    print("mailSel onReciveData MsgID:"..MsgID)
    
    if MsgID == Post_readMail then
        local ackData = NetData
        if ackData.state == 1  then
            self.data  =  ackData.readmail.info;
            self:updata();

        else
            NetHandler:showFailedMessage(ackData)
            self:removeFromParent();
        end
    end
end

function mailSel:pushAck()
    NetHandler:addAckCode(self,Post_readMail);
end

function mailSel:popAck()
    NetHandler:delAckCode(self,Post_readMail);
end

function mailSel:onEnter()
    self:pushAck();
end

function mailSel:onExit()
    MGRCManager:releaseResources("mailSel");
    self:popAck();
end

function mailSel.create(delegate)
    local layer = mailSel:new()
    layer.delegate = delegate
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


function mailSel.showBox(delegate)
    local layer = mailSel.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
