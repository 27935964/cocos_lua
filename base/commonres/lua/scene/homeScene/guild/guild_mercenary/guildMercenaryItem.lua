--------------------------公会佣兵营Item-----------------------

local guildMercenaryItem = class("guildMercenaryItem", MGWidget)

function guildMercenaryItem:init(delegate,widget)
    self.delegate=delegate;
    self:addChild(widget);
    self.pWidget = widget;

    self.timer = CCTimer:new();
    self.isStationed = false;
    self.timeNum = nil;

    local Panel_2 = self.pWidget:getChildByName("Panel_2");
    self:setContentSize(Panel_2:getContentSize());

    self.Label_name = Panel_2:getChildByName("Label_name");
    self.Label_name:setText(MG_TEXT("guildMercenaryItem_1"));

    self.Image_add = Panel_2:getChildByName("Image_add");
    self.Image_add:setVisible(false);

    self.Image_lock = Panel_2:getChildByName("Image_lock");
    self.Image_lock:setVisible(false);

    self.Image_headbox = Panel_2:getChildByName("Image_headbox");
    self.Image_headbox:setTouchEnabled(true);
    self.Image_headbox:addTouchEventListener(handler(self,self.onButtonClick));
    
    local Image_bg = Panel_2:getChildByName("Image_bg");
    local HeroCircleHead=require "HeroCircleHead";
    self.circleHead=HeroCircleHead.new("guild_mercenary_head_bg.png",0.85);
    self.circleHead:setPosition(cc.p(Image_bg:getContentSize().width/2,Image_bg:getContentSize().height/2));
    Image_bg:addChild(self.circleHead);

    self.Label_tip = Panel_2:getChildByName("Label_tip");
    self.Label_tip:setVisible(false);

    self.Button_delete = Panel_2:getChildByName("Button_delete");
    self.Button_delete:addTouchEventListener(handler(self,self.onButtonClick));

    self.Panel_3 = Panel_2:getChildByName("Panel_3");
    self.Panel_3:setTouchEnabled(false);
    self.Panel_3:addTouchEventListener(handler(self,self.onButtonClick));

    self.Label_revenue_num = self.Panel_3:getChildByName("Label_revenue_num");
    self.Label_time_num = self.Panel_3:getChildByName("Label_time_num");
    self.Label_hire_num = self.Panel_3:getChildByName("Label_hire_num");
    self.Label_num = self.Panel_3:getChildByName("Label_num");

    local Label_revenue = self.Panel_3:getChildByName("Label_revenue");
    Label_revenue:setText(MG_TEXT_COCOS("guild_mercenary_item_ui_1"));

    local Label_times = self.Panel_3:getChildByName("Label_times");
    Label_times:setText(MG_TEXT_COCOS("guild_mercenary_item_ui_2"));

    local Label_hire = self.Panel_3:getChildByName("Label_hire");
    Label_hire:setText(MG_TEXT_COCOS("guild_mercenary_item_ui_3"));

    local Label_hire_time = self.Panel_3:getChildByName("Label_hire_time");
    Label_hire_time:setText(MG_TEXT_COCOS("guild_mercenary_item_ui_4"));

end

function guildMercenaryItem:setData(data,mercenary,index)
    self.data = data;
    self.mercenaryData = mercenary.union_mercenary[index];
    self.index = index; 
    
    self.Image_add:setVisible(false);
    self.Image_lock:setVisible(false);
    self.Panel_3:setVisible(false);
    self.Label_tip:setVisible(false);
    self.Button_delete:setEnabled(false);
    self.isStationed = false;
    if ME:Lv() >= self.mercenaryData.value2 then--已开放
        self.Image_add:setVisible(true);
        self.Label_tip:setVisible(true);
        self.Label_tip:setText(MG_TEXT("guildMercenaryItem_2"));
        self.Label_tip:setColor(cc.c3b(255,228,0));
        for i=1,#self.data.mercenary do
            if index == tonumber(self.data.mercenary[i].id) then--有驻扎佣兵
                self.Panel_3:setVisible(true);
                self.Panel_3:setTouchEnabled(true);
                self.Image_add:setVisible(false);
                self.Button_delete:setEnabled(true);
                self.Label_tip:setVisible(false);
                self.isStationed = true;
                local gm = GENERAL:getAllGeneralModel(self.data.mercenary[i].g_id);
                if gm then
                    self.circleHead:setHeroFace(gm:bust());
                end

                self.Label_revenue_num:setText(tonumber(self.data.mercenary[i].station_gold));
                self.Label_hire_num:setText(tonumber(self.data.mercenary[i].hire_gold));
                self.Label_num:setText(tonumber(self.data.mercenary[i].num));

                local systemTime = UserData:instance():getServerTime();
                self.timeNum = tonumber(self.data.mercenary[i].get_time)-systemTime;
                if self.timeNum <= 0 then
                    self.timeNum = 0;
                end
                local time = MGDataHelper:secToString(self.timeNum);
                self.Label_time_num:setText(time);
                self.timer:startTimer(1000,handler(self,self.updateTime),false);--每秒回调一次
                break;
            end
        end
    else
        self.Image_lock:setVisible(true);
        self.Label_tip:setVisible(true);
        self.Label_tip:setText(string.format(MG_TEXT("guildMercenaryItem_3"),self.mercenaryData.value2));
        self.Label_tip:setColor(cc.c3b(255,0,0));
    end
end

function guildMercenaryItem:updateTime()
    if self.timeNum ~= nil and self.timeNum > 0 then
        self.timeNum = self.timeNum-1;
        local time =MGDataHelper:secToString(self.timeNum);
        self.Label_time_num:setText(time);
    else
        if self.timer~=nil then
            self.timer:stopTimer();
        end
    end
end

function guildMercenaryItem:onButtonClick(sender, eventType)
    if sender ~= self.Image_headbox and sender ~= self.Panel_3 then
        buttonClickScale(sender, eventType);
    end

    if eventType == ccui.TouchEventType.ended then
        if sender == self.Image_headbox then
            if ME:Lv() >= self.mercenaryData.value2 then--已开放
                if self.delegate and self.delegate.addGuildStationedLayer then
                    self.delegate:addGuildStationedLayer(self);
                end
            else
                MGMessageTip:showFailedMessage(MG_TEXT("heroAttLayer_9"));
            end
        elseif sender == self.Button_delete then
            if self.delegate and self.delegate.sendCloseStationReq then
                self.delegate:sendCloseStationReq(self.index);
            end
        elseif sender == self.Panel_3 then
            if self.timeNum <= 0 then
                if self.delegate and self.delegate.sendGetRewardReq then
                    self.delegate:sendGetRewardReq(self.index);
                    self.Panel_3:setTouchEnabled(false);
                end
            end
        end
    end
end

function guildMercenaryItem:onEnter()
    
end

function guildMercenaryItem:onExit()
    MGRCManager:releaseResources("guildMercenaryItem");
    if self.timer~=nil then
        self.timer:stopTimer();
    end
end

function guildMercenaryItem.create(delegate,widget)
    local layer = guildMercenaryItem:new()
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

return guildMercenaryItem