-----------------------仓库界面------------------------

PanelTop = class("PanelTop", MGLayer)
function PanelTop:ctor()
    self:init();
end

function PanelTop:init()
    MGRCManager:cacheResource("PanelTop", "main_top_bg.png");
    local pWidget = MGRCManager:widgetFromJsonFile("PanelTop","paneltop_ui_1.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);
    
    local Panel_2 = pWidget:getChildByName("Panel_2");
    local Panel_top = Panel_2:getChildByName("Panel_top");
    self.Button_back = Panel_top:getChildByName("Button_back");
    self.Button_back:addTouchEventListener(handler(self,self.onButtonClick));

    local Panel_mas = Panel_top:getChildByName("Panel_mas");
    self.Button_add1 = Panel_mas:getChildByName("Button_add");
    self.Button_add1:addTouchEventListener(handler(self,self.onButtonClick));
    self.Label_mas = Panel_mas:getChildByName("Label_num");

    local Panel_gold = Panel_top:getChildByName("Panel_gold");
    self.Button_add2 = Panel_gold:getChildByName("Button_add");
    self.Button_add2:addTouchEventListener(handler(self,self.onButtonClick));
    self.Label_gold = Panel_gold:getChildByName("Label_num");

    local Panel_action = Panel_top:getChildByName("Panel_action");
    self.Button_add3 = Panel_action:getChildByName("Button_add");
    self.Button_add3:addTouchEventListener(handler(self,self.onButtonClick));
    self.Label_action = Panel_action:getChildByName("Label_num");

    self.Image_title = Panel_top:getChildByName("Image_title");

    self.Image_rankcoin = Panel_top:getChildByName("Image_rankcoin");
    self.Label_rankcoin = self.Image_rankcoin:getChildByName("Label_rankcoin");
end

function PanelTop:setData(fileName)
    self.Image_title:loadTexture(fileName,ccui.TextureResType.plistType);
    self:upData()
end

function PanelTop:upData()
    local num = ME:getAction();
    local num2 = 81;
    local str1 = string.format("%d",num);
    if num >= 100000 then
        num = num/10000;
        str1 = string.format(MG_TEXT("WAN"),num);
    end
    
    local sql = string.format("select * from user_lv where lv=%d", ME:Lv());
    local DBData = LUADB.select(sql, "max_action");
    if DBData then
        num2 = DBData.info.max_action;
    end
    self.Label_action:setText(string.format("%s/%d",str1,num2));
    self.Label_gold:setText(MGDataHelper:formatNumber(ME:getCoin()));
    self.Label_mas:setText(MGDataHelper:formatNumber(ME:getGold()));
end

function PanelTop:showRankCoin(bshow)
    self.Image_rankcoin:setVisible(bshow);
    self.Label_rankcoin:setVisible(bshow);
end

function PanelTop:setRankCoin(value)
    self.Label_rankcoin:setText(MGDataHelper:formatNumber(value));
end

function PanelTop:setRankCoinPic(fileName)
    self.Image_rankcoin:loadTexture(fileName,ccui.TextureResType.plistType);
end

function PanelTop:onButtonClick(sender, eventType)
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
        if sender == self.Button_minus or sender == self.Button_add or sender == self.Button_max then
            self:setNum(sender);
        elseif sender == self.Button_back then--返回
            if self.delegate and self.delegate.back then
                self.delegate:back();
            end
        end
    end
end

function PanelTop:onEnter()
end

function PanelTop:onExit()

    MGRCManager:releaseResources("PanelTop");
end

function PanelTop.create(delegate)
    local layer = PanelTop:new()
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
