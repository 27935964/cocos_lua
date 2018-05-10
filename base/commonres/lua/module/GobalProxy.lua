----全局数据推送----
--author:hhh time:2017.17.7

GR={
	GobalProxyTest="GobalProxyTest",
       }

local GobalProxy=class("GobalProxy",Proxy);

function GobalProxy:ctor()
	GobalProxy.super.ctor(self);
	self:setGobal(true);

	-- self.testNum=0;
end

-- function GobalProxy:test()
	-- self.testNum=self.testNum+1;
	-- self:postNotificationName(GR.GobalProxyTest);
-- end

function GobalProxy:onRemove()
	print("GobalNoticCmd:onRemove error: can not remove GobalProxy");
end

return GobalProxy;