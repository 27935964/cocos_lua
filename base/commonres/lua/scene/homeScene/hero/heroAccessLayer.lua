-----------------------获得路径界面------------------------
require "Item"

local jumpItem = require "jumpItem"

heroAccessLayer = class("heroAccessLayer", MGLayer)

function heroAccessLayer:ctor()
    self:init();
end

function heroAccessLayer:init()
    local pWidget = MGRCManager:widgetFromJsonFile("heroAccessLayer","hero_access_ui_1.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);

    if not self.jumpItemWidget then
        MGRCManager:cacheResource("heroAccessLayer", "jump_ui.png","jump_ui.plist");
        self.jumpItemWidget = MGRCManager:widgetFromJsonFile("heroAccessLayer", "jump_ui_1.ExportJson",false);
        self.jumpItemWidget:retain();
    end
    
    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:setTouchEnabled(true);
    self.Panel_1:addTouchEventListener(handler(self,self.onBackClick));

    local Panel_2 = pWidget:getChildByName("Panel_2");
    self.Button_close = Panel_2:getChildByName("Button_close");
    self.Button_close:addTouchEventListener(handler(self,self.onButtonClick));

    local Image_box = Panel_2:getChildByName("Image_box");
    self.equip = Item.create(self);
    self.equip:setTouchEnabled(false);
    self.equip:setPosition(Image_box:getSize().width/2,Image_box:getSize().height/2);
    Image_box:addChild(self.equip);

    self.Label_name = Panel_2:getChildByName("Label_name");--武将名
    self.ListView = Panel_2:getChildByName("ListView");
    self.ListView:setScrollBarVisible(false);--true添加滚动条
    self.ListView:setItemsMargin(10);

    local Panel_des = Panel_2:getChildByName("Panel_des");
    self.descLabel = cc.Label:createWithTTF("",ttf_msyh,22);
    self.descLabel:setAlignment(cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_TOP);
    self.descLabel:setDimensions(250, 0);
    -- self.descLabel:setColor(cc.c3b(207, 203, 202));
    self.descLabel:setAnchorPoint(cc.p(0, 1));
    self.descLabel:setPosition(cc.p(0,Panel_des:getContentSize().height));
    Panel_des:addChild(self.descLabel);
end

function heroAccessLayer:setData(gm,resData)
    self.gm = gm;
    self.equip:setData(resData);
    self.Label_name:setText(resData:name());
    self.descLabel:setString(resData:desc());

    self.ListView:removeAllItems();
    for i=1,#resData:getGetGoInfo() do
        local item = jumpItem.create(self,self.jumpItemWidget:clone());
        item:setData(resData:getGetGoInfo()[i]:getId());
        self.ListView:pushBackCustomItem(item);
    end

end

function heroAccessLayer:onBackClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        self:removeFromParent();
    end
end

function heroAccessLayer:onButtonClick(sender, eventType)
    if eventType == ccui.TouchEventType.began then
        local sc = cc.ScaleTo:create(0.1, 1.1)
        sender:runAction(cc.EaseOut:create(sc ,2))
    end
    if eventType == ccui.TouchEventType.canceled then
        local sc = cc.ScaleTo:create(0.1, 1)
        sender:runAction(sc)
    end
    if eventType == ccui.TouchEventType.ended then
        local sc = cc.ScaleTo:create(0.1, 1)
        sender:runAction(sc)
        if sender == self.Button_close then
            self:removeFromParent();
        end
    end
end

function heroAccessLayer:onEnter()

end

function heroAccessLayer:onExit()
    MGRCManager:releaseResources("heroAccessLayer");

    if self.jumpItemWidget then
        self.jumpItemWidget:release()
    end
end

function heroAccessLayer.create(delegate)
    local layer = heroAccessLayer:new()
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

function heroAccessLayer.showBox(delegate)
    local layer = heroAccessLayer.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
