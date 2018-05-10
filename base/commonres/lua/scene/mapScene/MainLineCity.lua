--------------------------主线城池-----------------------
local MainLineCity = class("MainLineCity", MGWidget)

function MainLineCity:init(delegate,widget)
    self.delegate=delegate;
    self:addChild(widget);
    self.pWidget = widget;

    self.timer = CCTimer:new();
    self.leftTime = 0;

    self:setAnchorPoint(cc.p(0.5,0.5));
    self.pWidget:setAnchorPoint(cc.p(0.5,0.5));

    local Panel_2 = self.pWidget:getChildByName("Panel_2");

    self.Image_city = Panel_2:getChildByName("Image_city");
    self.Image_city:setTouchEnabled(true);
    self.Image_city:addTouchEventListener(handler(self,self.onButtonClick));
    self.oldHeadProgram = self.Image_city:getSprit():getShaderProgram();

    self.Button_war = Panel_2:getChildByName("Button_war");
    self.Button_war:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_event = Panel_2:getChildByName("Button_event");--事件
    self.Button_event:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_incursion = Panel_2:getChildByName("Button_incursion");--入侵
    self.Button_incursion:addTouchEventListener(handler(self,self.onButtonClick));

    self.Panel_bottom = Panel_2:getChildByName("Panel_bottom");
    self.Image_flag = self.Panel_bottom:getChildByName("Image_flag");
    self.Image_totem = self.Image_flag:getChildByName("Image_totem");
    self.Label_cityName = self.Panel_bottom:getChildByName("Label_cityName");

    self.Image_incursion = self.Panel_bottom:getChildByName("Image_bg1");--进入主线
    self.Image_incursion:setTouchEnabled(true);
    self.Image_incursion:addTouchEventListener(handler(self,self.onButtonClick));

    self.Image_headBg = self.Panel_bottom:getChildByName("Image_headBg");
    local HeroCircleHead=require "HeroCircleHead";--菱形头像
    self.circleHead=HeroCircleHead.new("mainLine_head_mod.png",0.98);
    self.circleHead:setPosition(cc.p(self.Image_headBg:getContentSize().width/2,
        self.Image_headBg:getContentSize().height/2));
    self.Image_headBg:addChild(self.circleHead,1);

    self.stars = {};
    for i=1,3 do
        local star = self.Panel_bottom:getChildByName("Image_star"..i);
        table.insert(self.stars,star);
    end

    self.Panel_up = Panel_2:getChildByName("Panel_up");
    self.Image_flag1 = self.Panel_up:getChildByName("Image_flag1");
    self.Image_totem1 = self.Image_flag1:getChildByName("Image_totem1");
    self.Label_name = self.Panel_up:getChildByName("Label_name");
    self.Label_time = self.Panel_up:getChildByName("Label_time");

    self.Image_war = self.Panel_up:getChildByName("Image_bg");--进入公会战
    self.Image_war:addTouchEventListener(handler(self,self.onButtonClick));
    
end

