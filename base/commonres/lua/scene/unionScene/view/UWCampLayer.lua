----公会战营帐----
--author:hhh time:2017.11.20
local UWCampLayer=class("UWCampLayer",function ()
	return cc.Layer:create();
end);

function UWCampLayer:ctor()
	self:setContentSize(cc.size(200,200));

	self.layer=cc.Layer:create();
	self.layer:setContentSize(cc.size(116, 126));
	self.layer:setPosition(-17,45);
	self.layer:setScale(0.7);
	self:addChild(self.layer);

	local headBg=cc.Sprite:createWithSpriteFrameName("GuildWarMain_headBg.png");
	self.layer:addChild(headBg);

	local clipNode=cc.ClippingNode:create();
	clipNode:setContentSize(cc.size(116, 126));
	clipNode:setAnchorPoint(cc.p(0.5, 0.5));
	self.layer:addChild(clipNode);
	
	clipNode:setAlphaThreshold(0.05);
	local stencil=cc.Sprite:createWithSpriteFrameName("GuildWarMain_headMask.png");
	stencil:setPosition(clipNode:getContentSize().width/2, clipNode:getContentSize().height/2+6);
	clipNode:setStencil(stencil);

	self.head=cc.Sprite:create();
	self.head:setPosition(clipNode:getContentSize().width/2, clipNode:getContentSize().height/2+6);
	clipNode:addChild(self.head);

	local campBg=cc.Sprite:createWithSpriteFrameName("GuildWarCampNumBg.png");
	self:addChild(campBg);

	local ttfConfig={};
	ttfConfig.fontFilePath=ttf_msyh;
	ttfConfig.fontSize=22;

	self.numLabel=cc.Label:createWithTTF(ttfConfig,"0", cc.VERTICAL_TEXT_ALIGNMENT_CENTER);
	self.numLabel:setTextColor(cc.c4b(255, 255, 255,255));
	self.numLabel:setAnchorPoint(cc.p(0.5, 0.5));
	self.numLabel:enableShadow(cc.c4b( 0,   0,   0, 191), cc.size(2, -2));
	self:addChild(self.numLabel);

	self:setHeroId(0);
	NodeListener(self);
end

function UWCampLayer:setHeroId(id)
	if id<=0 then
		self.layer:setVisible(false);
		return;
	end

	self.layer:setVisible(true);
	local gm=GENERAL:getAllGeneralModel(id);
	if gm then
		local headImg=gm:head();
		MGRCManager:cacheResource("UWCampLayer", headImg);
		self.head:setSpriteFrame(headImg);
	else
		print("UWCampLayer:setHeroId gm is nil")
	end
end

function UWCampLayer:setNum(value)
	self.numLabel:setString(tostring(value));
end

function UWCampLayer:onEnter()
	
end

function UWCampLayer:onExit()
	MGRCManager:releaseResources("UWCampLayer");
end

return UWCampLayer;