----主界面公会战列表项----
--author:hhh time:2017.11.6

local UWListItem=class("UWListItem",function()
	return ccui.Layout:create();
end);

function UWListItem:ctor(main)
	self.main=main;
	self:setSize(cc.size(316,65));
	self.bg=cc.Sprite:createWithSpriteFrameName("GuildWar_ListItemBg.png");
	self.bg:setAnchorPoint(cc.p(0,0));
	self:addChild(self.bg);

	self.flagImg=ccui.ImageView:create("GuildWar_FightIcon.png",ccui.TextureResType.plistType);
	self.flagImg:setPosition(cc.p(28,35));
	self:addChild(self.flagImg);

	local ttfConfig={};
	ttfConfig.fontFilePath=ttf_msyh;
	ttfConfig.fontSize=22;

	self.tileLabel=cc.Label:createWithTTF(ttfConfig,MG_TEXT("plotMenu1"), cc.VERTICAL_TEXT_ALIGNMENT_CENTER);
	self.tileLabel:setTextColor(cc.c4b(255, 216, 0,255));
	self.tileLabel:setAnchorPoint(cc.p(0, 0.5));
	self.tileLabel:setPosition(cc.p(62,45));
	self:addChild(self.tileLabel);
	
	self.nameLabel=cc.Label:createWithTTF(ttfConfig,"玩家名字", cc.VERTICAL_TEXT_ALIGNMENT_CENTER);
	self.nameLabel:setTextColor(cc.c4b(255, 255, 255,255));
	self.nameLabel:setAnchorPoint(cc.p(0, 0.5));
	self.nameLabel:setPosition(cc.p(62,20));
	self:addChild(self.nameLabel);

	self.timeLabel=cc.Label:createWithTTF(ttfConfig,"10:22:34", cc.VERTICAL_TEXT_ALIGNMENT_CENTER);
	self.timeLabel:setTextColor(cc.c4b(64, 246, 0,255));
	self.timeLabel:setAnchorPoint(cc.p(1, 0.5));
	self.timeLabel:setPosition(cc.p(305,20));
	self:addChild(self.timeLabel);

	self:setTouchEnabled(true);
	self:addTouchEventListener(handler(self,self.onItemClick));

	-- self:setBackGroundColorType(1);
	-- self:setBackGroundColor(Color3B.RED);

	self.data=nil;
end

function UWListItem:onItemClick(sender, eventType)
          if eventType == ccui.TouchEventType.ended then
                    	enterUnionWar(self.data.city_id,handler(self,self.onRemove));
          end
end

function UWListItem:onRemove()
	if self.main and self.main.removeItem then
		self.main:removeItem(self.index);
	end
end

function UWListItem:setIndex(index)
	self.index=index;
end

function UWListItem:initData(index,data,status,timeStr)
	self.data=data;
	self.index=index;
	self.status=status;
	self:setTime(timeStr);
	local sql=string.format("select name from stage_list where id=%d",data.city_id);
	local dbData=LUADB.select(sql, "name");
	self.nameLabel:setString(dbData.info.name);

	local format="";
	if data.type==1 then --1进攻方 2防守方 3助战 4协防 5玩家为第三方
		if self.status==0 then--备战
			format=MG_TEXT("unionWar_30");
		else
			format=MG_TEXT("unionWar_31");
		end
	elseif data.type==2 then
		format=MG_TEXT("unionWar_32");
		self.flagImg:loadTexture("GuildWar_DefendIcon.png",ccui.TextureResType.plistType);
	elseif data.type==3 then
		format=MG_TEXT("unionWar_34");
	elseif data.type==4 then
		format=MG_TEXT("unionWar_33");
		self.flagImg:loadTexture("GuildWar_DefendIcon.png",ccui.TextureResType.plistType);
	elseif data.type==5 then
		if self.status==0 then--备战
			format=MG_TEXT("unionWar_35");
		else
			format=MG_TEXT("unionWar_36");
		end
	end

	self.tileLabel:setString(string.format(format,unicode_to_utf8(data.union_name)));
end

function UWListItem:setTime(timeStr)
	self.timeLabel:setString(timeStr);
end

function UWListItem:removeMe()
	if self.main and self.main.reopenPlotList then
		self.main:reopenPlotList()
	end
end

return UWListItem;