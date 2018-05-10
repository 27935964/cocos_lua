----事件剧情奖励列表项----
--author:hhh time:2017.10.25

local PlotRewardListItem=class("PlotRewardListItem",function()
	return ccui.Layout:create();
end);

function PlotRewardListItem:ctor(main)
	self.main=main;
	self:setSize(cc.size(610,200));

	self.imgBg=ccui.ImageView:create("common_special_bg.png",ccui.TextureResType.plistType);
	self.imgBg:setCapInsets(cc.rect(74, 63, 1, 1));
	self.imgBg:setScale9Enabled(true);
	self.imgBg:setSize(cc.size(604, 190));
	self.imgBg:setAnchorPoint(cc.p(0,0));
	self:addChild(self.imgBg);

	local bgSize=self.imgBg:getSize();
	self.tileBg=ccui.ImageView:create("common_red_bg.png",ccui.TextureResType.plistType);
	self.tileBg:setScale9Enabled(true);
	self.tileBg:setSize(cc.size(579, 45));
	self.tileBg:setPosition(cc.p(bgSize.width*0.5,bgSize.height-40));
	self:addChild(self.tileBg);

	local ttfConfig={};
	ttfConfig.fontFilePath=ttf_msyh;
	ttfConfig.fontSize=22;

	self.tileLabel=cc.Label:createWithTTF(ttfConfig,"", cc.VERTICAL_TEXT_ALIGNMENT_CENTER);
	self.tileLabel:setTextColor(cc.c4b(255, 255, 255,255));
	self.tileLabel:setAnchorPoint(cc.p(0.5, 0.5));
	self.tileLabel:setPosition(cc.p(bgSize.width*0.5,bgSize.height-40));
	self:addChild(self.tileLabel);

	-- self.listView=ccui.ListView:create();--ListView
	self.listView=ccui.Layout:create();
	-- self.listView:setDirection(ccui.ScrollViewDir.horizontal);
	-- self.listView:setTouchEnabled(true);
	-- self.listView:setBounceEnabled(true);
	self.listView:setSize(cc.size(500, 100));
	-- self.listView:setScrollBarVisible(false);--true添加滚动条
	-- self.listView:setItemsMargin(25);
	-- self.listView:setBackGroundColorType(1);
	-- self.listView:setBackGroundColor(Color3B.BLUE);
	self.listView:setPosition(cc.p((bgSize.width-self.listView:getSize().width)*0.5,16));
	self:addChild(self.listView);
	

	self.rewardIcon=ccui.ImageView:create("Plot_get.png",ccui.TextureResType.plistType);
	local iconSize=self.rewardIcon:getSize();
	self.rewardIcon:setPosition(cc.p(bgSize.width-iconSize.width*0.5,bgSize.height-iconSize.height*0.5));
	self:addChild(self.rewardIcon);

	NodeListener(self);

	-- self:setBackGroundColorType(1);
	-- self:setBackGroundColor(Color3B.RED);

	self.data=nil;

	-- self:setTouchEnabled(true);
	-- self:addTouchEventListener(handler(self,self.onItemClick));
end

-- function PlotRewardListItem:onItemClick(sender, eventType)
--           if eventType == ccui.TouchEventType.ended then
--                     if self.main then
--                     		print(">>>>>>>>>>>>>>>");
--                     		self.main:selectItem(self.data.c_id);
--                     		-- table.check(self.data);
--                     end
--           end
-- end

function PlotRewardListItem:showMark(value)
	self.rewardIcon:setVisible(value);
end

function PlotRewardListItem:initData(data)
	self.data=data;
	self.tileLabel:setString(string.format(MG_TEXT("plot_1"),MG_TEXT("NUM_"..data.c_id)));
	local arr=getneedlist(data.reward);
	local item;
	for k,v in pairs(arr) do
		item=resItem.create(self);
		item:setData(v.type,v.id,v.num);
		item:setNum(v.num);
		item:setAnchorPoint(cc.p(0,0));
		item:setPositionX((k-1)*(item:getSize().width+26));
		-- self.listView:pushBackCustomItem(item);
		self.listView:addChild(item);
	end
end

function PlotRewardListItem:updateTime()

end

function PlotRewardListItem:onEnter()

end

function PlotRewardListItem:onExit()

end

return PlotRewardListItem;