-----------------------聊天界面------------------------
require "chatItem"
require "membersLayer"
require "chatTip"
require "chatRecentPrivate"

chatLayer = class("chatLayer", MGLayer)

function chatLayer:ctor()
    self.descLabel_1 = "";
    self.descLabel_2 = "";
    self.uid = ""
    self.curChatId = 100;
    self.curTag = 0;
    self.chatTip = nil;
    self.curItemData = nil;
    self:init();
end

function chatLayer:init()
    MGRCManager:cacheResource("chatLayer", "Chat_Frame.png");
    MGRCManager:cacheResource("chatLayer", "chat_ui.png", "chat_ui.plist");
    local pWidget = MGRCManager:widgetFromJsonFile("chatLayer","Chat_ui.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);

    self.value1 = tonumber(LUADB.readConfig(198));--世界频道开启等级
    self.value2 = tonumber(LUADB.readConfig(199));--私聊开启等级
    self.value3 = tonumber(LUADB.readConfig(200));--公会频道开启等级
    self.value4 = tonumber(LUADB.readConfig(201));--聊天最多字数

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:setAnchorPoint(cc.p(0.5, 0.5));
    CommonMethod:setFullBgScale(self.Panel_1);
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));

    local Panel_2 = pWidget:getChildByName("Panel_2");
    self.Panel_2 = Panel_2;

    self.Panel_btn = Panel_2:getChildByName("Panel_btn");
    self.Panel_btn:setTouchEnabled(false);
    self.Panel_btn:addTouchEventListener(handler(self,self.onButtonClick));

    local Panel_left = Panel_2:getChildByName("Panel_left");
    local Panel_Right = Panel_2:getChildByName("Panel_Right");

    self.btnInfos = {};
    for i=1,7 do
        local Panel_btn = Panel_left:getChildByName("Panel_btn"..i);
        Panel_btn:setTag(i);
        Panel_btn:setTouchEnabled(true);
        Panel_btn:addTouchEventListener(handler(self,self.onBtnClick));

        local Label_btn = Panel_btn:getChildByName("Label_btn"..i);
        Label_btn:setText(MG_TEXT_COCOS("Chat_ui_"..i));
        Label_btn:setColor(cc.c3b(130, 130, 111));

        if i == 1 then
            self.curPanelBtn = Panel_btn;
            Label_btn:setColor(cc.c3b(255, 255, 255));
        end

        local y = Panel_btn:getPositionY()+Panel_btn:getContentSize().height/2;
        table.insert(self.btnInfos,{btn=Panel_btn,Label_btn=Label_btn,posY=y})

        --------------暂不开放-------------
        if i > 4 then
            Panel_btn:setVisible(false);
            Panel_btn:setTouchEnabled(false);
        end
    end
    self.Image_select = Panel_left:getChildByName("Image_sel");
    self.Image_btn = Panel_left:getChildByName("Image_btn");
    self.oldHeadProgram = self.Image_btn:getSprit():getShaderProgram();

    self.Button_left = Panel_left:getChildByName("Button_left");--关
    self.Button_left:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_right = Panel_left:getChildByName("Button_right");--开
    self.Button_right:addTouchEventListener(handler(self,self.onButtonClick));

    self.Panel_send = Panel_Right:getChildByName("Panel_send");
    self.Label_tip = Panel_Right:getChildByName("Label_tip");
    self.Label_tip:setText(MG_TEXT_COCOS("Chat_ui_14"));
    
    self.Button_Send = self.Panel_send:getChildByName("Button_Send");--发送
    self.Button_Send:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_ChatWindow = Panel_Right:getChildByName("Button_ChatWindow");--收起
    self.Button_ChatWindow:addTouchEventListener(handler(self,self.onButtonClick));

    self.textImg_1 = self.Panel_send:getChildByName("Image_InputBox_Open");
    self.editBox_1 = self:createEditBox(self.textImg_1);
    self.posX = self.textImg_1:getPositionX();

    self.Panel_union = Panel_Right:getChildByName("Panel_union");
    self.textImg_2 = self.Panel_union:getChildByName("Image_InputPrivateChatName");
    self.editBox_2 = self:createEditBox(self.textImg_2);

    self.Button_GuildMember = self.Panel_union:getChildByName("Button_GuildMember");--公会成员
    self.Button_GuildMember:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_Recent = self.Panel_union:getChildByName("Button_RecentPrivateChat");--最近私聊
    self.Button_Recent:addTouchEventListener(handler(self,self.onButtonClick));

    self.ListView = Panel_Right:getChildByName("ListView");
    self.ListView:setScrollBarVisible(false);
    self.height = self.ListView:getContentSize().height;
    self.posY = self.ListView:getPositionY();

    local Label_Switch_Close = Panel_left:getChildByName("Label_Switch_Close");
    Label_Switch_Close:setText(MG_TEXT_COCOS("Chat_ui_8"));

    local Label_Switch_Open = Panel_left:getChildByName("Label_Switch_Open");
    Label_Switch_Open:setText(MG_TEXT_COCOS("Chat_ui_9"));

    local Label_LockScreen = Panel_left:getChildByName("Label_LockScreen");
    Label_LockScreen:setText(MG_TEXT_COCOS("Chat_ui_10"));

    local Label_GuildMember = self.Button_GuildMember:getChildByName("Label_GuildMember");
    Label_GuildMember:setText(MG_TEXT_COCOS("Chat_ui_11"));

    local Label_Recent = self.Button_Recent:getChildByName("Label_RecentPrivateChat");
    Label_Recent:setText(MG_TEXT_COCOS("Chat_ui_12"));

    local Label_Send = self.Button_Send:getChildByName("Label_Send");
    Label_Send:setText(MG_TEXT_COCOS("Chat_ui_13"));

    self:updataData(1,100);
