--class View

View=class("View");

function View:ctor(component)
	self.component=component;
	self.core=Core.getInstance();
	self.isGobal=false;
end

function View:onAdd()

end

function View:onRemove()

end

function View:postNotificationName(commandFile,obj)
	self.core:executeCommand(commandFile,obj);
end	

function View:addObserver(notificationName,callFun)
	self.core:addObserver(self,callFun,notificationName,nil);
end	

function View:removeObserver(notificationName)
	self.core:removeObserver(self,notificationName);
end

function View:getProxy(proxyFile)
	return self.core:getProxy(proxyFile);
end	

function View:setGobal(value)
	self.isGobal=value
end