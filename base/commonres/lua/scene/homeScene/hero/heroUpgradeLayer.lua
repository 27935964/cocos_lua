-----------------------将领升级界面------------------------
require "Item"

heroUpgradeLayer = class("heroUpgradeLayer", MGLayer)

function heroUpgradeLayer:ctor()
    self.isShow = false;
    self.p_id = 0;
    self.is_up = 0;
    self.curTag = 0;
    self:init();
end

function heroUpgradeLayer:init()
    local pWidget = MGRCManager:widgetFromJsonFile("heroUpgradeLayer","hero_upgrade_ui_1.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);
    
    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));

    self.checkbox = self.Panel_1:getChildByName("Image_checkbox");
    self.checkbox:setTouchEnabled(true);
    self.checkbox:addTouchEventListener(handler(self,self.onButtonClick));
    self.Image_tick = self.Panel_1:getChildByName("Image_tick");
    self.Image_tick:setVisible(self.isShow);
    self.items = {};

    local sql = string.format("select * from prop_list where item_type=%d",9);
    local DBDataList = LUADB.selectlist(sql, "id");

    self.gmList = {};
    for i=1,#DBDataList.info do
        local gm = RESOURCE:getDBResourceListByItemId(tonumber(DBDataList.info[i].id));
        table.insert(self.gmList,gm);

        local Image_box = self.Panel_1:getChildByName("Image_box"..i);
        Image_box:setTag(i);
        Image_box:setTouchEnabled(true);
        Image_box:addTouchEventListener(handler(self,self.onUpgradeClick));
        
        local item = Item.create(self);
        item:setTouchEnabled(false);
        item:setTag(i);
        item:setPosition(Image_box:getContentSize().width/2,Image_box:getContentSize().height/2);
        item:setData(gm);
        item:setShowTip(false);
        item.nameLabel:setVisible(true);
        Image_box:addChild(item);

        table.insert(self.items,{box=Image_box, item=item})
    end
end

function heroUpgradeLayer:setData(gm)
    self.gm = gm;
    for i=1,#self.items do
        self.items[i].item:setData(self.gmList[i]);
        if self.gmList[i]:getNum() <= 0 then
            self.items[i].item:setIsGray(true);
        end
    end
end

function heroUpgradeLayer:ItemSelect(item)
    if self.isShow == false then
        self.is_up = 0;
    elseif self.isShow == true then
        self.is_up = 1;
    end
    self.p_id = self.gmList[item:getTag()]:getItemId();
    self:sendReq();
end

function heroUpgradeLayer:sendReq()
    local str = string.format("&p_id=%d&g_id=%d&is_up=%d",self.p_id,self.gm:getId(),self.is_up);
    NetHandler:sendData(Post_addExp, str);
end

function heroUpgradeLayer:onUpgradeClick(sender, eventType)
    self.curTag = sender:getTag();
    if eventType == ccui.TouchEventType.began then
        local seq = cc.Sequence:create(cc.CallFunc:create(function() self:accumate() end),cc.DelayTime:create(0.2));
        self.action = self:runAction(cc.RepeatForever:create(seq));
    elseif eventType == ccui.TouchEventType.canceled then
        self:stopAction(self.action);
    elseif eventType == ccui.TouchEventType.ended then
        self:stopAction(self.action);
        self.curTag = 0;
    end
end

function heroUpgradeLayer:accumate()
    if self.isShow == false then
        self.is_up = 0;
    elseif self.isShow == true then
        self.is_up = 1;
    end
    self.p_id = self.gmList[self.curTag]:getItemId();
    self:sendReq();
end

function heroUpgradeLayer:onBackClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        self:remove();
    end
end

function heroUpgradeLayer:onButtonClick(sender, eventType)
    if eventType == ccui.TouchEventType.began then
        if self.isShow == false then
            self.isShow = true;
        else
            self.isShow = false;
        end
    end

    if eventType == ccui.TouchEventType.ended then
        if sender == self.Panel_1 then
            self:remove();
        elseif sender == self.checkbox then
            self.Image_tick:setVisible(self.isShow);
        end
    end
end

function heroUpgradeLayer:remove()
    if self.delegate and self.delegate.removeChildrenLayer then
        self.delegate:removeChildrenLayer();
    end
end

function heroUpgradeLayer:onEnter()

end

function heroUpgradeLayer:onExit()
    MGRCManager:releaseResources("heroUpgradeLayer");
end

function heroUpgradeLayer.create(delegate)
    local layer = heroUpgradeLayer:new()
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

function heroUpgradeLayer.showBox(delegate)
    local layer = heroUpgradeLayer.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end