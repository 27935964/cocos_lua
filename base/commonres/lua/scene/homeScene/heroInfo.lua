-----------------------将领属性界面------------------------

heroInfo = class("heroInfo", MGLayer)

function heroInfo:ctor()
    self:init();
end

function heroInfo:init()
    MGRCManager:cacheResource("heroInfo", "role_info_VIP_number.png");
    local pWidget = MGRCManager:widgetFromJsonFile("heroInfo","hero_info_ui.ExportJson",false);
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);

    
    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));

    local Image_frame = self.Panel_1:getChildByName("Image_frame");
    self.Image_frame = Image_frame;
    self.Label_name =  Image_frame:getChildByName("Label_name");
    self.Label_score =  Image_frame:getChildByName("Label_score");
    self.Label_soldier =  Image_frame:getChildByName("Label_soldier");
    self.Label_power_name =  Image_frame:getChildByName("Label_power_name");
    self.Label_command_name =  Image_frame:getChildByName("Label_command_name");
    self.Label_strategy_name =  Image_frame:getChildByName("Label_strategy_name");
    self.Label_atk_name =  Image_frame:getChildByName("Label_atk_name");
    self.Label_defense_name =  Image_frame:getChildByName("Label_defense_name");
    self.Label_forces_name =  Image_frame:getChildByName("Label_forces_name");
    self.Label_speed_name =  Image_frame:getChildByName("Label_speed_name");
    self.Label_skill_name =  Image_frame:getChildByName("Label_skill_name");
    self.Label_features_name    =  Image_frame:getChildByName("Label_features_name");
    self.Label_talent_name =  Image_frame:getChildByName("Label_talent_name");
    self.Label_power =  Image_frame:getChildByName("Label_power");
    self.Label_command =  Image_frame:getChildByName("Label_command");
    self.Label_strategy =  Image_frame:getChildByName("Label_strategy");
    self.Label_atk =  Image_frame:getChildByName("Label_atk");
    self.Label_defense =  Image_frame:getChildByName("Label_defense");
    self.Label_forces =  Image_frame:getChildByName("Label_forces");
    self.Label_speed =  Image_frame:getChildByName("Label_speed");
    self.AtlasLabel = Image_frame:getChildByName("AtlasLabel");
    self.featureslist = Image_frame:getChildByName("ListView_1");
    self.talentlist = Image_frame:getChildByName("ListView_2");
    self.skilllist = Image_frame:getChildByName("ListView_3");
    local Image_head = Image_frame:getChildByName("Image_hero");

    self.Image_stars = {};
    for i=1,5 do
        local Image_star = Image_frame:getChildByName(string.format("Image_star_%d",i))
        Image_star:setVisible(false);
        table.insert(self.Image_stars, Image_star)
    end

    self.Label_score:setText(MG_TEXT_COCOS("hero_info_ui_1"));
    self.Label_power_name:setText(MG_TEXT_COCOS("hero_info_ui_2"));
    self.Label_command_name:setText(MG_TEXT_COCOS("hero_info_ui_3"));
    self.Label_strategy_name:setText(MG_TEXT_COCOS("hero_info_ui_4"));
    self.Label_atk_name:setText(MG_TEXT_COCOS("hero_info_ui_5"));
    self.Label_defense_name:setText(MG_TEXT_COCOS("hero_info_ui_6"));
    self.Label_forces_name:setText(MG_TEXT_COCOS("hero_info_ui_7"));
    self.Label_speed_name:setText(MG_TEXT_COCOS("hero_info_ui_8"));
    self.Label_skill_name:setText(MG_TEXT_COCOS("hero_info_ui_9"));
    self.Label_features_name:setText(MG_TEXT_COCOS("hero_info_ui_10"));
    self.Label_talent_name:setText(MG_TEXT_COCOS("hero_info_ui_11"));


    self.heroHead = HeroHeadEx.create(self);
    self.heroHead:setTouchEnabled(false);
    self.heroHead:setAnchorPoint(cc.p(0.5, 0.5));
    self.heroHead:setPosition(Image_head:getPosition());
    Image_frame:addChild(self.heroHead,1);
    Image_head:setVisible(false);
    self:setVisible(false);
end

function heroInfo:setData(uid,gm)
    self.gm = gm;
    --@Input uid String 用户ID
    --gid Int 英雄ID
    local str = string.format("&uid=%s&gid=%d",uid,self.gm:getId());
    NetHandler:sendData(Post_getGeneralInfo, str);
end


