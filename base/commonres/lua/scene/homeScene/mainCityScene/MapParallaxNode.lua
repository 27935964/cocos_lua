----------------主城背景层------------------
--http://www.cnblogs.com/apophisx/p/3917705.html
require "usercardLayer"

local mainHomeInfo = require "mainHomeInfo";
local effectInfo = require "effectInfo";
MapParallaxNode = class("MapParallaxNode", MGLayer)

MapParallaxNode.rates={[1]=1.6, [2]=1.0, [3]=0.6, [4]=0.3, [5]=0.1, [6]=0.001}
MapParallaxNode.offsets={[1]=-530, [2]=-332, [3]=-332, [4]=-332, [5]=-332, [6]=-332}

function MapParallaxNode:ctor()
    self.mapBgs = {};
    self.buildBtns = {};
    self.buildInfo = {};
    self.cloudSpr1 = nil;
    self.cloudSpr2 = nil;
    self.cloudSprPosX1 = 0;
    self.cloudSprPosX2 = 0;
    self.touchSpr = nil;
    self.curBuildingId = 0;

    self.financeLayer=nil;
    self.leveyLayer=nil;
    self.magicLayer=nil;
    self.cloudCMainLayer=nil;
    
    self:init();
end

function MapParallaxNode:init()
    self.timer = CCTimer:new();
    self.size = cc.Director:getInstance():getWinSize();
    self.timer:startTimer(1000,handler(self,self.updateTime),false);--每秒回调一次

    self:initMapBg();
    local layout = ccui.Layout:create();
    layout:setSize(cc.size(2001,750));
    self:addChild(layout);
    CommonMethod:setNodeScale(layout,true);--适配

    self.parallaxNode = cc.ParallaxNode:create();
    self.parallaxNode:setAnchorPoint(cc.p(0,0));
    layout:addChild(self.parallaxNode);

    local listener = cc.EventListenerTouchOneByOne:create();
    listener:setSwallowTouches(true);
    listener:registerScriptHandler(handler(self,self.onTouchBegin),cc.Handler.EVENT_TOUCH_BEGAN);
    listener:registerScriptHandler(handler(self,self.onTouchesMoved),cc.Handler.EVENT_TOUCH_MOVED);
    listener:registerScriptHandler(handler(self,self.onTouchEnd),cc.Handler.EVENT_TOUCH_ENDED);
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self.parallaxNode);

    --参数：子节点，层级，位移比例，在视差节点中的初始位置
    for i=1,#self.mapBgs do
        local bgInfo = mainHomeInfo[i].bg;
        self.parallaxNode:addChild(self.mapBgs[i], #self.mapBgs-i,cc.p(self.rates[i],1.0),
            cc.p(bgInfo.x+self.offsets[i],bgInfo.y));
    end

    self:coordinateTransformation();

end

function MapParallaxNode:onTouchBegin(touch,event)
    -- print("-----------onTouchBegin---------------")

    self.beginPoint = touch:getLocation();
    self.beginPosX = {};
    for i=1,#self.buildInfo do
        local iFlag = self:pointsInPolygon(self.buildInfo[i].pos, self.beginPoint);
        if iFlag == 1 then--点击在建筑上
            if self.btnSpr==nil then
                self.btnSpr = cc.Sprite:create();
                self.btnSpr:setSpriteFrame(self.buildInfo[i].pic);
                self.btnSpr:setPosition(cc.p(self.buildInfo[i].spr:getContentSize().width/2,self.buildInfo[i].spr:getContentSize().height/2));
                self.buildInfo[i].spr:addChild(self.btnSpr);
                self.btnSpr:setShaderProgram(MGGraySprite:getLightShaderProgram(1));

                self.touchSpr = self.buildInfo[i].spr;
            end
            break;
        end
    end

    for i=1,#self.buildBtns do
        table.insert(self.beginPosX,self:getBuildingWordPos(i).x);
    end
    return true;
end

