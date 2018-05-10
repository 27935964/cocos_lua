------------------------战斗结果-------------------------
require "HeroHead"
require "Item"
FightResult = class("FightResult", MGLayer)

function FightResult:ctor()
    self:init();
end

function FightResult:init()
    MGRCManager:cacheResource("FightResult", "fight_resultf_bg.png");
    MGRCManager:cacheResource("FightResult", "fight_resultv_bg.png");
    local pWidget = MGRCManager:widgetFromJsonFile("FightResult","FightResult_1.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);

    local Panel_2 = pWidget:getChildByName("Panel_2");

    local Image_bg = Panel_2:getChildByName("Image_bg");
    self.Image_head = Panel_2:getChildByName("Image_head");

    --回放
    self.Button_replay = Panel_2:getChildByName("Button_replay");
    self.Button_replay:addTouchEventListener(handler(self,self.onButtonClick));
    --退出战斗
    self.Button_exit = Panel_2:getChildByName("Button_exit");
    self.Button_exit:addTouchEventListener(handler(self,self.onButtonClick));

    self.Label_replay= self.Button_replay:getChildByName("Label_replay");
    self.Label_replay:setVisible(false);
    local replayLabel = cc.Label:createWithTTF(MG_TEXT_COCOS("FightResult_1"),ttf_msyh,22);
    replayLabel:setPosition(cc.p(self.Button_replay:getContentSize().width/2,self.Button_replay:getContentSize().height/2))
    self.Button_replay:addChild(replayLabel);
    replayLabel:enableShadow(Color4B.BLACK, cc.size(1, -1),1);

    self.Label_exit= self.Button_exit:getChildByName("Label_exit");
    self.Label_exit:setVisible(false);
    local exitLabel = cc.Label:createWithTTF(MG_TEXT_COCOS("FightResult_2"),ttf_msyh,22);
    exitLabel:setPosition(cc.p(self.Button_exit:getContentSize().width/2,self.Button_exit:getContentSize().height/2))
    self.Button_exit:addChild(exitLabel);
    exitLabel:enableShadow(Color4B.BLACK, cc.size(1, -1),1);

    self.Panel_soldier = Panel_2:getChildByName("Panel_soldier");
    local Label_lost0= self.Panel_soldier:getChildByName("Label_lost0");
    local Label_lost1= self.Panel_soldier:getChildByName("Label_lost1");
    local Label_have0= self.Panel_soldier:getChildByName("Label_have0");
    local Label_have1= self.Panel_soldier:getChildByName("Label_have1");
    Label_lost0:setText(MG_TEXT_COCOS("FightResult_3"));
    Label_lost1:setText(MG_TEXT_COCOS("FightResult_5"));
    Label_have0:setText(MG_TEXT_COCOS("FightResult_4"));
    Label_have1:setText(MG_TEXT_COCOS("FightResult_6"));

    self.Label_lost_num0= self.Panel_soldier:getChildByName("Label_lost_num0");
    self.Label_lost_num1= self.Panel_soldier:getChildByName("Label_lost_num1");
    self.Label_have_num0= self.Panel_soldier:getChildByName("Label_have_num0");
    self.Label_have_num1= self.Panel_soldier:getChildByName("Label_have_num1");

    self.listleft = self.Panel_soldier:getChildByName("ListView_left");
    self.listright = self.Panel_soldier:getChildByName("ListView_right");

    self.Panel_award= Panel_2:getChildByName("Panel_award");
    self.listaward = self.Panel_award:getChildByName("ListView_award");
    self.Panel_upgrade = Panel_2:getChildByName("Panel_upgrade");

    self.Panel_soldier:setVisible(false);
    self.Panel_award:setVisible(false);
    self.Panel_upgrade:setVisible(false);
end

function FightResult:setData(getitem,result_army)
    local lose = 0;
    local forces = 0;
    self.listleft:setItemsMargin(5);
    for i=1,#result_army.atk do
        local gm = self:getHero(result_army.atk[i])
        local item = HeroHead.create();
        if result_army.atk[i].npc_id==0 then
            item:setData(gm,false);
        else
            item:setData(gm,true);
        end
        if result_army.atk[i].is_dead==1 then
            item:setIsGray(true);
        end
        item:setScale(0.9);
        self.listleft:pushBackCustomItem(item);
        lose = lose + result_army.atk[i].lose;
        forces = forces + result_army.atk[i].forces;
    end
    self.Label_lost_num0:setText(""..lose);
    self.Label_have_num0:setText(""..forces);

    lose = 0;
    forces = 0;
    self.listright:setItemsMargin(5);
    for i=1,#result_army.dfd do
        local gm = self:getHero(result_army.dfd[i])
        local item = HeroHead.create();
        if result_army.dfd[i].npc_id==0 then
            item:setData(gm,false);
        else
            item:setData(gm,true);
        end
        if result_army.dfd[i].is_dead==1 then
            item:setIsGray(true);
        end
        item:setScale(0.9);
        self.listright:pushBackCustomItem(item);
        lose = lose + result_army.dfd[i].lose;
        forces = forces + result_army.dfd[i].forces;
    end
    self.Label_lost_num1:setText(""..lose);
    self.Label_have_num1:setText(""..forces);

    self.listaward:setItemsMargin(5);
    local list = getneedlist(getitem);
    local count = #list;
    local w = 0;
    for i=1,count do
        local item = resItem.create();
        item:setData(list[i].type,list[i].id);
        item:setNum(list[i].num);
        item:setScale(0.9);
        w=item:getContentSize().width;
        self.listaward:pushBackCustomItem(item);
    end
    if count<5 then
        self.listaward:setSize(cc.size((w+5)*count, 163));
        self.listaward:setPositionX((self.Panel_award:getSize().width-self.listaward:getSize().width)/2);
    end

    if result_army.result == 0 then
        self.Image_head:loadTexture("fight_resultf_head.png", ccui.TextureResType.plistType);
        self.Panel_award:setVisible(false);
        self.Panel_upgrade:setVisible(true);
        for i=1,3 do
            local Image_star = self.Image_head:getChildByName(string.format("Image_star_%d",i-1));
            if i<=result_army.war_star then
                Image_star:setVisible(false)
            else
                Image_star:setVisible(true);
            end
        end
        
    else
        self.Image_stars = {};
        for i=1,3 do
            local Image_star = self.Image_head:getChildByName(string.format("Image_star_%d",i-1));
            Image_star:setVisible(false)
            if i<=result_army.war_star then
                table.insert(self.Image_stars, Image_star);
            end
        end

        self.Image_head:setScale(3);
        self.Image_head:setOpacity(0);
        local scaleTo1 = cc.ScaleTo:create(0.03, 1);
        local callFunc=cc.CallFunc:create(handler(self,self.starDisplay));
        local action   = cc.Sequence:create(scaleTo1,callFunc) 
        self.Image_head:runAction(action);
        self.Image_head:runAction(cc.FadeTo:create(0.2, 255));
    end
end


function FightResult:getHero(info)
    local str = cjson.encode(info);
    local gm;
    if info.npc_id==0 then
        gm = GeneralModel:create(info.g_id,false);
    else
        gm = NPCGeneralModel:create(info.npc_id);
    end
    gm:updata(str);
    return gm;
end

function FightResult:starDisplay()
    
    if #self.Image_stars>=1 then
        self.Image_stars[1]:setVisible(true);
        local scaleTo1 = cc.ScaleTo:create(0.1, 2);
        local scaleTo2 = cc.ScaleTo:create(0.08, 0.8);
        local scaleTo3 = cc.ScaleTo:create(0.04, 1.0);
        local callFunc=cc.CallFunc:create(handler(self,self.starDisplay));
        local action   = cc.Sequence:create(scaleTo1,scaleTo2,scaleTo3,callFunc) 
        self.Image_stars[1]:runAction(action);

        table.remove(self.Image_stars,1);
    else
        self.Panel_soldier:setVisible(true);
        self.Panel_award:setVisible(true);
    end

end

function FightResult:onButtonClick(sender, eventType)
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
        if sender == self.Button_replay then
            self:removeFromParent();
            LuaBackCpp:rePlay();
        elseif sender == self.Button_exit then
            if self.delegate and self.delegate.ResultBack then
                self.delegate:ResultBack();
            end
            self:removeFromParent();
        end
    end
end


function FightResult:onEnter()

end

function FightResult:onExit()
    MGRCManager:releaseResources("FightResult")
end

function FightResult.create(delegate)
    local layer = FightResult:new()
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

function showFightResult()
    local layer = FightResult.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
