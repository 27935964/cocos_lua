---------------生成地图数据的的工具-----------------------


JesonGenerator = class("JesonGenerator", MGLayer)

JesonGenerator.roadTypes={
    [1] =   {
                [1]={1,2,6,2,1},--表示从城池1到城池2的路线有6个箭头指示,这座城池有2个方向可走,其中一个方向的ID为1
                [2]={1,4,5,2,2},--表示从城池1到城池2的路线有6个箭头指示,这座城池有2个方向可走,其中一个方向的ID为2
                [3]={2,3,5,1,1},
                [4]={3,4,7,2,1},
                [5]={3,5,6,2,2},
                [6]={4,2,5,1,1}
            },

    [2] =   {
                [1]={1,2,6,2,1},
                [2]={1,4,5,2,2},
                [3]={2,3,5,1,1},
                [4]={3,4,7,2,1},
                [5]={3,5,6,2,2},
                [6]={4,2,5,1,1}
            },

    [3] =   {
                [1]={1,2,6,2,1},
                [2]={1,4,5,2,2},
                [3]={2,3,5,1,1},
                [4]={3,4,7,2,1},
                [5]={3,5,6,2,2},
                [6]={4,2,5,1,1}
            },

    [4] =   {
                [1]={1,2,6,2,1},
                [2]={1,4,5,2,2},
                [3]={2,3,5,1,1},
                [4]={3,4,7,2,1},
                [5]={3,5,6,2,2},
                [6]={4,2,5,1,1}
            },

    [5] =   {
                [1]={1,2,6,2,1},
                [2]={1,4,5,2,2},
                [3]={2,3,5,1,1},
                [4]={3,4,7,2,1},
                [5]={3,5,6,2,2},
                [6]={4,2,5,1,1}
            }
};

JesonGenerator.chapters = {
    [1] = JesonGenerator.roadTypes[1];
    [2] = JesonGenerator.roadTypes[2];
    [3] = JesonGenerator.roadTypes[3];
    [4] = JesonGenerator.roadTypes[4];
    [5] = JesonGenerator.roadTypes[5];
};

function JesonGenerator:ctor()
    self.keyCode = 0;
    self.sprs = {};
    self.mapSprs = {};
    self.index = 0;
    self.currentTag = 0;
end

