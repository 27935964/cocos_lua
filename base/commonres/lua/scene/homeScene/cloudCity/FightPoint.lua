----云中城猜拳点界面----
local FightPoint=class("FightPoint",function()
	return cc.Layer:create();
end);

function FightPoint:ctor(delegate)
  	self.delegate=delegate;
    self.diceContent=delegate.diceContent;
    -- 
    self.winNum=0;
    self.loseNum=0;
    self.chooseIndex=0;
    self.savePos={x=0,y=0};
    self.reward="";
    self.fightReward=nil;
    self.moveSp=nil;
    -- 
  	self.pWidget=MGRCManager:widgetFromJsonFile("FightPoint", "CloudCity_FightPoint_Ui.ExportJson");
  	self:addChild(self.pWidget);

  	local panel_2 = self.pWidget:getChildByName("Panel_2");--Panel
    self.panel_3=self.pWidget:getChildByName("Panel_3");
    self:setNoCanClick(false);
    -- 
    self.img_unKnown=panel_2:getChildByName("Image_Unknown"); 
    self.img_vs=panel_2:getChildByName("Image_VSIcon");
    self.moveSp=cc.Sprite:createWithSpriteFrameName("CloudCity_FightPoint_Win.png");
    self.moveSp:setVisible(false);
    panel_2:addChild(self.moveSp,1); 
    -- 
    self.img_win=panel_2:getChildByName("Image_Win");
    self.img_winNum=self.img_win:getChildByName("Image_0");
    self.img_lose=panel_2:getChildByName("Image_Lose");  
    self.img_loseNum=self.img_lose:getChildByName("Image_0");
    -- 
    self.skillTab={};
    for i=1,3 do
        local skillBtn=panel_2:getChildByName(string.format("Image_Skill%d",i));
        skillBtn:addTouchEventListener(handler(self,self.skillBtnClick));
        table.insert(self.skillTab,skillBtn); 
    end
    -- tips
    self.img_bubble=panel_2:getChildByName("Image_Bubble");
    -- 图片
    self.img_angel=panel_2:getChildByName("Image_Angel");
    -- 名称 
    self.img_name=panel_2:getChildByName("Image_23");
    -- 星级
    self.panel_24=panel_2:getChildByName("Panel_24");
    -- 
   	NodeListener(self);
    -- 
    local str_list=spliteStr(self.diceContent,'|');
    self.winNum=tonumber(str_list[1]);
    self.loseNum=tonumber(str_list[2]);
    self:setWinLose();
    -- 
    self:initData();
    --
    -- 
    -- local Panel_1 = self.pWidget:getChildByName("Panel_1")
    -- local function closeClick(sender,eventType)
    --     if eventType == ccui.TouchEventType.ended then
    --         self:removeFromParentAndCleanup(true);
    --     end
    -- end
    -- Panel_1:addTouchEventListener(closeClick)

    -- self.winNum=2;
    -- self.loseNum=0
    -- self.reward="18:1:50|18:1:50"
    -- local FightReward=require "FightReward";
    -- local reward=FightReward.new(self.reward,self.winNum,self.loseNum);
    -- self:addChild(reward);
end

function FightPoint:setNoCanClick(isVisible)
    self.panel_3:setTouchEnabled(isVisible);
end

function FightPoint:setEndIndex(is_win)
    -- is_win Int 是否胜利 0失败 1胜利 2平局
    local endIndex=1;
    if self.chooseIndex==2 then
        if is_win==0 then
            endIndex=3;
            self.loseNum=self.loseNum+1;
        elseif is_win==1 then
            endIndex=1;
            self.winNum=self.winNum+1;
        else
            endIndex=2;
        end 
    elseif self.chooseIndex==3 then
        if is_win==0 then
            endIndex=1;
            self.loseNum=self.loseNum+1;
        elseif is_win==1 then
            endIndex=2;
            self.winNum=self.winNum+1;
        else
            endIndex=3;
        end 
    else
        if is_win==0 then
            endIndex=2;
            self.loseNum=self.loseNum+1;
        elseif is_win==1 then
            endIndex=3;
            self.winNum=self.winNum+1;
        else
            endIndex=1;
        end 
    end
    self.endIndex=endIndex;
    self:startRandom();
