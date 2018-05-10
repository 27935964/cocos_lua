------------------------选区界面管理-------------------------

EnterLogin = class("EnterLogin", MGLayer)

function EnterLogin:ctor()
    self.type = 0;
    --self.updataTime = 0;
    self.nameLabel="";
    self.pswLabel="";
    self:init();
end

function EnterLogin:init()
    MGRCManager:cacheResource("EnterLogin", "enterlogin_bg.jpg");

    local pWidget = MGRCManager:widgetFromJsonFile("EnterLogin","Enterlogin_1.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);

    local Panel_2 = pWidget:getChildByName("Panel_2");
    --选区
    self.Button_zone = Panel_2:getChildByName("Button_zone");
    self.Button_zone:addTouchEventListener(handler(self,self.onButtonClick));
    --注 销
    self.Button_exit = Panel_2:getChildByName("Button_exit");
    self.Button_exit:addTouchEventListener(handler(self,self.onButtonClick));
    --公 告
    self.Button_inform = Panel_2:getChildByName("Button_inform");
    self.Button_inform:addTouchEventListener(handler(self,self.onButtonClick));
    --开始游戏
    self.Button_enter = Panel_2:getChildByName("Button_enter");
    self.Button_enter:addTouchEventListener(handler(self,self.onButtonClick));

    self.Label_enter = self.Button_enter:getChildByName("Label_enter");
    self.Label_enter:setVisible(false);
    local enterLabel = cc.Label:createWithTTF(MG_TEXT_COCOS("Enterlogin_1"),ttf_msyh,22);
    enterLabel:setPosition(cc.p(self.Button_enter:getContentSize().width/2,self.Button_enter:getContentSize().height/2))
    self.Button_enter:addChild(enterLabel);
    enterLabel:enableShadow(cc.c4b(0,   0,   0, 191), cc.size(1, -1),1);

    --区名
    self.Label_zone = self.Button_zone:getChildByName("Label_zone");
    --版本
    self.Label_ver = Panel_2:getChildByName("Label_ver");
    
end

function EnterLogin:onButtonClick(sender, eventType)
    if sender ~= self.Button_zone then
        buttonClickScale(sender, eventType);
    end
    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_enter then
            self.Button_enter:setTouchEnabled(false);
            local function setTouch()
                self.Button_enter:setTouchEnabled(true)
            end
            local time = cc.DelayTime:create(0.4);
            local func = cc.CallFunc:create(setTouch);
            self:runAction(cc.Sequence:create(time,func));
            self:sendReq();
        elseif sender == self.Button_exit then--注销
            require "MessageTip";
            local MessageTip = MessageTip.showBox(self);
            MessageTip:setText(MG_TEXT"Login_cancellation");
        elseif sender == self.Button_inform then--公告
            -- self:removeFromParent();
        elseif sender == self.Button_zone then--选区(暂不开放)
            -- local loginDistrict = require "loginDistrict";
            -- local district = loginDistrict.new(self);
            -- self:addChild(district);
        end
    end
end

function EnterLogin:callBack()
    if self.type == 2 then
        if self.delegate and self.delegate.addLoginLayer then
            self.delegate:addLoginLayer();
        end
    end
    self:removeFromParent();
end

function EnterLogin:setData(nameLabel,pswLabel,type,state_1,state_2)
    self.nameLabel=nameLabel;
    self.pswLabel=pswLabel;
    self.state_1=state_1;
    self.state_2=state_2;
    self.type = type;
end

function EnterLogin:setUserInfo()
    SAVESET:setUser(self.nameLabel);
    SAVESET:setPsw(self.pswLabel);
end

function EnterLogin:onReciveData(MsgID, NetData)
    print("EnterLogin onReciveData MsgID:"..MsgID)
    local ackData = NetData;
    if MsgID == Post_doPassportLogin then
        if ackData.state == 1 then
            local str = string.format("&account=%s&sess_id=%s&use_id=0&is_debug=0&version=0&from=0",ackData.dopassportlogin.account,ackData.dopassportlogin.sess_id);
            self.account=ackData.dopassportlogin.account;
            self.sess_id=ackData.dopassportlogin.sess_id;
            --self.updataTime = self.updataTime + 1;
            --if self.updataTime >= 2 then
                NetHandler:sendData(Post_doLogin, str);
                --self.updataTime = 1;
            --end
        else
            NetHandler:showFailedMessage(ackData);
        end
    elseif  MsgID == Post_doLogin then
        if ackData.state == 1  then
            if ackData.dologin.ret==1 then
                ME:setUser(self.nameLabel);
                ME:setPsw(self.pswLabel);
                ME:setSevTime(ackData.dologin.server_time);
                ME:setUid(ackData.dologin.uid);
                ME:setVerfiy(ackData.dologin.verfiy);
                initChatData();--初始化聊天数据
                self:saveUserName(self.nameLabel,self.pswLabel)--保存登录信息到本地
                NetHandler:sendData(Post_getGenerals, "");
                NetHandler:sendData(Post_getStorage, "");
                NetHandler:sendData(Post_Chat_getChatConfig, "");
                self:setUserInfo();
                self:checkIsFirstBuy();
                enterLuaScene(SCENEINFO.MAP_SCENE);
                MGMessageTip:showFailedMessage(string.format("连接成功(%s)",ackData.dologin.uid));
            elseif ackData.dologin.ret==-2 then
                self:sendDoActivationReq();
                -- local intileName = intileNameLayer.showBox(self);
            elseif ackData.dologin.ret == -3 then--正在激活
                self:sendReqDoLogin(self.account,self.sess_id);
            else
                MGMessageTip:showFailedMessage(MG_TEXT("Login_err"));
            end
        else
            NetHandler:showFailedMessage(ackData);
        end
    elseif MsgID == Post_doActivation then
        if ackData.state == 1 then
            local str = string.format("&account=%s&sess_id=%s&use_id=0&is_debug=0&version=0&from=0",self.account,self.sess_id);
            NetHandler:sendData(Post_doLogin, str);
        else
            NetHandler:showFailedMessage(ackData);
        end
    end
end

function EnterLogin:checkIsFirstBuy()
    local userDefault=cc.UserDefault:getInstance();
    local data=nil;
    local dataKey="shopLayer";
    local dataStr=userDefault:getStringForKey(dataKey);
    if dataStr==nil or dataStr=="" then--登录后首次购买需要弹框
        data={};
        data.isFirst=true;
        dataStr=cjson.encode(data);
        userDefault:setStringForKey(dataKey,dataStr);
        userDefault:flush();
    else
        data=cjson.decode(dataStr);
        if nil==data.isFirst or data.isFirst==false then
            data.isFirst=true;
            dataStr=cjson.encode(data);
            userDefault:setStringForKey(dataKey,dataStr);
            userDefault:flush();
        end
    end
end

--保存登录信息到本地
function EnterLogin:saveUserName(name,psw)
    local userDefault=cc.UserDefault:getInstance();
    local data=nil;
    local dataKey="user_login";
    -- local dataKey=string.format("user_login_%s_%s",name,psw);
    local dataStr=userDefault:getStringForKey(dataKey);
    if dataStr==nil or dataStr=="" then
        data={};
        local info = {};
        info.name=name;
        info.psw=psw;
        info.isSave=self.state_1;--是否保存密码
        info.isAutoLogin=self.state_2;--是否自动登录
        table.insert(data,info);
        dataStr=cjson.encode(data);
        userDefault:setStringForKey(dataKey,dataStr);
        userDefault:flush();
    else
        data=cjson.decode(dataStr);
        for i=1,#data do
            if name==data[i].name and psw==data[i].psw then
                table.remove(data,i);
                dataStr=cjson.encode(data);
                userDefault:setStringForKey(dataKey,dataStr);
                userDefault:flush();
                break;
            end
        end

        local info = {};
        info.name=name;
        info.psw=psw;
        info.isSave=self.state_1;--是否保存密码
        info.isAutoLogin=self.state_2;--是否自动登录
        table.insert(data,1,info);
        dataStr=cjson.encode(data);
        userDefault:setStringForKey(dataKey,dataStr);
        userDefault:flush();
        table.insert(data,info);
    end
end

function EnterLogin:sendReq()
    local str = string.format("&account=%s&pwd=%s&sid=%d",self.nameLabel,self.pswLabel,1);
    NetHandler:sendData(Post_doPassportLogin, str);
end

function EnterLogin:sendReqDoLogin(account,sess_id)
    local str = string.format("&account=%s&sess_id=%s&use_id=0&is_debug=0&version=0&from=0",account,sess_id);
    self.account=account;
    self.sess_id=sess_id;
    NetHandler:sendData(Post_doLogin, str);
end

function EnterLogin:sendDoActivationReq()
    local str = string.format("&sess_id=%s&from=%s&mac=%s",self.sess_id,"1","1");
    NetHandler:sendData(Post_doActivation, str);
end

function EnterLogin:pushAck()
    NetHandler:addAckCode(self,Post_doPassportLogin);
    NetHandler:addAckCode(self,Post_doLogin);
    NetHandler:addAckCode(self,Post_getGenerals);
    NetHandler:addAckCode(self,Post_getStorage);
    NetHandler:addAckCode(self,Post_doActivation);
end

function EnterLogin:popAck()
    NetHandler:delAckCode(self,Post_doPassportLogin);
    NetHandler:delAckCode(self,Post_doLogin);
    NetHandler:delAckCode(self,Post_getGenerals);
    NetHandler:delAckCode(self,Post_getStorage);
    NetHandler:delAckCode(self,Post_doActivation);
end

function EnterLogin:onEnter()
    self:pushAck();
end

function EnterLogin:onExit()
    MGRCManager:releaseResources("EnterLogin")

    self:popAck();
end

function EnterLogin.create(delegate)
    local layer = EnterLogin:new()
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

function EnterLogin.showBox(delegate)
    local layer = EnterLogin.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
