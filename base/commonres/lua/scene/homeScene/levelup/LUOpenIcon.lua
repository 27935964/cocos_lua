----玩家升级界面功能开发图标----
--author:hhh time:2017.10.23

local LUOpenIcon=class("LUOpenIcon",function()
	return ccui.Layout:create();
end);

function LUOpenIcon:ctor()
	self.imgeView= ccui.ImageView:create();
	self.imgeView:setAnchorPoint(cc.p(0,0));
	self.imgeView:setTouchEnabled(true);
	self.imgeView:addTouchEventListener(handler(self,self.onIconClick));
	self:addChild(self.imgeView);

	self:setSize(cc.size(100,85));
	NodeListener(self);
end

function LUOpenIcon:onIconClick(sender, eventType)
          if eventType == ccui.TouchEventType.ended then
                    print("LUOpenIcon:onIconClick",self.data.name);
          end
end

function LUOpenIcon:initData(data)
	self.data=data;
	MGRCManager:cacheResource("LUOpenIcon",data.lvup_pic);
	self.imgeView:loadTexture(data.lvup_pic,ccui.TextureResType.plistType);
end

function LUOpenIcon:onEnter()

end

function LUOpenIcon:onExit()
	MGRCManager:releaseResources("LUOpenIcon");
end

return LUOpenIcon;