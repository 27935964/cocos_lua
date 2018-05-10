
MGMapScrollView = class("MGMapScrollView",function()
        return MGScrollView:create();
end);

MGMapScrollView.m_ClickTouch = nil
MGMapScrollView.m_touchCounts = 0
MGMapScrollView.m_pMapDelegate = nil
MGMapScrollView.delay = 0

MGMapScrollView.schedulerEntry1 = nil
MGMapScrollView.schedulerEntry2 = nil

function MGMapScrollView:ctor()
    self.m_pMapDelegate = nil
    self.m_touchCounts = 0
    self.delay = cc.Director:getInstance():getDeltaTime()*5
end

function MGMapScrollView:setMapDelegate( delegate )
    self.m_pMapDelegate = delegate
end

function MGMapScrollView:destroy()
    local scheduler = cc.Director:getInstance():getScheduler()
    if self.schedulerEntry1 then
        scheduler:unscheduleScriptEntry(self.schedulerEntry1)
    end
        
    if self.schedulerEntry2 then
        scheduler:unscheduleScriptEntry(self.schedulerEntry2)
    end
end

function MGMapScrollView:init()
    local function scrollViewDidScroll( )
        -- print("scrollViewDidScroll")
        if self.m_pMapDelegate and self.m_pMapDelegate.mapScrollViewDidScroll then
            self.m_pMapDelegate:mapScrollViewDidScroll(self)
        end
    end 

    local function scrollViewDidZoom( )
        -- print("scrollViewDidZoom")
        if self.m_pMapDelegate and self.m_pMapDelegate.mapScrollViewDidZoom then
            self.m_pMapDelegate:mapScrollViewDidZoom(self)
        end
    end

    self:setDelegate()
    self:registerScriptHandler(scrollViewDidScroll,cc.SCROLLVIEW_SCRIPT_SCROLL)
    self:registerScriptHandler(scrollViewDidZoom,cc.SCROLLVIEW_SCRIPT_ZOOM)
    
    local function onTouchBegan(touch, event)
        return self:onTouchBegan(touch,event)
    end

    local function onTouchMoved(touch, event)
        self:onTouchMoved(touch,event)
    end

    local function onTouchEnded(touch, event)
        self:onTouchEnded(touch,event)
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(false)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
   
    return true
end

function MGMapScrollView:onTouchBegan(touch, event)
    if self.m_pMapDelegate and self.m_pMapDelegate.mapScrollViewkTouchBegan then
        self.m_pMapDelegate:mapScrollViewkTouchBegan(self)
    end

    return true
end

function MGMapScrollView:onTouchMoved(touch, event)
    -- print("onTouchMoved")
    self.m_touchCounts = 3
    if self.m_pMapDelegate and self.m_pMapDelegate.mapScrollViewkMove then
        self.m_pMapDelegate:mapScrollViewkMove(self)
    end
end

function MGMapScrollView:onDoubleClick()
    -- print("onDoubleClick")
    if self:getZoomScale()==self:maxScale() then
        self:setZoomScale(self:minScale(),true)
    else
        self:setZoomScale(self:maxScale(),true)
    end

    if self.m_pMapDelegate and self.m_pMapDelegate.mapScrollViewDoubleClick then
        self.m_pMapDelegate:mapScrollViewDoubleClick(self)
    end
end

function MGMapScrollView:onSingleCLick()
    -- print("onSingleCLick")
    if self.m_pMapDelegate and self.m_pMapDelegate.mapScrollViewClick then
        self.m_pMapDelegate:mapScrollViewClick(self)
    end
end

function MGMapScrollView:updateSingleDelay( dt)
    local scheduler = cc.Director:getInstance():getScheduler()
    if self.schedulerEntry1 then
        scheduler:unscheduleScriptEntry(self.schedulerEntry1)
        self.schedulerEntry1 = nil
    end
    if self.m_touchCounts == 1 then
        self:onSingleCLick()
        self.m_touchCounts = 0
    end
end

function MGMapScrollView:updateDoubleDelay( dt )
    local scheduler = cc.Director:getInstance():getScheduler()
    if self.schedulerEntry2 then
        scheduler:unscheduleScriptEntry(self.schedulerEntry2)
        self.schedulerEntry2 = nil
    end
    if self.m_touchCounts == 2 then
        self:onDoubleClick()
        self.m_touchCounts = 0
    end
end

function MGMapScrollView:onTouchEnded(touch, event)
    local p = touch:getLocation();
    self.nowpt = self:convertToNodeSpace(p);
    --cclog("%2f  %2f",p.x,p.y)
    --cclog("%2f  %2f",self:getContainer():getPositionX(),self:getContainer():getPositionY())
    self.nowpt.x = self.nowpt.x - self:getContainer():getPositionX();
    self.nowpt.y = self.nowpt.y - self:getContainer():getPositionY();
    --cclog("%2f  %2f",self.nowpt.x,self.nowpt.y)

    if self.m_touchCounts == 3 then
        self.m_touchCounts = 0

        return    
    end

    if self.m_touchCounts == 0 then

        local function updateSingleDelay( dt)
            self:updateSingleDelay(dt)
        end

        local scheduler = cc.Director:getInstance():getScheduler()
        self.schedulerEntry1 = scheduler:scheduleScriptFunc(updateSingleDelay, self.delay, false)
        self.m_touchCounts = self.m_touchCounts+1

        return
    end

    if self.m_touchCounts == 1 then
        
        local function updateDoubleDelay( dt)
            self:updateDoubleDelay(dt)
        end

        local scheduler = cc.Director:getInstance():getScheduler()
        self.schedulerEntry2 = scheduler:scheduleScriptFunc(updateDoubleDelay, self.delay, false)
        self.m_touchCounts = self.m_touchCounts+1

        return
    end
end

function MGMapScrollView:onTouchCancelled(touch, event)

end

function MGMapScrollView.create()
    local layer = MGMapScrollView:new()
    layer:init()
    
    return layer   
end

