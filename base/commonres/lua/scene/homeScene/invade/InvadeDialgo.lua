local InvadeDialgo=class("InvadeDialgo",function()
	return cc.Layer:create();
end);

function InvadeDialgo:ctor(main)
	self.main=main;
	local widget=MGRCManager:widgetFromJsonFile("InvadeDialgo", "InvadeUi_2.ExportJson");
	self:addChild(widget);

	local panel_mask=widget:getChildByName("Panel_mask");--Panel
	local panel_content=widget:getChildByName("Panel_content");--Panel
	
	local panel_3=panel_content:getChildByName("Panel_3");--Panel
	local label_tip1=panel_3:getChildByName("Label_Tip1");--Label
	label_tip1:setText(MG_TEXT_COCOS("InvadeUi_2_1"));
	local label_tip2=panel_3:getChildByName("Label_Tip2");--Label
	label_tip2:setText(MG_TEXT_COCOS("InvadeUi_2_2"));

	self.consume=panel_3:getChildByName("Label_Consume");--Label

	local button_cancel=panel_content:getChildByName("Button_Cancel");--Button
	button_cancel:addTouchEventListener(handler(self,self.onButton_CancelClick));
	local label_cancel=button_cancel:getChildByName("Label_Cancel");--Label
	label_cancel:setText(MG_TEXT_COCOS("InvadeUi_2_3"));

	local button_ok=panel_content:getChildByName("Button_Ok");--Button
	button_ok:addTouchEventListener(handler(self,self.onButton_OkClick));
	local label_ok=button_ok:getChildByName("Label_Ok");--Label
	label_ok:setText(MG_TEXT_COCOS("InvadeUi_2_4"));

	NodeListener(self);
end

function InvadeDialgo:onButton_CancelClick(sender, eventType)
	buttonClickScale(sender, eventType);
	if eventType == ccui.TouchEventType.ended then
		--MGSound:getInstance():play(SOUND_COM_CLICK);
		if self.main and self.main.openInvadeDialgo then
			self.main:openInvadeDialgo(false);
		end
	end
end

function InvadeDialgo:onButton_OkClick(sender, eventType)
	buttonClickScale(sender, eventType);
	if eventType == ccui.TouchEventType.ended then
		--MGSound:getInstance():play(SOUND_COM_CLICK);
		if self.main then
			if self.main.doChange then
				self.main:doChange();
			end

			if self.main.openInvadeDialgo then
				self.main:openInvadeDialgo(false);
			end
		end
	end
end

function InvadeDialgo:initData(reflashCost)
	self.consume:setText(tostring(reflashCost));
end

function InvadeDialgo:onEnter()
	
end

function InvadeDialgo:onExit()
	MGRCManager:releaseResources("InvadeDialgo");
end

return InvadeDialgo;