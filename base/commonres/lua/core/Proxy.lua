--class Proxy

Proxy=class("Proxy");

function Proxy:ctor()
    self.core=Core.getInstance();
    self.isGobal=false;
end    

function Proxy:onAdd()

end

function Proxy:onRemove()

end

function Proxy:postNotificationName(notificationName,obj)
    self.core:postNotification(notificationName,obj);
end

function Proxy:setGobal(value)
	self.isGobal=value
end