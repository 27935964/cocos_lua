require "sodierShow"
require "LoginManager"

LoadingPanel = class("LoadingPanel", MGLayer)

function LoadingPanel:ctor()
    self.pWidget = nil;
    self.panel = nil;
    self.panel_list = nil;
    self.datas = nil;
    self.Button_arena = nil;
end



local GameScene = class("GameScene",function()
    return cc.Scene:create()
end)

function GameScene.create()
    local scene = GameScene.new()
    return scene
end

--*****************************************************************--
--3D晃动的特效
local shaky3d = function () 
    return cc.Shaky3D:create(2,cc.size(50,50),10,false)
end
--3D瓷砖晃动特效
local shakyTiles3D = function ()
    return cc.ShakyTiles3D:create(2,cc.size(50,50),10,false)
end

local wave = function()
    return cc.Waves:create(5, cc.size(10, 10), 10, 20, true, true)
end

--3D水波纹特效 CCWaves3D
local waves3D = function()
    return cc.Waves3D:create(5, cc.size(10, 10), 10, 20)
end

--3D瓷砖波动特效 
local wavesTiles3D = function()
    return cc.WavesTiles3D:create(5, cc.size(10, 10), 10, 20)
end

--X轴 3D反转特效 
local filpX = function()
    return cc.FlipX:create(5)
end

--Y轴3D反转特效
local filpY = function()
    return cc.FlipY:create(5)
end

--凸透镜特效
local lens3D = function()
    return cc.Lens3D:create(2, cc.size(10, 10),cc.p(240, 160), 240)
end

--水波纹特效 
local ripple3D = function()
    return cc.Ripple3D:create(5, cc.size(10, 10), cc.p(240, 160), 240, 4, 160)
end

--液体特效
local liquid = function()
    return cc.Liquid:create(5, cc.size(10, 10), 4, 20)
end

--扭曲旋转特效  
local twirl = function()
    return cc.Twirl:create(50, cc.size(10, 10), cc.p(240, 160), 2, 2.5)
end

--破碎的3D瓷砖特效  
local shatteredTiles3D = function()
    return cc.ShatteredTiles3D:create(15, cc.size(10, 10), 50, true)
end

--瓷砖洗牌特效  
local shuffle = function()
    return cc.ShuffleTiles:create(5, cc.size(50, 50), 50)
end 

--部落格效果,从左下角到右上角  
local fadeOutTRTiles = function()
    return cc.FadeOutTRTiles:create(5, cc.size(50, 50))
end 

--折叠效果 从下到上  
local fadeOutUpTiles = function()
    return cc.FadeOutUpTiles:create(5, cc.size(20, 50))
end 

--折叠效果，从上到下  
local fadeOutDownTiles = function()
    return cc.FadeOutDownTiles:create(5, cc.size(20, 50))
end

--方块消失特效  
local turnOffFiels = function()
    return cc.TurnOffTiles:create(5, cc.size(50, 50))
end

--跳动的方块特效  
local jumpTiles3D = function()
    return cc.JumpTiles3D:create(5, cc.size(20, 20), 5, 20)
end

--分多行消失特效  
local splitCols = function()
    return cc.SplitCols:create(5,50)
end

--分多列消失特效  
local splitRows = function()
    return cc.SplitRows:create(5,50)
end 

--3D翻页特效  
local pageTurn3D = function()
    return cc.PageTurn3D:create(5,cc.size(20,20))
end 
--*****************************************************************--

local ActionList = {
    shaky3d,
    shakyTiles3D,
    wave,
    waves3D,
    wavesTiles3D,
    lens3D,
    ripple3D,
    liquid,
    twirl,
    shatteredTiles3D,
    shuffle,
    fadeOutTRTiles,
    fadeOutUpTiles,
    fadeOutDownTiles,
    turnOffFiels,
    jumpTiles3D,
    splitCols,
    splitRows,
    pageTurn3D,
}

local ActionListName = {
    '3D晃动的特效:Shaky3D',
    '3D瓷砖晃动特效:ShakyTiles3D',
    '波动特效:Waves',
    '3D水波纹特效 Waves3D',
    '3D瓷砖波动特效 :WavesTiles3D',
    '凸透镜特效:Lens3D',
    '水波纹特效 :Ripple3D',
    '液体特效:Liquid',
    '扭曲旋转特效:Twirl',
    '破碎的3D瓷砖特效  :ShatteredTiles3D',
    '瓷砖洗牌特效:ShuffleTiles',
    '部落格效果,从左下角到右上角  :fadeOutTRTiles',
    '折叠效果 从下到上  :fadeOutUpTiles',
    '折叠效果，从上到下  :fadeOutDownTiles',
    '方块消失特效：TurnOffTiles',
    '跳动的方块特效  :JumpTiles3D',
    '分多行消失特效  :SplitCols',
    '分多列消失特效:splitRows ',
    '3D翻页特效 :PageTurn3D'

}        

