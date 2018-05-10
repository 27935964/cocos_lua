--------------------------跳转的Item-----------------------

local jumpItem = class("jumpItem", MGWidget)

function jumpItem:init(delegate,widget)
	self.delegate=delegate;
    self:addChild(widget);
    self.pWidget = widget;

    local Panel_1 = self.pWidget:getChildByName("Panel_1");
    self:setContentSize(Panel_1:getContentSize());
    self.Panel = Panel_1;
    self.Panel:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_go = Panel_1:getChildByName("Button_go");
    self.Button_go:addTouchEventListener(handler(self,self.onButtonClick));

    self.Image_bg= Panel_1:getChildByName("Image_bg");
    self.Label_tip= Panel_1:getChildByName("Label_tip");
end

function jumpItem:onButtonClick(sender, eventType)
    if sender == self.Button_go then
        buttonClickScale(sender, eventType);
    end

    if eventType == ccui.TouchEventType.ended then
        print("========================跳转========================");
    end
end

function jumpItem:setData(id)
	self.id = id;

    local DBData = LUADB.select(string.format("select * from source where id=%d",id), "id:name:des:pic");
    if DBData then
        self.Image_bg:loadTexture(DBData.info.pic..".png",ccui.TextureResType.plistType);
        self.Label_tip:setText(DBData.info.des);
    end
end

function jumpItem:onEnter()
    
end

function jumpItem:onExit()
    MGRCManager:releaseResources("jumpItem")
end

function jumpItem.create(delegate,widget)
    local layer = jumpItem:new()
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

return jumpItem