--------------------------交际界面的Item-----------------------

local heroCommunicationItem = class("heroCommunicationItem", MGWidget)

function heroCommunicationItem:init(delegate,widget)
	self.delegate=delegate;
    self:addChild(widget);
    self.pWidget = widget;
    self.btnType = 1;--1激活，2升级

    local Panel_2 = self.pWidget:getChildByName("Panel_2");
    self:setContentSize(Panel_2:getContentSize());

    self.Image_nameBg= Panel_2:getChildByName("Image_nameBg");
    self.Label_name= Panel_2:getChildByName("Label_name");
    self.Label_level= Panel_2:getChildByName("Label_level");

    local Panel_head= Panel_2:getChildByName("Panel_head");
    self.headEx = HeroHeadEx.create(self);
    self.headEx:setPosition(cc.p(Panel_head:getContentSize().width/2,Panel_head:getContentSize().height/2));
    Panel_head:addChild(self.headEx);

    self.Panel_3= Panel_2:getChildByName("Panel_3");
    self.Label_value1= self.Panel_3:getChildByName("Label_value1");

    self.Panel_4= Panel_2:getChildByName("Panel_4");
    self.pos = self.Panel_4:getPosition();
    self.Label_value2= self.Panel_4:getChildByName("Label_value2");

    self.Image_mark= Panel_2:getChildByName("Image_mark");
    self.Image_mark:setVisible(false);
    self.oldHeadProgram = self.Image_mark:getSprit():getShaderProgram();

    self.Label_need= Panel_2:getChildByName("Label_need");
    self.needLabel = MGColorLabel:label();
    self.needLabel:setAnchorPoint(cc.p(0, 0.5));
    self.needLabel:setPosition(self.Label_need:getPosition());
    Panel_2:addChild(self.needLabel);

    self.Panel_5= Panel_2:getChildByName("Panel_5");
    self.Label_num= self.Panel_5:getChildByName("Label_num");
    -- self.Image_coin= self.Panel_5:getChildByName("Image_coin");
    -- self.Image_coin:setScale(0.5)

    self.Button_up = self.Panel_5:getChildByName("Button_up");
    self.Button_up:addTouchEventListener(handler(self,self.onButtonClick));

    local Label_add1= self.Panel_3:getChildByName("Label_add1");
    local Label_add2= self.Panel_4:getChildByName("Label_add2");
    local Label_tip= self.Panel_5:getChildByName("Label_tip");
    self.Label_btn= self.Button_up:getChildByName("Label_btn");
    self.Label_btn:getLabel():enableShadow(cc.c4b(0,0,0,191), cc.size(2, -2),1);

    Label_add1:setText(MG_TEXT_COCOS("hero_communication_item_ui_1"));
    Label_add2:setText(MG_TEXT_COCOS("hero_communication_item_ui_2"));
    Label_tip:setText(MG_TEXT_COCOS("hero_communication_item_ui_3"));
    self.Label_btn:setText(MG_TEXT_COCOS("hero_communication_item_ui_4"));
    
end

function heroCommunicationItem:setData(friendships,maxLevel,qualityList,friendshipData)
    self.friendships = friendships;
	self.qualityList = qualityList;
    self.friendshipData = friendshipData;

    self.gm = nil;
    self.g_id = 0;
    self.f_s_id = 0;
    self.nextLv = 1;
    local isMyGneral = true;--该武将已经拥有
    if nil == friendshipData then--未激活
        self.btnType = 1;
        self.g_id = friendships[self.nextLv].need_g_id;
        self.f_s_id = friendships[self.nextLv].f_s_id;
        self.nextLv = friendships[self.nextLv].lv;
        self.gm = GENERAL:getGeneralModel(friendships[1].need_g_id);
        if nil == self.gm then
            isMyGneral = false;
            self.gm = GENERAL:getAllGeneralModel(friendships[1].need_g_id);
        end
        self.Image_mark:setVisible(false);
        if isMyGneral == false then
            self:setShow(1,friendships);
        else
            if self:isMeetConditionsmeet(self.gm,friendships[self.nextLv]) == true then
                self:setShow(2,friendships);
            else
                self:setShow(1,friendships);
            end
        end
    else
        self.btnType = 2;
        self.nextLv = friendshipData.lv+1;
        self.g_id = friendships[self.nextLv].need_g_id;
        self.f_s_id = friendships[self.nextLv].f_s_id;
        if self.nextLv >= maxLevel then
            self.nextLv = maxLevel;
        end
        self.gm = GENERAL:getGeneralModel(friendshipData.g_id);
        self.Image_mark:setVisible(true);
        if self:isMeetConditionsmeet(self.gm,friendships[self.nextLv]) == true then
            self:setShow(2,friendships);
        else
            self:setShow(1,friendships);
        end
    end

    if self.gm then
        self.headEx:setData(self.gm);
        self.Label_name:setText(self.gm:name());
        self.Label_level:setText(string.format("Lv %d/%d",self.gm:getLevel(),maxLevel));
        self.Label_num:setText(friendships[self.nextLv].need.value3);
        if self.nextLv >= maxLevel then
            self.Panel_5:setVisible(false);
            self.Button_up:setEnabled(false);
            self.needLabel:setVisible(true);
            self.needLabel:setText(MG_TEXT("heroCommunication_8"));
        end
    end
end

