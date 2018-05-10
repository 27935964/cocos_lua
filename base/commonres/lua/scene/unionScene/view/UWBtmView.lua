----公会战view----
--author:hhh time:2017.11.6
local UWBtmView=class("UWBtmView",View);

function UWBtmView:ctor(component)
    	UWBtmView.super.ctor(self,component);
    	self.btmLayer=nil;
end

function UWBtmView:onAdd()
	self:addObserver(UWNN.UWInitProxyInit,self.dataInit);
	self:addObserver(UWNN.UWInitProxyFightAction,self.fightAction);
	self:addObserver(UWNN.UWInitProxyFightBack,self.fightBack);
	self:addObserver(UWNN.UWInitProxyArmyNum,self.armyNum);
	self:addObserver(UWNN.UWInitProxyHeadNum,self.armyHead);
end

function UWBtmView:onRemove()
	self:removeObserver(UWNN.UWInitProxyInit);
	self:removeObserver(UWNN.UWInitProxyFightAction);
	self:removeObserver(UWNN.UWInitProxyFightBack);
	self:removeObserver(UWNN.UWInitProxyArmyNum);
	self:removeObserver(UWNN.UWInitProxyHeadNum);
end

--初始化数据
function UWBtmView:dataInit(notification)
	self.initProxy=self:getProxy(UWNN.UWInitProxy);
	local UWBtmLayer=require "UWBtmLayer";
	self.btmLayer=coreLayerCreate(self,self.btmLayer,UWBtmLayer);
	if self.btmLayer then
		self.btmLayer:initData(self.initProxy);
	end
end

function UWBtmView:fightAction(notification)
	if self.btmLayer then
		self.btmLayer:fightAction(notification:getObj());
	end
end

function UWBtmView:fightBack(notification)
	if self.btmLayer then
		self.btmLayer:fightBack(notification:getObj());
	end
end

function UWBtmView:armyNum(notification)
	if self.btmLayer then
		self.btmLayer:armyNum(notification:getObj());
	end
end

function UWBtmView:armyHead(notification)
	if self.btmLayer then
		self.btmLayer:armyHead(notification:getObj());
	end
end

function UWBtmView:getBox()
    	return self.component;
end

return UWBtmView;