--Class NotificationObserver

NotificationObserver=class("NotificationObserver");

function NotificationObserver:ctor(target,callFun,notificationName,obj)
    self.target=target;
    self.callFun=callFun;
    self.notificationName=notificationName;
    self.obj=obj;
end

function NotificationObserver:perform(obj)

    if(obj~=nil) then
        self.callFun(self.target,obj);
    else
        self.callFun(self.target,self.obj);
    end    
end   

function NotificationObserver:getTarget()
    return self.target;
end

function NotificationObserver:getCallFun()
    return self.callFun;
end

function NotificationObserver:getNotificationName()
    return self.notificationName;
end

function NotificationObserver:getObj()
    return self.obj;
end

