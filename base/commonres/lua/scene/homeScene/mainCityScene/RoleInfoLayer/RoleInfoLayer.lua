------------------------角色信息界面管理-------------------------
require "ChangeHeadLayer"
require "changeNameLayer"
require "SystemSetting"

RoleInfoLayer = class("RoleInfoLayer", MGLayer)

function RoleInfoLayer:ctor()
    self:init();
end

function RoleInfoLayer:init()
    MGRCManager:cacheResource("RoleInfoLayer", "role_info_VIP_number.png");
    MGRCManager:cacheResource("RoleInfoLayer", "RoleInfoLayer_ui.png","RoleInfoLayer_ui.plist");
    local pWidget = MGRCManager:widgetFromJsonFile("RoleInfoLayer","RoleInfoLayer_ui_1.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:addTouchEventListener(handler(self,self.onBackClick));

    local Panel_2 = pWidget:getChildByName("Panel_2");
    self.Button_close = Panel_2:getChildByName("Button_close");
    self.Button_close:addTouchEventListener(handler(self,self.onButtonClick));

    local Panel_3 = Panel_2:getChildByName("Panel_3");
    self.Button_change = Panel_3:getChildByName("Button_change");
    self.Button_change:addTouchEventListener(handler(self,self.onButtonClick));
    local Label_change = self.Button_change:getChildByName("Label_change");
    Label_change:setText(MG_TEXT_COCOS("RoleInfoLayer_ui_5"));

    self.Button_switch = Panel_3:getChildByName("Button_switch");--切换账号按钮
    self.Button_switch:addTouchEventListener(handler(self,self.onButtonClick));
    local Label_switch = self.Button_switch:getChildByName("Label_switch");
    Label_switch:setText(MG_TEXT_COCOS("RoleInfoLayer_ui_3"));

    self.Button_set = Panel_3:getChildByName("Button_set");--设置按钮
    self.Button_set :addTouchEventListener(handler(self,self.onButtonClick));
    local Label_set  = self.Button_set:getChildByName("Label_set ");
    Label_set :setText(MG_TEXT_COCOS("RoleInfoLayer_ui_4"));

    local Image_vipBg = Panel_3:getChildByName("Image_vipBg");
    self.AtlasLabel = Image_vipBg:getChildByName("AtlasLabel");

    local Image_head = Panel_3:getChildByName("Image_head");
    Image_head:setVisible(false);

    self.heroHead = userHead.create(self);
    self.heroHead:setTouchEnabled(false);
    self.heroHead:setAnchorPoint(cc.p(0.5, 0.5));
    self.heroHead:setPosition(Image_head:getPosition());
    Panel_3:addChild(self.heroHead,1);

    local Panel_4 = Panel_3:getChildByName("Panel_4");
    self.Image_editBox = Panel_4:getChildByName("Image_editBox");
    self.Image_editBox:setTouchEnabled(true);
    self.Image_editBox:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_rename = Panel_4:getChildByName("Button_rename");--改名按钮
    self.Button_rename:addTouchEventListener(handler(self,self.onButtonClick));

    self.ProgressBar = Panel_4:getChildByName("ProgressBar");--进度条
    self.Label_bar = Panel_4:getChildByName("Label_bar");--进度

    self.Label_level = Panel_4:getChildByName("Label_level");
    self.Label_idValue = Panel_4:getChildByName("Label_idValue");
    self.Label_powerValue = Panel_4:getChildByName("Label_powerValue");
    self.Label_name = Panel_4:getChildByName("Label_name");
    self.Label_name:setText(MG_TEXT("RoleInfoLayer_1"));
    self.Label_userName = Panel_4:getChildByName("Label_userName");
    
    local Label_power = Panel_4:getChildByName("Label_power");
    Label_power:setText(MG_TEXT_COCOS("RoleInfoLayer_ui_1"));
    local Label_legion = Panel_4:getChildByName("Label_legion");
    Label_legion:setText(MG_TEXT_COCOS("RoleInfoLayer_ui_2"));
end

function RoleInfoLayer:onBackClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        self:removeFromParent();
    end
end

function RoleInfoLayer:onButtonClick(sender, eventType)
    if sender ~= self.Image_editBox then
        buttonClickScale(sender, eventType);
    end
    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_close then
            self:removeFromParent();
        elseif sender == self.Button_change then--更换头像
            NetHandler:sendData(Post_getUserAllHead, "");
        elseif sender == self.Button_switch then--切换账号按钮
            LuaBackCpp:enterLuaScene(SCENEINFO.LOGIN_SCENE,LAYERTAG.LAYER_LOGIN,0,0,0);
        elseif sender == self.Button_set then--设置按钮
            local SystemSetting = SystemSetting.showBox(self);
        elseif sender == self.Button_rename or sender == self.Image_editBox then--改名按钮 
            local changeNameLayer = changeNameLayer.showBox(self);
        end
    end
end

function RoleInfoLayer:setData()
    self.gm = GENERAL:getGeneralModel(ME:getHeadId());
    self.heroHead:setData(self.gm);
    self.AtlasLabel:setStringValue(ME:vipLevel());
    self.Label_level:setText(string.format("Lv.%d",ME:Lv()));
    self.Label_idValue:setText(ME:getUid());
    self.Label_powerValue:setText(ME:getWarMax());
    self.Label_userName:setText(unicode_to_utf8(ME:getName()));

    if ME:Lv() < ME:getMaxUserLv() then
        local DBData = LUADB.select(string.format("select * from user_lv where lv=%d",17),"need_exp");
        local fNum = string.format("%d", ME:Lv()/tonumber(DBData.info.need_exp));
        self.ProgressBar:setPercent(fNum);
        self.Label_bar:setText(string.format("%d%%",fNum));
    else
        self.ProgressBar:setPercent(100);
        self.Label_bar:setText(string.format("%d%%",100));
    end
end

function RoleInfoLayer:setName(name)
    self.Label_userName:setText(name);
end

function RoleInfoLayer:HeroHeadSelect(head)
    self.gm = head.gm;
    self:sendReq(head.gm);
end

function RoleInfoLayer:onReciveData(MsgID, NetData)
    print("RoleInfoLayer onReciveData MsgID:"..MsgID)
    
    if MsgID == Post_getUserAllHead then
        local ackData = NetData
        if ackData.state == 1 then
            local changeHeadLayer = ChangeHeadLayer.showBox(self);
            changeHeadLayer:setData(ackData.getuserallhead);
        else
            NetHandler:showFailedMessage(ackData)
        end
    elseif  MsgID == Post_setUserHead then
        local ackData = NetData
        if ackData.state == 1  then
            ME:setHeadId(self.gm:getId());
            if self.delegate and self.delegate.data and self.delegate.setData then
                self.delegate:setData(self.delegate.data);
            end
            self:setData();
        else
            NetHandler:showFailedMessage(ackData)
        end
    end
    
end

function RoleInfoLayer:sendReq(gm)
    local str = string.format("&id=%d",gm:getId());
    NetHandler:sendData(Post_setUserHead, str);
end

function RoleInfoLayer:pushAck()
    NetHandler:addAckCode(self,Post_getUserAllHead);
    NetHandler:addAckCode(self,Post_setUserHead);
end

function RoleInfoLayer:popAck()
    NetHandler:delAckCode(self,Post_getUserAllHead);
    NetHandler:delAckCode(self,Post_setUserHead);
end

function RoleInfoLayer:onEnter()
    self:pushAck();
end

function RoleInfoLayer:onExit()
    MGRCManager:releaseResources("RoleInfoLayer");
    self:popAck();
end

function RoleInfoLayer.create(delegate)
    local layer = RoleInfoLayer:new()
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

function RoleInfoLayer.showBox(delegate)
    local layer = RoleInfoLayer.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
