-----------------------将领属性界面------------------------

arena_say = class("arena_say", MGLayer)

function arena_say:ctor()
    self:init();
end

function arena_say:init()
    local pWidget = MGRCManager:widgetFromJsonFile("arena_say","arena_ui_4.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);--设置描边或者阴影
    
    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));
    local Panel_2 = pWidget:getChildByName("Panel_2");
    local Image_arena_say = Panel_2:getChildByName("Image_arena_say");
    self.Button_close = Panel_2:getChildByName("Button_close");
    self.Button_close:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_ok = Panel_2:getChildByName("Button_ok");
    self.Button_ok:addTouchEventListener(handler(self,self.onButtonClick));
    self.Label_ok = self.Button_ok:getChildByName("Label_ok");
    self.Label_ok:setText(MG_TEXT_COCOS("arena_ui_19"));


    local Panel_mid = Panel_2:getChildByName("Panel_mid");
    local Label_tip = Panel_mid:getChildByName("Label_tip");
    Label_tip:setText(MG_TEXT_COCOS("arena_ui_18"));

    local Image_frame = Panel_mid:getChildByName("Image_frame");
    self.editBox = self:createEditBox(Image_frame);
    self.Label_txt = Image_frame:getChildByName("Label_txt");
end

function arena_say:createEditBox(imageView)
    local sp = cc.Scale9Sprite:create();
    local editBox = cc.EditBox:create(cc.size(imageView:getSize().width * 0.96, imageView:getSize().height), sp);
    editBox:setFontSize(22);
    editBox:setFontColor(Color3B.WHITE);
    editBox:setFontName(ttf_msyh);
    editBox:setAnchorPoint(cc.p(0.5, 0.5));
    editBox:setPosition(cc.p(imageView:getSize().width/2, imageView:getSize().height / 2));
    editBox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE);
    editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_SEARCH);
    editBox:registerScriptEditBoxHandler(handler(self,self.editBoxTextEventHandler));
    imageView:addChild(editBox);
    editBox:setMaxLength(20);
    return editBox;
end


function arena_say:editBoxTextEventHandler(strEventName,sender)
    if strEventName == "began" then
        self.editBox:setText(self.Label_txt:getStringValue())
    elseif strEventName == "return" then
        self.context = self.editBox:getText();
        self.editBox:setText("");
        self.Label_txt:setText(self.context);
    end
end

function arena_say:setData(sign)
    self.sign = sign;
    self.context = self.sign;
    self.Label_txt:setText(self.sign);
end

function arena_say:onButtonClick(sender, eventType)
    buttonClickScale(sender, eventType);
    if eventType == ccui.TouchEventType.ended then
        if sender == self.Panel_1 then
            self:removeFromParent();
        elseif sender == self.Button_close then
            self:removeFromParent();
        elseif sender == self.Button_ok then
            if self.context == "" then
                self.context = MG_TEXT("arena_signature");
            end
            if self.context~= self.sign then
                if self.delegate and self.delegate.sendSay then
                    self.delegate:sendSay(self.context);
                end
                self:removeFromParent();
            else
                MGMessageTip:showFailedMessage(MG_TEXT("arena_sign_fail"));
            end

        end
    end
end


function arena_say:onEnter()

end

function arena_say:onExit()
    MGRCManager:releaseResources("arena_say");
end

function arena_say.create(delegate)
    local layer = arena_say:new()
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
