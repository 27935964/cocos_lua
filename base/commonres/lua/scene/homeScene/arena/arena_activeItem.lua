require "utf8"
arena_activeItem = class("arena_activeItem", function()
    return ccui.Layout:create();
end)

function arena_activeItem:ctor()

end

function arena_activeItem:init(delegate,widget)
    self.delegate=delegate;
    self:addChild(widget);
    self.pWidget = widget;

    local Panel_1 = self.pWidget:getChildByName("Panel_1");
    self:setSize(Panel_1:getSize())

    local Image_bg = Panel_1:getChildByName("Image_bg");
    local Label_active_name = Image_bg:getChildByName("Label_active_name");
    Label_active_name:setText(MG_TEXT_COCOS("arena_ui_24"));
    self.Label_active = Image_bg:getChildByName("Label_active");
    self.list = Image_bg:getChildByName("ListView");
    self.Button_get= Image_bg:getChildByName("Button_get");
    self.Button_get:addTouchEventListener(handler(self,self.onButtonClick));
    local Label_get = self.Button_get:getChildByName("Label_get");
    Label_get:setText(MG_TEXT_COCOS("arena_ui_23"));
    Label_get:getLabel():enableShadow(Color4B.BLACK, cc.size(1, -1),1);
    self.Label_get = Label_get;

    self.Image_get = Image_bg:getChildByName("Image_get");
end

function arena_activeItem:setData(data,canget,haveget)
    self.data = data;
    self.Label_active:setText(""..data.active);

    local reward = getneedlist(data.reward);
    self.list:removeAllItems();
    for i=1,#reward do
        local item = resItem.create();
        item:setData(reward[i].type,reward[i].id);
        item:setNum(reward[i].num)
        self.list:pushBackCustomItem(item);
    end

    if canget==1 then
        if haveget ==1 then
            self:upData();
        else
            self.Button_get:setBright(true);
            self.Button_get:setTouchEnabled(true);
        end
    else
        self.Button_get:setBright(false);
        self.Button_get:setTouchEnabled(false);
    end
end

function arena_activeItem:upData()
    self.Button_get:setEnabled(false);
    self.Image_get:setVisible(true);
end



function arena_activeItem:onButtonClick(sender, eventType)
    buttonClickScale(sender, eventType,0.8);
    if eventType == ccui.TouchEventType.ended then
        if self.delegate and self.delegate.getItemActive then
            self.delegate:getItemActive(self);
        end
    end
end

function arena_activeItem:onEnter()

end

function arena_activeItem:onExit()
    MGRCManager:releaseResources("arena_activeItem")
end

function arena_activeItem.create(delegate,widget)
    local layer = arena_activeItem:new()
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
