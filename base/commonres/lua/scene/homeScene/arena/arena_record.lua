-----------------------将领属性界面------------------------
require "arena_recordItem"

arena_record = class("arena_record", MGLayer)

function arena_record:ctor()
    self.arenaItemWidget = nil;
    self:init();
end

function arena_record:init()
    local pWidget = MGRCManager:widgetFromJsonFile("arena_record","arena_ui_6.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);--设置描边或者阴影
    
    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));
    local Panel_2 = pWidget:getChildByName("Panel_2");
    local Image_arena_record = Panel_2:getChildByName("Image_arena_record");
    self.Button_close = Panel_2:getChildByName("Button_close");
    self.Button_close:addTouchEventListener(handler(self,self.onButtonClick));

    local Panel_mid = Panel_2:getChildByName("Panel_mid");
    self.list = Panel_mid:getChildByName("ListView");

    if not self.arenaItemWidget then
        self.arenaItemWidget = MGRCManager:widgetFromJsonFile("arena_record", "arena_ui_12.ExportJson");
        self.arenaItemWidget:retain()
    end

    self.Label_tip = Panel_mid:getChildByName("Label_tip");
    self.Label_tip:setText(MG_TEXT_COCOS("arena_ui_22"));
    self.Label_tip:setVisible(false);
end


function arena_record:setData(data)
    if #data == 0 then
        self.Label_tip:setVisible(true);
        return;
    end

    self.list:removeAllItems();
    --self.list:setItemsMargin(5);
    local itemLay = ccui.Layout:create();
    local _width = 0;
    local _hight = 0;
    for i=1,#data do
        local arena_recordItem = arena_recordItem.create(self.delegate,self.arenaItemWidget:clone());
        arena_recordItem:setData(data[i]);
        _width = arena_recordItem:getContentSize().width
        _hight = arena_recordItem:getContentSize().height
        arena_recordItem:setPosition(cc.p(0,(_hight+5)*#data-(_hight+5)*i));
        print(_width..":".._hight)
        itemLay:addChild(arena_recordItem);
    end
    itemLay:setSize(cc.size(_width, (_hight+5)*#data));

    self.list:pushBackCustomItem(itemLay);
end


function arena_record:onButtonClick(sender, eventType)
    buttonClickScale(sender, eventType);
    if eventType == ccui.TouchEventType.ended then
        if sender == self.Panel_1 then
            self:removeFromParent();
        elseif sender == self.Button_close then
            self:removeFromParent();
        end
    end
end


function arena_record:onEnter()

end

function arena_record:onExit()
    if self.arenaItemWidget then
        self.arenaItemWidget:release()
    end
    MGRCManager:releaseResources("arena_record");
end

function arena_record.create(delegate)
    local layer = arena_record:new()
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
