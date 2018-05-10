----云中城天使升星界面----

local AngelRisingStar=class("AngelRisingStar",function()
	return cc.Layer:create();
end);

function AngelRisingStar:ctor(delegate)
  	self.delegate=delegate;
    self.angelSkillStr=delegate.angelSkillStr;
    self.angelData=delegate.angelData;

  	self.pWidget=MGRCManager:widgetFromJsonFile("AngelRisingStar", "CloudCity_AngelRisingStar.ExportJson");
  	self:addChild(self.pWidget);

    local panel_2=self.pWidget:getChildByName("Panel_2");
  	local button_close=panel_2:getChildByName("Button_close");--Button
  	button_close:addTouchEventListener(handler(self,self.closeBtnClick));

    local button_risingStar=panel_2:getChildByName("Button_RisingStar");--Button
    button_risingStar:addTouchEventListener(handler(self,self.risingStarBtnClick));

    local label_risingStar=button_risingStar:getChildByName("Label_RisingStar");
    label_risingStar:setText(MG_TEXT_COCOS("AngelRisingStar_Ui_1"));
    -- 升星前后
    self.img_before=panel_2:getChildByName("Image_16");
    self.label_before=panel_2:getChildByName("Label_19");
    self.img_later=panel_2:getChildByName("Image_17");
    self.label_later=panel_2:getChildByName("Label_20");
    -- 技能图标
    self.img_skill=panel_2:getChildByName("Image_18");
    -- 技能名称
    self.label_skillName=panel_2:getChildByName("Label_SkillName");
    -- 技能效果
    self.label_effect=panel_2:getChildByName("Label_SkillEffect");
    -- 
    self.costList=panel_2:getChildByName("ListView_20");
    -- 
   	NodeListener(self);
    -- 
    self:initData();
end

function AngelRisingStar:initData()
    local str_list=spliteStr(self.angelSkillStr,'|');
    local skillDb={};
    for i=1,#str_list do
        local skillStr=spliteStr(str_list[i],':');
        if tonumber(skillStr[2])==self.angelData.star then
            skillStr=spliteStr(str_list[i+1],':');
            local sql=string.format("select * from angel_skill where skill_id=%d and rebirth_lv=%d",skillStr[1],self.angelData.rebirth_lv);
            local tmpDb=LUADB.select(sql, "skill_id:need:name:pic:des");
            skillDb=tmpDb.info;
            break
        end
    end
    local iconName=skillDb.pic..".png";
    MGRCManager:cacheResource("AngelRisingStar",iconName);
    self.img_skill:loadTexture(iconName, ccui.TextureResType.plistType);
    self.label_skillName:setText(skillDb.name);
    self.label_effect:setText(skillDb.des);
    -- 
    local angelHead="";
    local angelName="";
    if self.delegate then
        local angelDb=self.delegate:getAngelDb(self.angelData.a_id);
        angelHead=angelDb.head_pic..".png";
        MGRCManager:cacheResource("AngelRisingStar",angelHead);
        self.img_before:loadTexture(angelHead, ccui.TextureResType.plistType);
        self.img_later:loadTexture(angelHead, ccui.TextureResType.plistType);
        angelName=angelDb.name;
    end
    self:showHeadStar(self.img_before,self.angelData.star);
    self:showHeadStar(self.img_later,self.angelData.star+1);
    self.label_before:setText(angelName);
    self.label_later:setText(angelName);
    -- 
    -- 
    local sql=string.format("select * from angel_star where a_id=%d and star=%d",self.angelData.a_id,self.angelData.star+1);
    local tmpDb=LUADB.select(sql, "need");
    local starDb=tmpDb.info;
    local str_need=spliteStr(starDb.need,'|');
    local count=#str_need;
    self.costList:removeAllItems();
    local itemLay = ccui.Layout:create();
    itemLay:setSize(cc.size(count*self.costList:getContentSize().height, self.costList:getContentSize().height));
    self.costList:pushBackCustomItem(itemLay);
    for i=1,count do
        local resData=ResourceTip.getInstance():getResData(str_need[i]);
        local item = resItem.create();
        item:setData(resData.type,resData.id,0);
        item:setNum(resData.num);
        itemLay:addChild(item);
        -- local scale1=itemLay:getContentSize().height/item:getContentSize().height;
        -- print("scale1 == ", scale1)
        -- item:setScale(scale1);
        item:setAnchorPoint(0,0.5);
        item:setPosition((i-1)*(item:getContentSize().width+40),itemLay:getContentSize().height/2);
    end
end

function AngelRisingStar:showHeadStar(node,starLv)
    for i=1,starLv do
        local scaleVal=0.5;
        local starImg=ccui.ImageView:create("com_angel_star.png", ccui.TextureResType.plistType);
        starImg:setAnchorPoint(0,0);
        starImg:setScale(scaleVal);
        starImg:setPosition(cc.p((starImg:getContentSize().width*scaleVal-7)*(i-1), 0));
        node:addChild(starImg);
    end
end

function AngelRisingStar:closeBtnClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        self:closeRisingStar();
    end
end

function AngelRisingStar:risingStarBtnClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local str=string.format("&id=%d",self.angelData.a_id);
        NetHandler:sendData(Post_Cloud_Angel_upAngelStar, str);
    end
end

function AngelRisingStar:onReciveData(msgId, netData)
	  if msgId == Post_Cloud_Angel_upAngelStar then
      	if netData.state == 1 then
            local angellist=netData.angellist.user_angel;
            -- local num=table.getn(angellist);
            -- for i=1,num do
            --     if angellist[i].a_id==self.angelData.a_id then
            --         self.angelData=angellist[i];
            --         break
            --     end
            -- end
            -- self:initData();
            -- 
            if self.delegate then
                self.delegate:updataAngelData(angellist,true);
            end
            self:closeRisingStar();
      	else
          	NetHandler:showFailedMessage(netData);
      	end
  	end
end

function AngelRisingStar:closeRisingStar()
    self:removeFromParentAndCleanup(true);
end

function AngelRisingStar:onEnter()
    NetHandler:addAckCode(self,Post_Cloud_Angel_upAngelStar);
end

function AngelRisingStar:onExit()
	  NetHandler:delAckCode(self,Post_Cloud_Angel_upAngelStar);
	  MGRCManager:releaseResources("AngelRisingStar");
end

return AngelRisingStar;
