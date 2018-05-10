------------------------主线界面管理-------------------------
LoginManager = class("LoginManager", MGLayer)

function LoginManager:init()
    self.info = self:getUserInfo();
    self:addLayer();
end

function LoginManager:ctor()
    
end

function LoginManager:addLayer()
	-- if SAVESET:getUser() ~= "" and SAVESET:getPsw() ~= "" then
    if self.info then
        if self.layerType == LAYERTAG.LAYER_LOGIN then
            self:addLoginLayer();
        else
            if self.info.isAutoLogin then--自动登录
                require "EnterLogin";
                local enterLogin = EnterLogin.showBox(self);
                enterLogin:setData(self.info.name,self.info.psw,2,self.info.isSave,self.info.isAutoLogin);
                --enterLogin:sendReq();
            else
                self:addLoginLayer();
            end
        end
    else
        self:addLoginLayer();
    end
end

function LoginManager:addLoginLayer()
    require "LoginLayer";
    local loginLayer = LoginLayer.showBox(self);
    loginLayer:setData(self.info);
end

function LoginManager:getUserInfo()
    local UserInfo = nil;
    local userDefault=cc.UserDefault:getInstance();
    local data=nil;
    local dataKey="user_login";
    local dataStr=userDefault:getStringForKey(dataKey);
    if dataStr==nil or dataStr=="" then
        return;
    else
        data=cjson.decode(dataStr);
        local isAuto = false;
        for i=1,#data do
            if data[i].isAutoLogin then--自动登录
                UserInfo = data[i];
                isAuto = true;
                break;
            end
        end

        if isAuto == false then
            UserInfo = data[1];
        end
    end

    return UserInfo;
end

function LoginManager:onEnter()
	
end

function LoginManager:onExit()
	MGRCManager:releaseResources("LoginManager");
end

function LoginManager.create(layerType)
    local layer = LoginManager:new();
    layer.layerType = layerType;
    layer:init();
    local function onNodeEvent(event)
        if event == "enter" then
            layer:onEnter();
        elseif event == "exit" then
            layer:onExit();
        end
    end
    
    layer:registerScriptHandler(onNodeEvent);
    
    return layer;
end

s_LoginManager = nil;
function addLoginManager(layerType)
	s_LoginManager = LoginManager.create(layerType);
	cc.Director:getInstance():getRunningScene():addChild(s_LoginManager,ZORDER_MAX);
end

function delLoginManager()
    if s_LoginManager then
        s_LoginManager:removeFromParent();
    end
end
