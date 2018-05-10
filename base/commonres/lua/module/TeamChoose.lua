
TeamChooseLayer = class("TeamChooseLayer", MGWidget)
TeamChooseLayer.pWidget = nil
TeamChooseLayer.panel = nil
TeamChooseLayer.chooseBtn = nil
TeamChooseLayer.isSpread = false
TeamChooseLayer.countryLabel = nil
TeamChooseLayer.armsLabel = nil
TeamChooseLayer.conPanel = nil
TeamChooseLayer.chooseImg = nil
TeamChooseLayer.armses = nil
TeamChooseLayer.countries = nil
TeamChooseLayer.arms = em_ArmsAll
TeamChooseLayer.country = em_Country_All
TeamChooseLayer.m_delegate = nil

TeamChooseLayer.BG_W = 340
TeamChooseLayer.BG_COM_H = 68
TeamChooseLayer.BG_EXT_H = 486


function TeamChooseLayer:init(delegate)
	local pWidget = MGRCManager:widgetFromJsonFile("TeamChooseLayer","TeamChoose_ui.ExportJson")
    self:addChild(pWidget)
    self:setContentSize(cc.size(TeamChooseLayer.BG_W, TeamChooseLayer.BG_COM_H))

    self.pWidget = pWidget

    self.m_delegate = delegate

    local panel = pWidget:getChildByName("Panel")
    self.panel = panel

    self.conPanel = panel:getChildByName("conPanel")
    self.chooseImg = panel:getChildByName("chooseImg")

    self.countryLabel = panel:getChildByName("countryLabel")
    self.armsLabel = panel:getChildByName("armsLabel")

    local function chooseClick(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            MGSound:getInstance():play(SOUND_COM_CLICK);
        end

		if eventType == ccui.TouchEventType.ended then
            self.isSpread = not self.isSpread
            self:updateContent()
        end
	end
    local chooseBtn = panel:getChildByName("chooseBtn")
    chooseBtn:addTouchEventListener(chooseClick)
    self.chooseBtn = chooseBtn

    local function armsClick(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            local label = self.armses[sender:getTag()]
            label:setColor(cc.c3b(255,255,0))
            self.armsLabel:setText(label:getStringValue())
            self.arms = sender:getTag()
            for k,v in pairs(self.armses) do
                if k ~= sender:getTag() then
                    v:setColor(cc.c3b(255,255,255))
                end
            end

            if self.m_delegate then
                self.m_delegate:onTeamChoose(self.arms,self.country)
            end
        end
    end
    self.armses = {}
    for i=1,4 do
        local armsLabel = self.conPanel:getChildByName(string.format("armsLabel_%d",i))
        table.insert(self.armses, armsLabel)

        local lay = ccui.Layout:create()
        lay:setTag(i)
        lay:setSize(armsLabel:getContentSize())
        lay:setAnchorPoint(armsLabel:getAnchorPoint())
        lay:setPosition(armsLabel:getPositionX(),armsLabel:getPositionY())
        lay:setTouchEnabled(true)
        lay:addTouchEventListener(armsClick)
        self.conPanel:addChild(lay)
    end

    local function countryClick(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            local label = self.countries[sender:getTag()]
            label:setColor(cc.c3b(255,255,0))
            self.countryLabel:setText(label:getStringValue())
            self.country = sender:getTag()-1
            for k,v in pairs(self.countries) do
                if k ~= sender:getTag() then
                    v:setColor(cc.c3b(255,255,255))
                end
            end

            if self.m_delegate then
                self.m_delegate:onTeamChoose(self.arms,self.country)
            end
        end
    end
    self.countries = {}
    for i=1,5 do
        local countryLabel = self.conPanel:getChildByName(string.format("countryLabel_%d",i-1))
        table.insert(self.countries, countryLabel)

        local lay = ccui.Layout:create()
        lay:setTag(i)
        lay:setSize(countryLabel:getContentSize())
        lay:setAnchorPoint(countryLabel:getAnchorPoint())
        lay:setPosition(countryLabel:getPositionX(),countryLabel:getPositionY())
        lay:setTouchEnabled(true)
        lay:addTouchEventListener(countryClick)
        self.conPanel:addChild(lay)
    end

    self.isSpread = false

    self:updateContent()

end

function TeamChooseLayer:updateContent()
	if self.isSpread  then
		self.chooseImg:setSize(cc.size(TeamChooseLayer.BG_W, TeamChooseLayer.BG_EXT_H ))
		self.conPanel:setEnabled(true)
	else
		self.chooseImg:setSize(cc.size(TeamChooseLayer.BG_W, TeamChooseLayer.BG_COM_H ))
		self.conPanel:setEnabled(false)
	end
end

function TeamChooseLayer:setIsSpread(isSpread)
    if self.isSpread == isSpread then
        return
    end

    self.isSpread = isSpread

    self:updateContent()
end

function TeamChooseLayer:onEnter()
    
end

function TeamChooseLayer:onExit()
    MGRCManager:releaseResources("TeamChooseLayer")

end

function TeamChooseLayer.create(delegate)
    local layer = TeamChooseLayer:new()
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
