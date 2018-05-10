-----------------------公会仓库捐献物质提示弹框-----------------

guildPackageTip = class("guildPackageTip", MGLayer)

function guildPackageTip:ctor()
    self:init();
end

function guildPackageTip:init()
    local pWidget = MGRCManager:widgetFromJsonFile("guildPackageTip","guild_package_tip_ui.ExportJson");
    self:addChild(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));
    self.Panel_1:setAnchorPoint(cc.p(0.5, 0.5));
    CommonMethod:setFullBgScale(self.Panel_1);

    local Panel_2 = pWidget:getChildByName("Panel_2");
    NodeShow(Panel_2);

    self.Panel_3 = Panel_2:getChildByName("Panel_3");
    self.Label_num = self.Panel_3:getChildByName("Label_num");

    self.Button_cancel = Panel_2:getChildByName("Button_cancel");
    self.Button_cancel:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_ok = Panel_2:getChildByName("Button_ok");
    self.Button_ok:addTouchEventListener(handler(self,self.onButtonClick));

    local Image_item = self.Panel_3:getChildByName("Image_item");
    self.item = Item.create();
    self.item:setPosition(Image_item:getContentSize().width/2,Image_item:getContentSize().height/2);
    Image_item:addChild(self.item);

    local Label_tip = self.Panel_3:getChildByName("Label_tip");
    self.Label_tip1 = self.Panel_3:getChildByName("Label_tip1");
    local Label_cancel = self.Button_cancel:getChildByName("Label_cancel");
    local Label_ok = self.Button_ok:getChildByName("Label_ok");

    Label_tip:setText(MG_TEXT_COCOS("guild_package_tip_ui_1"));
    self.Label_tip1:setText(MG_TEXT_COCOS("guild_package_tip_ui_2"));
    Label_cancel:setText(MG_TEXT_COCOS("guild_package_tip_ui_3"));
    Label_ok:setText(MG_TEXT_COCOS("guild_package_tip_ui_4"));

end

function guildPackageTip:setData(gm,goodsNum)
    self.gm = gm;
    self.item:setData(gm);
    self.item:numHide();
    self.Label_num:setText(string.format("x%d",goodsNum));
    self.Label_tip1:setPositionX(self.Label_num:getPositionX()+self.Label_num:getContentSize().width+10);
end

function guildPackageTip:onButtonClick(sender, eventType)
    if sender ~= self.Panel_1 then
        buttonClickScale(sender, eventType);
    end

    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_ok then
            if self.delegate and self.delegate.sendReq then
                self.delegate:sendReq(self);
                self:removeFromParent();
            end
        else
            self:removeFromParent();
        end
    end
end

function guildPackageTip:onEnter()

end

function guildPackageTip:onExit()
    MGRCManager:releaseResources("guildPackageTip");
end

function guildPackageTip.create(delegate)
    local layer = guildPackageTip:new()
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

function guildPackageTip.showBox(delegate)
    local layer = guildPackageTip.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
