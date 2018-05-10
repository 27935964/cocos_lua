----云中城祝福点界面----
-- require "ItemJump";
-- local CCHeroListItem=require "CCHeroListItem";
local BlessingPoint=class("BlessingPoint",function()
	return cc.Layer:create();
end);

function BlessingPoint:ctor(delegate)
  	self.delegate=delegate;
    self.tabView=nil;
    self.heroItem=nil;
    -- 
  	self.pWidget=MGRCManager:widgetFromJsonFile("BlessingPoint", "CloudCity_BlessingPoint_Ui.ExportJson");
  	self:addChild(self.pWidget);

  	local panel_2=self.pWidget:getChildByName("Panel_2");--Panel
    self.panel_4=panel_2:getChildByName("Panel_3");
    self.panel_3=self.pWidget:getChildByName("Panel_3");
    self:setNoCanClick(false);
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
    label_tips:setText(MG_TEXT_COCOS("BlessingPoint_Ui_1"));
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

function BlessingPoint:setNoCanClick(isVisible)
    self.panel_3:setTouchEnabled(isVisible);
end

function BlessingPoint:initData()
    -- 自己已经拥有的
    local tmpList=GENERAL:getGeneralList();
    local temList={};
    for k,v in pairs(tmpList) do--根据数据库配置可否接受祝福
        if v:isBlessing() then
            table.insert(temList,v);
        end
    end
    print("temList ===",table.getn(temList))
    self.viewDatas=self:parseTableViewData(temList);
    self.cell_num=table.getn(self.viewDatas);
    self:createTableView();
    -- 
    if self.delegate then
        self.delegate:showAngelInfo(self.img_bubble,self.img_angel,self.img_name,self.panel_24,false);
    end
end

function BlessingPoint:parseTableViewData(datas)
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

function BlessingPoint:createTableView()
    if self.tabView==nil then
        local CCHeroListItem=require "CCHeroListItem";
        self.tabView = cc.TableView:create(self.panel_4:getContentSize())
        self.tabView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.tabView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self.panel_4:addChild(self.tabView)

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
            selCell:initData(self,data,2);
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

function BlessingPoint:clickHeroItem(delegete)
    self.heroItem=delegete;
    local str=string.format("&g_id=%d",self.heroItem.data:getId());
    NetHandler:sendData(Post_Cloud_Main_doBlessing, str);
    self:setNoCanClick(true);
end

function BlessingPoint:onReciveData(msgId, netData)
	  if msgId == Post_Cloud_Main_doBlessing then
      	if netData.state == 1 then
            local reward=netData.doblessing.reward;
            local itemPos={};
            local headItem=self.heroItem.headItem;
            local point=self.heroItem:convertToWorldSpace(cc.p(headItem:getPositionX(),
                            headItem:getPositionY()));
            local pos=cc.p(point.x,point.y);
            table.insert(itemPos,pos);
            ItemJump:getInstance():showItemJump(reward,self.pWidget,itemPos,0.9,true);
            -- 
            -- 延迟关闭
            local function delayClose()
                self:closeBlessing();
            end
            local delay=cc.DelayTime:create(2.0);
            local callFunc=cc.CallFunc:create(delayClose);
            self:runAction(cc.Sequence:create(delay,callFunc));
            
      	else
          	NetHandler:showFailedMessage(netData);
      	end
  	end
end

function BlessingPoint:closeBlessing()
    if self.delegate then
        self.delegate:closeOpenLayer();
    end
end

function BlessingPoint:onEnter()
    NetHandler:addAckCode(self,Post_Cloud_Main_doBlessing);
end

function BlessingPoint:onExit()
  	NetHandler:delAckCode(self,Post_Cloud_Main_doBlessing);
  	MGRCManager:releaseResources("BlessingPoint");
end

return BlessingPoint;