function heroCommunicationItem:setShow(type,friendships)
    if self.gm == nil then
        return;
    end

    if type == 1 then--显示条件
        self.Image_nameBg:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
        self.Panel_3:setVisible(false);
        self.Panel_4:setPosition(self.Panel_3:getPosition());
        self.Label_level:setVisible(false);
        self.Button_up:setEnabled(false);
        self.Panel_5:setVisible(false);
        self.needLabel:setVisible(true);

        local quality = "";
        if friendships[self.nextLv].need_g_quality > 0 then
            quality = self.qualityList[friendships[self.nextLv].need_g_quality].desc;
        end

        local str = "";
        local str0 = "";
        local str1 = "";
        local str2 = "";
        local str3 = "";
        local str4 = "";
        str0 = string.format(MG_TEXT("heroCommunication_1"),self.gm:name());
        if friendships[self.nextLv].need_g_lv > 0 and self.gm:getLevel() >= friendships[self.nextLv].need_g_lv then
            str1 = string.format("<c=021,080,000>%s</c>",string.format(MG_TEXT("heroCommunication_4"),friendships[self.nextLv].need_g_lv));
        elseif friendships[self.nextLv].need_g_lv > 0 and self.gm:getLevel() < friendships[self.nextLv].need_g_lv then
            str1 = string.format("<c=161,000,000>%s</c>",string.format(MG_TEXT("heroCommunication_4"),friendships[self.nextLv].need_g_lv));
        end

        if friendships[self.nextLv].need_g_quality > 0 and self.gm:getQuality() >= friendships[self.nextLv].need_g_quality then
            str2 = string.format("<c=021,080,000>%s</c>",string.format(MG_TEXT("heroCommunication_5"),quality));
        elseif friendships[self.nextLv].need_g_quality > 0 and self.gm:getQuality() < friendships[self.nextLv].need_g_quality then
            str2 = string.format("<c=161,000,000>%s</c>",string.format(MG_TEXT("heroCommunication_5"),quality));
        end

        if friendships[self.nextLv].need_g_star > 0 and self.gm:getStar() >= friendships[self.nextLv].need_g_star then
            str3 = string.format("<c=021,080,000>%s</c>",string.format(MG_TEXT("heroCommunication_6"),friendships[self.nextLv].need_g_star));
        elseif friendships[self.nextLv].need_g_star > 0 and self.gm:getStar() < friendships[self.nextLv].need_g_star then
            str3 = string.format("<c=161,000,000>%s</c>",string.format(MG_TEXT("heroCommunication_6"),friendships[self.nextLv].need_g_star));
        end

        local name = ""
        local isTreasure = true;--是否有物品
        if friendships[self.nextLv].need_treasure_id > 0 then
            local resGm = RESOURCE:getResModel(friendships[self.nextLv].need_treasure_id);
            if nil == resGm then
                isTreasure = false;
            else
                local sql = string.format("select name from treasure where id=%d",friendships[self.nextLv].need_treasure_id);
                local DBData = LUADB.select(sql, "name");
                name = DBData.info.name;
            end
        end
        if friendships[self.nextLv].need_treasure_id > 0 and isTreasure == true then
            str4 = string.format("<c=021,080,000>%s</c>",string.format(MG_TEXT("heroCommunication_7"),name));
        elseif friendships[self.nextLv].need_treasure_id > 0 and isTreasure == false then
            str4 = string.format("<c=161,000,000>%s</c>",string.format(MG_TEXT("heroCommunication_7"),name));
        end

        str = str0..str1..str2..str3..str4;
        self.needLabel:clear();
        self.needLabel:appendStringAutoWrap(str,16,1,cc.c3b(255,255,255),22);
    elseif type == 2 then--显示激活或升级
        self.Panel_3:setVisible(true);
        self.Panel_4:setPosition(self.pos);
        self.Button_up:setEnabled(true);
        self.Panel_5:setVisible(true);
        self.Label_btn:setText(MG_TEXT("heroCommunication_2"));
        self.needLabel:setVisible(false);

        if self.friendshipData then
            self.Label_btn:setText(MG_TEXT("heroCommunication_3"));
        end
    end

    local sql = string.format("select name from effect where id=%d",self.nextLv);
    local DBData = LUADB.select(sql, "name");
    self.Label_value2:setText(string.format("%s +%d",DBData.info.name,friendships[self.nextLv].effect[1].value2));

end

function heroCommunicationItem:isMeetConditionsmeet(gm,friendship)--判断是否满足激活或者升级条件
    local isMeet = false;
    local isTreasure = true;--是否有物品
    if friendship.need_treasure_id > 0 then
        local resGm = RESOURCE:getResModel(friendship.need_treasure_id);
        if nil == resGm then
            isTreasure = false;
        end
    end

    if self.gm:getLevel() >= friendship.need_g_lv and self.gm:getQuality() >= friendship.need_g_quality
    and self.gm:getStar() >= friendship.need_g_star and isTreasure == true then
        isMeet = true;
    end

    return isMeet;
end

function heroCommunicationItem:onButtonClick(sender, eventType)
    buttonClickScale(sender, eventType, 0.80);

    if eventType == ccui.TouchEventType.ended then
        if self.btnType == 1 then--激活
            if self.delegate and self.delegate.upSendReq then
                self.delegate:upSendReq(self.g_id,self.f_s_id);
            end
        elseif self.btnType == 2 then--升级
            if self.delegate and self.delegate.upSendReq then
                self.delegate:upSendReq(self.g_id,self.f_s_id);
            end
        end
    end
end

function heroCommunicationItem:onEnter()
    
end

function heroCommunicationItem:onExit()
    MGRCManager:releaseResources("heroCommunicationItem")
end

function heroCommunicationItem.create(delegate,widget)
    local layer = heroCommunicationItem:new()
    layer:init(delegate,widget)
    local function onNodeEvent(event)
        if event == "enter" then
            layer:onEnter()
        elseif event == "exit" then
            layer:onExit()
        end
    end
    
    layer:registerScriptHandler(onNodeEvent)
    
    return layer   
end

return heroCommunicationItem