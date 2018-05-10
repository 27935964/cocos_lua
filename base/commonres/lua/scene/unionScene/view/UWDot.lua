----公会战战场标记点----
--author:hhh time:2017.11.17
local UWDot=class("UWDot",function()
	return cc.Sprite:create();
end);

function UWDot:ctor()

	self:setSpriteFrame("GuildWarMap_posBg.png");

	local ttfConfig={};
	ttfConfig.fontFilePath=ttf_msyh;
	ttfConfig.fontSize=30;

	self.tileLabel=cc.Label:createWithTTF(ttfConfig,"0", cc.VERTICAL_TEXT_ALIGNMENT_CENTER);
	self.tileLabel:setTextColor(cc.c4b(255, 255, 255,255));
	self.tileLabel:setAnchorPoint(cc.p(0.5, 0.5));
	self.tileLabel:setPosition(cc.p(20,20));
	self:addChild(self.tileLabel);
end

function UWDot:initData(index)
	self.tileLabel:setString(tostring(index));
end

return UWDot;