function MapParallaxNode:onTouchesMoved(touch, event)
    -- print("-----------onTouchesMoved---------------")
    local diff = touch:getDelta();--获取移动的任何时刻产生的位移差。
    local node = event:getCurrentTarget();
    local currentPosX, currentPosY = node:getPosition();--获取 视差节点self.parallaxNode
    --将移动所产生的位移差加到 视差节点 的坐标上，产生移动和视差效果
    local disPos = currentPosX + diff.x;
    if disPos >= 332 then
        disPos = 332;
        diff.x = 0;
    end
    if disPos <= -332 then
        disPos = -332;
        diff.x = 0;
    end
    node:setPositionX(disPos);

    if self.btnSpr then
        self.btnSpr:removeFromParent();
        self.btnSpr = nil;
    end
end

function MapParallaxNode:onTouchEnd(touch,event)
    -- print("-----------onTouchEnd---------------")

    if self.btnSpr then
        self.btnSpr:removeFromParent();
        self.btnSpr = nil;
    end

    self.beginPoint = touch:getStartLocation();
    self.endPoint = touch:getLocation();

    for i=1,#self.buildInfo do
        for m=1,#self.buildBtns do
            if self.buildBtns[m]:getTag() == self.buildInfo[i].id then
                local endPosX = self:getBuildingWordPos(self.buildInfo[i].id).x;
                local diff = endPosX-self.beginPosX[m];
                for j=1,#self.buildInfo[i].pos do
                    self.buildInfo[i].pos[j].x = self.buildInfo[i].pos[j].x+diff;
                end

            end
        end
    end
    
    local disX = self.endPoint.x - self.beginPoint.x;
    if disX < 5 and disX > -5 then
        if self.touchSpr then
            self:onButtonClick(self.touchSpr);
        end
    end
end

function MapParallaxNode:initMapBg()
    self.buildBtns = {};
    self.buildInfo = {};
    for index=1,#mainHomeInfo do
        if index == 1 then
            local layout = ccui.Layout:create();
            layout:setSize(cc.size(2001,170));
            layout:setAnchorPoint(cc.p(0,0));

            local sprite1=cc.Sprite:create("main_bg_0.png");
            sprite1:setAnchorPoint(cc.p(0,0));
            layout:addChild(sprite1);

            local sprite2=cc.Sprite:create("main_bg_1.png");
            sprite2:setAnchorPoint(cc.p(0,0));
            sprite2:setPosition(cc.p(1480,0));
            layout:addChild(sprite2);

            table.insert(self.mapBgs,layout);
        elseif index == 5 then
            local layout = ccui.Layout:create();
            layout:setSize(cc.size(2001,354));
            layout:setAnchorPoint(cc.p(0,0));

            self:createCity(layout,index);

            self.cloudSpr1 = cc.Sprite:create("main_cloud_1.png");
            self.cloudSpr1:setPosition(cc.p(1012,328));
            layout:addChild(self.cloudSpr1);
            self.cloudSprPosX1 = self.cloudSpr1:getPositionX();

            self.cloudSpr2 = cc.Sprite:create("main_cloud_2.png");
            self.cloudSpr2:setPosition(cc.p(952,212));
            layout:addChild(self.cloudSpr2,2);
            self.cloudSprPosX2 = self.cloudSpr2:getPositionX();

            self:cloudAction();

            table.insert(self.mapBgs,layout);
        else
            local sprite=cc.Sprite:create();
            sprite:setAnchorPoint(cc.p(0,0));
            table.insert(self.mapBgs,sprite);

            local picName = string.format("main_bg_%d.png",index);
            if index == 6 then
                picName = string.format("main_bg_%d.jpg",index-1);
            end
            sprite:setSpriteFrame(picName);
            self:createCity(sprite,index);
        end
    end

    self:createEffect();
end

