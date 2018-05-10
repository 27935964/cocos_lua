--class Core

require "NotificationCenter"
require "Notification"

Core=class("Core");

local _coreInstance=nil;

function Core:ctor()
    self.views={};
    self.contros={};
    self.proxys={};
    self.center=NotificationCenter.getInstance();
    self.modules={};
    self.curModule=nil;
    self.curModuleKey=nil;
end

function Core:setModule(key)
        if key==nil then
            print("Core:setModules curModule is nil");
            self.curModuleKey=nil;
            self.curModule=nil;
        else
            if self.modules[key]==nil then
                print("Core:setModules create new module ",key);
                self.modules[key]={views={},contros={},proxys={}};
            end
            print("Core:setModules curModule is ",key);
            self.curModuleKey=key;
            self.curModule=self.modules[key];
        end
end

function Core:addView(viewFile,component)
    if(self.views[viewFile]==nil) then
        print("Core:addView ",viewFile);
        local View=require (viewFile);
        local view=View.new(component);
        view:onAdd();
        self.views[viewFile]=view;
        if self.curModule~=nil then
            self.curModule.views[viewFile]=view;    
        end
    end    
end

function Core:removeView(viewFile)
    local view=self.views[viewFile];
    if(view~=nil) then
        view:onRemove();
        self.views[viewFile]=nil;
    end    
end

function Core:getView(viewFile)
    return self.views[viewFile];
end

function Core:removeCommand(commandFile)
    local command=self.contros[commandFile];
    if(command~=nil) then
        command:onRemove();
        self.contros[commandFile]=nil;
    end  
end

function Core:executeCommand(commandFile,obj)
    if(self.contros[commandFile]==nil) then
        print("Core:executeCommand ",commandFile);
        local Cmmmand=require (commandFile);
        local command=Cmmmand.new();
        self.contros[commandFile]=command;
        if self.curModule~=nil then
            self.curModule.contros[commandFile]=command;    
        end
        command:execute(obj);
    else
        local command=self.contros[commandFile];
        command:execute(obj); 
    end 
end

function Core:getCommand(commandFile)
    return self.contros[commandFile];
end

function Core:removeProxy(proxyFile)
    local proxy=self.proxys[proxyFile];
    if(proxy~=nil) then
        proxy:onRemove();
        self.proxys[proxyFile]=nil;
    end    
end

function Core:getProxy(proxyFile)
    if(self.proxys[proxyFile]==nil) then
        print("Core:getProxy ",proxyFile);
        local Proxy=require (proxyFile);
        local proxy=Proxy.new();
        proxy:onAdd();
        self.proxys[proxyFile]=proxy;
         if self.curModule~=nil then
            self.curModule.proxys[proxyFile]=proxy;    
        end
    end
    return self.proxys[proxyFile];
end

function Core:removeAll(clearGobal)
    for k,v in pairs(self.views) do
        if clearGobal or not v.isGobal then
            self:removeView(k);
        end
    end

    for k,v in pairs(self.proxys) do
        if clearGobal or not v.isGobal then
            self:removeProxy(k);
        end
    end

    for k,v in pairs(self.contros) do
        if clearGobal or not v.isGobal then
            self:removeCommand(k);
        end
    end

    self.modules={};
    self.curModule=nil;
    self.curModuleKey=nil;
end

function Core:removeModule(key)
    local moduleKey=key or self.curModuleKey;

    if moduleKey~=nil then
        local module=self.modules[moduleKey];
        for k,v in pairs(module.views) do
            if not v.isGobal then
                self:removeView(k);
            end
        end

        for k,v in pairs(module.proxys) do
            if not v.isGobal then
                self:removeProxy(k);
            end
        end

        for k,v in pairs(module.contros) do
            if not v.isGobal then
                self:removeCommand(k);
            end
        end

        self.modules[moduleKey]=nil;
        if self.curModuleKey==moduleKey then
            self.curModuleKey=nil;
            self.curModule=nil;
        end
    end
end

function Core:dump()
    print("===== Core:dump =====\n");
    local fileNum=0;
    print(">>>> views:");
    for k,v in pairs(self.views) do
        print(k);
        fileNum=fileNum+1;
    end
    print(string.format("view files:%d\n",fileNum));

    local fileNum=0;
    print(">>>> proxys:");
    for k,v in pairs(self.proxys) do
        print(k);
        fileNum=fileNum+1;
    end
    print(string.format("proxy files:%d\n",fileNum));

    local fileNum=0;
    print(">>>> commands:");
    for k,v in pairs(self.contros) do
        print(k);
        fileNum=fileNum+1;
    end
    print(string.format("command files:%d\n",fileNum));

    local fileNum=0;
    print(">>>> modules:");
    for k,v in pairs(self.modules) do
        print(k);
        fileNum=fileNum+1;
    end
    print(string.format("modules number:%d\n",fileNum));
    print(string.format("curModule is %s\n",self.curModuleKey));
end

function Core:addObserver(target,callFun,notificationName,obj)
    self.center:addObserver(target,callFun,notificationName,obj);
end

function Core:removeObserver(target,notificationName)
    self.center:removeObserver(target,notificationName);
end

function Core:postNotificationName(commandFile,obj)
    self:executeCommand(commandFile,obj);
end

function Core:postNotification(notificationName,obj)
    assert(notificationName~=nil,"Core:postNotification notificationName is nil");
    local notification=Notification.new(notificationName,obj); 
    self.center:postNotification(notificationName,notification);
end

--static function

function Core.getInstance()
    if(_coreInstance==nil) then
        _coreInstance=Core.new();
    end 
    return _coreInstance;
end

function Core.purgeInstance()
    if(_coreInstance~=nil) then
        _coreInstance=nil;
    end    
end

