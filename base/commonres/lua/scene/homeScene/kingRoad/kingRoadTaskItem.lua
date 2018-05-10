--------------------------君王之路任务Item-----------------------

local kingRoadTaskItem = class("kingRoadTaskItem", MGWidget);
local taskRewardItem = require "taskRewardItem";

function kingRoadTaskItem:init(delegate,widget)
    self.delegate=delegate;
    self:addChild(widget);
    self.pWidget = widget;

    local Panel_2 = self.pWidget:getChildByName("Panel_2");
    self:setContentSize(Panel_2:getContentSize());

    self.Label_Title = Panel_2:getChildByName("Label_Title");
    self.Label_Schedule = Panel_2:getChildByName("Label_Schedule");

    self.Label_Requirements = Panel_2:getChildByName("Label_Requirements");
    self.Label_Requirements:setVisible(false);
    self.descLabel = MGColorLabel:label();
    self.descLabel:setAnchorPoint(cc.p(0, 0.5));
    self.descLabel:setPosition(self.Label_Requirements:getPosition());
    Panel_2:addChild(self.descLabel);

    self.Image_Receive = Panel_2:getChildByName("Image_Receive");--领取
    self.Image_Receive:setTouchEnabled(true);
    self.Image_Receive:addTouchEventListener(handler(self,self.onButtonClick));
    self.oldHeadProgram = self.Image_Receive:getSprit():getShaderProgram();

    self.Label_Receive = self.Image_Receive:getChildByName("Label_Receive");
    self.Label_Receive:setText(MG_TEXT("get"));
    
    local Panel_HeadPortrait = Panel_2:getChildByName("Panel_HeadPortrait");
    require "userHead";
    self.itemHead = userHead.create(self);
    self.itemHead:setPosition(cc.p(Panel_HeadPortrait:getContentSize().width/2,Panel_HeadPortrait:getContentSize().height/2));
    Panel_HeadPortrait:addChild(self.itemHead);

    self.ListView_Reward = Panel_2:getChildByName("ListView_Reward");
    self.ListView_Reward:setScrollBarVisible(false);

    local Label_Reward = Panel_2:getChildByName("Label_Reward");
    Label_Reward:setText(MG_TEXT_COCOS("TheRoadOfKings_Task_Ui_1"));

end

function kingRoadTaskItem:setData(achData)
    self.achData = achData;

    self.Label_Title:setText(self.achData.name);--utf8_to_unicode
    self.itemHead:setHeadData(self.achData.pic);
    self.descLabel:clear();
    self.descLabel:appendStringAutoWrap(self.achData.des,16,1,cc.c3b(107,075,036),22);

    self:createItem();

    self.Image_Receive:loadTexture("com_task_button_2.png",ccui.TextureResType.plistType);
    self.Label_Receive:setText(MG_TEXT("go"));
    self.Image_Receive:getSprit():setShaderProgram(self.oldHeadProgram);
    if 1 == tonumber(self.achData.status) then--状态(0未完成,1完成,2已领取奖励)
        self.Image_Receive:loadTexture("com_task_button_1.png",ccui.TextureResType.plistType);
        self.Label_Receive:setText(MG_TEXT("get"));
    elseif 2 == tonumber(self.achData.status) then
        self.Image_Receive:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
        self.Label_Receive:setText(MG_TEXT("complete"));
        self.Image_Receive:setTouchEnabled(false);
    end

    self:setStatus();
end

function kingRoadTaskItem:createItem()
    self.ListView_Reward:removeAllItems();
    local totalNum = #self.achData.reward;
    if totalNum == 0 then
        return;
    end

    local itemIndex = 1;
    local function loadEachItem(dt)
        if itemIndex > totalNum then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
        else
            local item = taskRewardItem.new(self);
            item:setData(self.achData.reward[itemIndex]);
            self.ListView_Reward:pushBackCustomItem(item);

            self.ListView_Reward:setItemsMargin(5);
            itemIndex = itemIndex+1;
        end
    end

    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
    end
    self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(loadEachItem, 0.001, false);
end

function kingRoadTaskItem:setStatus()
    local num = 0;
    local totalNum = 0;
    local str_list = spliteStr(self.achData.completion_status,':');
    if tonumber(self.achData.status) == 0 then
        if tonumber(self.achData.type) == 1 then--击败废庙的守关大将
            if tonumber(self.achData.status) == 1 then
                num = tonumber(self.achData.max_num);
                totalNum = tonumber(self.achData.max_num);
            end
        else
            num = tonumber(str_list[1]);
            totalNum = tonumber(str_list[2]);
        end
    else
        num = tonumber(self.achData.max_num);
        totalNum = tonumber(self.achData.max_num);
    end
    self.Label_Schedule:setText(string.format("%d/%d",num,totalNum));
end

function kingRoadTaskItem:onButtonClick(sender, eventType)
    buttonClickScale(sender, eventType);
    if eventType == ccui.TouchEventType.ended then
        if sender == self.Image_Receive then
            if 0 == tonumber(self.achData.status) then--状态(0未完成,1完成,2已领取奖励)
                print(">>>>>>>>>>>>前往>>>>>>>>>>>>>")
                
            elseif 1 == tonumber(self.achData.status) then
                if self.delegate and self.delegate.sendReqGetReward then
                    self.delegate:sendReqGetReward(tonumber(self.achData.a_id));
                end
            end
        end
    end
end

function kingRoadTaskItem:onEnter()
    
end

function kingRoadTaskItem:onExit()
    MGRCManager:releaseResources("kingRoadTaskItem");
    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
    end
end

function kingRoadTaskItem.create(delegate,widget)
    local layer = kingRoadTaskItem:new()
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

return kingRoadTaskItem