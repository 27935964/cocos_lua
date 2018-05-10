
CCTimer=class("CCTimer");

CCTimer.__index=CCTimer;

function CCTimer:ctor()
    self.schedulerId=-1;
    self.count=0;
    self.scheduler=cc.Director:getInstance():getScheduler();
    self.schedulerHandler=nil;
end

function CCTimer:timerEndHd(dt)

    if self.schedulerHandler~=nil then
        self.count=self.count+1;
        self.schedulerHandler();
    end

    if self.onlyOnce then
        self:stopTimer();
    end
end

function CCTimer:startTimer(ms,callBack,onlyOnce)
    onlyOnce=onlyOnce or false;
    self:stopTimer();
    self.schedulerHandler=callBack;
    self.onlyOnce=onlyOnce;
    self.schedulerId=self.scheduler:scheduleScriptFunc(handler(self,self.timerEndHd),ms/1000,false);
end

function CCTimer:stopTimer()
    if self.schedulerId~=-1 then
        self.scheduler:unscheduleScriptEntry(self.schedulerId);
        self.schedulerId=-1;
        self.count=0;
        self.schedulerHandler=nil;
    end
end

function CCTimer:isRuning()
    return self.schedulerId~=-1;
end