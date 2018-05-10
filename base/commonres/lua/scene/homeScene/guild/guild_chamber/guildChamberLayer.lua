-----------------------公会议会厅界面------------------------
require "guildChamberSet"
require "guildLogLayer"
require "guildMemberLayer"
require "guildApproveLayer"
require "guildNoticeLayer"
require "guildRecruitLayer"
require "guildInfoLayer"
require "mailLayer"

guildChamberLayer = class("guildChamberLayer", MGLayer)

local tag1={--会长，副会长
    [1]={name=MG_TEXT("guildChamberLayer_1"),id=1,type=1},--公会信息
    [2]={name=MG_TEXT("guildChamberLayer_2"),id=2,type=2},--公会成员
    [3]={name=MG_TEXT("guildChamberLayer_3"),id=3,type=3},--公会日志
    [4]={name=MG_TEXT("guildChamberLayer_4"),id=4,type=4},--公会招募
    [5]={name=MG_TEXT("guildChamberLayer_5"),id=5,type=5},--申请审批
    [6]={name=MG_TEXT("guildChamberLayer_6"),id=6,type=6},--通讯公告
}

local tag2={--成员
    [1]={name=MG_TEXT("guildChamberLayer_1"),id=1,type=1},--公会信息
    [2]={name=MG_TEXT("guildChamberLayer_2"),id=2,type=2},--公会成员
    [3]={name=MG_TEXT("guildChamberLayer_3"),id=3,type=3},--公会日志
    [4]={name=MG_TEXT("guildChamberLayer_6"),id=6,type=4},--通讯公告
}

function guildChamberLayer:ctor()
    self.curLayer = nil;
    self.curTag = 1;
    self.myPost = 0;--职位 固定 10会长 9副会长 8精英 0普通成员
    self.curLabel = "";
    self:init();
end

