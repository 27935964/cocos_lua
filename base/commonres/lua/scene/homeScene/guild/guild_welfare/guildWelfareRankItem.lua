--------------------------公会------红包排行Item-----------------------

local guildWelfareRankItem = class("guildWelfareRankItem", MGWidget)

function guildWelfareRankItem:init(delegate,widget)
    self.delegate=delegate;
    self:addChild(widget);
    self.pWidget = widget;

    local Panel_2 = self.pWidget:getChildByName("Panel_2");
    self:setContentSize(Panel_2:getContentSize());
    
    self.Image_bg = Panel_2:getChildByName("Image_bg");
    self.Image_rank = Panel_2:getChildByName("Image_rank");
    self.Image_rank:setVisible(false);

    self.Label_rank = Panel_2:getChildByName("Label_rank");
    self.Label_name = Panel_2:getChildByName("Label_name");
    self.Label_num = Panel_2:getChildByName("Label_num");
    self.Label_diamond = Panel_2:getChildByName("Label_diamond");
    self.Label_gold = Panel_2:getChildByName("Label_gold");

end

function guildWelfareRankItem:setData(data)
    self.data = data;

    if tonumber(self.data.rank) <= 3 then
        self.Image_rank:setVisible(true);
        self.Label_rank:setVisible(false);
        self.Image_rank:loadTexture(string.format("com_rank_cup_%d.png",tonumber(self.data.rank)),ccui.TextureResType.plistType);
    end

    if math.mod(tonumber(self.data.rank),2) == 0 then
        self.Image_bg:setVisible(true);
    elseif math.mod(tonumber(self.data.rank),2) == 1 then
        self.Image_bg:setVisible(false);
    end
    
    self.Label_rank:setText(tonumber(self.data.rank));
    self.Label_name:setText(unicode_to_utf8(self.data.name));
    self.Label_num:setText(tonumber(self.data.red_num));
    self.Label_diamond:setText(tonumber(self.data.gold));
    self.Label_gold:setText(tonumber(self.data.coin));
end

function guildWelfareRankItem:onEnter()
    
end

function guildWelfareRankItem:onExit()
    MGRCManager:releaseResources("guildWelfareRankItem");
end

function guildWelfareRankItem.create(delegate,widget)
    local layer = guildWelfareRankItem:new()
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

return guildWelfareRankItem