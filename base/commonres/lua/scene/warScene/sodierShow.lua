SodierCocos = require "SodierCocos"

sodierShow = class("sodierShow", MGLayer)

function sodierShow:ctor()
    self.pWidget = nil;
    self.panel = nil;
    self.panel_list = nil;
    self.datas = nil;
    self.Button_arena = nil;
end
   
function sodierShow:init()
    local pWidget = MGRCManager:widgetFromJsonFile("sodierShow","sodierUi_1.ExportJson")
    self:addChild(pWidget)
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
            if sender == self.Button_stand then
                self.sodier:showAction(Sodier.AStand);
            elseif sender == self.Button_run then
                self.sodier:showAction(Sodier.ARun);
            elseif sender == self.Button_attack then
                self.sodier:showAction(Sodier.AAttack);
            elseif sender == self.Button_die then
                self.sodier:showAction(Sodier.ADie,handler(self,self.alive));
            elseif sender == self.Button_skill then
                self.sodier:showAction(Sodier.ASkill);
            elseif sender == self.Button_close then
                self:removeFromParent();
            end
            
        end
    end
    self.Button_stand = Panel_bg:getChildByName("Button_stand")
    self.Button_stand:addTouchEventListener(onButtonClick)
    self.Button_run = Panel_bg:getChildByName("Button_run")
    self.Button_run:addTouchEventListener(onButtonClick)
    self.Button_attack = Panel_bg:getChildByName("Button_attack")
    self.Button_attack:addTouchEventListener(onButtonClick)
    self.Button_die = Panel_bg:getChildByName("Button_die")
    self.Button_die:addTouchEventListener(onButtonClick)
    self.Button_skill = Panel_bg:getChildByName("Button_skill")
    self.Button_skill:addTouchEventListener(onButtonClick)
    self.Button_close = Panel_bg:getChildByName("Button_close")
    self.Button_close:addTouchEventListener(onButtonClick)


    self.sodier=SodierCocos.new();
    self.sodier:init(self,Sodier.KCavalry,Sodier.DLeft);
    self.sodier:setPosition(self:getContentSize().width/2,self:getContentSize().height/2)
end

function sodierShow:alive(sodier)
    sodier:relive();
end

function sodierShow:onEnter()

end

function sodierShow:onExit()
    MGRCManager:releaseResources("sodierShow")
end

function sodierShow.create()
    local layer = sodierShow:new()
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






