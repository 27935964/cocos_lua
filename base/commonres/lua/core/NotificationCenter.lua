--class NotificationCenter

require "NotificationObserver"

NotificationCenter=class("NotificationCenter");

local _centerInstance=nil;

function NotificationCenter:ctor()
    self.observers={};
end

  
function NotificationCenter:observerExisted(target,notificationName)
    
   for key,value in pairs(self.observers) do
        if(value.notificationName==notificationName and value.target==target) then
            return true;
        end
    end 
    return false;

end    

function NotificationCenter:addObserver(target,callFun,notificationName,obj)

    if(self:observerExisted(target,notificationName)) then 
        return;
    end

   local observer=NotificationObserver.new(target,callFun,notificationName,obj);
   table.insert(self.observers,observer); 
end    

function NotificationCenter:removeObserver(target,notificationName)
    for key,value in pairs(self.observers) do
        if(value.notificationName==notificationName and value.target==target) then
            table.remove(self.observers,key);
            break;
        end
    end
end    

function NotificationCenter:removeAllObservers(target)
    local arr={};
    for key,value in pairs(self.observers) do
        if value.target==target then
            table.insert(arr,key); 
        end
    end

    local len=#arr;
    for i=len, 1, -1 do
            local key=arr[i];
            table.remove(self.observers,key);
    end

    return len;
end   

function NotificationCenter:postNotification(notificationName,obj)
    for key,value in pairs(self.observers) do
        if(value.notificationName==notificationName) then
            value:perform(obj);
        end
    end 
end

--static function

function NotificationCenter.getInstance()
    if(_centerInstance==nil) then
        _centerInstance=NotificationCenter.new();
    end    
    return _centerInstance;
end    

function NotificationCenter.purgeInstance()
    if(_centerInstance~=nil) then
        _centerInstance=nil;
    end    
end  
