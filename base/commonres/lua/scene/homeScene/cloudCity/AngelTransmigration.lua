----云中城天使转生界面----
-- local AngelTransItem=require "AngelTransItem";
local AngelTransmigration=class("AngelTransmigration",function()
	return cc.Layer:create();
end);

function AngelTransmigration:ctor(delegate)
  	self.delegate=delegate;
    self.angelSkillStr=delegate.angelSkillStr;
    self.angelData=delegate.angelData;

  	self.pWidget=MGRCManager:widgetFromJsonFile("AngelTransmigration", "CloudCity_AngelTransmigration.ExportJson");
  	self:addChild(self.pWidget);

  	local panel_2 = self.pWidget:getChildByName("Panel_2");--Panel
    local button_close=panel_2:getChildByName("Button_close");--Button
    button_close:addTouchEventListener(handler(self,self.closeBtnClick));
    -- 
  	local button_trans=panel_2:getChildByName("Button_Transmigration");--Button
  	button_trans:addTouchEventListener(handler(self,self.transBtnClick));

    local label_transmigration=button_trans:getChildByName("Label_Transmigration");
    label_transmigration:setText(MG_TEXT_COCOS("AngelTransmigration_Ui_2"));
    -- 
    self.img_angel=panel_2:getChildByName("Image_16");
    self.img_angel:setScale(0.6);
    self.img_name=panel_2:getChildByName("Image_21");
    -- 星级
    self.panel_18=panel_2:getChildByName("Panel_19");
    -- 效果
    self.effectList=panel_2:getChildByName("ListView_19");
    -- 消耗
    self.costList=panel_2:getChildByName("ListView_18");
    -- 
    self.label_before=panel_2:getChildByName("Label_Level_Before");
    self.label_later=panel_2:getChildByName("Label_Level_Later");
    -- 
    local label_comsume=panel_2:getChildByName("Label_Comsume");
    label_comsume:setText(MG_TEXT_COCOS("AngelTransmigration_Ui_1"));
    -- 
   	NodeListener(self);
    -- 
    self:initData();
end