function MainLineCity:setData(data,mapInfo,unlockList)
    self.data = data;
    self.mapInfo = mapInfo;
    self.unlockList = unlockList;

    self:initState();
    self.Image_city:loadTexture(self.mapInfo.icon,ccui.TextureResType.plistType);
    if self.mapInfo.rotate == -1 then
        self.Image_city:setScale(-1);
        self.Image_city:setScaleY(1);
    end
    self.Label_cityName:setText(self.mapInfo.name);

    if #self.mapInfo.c_reward_show > 0 then
        local itemType = tonumber(self.mapInfo.c_reward_show[1].value2);
        local id = tonumber(self.mapInfo.c_reward_show[1].value3);
        require "itemInfo"
        local info = itemInfo(itemType,id);
        if info then
            MGRCManager:cacheResource("MainLineCity",info.item_pic);
            self.circleHead:setHeroFace(info.item_pic);
            self.circleHead:setHeadScale(0.6);
        end
    else
        self.Image_headBg:setVisible(false);
    end

    for i=1,#self.data.union_war_info do--进攻方信息
        local warInfo = self.data.union_war_info[i];
        if self.mapInfo.id == tonumber(warInfo.city_id) then
            self.Panel_up:setVisible(true);
            self.Image_war:setTouchEnabled(true);
            self.Image_flag1:loadTexture(string.format("guild_flag_%d.png",tonumber(warInfo.atk_u_flag_bg)),ccui.TextureResType.plistType);
            self.Image_totem1:loadTexture(string.format("guild_totem_%d.png",tonumber(warInfo.atk_u_flag)),ccui.TextureResType.plistType);
            self.Label_name:setText(unicode_to_utf8(warInfo.atk_u_name));

            local startTime=LUADB.readConfig(152);
            local timeArr=string.split(startTime,":");

            local nowTime=ME:getServerTime();
            startTime=getTimeStamp(timeArr[1],timeArr[2]);
            self.leftTime=startTime-nowTime;--战斗倒计时间
            local time = MGDataHelper:secToString(self.leftTime);
            self.Label_time:setText(time);
            self.timer:startTimer(1000,handler(self,self.updateTime),false);--每秒回调一次
            break;
        end
    end

    for i=1,#self.data.city_flag do--城池旗帜
        if self.mapInfo.id == tonumber(self.data.city_flag[i].city_id) then
            self.Image_flag:setVisible(true);
            self.Image_flag:loadTexture(string.format("guild_flag_%d.png",
                tonumber(self.data.city_flag[i].flag_bg)),ccui.TextureResType.plistType);
            self.Image_totem:loadTexture(string.format("guild_totem_%d.png",
                tonumber(self.data.city_flag[i].flag)),ccui.TextureResType.plistType);
            break;
        end
    end

    table.sort(self.data.stage,function (a,b) return tonumber(a) > tonumber(b) end)
    for i=1,#self.data.stage do
        if self.mapInfo.id == tonumber(self.data.stage[i]) then
            self.Image_city:getSprit():setShaderProgram(self.oldHeadProgram);
        end
        if self.mapInfo.id == tonumber(self.data.new_stage_id) then
            self:createCityEffect();
        end
    end

    local value=LUADB.readConfig(126);
    local timeArr=getDataList(value);
    local nowTime=ME:getServerTime();
    local startTime = getTimeStamp(timeArr[1].value1,timeArr[1].value2);
    local endTime = getTimeStamp(timeArr[2].value1,timeArr[2].value2);
    local disTime = endTime - startTime;

    for i=1,#self.data.declare_city do--可宣战城池
        if self.mapInfo.id == tonumber(self.data.declare_city[i]) then
            self.Button_war:setEnabled(true);
            break;
        end
    end

    self:setIsGray(false);
    if self:inUnloclArea() == false then
        self:setTouch(false);
        self:setIsGray(true);
    end
    if self.isUnlockStage == false then
        self:setIsGray(true);
    end

    --星级
    local starNum = self.data.stage_star[tostring(self.mapInfo.id)];
    if nil ~= starNum then
        for i=1,#self.stars do
            if i <= starNum then
                self.stars[i]:setVisible(true);
            end
        end
    end

    local posX = self.Image_city:getPositionX();
    local posY_1 = self.Image_city:getPositionY()-self.Image_city:getContentSize().height/2;
    local posY_2 = self.Image_city:getPositionY()+self.Image_city:getContentSize().height/2;
    self.Panel_bottom:setPosition(cc.p(posX-self.Panel_bottom:getContentSize().width/2,
        posY_1-self.Panel_bottom:getContentSize().height+10));

    local rate = (self.Label_cityName:getContentSize().width+60)/self.Image_incursion:getContentSize().width;
    self.Image_incursion:setScaleX(rate);
    self.Image_flag:setPositionX(self.Image_incursion:getPositionX()-
        self.Image_incursion:getContentSize().width*rate/2);
    self.Image_headBg:setPositionX(self.Image_incursion:getPositionX()+
        self.Image_incursion:getContentSize().width*rate/2);
end

function MainLineCity:updateTime()
    self.leftTime=self.leftTime-1;
    if self.leftTime <= 0 then
        if self.timer~=nil then
            self.timer:stopTimer();
        end
        self.Label_time:setText(MG_TEXT("MainLineLayer_2"));
        self.Button_war:setEnabled(false);
    else
        local time = MGDataHelper:secToString(self.leftTime);
        self.Label_time:setText(time);
    end
end

function MainLineCity:createCityEffect()
    if self.cityEffect==nil then
        self.cityEffect=cc.Sprite:create();
        local x1=self.Image_city:getContentSize().width/2;
        local y1=self.Image_city:getContentSize().height/2;
        self.cityEffect:setPosition(cc.p(x1,y1));
        self.cityEffect:setScale(0.8);
        self.Image_city:addChild(self.cityEffect);
        local action=fuGetAnimate("GuildWar_fightEffect",0,11,0.083,true);
        self.cityEffect:runAction(action);
    end
end

function MainLineCity:initState()
    self.Button_war:setEnabled(false);
    self.Button_event:setEnabled(false);
    self.Button_incursion:setEnabled(false);
    self.Panel_up:setVisible(false);
    self.Image_war:setTouchEnabled(false);
    self.Image_flag:setVisible(false);
    self.Image_headBg:setVisible(false);
    self.Image_flag:setVisible(false);
    for i=1,#self.stars do
        self.stars[i]:setVisible(false);
    end
