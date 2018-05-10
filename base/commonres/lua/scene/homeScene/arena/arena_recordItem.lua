require "utf8"
arena_recordItem = class("arena_recordItem", function()
    return ccui.Layout:create();
end)

function arena_recordItem:ctor()

end

function arena_recordItem:init(delegate,widget)
    self.delegate=delegate;
    self:addChild(widget);
    self.pWidget = widget;

    local Panel_1 = self.pWidget:getChildByName("Panel_1");
    self:setSize(Panel_1:getSize())

    local Image_bg = Panel_1:getChildByName("Image_bg");
    self.Label_name = Image_bg:getChildByName("Label_name");
    self.Label_lv = Image_bg:getChildByName("Label_lv");
    self.Label_rank = Image_bg:getChildByName("Label_rank");
    self.Label_day = Image_bg:getChildByName("Label_day");
    self.Label_time = Image_bg:getChildByName("Label_time");
    self.Image_up = Image_bg:getChildByName("Image_up");
    self.Image_ret = Image_bg:getChildByName("Image_ret");
    local Label_rank_name = Image_bg:getChildByName("Label_rank_name");
    Label_rank_name:setText(MG_TEXT("rank"));
    self.Button_play= Image_bg:getChildByName("Button_play");
    self.Button_play:addTouchEventListener(handler(self,self.onButtonClick));
end

function arena_recordItem:setData(data)
    self.data = data;
    data.name = unicode_to_utf8(data.name);
    self.Label_name:setText(data.name);
    self.Label_lv:setText("Lv."..data.lv);
    self.Label_rank:setText(""..data.change_rank);

    if data.result == 1 then
        self.Image_ret:loadTexture("arena_win.png", ccui.TextureResType.plistType)
        self.Image_up:loadTexture("arena_up.png", ccui.TextureResType.plistType)
    else
        self.Image_ret:loadTexture("arena_fail.png", ccui.TextureResType.plistType)
        self.Image_up:loadTexture("arena_down.png", ccui.TextureResType.plistType)
    end


    self.Label_day:setText(MGDataHelper:secToMonDay(data.time));
    self.Label_time:setText(MGDataHelper:secToTimeStringNoSec(data.time));
end


function arena_recordItem:onButtonClick(sender, eventType)
    buttonClickScale(sender, eventType);
    if eventType == ccui.TouchEventType.ended then
        if self.delegate and self.delegate.recordItemPlay then
            self.delegate:recordItemPlay(self.data.report);
        end
    end
end

function arena_recordItem:onEnter()

end

function arena_recordItem:onExit()
    MGRCManager:releaseResources("arena_recordItem")
end

function arena_recordItem.create(delegate,widget)
    local layer = arena_recordItem:new()
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
