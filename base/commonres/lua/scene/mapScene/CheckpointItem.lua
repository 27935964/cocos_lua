require "CheckpointHeadItem"

CheckpointItem = class("CheckpointItem", MGImageView)

function CheckpointItem:ctor()
    self.c_id = 0;
    self.type = 0;
end

function CheckpointItem:init(delegate)
	self.delegate = delegate
    local pWidget = MGRCManager:widgetFromJsonFile("CheckpointItem","checkpoint_item_ui.ExportJson");
    pWidget:setAnchorPoint(cc.p(0.5,0.5));
    self:addChild(pWidget);

    local Panel_2 = pWidget:getChildByName("Panel_2");
    Panel_2:setTouchEnabled(true);
    Panel_2:addTouchEventListener(handler(self,self.onButtonClick));

    self.Image_city = Panel_2:getChildByName("Image_city");
    local name = Panel_2:getChildByName("Label_name");
    name:setVisible(false);
    self.Label_name = cc.Label:createWithTTF("",ttf_msyh,22);
    -- self.Label_name:setAlignment(cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_TOP);
    -- self.Label_name:setDimensions(360, 0);
    -- self.Label_name:setAnchorPoint(cc.p(0.5, 1));
    self.Label_name:setPosition(name:getPosition());
    Panel_2:addChild(self.Label_name);
    self.Label_name:enableShadow(cc.c4b(0,   0,   0, 191), cc.size(2, -2),2);--投影

    self.Image_bg = Panel_2:getChildByName("Image_bg");
    self.Image_bg:setVisible(false);

    self.head = CheckpointHeadItem.create(self,"checkpoint_head_prismatic.png");
    self.head:setPosition(self.Image_bg:getPosition());
    self.head:setVisible(false);
    Panel_2:addChild(self.head);

    local actionBy = cc.MoveBy:create(1.5, cc.p(0, 15));
    local actionByBack = actionBy:reverse();
    self.head:runAction(cc.RepeatForever:create(cc.Sequence:create(actionBy, actionByBack)));

    self.stars = {};
    for i=1,3 do
        local Image_star = Panel_2:getChildByName("Image_star"..i);
        Image_star:setVisible(false);
        table.insert(self.stars,Image_star);
    end
end

function CheckpointItem:setData(checkpointData,c_id,data)
    self.data = data;
    self.checkpointData = checkpointData;
    self.c_id = c_id;

    self.Image_city:loadTexture(self.checkpointData.pic,ccui.TextureResType.plistType);
    self.Label_name:setString(string.format("%d.%s",self.c_id,self.checkpointData.name));

    self.head:setData(checkpointData,c_id,data)
    if 0 ~= tonumber(self.checkpointData.npc_id) then--是否守关大将
        self.Label_name:setColor(cc.c3b(255,0,0));
        self.head:setVisible(true);
    else
        if 0 ~= self.checkpointData.reward_limit then--0表示没次数限制，有次数限制是展示资源图标
            if 0 ~= self.checkpointData.reward_flip_show and #self.checkpointData.reward_flip_show >= 1 then
                self.head:setVisible(true);
            else
                if 0 ~= self.checkpointData.reward_show and #self.checkpointData.reward_show >= 1 then
                    self.head:setVisible(true);
                end
            end
        end
    end

    for i=1,#self.data.stage_c_info do
        if c_id == tonumber(self.data.stage_c_info[i].c_id) then
            for j=1,#self.stars do
                if j <= tonumber(self.data.stage_c_info[i].star) then
                    self.stars[j]:setVisible(true);
                else
                    self.stars[j]:setVisible(false);
                end
            end
            break;
        end
    end
end

function CheckpointItem:ItemSelect()
    if self.delegate and self.delegate.addCityInfoLayer then
        self.delegate:addCityInfoLayer(self.c_id);
    end
end

function CheckpointItem:onButtonClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
       self:ItemSelect();
    end
end

function CheckpointItem:remove()
    self:removeFromParent();
end

function CheckpointItem:onEnter()

end

function CheckpointItem:onExit()
	MGRCManager:releaseResources("CheckpointItem")
end

function CheckpointItem.create(delegate)
	local layer = CheckpointItem:new()
    layer:init(delegate)
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
