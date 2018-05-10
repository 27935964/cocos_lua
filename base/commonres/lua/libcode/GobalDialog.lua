
GobalDialog=class("GobalDialog");
GobalDialog.__index=GobalDialog;

function GobalDialog:ctor()
	self.box=nil;
end

function GobalDialog:initBox()
	if self.box==nil then
		local scene=cc.Director:getInstance():getRunningScene();
		self.box=cc.Layer:create();
		scene:addChild(self.box,ZORDER_MAX);
	end
	return self.box;
end

function GobalDialog:showComfirm(msg,confirmFun,cancleFun)

	if self.box~=nil then
		return;
	end

	self.confirmFun=confirmFun;
	self.cancleFun=cancleFun;
	self:initBox();
	local winSize=cc.Director:getInstance():getWinSize();
	self.widget=MGRCManager:widgetFromJsonFile("GobalDialog", "Gobal_Dilgo_Ui.ExportJson");
	self.widget:setAnchorPoint(cc.p(0.5,0));
	self.widget:setPosition(cc.p(winSize.width/2,0));
	self.box:addChild(self.widget);

	local panelContent=self.widget:getChildByName("Panel_content");
	local frameBg=panelContent:getChildByName("Image_Frame");

	local msgLabel= MGColorLabel:label();
    	msgLabel:setAnchorPoint(cc.p(0.5,0.5));
    	msgLabel:setPosition(frameBg:getContentSize().width/2, frameBg:getContentSize().height/2);
	msgLabel:appendStringAutoWrap(msg,18,1,Color3B.WHITE,22);
	frameBg:addChild(msgLabel);
	

	self.confirm=panelContent:getChildByName("confirmBtn");
	self.cancleBtn=panelContent:getChildByName("cancleBtn");

	self.confirm:addTouchEventListener(handler(self,self.onConfirmClick));
	self.cancleBtn:addTouchEventListener(handler(self,self.onCancleClick));
end

function GobalDialog:showAlert(msg,confirmFun,color)
	if self.box~=nil then
		return;
	end

	color=color or Color3B.WHITE;
	self.confirmFun=confirmFun;
	self:initBox();
	local winSize=cc.Director:getInstance():getWinSize();
	self.widget=MGRCManager:widgetFromJsonFile("GobalDialog", "Gobal_Dilgo_Ui.ExportJson");
	self.widget:setAnchorPoint(cc.p(0.5,0));
	self.widget:setPosition(cc.p(winSize.width/2,0));
	self.box:addChild(self.widget);

	local panelContent=self.widget:getChildByName("Panel_content");
	local frameBg=panelContent:getChildByName("Image_Frame");

	local msgLabel= MGColorLabel:label();
    	msgLabel:setAnchorPoint(cc.p(0.5,0.5));
    	msgLabel:setPosition(frameBg:getContentSize().width/2, frameBg:getContentSize().height/2);
	msgLabel:appendStringAutoWrap(msg,18,1,color,22);
	frameBg:addChild(msgLabel);
	

	self.confirm=panelContent:getChildByName("confirmBtn");
	self.confirm:setPositionX(frameBg:getPositionX());

	self.cancleBtn=panelContent:getChildByName("cancleBtn");
	self.cancleBtn:setEnabled(false);

	self.confirm:addTouchEventListener(handler(self,self.onConfirmClick));

end

function GobalDialog:onConfirmClick(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		if self.confirmFun~=nil then
			self.confirmFun();
		end
		self.box:removeFromParent();
		self.box=nil;
	end
end

function GobalDialog:onCancleClick(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		if self.cancleFun~=nil then
			self.cancleFun();
		end
		self.box:removeFromParent();
		self.box=nil;
	end
end

function GobalDialog:clear()
	MGRCManager:releaseResources("GobalDialog");
end

local instance;
function GobalDialog:getInstance()
	if instance==nil then
		instance=GobalDialog.new();
	end

	return instance;
end

function GobalDialog:dispose()
	if instance~=nil then
		instance:clear();
		instance=nil;
	end
end