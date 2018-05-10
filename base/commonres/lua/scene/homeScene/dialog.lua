-----------------------将领属性界面------------------------

dialog = class("dialog", MGLayer)

function dialog:ctor()
    self:init();
end

function dialog:init()
    local pWidget = MGRCManager:widgetFromJsonFile("dialog","dialog_ui.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);--设置描边或者阴影
    
    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));
    local Panel_2 = pWidget:getChildByName("Panel_2");
    local Image_dialog = Panel_2:getChildByName("Image_dialog");
    self.Button_close = Panel_2:getChildByName("Button_close");
    self.Button_close:addTouchEventListener(handler(self,self.onButtonClick));
    self.Button_ok = Panel_2:getChildByName("Button_ok");
    self.Button_ok:addTouchEventListener(handler(self,self.onButtonClick));
    local Label_ok = self.Button_ok:getChildByName("Label_ok");
    Label_ok:setText(MG_TEXT_COCOS("dialog_ui_1"));
    self.Image_title = Panel_2:getChildByName("Image_title");
end

function dialog:setTitle(title)
    self.Image_title:loadTexture(title,ccui.TextureResType.plistType);
end

function dialog:onButtonClick(sender, eventType)
    buttonClickScale(sender, eventType);
    if eventType == ccui.TouchEventType.ended then
        if sender == self.Panel_1 then
            if self.delegate and self.delegate.dialogok then
                self.delegate:dialogok(0);
            end
            self:removeFromParent();
        elseif sender == self.Button_close then
            if self.delegate and self.delegate.dialogok then
                self.delegate:dialogok(0);
            end
            self:removeFromParent();
        elseif sender == self.Button_ok then
            if self.delegate and self.delegate.dialogok then
                self.delegate:dialogok(1);
            end
            self:removeFromParent();
        end
    end
end



function dialog:onEnter()

end

function dialog:onExit()
    MGRCManager:releaseResources("dialog");
end

function dialog.create(delegate)
    local layer = dialog:new()
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


function dialog.showBox(delegate)
    local layer = dialog.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
