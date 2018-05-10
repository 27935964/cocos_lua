----事件排名列表项----
--author:hhh time:2017.10.24

local UWRankListItem=class("UWRankListItem",function()
	return ccui.Layout:create();
end);

function UWRankListItem:ctor(main)
	self.main=main;
	self:setSize(cc.size(900,56));

	self.listBg=ccui.ImageView:create("com_rank_bg.png",ccui.TextureResType.plistType);
	self.listBg:setCapInsets(cc.rect(30, 30, 1, 1));
	self.listBg:setScale9Enabled(true);
	self.listBg:setSize(cc.size(900, 56));
	self.listBg:setAnchorPoint(cc.p(0,0));
	self:addChild(self.listBg);

	self.icon=ccui.ImageView:create("com_rank_cup_1.png",ccui.TextureResType.plistType);
	self.icon:setAnchorPoint(cc.p(0, 0.5));
	self.icon:setPosition(cc.p(60,27));
	self:addChild(self.icon);

	local ttfConfig={}
	ttfConfig.fontFilePath=ttf_msyh
	ttfConfig.fontSize=22;

	self.indexLabel=cc.Label:createWithTTF(ttfConfig,"1", cc.VERTICAL_TEXT_ALIGNMENT_CENTER);
	self.indexLabel:setTextColor(cc.c4b(255, 255, 255,255));
	self.indexLabel:setAnchorPoint(cc.p(0.5, 0.5));
	self.indexLabel:setPosition(cc.p(82,25));
	self:addChild(self.indexLabel);

	self.nameLabel=cc.Label:createWithTTF(ttfConfig,"玩家名字", cc.VERTICAL_TEXT_ALIGNMENT_CENTER);
	self.nameLabel:setTextColor(cc.c4b(255, 255, 255,255));
	self.nameLabel:setAnchorPoint(cc.p(0, 0.5));
	self.nameLabel:setPosition(cc.p(220,25));
	self:addChild(self.nameLabel);

	self.lvLabel=cc.Label:createWithTTF(ttfConfig,"Lv.99", cc.VERTICAL_TEXT_ALIGNMENT_CENTER);
	self.lvLabel:setTextColor(cc.c4b(255, 255, 255,255));
	self.lvLabel:setAnchorPoint(cc.p(0, 0.5));
	self.lvLabel:setPosition(cc.p(420,25));
	self:addChild(self.lvLabel);
	
	self.froceLabel=cc.Label:createWithTTF(ttfConfig,"10000", cc.VERTICAL_TEXT_ALIGNMENT_CENTER);
	self.froceLabel:setTextColor(cc.c4b(255, 255, 255,255));
	self.froceLabel:setAnchorPoint(cc.p(0, 0.5));
	self.froceLabel:setPosition(cc.p(600,25));
	self:addChild(self.froceLabel);

	self.killNumLabel=cc.Label:createWithTTF(ttfConfig,"10000", cc.VERTICAL_TEXT_ALIGNMENT_CENTER);
	self.killNumLabel:setTextColor(cc.c4b(255, 255, 255,255));
	self.killNumLabel:setAnchorPoint(cc.p(0, 0.5));
	self.killNumLabel:setPosition(cc.p(785,25));
	self:addChild(self.killNumLabel);

	NodeListener(self);
end

function UWRankListItem:initData(data,index)
	if index%2==0 then
		self.listBg:setVisible(false);
	end
	
	if index<=3 then
		self.indexLabel:setVisible(false);
		self.icon:setVisible(true);
		self.icon:loadTexture(string.format("com_rank_cup_%d.png",index),ccui.TextureResType.plistType);
	else 
		self.icon:setVisible(false);
		self.indexLabel:setVisible(true);
		self.indexLabel:setString(tostring(index));
	end
	self.nameLabel:setString(unicode_to_utf8(data.name));
	self.lvLabel:setString(string.format(MG_TEXT("plotMenu4"),data.lv));
	self.froceLabel:setString(tostring(data.score));
	self.killNumLabel:setString(tostring(data.kill));
end

function UWRankListItem:onEnter()

end

function UWRankListItem:onExit()
	
end

return UWRankListItem;