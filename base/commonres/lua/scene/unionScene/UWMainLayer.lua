----公会战入口----
--author:hhh time:2017.11.6
require "CoreLayer"
require "UWNoticName"
require "ResourceTip"

_G_UN_CITY_ID=0;

UWMainLayer=class("UWMainLayer",CoreLayer)

local _instance;

function UWMainLayer:ctor(cityId)
	
	assert(_instance==nil,"调用UWMainLayer.getInstance()取得实例");
	_G_UN_CITY_ID=cityId;
	self.isFightBack=false;

	UWMainLayer.super.ctor(self);
	self.topBox=cc.Layer:create();
	self.midBox=cc.Layer:create();
	self.btmBox=cc.Layer:create();
	
	self:addChild(self.btmBox);
	self:addChild(self.midBox);
	self:addChild(self.topBox);

    	NodeListener(self);
end

function UWMainLayer:onEnter()
	self:setModule("UWMainLayer");
	self:postNotificationName(UWNN.UWInitCmd,self);
end

function UWMainLayer:onExit()
	self:removeModule("UWMainLayer");
	_instance=nil;
end

function UWMainLayer.getInstance(cityId)
	if _instance==nil then
		_instance=UWMainLayer.new(cityId);
	end
	return _instance;
end

function UWMainLayer.dispose()
	if _instance~=nil then
		_instance=nil;
	end
end