function guildChamberLayer:init()
    MGRCManager:cacheResource("guildChamberLayer", "guild_chamber_ui.png", "guild_chamber_ui.plist");
    local pWidget = MGRCManager:widgetFromJsonFile("guildChamberLayer","guild_hall_ui.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);

    self.pPanelTop = PanelTop.create(self)
    self.pPanelTop:setData("guild_chamber_title.png");
    self:addChild(self.pPanelTop,10);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:setAnchorPoint(cc.p(0.5, 0.5));
    CommonMethod:setFullBgScale(self.Panel_1);

    local Panel_2 = pWidget:getChildByName("Panel_2");
    local Panel_left = Panel_2:getChildByName("Panel_left");
    self.Panel_3 = Panel_left:getChildByName("Panel_3");

    self.Button_mail = self.Panel_3:getChildByName("Button_mail");
    self.Button_mail:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_set = self.Panel_3:getChildByName("Button_set");
    self.Button_set:addTouchEventListener(handler(self,self.onButtonClick));

    local Label_mail = self.Panel_3:getChildByName("Label_mail");
    Label_mail:setText(MG_TEXT_COCOS("guild_hall_ui_7"));

    local Label_set = self.Panel_3:getChildByName("Label_set");
    Label_set:setText(MG_TEXT_COCOS("guild_hall_ui_8"));

    self.Panel_btn = Panel_left:getChildByName("Panel_btn");
    self:updateItem(tag1);

end

function guildChamberLayer:setData()
    if self.myPost == 10 or self.myPost == 9 then
        self:updateItem(tag1);
        self.Panel_3:setVisible(true);
        self.Button_mail:setEnabled(true);
        self.Button_set:setEnabled(true);
    else
        self:updateItem(tag2);
        self.Panel_3:setVisible(false);
        self.Button_mail:setEnabled(false);
        self.Button_set:setEnabled(false);
    end
end

function guildChamberLayer:updateItem(tags)
    self.Panel_btn:removeAllChildren();
    self.posY = {};
    self.btns = {};
    for i=1,#tags do
        local item = self:createItem(tags[i]);
        local h=self.Panel_btn:getContentSize().height-item:getContentSize().height/2-(i-1)*item:getContentSize().height;
        item:setPosition(cc.p(self.Panel_btn:getContentSize().width/2,h));
        self.Panel_btn:addChild(item,1);
        table.insert(self.posY,item:getPositionY());
    end

    self.Image_select = cc.Sprite:createWithSpriteFrameName("com_page_select.png");
    self.Image_select:setPosition(self.btns[1].btn:getPosition());
    self.Panel_btn:addChild(self.Image_select);

    self.curLabel = self.btns[1].nameLabel;
    self.btns[1].nameLabel:setColor(cc.c3b(255, 255, 255));
    self:onButtonClick(self.btns[1].btn, ccui.TouchEventType.ended);
    
end

function guildChamberLayer:createItem(tag)
    local layout = ccui.Layout:create();
    layout:setAnchorPoint(cc.p(0.5,0.5));
    layout:setSize(cc.size(210,75));

    layout:setTouchEnabled(true);
    layout:addTouchEventListener(handler(self,self.onButtonClick));
    layout:setTag(tag.type);

    local lineImg = ccui.ImageView:create("com_left_line3.png", ccui.TextureResType.plistType);
    lineImg:setPosition(cc.p(layout:getContentSize().width/2, 0));
    lineImg:setScale9Enabled(true);
    lineImg:setCapInsets(cc.rect(5, 1, 1, 1));
    lineImg:setSize(cc.size(210, 3));
    layout:addChild(lineImg,1);

    local nameLabel = cc.Label:createWithTTF(tag.name,ttf_msyh,22);
    nameLabel:setColor(cc.c3b(130, 130, 111));
    nameLabel:setPosition(cc.p(layout:getContentSize().width/2, layout:getContentSize().height/2));
    layout:addChild(nameLabel);

    table.insert(self.btns,{btn=layout,nameLabel=nameLabel,id=tag.id});

    return layout;
end

function guildChamberLayer:onButtonClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_mail then--邮件
            local mailLayer = mailLayer.showBox(self);
        elseif sender == self.Button_set then--设置
            local guildChamberSet = guildChamberSet.showBox(self);
        else
            if self.curTag == sender:getTag() and self.curLayer then
                return;
            end
            if self.curLayer then
                self.curLayer:removeFromParent();
                self.curLayer = nil;
            end

            if self.btns[sender:getTag()].id == 1 then--公会信息
                self.curLayer = guildInfoLayer.create(self);
            elseif self.btns[sender:getTag()].id == 2 then--公会成员
                self.curLayer = guildMemberLayer.create(self);
            elseif self.btns[sender:getTag()].id == 3 then--公会日志
                self.curLayer = guildLogLayer.create(self);
            elseif self.btns[sender:getTag()].id == 4 then--公会招募
                self.curLayer = guildRecruitLayer.create(self);
                self.curLayer:setData(data);
            elseif self.btns[sender:getTag()].id == 5 then--申请审批
                self.curLayer = guildApproveLayer.create(self);
            elseif self.btns[sender:getTag()].id == 6 then--通讯公告
                self.curLayer = guildNoticeLayer.create(self);
            end
            self:addChild(self.curLayer,5);
            self.Image_select:setPositionY(self.posY[sender:getTag()]);
            self.curTag = sender:getTag();
            self.curLabel:setColor(cc.c3b(130, 130, 111));
            self.btns[sender:getTag()].nameLabel:setColor(cc.c3b(255, 255, 255));
            self.curLabel = self.btns[sender:getTag()].nameLabel;
        end
    end
end

function guildChamberLayer:setPost(post)
    self.myPost = post;
    self:setData();
end

function guildChamberLayer:getPost()
    return self.myPost;
end

function guildChamberLayer:back()
    self:removeFromParent();
end



function guildChamberLayer:onEnter()
    
end

function guildChamberLayer:onExit()
    MGRCManager:releaseResources("guildChamberLayer");
end

function guildChamberLayer.create(delegate,type)
    local layer = guildChamberLayer:new()
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

function guildChamberLayer.showBox(delegate,type)
    local layer = guildChamberLayer.create(delegate,type);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