end

function MainLineCity:inUnloclArea()--检查是否在解锁区域内
    if self.mapInfo.city_type > 4 then
        return;
    end

    self.checkpointId = self.mapInfo.id;
    self.isUnlockArea = false;--区域是否解锁
    self.isUnlockStage = false;--城池是否解锁

    for i=1,#self.data.stage do--已解锁的城池
        if tonumber(self.data.stage[i]) == self.checkpointId then
            self.isUnlockStage = true;
            break;
        end
    end

    if self.mapInfo.city_type <= 4 then
        for j=1,#self.unlockList do
            for m=1,#self.unlockList[j].s_ids do
                if tonumber(self.unlockList[j].s_ids[m]) == self.checkpointId then
                    for n=1,#self.data.area do--已解锁的区域
                        if tonumber(self.data.area[n]) == tonumber(self.unlockList[j].id) then--该城池区域已经解锁
                            self.isUnlockArea = true;
                            return true;
                        end
                    end
                end
            end
        end
    end

    return false;
end

function MainLineCity:onButtonClick(sender, eventType)
    if sender == self.Button_war or sender == self.Button_event or 
    sender == self.Button_incursion then
        buttonClickScale(sender, eventType);
    end

    if eventType == ccui.TouchEventType.began then
        if sender == self.Image_city then
            if self.citySpr==nil then
                self.citySpr = cc.Sprite:createWithSpriteFrameName(self.mapInfo.icon);
                self.citySpr:setPosition(cc.p(self.Image_city:getContentSize().width/2,
                    self.Image_city:getContentSize().height/2));
                self.Image_city:addChild(self.citySpr);
                self.citySpr:setShaderProgram(MGGraySprite:getLightShaderProgram(1));
            end
        end
    end
    if eventType == ccui.TouchEventType.canceled then
        if sender == self.Image_city then
            if self.citySpr then
                self.citySpr:removeFromParent();
                self.citySpr = nil;
            end
        end
    end
    if eventType == ccui.TouchEventType.ended then
        if sender == self.Image_city then
            if self.citySpr then
                self.citySpr:removeFromParent();
                self.citySpr = nil;
            end
        end

        if sender == self.Image_city or sender == self.Image_incursion then
            if self.isUnlockStage == false then
                MGMessageTip:showFailedMessage(MG_TEXT("MainLineLayer_3"));
            else
                if self.delegate and self.delegate.addCheckpointLayer then
                    self.delegate:addCheckpointLayer(self.mapInfo);
                end
            end
        elseif sender == self.Button_war then--宣战
            print(">>>>>>>>>>>>宣战>>>>>>>>>>>>>>>")
            require "MLwar";
            local war = MLwar.showBox(self);
            war:setData(self.data,self.mapInfo);
        elseif sender == self.Button_event then--事件
            print(">>>>>>>>>>>>事件>>>>>>>>>>>>>>>")
        elseif sender == self.Button_incursion then--入侵
            print(">>>>>>>>>>>>入侵>>>>>>>>>>>>>>>")
        elseif sender == self.Image_war then--进入公会战
            enterUnionWar(self.mapInfo.id,handler(self,self.onRemove));
        end
    end
end

function MainLineCity:setIsGray(isGray)
    if self.mapInfo.city_type > 4 then
        return;
    end

    if isGray then
        self.Image_city:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
        self.Image_incursion:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
        self.Label_cityName:setColor(Color3B.GRAY);
    else
        self.Image_city:getSprit():setShaderProgram(self.oldHeadProgram);
        self.Image_incursion:getSprit():setShaderProgram(self.oldHeadProgram);
        self.Label_cityName:setColor(Color3B.WHITE);
    end
end

function MainLineCity:setTouch(isTouch)
    self.Image_city:setTouchEnabled(isTouch);
    self.Image_incursion:setTouchEnabled(isTouch);
end

function MainLineCity:onRemove()
    self.Panel_up:setVisible(false);
    self.Image_war:setTouchEnabled(false);
end

function MainLineCity:remove()
    self:removeFromParent();
end

function MainLineCity:updataCityInfo(data)
    if self.delegate and self.delegate.updataCityInfo then
        self.delegate:updataCityInfo(data);
    end
end

function MainLineCity:onEnter()
    
end

function MainLineCity:onExit()
    MGRCManager:releaseResources("MainLineCity");
    if self.timer~=nil then
        self.timer:stopTimer();
    end
end

function MainLineCity.create(delegate,widget)
    local layer = MainLineCity:new()
    layer:init(delegate,widget)
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

return MainLineCity