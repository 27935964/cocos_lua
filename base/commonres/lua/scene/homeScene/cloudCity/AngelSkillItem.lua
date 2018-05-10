----云中城天使技能Item界面----

local AngelSkillItem=class("AngelSkillItem",function()
	return cc.Layer:create();
end);

AngelSkillItem.WIDTH=971;
AngelSkillItem.HEIGHT=191;

function AngelSkillItem:ctor(delegate)
  	self.delegate=delegate;
    -- 
  	local widget=self.delegate.listWidget:clone();
    self:addChild(widget);
    -- 技能名
    self.label_skillName=widget:getChildByName("Label_SkillName");
    -- 技能等级
    self.label_level=widget:getChildByName("Label_Level");
    self.label_level:setVisible(false);
    -- 技能图标
    self.img_icon=widget:getChildByName("Image_19");
    -- 描述
    self.label_desc=widget:getChildByName("Label_SkillInstruction");
    -- 
    self.button_levelUp=widget:getChildByName("Button_LevelUp");--Button
    self.button_levelUp:addTouchEventListener(handler(self,self.levelUpBtnClick));
    self.button_levelUp:setEnabled(false);
    self.program = self.button_levelUp:getVirtualRenderer():getShaderProgram();
    local label_levelUp=self.button_levelUp:getChildByName("Label_LevelUp");
    label_levelUp:setText(MG_TEXT_COCOS("AngelSkillItem_Ui_1"));
    -- 
    self.img_unActivated=widget:getChildByName("Image_UnActivated");
    self.img_unActivated:setVisible(false);
    -- 
    local panel_consume=widget:getChildByName("Panel_Consume");
    self.label_consume=panel_consume:getChildByName("Label_Comsume");
    self.label_consume:setVisible(false);
    self.panel_12=panel_consume:getChildByName("Panel_12");
end

