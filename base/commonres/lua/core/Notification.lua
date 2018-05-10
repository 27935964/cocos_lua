--Class Notification

Notification=class("Notification");

Notification.__index=Notification;

function Notification:ctor(notificationName,obj)
    self.notificationName=notificationName;
    self.obj=obj;
end


function Notification:getNotificationName()
    return self.notificationName;
end

function Notification:getObj()
    return self.obj;
end