function MapParallaxNode:createCity(sprite,index)
    for i=1,#mainHomeInfo[index].city do
        local cityInfo = mainHomeInfo[index].city[i];
        local unlockInfo = mainHomeInfo[index].unlock[i];
        local titleInfo = mainHomeInfo[index].title[i];
        local building = ccui.ImageView:create(cityInfo.pic..".png", ccui.TextureResType.plistType);
        building:setPosition(cc.p(cityInfo.x,cityInfo.y));
        sprite:addChild(building);
        building:setLocalZOrder(cityInfo.zOrder);
        building:setTag(cityInfo.id);
        building:setTouchEnabled(false);
        if cityInfo.byFlag == 1 then
            self.buildBtns[cityInfo.id] = building;
            local pos = getDataList(cityInfo.pos);
            table.insert(self.buildInfo,{spr=building,pic=cityInfo.pic..".png",
                openlv=cityInfo.openlv,pos=pos,rate=self.rates[index],id=cityInfo.id,
                achievementlv=cityInfo.achievementlv});

            local titleSpr = cc.Sprite:createWithSpriteFrameName(string.format("main_building_title_%d.png",titleInfo.id));
            titleSpr:setPosition(cc.p(titleInfo.x,titleInfo.y));
            sprite:addChild(titleSpr,titleInfo.zOrder);

            if ME:Lv() < cityInfo.openlv or ME:getAchLv() < cityInfo.achievementlv then
                local unlockSpr = cc.Sprite:createWithSpriteFrameName("main_unlock.png");
                unlockSpr:setPosition(cc.p(unlockInfo.x,unlockInfo.y));
                sprite:addChild(unlockSpr,unlockInfo.zOrder);
            end
        end
        if cityInfo.id == 100 then
            self.buildingBtn = building;
        end
    end
    
end

function MapParallaxNode:coordinateTransformation()--转换坐标
    for i=1,#self.buildInfo do
        local pos = {}
        for j=1,#self.buildInfo[i].pos do
            local x = self.buildInfo[i].pos[j].value1;
            local y = self.buildInfo[i].pos[j].value2;
            local startPos = self.buildInfo[i].spr:getParent():convertToWorldSpace(cc.p(x,y));
            table.insert(pos,startPos);
        end
        self.buildInfo[i].initPos = pos;
        self.buildInfo[i].pos = pos;
    end
end

--当有触摸点时只要调用这个函数就行，把多边形的关键点作为参数传入，或者不传也行， 但是最后一个点和第一个点的线段也要判断。
--参数1: 控制点的数组, 参数2:点击的点
--返回值: 0:在外面, 1:在里面, 2:在线上
function MapParallaxNode:pointsInPolygon(posArray, touchPos)
    --数组的个数 里面的数组是测试用的
    local count = #posArray;
    --在多边形内的数量
    local nCount = 0;
    --返回值
    local nFlag = 0;
    for i=1,count do
        local next = i + 1;
        if next > count then
            break;
        end

        local pos1 = posArray[i];
        local pos2 = posArray[next];
        nFlag = self:isIntersect(pos1.x, pos1.y, pos2.x, pos2.y, touchPos.x, touchPos.y);

        if -1 == nFlag then
            --在线上
            return 2;
        end
        if 1 == nFlag then
            --在线上
            nCount = nCount + 1;
        end
    end

    --nCount为偶数不在里面，奇数在里面
    if math.mod(nCount,2) == 1 then
        --在里面
        return 1;
    end

    return 0;
end

