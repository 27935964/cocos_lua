--------------------------公会议会厅申请审批界面-----------------------

local guildApproveItem = class("guildApproveItem", MGWidget)

function guildApproveItem:init(delegate,widget)
    self.uid = 0;
    self.delegate=delegate;
    self:addChild(widget);
    self.pWidget = widget;

    local Panel_2 = self.pWidget:getChildByName("Panel_2");
    self:setContentSize(Panel_2:getContentSize());

    local Panel_3 = Panel_2:getChildByName("Panel_3");
    self.heroHead = userHead.create(self);
    self.heroHead:setAnchorPoint(cc.p(0.5, 0.5));
    self.heroHead:setPosition(cc.p(Panel_3:getContentSize().width/2,Panel_3:getContentSize().height/2));
    Panel_3:addChild(self.heroHead);

    self.Label_level = Panel_2:getChildByName("Label_level");
    self.BitmapLabel = Panel_2:getChildByName("BitmapLabel");
    self.Label_name = Panel_2:getChildByName("Label_name");
    self.Label_power = Panel_2:getChildByName("Label_power");
    self.Label_prestige_number = Panel_2:getChildByName("Label_prestige_number");

    self.Label_limit = Panel_2:getChildByName("Label_limit");
    self.Label_tip = Panel_2:getChildByName("Label_tip");
    self.Image_apply = Panel_2:getChildByName("Image_apply");

    self.Button_agree = Panel_2:getChildByName("Button_agree");--同意
    self.Button_agree:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_reject = Panel_2:getChildByName("Button_reject");--拒绝
    self.Button_reject:addTouchEventListener(handler(self,self.onButtonClick));

    local Label_agree = self.Button_agree:getChildByName("Label_agree");
    Label_agree:setText(MG_TEXT_COCOS("guild_hall_item_2_1"));
    local Label_reject = self.Button_reject:getChildByName("Label_reject");
    Label_reject:setText(MG_TEXT_COCOS("guild_hall_item_2_2"));
end

function guildApproveItem:setData(data)
    self.data = data;
    self.uid = data.uid;

    self.BitmapLabel:setText(self.data.vip_lv);
    self.Label_name:setText(unicode_to_utf8(self.data.name));
    self.Label_power:setText(self.data.score);
    self.Label_level:setText(string.format("Lv.%d",tonumber(self.data.lv)));
    self.Label_prestige_number:setText(self.data.feats);
    
    local gm = GENERAL:getGeneralModel(tonumber(data.head));
    if gm then
        self.heroHead:setData(gm);
    end
end

function guildApproveItem:setState(state)
    self.Button_apply:setEnabled(false);
    self.Label_tip:setVisible(false);
    self.Image_apply:setVisible(false);
    if state == 0 then--state：0表示未申请，1表示已申请，2已满员，3任何人都无法加入
        self.Button_apply:setEnabled(true);
    elseif state == 1 then
        self.Image_apply:setVisible(true);
        self.Image_apply:loadTexture("guild_applied.png",ccui.TextureResType.plistType);
    elseif state == 2 then
        self.Image_apply:setVisible(true);
        self.Image_apply:loadTexture("guild_was_full.png",ccui.TextureResType.plistType);
    elseif state == 3 then
        self.Label_tip:setVisible(true);
    end
end

function guildApproveItem:onButtonClick(sender, eventType)
    buttonClickScale(sender, eventType);

    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_agree then
            if self.delegate and self.delegate.sendAgreeApplyReq then
                self.delegate:sendAgreeApplyReq(self);
            end
        elseif sender == self.Button_reject then
            if self.delegate and self.delegate.addTip then
                self.delegate:addTip(self);
            end
        end
    end
end

function guildApproveItem:onEnter()
    
end

function guildApproveItem:onExit()
    MGRCManager:releaseResources("guildApproveItem")
end

function guildApproveItem.create(delegate,widget)
    local layer = guildApproveItem:new()
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

return guildApproveItem