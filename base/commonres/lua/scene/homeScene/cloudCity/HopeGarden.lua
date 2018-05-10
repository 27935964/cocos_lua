----云中城希望花园界面----

local HopeGarden=class("HopeGarden",function()
	return cc.Layer:create();
end);

function HopeGarden:ctor(delegate,grid,set_info)
  	self.delegate=delegate;
    self.grid=grid;
    self.set_info=set_info;
    self.grid_type=0;
    -- 
  	self.pWidget=MGRCManager:widgetFromJsonFile("HopeGarden", "CloudCity_HopeGarden_Ui.ExportJson");
  	self:addChild(self.pWidget);

  	local panel_2 = self.pWidget:getChildByName("Panel_2");--Panel
    -- 标题
    self.label_title=panel_2:getChildByName("Label_21");--Label 
    -- 描述
    self.label_tips=panel_2:getChildByName("Label_Tips");
    -- 确定
  	local button_OK=panel_2:getChildByName("Button_OK");--Button
  	button_OK:addTouchEventListener(handler(self,self.sureBtnClick));

    local label_oK=button_OK:getChildByName("Label_OK");
    label_oK:setText(MG_TEXT_COCOS("HopeGarden_Ui_5"));
    -- 
    local button_close=panel_2:getChildByName("Button_close");--Button
    button_close:addTouchEventListener(handler(self,self.closeBtnClick));
    -- 自动完成
    self.checkBox_1=panel_2:getChildByName("CheckBox_1");
    self.checkBox_1:addEventListenerCheckBox(handler(self,self.selectedEvent));
    -- 兴趣点
    self.checkBox_2=panel_2:getChildByName("CheckBox_2");
    self.checkBox_2:addEventListenerCheckBox(handler(self,self.selectedEvent));
    -- 图片
    self.img_angel=panel_2:getChildByName("Image_Angel");
    -- 名称 
    self.img_name=panel_2:getChildByName("Image_23");
    -- 星级
    self.panel_24=panel_2:getChildByName("Panel_24");
    -- 
    local label_autoComplete=panel_2:getChildByName("Label_AutoComplete");
    label_autoComplete:setText(MG_TEXT_COCOS("HopeGarden_Ui_1"));

    local label_autoCTips=panel_2:getChildByName("Label_AutoComplete_Tips");
    label_autoCTips:setText(MG_TEXT_COCOS("HopeGarden_Ui_2"));

    local label_interesting=panel_2:getChildByName("Label_InterestingPoint");
    label_interesting:setText(MG_TEXT_COCOS("HopeGarden_Ui_3"));

    local label_interestingTips=panel_2:getChildByName("Label_InterestingPoint_Tips");
    label_interestingTips:setText(MG_TEXT_COCOS("HopeGarden_Ui_4"));
    -- 
   	NodeListener(self);
    -- 
    self:initData();
end

function HopeGarden:selectedEvent(sender,eventType)
    if eventType == ccui.CheckBoxEventType.selected then
        sender:setSelectedState(true);
    elseif eventType == ccui.CheckBoxEventType.unselected then
        sender:setSelectedState(false);
    end
end

function HopeGarden:initData()
    if self.delegate then
        self.delegate:showAngelInfo(nil,self.img_angel,self.img_name,self.panel_24,false);
    end
    -- 
    local sql=string.format("select * from cloud_grid where id=%d",self.grid);
    local DBData=LUADB.select(sql, "type:ui_name:des");
    self.grid_type=tonumber(DBData.info.type);
    self.label_title:setText(DBData.info.ui_name);
    self.label_tips:setText(DBData.info.des);
    -- 
    local str_list=spliteStr(self.set_info,'|');
    local set1=0;
    local set2=0;
    for i=1,#str_list do
        local str=spliteStr(str_list[i],':');
        if tonumber(str[1])==self.grid_type then
            set2=tonumber(str[2]);
            set1=tonumber(str[3]);
            break
        end
    end
    if set2==1 then
        self.checkBox_2:setSelectedState(true);
    end
    if set1==1 then
        self.checkBox_1:setSelectedState(true);
    end
end

function HopeGarden:sureBtnClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local set1=0;
        local set2=0;
        if self.checkBox_1:getSelectedState() then
            set1=1;
        end
        if self.checkBox_2:getSelectedState() then
            set2=1;
        end
        -- 格子类型:兴趣点:自动完成
        local setStr=string.format("%d:%d:%d",self.grid_type,set2,set1);
        local str=string.format("&set_info=%s",setStr);
        NetHandler:sendData(Post_Cloud_Main_cloudSet, str);
    end
end

function HopeGarden:closeBtnClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        self:closeHopeGarden();
    end
end

function HopeGarden:onReciveData(msgId, netData)
	  if msgId == Post_Cloud_Main_cloudSet then
      	if netData.state == 1 then
            local set_info=netData.cloudset.new_set;
            if self.delegate then
                self.delegate:updateSetInfo(set_info);
            end
            self:closeHopeGarden();
      	else
          	NetHandler:showFailedMessage(netData);
      	end
  	end
end

function HopeGarden:closeHopeGarden()
    if self.delegate then
        self.delegate:closeOpenLayer();
    end
end

function HopeGarden:onEnter()
    NetHandler:addAckCode(self,Post_Cloud_Main_cloudSet);
end

function HopeGarden:onExit()
	NetHandler:delAckCode(self,Post_Cloud_Main_cloudSet);
	MGRCManager:releaseResources("HopeGarden");
end

return HopeGarden;