--以触摸点的y值不变，发射横向射线，与对比的线相交 判断有没有在触摸点x值左边的相交点, 并返回对应值
--<参数1:x1, 参数2:y1> 首端点x,y轴坐标, <参数3:x2, 参数4:y2> 末端点x,y轴坐标, <参数5:x, 参数6:y> 点击点x,y轴坐标
--返回值: -1:在线上, 0:不相交, 1:相交
function MapParallaxNode:isIntersect(x1,y1,x2,y2,x,y)

    --定义最小和最大的X Y轴值
    local minX,maxX,minY,maxY = 0;
    minX = x1;
    maxX = x2;
    minY = y1;
    maxY = y2;
    --如果不是这种情况， 则把两个大小值换下
    if minX > maxX then
        minX = x2;
        maxX = x1;
    end
    if minY > maxY then
        minY = y2;
        maxY = y1;
    end

    --射线与边无交点的其他情况
    if y < minY or y > maxY or x < minX then
        return 0;
    end
    
    --对比线垂直的情况， 这段可以快速判断出对比线段垂直的情况, (不过感觉没必要判断,不要这段代码也行.)
    if minX == maxX then
        --y值只有两种(1 在线段y值中，2 和线段y值外(必不相交, 前面已经排除了), 这里排除掉在末端点y2上的情况)
        if y == y2 then
            return 0;
        end
        --剩下的y在minY和maxY之间
        --1 如果x == minx也相等， 表示在对比线上，返回-1;
        --2 如果x < minX 则肯定不相交, 返回 0;
        --3 那么 x> minX时， 肯定相交， 返回1.
        if x == minX then
            return -1;
        elseif x < minX then
            return 0;
        else
            return 1;
        end
    end
    --对比线平行的情况
    if minY == maxY then
        --在前面排除掉 y < minY 和 y > maxY 的情况后只剩下，y和两个y值相等的情况, 即触摸点与这个对比线在一条线上
        --前面判断过x < minX的情况， 如果x<maxX 则表示在线上(排除与末端点x2相等的情况)
        if x <= maxX and x ~= x2 then
            return -1;
        else
            return 0;
        end
    end
    --剩下的情况, 计算射线与边所在的直线的交点的横坐标
    local x0 = x1+((x2-x1)/(y2-y1))*(y-y1);
    --交点在射线右侧，不相交
    if x0 > x then
        return 0;
    elseif x0 == x then
        return -1;
    end

    --穿过下端点不计
    if x0 == x2 then
        return 0;
    end
    return 1;
end

function MapParallaxNode:getBuildingWordPos(id)
            local pos=cc.p(0,0);
            local building=self.buildBtns[id];
            local x,y=building:getPosition();
            pos=building:getParent():convertToWorldSpace(cc.p(x,y));
            return pos;
end

