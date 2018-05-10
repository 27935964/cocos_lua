-----------------------将领属性界面------------------------
require "arena_rankItem"
require "playerInfo"
arena_rank = class("arena_rank", MGLayer)

function arena_rank:ctor()
    self:init();
end

function arena_rank:init()
    local pWidget = MGRCManager:widgetFromJsonFile("arena_rank","arena_ui_5.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);--设置描边或者阴影
    
    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));
    local Panel_2 = pWidget:getChildByName("Panel_2");
    local Image_arena_rank = Panel_2:getChildByName("Image_arena_rank");
    self.Button_close = Panel_2:getChildByName("Button_close");
    self.Button_close:addTouchEventListener(handler(self,self.onButtonClick));

    local Panel_mid = Panel_2:getChildByName("Panel_mid");
    self.list = Panel_mid:getChildByName("ListView");
end


function arena_rank:setData(data)
    self.list:removeAllItems();
    --self.list:setItemsMargin(5);
    for i=1,#data do
        local arena_rankItem = arena_rankItem.create(self);
        arena_rankItem:setData(data[i],i);
        self.list:pushBackCustomItem(arena_rankItem);
    end
end

function arena_rank:rankItemSelect(item)
    local playerInfo = playerInfo.create(self);
    playerInfo:setData(item.info.uid,item.info.name);
    cc.Director:getInstance():getRunningScene():addChild(playerInfo,ZORDER_MAX);
end

function arena_rank:onButtonClick(sender, eventType)
    buttonClickScale(sender, eventType);
    if eventType == ccui.TouchEventType.ended then
        if sender == self.Panel_1 then
            self:removeFromParent();
        elseif sender == self.Button_close then
            self:removeFromParent();
        elseif sender == self.Button_ok then
            if self.data.is_affix == 1 then
                if self.delegate and self.delegate.sendgetAffix then
                    self.delegate:sendgetAffix();
                end
            end
            self:removeFromParent();
        end
    end
end


function arena_rank:onEnter()

end

function arena_rank:onExit()
    MGRCManager:releaseResources("arena_rank");
end

function arena_rank.create(delegate)
    local layer = arena_rank:new()
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
