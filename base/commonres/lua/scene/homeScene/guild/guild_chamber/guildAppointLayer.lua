-----------------------公会议会厅--任命界面------------------------
require "userHead"
require "MessageTip"

guildAppointLayer = class("guildAppointLayer", MGLayer)

function guildAppointLayer:ctor()
    self.descLabel = "";
    self.btns = {};
    self.myPost = 0;
    self.post = 0;

    self:init();
end

function guildAppointLayer:init()
    local pWidget = MGRCManager:widgetFromJsonFile("guildAppointLayer","guild_hall_ui_5.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:setAnchorPoint(cc.p(0.5, 0.5));
    CommonMethod:setFullBgScale(self.Panel_1);
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));

    local Panel_2 = pWidget:getChildByName("Panel_2");
    local Panel_3 = Panel_2:getChildByName("Panel_3");
    self.Button_close = Panel_3:getChildByName("Button_close");
    self.Button_close:addTouchEventListener(handler(self,self.onButtonClick));

    local Panel_4 = Panel_2:getChildByName("Panel_4");

    local Panel_head = Panel_4:getChildByName("Panel_head");
    self.heroHead = userHead.create(self);
    self.heroHead:setAnchorPoint(cc.p(0.5, 0.5));
    self.heroHead:setPosition(cc.p(Panel_head:getContentSize().width/2,Panel_head:getContentSize().height/2));
    Panel_head:addChild(self.heroHead);

    self.Label_name = Panel_4:getChildByName("Label_name");
    self.Label_levelNum = Panel_4:getChildByName("Label_levelNum");
    self.Label_post1 = Panel_4:getChildByName("Label_post1");
    self.Label_time1 = Panel_4:getChildByName("Label_time1");
    self.BitmapLabel = Panel_4:getChildByName("BitmapLabel");

    self.ListView = Panel_3:getChildByName("ListView");
    -- self.ListView:setItemsMargin(5);
    self.ListView:setScrollBarVisible(false);

    local Label_level = Panel_4:getChildByName("Label_level");
    Label_level:setText(MG_TEXT_COCOS("guild_hall_ui_5_1"));

    local Label_time = Panel_4:getChildByName("Label_time");
    Label_time:setText(MG_TEXT_COCOS("guild_hall_ui_5_2"));

    local Label_post = Panel_4:getChildByName("Label_post");
    Label_post:setText(MG_TEXT_COCOS("guild_hall_ui_5_3"));
end

function guildAppointLayer:setData(data,timeStr,myPost,memberNum1,memberNum2)
    self.data = data;
    self.timeStr = timeStr;
    self.memberNum1 = memberNum1;--副会长数量
    self.memberNum2 = memberNum2;--精英数量
    self.myPost = myPost;

    self.Label_name:setText(unicode_to_utf8(data.name));
    self.Label_levelNum:setText(string.format("Lv.%d",tonumber(data.lv)));
    self.BitmapLabel:setText(tonumber(data.vip));
    self.Label_post1:setText(MG_TEXT("Union_"..tonumber(data.post)));
    self.Label_time1:setText(timeStr);

    local gm = GENERAL:getGeneralModel(tonumber(data.head));
    if gm then
        self.heroHead:setData(gm);
    end

    self.btns = {};
    self.ListView:removeAllItems();
    local itemLayout = ccui.Layout:create();
    itemLayout:setSize(cc.size(self.ListView:getContentSize().width, self.ListView:getContentSize().height));
    self.ListView:pushBackCustomItem(itemLayout);

    if self.myPost == 10 then
        for i=1,4 do
            local item = self:createItem(i);
            local h = itemLayout:getContentSize().height-item:getContentSize().height/2;
            item:setPosition(cc.p(itemLayout:getContentSize().width/2,h-(i-1)*item:getContentSize().height));
            itemLayout:addChild(item);
        end
    elseif self.myPost == 9 then
        for i=1,2 do
            local item = self:createItem(i);
            local h = itemLayout:getContentSize().height-item:getContentSize().height*3/2;
            item:setPosition(cc.p(itemLayout:getContentSize().width/2,h-(i-1)*item:getContentSize().height));
            itemLayout:addChild(item);
        end
    end
end