function JesonGenerator:init()
    -- MGRCManager:cacheResource("JesonGenerator", "Map_BG.jpg");
    -- MGRCManager:cacheResource("JesonGenerator", "city.png");
    -- MGRCManager:cacheResource("JesonGenerator", "mw_direction.png");
    local str = "";

    local pMapWidget = MGRCManager:widgetFromJsonFile("JesonGenerator","MainMap_Jeson_Ui_1.ExportJson");
    self:addChild(pMapWidget);

    self.mapSprs = {};
    for i=1,5 do
        local cityImg = pMapWidget:getChildByName("Image_"..i);
        table.insert(self.mapSprs,cityImg);
    end

    --生成大地图
    local gMapFile = io.open("MainLineMap.json" ,"w");
    gMapFile:write("{\n"..[[  "]].."MainLineMap"..[["]]..":[");
    for i=1,#self.mapSprs do
        if i == #self.mapSprs then
            str = string.format("[%d,%d,%d,%d]\n        ",1,i,self.mapSprs[i]:getPositionX(),self.mapSprs[i]:getPositionY());
        else
            str = string.format("[%d,%d,%d,%d],\n        ",1,i,self.mapSprs[i]:getPositionX(),self.mapSprs[i]:getPositionY());
        end
        gMapFile:write(str);
    end
    gMapFile:write("],\n");

    --生成路径
    local gFile = io.open("MainLinePath.json" ,"w");
    gFile:write("[\n");
    for m=1,#self.chapters do
        self.sections = self.roadTypes[m];
        local pWidget = MGRCManager:widgetFromJsonFile("JesonGenerator","Checkpoint_Jeson_Ui_1.ExportJson");
        self:addChild(pWidget);
        
        local Panel_15 = pWidget:getChildByName("Panel_15");
        self.directions = {};
        self.sprs = {};
        for i=1,5 do
            local cityImg = Panel_15:getChildByName("Image_"..i);
            table.insert(self.sprs,cityImg);
        end

        for i=1,#self.sections do
            self.directions[i] = {};
            local roadType = self.sections[i];
            for j=1,roadType[3] do
                local dirImg = Panel_15:getChildByName(string.format("Image_%d_%d_%d",roadType[1],roadType[2],j));
                table.insert(self.directions[i],dirImg);
            end
        end
        
        --生成关卡地图坐标数据
        gMapFile:write([[    "]].."chapter"..m..[["]]..":[");
        for i=1,#self.sprs do
            if i == #self.sprs then
                str = string.format("[%d,%d,%d,%d]\n        ",1,i,self.sprs[i]:getPositionX(),self.sprs[i]:getPositionY(),self.sprs[i]:getRotation());
            else
                str = string.format("[%d,%d,%d,%d],\n        ",1,i,self.sprs[i]:getPositionX(),self.sprs[i]:getPositionY(),self.sprs[i]:getRotation());
            end
            gMapFile:write(str);
        end
        if m == #self.chapters then
            gMapFile:write("]\n");
        else
            gMapFile:write("],\n");
        end

        --生成路径坐标数据
        -- local gFile = io.open("direction.json" ,"w");
        -- gFile:write("/*[路径id,起点城池id,终点城池id,横坐标,纵坐标,旋转角度]*/\n");
        -- gFile:write("[\n");

        gFile:write(" {\n"..[[  "]].."chapter"..m..[["]]..":[");
        for i=1,#self.sections do
            local roadType = self.sections[i];
            if i == #self.sections then
                str = string.format("[%d,%d,%d,%d,%d]\n        ],\n",i,roadType[1],roadType[2],roadType[4],roadType[5]);
            else
                str = string.format("[%d,%d,%d,%d,%d],\n        ",i,roadType[1],roadType[2],roadType[4],roadType[5]);
            end
            gFile:write(str);
        end

        for i=1,#self.sections do
            gFile:write([[    "]].."section"..i..[["]]..":[");
            local roadType = self.sections[i];
            for j=1,#self.directions[i] do
                local obj = self.directions[i][j];
                if i == #self.sections and j == #self.directions[#self.sections] then
                    str = string.format("[%d,%d,%d,%d,%d,%d]\n        ",i,roadType[1],roadType[2],obj:getPositionX(),obj:getPositionY(),obj:getRotation());
                elseif i ~= #self.sections and j == #self.directions[i] then
                    str = string.format("[%d,%d,%d,%d,%d,%d]\n        ],\n",i,roadType[1],roadType[2],obj:getPositionX(),obj:getPositionY(),obj:getRotation());
                else
                    str = string.format("[%d,%d,%d,%d,%d,%d],\n        ",i,roadType[1],roadType[2],obj:getPositionX(),obj:getPositionY(),obj:getRotation());
                end
                gFile:write(str);
            end
        end
        if m == #self.chapters then
            gFile:write("]\n }");
        else
            gFile:write("]\n },\n");
        end
    end
    gFile:write("\n]");
    gFile:close();

    gMapFile:write("}");
    gMapFile:close();

end

function JesonGenerator:onTouchBegin(touch,event)
    self.screenPoint = touch:getLocation();
    self.worldPoint = self.pContainerNode:convertToNodeSpace(self.screenPoint);

    local target = event:getCurrentTarget();
    local locationInNode = target:convertToNodeSpace(touch:getLocation());
    local size = target:getContentSize();
    local rect = cc.rect(0, 0, size.width, size.height);
    self.currentTag = target:getTag();
    self.currentSprite = target;
    
    if cc.rectContainsPoint(rect,locationInNode) then--判断触摸点是否在目标的范围内
        return true;
    else
        return false;
    end
    return true;
end

function JesonGenerator:onTouchMove(touch,event)
    self.screenPoint = touch:getLocation();
    self.worldPoint = self.pContainerNode:convertToNodeSpace(self.screenPoint);
    local target = event:getCurrentTarget();
    target:setPosition(cc.p(self.worldPoint.x,self.worldPoint.y));
end

function JesonGenerator:onTouchEnd(touch,event)
   
end

