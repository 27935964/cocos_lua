require "Item"

local taskRewardItem = require "taskRewardItem";
taskItem = class("taskItem",function()  
    return ccui.Layout:create(); 
end)

function taskItem:ctor()
    self.btnType = 1;--1前往，2领取
end

function taskItem:init()
    self:setSize(cc.size(972, 190));
    self:setAnchorPoint(cc.p(0.5,0.5));

    --头像
    self.bgSpr = cc.Sprite:createWithSpriteFrameName("task_item_bg.png");
    self.bgSpr:setPosition(cc.p(self:getContentSize().width/2, self:getContentSize().height/2));
    self:addChild(self.bgSpr);

    self.titleLabel = cc.Label:createWithTTF("", ttf_msyh, 22);
    self.titleLabel:setAnchorPoint(cc.p(0,0.5));
    self.titleLabel:setPosition(cc.p(24, 154));
    self:addChild(self.titleLabel);

    self.stateLabel = cc.Label:createWithTTF("", ttf_msyh, 22);
    self.stateLabel:setAnchorPoint(cc.p(1,0.5));
    self.stateLabel:setPosition(cc.p(940, 154));
    self:addChild(self.stateLabel);

    require "userHead";
    self.itemHead = userHead.create(self);
    self.itemHead:setAnchorPoint(cc.p(0, 0));
    self.itemHead:setPosition(cc.p(13,15));
    self:addChild(self.itemHead);

    self.descLabel = MGColorLabel:label();
    self.descLabel:setAnchorPoint(cc.p(0, 0.5));
    self.descLabel:setPosition(cc.p(150, 100));
    self:addChild(self.descLabel);

    local Label_tip1 = cc.Label:createWithTTF("奖励", ttf_msyh, 22);
    Label_tip1:setAnchorPoint(cc.p(0,0.5));
    Label_tip1:setPosition(cc.p(150, 47));
    Label_tip1:setColor(cc.c3b(115,0,2));
    self:addChild(Label_tip1);

    self.listView = ccui.ListView:create();
    self.listView:setDirection(ccui.ScrollViewDir.horizontal);
    self.listView:setBounceEnabled(false);
    self.listView:setAnchorPoint(cc.p(0,0));
    self.listView:setSize(cc.size(500, 65));
    self.listView:setScrollBarVisible(false);--true添加滚动条
    self.listView:setPosition(cc.p(217,14));
    -- self.listView:setItemsMargin(-20);
    self:addChild(self.listView);
    -- self.listView:setBackGroundColorType(1);
    -- self.listView:setBackGroundColor(cc.c3b(0,255,250));

    self.getBtn = ccui.ImageView:create("com_task_button_1.png", ccui.TextureResType.plistType);
    self.getBtn:setPosition(cc.p(860, 68));
    self:addChild(self.getBtn,1);
    -- self.getBtn:setEnabled(true);
    self.getBtn:setTouchEnabled(true);
    self.getBtn:addTouchEventListener(handler(self,self.onButtonClick));

    self.btnName = cc.Label:createWithTTF("", ttf_msyh, 25);
    self.btnName:setPosition(cc.p(self.getBtn:getContentSize().width/2, self.getBtn:getContentSize().height/2));
    self.btnName:enableShadow(cc.c4b(0,   0,   0, 191), cc.size(2, -2),2);
    self.btnName:setColor(cc.c3b(255,243,211));
    self.getBtn:addChild(self.btnName);

    -- self.helpBtn = ccui.ImageView:create("com_help_btn.png", ccui.TextureResType.plistType);
    -- self.helpBtn:setPosition(cc.p(860, 68));
    -- self:addChild(self.helpBtn,1);
    -- -- self.helpBtn:setEnabled(false);
    -- self.helpBtn:addTouchEventListener(handler(self,self.onButtonClick));

    -- self.Label_tip2 = cc.Label:createWithTTF("任务指引", ttf_msyh, 22);
    -- self.Label_tip2:setAnchorPoint(cc.p(0,0.5));
    -- self.Label_tip2:setPosition(cc.p(845, 68));
    -- self.Label_tip2:setColor(cc.c3b(115,0,2));
    -- self:addChild(self.Label_tip2,2);
end

function taskItem:setData(data,taskData)
    self.data = data;
    self.taskData = taskData;
    
    self.titleLabel:setString(self.taskData.name);
    self.itemHead:setHeadData(self.taskData.pic);
    self.descLabel:clear();
    self.descLabel:appendStringAutoWrap(self.taskData.des,16,1,cc.c3b(107,75,36),22);

    local completion_status = spliteStr(self.data.completion_status,':');
    if #completion_status >= 2 then
        self.stateLabel:setString(string.format("%s/%s",completion_status[1],completion_status[2]));
    end

    if 0 == tonumber(self.data.status) then--状态(0未完成,1已完成,2已领奖)
        self.btnName:setString(MG_TEXT("go"));
        self.btnType = 1;
        if #self.taskData.get_go <= 0 then
            self.getBtn:setEnabled(false);
        end
    elseif 1 == tonumber(self.data.status) then
        self.stateLabel:setString(MG_TEXT("complete"));
        self.btnName:setString(MG_TEXT("receive"));
        self.btnType = 2;
    elseif 2 == tonumber(self.data.status) then
        self.stateLabel:setString(MG_TEXT("complete"));
        self.getBtn:setTouchEnabled(false);
        self.getBtn:setVisible(true);
        self.btnName:setString(MG_TEXT("Get"));
        self.getBtn:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
        self.btnName:setColor(cc.c3b(127,127,127));
    end

    self.listView:removeAllItems();
    for i=1,#self.taskData.reward do
        local item = taskRewardItem.new(self);
        item:setData(self.taskData.reward[i]);
        self.listView:pushBackCustomItem(item);
    end
    
end

function taskItem:onButtonClick(sender, eventType)
    buttonClickScale(sender, eventType);
    if eventType == ccui.TouchEventType.ended then
        if sender == self.getBtn then
            if self.btnType == 1 then
                print("1111111111111qianwang")
            elseif self.btnType == 2 then
                print("1111111111111lingqu")
                if self.delegate and self.delegate.sendReq then--领取
                    self.delegate:sendReq(tonumber(self.data.e_id));
                end
            end
        end
    end
end

function taskItem:onEnter()

end

function taskItem:onExit()
    MGRCManager:releaseResources("taskItem");
end

function taskItem.create(delegate)
    local layer = taskItem:new()
    layer.delegate = delegate;
    layer:init()
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