function guildAppointLayer:createItem(i)
    local layout = ccui.Layout:create();
    layout:setAnchorPoint(cc.p(0.5,0.5));
    layout:setSize(cc.size(self.ListView:getContentSize().width, 54));

    local img = ccui.ImageView:create("com_left_line3.png", ccui.TextureResType.plistType);
    img:setPosition(cc.p(layout:getContentSize().width/2, 0));
    img:setScale9Enabled(true);
    img:setCapInsets(cc.rect(5, 1, 1, 1));
    img:setSize(cc.size(387, 3));
    layout:addChild(img);

    local changeBtn = ccui.ImageView:create("Button_agree.png", ccui.TextureResType.plistType);
    changeBtn:setTouchEnabled(true);
    changeBtn:setPosition(cc.p(layout:getContentSize().width-50, layout:getContentSize().height/2));
    layout:addChild(changeBtn);
    changeBtn:setTag(i);
    changeBtn:addTouchEventListener(handler(self,self.onTouchClick));

    local descLabel = cc.Label:createWithTTF("", ttf_msyh, 22);
    descLabel:setAnchorPoint(cc.p(0,0.5));
    descLabel:setPosition(cc.p(50, layout:getContentSize().height/2));
    layout:addChild(descLabel);

    if self.myPost == 10 then
        if i == 1 then
            descLabel:setString(MG_TEXT("guildAppointLayer_1"));
        elseif i == 2 then
            descLabel:setString(string.format(MG_TEXT("guildAppointLayer_2"),self.memberNum1,2));
            if tonumber(self.data.post) == 9 then
                changeBtn:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
                changeBtn:setTouchEnabled(false);
            end
        elseif i == 3 then
            descLabel:setString(string.format(MG_TEXT("guildAppointLayer_3"),self.memberNum2,10));
            if tonumber(self.data.post) == 8 then
                changeBtn:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
                changeBtn:setTouchEnabled(false);
            end
        elseif i == 4 then
            descLabel:setString(MG_TEXT("guildAppointLayer_4"));
            if tonumber(self.data.post) == 0 then
                changeBtn:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
                changeBtn:setTouchEnabled(false);
            end
        end
    elseif self.myPost == 9 then
        if i == 1 then
            descLabel:setString(string.format(MG_TEXT("guildAppointLayer_3"),self.memberNum2,10));
        elseif i == 2 then
            descLabel:setString(MG_TEXT("guildAppointLayer_4"));
        end
    end

    table.insert(self.btns,changeBtn);

    return layout;
end

function guildAppointLayer:onTouchClick(sender, eventType)
    buttonClickScale(sender, eventType);
    if eventType == ccui.TouchEventType.ended then
        if self.myPost == 10 then
            if sender:getTag() == 1 then--会长禅让
                self.post = 10;
                local str = string.format(MG_TEXT("guildAppointLayer_5"),unicode_to_utf8(self.data.name));
                local MessageTip = MessageTip.showBox(self);
                MessageTip:setText(str);
            elseif sender:getTag() == 2 then--任命为副会长
                if self.memberNum1 >= 2 then
                    MGMessageTip:showFailedMessage(MG_TEXT("guildAppointLayer_6"));
                else
                    self.post = 9;
                    self:sendReq();
                end
            elseif sender:getTag() == 3 then--任命为精英
                if self.memberNum1 >= 10 then
                    MGMessageTip:showFailedMessage(MG_TEXT("guildAppointLayer_7"));
                else
                    self.post = 8;
                    self:sendReq();
                end
            elseif sender:getTag() == 4 then--任命为普通成员
                self.post = 0;
                self:sendReq();
            end
        end
    end
end

function guildAppointLayer:onButtonClick(sender, eventType)
    if sender ~= self.Panel_1 then
        buttonClickScale(sender, eventType);
    end

    if eventType == ccui.TouchEventType.ended then
        if self.delegate and self.delegate.removeAppointLayer then
            self.delegate:removeAppointLayer();
        end
    end
end

function guildAppointLayer:callBack()
    self:sendReq();
end

function guildAppointLayer:onReciveData(MsgID, NetData)
    print("guildAppointLayer onReciveData MsgID:"..MsgID)

    if MsgID == Post_changeMemRank then
        local ackData = NetData
        if ackData.state == 1 then
            if tonumber(self.data.post) == 9 then
                self.memberNum1 = self.memberNum1 - 1;--副会长数量
            elseif tonumber(self.data.post) == 8 then
                self.memberNum2 = self.memberNum2 - 1;--精英数量
            end
            if self.post == 9 then
                self.memberNum1 = self.memberNum1 + 1;
            elseif self.post == 8 then
                self.memberNum2 = self.memberNum2 + 1;
            end
            self.data.post = self.post;

            MGMessageTip:showFailedMessage(MG_TEXT("guildAppointLayer_8"));
            self.post = 0;

            if self.delegate and self.delegate.updataItem then
                self.delegate:updataItem(self);
            end
        else
            NetHandler:showFailedMessage(ackData);
        end
    end
end

function guildAppointLayer:sendReq()
    local str = string.format("&id=%s&rank=%d",self.data.uid,self.post);
    NetHandler:sendData(Post_changeMemRank, str);
end

function guildAppointLayer:pushAck()
    NetHandler:addAckCode(self,Post_changeMemRank);
end

function guildAppointLayer:popAck()
    NetHandler:delAckCode(self,Post_changeMemRank);
end

function guildAppointLayer:onEnter()
    self:pushAck();
end

function guildAppointLayer:onExit()
    self:popAck();
    MGRCManager:releaseResources("guildAppointLayer");
end

function guildAppointLayer.create(delegate,type)
    local layer = guildAppointLayer:new()
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

function guildAppointLayer.showBox(delegate,type)
    local layer = guildAppointLayer.create(delegate,type);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
