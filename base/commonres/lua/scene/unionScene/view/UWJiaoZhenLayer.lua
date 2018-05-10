----公会战叫阵界面----
--author:hhh time:2017.11.9
local SodierItem=require "SodierItem";

local UWJiaoZhenLayer=class("UWJiaoZhenLayer",function()
	return cc.Layer:create();
end);

function UWJiaoZhenLayer:ctor()
	self.view=nil;

	self.pPanelTop=PanelTop.create(self)
	self.pPanelTop:setData("GuildWar_Title_jiaozhen.png");
	self:addChild(self.pPanelTop,2);

	self.imgBg=ccui.ImageView:create("package_bg.jpg",ccui.TextureResType.plistType);
	self.imgBg:setAnchorPoint(cc.p(0,0));
	self:addChild(self.imgBg);

	local widget=MGRCManager:widgetFromJsonFile("UWJiaoZhenLayer", "GuildWar_Ui_Deploy3.ExportJson");
	self:addChild(widget);

	local panel_content=widget:getChildByName("Panel_content");--Panel
	local label_choose=panel_content:getChildByName("Label_Choose");--Label
	label_choose:setText(MG_TEXT_COCOS("GuildWar_Ui_Deploy3_1"));
	self.choose_number=panel_content:getChildByName("Label_Choose_number");--Label


	local label_surplus=panel_content:getChildByName("Label_Surplus");--Label
	label_surplus:setText(MG_TEXT_COCOS("GuildWar_Ui_Deploy3_2"));
	self.surplus_number=panel_content:getChildByName("Label_Surplus_number");--Label


	self.panelBox=panel_content:getChildByName("Panel_box");--Panel
	self.button_left=panel_content:getChildByName("Button_Left");--Button
	self.button_left:addTouchEventListener(handler(self,self.onButton_LeftClick));

	self.button_right=panel_content:getChildByName("Button_Right");--Button
	self.button_right:addTouchEventListener(handler(self,self.onButton_RightClick));

	self.label_tips=panel_content:getChildByName("Label_Tips");--Label
	self.label_tips:setText(MG_TEXT_COCOS("GuildWar_Ui_Deploy3_3"));
	local button_dispatch=panel_content:getChildByName("Button_Dispatch");--Button
	button_dispatch:addTouchEventListener(handler(self,self.onButton_DispatchClick));
	local label_dispatch=button_dispatch:getChildByName("Label_Dispatch");--Label
	label_dispatch:setText(MG_TEXT_COCOS("GuildWar_Ui_Deploy3_4"));

	self.image_dispatchorder=panel_content:getChildByName("Image_DispatchOrder");--ImageView
	self.dispatchorder=panel_content:getChildByName("Label_DispatchOrder");--Label

	local button_help=panel_content:getChildByName("Button_help");--Button
	button_help:addTouchEventListener(handler(self,self.onButton_helpClick));

	self.tipLabel=panel_content:getChildByName("Label_35");
	self.tipLabel:setText(MG_TEXT_COCOS("GuildWar_Ui_Deploy3_5"));

	self.curPage=1;
	self.totalPage=0;
	self.pageCount=8;
	self.totalCount=0;
	self.corps_list=nil;
	self.selectNum=0;
	self.orderMax=0;--玩家拥有的出征令
	self.itemCost=nil;
end

function UWJiaoZhenLayer:initPages(total)
	self.totalCount=total;
	self.curPage=1;
	self.totalPage=math.floor(self.totalCount/self.pageCount)+1;
end

function UWJiaoZhenLayer:getIndex()
	local sIndex=(self.curPage-1)*self.pageCount+1
	local eIndex=sIndex+self.pageCount-1;
	if eIndex>self.totalCount then
		eIndex=self.totalCount;
	end
	return sIndex,eIndex;
end

function UWJiaoZhenLayer:nextPage()
	self.curPage=self.curPage+1;
	if self.curPage>self.totalPage then
		self.curPage=self.totalPage;
	end
end

function UWJiaoZhenLayer:prePage()
	self.curPage=self.curPage-1;
	if self.curPage<1 then
		self.curPage=1;
	end
end

