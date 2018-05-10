----云中城遥控骰子Item界面----

local RemoteDiceItem=class("RemoteDiceItem",function()
	return cc.Layer:create();
end);

function RemoteDiceItem:ctor()
  	self.delegate=nil;
    -- 
    local size=cc.size(126, 76);
  	self.bgImg=ccui.ImageView:create("dice_1.png", ccui.TextureResType.plistType);
    self.bgImg:setAnchorPoint(cc.p(0.5,0.5));
    self.bgImg:setPosition(size.width/2,size.height/2);
    self:addChild(self.bgImg);
    self.bgRect=cc.rect(0, 0, self.bgImg:getContentSize().width, self.bgImg:getContentSize().height);
end

function RemoteDiceItem:addTouch(touchHandler)
    local listenner=cc.EventListenerTouchOneByOne:create();
    listenner:setSwallowTouches(false);
    listenner:registerScriptHandler(handler(self,self.onTouchBegin),cc.Handler.EVENT_TOUCH_BEGAN);
    listenner:registerScriptHandler(handler(self,self.onTouchMove),cc.Handler.EVENT_TOUCH_MOVED);
    listenner:registerScriptHandler(touchHandler,cc.Handler.EVENT_TOUCH_ENDED);
    local eventDispatcher=self:getEventDispatcher();
    eventDispatcher:removeEventListenersForTarget(self);
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner,self);
end

function RemoteDiceItem:onTouchBegin(touch, event)
    local point=self.bgImg:convertToNodeSpace(touch:getLocation());
    if not cc.rectContainsPoint(self.bgRect, point) then
        return false
    end
    self.isMove=false;
    self.touchPoint=touch:getLocation();
    return true;
end

function RemoteDiceItem:onTouchMove(touch,event)
    local oldPoint=touch:getLocation();
    if math.abs(oldPoint.y-self.touchPoint.y)>10 then
        self.isMove=true;
    end
end

function RemoteDiceItem:updataData()
    self.bgImg:loadTexture(string.format("dice_%d.png",self.index), ccui.TextureResType.plistType);
end

function RemoteDiceItem:initData(delegate, index)
    self.delegate=delegate;
    self.index=index;
    self:updataData();
    self:addTouch(handler(self,self.onClick));
end

function RemoteDiceItem:onClick(touch, event)
    local y=touch:getLocation().y;
    print("y=== ", y)
    -- 
    if not self.isMove and y>110 and y<571 then
        if self.delegate then
            self.delegate:clickRDiceItem(self.index);
        end
    end
end

function RemoteDiceItem:onEnter()
end

function RemoteDiceItem:onExit()
	MGRCManager:releaseResources("RemoteDiceItem");
end

return RemoteDiceItem;