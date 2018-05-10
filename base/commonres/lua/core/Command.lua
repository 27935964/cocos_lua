--class Command

Command=class("Command");

function Command:ctor()
    self.core=Core.getInstance();
    self.isGobal=false;
end

function Command:execute(notification)

end

function Command:onRemove()

end

function Command:postNotificationName(commandFile,obj)
	self.core:executeCommand(commandFile,obj);
end

function Command:getProxy(proxyFile)
	return self.core:getProxy(proxyFile);
end

function Command:addView(viewFile,component)
	self.core:addView(viewFile,component);
end

function Command:remove()
	self.core:removeCommand(self.__cname);
end

function Command:setGobal(value)
	self.isGobal=value
end