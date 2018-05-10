-----------------------公会议会厅--招募界面------------------------

guildRecruitLayer = class("guildRecruitLayer", MGLayer)

function guildRecruitLayer:ctor()
    self.descLabel = "";
    self.items = {};
    self:init();
end

function guildRecruitLayer:init()
    local pWidget = MGRCManager:widgetFromJsonFile("guildRecruitLayer","guild_hall_ui_3.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);

    local Panel_2 = pWidget:getChildByName("Panel_2");
    self.Button_send = Panel_2:getChildByName("Button_send");
    self.Button_send:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_shortcut = Panel_2:getChildByName("Button_shortcut");--快捷语
    self.Button_shortcut:addTouchEventListener(handler(self,self.onButtonClick));

    self.Image_editBox = Panel_2:getChildByName("Image_imput_bg");
    self.editBox = self:createEditBox(self.Image_editBox);
    self.Label_hint = Panel_2:getChildByName("Label_hint");

    self.Panel_3 = pWidget:getChildByName("Panel_3");
    self.Panel_3:setVisible(false);
    self.Panel_3:setTouchEnabled(false);
    self.Panel_3:addTouchEventListener(handler(self,self.onButtonClick));

    self.ListView = self.Panel_3:getChildByName("ListView");
    self.ListView:setItemsMargin(5);
    self.ListView:setScrollBarVisible(false);
    self.ListView:setEnabled(false);

    local Label_send = self.Button_send:getChildByName("Label_send");
    Label_send:setText(MG_TEXT_COCOS("guild_hall_ui_3_1"));

    local Label_shortcut = Panel_2:getChildByName("Label_shortcut");
    Label_shortcut:setText(MG_TEXT_COCOS("guild_hall_ui_3_2"));

    local Label_tip = Panel_2:getChildByName("Label_tip");
    Label_tip:setText(MG_TEXT_COCOS("guild_hall_ui_3_3"));
end

function guildRecruitLayer:createEditBox(imageView)
    local sp = cc.Scale9Sprite:create();
    local editBox = cc.EditBox:create(cc.size(imageView:getSize().width * 0.95, imageView:getSize().height), sp);
    editBox:setFontSize(22);
    -- editBox:setFontColor(cc.c3b(82,82,82));
    editBox:setFontName(ttf_msyh);
    editBox:setAnchorPoint(cc.p(0.5, 0.5));
    editBox:setPosition(cc.p(imageView:getSize().width/2, imageView:getSize().height / 2));
    editBox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE);
    editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_SEARCH);
    editBox:registerScriptEditBoxHandler(handler(self,self.editBoxTextEventHandler));
    imageView:addChild(editBox);

    editBox:setMaxLength(50);

    return editBox;
end

function guildRecruitLayer:setData(data)
    self.data = data;

    self.items = {};
    self.ListView:removeAllItems();
    for i=1,10 do
        local item = self:createItem(i);
        self.ListView:pushBackCustomItem(item);
    end
end

function guildRecruitLayer:createItem(i)
    local layout = ccui.Layout:create();
    layout:setTag(i);
    layout:setSize(cc.size(self.ListView:getContentSize().width, 54));
    layout:setTouchEnabled(true);
    layout:addTouchEventListener(handler(self,self.onItemClick));

    local bgSpr = cc.Sprite:createWithSpriteFrameName("word_bg.png");
    bgSpr:setPosition(cc.p(layout:getContentSize().width/2, layout:getContentSize().height/2));
    layout:addChild(bgSpr);

    local descLabel = cc.Label:createWithTTF("本服第一公会招人啦！仅5席位置，欢迎红装全套加入！", ttf_msyh, 22);
    descLabel:setAnchorPoint(cc.p(0,0.5));
    descLabel:setPosition(cc.p(0, layout:getContentSize().height/2));
    layout:addChild(descLabel);

    table.insert(self.items,layout);

    return layout;
end

function guildRecruitLayer:editBoxTextEventHandler(strEventName,sender)
    if strEventName == "began" then
        if sender == self.editBox then
            self.editBox:setText(self.Label_hint:getStringValue());
        end
    elseif strEventName == "return" then
        self.descLabel = self.editBox:getText();
        self.editBox:setText("");
        if self.descLabel == "" then
            self.descLabel = MG_TEXT("guildRecruitLayer_1");
        end
        self.Label_hint:setText(self.descLabel);
    end
end

function guildRecruitLayer:onItemClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        self.descLabel = "本服第一公会招人啦！仅5席位置，欢迎红装全套加入！";
        self.Label_hint:setText(self.descLabel);
        self:setShow(false);
    end
end

function guildRecruitLayer:onButtonClick(sender, eventType)
    if sender ~= self.Panel_3 then
        buttonClickScale(sender, eventType);
    end

    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_shortcut then
            self:setShow(true);
        elseif sender == self.Button_send then

        elseif sender == self.Panel_3 then
            self:setShow(false);
        end
    end
end

function guildRecruitLayer:setShow(isShow)
    self.Panel_3:setVisible(isShow);
    self.Panel_3:setTouchEnabled(isShow);
    self.ListView:setEnabled(isShow);
end

function guildRecruitLayer:onEnter()

end

function guildRecruitLayer:onExit()
    MGRCManager:releaseResources("guildRecruitLayer");
end

function guildRecruitLayer.create(delegate,type)
    local layer = guildRecruitLayer:new()
    layer.delegate = delegate
    layer.scenetype = type
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

function guildRecruitLayer.showBox(delegate,type)
    local layer = guildRecruitLayer.create(delegate,type);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
