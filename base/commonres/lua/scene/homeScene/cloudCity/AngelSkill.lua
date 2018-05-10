----云中城天使技能界面----
-- local AngelSkillItem=require "AngelSkillItem";
local AngelSkill=class("AngelSkill",function()
	return cc.Layer:create();
end);

function AngelSkill:ctor(delegate)
  	self.delegate=delegate;
    self.angelSkillStr=delegate.angelSkillStr;
    self.angelData=delegate.angelData;
    self.listWidget=nil;
    self.tabView=nil;
    self.cell_num=0;
    self.curListY=100000;

    if self.listWidget==nil then
        self.listWidget=MGRCManager:widgetFromJsonFile("AngelSkill", "CloudCity_AngelSkill_Ui_2.ExportJson");
        self.listWidget:retain();
    end
  	self.pWidget=MGRCManager:widgetFromJsonFile("AngelSkill", "CloudCity_AngelSkill_Ui_1.ExportJson");
  	self:addChild(self.pWidget);

  	local panel_2=self.pWidget:getChildByName("Panel_2");--Panel
  
  	local button_close=panel_2:getChildByName("Button_close");--Button
  	button_close:addTouchEventListener(handler(self,self.closeBtnClick));

    self.panel_14=panel_2:getChildByName("Panel_14");
    -- 
   	NodeListener(self);
    -- 
    self:initData();
end

function AngelSkill:initData()
    local str_list=spliteStr(self.angelSkillStr,'|');
    --当前转级的
    self.skillDbDatas={};
    --当前转下一级的
    self.nextSkillDbDatas={};
    for i=1,#str_list do
        local skillStr=spliteStr(str_list[i],':');
        local sql=string.format("select * from angel_skill where skill_id=%d and lv=%d",skillStr[1],1);--skillStr[2]
        local nextSql="";
        -- print("111111sql=====",sql)
        if self.angelData then
            local skill_info=self.angelData.skill_info;
            local str_info=spliteStr(skill_info,'|');
            for j=1,#str_info do
                local str=spliteStr(str_info[j],':');
                if tonumber(str[1])==tonumber(skillStr[1]) then
                    if self.angelData.rebirth_lv>0 then
                        local starLv=tonumber(str[2]);
                        sql=string.format("select * from angel_skill where skill_id=%d and rebirth_lv=%d and lv=%d",str[1],self.angelData.rebirth_lv,starLv);
                        local angelSkillMaxLv=LUADB.readConfig(130);
                        angelSkillMaxLv=tonumber(angelSkillMaxLv);
                        if starLv<angelSkillMaxLv then
                            starLv=starLv+1;
                        end
                        nextSql=string.format("select * from angel_skill where skill_id=%d and rebirth_lv=%d and lv=%d",str[1],self.angelData.rebirth_lv,starLv);
                        -- print("222222sql=====",sql)
                    elseif tonumber(str[2])>0 then
                        sql=string.format("select * from angel_skill where skill_id=%d and rebirth_lv=%d and lv=%d",str[1],self.angelData.rebirth_lv,str[2]);
                        -- print("333333sql=====",sql)
                    end
                    break
                end
            end
        end
        local skillDb=LUADB.select(sql, "skill_id:lv:need:name:pic:des");
        table.insert(self.skillDbDatas,skillDb.info);
        local nextSkillDb=LUADB.select(nextSql, "skill_id:lv:need:name:pic:des");
        if nextSkillDb then
            table.insert(self.nextSkillDbDatas,nextSkillDb.info);
        end
    end
    self.cell_num=#str_list;
    self:createTableView();
end

function AngelSkill:createTableView()
    if self.tabView==nil then
        local AngelSkillItem=require "AngelSkillItem";
        self.tabView = cc.TableView:create(self.panel_14:getContentSize());
        self.tabView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.tabView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self.panel_14:addChild(self.tabView)
        self.tabView:setPosition(cc.p(0, 0))   

        local function cellSizeForTable(view, idx)
            return AngelSkillItem.HEIGHT,AngelSkillItem.WIDTH
        end
        local function numberOfCellsInTableView(view)
            return self.cell_num
        end
        local l_tag = 888
        local function tableCellAtIndex(view, idx)
            local skillDb = self.skillDbDatas[idx+1];
            local nextSkillDb = nil;
            if table.getn(self.nextSkillDbDatas)>=idx+1 then
                nextSkillDb=self.nextSkillDbDatas[idx+1];
            end
            local cell = view:dequeueCell()
            if not cell then
                cell = cc.TableViewCell:new()
            end
            local selCell = cell:getChildByTag(l_tag)
            if not selCell then
                selCell = AngelSkillItem.new(self);
                NodeListener(selCell);
                selCell:setTag(l_tag)
                cell:addChild(selCell)
            end
            selCell:setData(skillDb,nextSkillDb,self.angelData,self.angelSkillStr);
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
        -- 
        if self.curListY~=100000 then
            self.tabView:setContentOffset(cc.p(0, self.curListY));
        end
    end
end

function AngelSkill:closeBtnClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        self:removeFromParentAndCleanup(true);
    end
end

-- function AngelSkill:risingStarBtnClick(sender, eventType)
--     if eventType == ccui.TouchEventType.ended then
--     end
-- end

function AngelSkill:clickItemUpSkill(angelData,skillDb)
    local str=string.format("&id=%d&skill_id=%d",angelData.a_id,skillDb.skill_id);
    NetHandler:sendData(Post_Cloud_Angel_upSkill, str);
    self.curListY=self.tabView:getContentOffset().y;
end

function AngelSkill:onReciveData(msgId, netData)
	if msgId == Post_Cloud_Angel_upSkill then
      	if netData.state == 1 then
            local angellist=netData.angellist.user_angel;
            local num=table.getn(angellist);
            for i=1,num do
                if angellist[i].a_id==self.angelData.a_id then
                    self.angelData=angellist[i];
                    break
                end
            end
            self:initData();
            -- 
            if self.delegate then
                self.delegate:updataAngelData(angellist,false);
            end
      	else
          	NetHandler:showFailedMessage(netData);
      	end
  	end
end

function AngelSkill:onEnter()
    NetHandler:addAckCode(self,Post_Cloud_Angel_upSkill);
end

function AngelSkill:onExit()
  if self.listWidget~=nil then
      self.listWidget:release();
      self.listWidget=nil;
  end
	NetHandler:delAckCode(self,Post_Cloud_Angel_upSkill);
	MGRCManager:releaseResources("AngelSkill");
end

return AngelSkill;