function MapParallaxNode:createEffect()--主城特效
    --国会大楼的光
    local effectSpr1 = cc.Sprite:create();
    effectSpr1:setPosition(cc.p(self.buildBtns[8]:getContentSize().width/2+40,self.buildBtns[8]:getContentSize().height/2-60));
    self.buildBtns[8]:addChild(effectSpr1,1);
    local action1=cc.RepeatForever:create(fuGetAnimate("guang00",1,15,0.063));
    effectSpr1:runAction(action1);

    --水池 的流水
    local effectSpr2 = cc.Sprite:create();
    effectSpr2:setPosition(cc.p(self.buildingBtn:getContentSize().width/2-95,self.buildingBtn:getContentSize().height/2-5));
    self.buildingBtn:addChild(effectSpr2,1);
    local action2=cc.RepeatForever:create(fuGetAnimate("shuiliu00",1,16,0.083));
    effectSpr2:runAction(action2);

    --魔法行会 传送门
    local effectSpr3 = cc.Sprite:create();
    effectSpr3:setPosition(cc.p(self.buildBtns[12]:getContentSize().width/2-30,self.buildBtns[12]:getContentSize().height/2-40));
    self.buildBtns[12]:addChild(effectSpr3,1);
    local action3=cc.RepeatForever:create(fuGetAnimate("chuangsongmen00",1,12,0.1));
    effectSpr3:runAction(action3);

    --铁匠铺的火光
    local effectSpr4_1 = cc.Sprite:create();
    effectSpr4_1:setPosition(cc.p(self.buildBtns[6]:getContentSize().width/2+38,self.buildBtns[6]:getContentSize().height/2-23));
    self.buildBtns[6]:addChild(effectSpr4_1,1);
    local action_1 = fuGetAnimate("huoguang00",1,12,0.083);
    local action_2 = fuGetAnimate("huoguang00",12,1,0.083);
    local action4_1=cc.RepeatForever:create(cc.Sequence:create(action_1,action_2));
    effectSpr4_1:runAction(action4_1);

    --铁匠铺的烟
    local effectSpr4_2 = cc.Sprite:create();
    effectSpr4_2:setPosition(cc.p(self.buildBtns[6]:getContentSize().width/2-35,self.buildBtns[6]:getContentSize().height/2+60));
    self.buildBtns[6]:addChild(effectSpr4_2,1);
    local action4_2=cc.RepeatForever:create(fuGetAnimate("yanwu00",1,32,0.083));
    effectSpr4_2:runAction(action4_2);

    --主城堡旗帜1
    local effectSpr5_1 = cc.Sprite:create();
    effectSpr5_1:setPosition(cc.p(self.buildBtns[10]:getContentSize().width/2-259,self.buildBtns[10]:getContentSize().height/2-40));
    self.buildBtns[10]:addChild(effectSpr5_1,1);
    local action5_1=cc.RepeatForever:create(fuGetAnimate("qizhi_animation_",0,16,0.083));
    effectSpr5_1:runAction(action5_1);

    --主城堡旗帜1
    local effectSpr5_1 = cc.Sprite:create();
    effectSpr5_1:setPosition(cc.p(self.buildBtns[10]:getContentSize().width/2+64,self.buildBtns[10]:getContentSize().height/2-50));
    self.buildBtns[10]:addChild(effectSpr5_1,1);
    local action5_1=cc.RepeatForever:create(fuGetAnimate("qizhi_animation_",0,16,0.083));
    effectSpr5_1:runAction(action5_1);

    --主城堡旗帜2
    local effectSpr6_1 = cc.Sprite:create();
    effectSpr6_1:setPosition(cc.p(self.buildBtns[10]:getContentSize().width/2-115,self.buildBtns[10]:getContentSize().height/2+60));
    self.buildBtns[10]:addChild(effectSpr6_1,1);
    local action6_1=cc.RepeatForever:create(fuGetAnimate("flag_animation_",1,17,0.083));
    effectSpr6_1:runAction(action6_1);

    --主城堡旗帜2
    local effectSpr6_1 = cc.Sprite:create();
    effectSpr6_1:setPosition(cc.p(self.buildBtns[10]:getContentSize().width/2+51,self.buildBtns[10]:getContentSize().height/2+93));
    self.buildBtns[10]:addChild(effectSpr6_1,1);
    local action6_1=cc.RepeatForever:create(fuGetAnimate("flag_animation_",1,17,0.083));
    effectSpr6_1:runAction(action6_1);

    --水流
    local effectSpr7 = cc.Sprite:create();
    effectSpr7:setPosition(cc.p(160,25));
    self.mapBgs[3]:addChild(effectSpr7,1);
    local action7=cc.RepeatForever:create(fuGetAnimate("liushui_",1,16,0.083));
    effectSpr7:runAction(action7);

    --战神像
    local effectSpr8_1 = cc.Sprite:create();
    effectSpr8_1:setPosition(cc.p(self.buildBtns[11]:getContentSize().width/2+25,self.buildBtns[11]:getContentSize().height/2+15));
    self.buildBtns[11]:addChild(effectSpr8_1,1);
    local action8_1=cc.RepeatForever:create(fuGetAnimate("guangliang_",1,24,0.083));
    effectSpr8_1:runAction(action8_1);

    --战神像
    local effectSpr8_2 = cc.Sprite:create();
    effectSpr8_2:setPosition(cc.p(0,self.buildBtns[11]:getContentSize().height-10));
    self.buildBtns[11]:addChild(effectSpr8_2,1);
    local action8_2=cc.RepeatForever:create(fuGetAnimate("zhanshenguanghuan00",1,20,0.083));
    effectSpr8_2:runAction(action8_2);

    self:createWaterEffect();
