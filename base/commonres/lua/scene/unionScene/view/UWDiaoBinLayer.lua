----公会战调兵界面----
--author:hhh time:2017.11.9
local SodierItem=require "SodierItem";

local UWDiaoBinLayer=class("UWDiaoBinLayer",function()
	return cc.Layer:create();
end);

function UWDiaoBinLayer:ctor()
	self.view=nil;

	self.pPanelTop=PanelTop.create(self)
	self.pPanelTop:setData("GuildWar_Title_diaobin.png");
	self:addChild(self.pPanelTop,2);

	self.imgBg=ccui.ImageView:create("package_bg.jpg",ccui.TextureResType.plistType);
	self.imgBg:setAnchorPoint(cc.p(0,0));
	self:addChild(self.imgBg);

	local widget=MGRCManager:widgetFromJsonFile("UWDiaoBinLayer", "GuildWar_Ui_Deploy1.ExportJson");
	self:addChild(widget);

	local panel_content=widget:getChildByName("Panel_content");--Panel
	local label_choose=panel_content:getChildByName("Label_Choose");--Label
	label_choose:setText(MG_TEXT_COCOS("GuildWar_Ui_Deploy1_1"));
	self.label_choose_number=panel_content:getChildByName("Label_Choose_number");--Label

	local label_surplus=panel_content:getChildByName("Label_Surplus");--Label
	label_surplus:setText(MG_TEXT_COCOS("GuildWar_Ui_Deploy1_2"));
	self.label_surplus_number=panel_content:getChildByName("Label_Surplus_number");--Label

	self.panelBox=panel_content:getChildByName("Panel_box");--Panel

	self.button_left=panel_content:getChildByName("Button_Left");--Button
	self.button_left:addTouchEventListener(handler(self,self.onButton_LeftClick));

	self.button_right=panel_content:getChildByName("Button_Right");--Button
	self.button_right:addTouchEventListener(handler(self,self.onButton_RightClick));

	local label_tips=panel_content:getChildByName("Label_Tips");--Label
	label_tips:setText(MG_TEXT_COCOS("GuildWar_Ui_Deploy1_3"));

	local button_onekeysend=panel_content:getChildByName("Button_OnekeySend");--Button
	button_onekeysend:addTouchEventListener(handler(self,self.onButton_OnekeySendClick));
	local label_onekeysend=button_onekeysend:getChildByName("Label_OnekeySend");--Label
	label_onekeysend:setText(MG_TEXT_COCOS("GuildWar_Ui_Deploy1_4"));

	local button_sendarmy=panel_content:getChildByName("Button_SendArmy");--Button
	button_sendarmy:addTouchEventListener(handler(self,self.onButton_SendArmyClick));
	local label_sendarmy=button_sendarmy:getChildByName("Label_SendArmy");--Label
	label_sendarmy:setText(MG_TEXT_COCOS("GuildWar_Ui_Deploy1_5"));

	local button_help=panel_content:getChildByName("Button_help");--Button
	button_help:addTouchEventListener(handler(self,self.onButton_helpClick));

	self.tipLabel=panel_content:getChildByName("Label_35");
	self.tipLabel:setText(MG_TEXT_COCOS("GuildWar_Ui_Deploy3_5"));

	self.curPage=1;
	self.totalPage=0;
	self.pageCount=8;
	self.totalCount=0;
	self.selectNum=0;
	self.corps_list=nil;
	self.teamInfoLayer=nil;
	self.items={};
end

function UWDiaoBinLayer:initPages(total)
	self.totalCount=total;
	self.curPage=1;
	self.totalPage=math.floor(self.totalCount/self.pageCount)+1;
end

function UWDiaoBinLayer:getIndex()
	local sIndex=(self.curPage-1)*self.pageCount+1
	local eIndex=sIndex+self.pageCount-1;
	if eIndex>self.totalCount then
		eIndex=self.totalCount;
	end
	return sIndex,eIndex;
end

function UWDiaoBinLayer:nextPage()
	self.curPage=self.curPage+1;
	if self.curPage>self.totalPage then
		self.curPage=self.totalPage;
	end
end

function UWDiaoBinLayer:prePage()
	self.curPage=self.curPage-1;
	if self.curPage<1 then
		self.curPage=1;
	end
end

function UWDiaoBinLayer:initData(initProxy)
	self:updataData(initProxy);
end

