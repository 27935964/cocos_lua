----云中城猜拳奖励界面----

local FightReward=class("FightReward",function()
	return cc.Layer:create();
end);

function FightReward:ctor(delegate,reward,winNum,loseNum)
    self.delegate=delegate;
    self.reward=reward;
    -- 
    MGRCManager:cacheResource("FightReward", "user_card_get_bg.png");
    MGRCManager:cacheResource("FightReward", "userCard_ui0.png","userCard_ui0.plist");
    -- 
  	local pWidget=MGRCManager:widgetFromJsonFile("FightReward","usercard_ui_4.ExportJson");
    self:addChild(pWidget);

  	local panel_2=pWidget:getChildByName("Panel_2");--Panel
    -- 
    local btn_again=panel_2:getChildByName("Button_again");
    btn_again:setEnabled(false);
    local img_icon=panel_2:getChildByName("Image_icon");
    img_icon:setVisible(false);
    -- 
    local img_frame=panel_2:getChildByName("Image_bg2");
    local img_title=panel_2:getChildByName("Image_titleBg");
    local titleName="CloudCity_Fail.png";
    if winNum>=2 then
        if loseNum==0 then
            -- 完胜
            titleName="CloudCity_Victory.png";
        else
            -- 胜利
            titleName="CloudCity_Win.png";
        end
    end
    img_title:loadTexture(titleName, ccui.TextureResType.plistType);
    img_title:setPositionY(img_frame:getPositionY()+img_frame:getContentSize().height/2+20);
    -- 
    local btn_back=panel_2:getChildByName("Button_back");
    local Label_back=btn_back:getChildByName("Label_back");
    Label_back:setText(MG_TEXT_COCOS("ChangeNameUi_4"));
    btn_back:setPositionX(panel_2:getContentSize().width/2);
    btn_back:addTouchEventListener(handler(self,self.onBackClick));
    -- 
    self.List=panel_2:getChildByName("ListView");
    self:showReward();
end

function FightReward:showReward()
    local str_list=spliteStr(self.reward,'|');
    local getitem={};
    for i=1,#str_list do
        local resData=ResourceTip.getInstance():getResData(str_list[i]);
        table.insert(getitem,resData);
    end
    local t1 = math.modf(#getitem/5);
    local t2 = #getitem - t1*5
    if t2>0 then
        t1 = t1+1;
    end
    for i=1,t1 do
        local count = 5;
        if i==t1 and t2>0 then
            count = t2;
        end
        local itemLay = ccui.Layout:create();
        local _width = 0;
        local _hight = 140;
        for j=1,count do
            local x = (i-1)*5 + j;
            if x>#getitem then
                break;
            end
            local item = resItem.create();
            item:setData(getitem[x].type,getitem[x].id,0);
            item:setNum(getitem[x].num);
            item.nameLabel:setVisible(true);
            item:setPosition(cc.p(item:getContentSize().width/2+(item:getContentSize().width+40)*(j-1),80));
            itemLay:addChild(item);

            _width=item:getContentSize().width;
        end
        if t1==1 and t2>0 then
            itemLay:setSize(cc.size(_width*t2+40*(t2-1), _hight));
        else
            itemLay:setSize(cc.size(_width*5+40*4, _hight));
        end
        self.List:pushBackCustomItem(itemLay);
    end

    if t1 == 1 then
        self.List:setSize(cc.size(self.List:getSize().width, 160));
        self.List:setPositionY(260);
    end
end

function FightReward:onBackClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        self:closeFightReward();
    end
end

function FightReward:closeFightReward()
    if self.delegate then
        self.delegate:closeOpenReward();
    end
end

function FightReward:onEnter()
end

function FightReward:onExit()
	  MGRCManager:releaseResources("FightReward");
end

return FightReward;