end

function MapParallaxNode:createWaterEffect()--水星特效
    for i=1,#effectInfo do
        local effectSpr = cc.Sprite:create();
        effectSpr:setPosition(cc.p(effectInfo[i].x,effectInfo[i].y));
        effectSpr:setScale(effectInfo[i].scale);
        self.mapBgs[3]:addChild(effectSpr,effectInfo[i].zOrder);

        local action = cc.RepeatForever:create(fuGetAnimate(string.format("hupo_%d_",effectInfo[i].type),1,24,0.083));
        effectSpr:runAction(action);
    end
    
end

function MapParallaxNode:cloudAction()--云动画
    local moveBy = cc.MoveBy:create(1, cc.p(10,0));
    self.cloudSpr1:runAction(cc.RepeatForever:create(moveBy));

    local moveBy2 = cc.MoveBy:create(1, cc.p(15,0));
    self.cloudSpr2:runAction(cc.RepeatForever:create(moveBy2));
end

function MapParallaxNode:updateTime()
    if self.cloudSpr1:getPositionX()>=self.cloudSprPosX1+self.mapBgs[5]:getContentSize().width/2+self.cloudSpr1:getContentSize().width/2 then
        self.cloudSpr1:setPositionX(self.cloudSprPosX1-self.mapBgs[5]:getContentSize().width/2-self.cloudSpr1:getContentSize().width/2);
    end

    if self.cloudSpr2:getPositionX()>=self.cloudSprPosX2+self.mapBgs[5]:getContentSize().width/2+self.cloudSpr2:getContentSize().width/2 then
        self.cloudSpr2:setPositionX(self.cloudSprPosX2-self.mapBgs[5]:getContentSize().width/2-self.cloudSpr2:getContentSize().width/2);
    end
end

--财政厅
function MapParallaxNode:openFinance(value)
        local curScene=cc.Director:getInstance():getRunningScene();
        if value then
                if self.financeLayer==nil then
                    local FinanceLayer=require "FinanceLayer";
                    self.financeLayer=FinanceLayer.new(self);
                    self.financeLayer:setManager(self.delegate);
                    curScene:addChild(self.financeLayer,ZORDER_MAX);
                end
        else
                if self.financeLayer then
                    self.financeLayer:removeFromParent();
                    self.financeLayer=nil;
                end
        end
end

--国会大厅
function MapParallaxNode:openLevey(value)
        local curScene=cc.Director:getInstance():getRunningScene();
        if value then
                if self.leveyLayer==nil then
                    local LeveyLayer=require "LeveyLayer";
                    self.leveyLayer=LeveyLayer.new(self);
                    self.leveyLayer:setManager(self.delegate);
                    curScene:addChild(self.leveyLayer,ZORDER_MAX);
                end
        else
                if self.leveyLayer then
                    self.leveyLayer:removeFromParent();
                    self.leveyLayer=nil;
                end
        end
end

--魔法行会
function MapParallaxNode:openMagic(value)
        local curScene=cc.Director:getInstance():getRunningScene();
        if value then
                if self.magicLayer==nil then
                    local MagicGuildLayer=require "MagicGuildLayer";
                    self.magicLayer=MagicGuildLayer.new(self);
                    self.magicLayer:setManager(self.delegate);
                    curScene:addChild(self.magicLayer,ZORDER_MAX);
                end
        else
                if self.magicLayer then
                    self.magicLayer:removeFromParent();
                    self.magicLayer=nil;
                end
        end
end

--云中城
function MapParallaxNode:openCloudCMain(value)
    local curScene=cc.Director:getInstance():getRunningScene();
    if value then
        if self.cloudCMainLayer==nil then
            local CloudCMainLayer=require "CloudCMainLayer";
            self.cloudCMainLayer=CloudCMainLayer.new(self);
            self.cloudCMainLayer:setManager(self.delegate);
            curScene:addChild(self.cloudCMainLayer,ZORDER_MAX);
        end
    else
        if self.cloudCMainLayer then
            self.cloudCMainLayer:removeFromParent();
            self.cloudCMainLayer=nil;
        end
    end