function AngelSkillItem:setData(skillDb,nextSkillDb,angelData,angelSkillStr)
    self.skillDb=skillDb;
    self.angelData=angelData;
    self.label_skillName:setText(skillDb.name);  
    local iconName=skillDb.pic..".png";
    MGRCManager:cacheResource("AngelSkillItem",iconName);
    self.img_icon:loadTexture(iconName, ccui.TextureResType.plistType);
    self.label_desc:setText(skillDb.des);
    -- 
    self.panel_12:removeAllChildren();
    -- 
    local unactivated=true;
    local starLv="0";
    if angelData then
        -- local str_need=spliteStr(skillDb.need,'|');
        -- for i=1,#str_need do
        --     local resData=ResourceTip.getInstance():getResData(str_need[i]);
        --     local itemLay = ccui.Layout:create();
        --     itemLay:setSize(cc.size(self.panel_12:getContentSize().width, self.panel_12:getContentSize().height));
        --     local item = resItem.create();
        --     item:setData(resData.type,resData.id,resData.num);
        --     itemLay:addChild(item);
        --     local scale1=itemLay:getContentSize().height/item:getContentSize().height;
        --     item:setScale(scale1);
        --     item:setAnchorPoint(0,0.5);
        --     item:setPosition(item:getContentSize().width*(i-1),itemLay:getContentSize().height/2);
        --     self.panel_12:addChild(itemLay);
        -- end
        -- 
        -- local starLv="0";
        local skill_info=self.angelData.skill_info;
        if skill_info then
            local str_info=spliteStr(skill_info,'|');
            if str_info then
                for i=1,#str_info do
                    local str=spliteStr(str_info[i],':');
                    for j=1,#str do
                        if str[1]==skillDb.skill_id then
                            if self.angelData.rebirth_lv>0 then
                                unactivated=false;
                                starLv=str[2];
                            elseif tonumber(str[2])>0 then
                                unactivated=false;
                                starLv=str[2];
                            end
                            break
                        end
                    end
                    if unactivated==false then
                        break
                    end
                end
            end
        end
        if self.angelData.rebirth_lv>0 then
            unactivated=false;
        end
        -- self.label_level:setText(string.format(MG_TEXT("AngelSkillItem_1"),self.angelData.rebirth_lv,starLv));
        -- self.label_level:setVisible(true);
    else
        -- local needNum=skillDb.lv;
        -- for i=1,needNum do
        --     local starImg=ccui.ImageView:create("com_angel_star.png", ccui.TextureResType.plistType);
        --     starImg:setAnchorPoint(0,0.5);
        --     starImg:setPosition(cc.p(starImg:getContentSize().width*(i-1), self.panel_12:getContentSize().height/2));
        --     self.panel_12:addChild(starImg);
        -- end
    end
    -- 
    local consumeStr="";
    local markName=""; 
    -- 未激活
    if unactivated then
        markName="CloudCity_SupremePalace_Skill_Unactivated.png";
        consumeStr=MG_TEXT("AngelSkillItem_2");
        -- 
        local needNum=0;
        local str_list=spliteStr(angelSkillStr,'|');
        for i=1,#str_list do
            local skillStr=spliteStr(str_list[i],':');
            if tonumber(skillDb.skill_id)==tonumber(skillStr[1]) then
                needNum=tonumber(skillStr[2]);
                break
            end 
        end
        for i=1,needNum do
            local starImg=ccui.ImageView:create("com_angel_star.png", ccui.TextureResType.plistType);
            starImg:setAnchorPoint(0,0.5);
            starImg:setPosition(cc.p(starImg:getContentSize().width*(i-1), self.panel_12:getContentSize().height/2));
            self.panel_12:addChild(starImg);
        end
    else
        -- 已激活
        if self.angelData.rebirth_lv>0 then
            -- 已转生可升级
            if nextSkillDb then
                local str_need=spliteStr(nextSkillDb.need,'|');
                for i=1,#str_need do
                    local resData=ResourceTip.getInstance():getResData(str_need[i]);
                    local itemLay=ccui.Layout:create();
                    itemLay:setSize(cc.size(self.panel_12:getContentSize().width, self.panel_12:getContentSize().height));
                    local item=resItem.create();
                    item:setData(resData.type,resData.id,0);
                    item:setNum(resData.num);
                    itemLay:addChild(item);
                    local scale1=itemLay:getContentSize().height/item:getContentSize().height;
                    item:setScale(scale1);
                    item:setAnchorPoint(0,0.5);
                    item:setPosition(item:getContentSize().width*(i-1),itemLay:getContentSize().height/2);
                    self.panel_12:addChild(itemLay);
                end
                -- 
                self.label_level:setText(string.format(MG_TEXT("AngelSkillItem_1"),self.angelData.rebirth_lv,starLv));
                self.label_level:setVisible(true);
                -- 当前转升到最大级了
                local angelSkillMaxLv=LUADB.readConfig(130);
                angelSkillMaxLv=tonumber(angelSkillMaxLv);
                if tonumber(starLv)>=angelSkillMaxLv then
                    MGGraySprite:graySprite(self.button_levelUp:getVirtualRenderer());
                else
                    self.button_levelUp:getVirtualRenderer():setShaderProgram(self.program);
                end
            end
        else
            -- 未转生不可升级
            markName="CloudCity_SupermePalace_Skill_Active.png";
        end
    end
    if string.len(markName)>0 then
        self.img_unActivated:loadTexture(markName, ccui.TextureResType.plistType);
        self.img_unActivated:setVisible(true);
        self.button_levelUp:setEnabled(false);
    else
        self.button_levelUp:setEnabled(true);
        self.img_unActivated:setVisible(false);
        consumeStr=MG_TEXT("AngelSkillItem_3");
    end
    if string.len(consumeStr)>0 then
        self.label_consume:setText(consumeStr);
        self.label_consume:setVisible(true);
    else
        self.label_consume:setVisible(false);
    end
end

function AngelSkillItem:levelUpBtnClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        if self.delegate then
            self.delegate:clickItemUpSkill(self.angelData,self.skillDb);
        end
    end
end

function AngelSkillItem:onEnter()
end

function AngelSkillItem:onExit()
	MGRCManager:releaseResources("AngelSkillItem");
end

return AngelSkillItem;