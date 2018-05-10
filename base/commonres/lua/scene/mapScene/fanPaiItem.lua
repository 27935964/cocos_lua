require "HeroHead"

fanPaiItem = class("fanPaiItem",function()  
    return ccui.Layout:create();
end)

function fanPaiItem:ctor()
    self:init()
end

function fanPaiItem:init()
    self:setSize(cc.size(200, 300));
    self:setAnchorPoint(cc.p(0.5,0.5));

    self:setTouchEnabled(true);
    self:addTouchEventListener(handler(self,self.onButtonClick));

    self.bgSpr = cc.Sprite:createWithSpriteFrameName("fanpai_card.png");
    self.bgSpr:setPosition(cc.p(self:getSize().width/2,self:getSize().height/2));
    self:addChild(self.bgSpr);

    self.logoSpr = cc.Sprite:createWithSpriteFrameName("fanpai_logo.png");
    self.logoSpr:setPosition(cc.p(self.bgSpr:getContentSize().width/2,self.bgSpr:getContentSize().height/2));
    self.bgSpr:addChild(self.logoSpr);

    self.masSpr = cc.Sprite:createWithSpriteFrameName("main_icon_masonry.png");
    self.masSpr:setPosition(cc.p(self:getSize().width/2-20,0));
    self:addChild(self.masSpr);

    self.numLabel = cc.Label:createWithTTF("10",ttf_msyh,22);
    self.numLabel:setAnchorPoint(cc.p(0, 0.5));
    self.numLabel:setPosition(cc.p(self:getSize().width/2, 0.5));
    self:addChild(self.numLabel);
end

function fanPaiItem:setData(data,index,curLayer,value)
    self.data = data;
    self.index = index;
    self.curLayer = curLayer;
    self.flip_item = self.data.flip_item;
    self.get = {};
    if self.data.get and #self.data.get > 0 then
        self.get = getefflist(self.data.get);
    end

    self.logoSpr:setVisible(true);
    if curLayer == 1 then
            self.logoSpr:setVisible(false);
            self:createItem(self.flip_item[index].item_type,self.flip_item[index].item_id,self.flip_item[index].item_num);
    elseif curLayer == 2 then
        for i=1,#self.get do
            if self.get[i].id == index then
                self.logoSpr:setVisible(false);
                local j = self.get[i].count+1;
                self:createItem(self.flip_item[j].item_type,self.flip_item[j].item_id,self.flip_item[j].item_num);
                break;
            end
        end
    end

    if value > 0 or curLayer == 1 then
        self:setShow(false);
    else
        self:setShow(true);
    end
end

function fanPaiItem:createItem(item_type,item_id,item_num)
    local function setState()
        local item = resItem.create(self);
        item:setData(item_type,item_id,item_num);
        item:setNum(item_num);
        item:setPosition(cc.p(self:getSize().width/2,self:getSize().height/2));
        self:addChild(item);
        self.logoSpr:setVisible(false);
    end
    --旋转的时间、起始半径、半径差、起始z角、旋转z角差、起始x角、旋转x角差
    local orbit=cc.OrbitCamera:create(0.2, 1, 0, 0, 90, 0, 0);
    local orbit2=cc.OrbitCamera:create(0.2, 1, 0, 90, 90, 0, 0);
    local function setScaleX()
        self:setScaleX(-1);
    end
    local callFunc = cc.CallFunc:create(setScaleX);
    local callFunc1 = cc.CallFunc:create(setState);
    if self.curLayer == 1 then
        self:runAction(cc.Sequence:create(callFunc1));
    else
        self:runAction(cc.Sequence:create(callFunc,orbit,callFunc1,orbit2));
    end
end

function fanPaiItem:setShow(isShow)
    self.masSpr:setVisible(isShow);
    self.numLabel:setVisible(isShow);
end

function fanPaiItem:setMasNum(num)
    if self.numLabel then
        self.numLabel:setString(num);
    end
end

function fanPaiItem:onButtonClick(sender, eventType)
    if eventType == ccui.TouchEventType.began then
        self.bgSpr:setShaderProgram(MGGraySprite:getLightShaderProgram(3));
        self.logoSpr:setShaderProgram(MGGraySprite:getLightShaderProgram(3));
    end
    if eventType == ccui.TouchEventType.canceled then
        self.bgSpr:setShaderProgram(MGGraySprite:getLightShaderProgram(0));
        self.logoSpr:setShaderProgram(MGGraySprite:getLightShaderProgram(0));
    end
    if eventType == ccui.TouchEventType.ended then
        self.bgSpr:setShaderProgram(MGGraySprite:getLightShaderProgram(0));
        self.logoSpr:setShaderProgram(MGGraySprite:getLightShaderProgram(0));
        if self.delegate and self.delegate.doFlipSendReq then
            self.delegate:doFlipSendReq(self.index);
        end
    end
end

function fanPaiItem:onEnter()

end

function fanPaiItem:onExit()
    MGRCManager:releaseResources("fanPaiItem");
end

function fanPaiItem.create(delegate)
    local layer = fanPaiItem:new()
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
