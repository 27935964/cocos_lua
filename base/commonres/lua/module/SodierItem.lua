local SodierItem=class("SodierItem",function ()
	return ccui.Layout:create();
end);

function SodierItem:ctor(main)
	self.main=main;
	self.imgBg=ccui.ImageView:create("com_sodier_item_bg.png",ccui.TextureResType.plistType);
	self.imgBg:setAnchorPoint(0.5,0.3);
	self:addChild(self.imgBg);

	self.selectImg=ccui.ImageView:create("com_sodier_item_select.png",ccui.TextureResType.plistType);
	self.selectImg:setAnchorPoint(0.5,0.3);
	self:addChild(self.selectImg);

	self.lvBg=ccui.ImageView:create("com_vip_bg.png",ccui.TextureResType.plistType);
	self.lvBg:setPosition(cc.p(-70,110));
	self:addChild(self.lvBg,1);

	local ttfConfig={};
	ttfConfig.fontFilePath=ttf_msyh;
	ttfConfig.fontSize=20;
	self.lvLabel=cc.Label:createWithTTF(ttfConfig,"99", cc.VERTICAL_TEXT_ALIGNMENT_CENTER);
	self.lvLabel:setTextColor(cc.c4b(255, 255, 255,255));
	self.lvLabel:setAnchorPoint(cc.p(0.5, 0.5));
	self.lvLabel:setPosition(cc.p(-70,110));
	self:addChild(self.lvLabel,1);

	ttfConfig.fontSize=22;
	self.nameLabel=cc.Label:createWithTTF(ttfConfig,"99", cc.VERTICAL_TEXT_ALIGNMENT_CENTER);
	self.nameLabel:setTextColor(cc.c4b(255, 255, 255,255));
	self.nameLabel:setAnchorPoint(cc.p(0, 0.5));
	self.nameLabel:setPosition(cc.p(-52,110));
	self.nameLabel:enableShadow(cc.c4b( 0,   0,   0, 191), cc.size(2, -2));
	self:addChild(self.nameLabel,1);

	self:setSize(cc.size(40,40));
	NodeListener(self);

	self.skinSprite=cc.Sprite:create();
	self:addChild(self.skinSprite);
	self.skin=nil;
	self.heroId=0;
	self.select=false;
	self:setSelect(false);
	self.soiderData=nil;
end

--clickType=1表示点击后回调没选中效果，其他情况有选中效果
function SodierItem:setTouch(value,clickType)
	self.imgBg:setTouchEnabled(value);
	if clickType == 1 then
		self.imgBg:addTouchEventListener(handler(self,self.onButtonClick));
	else
		self.imgBg:addTouchEventListener(handler(self,self.onItemClick));
	end
end

function SodierItem:setNameTouch(value)
	if value then
		local clickRect=ccui.Layout:create();
		clickRect:setSize(cc.size(180,30));
		clickRect:setPosition(-85,95);
		self:addChild(clickRect);
		-- clickRect:setBackGroundColorType(1);
		-- clickRect:setBackGroundColor(Color3B.BLUE);
		clickRect:setTouchEnabled(true);
		clickRect:addTouchEventListener(handler(self,self.onNameClick));
	end
end

function SodierItem:setName(name)--数据库读取的名字不需要转码
	self.nameLabel:setString(name);
end

function SodierItem:setSkinReverse()--兵要转向
	self.skinSprite:setScaleX(-1);
end

function SodierItem:setSoiderData(data)
	self.soiderData=data;
end

function SodierItem:setSelect(value)
	self.select=value;
	self.selectImg:setVisible(value);
end

function SodierItem:onItemClick(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		--MGSound:getInstance():play(SOUND_COM_CLICK);
		if self.select then
			self.select=false;
			self.selectImg:setVisible(self.select);
			if self.main and self.main.itemUnSelect then
				self.main:itemUnSelect(self);
			end
		else
			self.select=true;
			self.selectImg:setVisible(self.select);
			if self.main and self.main.itemSelect then
				self.main:itemSelect(self);
			end
		end
	end
end

function SodierItem:onButtonClick(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		--MGSound:getInstance():play(SOUND_COM_CLICK);
		if self.main and self.main.onSelect then
			self.main:onSelect(self);
		end
	end
end

function SodierItem:onNameClick(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		--MGSound:getInstance():play(SOUND_COM_CLICK);
		if self.main and self.main.itemNameClick then
			self.main:itemNameClick(self);
		end
	end
end

function SodierItem:setData(id,lv,name,select)
	self.heroId=id;
	select=select or false;
	self:setSelect(select);
	self.lvLabel:setString(tostring(lv));
	self.nameLabel:setString(unicode_to_utf8(name));
	local model=self:getMode(id);
	if model and self.skin then
		local imgName=string.format("sodier_%s.png",model);
		local plistName=string.format("sodier_%s.plist",model);
		MGRCManager:cacheResource("SodierItem",imgName,plistName);

		local actionName=self.skin.skinPre.."_stand_";
		self.skinSprite:setSpriteFrame(actionName.."0.png");
		self.skinSprite:setAnchorPoint(self.skin.anchor);
		local action=cc.RepeatForever:create(fuGetAnimate(actionName,0,self.skin.stand,self.skin.speed));
		self.skinSprite:runAction(action);
	else
		print("SodierItem:setData:model is nil");
	end
end

function SodierItem:setQuality(quality)
	self.nameLabel:setColor(QualityDB:getColor3B(quality));
end

function SodierItem:getMode(id)
	local gm=GENERAL:getAllGeneralModel(id);
	if gm then
		local sodierId=gm:soldierid();
		local skinIds=require "soiderConfig";
		self.skin=skinIds[sodierId];
		local sql=string.format("select model from soldier_list where id=%d",sodierId);
       		local DBData=LUADB.select(sql, "model");
       		if DBData then
       			return DBData.info.model;
       		end
	end
	return nil;
end

function SodierItem:onEnter()
	
end

function SodierItem:onExit()
	MGRCManager:releaseResources("SodierItem");
end

return SodierItem;