function LoadingPanel:init()

    -- local DBData = LUADB.select("select * from treasure where id=1", "id:name:pic:need");
    -- local DBDataList = LUADB.selectlist("select * from treasure", "id:name:pic:need");
    
    MGRCManager:cacheResource(this, "bg.jpg");
    MGRCManager:cacheResource(this, "menu.png","menu.plist");
    local bjSprite =  cc.Sprite:createWithSpriteFrameName("bg.jpg");
    bjSprite:setAnchorPoint(cc.p(0.5, 0.5))
    -- bjSprite:setPosition(cc.p(self:getContentSize().width/2, self:getContentSize().height/2))
    -- self:addChild(bjSprite)
    -- CommonMethod:setVisibleScale(bjSprite,self);


    -- bjSprite:setScale(0.1)  
    -- bjSprite:setOpacity(0)  
    -- local action1 = cc.Spawn:create(cc.ScaleTo:create(0.15, 2.0),cc.FadeTo:create(0.15,255))  
    -- local action  = cc.Sequence:create(action1,cc.DelayTime:create(1.0)) 
    -- bjSprite:runAction(action)

    self.nodegird = cc.NodeGrid:create()
    bjSprite:setPosition(cc.p(self.nodegird:getContentSize().width/2, self.nodegird:getContentSize().height/2))
    self.nodegird:addChild(bjSprite)
    self.nodegird:setPosition(cc.p(self:getContentSize().width/2, self:getContentSize().height/2))
    self:addChild(self.nodegird)


    self.currentId = 1
    
    local function overAction()
        self.nodegird:stopAllActions()
        self.nodegird:setGrid(nil)
    end

    local function changeAction()
        if self.currentId > #ActionList then
            self.currentId = 1
        end
        self.nodegird:stopAllActions()
        local fun = ActionList[self.currentId]
        local actionInterval = fun()
        self.nodegird:setGrid(nil)
        local func = cc.CallFunc:create(overAction)
        local sq = cc.Sequence:create(actionInterval,func)
        self.nodegird:runAction(sq)
        self._nameLabel:setString(ActionListName[self.currentId])
        self.currentId = self.currentId + 1  
    end



    local menuRun = cc.MenuItemFont:create("ChangeAction")
    menuRun:setPosition(0, 0)
    menuRun:registerScriptTapHandler(changeAction)
    local menu = cc.Menu:create(menuRun)
    menu:setPosition(400,50)
    self:addChild(menu,2)

    local menuRun1 = cc.MenuItemFont:create("overAction")
    menuRun1:setPosition(0, 0)
    menuRun1:registerScriptTapHandler(overAction)
    local menu1 = cc.Menu:create(menuRun1)
    menu1:setPosition(800,50)
    self:addChild(menu1,2)
    
    local hintConfig  = {}
    hintConfig.fontFilePath= ttf_msyh
    hintConfig.fontSize = 25
    local nameLable = cc.Label:create()
    nameLable:setTTFConfig(hintConfig)
    nameLable:setPosition(self:getContentSize().width/2,self:getContentSize().height-50)
    self:addChild(nameLable)
    self._nameLabel = nameLable

    local pWidget = MGRCManager:widgetFromJsonFile("LoadingPanel","NewUi_1.ExportJson")
    self:addChild(pWidget,1)
    CommonMethod:setVisibleSize(pWidget)

    local Panel_bg = pWidget:getChildByName("Panel_1")

    local function onButtonClick(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            local sc = cc.ScaleTo:create(0.1, 1.1)
            sender:runAction(cc.EaseOut:create(sc ,2))
        end
        if eventType == ccui.TouchEventType.canceled then
            local sc = cc.ScaleTo:create(0.1, 1)
            sender:runAction(sc)
        end
        if eventType == ccui.TouchEventType.ended then
            local sc = cc.ScaleTo:create(0.1, 1)
            sender:runAction(sc)
            if sender == self.Button_sodier then
                 --enterLuaScene(SCENEINFO.LOGIN_SCENE,1,0,0,0);
                 local _Layer = sodierShow.create()
                 cc.Director:getInstance():getRunningScene():addChild(_Layer,ZORDER_MAX)
            elseif sender == self.Button_matrix then
                 LuaBackCpp:enterLuaScene(SCENEINFO.LOGIN_SCENE,2,0,0,0);
            elseif sender == self.Button_fight then
                 LuaBackCpp:enterLuaScene(SCENEINFO.LOGIN_SCENE,3,0,0,0);
            elseif sender == self.Button_map then
                 -- MGMessageTip:showFailedMessage("地图");
                self:addMainLineLayer();
            elseif sender == self.Button_link then
                self:sendReq();
            elseif sender == self.Button_login then
                addLoginManager();
                self:removeFromParent();
            end
            
        end
    end
    self.Button_sodier = Panel_bg:getChildByName("Button_sodier")
    self.Button_sodier:addTouchEventListener(onButtonClick)
    self.Button_map = Panel_bg:getChildByName("Button_map")
    self.Button_map:addTouchEventListener(onButtonClick)
    self.Button_link = Panel_bg:getChildByName("Button_link")
    self.Button_link:addTouchEventListener(onButtonClick)
    self.Button_matrix = Panel_bg:getChildByName("Button_matrix")
    self.Button_matrix:addTouchEventListener(onButtonClick)
    self.Button_fight = Panel_bg:getChildByName("Button_fight")
    self.Button_fight:addTouchEventListener(onButtonClick)
    self.Button_login = Panel_bg:getChildByName("Button_login")
    self.Button_login:addTouchEventListener(onButtonClick)
end

function LoadingPanel:addMainLineLayer()
    -- local MainLineLayer = MainLineLayer.showBox();
    --enterLuaLayer(SCENEINFO.MAP_SCENE);
    LuaBackCpp:enterLuaScene(SCENEINFO.MAP_SCENE,0,0,0,0);
end

function LoadingPanel:sendReq()
    -- local postdata = {};
    -- postdata.cmd = Post_doPassportLogin;
    -- postdata.name = "test";
    -- postdata.psw  = "123456";
    -- local str = cjson.encode(postdata)

    --@Input    account String 平台用户ID
    --          pwd String 平台token
    --          sid Int 服务器序号
    --husong1 admins
    local str = string.format("&account=%s&pwd=%s&sid=%d","husong1","admins",1)
    NetHandler:sendData(Post_doPassportLogin, str);
end

function LoadingPanel:onReciveData(MsgID, NetData)
    print("LoadingPanel onReciveData MsgID:"..MsgID)
    if MsgID == Post_doPassportLogin then
        local ackData = NetData
        if ackData.state == 1 then
            --MGMessageTip:showFailedMessage(string.format("连接成功(%s)",ackData.account));
-- @Input        account String 用户账号
--               use_id String 使用用户ID(0选择第一个角色)
--               is_debug 0 or 1 default 0 是否测试
--               version String 版本号
--               from String 来源
            local str = string.format("&account=%s&sess_id=%s&use_id=0&is_debug=0&version=0&from=0",ackData.dopassportlogin.account,ackData.dopassportlogin.sess_id)
            NetHandler:sendData(Post_doLogin, str);
        else
            NetHandler:showFailedMessage(ackData)
        end
    elseif  MsgID == Post_doLogin then
        local ackData = NetData
        if ackData.state == 1  then
            if ackData.dologin.ret==1 then
                ME:setSevTime(ackData.dologin.server_time);
                ME:setUid(ackData.dologin.uid);
                ME:setVerfiy(ackData.dologin.verfiy);
                NetHandler:sendData(Post_getGenerals, "");
                NetHandler:sendData(Post_getStorage, "");
                MGMessageTip:showFailedMessage(string.format("连接成功(%s)",ackData.dologin.uid));
            else
                MGMessageTip:showFailedMessage(MG_TEXT("Login_err"));
            end
        else
            NetHandler:showFailedMessage(ackData)
        end
    elseif  MsgID == Post_getGenerals then
        local ackData = NetData
        if ackData.state == 1  then

        else
            NetHandler:showFailedMessage(ackData)
        end
    elseif  MsgID == Post_getStorage then
        local ackData = NetData
        if ackData.state == 1  then

        else
            NetHandler:showFailedMessage(ackData)
        end
    end
end

function LoadingPanel:pushAck()
    NetHandler:addAckCode(self,Post_doPassportLogin);
    NetHandler:addAckCode(self,Post_doLogin);
    NetHandler:addAckCode(self,Post_getGenerals);
    NetHandler:addAckCode(self,Post_getStorage);
end

function LoadingPanel:popAck()
    NetHandler:delAckCode(self,Post_doPassportLogin);
    NetHandler:delAckCode(self,Post_doLogin);
    NetHandler:delAckCode(self,Post_getGenerals);
    NetHandler:delAckCode(self,Post_getStorage);
end

function LoadingPanel:onEnter()
    self:pushAck();
end

function LoadingPanel:onExit()
    MGRCManager:releaseResources("LoadingPanel")
    self:popAck();
    s_LoadingPanel = nil;
end

function LoadingPanel.create()
    local layer = LoadingPanel:new()
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

s_LoadingPanel = nil;
function addLoadingPanel()
    local layer = LoadingPanel.create()
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX)
    s_LoadingPanel = layer;
end

function delLoadingPanel()
    if s_LoadingPanel then
        s_LoadingPanel:removeFromParent() 
    end
end