function JesonGenerator:onButtonClick(sender, eventType)
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
        if sender == self.Button_back then
            enterLuaScene(SCENEINFO.LOGIN_SCENE);
        elseif sender == self.Button_sp then
            self:createSp();
        elseif sender == self.Button_jeson then
            local str = "";
            local gFile = io.open("MainLineMap.json" ,"w");
            gFile:write("{\n"..[["]].."MainLine"..[["]]..":[");
            for i=1,#self.sprs do
                if i == #self.sprs then
                    str = string.format("[%d,%d,%d,%d]\n        ",1,i,self.sprs[i].sprite:getPositionX(),self.sprs[i].sprite:getPositionY());
                else
                    str = string.format("[%d,%d,%d,%d],\n        ",1,i,self.sprs[i].sprite:getPositionX(),self.sprs[i].sprite:getPositionY());
                end
                gFile:write(str);
            end
            gFile:write("]\n}");
            gFile:close();
        end
    end
end

function JesonGenerator:createSp()
    self.index = self.index + 1;

    self.currentSprite = ccui.ImageView:create("city.png");
    self.currentSprite:setScale(2.0);
    self.currentSprite:setPosition(cc.p(self.mapPanel:getContentSize().width,self.mapPanel:getContentSize().height));
    self.currentSprite:setTag(self.index);
    self.pContainerNode:addChild(self.currentSprite,1);

    local numberLabel = cc.Label:createWithTTF(string.format("%d",self.index),ttf_msyh,30);
    numberLabel:setPosition(cc.p(self.currentSprite:getContentSize().width/2,self.currentSprite:getContentSize().height+5));
    numberLabel:setColor(cc.c3b(255, 0, 255));
    numberLabel:setTag(self.index);
    self.currentSprite:addChild(numberLabel);
    table.insert(self.sprs,{sprite=self.currentSprite,numberLabel=numberLabel});

    local listener = cc.EventListenerTouchOneByOne:create();
    listener:setSwallowTouches(true);
    listener:registerScriptHandler(handler(self,self.onTouchBegin),cc.Handler.EVENT_TOUCH_BEGAN);
    listener:registerScriptHandler(handler(self,self.onTouchMove),cc.Handler.EVENT_TOUCH_MOVED);
    listener:registerScriptHandler(handler(self,self.onTouchEnd),cc.Handler.EVENT_TOUCH_ENDED);
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self.currentSprite);
    self:addKeyboardEvent();
end

function JesonGenerator:addKeyboardEvent()--注册键盘事件
    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(handler(self,self.keyboardPressed), cc.Handler.EVENT_KEYBOARD_PRESSED)
    listener:registerScriptHandler(handler(self,self.keyboardReleased), cc.Handler.EVENT_KEYBOARD_RELEASED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.currentSprite)
end

function JesonGenerator:keyboardPressed(keyCode, event)--按下事件
    self.keyCode = keyCode;
    -- print("keyCode = "..tostring(keyCode));
    -- print("event = "..tostring(event));
end

function JesonGenerator:keyboardReleased(keyCode, event)--弹起事件
    self.keyCode = 0;
    --print("keyCode = "..tostring(keyCode))
    --print("event = "..tostring(event))
end

function JesonGenerator:updateTime()
    if nil == self.currentSprite then
        return;
    end
    local distance = 10;
    if self.keyCode == 4177 then
        print("left");
        self.currentSprite:setPositionX(self.currentSprite:getPositionX()-distance);
    elseif self.keyCode == 4179 then
        print("right");
        self.currentSprite:setPositionX(self.currentSprite:getPositionX()+distance);
    elseif self.keyCode == 4178 then
        print("up");
        self.currentSprite:setPositionY(self.currentSprite:getPositionY()+distance);
    elseif self.keyCode == 4180 then
        print("down");
        self.currentSprite:setPositionY(self.currentSprite:getPositionY()-distance);
    elseif self.keyCode == 4351 then
        print("delete");
        for i=#self.sprs, 1, -1 do
            if self.sprs[i].numberLabel:getTag() > self.currentTag then
                self.sprs[i].numberLabel:setString(tonumber(self.sprs[i].numberLabel:getString())-1);
            end

            if self.sprs[i].sprite:getTag() == self.currentTag then
                self.sprs[i].sprite:removeFromParent();
                self.sprs[i].sprite = nil;
                table.remove(self.sprs,i);
                self.index = self.index - 1;
            end
        end
    end
    self.keyCode = 0;
end

function JesonGenerator:onEnter()

end

function JesonGenerator:onExit()
    if self.timer~=nil then
        self.timer:stopTimer();
    end
    MGRCManager:releaseResources("JesonGenerator")

end

function JesonGenerator.create(delegate)
    local layer = JesonGenerator:new()
    layer:init(delegate)
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

function JesonGenerator.showBox()
    local layer = JesonGenerator.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