function AngelTransmigration:initData()
    local angelDb={};
    if self.delegate then
        angelDb=self.delegate:getAngelDb(self.angelData.a_id);
        local bigPic=angelDb.pic..".png";
        local namePic=angelDb.name_pic..".png";
        MGRCManager:cacheResource("AngelTransmigration",bigPic);
        MGRCManager:cacheResource("AngelTransmigration",namePic);
        self.img_angel:loadTexture(bigPic, ccui.TextureResType.plistType);
        self.img_name:loadTexture(namePic, ccui.TextureResType.plistType);
        -- 
        local starLv=0;
        if self.angelData then
            starLv=self.angelData.star;
        end
        self.panel_18:removeAllChildren();
        self.delegate:showAngelStar(self.panel_18,starLv);
    end
    -- 
    local beforeStr="";
    local laterStr="";
    local angelSkillMaxLv=LUADB.readConfig(130);
    angelSkillMaxLv=tonumber(angelSkillMaxLv);
    
    local skillBeforeTab={};
    local skillLaterTab={};
    local skill_info=self.angelData.skill_info;
    if skill_info then
        local str_info=spliteStr(skill_info,'|');
        if str_info then
            for i=1,#str_info do
                local skill_info=spliteStr(str_info[i],':');
                local sql=string.format("select * from angel_skill where skill_id=%d and rebirth_lv=%d and lv=%d",skill_info[1],self.angelData.rebirth_lv,skill_info[2]);
                local tmpDb=LUADB.select(sql, "effect");
                table.insert(skillBeforeTab,tmpDb.info);
                -- 判断下一转或者下一级的
                local rebirth_lv=self.angelData.rebirth_lv;
                local lv=tonumber(skill_info[2]);
                if rebirth_lv>0 then
                    if lv>=angelSkillMaxLv then
                        rebirth_lv=rebirth_lv+1;
                        lv=0;
                    else
                        lv=lv+1;
                    end
                else
                    rebirth_lv=rebirth_lv+1;
                    lv=0;
                end
                sql=string.format("select * from angel_skill where skill_id=%d and rebirth_lv=%d and lv=%d",skill_info[1],rebirth_lv,lv);
                tmpDb=LUADB.select(sql, "effect");
                table.insert(skillLaterTab,tmpDb.info);
                -- 
                if i==1 then
                    if self.angelData.rebirth_lv<=0 then
                        beforeStr=MG_TEXT("AngelTransmigration_1");
                    else
                        beforeStr=string.format(MG_TEXT("AngelTransmigration_2"),self.angelData.rebirth_lv,tonumber(skill_info[2]));
                    end
                    laterStr=string.format(MG_TEXT("AngelTransmigration_2"),rebirth_lv,lv);
                end
            end
        end
    end
    self.label_before:setText(beforeStr);
    self.label_later:setText(laterStr);
    -- 
    self.effectList:removeAllItems();
    local itemLay=ccui.Layout:create();
    local allHeight=0;
    local AngelTransItem=require "AngelTransItem";
    for i=1,table.getn(skillBeforeTab) do
        local beforeDb=skillBeforeTab[i];
        local laterDb=skillLaterTab[i];
        local item=AngelTransItem.new();
        item:setData(beforeDb,laterDb);
        itemLay:addChild(item);
        item:setTag(i);
        -- item:setAnchorPoint(0,1);
        allHeight=allHeight+item:getContentSize().height;
    end
    -- print("allHeight ===", allHeight)
    itemLay:setSize(cc.size(self.effectList:getContentSize().width, allHeight));
    self.effectList:pushBackCustomItem(itemLay);
    local items_count=itemLay:getChildrenCount()
    for i=1,items_count do
        local item=itemLay:getChildByTag(i)
        allHeight=allHeight-item:getContentSize().height;
        item:setPosition(0,allHeight);
    end
    -- 消耗
    local sql=string.format("select * from angel_rebirth where a_id=%d and rebirth_lv=%d",self.angelData.a_id,self.angelData.rebirth_lv+1);
    local tmpDb=LUADB.select(sql, "need");
    local rebirthDb=tmpDb.info;
    local str_need=spliteStr(rebirthDb.need,'|');
    local count=#str_need;
    self.costList:removeAllItems();
    local itemLay2 = ccui.Layout:create();
    itemLay2:setSize(cc.size(count*self.costList:getContentSize().height, self.costList:getContentSize().height));
    self.costList:pushBackCustomItem(itemLay2);
    for i=1,count do
        local resData=ResourceTip.getInstance():getResData(str_need[i]);
        local item = resItem.create();
        item:setData(resData.type,resData.id,0);
        item:setNum(resData.num);
        itemLay2:addChild(item);
        item:setAnchorPoint(0,0.5);
        item:setPosition((i-1)*(item:getContentSize().width+40),itemLay2:getContentSize().height/2);
    end
end

function AngelTransmigration:closeBtnClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        self:closeTransmigration();
    end
end

function AngelTransmigration:transBtnClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local str=string.format("&id=%d",self.angelData.a_id);
        NetHandler:sendData(Post_Cloud_Angel_angelRebirth, str);
    end
end

function AngelTransmigration:onReciveData(msgId, netData)
	  if msgId == Post_Cloud_Angel_angelRebirth then
      	if netData.state == 1 then
            local angellist=netData.angellist.user_angel;
            if self.delegate then
                self.delegate:updataAngelData(angellist,true);
            end
            self:closeTransmigration();
      	else
          	NetHandler:showFailedMessage(netData);
      	end
  	end
end

function AngelTransmigration:closeTransmigration()
    self:removeFromParentAndCleanup(true);
end

function AngelTransmigration:onEnter()
    NetHandler:addAckCode(self,Post_Cloud_Angel_angelRebirth);
end

function AngelTransmigration:onExit()
	NetHandler:delAckCode(self,Post_Cloud_Angel_angelRebirth);
	MGRCManager:releaseResources("AngelTransmigration");
end

return AngelTransmigration;