end

function chatLayer:createEditBox(imageView)
    local sp = cc.Scale9Sprite:create();
    local editBox = cc.EditBox:create(cc.size(imageView:getSize().width*0.98, imageView:getSize().height), sp);
    editBox:setFontSize(26);
    editBox:setFontColor(cc.c3b(118,118,118));
    editBox:setFontName(ttf_msyh);
    editBox:setAnchorPoint(cc.p(0.5, 0.5));
    editBox:setPosition(cc.p(imageView:getSize().width/2, imageView:getSize().height / 2));
    editBox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE);
    editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_SEARCH);
    editBox:registerScriptEditBoxHandler(handler(self,self.editBoxTextEventHandler));
    imageView:addChild(editBox);

    if imageView == self.textImg_1 then
        editBox:setMaxLength(self.value4);
        editBox:setPlaceHolder(MG_TEXT("chatLayer_2"));
    elseif imageView == self.textImg_2 then
        editBox:setPlaceHolder(MG_TEXT("chatLayer_1"));
        -- editBox:setMaxLength(7);
    end

    return editBox;
end

function chatLayer:editBoxTextEventHandler(strEventName,sender)
    if strEventName == "began" then

    elseif strEventName == "return" then
        if sender == self.editBox_1 then
            self.descLabel_1 = self.editBox_1:getText();
        elseif sender == self.editBox_2 then
            self.descLabel_2 = self.editBox_2:getText();
        end
    end
end

function chatLayer:updata()
    self:updataData(self.curTag,self.curChatId);
end

function chatLayer:updataData(tag,id)
    self.Panel_union:setVisible(false);
    self.Button_GuildMember:setEnabled(false);
    self.Button_Recent:setEnabled(false);
    self.ListView:setSize(cc.size(self.ListView:getContentSize().width,self.height));
    self.ListView:setPositionY(self.posY);
    if tag == 4 then--私聊
        self.data = _G.CHAT.chatUserData or {};
        self.Panel_union:setVisible(true);
        self.Button_GuildMember:setEnabled(true);
        self.Button_Recent:setEnabled(true);
        self.ListView:setSize(cc.size(self.ListView:getContentSize().width,self.height-60));
        self.ListView:setPositionY(self.posY+60);
    else
        self.data = _G.CHAT.chatData[id] or {};
    end
    self:creatItem();

    if tag == 1 then--系统频道
        self.editBox_1:setEnabled(false);
        self.editBox_1:setText(MG_TEXT("chatLayer_4"));
        self.Button_Send:setEnabled(false);
        self.textImg_1:setPositionX(self.Panel_send:getContentSize().width/2);
    else
        self.editBox_1:setEnabled(true);
        self.editBox_1:setText(MG_TEXT("chatLayer_2"));
        self.Button_Send:setEnabled(true);
        self.textImg_1:setPositionX(self.posX);
    end
    self.descLabel_1 = self.editBox_1:getText();

    self.Label_tip:setVisible(false);
    if 0 == #self.data then
        self.Label_tip:setVisible(true);
    end
