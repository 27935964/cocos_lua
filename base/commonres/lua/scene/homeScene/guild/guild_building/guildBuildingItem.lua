--------------------------公会建设界面Item-----------------------

local guildBuildingItem = class("guildBuildingItem", MGWidget)

function guildBuildingItem:init(delegate,widget)
    self.delegate=delegate;
    self:addChild(widget);
    self.pWidget = widget;

    local Panel_2 = self.pWidget:getChildByName("Panel_2");
    self:setContentSize(Panel_2:getContentSize());

    self.Label_Type = Panel_2:getChildByName("Label_Type");
    self.Label_Feats_num = Panel_2:getChildByName("Label_Feats_number");
    self.Label_EXP_num = Panel_2:getChildByName("Label_EXP_number");
    self.Image_feats = Panel_2:getChildByName("Image_FeatsIcon");
    self.Image_exp = Panel_2:getChildByName("Image_EXPIcon"); 

    self.Button_Reward = Panel_2:getChildByName("Button_Reward");
    self.Button_Reward:addTouchEventListener(handler(self,self.onButtonClick));

    self.Image_Gold = self.Button_Reward:getChildByName("Image_Gold");
    self.Label_Number = self.Button_Reward:getChildByName("Label_Number");

end

function guildBuildingItem:setData(data)
    self.data = data;

    self.Label_Type:setText(self.data.name);

    self.Image_feats:loadTexture(itemPicName(self.data.reward[1].value1),ccui.TextureResType.plistType);
    self.Image_exp:loadTexture(itemPicName(self.data.reward[2].value1),ccui.TextureResType.plistType);
    self.Image_Gold:loadTexture(itemPicName(tonumber(self.data.need[1])),ccui.TextureResType.plistType);
    self.Label_Feats_num:setText(string.format("+%d",self.data.reward[1].value3));
    self.Label_EXP_num:setText(string.format("+%d",self.data.reward[2].value3));
    self.Label_Number:setText(tonumber(self.data.need[3]));
    
end

function guildBuildingItem:onButtonClick(sender, eventType)
    buttonClickScale(sender, eventType);

    if eventType == ccui.TouchEventType.ended then
        if self.delegate and self.delegate.sendReq then
            self.delegate:sendReq(self);
        end
    end
end

function guildBuildingItem:onEnter()
    
end

function guildBuildingItem:onExit()
    MGRCManager:releaseResources("guildBuildingItem");
end

function guildBuildingItem.create(delegate,widget)
    local layer = guildBuildingItem:new()
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

return guildBuildingItem