function heroInfo:updata()
    self:setVisible(true);
    self.heroHead:setData(self.gm);
    self.Label_name:setText(self.gm:name());
    self.Label_power:setText(self.gm:getPower());
    self.Label_command:setText(self.gm:getCommand());
    self.Label_strategy:setText(self.gm:getStrategy());
    self.Label_atk:setText(self.gm:getAttack());
    self.Label_defense:setText(self.gm:getDefense());
    self.Label_forces:setText(self.gm:getForce());
    self.Label_speed:setText(self.gm:getSpeed());
    self.AtlasLabel:setStringValue(self.gm:getWarScore());
    local DBData = LUADB.select(string.format("select name from soldier_list where id=%d",self.gm:soldierid()), "name");
    self.Label_soldier:setText(DBData.info.name);
    for i=1,self.gm:getStar() do
        self.Image_stars[i]:setVisible(true);
    end
    local skills = self.gm:getSkill();
    local sql = "select name from skill_lv WHERE lv=1 and s_id in (";
    for i=1,#skills do
        sql=sql..skills[i]:value();
        if i<#skills then
            sql=sql..",";
        end
    end
    sql=sql..")";
    DBData = LUADB.selectlist(sql, "name");
    if DBData then
        local itemLay = ccui.Layout:create();
        local _width = 0;
        local _hight = 0;
        for i=1,#DBData.info do
            local nameLabel = cc.Label:createWithTTF(DBData.info[i].name, ttf_msyh, 22);
            nameLabel:setPosition(cc.p(nameLabel:getContentSize().width/2+(nameLabel:getContentSize().width+10)*(i-1), nameLabel:getContentSize().height/2));
            itemLay:addChild(nameLabel);
            _width=nameLabel:getContentSize().width;
            _hight=nameLabel:getContentSize().height;
        end
        itemLay:setSize(cc.size(_width*#DBData.info+10*(#DBData.info-1), _hight));
        self.skilllist:pushBackCustomItem(itemLay);
    end
    if self.features and #self.features then
        local itemLay = ccui.Layout:create();
        for i=1,#self.features do
            local wi = math.modf((i-1)/3);
            sql = "select f_name from features where f_id="..self.features[i].f_id;
            sql = sql..' and lv='..self.features[i].lv;
            local DBData1 = LUADB.select(sql, "f_name");
            local hi = i-wi*3-1;
            local nameLabel = cc.Label:createWithTTF(string.format("%s lv.%d",DBData1.info.f_name,self.features[i].lv), ttf_msyh, 22);
            nameLabel:setAnchorPoint(cc.p(0,0.5))
            nameLabel:setPosition(cc.p(173*wi, self.featureslist:getSize().height-nameLabel:getContentSize().height/2-35*hi));
            itemLay:addChild(nameLabel);
        end
        local t1 = math.modf((#self.features-1)/6);
        t1=t1+1;
        itemLay:setSize(cc.size(self.featureslist:getSize().width*t1, self.featureslist:getSize().height));
        self.featureslist:pushBackCustomItem(itemLay);
    end

end

function heroInfo:setStartPos(pos,w)
    local y = pos.x+w+self.Image_frame:getSize().width
    if  y<self.Panel_1:getSize().width then
        self.Image_frame:setPositionX(pos.x+self.Image_frame:getSize().width/2+w);
    else
        self.Image_frame:setPositionX(pos.x-self.Image_frame:getSize().width/2-w);
    end
end

function heroInfo:onButtonClick(sender, eventType)
    buttonClickScale(sender, eventType);
    if eventType == ccui.TouchEventType.ended then
        if sender == self.Panel_1 then
            if self.delegate and self.delegate.heroInfoClose then
                self.delegate:heroInfoClose();
            end
            self:removeFromParent();
        end
    end
end

function heroInfo:onReciveData(MsgID, NetData)
    print("playerInfo onReciveData MsgID:"..MsgID)
    
    if MsgID == Post_getGeneralInfo then
        local ackData = NetData
        if ackData.state == 1  then

            local str = cjson.encode(ackData.getgeneralinfo);
            self.gm:updata(str);
            self.features = ackData.getgeneralinfo.features;
            self:updata();
            

        else
            NetHandler:showFailedMessage(ackData)

            if self.delegate and self.delegate.heroInfoClose then
                self.delegate:heroInfoClose();
            end
            self:removeFromParent();
        end
    end
end

function heroInfo:pushAck()
    NetHandler:addAckCode(self,Post_getGeneralInfo);
end

function heroInfo:popAck()
    NetHandler:delAckCode(self,Post_getGeneralInfo);
end

function heroInfo:onEnter()
    self:pushAck();
end
 
function heroInfo:onExit()
    MGRCManager:releaseResources("heroInfo");
    self:popAck();
end


function heroInfo.create(delegate)
    local layer = heroInfo:new()
    layer.delegate = delegate
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

function heroInfo.showBox(delegate)
    local layer = heroInfo.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
