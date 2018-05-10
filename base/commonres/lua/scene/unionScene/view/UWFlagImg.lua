local UWFlagImg=class("UWFlagImg",function()
	return ccui.ImageView:create();
end);

function UWFlagImg:ctor(main)
	self.main=main;
	self.iconImg=ccui.ImageView:create();
	self:addChild(self.iconImg);

	local eventDispatcher = self:getEventDispatcher();
	local listener=cc.EventListenerTouchOneByOne:create();--点击事件
	listener:setSwallowTouches(true);
	listener:registerScriptHandler(handler(self,self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN);
	listener:registerScriptHandler(handler(self,self.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED);
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener,self);
	NodeListener(self);

	self.data=nil;
	self.dir=-1;-- -1助攻 1防守
	self.clickRect=cc.rect(0,0,0,0);
end

function UWFlagImg:onTouchBegan(touch, event)
	local point=self:convertToNodeSpace(touch:getLocation());
	if not cc.rectContainsPoint(self.clickRect, point) then
		return false;
	end
	if self.main and self.main.flagClick then
		self.main:flagClick(self,true);
	end
        	return true;
end

function UWFlagImg:onTouchEnded(touch, event)
       	if self.main and self.main.flagClick then
       		self.main:flagClick(self,false);
       	end
end

function UWFlagImg:setData(data,dir)
	self.data=data;
	self.dir=dir;
	self:loadTexture(string.format("guild_flag_%d.png",data.flag),ccui.TextureResType.plistType);
	self.iconImg:loadTexture(string.format("guild_totem_%d.png",data.flag_bg),ccui.TextureResType.plistType);
	local size=self:getSize();
	self.iconImg:setPosition(size.width*0.5,size.height*0.5);
	self.clickRect=cc.rect(0,0,size.width,size.height);
end

return UWFlagImg;