end

function chatLayer:creatItem()
    self.ListView:removeAllItems();
    self.totalNum = #self.data;
    if 0 == self.totalNum then
        return;
    end

    local modItem = chatItem.create(self);
    local itemLay = ccui.Layout:create();
    itemLay:setSize(cc.size(self.ListView:getContentSize().width, modItem:getContentSize().height*self.totalNum));
    self.ListView:pushBackCustomItem(itemLay);

    local itemIndex = self.totalNum;
    local function loadEachItem(dt)
        if itemIndex < 1 then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
            
        else
            local item = chatItem.create(self);
            item:setData(self.data[itemIndex]);
            item:setPosition(cc.p(item:getContentSize().width/2,itemLay:getContentSize().height-item:getContentSize().height/2
                -(itemIndex-1)*item:getContentSize().height));
            itemLay:addChild(item);
            self.ListView:jumpToBottom();
            itemIndex = itemIndex-1;
        end
    end

    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
    end
    self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(loadEachItem, 0.001, false);
end

function chatLayer:getChatId(tag)
    local id = 100;
    if tag == 1 then--系统
        id = 100;
    elseif tag == 2 then--世界
        id = 200;
    elseif tag == 3 then--公会
        id = tonumber("201"..ME:getUnionId());
    elseif tag == 4 then--私聊
        id = 0;
    elseif tag == 5 then

    elseif tag == 6 then

    elseif tag == 7 then

    end

    return id;
end

function chatLayer:select(uid,name)
    self.editBox_2:setText(unicode_to_utf8(name));
    self.descLabel_2 = unicode_to_utf8(name);
    self.uid = uid;
end

function chatLayer:onButtonClick(sender, eventType)
    if sender ~= self.Panel_1 then
        buttonClickScale(sender, eventType);
    end
    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_right then--开
            local moveTo = cc.MoveTo:create(0.1,cc.p(73,73))
            self.Image_btn:runAction(moveTo);
            self.Image_btn:getSprit():setShaderProgram(self.oldHeadProgram);
        elseif sender == self.Button_left then--关
            local moveTo = cc.MoveTo:create(0.1,cc.p(25,73))
            self.Image_btn:runAction(moveTo);
            self.Image_btn:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
        elseif sender == self.Button_Send then--发送
            if self.curPanelBtn:getTag() ~= 1 then
                if self.descLabel_1 and self.descLabel_1 ~= "" then
                    if self.curPanelBtn:getTag() == 4 then--私聊
                        self:sendUserReq(self.descLabel_1);
                    else
                        self:sendReq(self.curChatId,self.descLabel_1);
                    end
                else
                    MGMessageTip:showFailedMessage(MG_TEXT("chatLayer_3"));
                end
            else
                MGMessageTip:showFailedMessage(MG_TEXT("chatLayer_4"));
            end
        elseif sender == self.Button_GuildMember then--公会成员
            NetHandler:sendData(Post_getMemList, "");
        elseif sender == self.Button_Recent then--最近私聊
            self:addChatRecentPrivate();
        elseif sender == self.Button_ChatWindow or sender == self.Panel_1 then--收起
            -- NodeRemoveFromParent(self.Panel_2);
            self:dispose();

        elseif sender == self.Panel_btn then
            self:removeChatTip();
            self:removeRecentPrivate();
        end
    end
end

