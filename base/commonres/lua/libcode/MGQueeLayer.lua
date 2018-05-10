
MGQueeLayer = class("MGQueeLayer", MGLayer)

function MGQueeLayer:init()
	
end

function MGQueeLayer:setContent(content, color3b, size)
	self:setContentSize(size)
    
	if not self.pClipZone then 
		self.pClipZone = ccui.Layout:create();
        self.pClipZone:setAnchorPoint(cc.p(0.5, 0.5))
        self.pClipZone:setClippingEnabled(true)
    	self:addChild(self.pClipZone);
	end
    self.pClipZone:setSize(size);
    

    if not self.pLabel then
    	local ttfConfig  = {}
    	ttfConfig.fontFilePath= ttf_msyh
    	ttfConfig.fontSize = 25
    	self.pLabel = cc.Label:create()
    	self.pLabel:setTTFConfig(ttfConfig)
    	self.pLabel:setAnchorPoint(cc.p(0.5, 0.5))
    	self.pClipZone:addChild(self.pLabel, 1)
	end
    
    self.pLabel:setColor(color3b)
    self.pLabel:setPosition(cc.p(self.pClipZone:getSize().width / 2, self.pClipZone:getSize().height /2-2))
    self.pLabel:setString(content)
    
    self:checkMove()
end

function MGQueeLayer:checkMove()
    self:endMove()

    if not self.pLabel then
        return
    end

    if self.pLabel:getContentSize().width > self.pClipZone:getContentSize().width then
        self.pLabel:setAnchorPoint(cc.p(0, 0.5))
        self.pLabel:setPositionX(0)


        local scheduler = cc.Director:getInstance():getScheduler()
        local function delayFunc() 
            if self.schedulerDelay ~= nil then
                scheduler:unscheduleScriptEntry(self.schedulerDelay)
                self.schedulerDelay = nil
            end

            local function updateAct(dt)
                self:updateMove()
            end
            self.schedulerEntry = scheduler:scheduleScriptFunc(updateAct, 0.03, false)
        end
        self.schedulerDelay = scheduler:scheduleScriptFunc(delayFunc, 5, false)
    end
end

function MGQueeLayer:endMove()
    if self.schedulerEntry ~= nil then
        local scheduler = cc.Director:getInstance():getScheduler()
        scheduler:unscheduleScriptEntry(self.schedulerEntry)
        self.schedulerEntry = nil
    end

    if self.schedulerDelay ~= nil then
        local scheduler = cc.Director:getInstance():getScheduler()
        scheduler:unscheduleScriptEntry(self.schedulerDelay)
        self.schedulerDelay = nil
    end

    self.schCount = 0

    if not self.pLabel then
        return
    end

    self.pLabel:setAnchorPoint(cc.p(0.5, 0.5))
    self.pLabel:setPosition(cc.p(self.pClipZone:getSize().width / 2, self.pClipZone:getSize().height /2-2))
end

function MGQueeLayer:updateMove()
    local endX = -self.pLabel:getContentSize().width
    if self.schCount >= 1 then
        endX = 0
    end
    if self.pLabel:getPositionX() <= endX then
        self.schCount = self.schCount +1
        if self.schCount >= 2 then
            self:checkMove()
        else
            self.pLabel:setPositionX(self.pClipZone:getContentSize().width)
        end
    end
    self.pLabel:setPositionX(self.pLabel:getPositionX()-2)
end

function MGQueeLayer:ctor()
	self.pClipZone = nil
	self.pLabel = nil
    self.schedulerEntry = nil 
    self.schedulerDelay = nil
    self.schCount = 0
end

function MGQueeLayer:onEnter()
    self:checkMove()
end

function MGQueeLayer:onExit()
    self:endMove()
end

function MGQueeLayer.create()
    local layer = MGQueeLayer:new()
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