end

function MapParallaxNode:openShopLayer(type)
    shopLayer.showBox(self,type);
end

function MapParallaxNode:onButtonClick(sender)
    self.touchSpr = nil;
    local openlv = self.buildInfo[sender:getTag()].openlv;
    local achievementlv = self.buildInfo[sender:getTag()].achievementlv;
    if ME:Lv() < openlv then
        MGMessageTip:showFailedMessage(string.format(MG_TEXT("UnLock_level"),openlv));
        return;
    elseif ME:getAchLv() < achievementlv then
        MGMessageTip:showFailedMessage(string.format(MG_TEXT("UnLock_ach_level"),achievementlv));
        return;
    else
        if sender:getTag() == 1 then--酒馆
            local usercardLayer = usercardLayer.showBox(self);
        elseif sender:getTag() == 2 then--杂货铺
            print(">>>>>>>杂货铺>>>>>>",sender:getTag());
            self:openShopLayer(2);
        elseif sender:getTag() == 3 then--珍宝阁
            print(">>>>>>>珍宝阁>>>>>>",sender:getTag());
            self:openShopLayer(4);
        elseif sender:getTag() == 4 then--官市
            print(">>>>>>官市>>>>>>>",sender:getTag());
        elseif sender:getTag() == 5 then--英雄商店
            print(">>>>>>英雄商店>>>>>>>",sender:getTag());
            self:openShopLayer(1);
        elseif sender:getTag() == 6 then--军械铺
            print(">>>>>>军械铺>>>>>>>",sender:getTag());
            self:openShopLayer(3);
        elseif sender:getTag() == 7 then--兄弟会
            print(">>>>>>>兄弟会>>>>>>",sender:getTag());
        elseif sender:getTag() == 8 then--国会大楼
            self:openLevey(true);
        elseif sender:getTag() == 9 then--财政厅
                self:openFinance(true);
        elseif sender:getTag() == 10 then--工会
            print(">>>>>>>工会>>>>>>",sender:getTag());
        elseif sender:getTag() == 11 then--战神像
            print(">>>>>>>战神像>>>>>>",sender:getTag());
        elseif sender:getTag() == 12 then--魔法行会
            self:openMagic(true);
        elseif sender:getTag() == 13 then--云中城
            print(">>>>>>云中城>>>>>>>",sender:getTag());
            self:openCloudCMain(true);
        end
    end
end

-- function MapParallaxNode:onReciveData(MsgID, NetData)
--     if MsgID == Post_getUserMain then
--         local ackData = NetData.getusermain;
--         if NetData.state == 1 then
--             self:setData(ackData);
--         else
--             NetHandler:showFailedMessage(NetData);
--         end
--     end
-- end

-- function MapParallaxNode:pushAck()
--     NetHandler:addAckCode(self,Post_getUserMain);
-- end

-- function MapParallaxNode:popAck()
--     NetHandler:delAckCode(self,Post_getUserMain);
-- end

-- function MapParallaxNode:sendReq()
--     NetHandler:sendData(Post_getUserMain, "");
-- end

function MapParallaxNode:onEnter()
    _G.mapParallaxNode=self;
    -- self:pushAck();
    -- self:sendReq();
end

function MapParallaxNode:onExit()
    _G.mapParallaxNode=nil;
    -- self:popAck();
    MGRCManager:releaseResources("MapParallaxNode");
    if self.timer~=nil then
        self.timer:stopTimer();
    end
end

function MapParallaxNode.create(delegate)
    local layer = MapParallaxNode:new()
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

function MapParallaxNode.showBox(delegate)
    local layer = MapParallaxNode.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer);
    return layer;
end