end

function FightPoint:initData()
    if self.delegate then
        local sx=10;
        local width=250;
        local gridDb=self.delegate:getCloudGridDB();
        local tipsLabel=cc.Label:createWithTTF(gridDb.des, ttf_msyh, 20);
        tipsLabel:setDimensions(width-sx*2-5, 0);
        tipsLabel:setAnchorPoint(cc.p(0, 1));
        tipsLabel:setColor(cc.c3b(115, 0, 2));
        self.img_bubble:addChild(tipsLabel);
        -- 
        local height=tipsLabel:getContentSize().height;
        -- print("height==",height)
        if height>50 then
            height=height+230;
            self.img_bubble:setScale9Enabled(true);
            self.img_bubble:setCapInsets(cc.rect(150, 70, 1, 1));
            self.img_bubble:setSize(cc.size(width,height));
        end
        tipsLabel:setPosition(cc.p(sx, self.img_bubble:getContentSize().height-10));
        -- 
        local markImg=ccui.ImageView:create("CloudCity_FightPoint_RestraintRelationship.png", ccui.TextureResType.plistType); 
        markImg:setAnchorPoint(cc.p(0.5,1));
        markImg:setPosition(width/2,tipsLabel:getPositionY()-tipsLabel:getContentSize().height-10);
        self.img_bubble:addChild(markImg);
        -- 
        self.delegate:showAngelInfo(nil,self.img_angel,self.img_name,self.panel_24,false);
    end
    self:resetFight();
end

function FightPoint:resetFight()
    -- 每一局开始初始化
    self.endIndex=0;
    self._current=0;
    self._country=0;
    self._speed=200;
    -- 
    self.img_unKnown:loadTexture("CloudCity_FightPoint_Unknown.png", ccui.TextureResType.plistType);
    for i=1,table.getn(self.skillTab) do
        local skillBtn=self.skillTab[i];
        if self.chooseIndex==i then
            skillBtn:setPosition(self.savePos.x,self.savePos.y);
        else
            skillBtn:setVisible(true);
        end
    end
end

function FightPoint:setWinLose()
    self.img_winNum:loadTexture(string.format("CloudCity_FightPoint_Number%d.png",self.winNum), ccui.TextureResType.plistType);
    self.img_loseNum:loadTexture(string.format("CloudCity_FightPoint_Number%d.png",self.loseNum), ccui.TextureResType.plistType);
end

function FightPoint:actionOver()
    self:setWinLose();
    -- 胜负3局/或者2胜/或者2负,就算结束了
    if self.winNum+self.loseNum>=3 or self.winNum>=2 or self.loseNum>=2 then
        self:setNoCanClick(true);
        -- 延迟关闭
        -- local function delayClose()
        --     self:closeFight();
        -- end
        -- local delay=cc.DelayTime:create(1.5);
        -- local callFunc=cc.CallFunc:create(delayClose);
        -- self:runAction(cc.Sequence:create(delay,callFunc));
    else
        self:resetFight();
        self:setNoCanClick(false);
    end
    if string.len(self.reward)>0 then
        local function delayDeal()
            if self.fightReward==nil then
                local FightReward=require "FightReward";
                self.fightReward=FightReward.new(self,self.reward,self.winNum,self.loseNum);
                self:addChild(self.fightReward);
            end
        end
        local delay=cc.DelayTime:create(1.0);
        local callFunc=cc.CallFunc:create(delayDeal);
        self:runAction(cc.Sequence:create(delay,callFunc));
    end
end

function FightPoint:startRandom()
    self._current=1;
    self._country=self.endIndex;
    self:random(1,self.endIndex);
end