function UWDiaoBinLayer:updataData(initProxy)
	local troopsData=initProxy.troopsData;
	self.corps_list=troopsData.corps;
	self:initPages(#self.corps_list);
	self:showItems();
	self.selectNum=0;
	self:upSelectNum();
	if self.totalCount==0 then
		self.tipLabel:setVisible(true);
	else 
		self.tipLabel:setVisible(false);
	end
end

function UWDiaoBinLayer:showItems()
	self.panelBox:removeAllChildren();
	local s,e=self:getIndex();
	local row,col,data,index;
	self.items={};
	for i=s,e do
		data=self.corps_list[i];
		if data then
			index=(i-1)%8;
			row=math.floor(index/4);
			col=index%4;
			local item=SodierItem.new(self);
			item:setPosition(cc.p(125+col*250,300-row*200));
			item:setData(data.leadId,data.lowLv,data.name,data.select);
			item:setSoiderData(data);
			item:setQuality(data.leadQuality);
			item:setTouch(true);
			item:setNameTouch(true);
			self.panelBox:addChild(item);
			table.insert(self.items,item);
		end
	end

	if self.curPage==1 then
		self.button_left:setEnabled(false);
	else
		self.button_left:setEnabled(true);
	end

	if self.curPage==self.totalPage then
		self.button_right:setEnabled(false);
	else
		self.button_right:setEnabled(true);
	end
end

function UWDiaoBinLayer:upSelectNum()
	self.label_choose_number:setText(tostring(self.selectNum));
	self.label_surplus_number:setText(tostring(self.totalCount-self.selectNum));
end

function UWDiaoBinLayer:onButton_LeftClick(sender, eventType)
	buttonClickScale(sender,eventType,1);
	if eventType == ccui.TouchEventType.ended then
		--MGSound:getInstance():play(SOUND_COM_CLICK);
		self:prePage();
		self:showItems();
	end
end

function UWDiaoBinLayer:itemSelect(item)
	local leadId=item.heroId;
	if leadId then
		for k,v in pairs(self.corps_list) do
			if v.leadId==leadId then
				v.select=true;
				self.selectNum=self.selectNum+1;
				break;
			end
		end
	end
	self:upSelectNum();
end

function UWDiaoBinLayer:itemUnSelect(item)
	local leadId=item.heroId;
	if leadId then
		for k,v in pairs(self.corps_list) do
			if v.leadId==leadId then
				v.select=false;
				self.selectNum=self.selectNum-1;
				break;
			end
		end
	end
	self:upSelectNum();
end

function UWDiaoBinLayer:selectItem(soiderData)
	for k,v in pairs(self.items) do
		if soiderData.id==v.soiderData.id then
			v:onItemClick(nil,ccui.TouchEventType.ended);
			break;
		end
	end
	self:openTeamInfo(false);
end

function UWDiaoBinLayer:itemNameClick(item)
	self:openTeamInfo(true,item);
end

function UWDiaoBinLayer:openTeamInfo(value,item)
	if value then
		local UWDispatchLayer=require "UWDispatchLayer";
		if self.teamInfoLayer==nil then
			self.teamInfoLayer=UWDispatchLayer.new(self);
			local runScene=cc.Director:getInstance():getRunningScene();
			runScene:addChild(self.teamInfoLayer,ZORDER_MAX);
		end
		self.teamInfoLayer:initData(item.soiderData);
	else
		if self.teamInfoLayer then
			self.teamInfoLayer:removeFromParent();
			self.teamInfoLayer=nil;
		end
	end
end

function UWDiaoBinLayer:onButton_RightClick(sender, eventType)
	buttonClickScale(sender,eventType,1);
	if eventType == ccui.TouchEventType.ended then
		--MGSound:getInstance():play(SOUND_COM_CLICK);
		self:nextPage();
		self:showItems();
	end
end

function UWDiaoBinLayer:onButton_OnekeySendClick(sender, eventType)
	buttonClickScale(sender,eventType,1);
	if eventType == ccui.TouchEventType.ended then
		--MGSound:getInstance():play(SOUND_COM_CLICK);
		if self.totalCount==0 then
			MGMessageTip:showFailedMessage(MG_TEXT("unionWar_16"));
		else
			local data=self:getOnKeyHeros();
			self.view:postNotificationName(UWNN.UWDiaoBingCmd,{action=3,data=data});
		end
	end
end

function UWDiaoBinLayer:onButton_SendArmyClick(sender, eventType)
	buttonClickScale(sender,eventType,1);
	if eventType == ccui.TouchEventType.ended then
		--MGSound:getInstance():play(SOUND_COM_CLICK);
		if self.totalCount==0 then
			MGMessageTip:showFailedMessage(MG_TEXT("unionWar_16"));
		elseif self.selectNum==0 then
			MGMessageTip:showFailedMessage(MG_TEXT("unionWar_17"));
		else
			local data=self:getSelectHeros();
			self.view:postNotificationName(UWNN.UWDiaoBingCmd,{action=3,data=data});
		end
	end
end

function UWDiaoBinLayer:getSelectHeros()
	local arr={};
	for k,v in pairs(self.corps_list) do
		if v.select==true then
			table.insert(arr,v.id);
		end
	end
	return arr;
end

function UWDiaoBinLayer:getOnKeyHeros()
	local otherArr={};
	local selectArr={};
	for k,v in pairs(self.corps_list) do
		if v.select==true then
			table.insert(selectArr,v.id);
		else
			table.insert(otherArr,v);
		end
	end

	local arr={};
	if #selectArr>=10 then
		for i=1,10 do
			table.insert(arr,selectArr[i].id);
		end
	elseif #otherArr>0 then
		table.sort(otherArr,function(a,b)
			return a.score<b.score;
		end);

		local num=10-(#selectArr);
		if num>#otherArr then
			num=#otherArr;
		end
		local data;
		for i=1,num do
			data=otherArr[i];
			if data==nil then
				break;
			end
			table.insert(arr,data.id);
		end
	end
	return arr;
end

function UWDiaoBinLayer:onButton_helpClick(sender, eventType)
	buttonClickScale(sender,eventType,1);
	if eventType == ccui.TouchEventType.ended then
		--MGSound:getInstance():play(SOUND_COM_CLICK);
	end
end

function UWDiaoBinLayer:back()
	self.view:postNotificationName(UWNN.UWDiaoBingCmd,{action=2});
end

function UWDiaoBinLayer:onEnter()
	
end

function UWDiaoBinLayer:onExit()
	MGRCManager:releaseResources("UWDiaoBinLayer");
end

function UWDiaoBinLayer:setView(view)
	self.view=view;
end

return UWDiaoBinLayer;