function chatLayer:onBtnClick(sender, eventType)
    if self.curPanelBtn== sender then
        return;
    end

    self.curChatId = self:getChatId(sender:getTag());
    self.curTag = sender:getTag();
    if eventType == ccui.TouchEventType.ended then
        if sender:getTag() == 2 then--世界频道
            if ME:Lv() < self.value1 then
                MGMessageTip:showFailedMessage(string.format(MG_TEXT("chatLayer_11"),self.value1));
                return;
            end
        elseif sender:getTag() == 3 then--公会频道
            if ME:Lv() < self.value3 then
                MGMessageTip:showFailedMessage(string.format(MG_TEXT("chatLayer_12"),self.value3));
                return;
            else
                if ME:getUnionId() == 0 then--未加入公会
                    local guildLayer = guildLayer.showBox(self);
                    self:dispose();
                    return;
                end
            end
        elseif sender:getTag() == 4 then--私聊
            if ME:Lv() < self.value2 then
                MGMessageTip:showFailedMessage(string.format(MG_TEXT("chatLayer_13"),self.value2));
                return;
            end
        end

        self:updataData(sender:getTag(),self.curChatId);
        self.btnInfos[sender:getTag()].Label_btn:setColor(cc.c3b(255, 255, 255));
        self.btnInfos[self.curPanelBtn:getTag()].Label_btn:setColor(cc.c3b(130, 130, 111));
        self.curPanelBtn = sender;
        self.Image_select:setPositionY(self.btnInfos[sender:getTag()].posY);
    end
end

function chatLayer:HeroHeadSelect(item)
    self.curItemData = item.data;
    self.curItemData.name = item.attData[2];
    self.Panel_btn:setTouchEnabled(true);
    self.chatTip = chatTip.showBox(self);
    self.chatTip:setData(self.curItemData);
    local width = self.Panel_btn:getPositionX()+self.Panel_btn:getContentSize().width;
    local startPos = item.heroHead:getParent():convertToWorldSpace(cc.p(item.heroHead:getPositionX(),
        item.heroHead:getPositionY()));
    if startPos.x + self.chatTip:getContentSize().width > width-10 then
        startPos.x = startPos.x-self.chatTip:getContentSize().width;
    end
    if startPos.y - self.chatTip:getContentSize().height < 10 then
        startPos.y = startPos.y+self.chatTip:getContentSize().height;
    end
    self.chatTip:setPosition(startPos);
end

function chatLayer:removeChatTip()
    if self.chatTip then
        self.chatTip:removeFromParent();
        self.chatTip = nil;
        self.Panel_btn:setTouchEnabled(false);
    end
end

function chatLayer:removeRecentPrivate()
    if self.chatRecentPrivate then
        self.chatRecentPrivate:removeFromParent();
        self.chatRecentPrivate = nil;
        self.Panel_btn:setTouchEnabled(false);
    end
end

function chatLayer:chatTipCallBack(tag)
    if tag == 1 then--屏蔽
        local isInsert = true;--是否保存需要屏蔽的Uid
        for i=1,#_G.CHAT.shields do
            if _G.CHAT.shields[i] == self.curItemData.uid then
                isInsert = false;
                table.remove(_G.CHAT.shields,i);
                MGMessageTip:showFailedMessage(MG_TEXT("chatLayer_10"));
                break;--如果已经保存过的就不要再保存了
            end 
        end
        if isInsert then
            MGMessageTip:showFailedMessage(MG_TEXT("chatLayer_9"));
            table.insert(_G.CHAT.shields,self.curItemData.uid);
        end
    elseif tag == 2 then--查看
        local playerInfo = playerInfo.create(self);
        playerInfo:setData(self.curItemData.uid,self.curItemData.name);
        cc.Director:getInstance():getRunningScene():addChild(playerInfo,ZORDER_MAX);
    elseif tag == 3 then--私聊
        self.curTag = 4;
        self:onBtnClick(self.btnInfos[4].btn, ccui.TouchEventType.ended);
        self:updataData(self.curTag);
        self:select(self.curItemData.uid,self.curItemData.name);
    end
    self:removeChatTip();
end

function chatLayer:addChatRecentPrivate()
    self.Panel_btn:setTouchEnabled(true);
    self.chatRecentPrivate = chatRecentPrivate.showBox(self);
    self.chatRecentPrivate:setData();
    local width = self.Panel_btn:getPositionX()+self.Panel_btn:getContentSize().width;
    local startPos = self.Button_Recent:getParent():convertToWorldSpace(cc.p(self.Button_Recent:getPositionX(),
        self.Button_Recent:getPositionY()));
    self.chatRecentPrivate:setPosition(startPos);
    self.chatRecentPrivate:setPositionY(self.chatRecentPrivate:getPositionY()+30);
end

function chatLayer:chatRecentPrivateCallBack(uid,name)
    self:select(uid,name);
    self:removeRecentPrivate();
end