function FightPoint:random(current, country)
    self._current = current
    self._country = country

    local tmpVal = current%3
    if tmpVal==0 then
        tmpVal = 3
    end
    self:setSelected(tmpVal)

    if current>30 and country==tmpVal then
        self:stopAllActions()
        -- 随机完
        -- local function delayDeal()
        --     self:stopAllActions()
        --     self:actionOver();
        -- end
        -- local time = cc.DelayTime:create(2.0)
        -- local func = cc.CallFunc:create(delayDeal)
        -- local seq = cc.Sequence:create(time,func)
        -- self:runAction(seq)

        -- is_win Int 是否胜利 0失败 1胜利 2平局
        self.moveSp:stopAllActions();
        self.moveSp:setPosition(self.img_vs:getPosition());
        local moveName="CloudCity_FightPoint_flat.png";
        local pos=cc.p(self.moveSp:getPositionX(),self.moveSp:getPositionY()+100);
        if self.is_win==0 then
            moveName="CloudCity_FightPoint_Lose.png";
            pos=cc.p(self.img_lose:getPositionX(),self.img_lose:getPositionY());
        elseif self.is_win==1 then
            moveName="CloudCity_FightPoint_Win.png";
            pos=cc.p(self.img_win:getPositionX(),self.img_win:getPositionY());
        end
        local fadein = cc.FadeIn:create(0.1);
        local scaleBy = cc.ScaleBy:create(0.1, 1.2);
        local spawn = cc.Spawn:create(fadein,scaleBy);
        local delay = cc.DelayTime:create(0.8);
        local moveTo = cc.MoveTo:create(0.3, cc.p(pos.x,pos.y));
        local fadeout = cc.FadeOut:create(0.3);
        local spawn2 = cc.Spawn:create(moveTo,fadeout);
        local callFun = cc.CallFunc:create(function()
            self:stopAllActions()
            self:actionOver();
        end);
        local seq = cc.Sequence:create(spawn,delay,spawn2,callFun)
        self.moveSp:setVisible(true);
        self.moveSp:setSpriteFrame(moveName);
        self.moveSp:runAction(seq)
    else
        if current < 15 then
            self._speed = self._speed-12
        else
            self._speed = self._speed+12
        end
        self._current = self._current+1

        local function resest()
            self:random(self._current,self._country)
        end
        local time = cc.DelayTime:create(self._speed/1000)
        local func = cc.CallFunc:create(resest)
        local seq = cc.Sequence:create(time,func)
        self:runAction(seq)
    end
end

function FightPoint:setSelected(endIndex)
    -- print("endIndex==", endIndex)
    local imgName="CloudCity_FightPoint_Skill1.png";
    if endIndex==2 then
        imgName="CloudCity_FightPoint_Skill2.png";
    elseif endIndex==3 then
        imgName="CloudCity_FightPoint_Skill3.png";
    end
    self.img_unKnown:loadTexture(imgName, ccui.TextureResType.plistType);
end

function FightPoint:skillBtnClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        for i=1,table.getn(self.skillTab) do
            local skillBtn=self.skillTab[i];
            if sender==skillBtn then
                self.chooseIndex=i;
                self.savePos.x=skillBtn:getPositionX();
                self.savePos.y=skillBtn:getPositionY();
                skillBtn:setPosition(self.skillTab[2]:getPosition());
            else
                skillBtn:setVisible(false);
            end
        end
        -- 
        NetHandler:sendData(Post_Cloud_Main_doMora, "");
        self:setNoCanClick(true);
    end
end

function FightPoint:onReciveData(msgId, netData)
	  if msgId == Post_Cloud_Main_doMora then
      	if netData.state == 1 then
            local domora=netData.domora;
            self.diceContent=domora.content;
            self.is_win=domora.is_win;
            -- 
            self.reward=domora.reward;
            -- 
            local coin=domora.get_coin;
            local stone=domora.get_stone;
            if self.delegate then
                self.delegate:changeTopInfo(coin,stone);
            end
            -- 
            self:setEndIndex(self.is_win);
      	else
          	NetHandler:showFailedMessage(netData);
      	end
  	end
end

function FightPoint:closeOpenReward()
    if self.fightReward then
        self.fightReward:removeFromParentAndCleanup(true);
        self.fightReward=nil;
    end
    self:closeFight();
end

function FightPoint:closeFight()
    if self.delegate then
        self.delegate:closeOpenLayer();
    end
end

function FightPoint:onEnter()
    NetHandler:addAckCode(self,Post_Cloud_Main_doMora);
end

function FightPoint:onExit()
	  NetHandler:delAckCode(self,Post_Cloud_Main_doMora);
	  MGRCManager:releaseResources("FightPoint");
end

return FightPoint;
