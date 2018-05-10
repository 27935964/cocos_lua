-----------------------将领属性界面------------------------
require "arena_activeItem"
arena_active = class("arena_active", MGLayer)

function arena_active:ctor()
    self:init();
end

function arena_active:init()
    local pWidget = MGRCManager:widgetFromJsonFile("arena_active","arena_ui_7.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);--设置描边或者阴影
    
    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));
    local Panel_2 = pWidget:getChildByName("Panel_2");
    local Image_arena_active = Panel_2:getChildByName("Image_arena_active");
    self.Button_close = Panel_2:getChildByName("Button_close");
    self.Button_close:addTouchEventListener(handler(self,self.onButtonClick));

    local Panel_mid = Panel_2:getChildByName("Panel_mid");
    self.list = Panel_mid:getChildByName("ListView");
    local Label_active_name = Panel_mid:getChildByName("Label_active_name");
    Label_active_name:setText(MG_TEXT_COCOS("arena_ui_25"));
    self.Label_active = Panel_mid:getChildByName("Label_active");
    if not self.arenaItemWidget then
        self.arenaItemWidget = MGRCManager:widgetFromJsonFile("arena_active", "arena_ui_13.ExportJson");
        self.arenaItemWidget:retain()
    end
end


function arena_active:setData(data,active,get_active_reward)
    self.Label_active:setText(""..active);
    local get_activelist ={};
    local str_list = spliteStr(get_active_reward,'|');
    for i=1,#str_list do
        table.insert( get_activelist,tonumber(str_list[i]));
    end

    self.list:removeAllItems();
    self.list:setItemsMargin(5);
    for i=1,#data do
        local arena_activeItem = arena_activeItem.create(self.delegate,self.arenaItemWidget:clone());
        data[i].active = tonumber(data[i].active);
        local canget  = 1;
        local haveget = 0;
        if  data[i].active > active then
            canget = 0;
        else
            for j=1,#get_activelist do
                if data[i].active == get_activelist[j] then
                    haveget = 1;
                    break;
                end
            end
        end
        arena_activeItem:setData(data[i],canget,haveget);

        self.list:pushBackCustomItem(arena_activeItem);
    end
end

function arena_active:onButtonClick(sender, eventType)
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


function arena_active:onEnter()

end

function arena_active:onExit()
    if self.arenaItemWidget then
        self.arenaItemWidget:release()
    end
    MGRCManager:releaseResources("arena_active");
end

function arena_active.create(delegate)
    local layer = arena_active:new()
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
