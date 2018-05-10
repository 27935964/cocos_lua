-----------------------将领属性界面------------------------
require "arena_awardItem"

arena_award = class("arena_award", MGLayer)

function arena_award:ctor()
    self:init();
end

function arena_award:init()
    local pWidget = MGRCManager:widgetFromJsonFile("arena_award","arena_ui_8.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);--设置描边或者阴影
    
    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));
    local Panel_2 = pWidget:getChildByName("Panel_2");
    local Image_arena_award = Panel_2:getChildByName("Image_arena_award");
    self.Button_close = Panel_2:getChildByName("Button_close");
    self.Button_close:addTouchEventListener(handler(self,self.onButtonClick));


    local Panel_mid = Panel_2:getChildByName("Panel_mid");
    local Image_rank = Panel_mid:getChildByName("Image_rank");
    self.Label_rank = Image_rank:getChildByName("Label_rank");
    local Label_rank_award = Image_rank:getChildByName("Label_rank_award");
    Label_rank_award:setText(MG_TEXT_COCOS("arena_ui_21"));
    self.Label_coin = Image_rank:getChildByName("Label_coin");
    self.Label_gold = Image_rank:getChildByName("Label_gold");
    self.list = Panel_mid:getChildByName("ListView");

end


function arena_award:setData(data,ranking)
    self.list:removeAllItems();
    self.list:setItemsMargin(5);
    for i=1,#data do
        local arena_awardItem = arena_awardItem.create(self);
        data[i].min_rank = tonumber(data[i].min_rank)
        data[i].max_rank = tonumber(data[i].max_rank)
        arena_awardItem:setData(data[i]);
        self.list:pushBackCustomItem(arena_awardItem);

        if ranking>=data[i].min_rank and ranking<=data[i].max_rank then
            self.Label_rank:setText(""..ranking);
            local  reward = getneedlist(data[i].reward);
            self.Label_coin:setText(""..reward[1].num);
            self.Label_gold:setText(""..reward[2].num);
        end
    end
end

function arena_award:onButtonClick(sender, eventType)
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


function arena_award:onEnter()

end

function arena_award:onExit()
    MGRCManager:releaseResources("arena_award");
end

function arena_award.create(delegate)
    local layer = arena_award:new()
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


