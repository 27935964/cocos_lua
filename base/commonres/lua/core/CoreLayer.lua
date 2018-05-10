--class CoreLayer

require "extern"
require "Core"
require "View"
require "Command"
require "Proxy"

CoreLayer=class("CoreLayer",function()
    return cc.Layer:create();
end);

CoreLayer.__index=CoreLayer;

function CoreLayer:ctor()
   self.core=Core.getInstance();
end

function CoreLayer:addView(viewFile,component)
    self.core:addView(viewFile,component);
end

function CoreLayer:getProxy(proxyFile)
    return self.core:getProxy(proxyFile);
end

function CoreLayer:postNotificationName(commandFile,obj)
    self.core:executeCommand(commandFile,obj)
end

function CoreLayer:setModule(key)
	self.core:setModule(key);
end

function CoreLayer:removeModule(key)
	self.core:removeModule(key);
end

--通用功能函数，创建界面，删除界面功能
function coreLayerHelp(view,notification,layer,Clazz)
	local data=notification:getObj();
	if data and data.isOpen then
		if layer==nil then
	 		layer=Clazz.new();
	 		layer:setView(view);
	 		NodeListener(layer);	
	 		view:getBox():addChild(layer);
		end
	else
		if layer~=nil and layer:getParent()~=nil then
			layer:removeFromParent();
			layer=nil;
		end
	end
	return layer;
end

function coreLayerCreate(view,layer,Clazz)
	if layer==nil then
	 	layer=Clazz.new();
	 	layer:setView(view);
	 	NodeListener(layer);	
	 	view:getBox():addChild(layer);
	end
	return layer;
end