----云中城祈祷点界面----
-- require "FloatUpMessage";
-- local CCHeroListItem=require "CCHeroListItem";
local PrayerPoint=class("PrayerPoint",function()
	return cc.Layer:create();
end);

function PrayerPoint:ctor(delegate)
  	self.delegate=delegate;
    self.diceContent=delegate.diceContent;
    self.tabView=nil;
    self.chooseMax=3;
    self.heroTab={};

  	self.pWidget=MGRCManager:widgetFromJsonFile("PrayerPoint", "CloudCity_PrayerPoint_Ui.ExportJson");
  	self:addChild(self.pWidget);

  	local panel_2=self.pWidget:getChildByName("Panel_2");--Panel
    self.panel_3=self.pWidget:getChildByName("Panel_3");
    self:setNoCanClick(false);
    -- 总星级
    self.label_starNum=panel_2:getChildByName("Label_StarNumber");--Label 
    -- 还需选择的英雄数
    self.label_chNum=panel_2:getChildByName("Label_ChooseNumber");
    -- 
    self.panel_16=panel_2:getChildByName("Panel_16");
    -- tips
    self.img_bubble=panel_2:getChildByName("Image_Bubble");
    -- 图片
    self.img_angel=panel_2:getChildByName("Image_Angel");
    -- 名称 
    self.img_name=panel_2:getChildByName("Image_23");
    -- 星级
    self.panel_24=panel_2:getChildByName("Panel_24");
    -- 
    local label_tips=panel_2:getChildByName("Label_Tips");
    label_tips:setText(MG_TEXT_COCOS("PrayerPoint_Ui_1"));

    local label_totalStar=panel_2:getChildByName("Label_AngelTotalStar");
    label_totalStar:setText(MG_TEXT_COCOS("PrayerPoint_Ui_2"));
    -- 
  	self.button_pray=panel_2:getChildByName("Button_Pray");--Button
  	self.button_pray:addTouchEventListener(handler(self,self.prayerBtnClick));
    self.program=self.button_pray:getVirtualRenderer():getShaderProgram();
    MGGraySprite:graySprite(self.button_pray:getVirtualRenderer());
    self.button_pray:setTouchEnabled(false);
    local label_34=self.button_pray:getChildByName("Label_34");
    label_34:setText(MG_TEXT_COCOS("PrayerPoint_Ui_4"));
    -- 
   	NodeListener(self);
    -- 
    self:initData();
    --
    -- 
    -- local Panel_1 = self.pWidget:getChildByName("Panel_1")
    -- local function closeClick(sender,eventType)
    --     if eventType == ccui.TouchEventType.ended then
    --         self:removeFromParentAndCleanup(true);
    --     end
    -- end
    -- Panel_1:addTouchEventListener(closeClick)
end

function PrayerPoint:setNoCanClick(isVisible)
    self.panel_3:setTouchEnabled(isVisible);
end

function PrayerPoint:initData()
    -- 祈祷点可选英雄数量
    self.chooseMax=LUADB.readConfig(162);
    self.chooseMax=tonumber(self.chooseMax);
    local totalStar=tonumber(self.diceContent);
    self.label_starNum:setText(string.format("%d",totalStar));
    self.label_chNum:setText(string.format(MG_TEXT("PrayerPoint_1"),self.chooseMax));
    -- 
    local temList=GENERAL:getGeneralList();
    self.viewDatas=self:parseTableViewData(temList);
    self.cell_num=table.getn(self.viewDatas);
    self:createTableView();
    -- 
    if self.delegate then
        self.delegate:showAngelInfo(self.img_bubble,self.img_angel,self.img_name,self.panel_24,false);
    end
end

function PrayerPoint:parseTableViewData(datas)
    local index=0;
    local remainNum=#datas;
    local tempDatas={};
    for i=1,remainNum do
        index=math.floor((i-1)/5)+1;
        if tempDatas[index]==nil then
            tempDatas[index]={};
        end
        table.insert(tempDatas[index],datas[i]);
    end
    return tempDatas;
end

