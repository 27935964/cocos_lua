----公会战view----
--author:hhh time:2017.11.6
local UWMidView=class("UWMidView",View);

function UWMidView:ctor(component)
    	UWMidView.super.ctor(self,component);
    	self.frameLayer=nil;
end

function UWMidView:onAdd()
	self:addObserver(UWNN.UWInitProxyInit,self.dataInit);
	self:addObserver(UWNN.UWInitProxyArmyNum,self.armyNum);
	self:addObserver(UWNN.UWInitProxyWillOver,self.willOver);
	self:addObserver(UWNN.UWInitProxyKillNum,self.killNum);
	self:addObserver(UWNN.UWInitProxyOpenRank,self.openRank);
end

function UWMidView:onRemove()
	self:removeObserver(UWNN.UWInitProxyInit);
	self:removeObserver(UWNN.UWInitProxyArmyNum);
	self:removeObserver(UWNN.UWInitProxyWillOver);
	self:removeObserver(UWNN.UWInitProxyKillNum);
	self:removeObserver(UWNN.UWInitProxyOpenRank);
end

--初始化数据
function UWMidView:dataInit(notification)
	local initProxy=self:getProxy(UWNN.UWInitProxy);
	local UWFrameLayer=require "UWFrameLayer";
	self.frameLayer=coreLayerCreate(self,self.frameLayer,UWFrameLayer);
	if self.frameLayer then
		self.frameLayer:initData(initProxy);
	end
end

function UWMidView:armyNum(notification)
	if self.frameLayer then
		self.frameLayer:armyNum(notification:getObj())
	end
end

function UWMidView:willOver(notification)
	if self.frameLayer then
		local initProxy=self:getProxy(UWNN.UWInitProxy);
		self.frameLayer:willOver(initProxy,notification:getObj());
	end
end

function UWMidView:killNum(notification)
	if self.frameLayer then
		local initProxy=self:getProxy(UWNN.UWInitProxy);
		self.frameLayer:killNum(initProxy,notification:getObj());
	end
end

function UWMidView:openRank(notification)
	if self.frameLayer then
		local initProxy=self:getProxy(UWNN.UWInitProxy);
		self.frameLayer:killNum(initProxy);
	end
end

function UWMidView:getBox()
    return self.component;
end

return UWMidView;