--------------------------解锁按钮-----------------------

local MainLineUnlock = class("MainLineUnlock", MGWidget)

function MainLineUnlock:init(delegate,widget)
    self.delegate=delegate;
    self:addChild(widget);
    self.pWidget = widget;

    local Panel_2 = self.pWidget:getChildByName("Panel_2");
    self:setContentSize(Panel_2:getContentSize());

    self.Panel_2 = Panel_2;
    self.Panel_2:setTouchEnabled(true);
    self.Panel_2:addTouchEventListener(handler(self,self.onButtonClick));

    self.Label_unlock = Panel_2:getChildByName("Label_unlock");
    self.Panel_3 = Panel_2:getChildByName("Panel_3");
    self.Panel_3:setVisible(false);
    self.Label_num = self.Panel_3:getChildByName("Label_num");
    self.Image_gold = self.Panel_3:getChildByName("Image_gold");
end

function MainLineUnlock:setData(data,unLockData,mapList)
    self.data = data;
    self.stage = unLockData.stage;
    self.mapList = mapList;

    local isUnlock = false;
    local cityName = "";
    for i=1,#self.stage do
        if tonumber(self.stage[i]) == self.data.first_s_id then
            isUnlock = true;
            break;
        end
    end

    for i=1,#self.mapList do
        if self.mapList[i].id == self.data.need_s_id then
            cityName = self.mapList[i].name;
            break;
        end
    end

    self.Label_unlock:setVisible(false);
    self.Panel_3:setVisible(false);
    if isUnlock == false then
        if 0 == tonumber(unLockData.new_stage_npc_is_conquer) then--1 0 是否攻克最新解锁城池
            self.Label_unlock:setVisible(true);
            self.Label_unlock:setText(string.format(MG_TEXT("ML_MainLineUnlock_1"),cityName));
        else
            if ME:Lv() < self.data.lv then
                self.Label_unlock:setVisible(true);
                self.Label_unlock:setText(string.format(MG_TEXT("ML_MainLineUnlock_2"),self.data.lv));
            else
                self.Label_unlock:setVisible(false);
                self.Panel_3:setVisible(true);
                self.Label_num:setText(tonumber(self.data.need[3]));

                local info = itemInfo(self.data.need[1],self.data.need[2]);
                if info then
                    self.Image_gold:loadTexture(info.samll_pic,ccui.TextureResType.plistType);
                end
            end
        end
    end         
end

function MainLineUnlock:onButtonClick(sender, eventType)
    -- buttonClickScale(sender, eventType);
    if eventType == ccui.TouchEventType.ended then
        if self.delegate and self.delegate.sendUnlockAreaReq then
            self.delegate:sendUnlockAreaReq(self.data.id);
        end
    end
end

function MainLineUnlock:onEnter()
    
end

function MainLineUnlock:onExit()
    MGRCManager:releaseResources("MainLineUnlock");
    if self.timer~=nil then
        self.timer:stopTimer();
    end
end

function MainLineUnlock.create(delegate,widget)
    local layer = MainLineUnlock:new()
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

return MainLineUnlock