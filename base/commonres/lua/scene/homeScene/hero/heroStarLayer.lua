-----------------------将领升星界面------------------------
require "heroIntroduceLayer"
require "heroDetailsLayer"
require "Item"
require "heroComLayer"
require "heroStarFive"


heroStarLayer = class("heroStarLayer", MGLayer)

function heroStarLayer:ctor()
    self:init();
end

function heroStarLayer:init()
    local pWidget = MGRCManager:widgetFromJsonFile("heroStarLayer","hero_star_ui_1.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);--设置描边或者阴影

    self.heroComLayer = heroComLayer.create(self);
    self:addChild(self.heroComLayer,-1);
    
    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:setAnchorPoint(cc.p(0.5, 0.5));
    CommonMethod:setFullBgScale(self.Panel_1);

    local Panel_2 = pWidget:getChildByName("Panel_2");
    local Panel_right = Panel_2:getChildByName("Panel_right");

    local Label_level = Panel_right:getChildByName("Label_level");
    Label_level:setText(MG_TEXT_COCOS("hero_star_ui_1"));
    local Label_level_lock = Panel_right:getChildByName("Label_level_lock");
    Label_level_lock:setText(MG_TEXT_COCOS("hero_star_ui_2"));
    local Label_att= Panel_right:getChildByName("Label_att");
    Label_att:setText(MG_TEXT_COCOS("hero_star_ui_3"));
    local Label_skill = Panel_right:getChildByName("Label_skill");
    Label_skill:setText(MG_TEXT_COCOS("hero_star_ui_4"));
    local Label_need = Panel_right:getChildByName("Label_need");
    Label_need:setText(MG_TEXT_COCOS("hero_star_ui_5"));


    local Image_two_box = Panel_right:getChildByName("Image_two_box");
    local Image_big_bg = Image_two_box:getChildByName("Image_big_bg");
    self.progressbig = cc.ProgressTimer:create(cc.Sprite:createWithSpriteFrameName("hero_star_big_pro.png"));
    self.progressbig:setType(cc.PROGRESS_TIMER_TYPE_BAR);
    self.progressbig:setBarChangeRate(cc.p(1,0));
    self.progressbig:setMidpoint(cc.p(0,0));
    self.progressbig:setPosition(cc.p(Image_big_bg:getContentSize().width/2, Image_big_bg:getContentSize().height/2));
    self.progressbig:setAnchorPoint(cc.p(0.5,0.5));
    Image_big_bg:addChild(self.progressbig,1);
    self.bigstars = {};
    for i=1,5 do
        local Image_star = Image_big_bg:getChildByName("Image_star_"..i);
        table.insert(self.bigstars,Image_star);
    end
    self.Image_big_triangle = Panel_right:getChildByName("Image_big_triangle");

    local Image_three_box = Panel_right:getChildByName("Image_three_box");
    local Image_lit_bg = Image_three_box:getChildByName("Image_lit_bg");
    self.progresslit = cc.ProgressTimer:create(cc.Sprite:createWithSpriteFrameName("hero_star_lit_pro.png"));
    self.progresslit:setType(cc.PROGRESS_TIMER_TYPE_BAR);
    self.progresslit:setBarChangeRate(cc.p(1,0));
    self.progresslit:setMidpoint(cc.p(0,0));
    self.progresslit:setPosition(cc.p(Image_lit_bg:getContentSize().width/2, Image_lit_bg:getContentSize().height/2));
    self.progresslit:setAnchorPoint(cc.p(0.5,0.5));
    Image_lit_bg:addChild(self.progresslit,1);
    self.litstars = {};
    for i=1,5 do
        local Image_star = Panel_right:getChildByName("Image_star_"..i);
        Image_star:addTouchEventListener(handler(self,self.onButtonClick));
        table.insert(self.litstars,Image_star);
    end
    self.oldHeadProgram = self.litstars[1]:getSprit():getShaderProgram();
    self.Image_lit_triangle = Panel_right:getChildByName("Image_lit_triangle");


    self.Button_star= Panel_right:getChildByName("Button_star");--一键装备按钮
    self.Button_star:addTouchEventListener(handler(self,self.onButtonClick));
    local Label_btn = self.Button_star:getChildByName("Label_btn");
    Label_btn:setText(MG_TEXT_COCOS("hero_star_ui_6"));

    self.Image_skill= Panel_right:getChildByName("Image_skill");

    self.Label_skill_level_0= Panel_right:getChildByName("Label_skill_level_0");
    self.Label_skill_level_1= Panel_right:getChildByName("Label_skill_level_1");

    self.list= Panel_right:getChildByName("ListView");

    self.Label_att_num= Panel_right:getChildByName("Label_att_num");
end

function heroStarLayer:setData(gm)
    self.gm = gm;
    self:upData(false);
end

function heroStarLayer:upData(isani)
    self.heroComLayer:setHero(self.gm);

    for i=1,#self.bigstars do
        if i<=self.gm:getStar() then
            self.bigstars[i]:loadTexture("com_big_star.png",ccui.TextureResType.plistType);
        else
            self.bigstars[i]:loadTexture("hero_star_big_cao.png",ccui.TextureResType.plistType);
        end
    end
    if self.gm:getStar()==0 then
        self.progressbig:setPercentage(0);
    else
        self.progressbig:setPercentage((self.gm:getStar()-1)*100.0/4);
    end

    local bigstar = self.gm:getStar();
    local litstar = self.gm:getStarLv();
    local starindex = 0;
    local sql = ""
    local dbinfo = nil;
    local showtype = (bigstar==1);
    if isani then
        showtype = (bigstar==1 or (bigstar==2 and litstar ==0));
    end
    if  showtype then
        self.Image_big_triangle:setPositionX(266);
        sql = string.format("select star,max_lv,lv,skill_lv,need,effect from general_star where g_id=%d and star=1",self.gm:getId());
        DBData = LUADB.selectlist(sql, "star:max_lv:lv:skill_lv:need:effect");
        dbinfo = DBData.info;

        sql = string.format("select star,max_lv,lv,skill_lv,need,effect from general_star where g_id=%d and star=2 and lv=0",self.gm:getId());
        DBData = LUADB.select(sql, "star:max_lv:lv:skill_lv:need:effect");
        table.insert( dbinfo, DBData.info );

        for i=1,#self.litstars do
            if i==1 then
                self.litstars[i]:setVisible(true);
                self.litstars[i]:setPositionX(106);
                self.litstars[i]:loadTexture("hero_star_lit.png",ccui.TextureResType.plistType);
                self.litstars[i]:setTag(2);
                self.litstars[i]:setEnabled(true);
            elseif i==2 then
                self.litstars[i]:setVisible(true);
                self.litstars[i]:setPositionX(440);
                self.litstars[i]:loadTexture("com_big_star.png",ccui.TextureResType.plistType);
                self.litstars[i]:setTag(3);
                self.litstars[i]:setEnabled(true);
            else
                self.litstars[i]:setVisible(false);
                self.litstars[i]:setEnabled(false);
            end
        end

        if bigstar ==1 and litstar==0 then
            self.progresslit:setPercentage(0);
            self.litstars[1]:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
            self.litstars[2]:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
            starindex = 1;
        elseif bigstar ==1 and litstar==1 then
            self.progresslit:setPercentage(100);
            self.litstars[1]:getSprit():setShaderProgram(self.oldHeadProgram);
            self.litstars[2]:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
            starindex = 2;
        else
            self.progresslit:setPercentage(100);
            self.litstars[1]:getSprit():setShaderProgram(self.oldHeadProgram);
            self.litstars[2]:getSprit():setShaderProgram(self.oldHeadProgram);
            starindex = 2;
            self:showStarFive(starindex);
        end

        self.dbinfo = dbinfo;
        self:showbigstar(starindex);
        return;
    end
    
    showtype = (bigstar==2);
    if isani then
        showtype = (bigstar==2 or (bigstar==3 and litstar ==0)) ;
    end
    if showtype then
        self.Image_big_triangle:setPositionX(330);
        sql = string.format("select star,max_lv,lv,skill_lv,need,effect from general_star where g_id=%d and star=2",self.gm:getId());
        DBData = LUADB.selectlist(sql, "star:max_lv:lv:skill_lv:need:effect");
        dbinfo = DBData.info;

        sql = string.format("select star,max_lv,lv,skill_lv,need,effect from general_star where g_id=%d and star=3 and lv=0",self.gm:getId());
        DBData = LUADB.select(sql, "star:max_lv:lv:skill_lv:need:effect");
        table.insert( dbinfo, DBData.info );
        litstarnum = #dbinfo;

        for i=1,#self.litstars do
            if i==1 then
                self.litstars[i]:setVisible(true);
                self.litstars[i]:setPositionX(106);
                self.litstars[i]:loadTexture("hero_star_lit.png",ccui.TextureResType.plistType);
                self.litstars[i]:setTag(2);
                self.litstars[i]:setEnabled(true);
            elseif i==2 then
                self.litstars[i]:setVisible(true);
                self.litstars[i]:setPositionX(270);
                self.litstars[i]:loadTexture("hero_star_lit.png",ccui.TextureResType.plistType);
                self.litstars[i]:setTag(3);
                self.litstars[i]:setEnabled(true);
            elseif i==3 then
                self.litstars[i]:setVisible(true);
                self.litstars[i]:setPositionX(440);
                self.litstars[i]:loadTexture("com_big_star.png",ccui.TextureResType.plistType);
                self.litstars[i]:setTag(4);
                self.litstars[i]:setEnabled(true);
            else
                self.litstars[i]:setVisible(false);
                self.litstars[i]:setEnabled(false);
            end
        end

        if bigstar ==2 and litstar==0 then
            self.progresslit:setPercentage(0);
            self.litstars[1]:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
            self.litstars[2]:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
            self.litstars[3]:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
            starindex = 1;
        elseif bigstar ==2 and litstar==1 then
            self.progresslit:setPercentage(50);
            self.litstars[1]:getSprit():setShaderProgram(self.oldHeadProgram);
            self.litstars[2]:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
            self.litstars[3]:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
            starindex = 2;
        elseif bigstar ==2 and litstar==2 then
            self.progresslit:setPercentage(100);
            self.litstars[1]:getSprit():setShaderProgram(self.oldHeadProgram);
            self.litstars[2]:getSprit():setShaderProgram(self.oldHeadProgram);
            self.litstars[3]:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
            starindex = 3;
        elseif bigstar ==3 and litstar==0 then
            self.progresslit:setPercentage(100);
            self.litstars[1]:getSprit():setShaderProgram(self.oldHeadProgram);
            self.litstars[2]:getSprit():setShaderProgram(self.oldHeadProgram);
            self.litstars[3]:getSprit():setShaderProgram(self.oldHeadProgram);
            starindex = 3;
            self:showStarFive(starindex);
        end
        self.dbinfo = dbinfo;
        self:showbigstar(starindex);
        return;
    end

    showtype = (bigstar==3);
    if isani then
        showtype = (bigstar==3 or (bigstar==4 and litstar ==0)) ;
    end
    if showtype then
        self.Image_big_triangle:setPositionX(396);
        sql = string.format("select star,max_lv,lv,skill_lv,need,effect from general_star where g_id=%d and star=3",self.gm:getId());
        DBData = LUADB.selectlist(sql, "star:max_lv:lv:skill_lv:need:effect");
        dbinfo = DBData.info;

        sql = string.format("select star,max_lv,lv,skill_lv,need,effect from general_star where g_id=%d and star=4 and lv=0",self.gm:getId());
        DBData = LUADB.select(sql, "star:max_lv:lv:skill_lv:need:effect");
        table.insert( dbinfo, DBData.info );
        litstarnum = #dbinfo;

        for i=1,#self.litstars do
            if i==1 then
                self.litstars[i]:setVisible(true);
                self.litstars[i]:setPositionX(106);
                self.litstars[i]:loadTexture("hero_star_lit.png",ccui.TextureResType.plistType);
                self.litstars[i]:setTag(2);
                self.litstars[i]:setEnabled(true);
            elseif i==2 then
                self.litstars[i]:setVisible(true);
                self.litstars[i]:setPositionX(217.5);
                self.litstars[i]:loadTexture("hero_star_lit.png",ccui.TextureResType.plistType);
                self.litstars[i]:setTag(3);
                self.litstars[i]:setEnabled(true);
            elseif i==3 then
                self.litstars[i]:setVisible(true);
                self.litstars[i]:setPositionX(328.5);
                self.litstars[i]:loadTexture("hero_star_lit.png",ccui.TextureResType.plistType);
                self.litstars[i]:setTag(4);
                self.litstars[i]:setEnabled(true);
            elseif i==4 then
                self.litstars[i]:setVisible(true);
                self.litstars[i]:setPositionX(440);
                self.litstars[i]:loadTexture("com_big_star.png",ccui.TextureResType.plistType);
                self.litstars[i]:setTag(5);
                self.litstars[i]:setEnabled(true);
            else
                self.litstars[i]:setVisible(false);
                self.litstars[i]:setEnabled(false);
            end
        end

        if bigstar ==3 and litstar==0 then
            self.progresslit:setPercentage(0);
            self.litstars[1]:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
            self.litstars[2]:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
            self.litstars[3]:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
            self.litstars[4]:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
            starindex = 1;
        elseif bigstar ==3 and litstar==1 then
            self.progresslit:setPercentage(33.5);
            self.litstars[1]:getSprit():setShaderProgram(self.oldHeadProgram);
            self.litstars[2]:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
            self.litstars[3]:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
            self.litstars[4]:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
            starindex = 2;
        elseif bigstar ==3 and litstar==2 then
            self.progresslit:setPercentage(67);
            self.litstars[1]:getSprit():setShaderProgram(self.oldHeadProgram);
            self.litstars[2]:getSprit():setShaderProgram(self.oldHeadProgram);
            self.litstars[3]:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
            self.litstars[4]:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
            starindex = 3;
        elseif bigstar ==3 and litstar==3 then
            self.progresslit:setPercentage(100);
            self.litstars[1]:getSprit():setShaderProgram(self.oldHeadProgram);
            self.litstars[2]:getSprit():setShaderProgram(self.oldHeadProgram);
            self.litstars[3]:getSprit():setShaderProgram(self.oldHeadProgram);
            self.litstars[4]:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
            starindex = 4;
        elseif bigstar ==4 and litstar==0 then
            self.progresslit:setPercentage(100);
            self.litstars[1]:getSprit():setShaderProgram(self.oldHeadProgram);
            self.litstars[2]:getSprit():setShaderProgram(self.oldHeadProgram);
            self.litstars[3]:getSprit():setShaderProgram(self.oldHeadProgram);
            self.litstars[4]:getSprit():setShaderProgram(self.oldHeadProgram);
            starindex = 4;
            self:showStarFive(starindex);
        end

        self.dbinfo = dbinfo;
        self:showbigstar(starindex);
        return;
    end

    if bigstar==4 or (bigstar==5 and litstar ==0) then
        self.Image_big_triangle:setPositionX(461);
        sql = string.format("select star,max_lv,lv,skill_lv,need,effect from general_star where g_id=%d and star=4",self.gm:getId());
        DBData = LUADB.selectlist(sql, "star:max_lv:lv:skill_lv:need:effect");
        dbinfo = DBData.info;

        sql = string.format("select star,max_lv,lv,skill_lv,need,effect from general_star where g_id=%d and star=5 and lv=0",self.gm:getId());
        DBData = LUADB.select(sql, "star:max_lv:lv:skill_lv:need:effect");
        table.insert( dbinfo, DBData.info );
        litstarnum = #dbinfo;

        for i=1,5 do
            self.litstars[i]:setVisible(true);
            self.litstars[i]:setEnabled(true);
            if i==1 then
                self.litstars[i]:setPositionX(106);
                self.litstars[i]:loadTexture("hero_star_lit.png",ccui.TextureResType.plistType);
                self.litstars[i]:setTag(2);
            elseif i==2 then
                self.litstars[i]:setPositionX(188);
                self.litstars[i]:loadTexture("hero_star_lit.png",ccui.TextureResType.plistType);
                self.litstars[i]:setTag(3);
            elseif i==3 then
                self.litstars[i]:setPositionX(270);
                self.litstars[i]:loadTexture("hero_star_lit.png",ccui.TextureResType.plistType);
                self.litstars[i]:setTag(4);
            elseif i==4 then
                self.litstars[i]:setPositionX(356);
                self.litstars[i]:loadTexture("hero_star_lit.png",ccui.TextureResType.plistType);
                self.litstars[i]:setTag(5);
            else
                self.litstars[i]:setPositionX(440);
                self.litstars[i]:loadTexture("com_big_star.png",ccui.TextureResType.plistType);
                self.litstars[i]:setTag(6);
            end
        end

        if bigstar ==4 and litstar==0 then
            self.progresslit:setPercentage(0);
            self.litstars[1]:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
            self.litstars[2]:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
            self.litstars[3]:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
            self.litstars[4]:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
            self.litstars[5]:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
            starindex = 1;
        elseif bigstar ==4 and litstar==1 then
            self.progresslit:setPercentage(25);
            self.litstars[1]:getSprit():setShaderProgram(self.oldHeadProgram);
            self.litstars[2]:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
            self.litstars[3]:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
            self.litstars[4]:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
            self.litstars[5]:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
            starindex = 2;
        elseif bigstar ==4 and litstar==2 then
            self.progresslit:setPercentage(50);
            self.litstars[1]:getSprit():setShaderProgram(self.oldHeadProgram);
            self.litstars[2]:getSprit():setShaderProgram(self.oldHeadProgram);
            self.litstars[3]:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
            self.litstars[4]:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
            self.litstars[5]:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
            starindex = 3;
        elseif bigstar ==4 and litstar==3 then
            self.progresslit:setPercentage(75);
            self.litstars[1]:getSprit():setShaderProgram(self.oldHeadProgram);
            self.litstars[2]:getSprit():setShaderProgram(self.oldHeadProgram);
            self.litstars[3]:getSprit():setShaderProgram(self.oldHeadProgram);
            self.litstars[4]:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
            self.litstars[5]:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
            starindex = 4;
        elseif bigstar ==4 and litstar==4 then
            self.progresslit:setPercentage(100);
            self.litstars[1]:getSprit():setShaderProgram(self.oldHeadProgram);
            self.litstars[2]:getSprit():setShaderProgram(self.oldHeadProgram);
            self.litstars[3]:getSprit():setShaderProgram(self.oldHeadProgram);
            self.litstars[4]:getSprit():setShaderProgram(self.oldHeadProgram);
            self.litstars[5]:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
            starindex = 5;
        elseif bigstar ==5 and litstar==0 then
            self.progresslit:setPercentage(100);
            self.litstars[1]:getSprit():setShaderProgram(self.oldHeadProgram);
            self.litstars[2]:getSprit():setShaderProgram(self.oldHeadProgram);
            self.litstars[3]:getSprit():setShaderProgram(self.oldHeadProgram);
            self.litstars[4]:getSprit():setShaderProgram(self.oldHeadProgram);
            self.litstars[5]:getSprit():setShaderProgram(self.oldHeadProgram);
            starindex = 5;
            if isani then
                self:showStarFive(starindex);
            end
        end
        self.dbinfo = dbinfo;
        self:showbigstar(starindex);
    end
end

function heroStarLayer:StarFiveOver()
    self:upData(false);
end

function heroStarLayer:Share()
    self:upData(false);
end

function heroStarLayer:showStarFive(index)
    local i = self.litstars[index]:getTag();
    local attList = {}

    local  str = self.dbinfo[i].effect;
    local str_list = spliteStr(str,'|'); 
    local  effects = "";
    for i=1,#str_list do
        local str_list1 = spliteStr(str_list[i],':');  
        sql = "select name from effect where id="..str_list1[1];
        local DBData1 = LUADB.select(sql, "name");
        local att = {}
        att.name = DBData1.info.name;
        att.add =  tonumber(str_list1[2]);
        table.insert(attList, att)
    end

    local heroStarFive = heroStarFive.create(self);
    heroStarFive:setData(attList,self.dbinfo[i-1].skill_lv,self.dbinfo[i].skill_lv,self.gm);
    cc.Director:getInstance():getRunningScene():addChild(heroStarFive,ZORDER_MAX);
end


function heroStarLayer:showbigstar(index)

    self.Image_lit_triangle:setPositionX(self.litstars[index]:getPositionX());
    local i = self.litstars[index]:getTag();

    self.Label_skill_level_0:setText(string.format("Lv.%s",self.dbinfo[i-1].skill_lv));
    self.Label_skill_level_1:setText(string.format("Lv.%s",self.dbinfo[i].skill_lv));

    local  str = self.dbinfo[i].effect;
    local str_list = spliteStr(str,'|');  
    local  effects = "";
    for i=1,#str_list do
        local str_list1 = spliteStr(str_list[i],':');  
        sql = "select name from effect where id="..str_list1[1];
        local DBData1 = LUADB.select(sql, "name");
        if DBData1 then
            if i == 1 then
                effects = effects..DBData1.info.name.."+"..str_list1[2];
            else
                effects = effects.."  "..DBData1.info.name.."+"..str_list1[2];
            end
        end
    end

    self.list:removeAllItems();
    str = self.dbinfo[i].need;
    str_list = spliteStr(str,'|');  
    for i=1,#str_list do
        local str_list1 = spliteStr(str_list[i],':');  
        local gm =  RESOURCE:getResModelByItemId(tonumber(str_list1[2]));
        if gm ==nil then
            gm = ResourceModel:create(tonumber(str_list1[2]));
        end
        local item = Item.create();
        item:setData(gm);
        item:setNeedNum(tonumber(str_list1[3]));
        self.list:pushBackCustomItem(item);
    end

    self.Label_att_num:setText(effects);
    local skills = self.gm:getSkill();

    sql = string.format("select icon from skill_lv where s_id=%d and lv=%s",skills[1]:value(),self.dbinfo[i].skill_lv);
    DBData = LUADB.select(sql, "icon");
    MGRCManager:cacheResource("heroStarLayer",DBData.info.icon..".png");
    self.Image_skill:loadTexture(DBData.info.icon..".png",ccui.TextureResType.plistType);
end   


function heroStarLayer:onButtonClick(sender, eventType)
    if eventType == ccui.TouchEventType.began then
        local sc = cc.ScaleTo:create(0.1, 1.1)
        sender:runAction(cc.EaseOut:create(sc ,2))
    end
    if eventType == ccui.TouchEventType.canceled then
        local sc = cc.ScaleTo:create(0.1, 1)
        sender:runAction(sc)
    end
    if eventType == ccui.TouchEventType.ended then
        local sc = cc.ScaleTo:create(0.1, 1)
        sender:runAction(sc)
        if sender == self.Button_star then
            self:sendReq();
        else
            for i=1,#self.litstars do
                if sender == self.litstars[i] then
                    self:showbigstar(i);
                    return;
                end
            end
        end
    end
end

function heroStarLayer:onReciveData(MsgID, NetData)
    print("heroStarLayer onReciveData MsgID:"..MsgID)
    
    if MsgID == Post_addStar then
        local ackData = NetData
        if ackData.state == 1 then
            self:upData(true);
        else
            NetHandler:showFailedMessage(ackData)
        end
    end
    
end

function heroStarLayer:sendReq()
   --@Summary  将领增加星级
   --@Input    g_id Int 将领ID
    local str = string.format("&g_id=%d",self.gm:getId());
    NetHandler:sendData(Post_addStar, str);
end

function heroStarLayer:pushAck()
    NetHandler:addAckCode(self,Post_addStar);
end

function heroStarLayer:popAck()
    NetHandler:delAckCode(self,Post_addStar);
end

function heroStarLayer:onEnter()
    self:pushAck();
end

function heroStarLayer:onExit()
    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
    end
    MGRCManager:releaseResources("heroStarLayer");
    self:popAck();
end

function heroStarLayer.create(delegate,type)
    local layer = heroStarLayer:new()
    layer.delegate = delegate
    layer.type = type
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