function chatLayer:onReciveData(MsgID, NetData)
    print("chatLayer onReciveData MsgID:"..MsgID)

    if MsgID == TCP_APP_CHAT_USER then--私聊
        local str_list=spliteStr(NetData,'|');
        local NetData = {}
        if str_list[2] == "202" then
            NetData.state =1;
        else
            NetData.state =-2;
            NetData.reportMsg=str_list[2];
        end

        if NetData.state == 1 then
            table.insert(_G.CHAT.chatUserData,self.reqData);
            if #_G.CHAT.chatUserData > 30 then
                table.remove(_G.CHAT.chatUserData,1);
            end
            savePrivateChat(_G.CHAT.chatUserData);
            self:updataData(self.curTag,self.curChatId);
        else
            NetHandler:showFailedMessage(NetData);
        end
    elseif MsgID == TCP_APP_CHAT_CHANNEL then--频道聊天
        local str_list=spliteStr(NetData,'|');
        local NetData = {}
        if str_list[2] == "202" then
            NetData.state =1;
        else
            NetData.state =-2;
            NetData.reportMsg=str_list[2];
        end

        if NetData.state == 1 then

        else
            NetHandler:showFailedMessage(NetData);
        end
    elseif MsgID == Post_getMemList then--公会成员
        if NetData.state == 1 then
            local membersLayer = membersLayer.showBox(self);
            membersLayer:setData(NetData.getmemlist);
        else
            NetHandler:showFailedMessage(NetData);
        end
    end
end

function chatLayer:sendReq(id,desc)--频道
    local tcpurl=require "tcpurl";
    local post = tcpurl[TCP_APP_CHAT_CHANNEL];
    local att = string.format("%d:%s:%d:%d",ME:getHeadId(),ME:getName(),ME:Lv(),ME:vipLevel());
    local str=string.format(post.a,id,att,desc);
    NetHandler:sendSocket(TCP_APP_CHAT_CHANNEL, str);
end

function chatLayer:sendUserReq(desc)--私聊
    self.reqData = {};
    local tcpurl=require "tcpurl";
    local post = tcpurl[TCP_APP_CHAT_USER];
    local att = string.format("%d:%s:%d:%d",ME:getHeadId(),ME:getName(),ME:Lv(),ME:vipLevel());
    local str=string.format(post.a,self.uid,att,desc);
    self.reqData.type = 204;
    self.reqData.att = att;
    self.reqData.uid = ME:getUid();
    self.reqData.text = desc;
    NetHandler:sendSocket(TCP_APP_CHAT_USER, str);
end

function chatLayer:pushAck()
    NetHandler:addAckCode(self,TCP_APP_CHAT_USER);
    NetHandler:addAckCode(self,TCP_APP_CHAT_CHANNEL);
    NetHandler:addAckCode(self,Post_getMemList);
end

function chatLayer:popAck()
    NetHandler:delAckCode(self,TCP_APP_CHAT_USER);
    NetHandler:delAckCode(self,TCP_APP_CHAT_CHANNEL);
    NetHandler:delAckCode(self,Post_getMemList);
end

function chatLayer:onEnter()
    self:pushAck();
end

function chatLayer:onExit()
    self:popAck();
    MGRCManager:releaseResources("chatLayer");
    self:removeChatTip();
    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
    end
end

function chatLayer.create(delegate)
    local layer = chatLayer:new()
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

function chatLayer.showBox(delegate)
    local layer = chatLayer.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_PRIORITY);
    return layer;
end

local _instance;
function chatLayer:getInstance()
    if _instance then
        return _instance;
    end
end

function chatLayer:createInstance()
    if _instance==nil then
        _instance=chatLayer.showBox();
    end
    return _instance;
end

function chatLayer:dispose()
    if nil == _instance then
        return;
    end
    if self.Panel_2:getNumberOfRunningActions()>0 then
        self.Panel_2:stopAllActions();
    end
    self.Panel_2:setScale(1);
    local function callFunc()
        if _instance then
            if _instance:getParent() then
                _instance:removeFromParent();
            end
            _instance=nil;
        end
    end
    local func = cc.CallFunc:create(callFunc);
    local easeOut = cc.EaseOut:create(cc.ScaleTo:create(0.2,0),4);
    self.Panel_2:runAction(cc.Sequence:create(easeOut,func));
end
