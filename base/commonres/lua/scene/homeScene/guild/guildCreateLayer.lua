-----------------------公会创建界面------------------------
require "guildCreateNextLayer"

guildCreateLayer = class("guildCreateLayer", MGLayer)

function guildCreateLayer:ctor()
    self.flagId = 0;
    self.totemId = 0;
    self.type = 1;
    self:init();
end

function guildCreateLayer:init()
    local pWidget = MGRCManager:widgetFromJsonFile("guildCreateLayer","guild_create_ui.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:setAnchorPoint(cc.p(0.5, 0.5));
    CommonMethod:setFullBgScale(self.Panel_1);
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));

    local Panel_2 = pWidget:getChildByName("Panel_2");
    self.Image_title = Panel_2:getChildByName("Image_title");

    self.Button_close = Panel_2:getChildByName("Button_close");
    self.Button_close:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_next = Panel_2:getChildByName("Button_next");
    self.Button_next:addTouchEventListener(handler(self,self.onButtonClick));

    local Panel_3 = Panel_2:getChildByName("Panel_3");
    self.flags = {};
    for i=1,5 do
        local Image_flag = Panel_3:getChildByName("Image_flag"..i);
        Image_flag:setTag(i);
        Image_flag:setTouchEnabled(true);
        Image_flag:addTouchEventListener(handler(self,self.onFlagButtonClick));
        table.insert(self.flags,Image_flag);
    end

    self.totems = {};
    for i=1,5 do
        local Image_totem = Panel_3:getChildByName("Image_totem"..i);
        Image_totem:setTag(i);
        Image_totem:setTouchEnabled(true);
        Image_totem:addTouchEventListener(handler(self,self.onTotemButtonClick));
        table.insert(self.totems,Image_totem);
    end

    self.Image_selected1 = Panel_3:getChildByName("Image_selected1");
    self.Image_selected2 = Panel_3:getChildByName("Image_selected2");

    self.Label_next = self.Button_next:getChildByName("Label_next");
    self.Label_next:setText(MG_TEXT("guildLayer_12"));

    self.flagId = math.random(1,5);
    self.totemId = math.random(1,5);
    self.Image_selected1:setPositionX(self.flags[self.flagId]:getPositionX());
    self.Image_selected2:setPosition(self.totems[self.totemId]:getPosition());
end

function guildCreateLayer:setData(type)
    self.type = type;
    if self.type == 1 then
        self.Image_title:loadTexture("guild_create_title.png",ccui.TextureResType.plistType);
        self.Label_next:setText(MG_TEXT("guildLayer_12"));
    elseif self.type == 2 then
        self.Image_title:loadTexture("guild_flag_title.png",ccui.TextureResType.plistType);
        self.Label_next:setText(MG_TEXT("Ok1"));
    end
end

function guildCreateLayer:onFlagButtonClick(sender, eventType)
    self.Image_selected1:setPositionX(sender:getPositionX());
    if eventType == ccui.TouchEventType.ended then
        self.flagId = sender:getTag();
    end
end

function guildCreateLayer:onTotemButtonClick(sender, eventType)
    self.Image_selected2:setPosition(sender:getPosition());
    if eventType == ccui.TouchEventType.ended then
        self.totemId = sender:getTag();
    end
end

function guildCreateLayer:onButtonClick(sender, eventType)
    if sender ~= self.Panel_1 then
        buttonClickScale(sender, eventType);
    end

    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_next then
            if self.type == 1 then
                local guildCreateNextLayer = guildCreateNextLayer.showBox(self,self.scenetype);
                guildCreateNextLayer:setData(self.flagId,self.totemId);
            elseif self.type == 2 then
                self:sendReq();
            end
        else
            self:removeFromParent();
        end
    end
end

function guildCreateLayer:remove()
    if self.delegate and self.delegate.remove then
        self.delegate:remove();
    end
    self:removeFromParent();
end

function guildCreateLayer:onReciveData(MsgID, NetData)
    print("guildCreateLayer onReciveData MsgID:"..MsgID)
    if MsgID == Post_changeCheckType then
        local ackData = NetData
        if ackData.state == 1 then
            MGMessageTip:showFailedMessage(MG_TEXT("guildLayer_13"));
            if self.delegate and self.delegate.updateFlag then
                self.delegate:updateFlag(self.flagId,self.totemId);
            end
        else
            NetHandler:showFailedMessage(ackData);
        end
    end
end

function guildCreateLayer:sendReq()
    local str = string.format("&flag=%d&flag_bg=%d",self.flagId,self.totemId);
    NetHandler:sendData(Post_changeCheckType, str);
end

function guildCreateLayer:pushAck()
    NetHandler:addAckCode(self,Post_changeCheckType);
end

function guildCreateLayer:popAck()
    NetHandler:delAckCode(self,Post_changeCheckType);
end

function guildCreateLayer:onEnter()
    self:pushAck();
end

function guildCreateLayer:onExit()
    self:popAck();
    MGRCManager:releaseResources("guildCreateLayer");
end

function guildCreateLayer.create(delegate,type)
    local layer = guildCreateLayer:new()
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

function guildCreateLayer.showBox(delegate,type)
    local layer = guildCreateLayer.create(delegate,type);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