function PrayerPoint:createTableView()
    if self.tabView==nil then
        local CCHeroListItem=require "CCHeroListItem";
        self.tabView = cc.TableView:create(self.panel_16:getContentSize())
        self.tabView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.tabView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self.panel_16:addChild(self.tabView)

        local function cellSizeForTable(view, idx)
            return 160,118
        end
        local function numberOfCellsInTableView(view)
            return self.cell_num
        end
        local l_tag = 888
        local function tableCellAtIndex(view, idx)
            local data = self.viewDatas[idx+1];
            local cell = view:dequeueCell()
            if not cell then
                cell = cc.TableViewCell:new()
            end
            local selCell = cell:getChildByTag(l_tag)
            if not selCell then
                selCell = CCHeroListItem.new();
                NodeListener(selCell);
                selCell:setTag(l_tag)
                cell:addChild(selCell)
            end
            selCell:initData(self,data,1);
            return cell
        end
        local function tableCellTouched(table, cell)
        end
        self.tabView:setDelegate();
        self.tabView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX);
        self.tabView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX);
        self.tabView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW);
        self.tabView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED);
    end
    if self.tabView then
        self.tabView:reloadData();
    end
end

function PrayerPoint:prayerBtnClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local idStr="";
        for i=1,#self.heroTab do
            idStr=idStr..self.heroTab[i].data:getId();
            if i<#self.heroTab then
                idStr=idStr..":";
            end
        end
        local str=string.format("&g_ids=%s",idStr);
        NetHandler:sendData(Post_Cloud_Main_doPray, str);
        -- 
        MGGraySprite:graySprite(self.button_pray:getVirtualRenderer());
        self.button_pray:setTouchEnabled(false);
        self:setNoCanClick(true);  
    end
end

function PrayerPoint:clickHeroItem(delegete)
    local isChoose=delegete.isChoose;
    local data=delegete.data;
    local heroNum=table.getn(self.heroTab);
    if isChoose then
        if heroNum<self.chooseMax then
            table.insert(self.heroTab,delegete);
        end
    else
        if heroNum>=1 then
            for i=1,#self.heroTab do
                if self.heroTab[i].data:getId()==data:getId() then
                    table.remove(self.heroTab,i);
                    break
                end
            end
        end
    end
    heroNum=table.getn(self.heroTab);
    if heroNum>=self.chooseMax then
        self.button_pray:getVirtualRenderer():setShaderProgram(self.program);
        self.button_pray:setTouchEnabled(true);
        self.label_chNum:setVisible(false);
    else
        MGGraySprite:graySprite(self.button_pray:getVirtualRenderer());
        self.button_pray:setTouchEnabled(false);
        self.label_chNum:setVisible(true);
        self.label_chNum:setText(string.format(MG_TEXT("PrayerPoint_1"),self.chooseMax-heroNum));
    end
end

function PrayerPoint:onReciveData(msgId, netData)
	  if msgId == Post_Cloud_Main_doPray then
      	if netData.state == 1 then
            local dopray=netData.dopray;
            local add_exp=dopray.add_exp;
            -- 
            local upStr=string.format("%s+%d",MG_TEXT("PrayerPoint_2"),add_exp);
            for i=1,table.getn(self.heroTab) do
                local heroItem=self.heroTab[i];
                local headItem=heroItem.headItem;
                local point=heroItem:convertToWorldSpace(cc.p(headItem:getPositionX(),
                                headItem:getPositionY()));
                local pos=cc.p(point.x,point.y);
                FloatUpMessage:getInstance():showUpMessage("",upStr,self.pWidget,pos);
            end
            -- 
            self:createTableView();
            -- 延迟关闭
            local function delayClose()
                self:closePrayer();
            end
            local delay=cc.DelayTime:create(2.0);
            local callFunc=cc.CallFunc:create(delayClose);
            self:runAction(cc.Sequence:create(delay,callFunc));
      	else
          	NetHandler:showFailedMessage(netData);
      	end
  	end
end

function PrayerPoint:closePrayer()
    if self.delegate then
        self.delegate:closeOpenLayer();
    end
end

function PrayerPoint:onEnter()
    NetHandler:addAckCode(self,Post_Cloud_Main_doPray);
end

function PrayerPoint:onExit()
	NetHandler:delAckCode(self,Post_Cloud_Main_doPray);
	MGRCManager:releaseResources("PrayerPoint");
end

return PrayerPoint;