function UWJiaoZhenLayer:initData(initProxy)
	local cost=LUADB.readConfig(177);
	self.itemCost=getneedlist(cost)[1] or {id=1,type=1,num=10};
	self.label_tips:setText(string.format(MG_TEXT_COCOS("GuildWar_Ui_Deploy3_3"),self.itemCost.num));
	local resData=ResourceTip.getInstance():getResData(cost);

	MGRCManager:cacheResource("UWJiaoZhenLayer",resData.icon);
	self.image_dispatchorder:loadTexture(resData.icon,ccui.TextureResType.plistType);
	self.image_dispatchorder:setScale(0.5);
	self:updata(initProxy);
end

function UWJiaoZhenLayer:updata(initProxy)
	self.selectNum=0;
	self.corps_list=initProxy.getcamplist.corps_list;
	local rm=RESOURCE:getResModelByItemId(self.itemCost.id);
	if rm then
		self.orderMax=rm:getNum();
	end
	self:initPages(#self.corps_list);
	self:showItems();
	self:upSelectNum();
	if self.totalCount==0 then
		self.tipLabel:setVisible(true);
	else 
		self.tipLabel:setVisible(false);
	end
end

function UWJiaoZhenLayer:upSelectNum()
	self.choose_number:setText(tostring(self.selectNum));
	self.surplus_number:setText(tostring(self.totalCount-self.selectNum));

	local cost=self.selectNum*self.itemCost.num;
	self.dispatchorder:setText(string.format("%d/%d",cost,self.orderMax));
	if self.orderMax==0 or cost>self.orderMax then
		self.dispatchorder:setColor(cc.c3b(255,0,0));
	else
		self.dispatchorder:setColor(cc.c3b(255,255,255));
	end
end

function UWJiaoZhenLayer:showItems()
	self.panelBox:removeAllChildren();
	local s,e=self:getIndex();
	local row,col,data,index;
	for i=s,e do
		data=self.corps_list[i];
		if data then
			index=(i-1)%8;
			row=math.floor(index/4);
			col=index%4;
			local item=SodierItem.new(self);
			item:setPosition(cc.p(125+col*250,300-row*200));
			item:setData(data.leadId,data.lv,data.name,data.select);
			item:setTouch(true);
			self.panelBox:addChild(item);
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

function UWJiaoZhenLayer:itemSelect(item)
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

function UWJiaoZhenLayer:itemUnSelect(item)
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

function UWJiaoZhenLayer:onButton_LeftClick(sender, eventType)
	buttonClickScale(sender,eventType,1);
	if eventType == ccui.TouchEventType.ended then
		--MGSound:getInstance():play(SOUND_COM_CLICK);
		self:prePage();
		self:showItems();
	end
end

function UWJiaoZhenLayer:onButton_RightClick(sender, eventType)
	buttonClickScale(sender,eventType,1);
	if eventType == ccui.TouchEventType.ended then
		--MGSound:getInstance():play(SOUND_COM_CLICK);
		self:nextPage();
		self:showItems();
	end
end

function UWJiaoZhenLayer:onButton_DispatchClick(sender, eventType)
	buttonClickScale(sender,eventType,1);
	if eventType == ccui.TouchEventType.ended then
		--MGSound:getInstance():play(SOUND_COM_CLICK);
		local cost=self.selectNum*self.itemCost.num;
		if self.orderMax==0 or cost>self.orderMax then
			MGMessageTip:showFailedMessage(MG_TEXT("unionWar_7"));
			return;
		end

		local idArr={};
		for k,v in pairs(self.corps_list) do
			if v.select then
				table.insert(idArr,v.id)
			end
		end

		if #idArr<1 then
			MGMessageTip:showFailedMessage(MG_TEXT("unionWar_6"));
		else 
			self.view:postNotificationName(UWNN.UWJiaoZhenCmd,{action=3,idArr=idArr});
		end
	end
end

function UWJiaoZhenLayer:onButton_helpClick(sender, eventType)
	buttonClickScale(sender,eventType,1);
	if eventType == ccui.TouchEventType.ended then
		--MGSound:getInstance():play(SOUND_COM_CLICK);
		print("UWJiaoZhenLayer:onButton_helpClick");
	end
end

function UWJiaoZhenLayer:back()
	self.view:postNotificationName(UWNN.UWJiaoZhenCmd,{action=2});
end

function UWJiaoZhenLayer:onEnter()
	
end

function UWJiaoZhenLayer:onExit()
	MGRCManager:releaseResources("UWJiaoZhenLayer");
end

function UWJiaoZhenLayer:setView(view)
	self.view=view;
end

return UWJiaoZhenLayer;