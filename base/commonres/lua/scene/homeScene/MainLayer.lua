------------------------主城界面信息-------------------------
require "chatLayer"
require "chatInstance"
require "shopLayer"
require "getItem"

MainLayer = class("MainLayer", MGLayer)

function MainLayer:ctor(delegate,type)
    self.delegate = delegate;
    self.type = type;

    self.isUpdaUnion = false;--是否刷新公会按钮
    self.timer = CCTimer:new();
    self.timer:startTimer(1,handler(self,self.updateTime),false);--每1毫秒回调一次
    
    local pWidget = MGRCManager:widgetFromJsonFile("MainLayer","main_ui_1.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);

    local Panel_1 = pWidget:getChildByName("Panel_1");
    CommonMethod:setVisibleSize(Panel_1);

    local panelRight=Panel_1:getChildByName("Panel_right");
    self.Image_sieve1=panelRight:getChildByName("Image_bg1");--君王之路跳转
    self.Image_sieve1:addTouchEventListener(handler(self,self.onTouchClick));
    self.Button_sieve1 = self.Image_sieve1:getChildByName("Button_sieve1");--君王之路
    self.Button_sieve1:addTouchEventListener(handler(self,self.onButtonClick));

    self.descLabel = cc.Label:createWithTTF("",ttf_msyh,16);
    self.descLabel:setAlignment(cc.TEXT_ALIGNMENT_CENTER,cc.VERTICAL_TEXT_ALIGNMENT_TOP);
    self.descLabel:setDimensions(150, 0);
    self.descLabel:setColor(cc.c3b(255, 216, 0));
    self.descLabel:enableOutline(cc.c4b(  81,   48,   0, 255),1);
    self.descLabel:setPosition(cc.p(self.Image_sieve1:getContentSize().width/2-40,
        self.Image_sieve1:getContentSize().height/2));
    self.Image_sieve1:addChild(self.descLabel);

    local Panel_left = Panel_1:getChildByName("Panel_left");
    local Panel_2 = Panel_left:getChildByName("Panel_2");

    self.ProgressBar = Panel_2:getChildByName("ProgressBar");--进度条
    self.Label_level = Panel_2:getChildByName("Label_level");--玩家等级
    self.Label_name = Panel_2:getChildByName("Label_name");--玩家名

    self.ListView = Panel_2:getChildByName("ListView");
    local Panel_head = Panel_2:getChildByName("Panel_head");
    require "userHead";
    self.heroHead = userHead.create(self);--玩家头像
    self.heroHead:setAnchorPoint(cc.p(0.5, 0.5));
    self.heroHead:setPosition(cc.p(Panel_head:getContentSize().width/2,Panel_head:getContentSize().height/2));
    Panel_head:addChild(self.heroHead,2);

    self.Button_rec = Panel_left:getChildByName("Button_rec");--充值按钮
    self.Button_rec:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_act = Panel_left:getChildByName("Button_act");--活动按钮
    self.Button_act:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_chat = Panel_left:getChildByName("Button_chat");--聊天按钮
    self.Button_chat:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_pre = Panel_left:getChildByName("Button_pre");--特惠按钮
    self.Button_pre:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_gift = Panel_left:getChildByName("Button_gift");--礼包按钮
    self.Button_gift:addTouchEventListener(handler(self,self.onButtonClick));

    self.Image_sieve = Panel_left:getChildByName("Image_bg");--筛子迷宫按钮
    self.Button_sieve= self.Image_sieve:getChildByName("Button_sieve");--筛子迷宫按钮
    self.Button_sieve:addTouchEventListener(handler(self,self.onButtonClick));

    self.label2 = cc.Label:createWithTTF(MG_TEXT("MainLayer_5"),ttf_msyh,24);
    self.label2:setColor(cc.c3b(255, 215, 0));
    self.label2:setPosition(cc.p(150,60));
    self.Image_sieve:addChild(self.label2);

    local tipLabel2 = cc.Label:createWithTTF(MG_TEXT("MainLayer_1"),ttf_msyh,26);
    tipLabel2:setPosition(cc.p(150,33));
    self.Image_sieve:addChild(tipLabel2);
    tipLabel2:enableOutline(cc.c4b(80, 50, 0,255),2);


    local Panel_down = Panel_1:getChildByName("Panel_down");
    self.Image_bottom = Panel_down:getChildByName("Image_bottom");
    self.Image_bottom:setVisible(false);

    self.Button_open = self.Image_bottom:getChildByName("Button_open");--收缩按钮
    self.Button_open:addTouchEventListener(handler(self,self.onButtonClick));
    self.Button_open:setPositionX(4);

    self.Button_city = Panel_down:getChildByName("Button_city");--主城按钮
    self.Button_city:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_war = Panel_down:getChildByName("Button_war");--主线按钮
    self.Button_war:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_legion = Panel_down:getChildByName("Button_legion");--军团按钮
    self.Button_legion:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_warehouse = Panel_down:getChildByName("Button_warehouse");--仓库按钮
    self.Button_warehouse:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_shop = Panel_down:getChildByName("Button_shop");--商店按钮
    self.Button_shop:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_military = Panel_down:getChildByName("Button_military");--军事按钮
    self.Button_military:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_keji = Panel_down:getChildByName("Button_keji");--科技按钮
    self.Button_keji:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_hero = Panel_down:getChildByName("Button_hero");--英雄按钮
    self.Button_hero:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_task = Panel_down:getChildByName("Button_task");--任务按钮
    self.Button_task:addTouchEventListener(handler(self,self.onButtonClick));

    local Panel_up = Panel_1:getChildByName("Panel_up");
    local Panel_mas = Panel_up:getChildByName("Panel_mas");
    self.Label_mas = Panel_mas:getChildByName("Label_mas");--砖石数量

    self.Button_add1 = Panel_mas:getChildByName("Button_add1");--砖石添加按钮
    self.Button_add1:addTouchEventListener(handler(self,self.onButtonClick));

    local Panel_gold = Panel_up:getChildByName("Panel_gold");
    self.Label_gold = Panel_gold:getChildByName("Label_gold");--金币数量

    self.Button_add2 = Panel_gold:getChildByName("Button_add2");--金币添加按钮
    self.Button_add2:addTouchEventListener(handler(self,self.onButtonClick));

    local Panel_action = Panel_up:getChildByName("Panel_action");
    self.Label_action = Panel_action:getChildByName("Label_action");--体力数量

    self.Button_add3 = Panel_action:getChildByName("Button_add3");--体力添加按钮
    self.Button_add3:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_mail = Panel_up:getChildByName("Button_mail");--邮件按钮
    self.Button_mail:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_rank = Panel_up:getChildByName("Button_rank");--排行按钮
    self.Button_rank:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_pack = Panel_up:getChildByName("Button_pack");--争霸按钮
    self.Button_pack:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_event = Panel_up:getChildByName("Button_event");--事件按钮
    self.Button_event:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_country = Panel_up:getChildByName("Button_country");--领土按钮
    self.Button_country:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_show = Panel_left:getChildByName("Button_show");--显示战报
    self.Button_show:addTouchEventListener(handler(self,self.onButtonClick));
    
    self.Button_upload = Panel_left:getChildByName("Button_upload");--上传战报
    self.Button_upload:addTouchEventListener(handler(self,self.onButtonClick));

    local Panel_chat = Panel_1:getChildByName("Panel_chat");

    self.ListView_chat = Panel_chat:getChildByName("ListView_chat");
    self.ListView_chat:setScrollBarVisible(false);
    local chatInstance = chatInstance:createInstance();
    self.ListView_chat:removeAllItems();
    self.ListView_chat:pushBackCustomItem(chatInstance);

    self.Panel_chatBtn = Panel_chat:getChildByName("Panel_chatBtn");--聊天
    self.Panel_chatBtn:addTouchEventListener(handler(self,self.onButtonClick));

    self.allBtns={
        [14]=self.Button_rec,
        [15]=self.Button_chat,
        [16]=self.Button_pre,
        [17]=self.Button_gift,
        [18]=self.Button_act,
        [19]=self.Button_country,
        [20]=self.Button_event,
        [21]=self.Button_pack,
        [22]=self.Button_rank,
        [23]=self.Button_mail,
        [24]=self.Image_sieve1,
        [25]=self.Button_task,
        [26]=self.Button_hero,
        [27]=self.Button_keji,
        [28]=self.Button_military,
        [29]=self.Button_shop,
        [30]=self.Button_warehouse,
        [31]=self.Button_legion,
        [32]=self.Button_war
    };

    for k,v in pairs(self.allBtns) do
            v:setEnabled(false);
    end

    self.getusermain=nil;
    self.plotListLayer=nil;
    self.plotLayer=nil;
    self.invadeLayer=nil;
    self.mysteryStoreLayer=nil;
    self.plotListIsOpen=false;
    self.uwIsOpen=false;
    self.uwListLayer=nil;
    self.isSpread = true;--true展开状态
    self.btnsDataMap={};
    self.allBtnsData={};
    self.allShowBtns={};
    self.allBtnsPos={};
    self.schedulerID=0;
    self.allBtnsPos[1]={cc.p(50,429),cc.p(50,347),cc.p(50,265),cc.p(50,183),cc.p(142,429),cc.p(142,347),cc.p(142,265),cc.p(142,183)};
    self.allBtnsPos[2]={cc.p(57,58),cc.p(167,58),cc.p(277,58),cc.p(387,58),cc.p(497,58)};
    self.allBtnsPos[3]={cc.p(73,108)};
    self.allBtnsPos[4]={cc.p(133,59),cc.p(233,59),cc.p(333,59),cc.p(433,59),cc.p(533,59),cc.p(633,59),cc.p(733,59),cc.p(833,59)};

    self.value1 = tonumber(LUADB.readConfig(196));--聊天系统开启等级
    self.value2 = tonumber(LUADB.readConfig(88));--公会系统开启等级
    self:readSql();
end

function MainLayer:readSql()
    local DBDataList = LUADB.selectlist("select id,value from config", "id:value");
    for i=1,#DBDataList.info do
        if tonumber(DBDataList.info[i].id) == 3 then
            ME:setMaxAction(tonumber(DBDataList.info[i].value));
        elseif tonumber(DBDataList.info[i].id) == 12 then
            ME:setMaxCoin(tonumber(DBDataList.info[i].value));
        elseif tonumber(DBDataList.info[i].id) == 14 then
            ME:setMaxGold(tonumber(DBDataList.info[i].value));
        elseif tonumber(DBDataList.info[i].id) == 16 then
            ME:setMaxUserLv(tonumber(DBDataList.info[i].value));
        elseif tonumber(DBDataList.info[i].id) == 17 then
            ME:setMaxStar(tonumber(DBDataList.info[i].value));
        end
    end
end

function MainLayer:setData(data)
    self.data = data;
    self.Label_level:setText(string.format("Lv.%d",data.lv));
    self.Label_name:setText(unicode_to_utf8(data.name));
    
    local num = tonumber(data.action);
    local num2 = 81;
    local str1 = string.format("%d",num);
    if num >= 100000 then
        num = num/10000;
        str1 = string.format(MG_TEXT("WAN"),num);
    end

    local sql = string.format("select * from user_lv where lv=%d", ME:Lv());
    local DBData = LUADB.select(sql, "max_action");
    if DBData then
        num2 = DBData.info.max_action;
    end
    self.Label_action:setText(string.format("%s/%d",str1,num2));
    self:updataMoney();

    local gm = GENERAL:getGeneralModel(ME:getHeadId());
    if gm then
        self.heroHead:setData(gm)
    end

    if self.type and self.type == SCENEINFO.MAP_SCENE then
        self.Button_city:loadTextureNormal("main_button_city.png", ccui.TextureResType.plistType);
        self.Button_city:loadTexturePressed("main_button_city.png", ccui.TextureResType.plistType);
        self.Button_city:loadTextureDisabled("main_button_city.png", ccui.TextureResType.plistType);
    elseif self.type and self.type == SCENEINFO.MAIN_SCENE then
        self.Button_city:loadTextureNormal("main_button_mapwar.png", ccui.TextureResType.plistType);
        self.Button_city:loadTexturePressed("main_button_mapwar.png", ccui.TextureResType.plistType);
        self.Button_city:loadTextureDisabled("main_button_mapwar.png", ccui.TextureResType.plistType);
    end

    self:initBtns(tonumber(data.lv));
    self:rollAction();
    self:showLastLayer();--显示跳转界面

    if self.isUpdaUnion and ME:Lv() < self.value2 then
        MGMessageTip:showFailedMessage(string.format(MG_TEXT("guildMainLayer_2"),self.value2));
    else
        if self.isUpdaUnion == true then--进入公会判断是否创建公会还是进入公会
            chatInstance:dispose();
            chatLayer:dispose();
            if tonumber(self.getusermain.union_id) == 0 then--未加入公会
                require "guildLayer";
                local guildLayer = guildLayer.showBox(self,self.type);
            else
                self:createGuildMainLayer();
            end
            self.isUpdaUnion = false;
        end
    end
end

function MainLayer:setKingRoadData(data)
    self.kingRoadData = data;

    if nil == self.kingRoadData or 0 == #self.kingRoadData then
        return;
    end

    local dbData=LUADB.select("select type,des,max_num from achievement where id="..tonumber(data.a_id), "type:des:max_num");
    if dbData then
        local str = "";
        local num = 0;
        local totalNum = 0;
        local str_list = spliteStr(self.kingRoadData.completion_status,':');
        if tonumber(dbData.info.type) == 1 then--特殊的
            if tonumber(self.kingRoadData.status) == 1 then
                num = tonumber(dbData.info.max_num);
                totalNum = tonumber(dbData.info.max_num);
            end
        else
            num = tonumber(str_list[1]);
            totalNum = tonumber(str_list[2]);
        end
        str = dbData.info.des..string.format("(%d/%d)",num,totalNum);
        self.descLabel:setString(str);
    end
end

function MainLayer:initBtns(lv)
        local dbDataList=LUADB.selectlist("select * from function where area_id>0 and area_id<5", "id:name:lvup_pic:open_lv:area_id:show_order:pos:parent_id:is_show");
        local temArr={};
        for k,v in pairs(dbDataList.info) do--按钮按类型分类排序
                v.id=tonumber(v.id);
                v.open_lv=tonumber(v.open_lv);
                v.area_id=tonumber(v.area_id);
                v.show_order=tonumber(v.show_order);
                v.parent_id=tonumber(v.parent_id);
                v.is_show=tonumber(v.is_show);
                v.lvup_pic=v.lvup_pic..".png";
                self.btnsDataMap[v.id]=v;
                if temArr[v.area_id]==nil then
                        temArr[v.area_id]={};
                end
                table.insert(temArr[v.area_id],v);
        end

        for k,v in pairs(temArr) do
                table.sort(v,function(a,b) return a.show_order<b.show_order; end);
        end

        self.allBtnsData={};--保存按钮数据
        for k,v in pairs(temArr) do
                for k1,v1 in pairs(v) do
                        table.insert(self.allBtnsData,v1);
                end
        end

        self:updataBtns(lv);
end

function MainLayer:updataBtns(lv)
        local btn;
        self.allShowBtns={};
        for k,v in pairs(self.allBtnsData) do
                btn=self.allBtns[v.id];
                if self.allShowBtns[v.area_id]==nil then
                        self.allShowBtns[v.area_id]={};
                end

                if btn then
                        if v.open_lv<=lv then
                                btn:setEnabled(true);
                                table.insert(self.allShowBtns[v.area_id],btn);--按类型按顺序保存可见按钮
                        else
                                btn:setEnabled(false);
                        end
                else
                        print("btn is nil");
                end
        end

        for area_id,btns in pairs(self.allShowBtns) do
                for k,v in pairs(btns) do
                        local pos=self:getBtnPos(area_id,k,#btns);
                        if pos then
                            v:setPosition(pos);
                        end
                end
        end

        local btmBtnNum=#self.allShowBtns[4];
        self.Image_bottom:setVisible(true);
        self.Image_bottom:setSize(cc.size(146+btmBtnNum*100,124));
end

function MainLayer:getBtnPos(area_id,index,btnNum)
            local posArr=self.allBtnsPos[area_id];
            if posArr then
                    if area_id==1 or area_id==3 then
                            return posArr[index];
                    else
                            local newIndex=index+#posArr-btnNum;
                            return posArr[newIndex];
                    end
            end
end

--功能开放
function MainLayer:openFunc(menuOpenArr,mainOpenArr)

            if _G.sceneData.sceneType~=SCENEINFO.MAIN_SCENE and _G.sceneData.sceneType~=SCENEINFO.MAP_SCENE then
                    return;
            end

            function moveMenu()
                    self:updataBtns(13);

                    for k,v in pairs(menuOpenArr) do
                            local data=self.btnsDataMap[v.data.id];
                            if data then
                                    MGRCManager:cacheResource("MainLayer",data.lvup_pic);
                                    local icon=cc.Sprite:createWithSpriteFrameName(data.lvup_pic);
                                    icon:setPosition(v.pos);
                                    self:addChild(icon);

                                    local btn=self.allBtns[data.id];
                                    if btn then
                                            local x,y=btn:getPosition();
                                            local endPos=btn:getParent():convertToWorldSpace(cc.p(x,y));
                                            btn:setEnabled(false);

                                            function moveEnd(icon,arr)
                                                    icon:removeFromParent();
                                                    arr[1]:setEnabled(true);
                                            end

                                            local moveTo=cc.EaseOut:create(cc.MoveTo:create(0.8,endPos),4);
                                            local func=cc.CallFunc:create(moveEnd,{btn});
                                            icon:runAction(cc.Sequence:create(moveTo,func));
                                    end
                             end
                    end

                    for k,v in pairs(mainOpenArr) do
                            MGRCManager:cacheResource("MainLayer",v.data.lvup_pic);
                            local icon=cc.Sprite:createWithSpriteFrameName(v.data.lvup_pic);
                            icon:setPosition(v.pos);
                            self:addChild(icon);

                            local endPos=cc.p(0,0);
                            if _G.sceneData.sceneType==SCENEINFO.MAIN_SCENE then--主场景飞到建筑上
                                    if _G.mapParallaxNode then
                                            endPos=_G.mapParallaxNode:getBuildingWordPos(v.data.id);
                                    end
                            else--飞到主城按钮上
                                    local x,y=self.Button_city:getPosition();
                                    endPos=self.Button_city:getParent():convertToWorldSpace(cc.p(x,y));
                            end

                            function moveEnd(icon)
                                    icon:removeFromParent();
                            end

                            local moveTo=cc.EaseOut:create(cc.MoveTo:create(0.8,endPos),4);
                            local func=cc.CallFunc:create(moveEnd);
                            icon:runAction(cc.Sequence:create(moveTo,func));
                    end
            end

            if not self.isSpread then--展开底部菜单
                    self:runMenuAction(moveMenu);
            else
                    moveMenu();
            end
end

--显示跳转界面
function MainLayer:showLastLayer()
        require "campaignLayer";
        if _G.sceneData.layerType== LAYERTAG.LAYER_ARENA then
                local campaignLayer = campaignLayer.showBox(self,self.type);
                local arenaLayer = arenaLayer.showBox(self,self.type);
        elseif _G.sceneData.layerType==LAYERTAG.LAYER_PLOT then
                NetHandler:addAckCode(self,Post_Plot_plotList);
                NetHandler:sendData(Post_Plot_plotList, "");--用来刷新数据
        elseif _G.sceneData.layerType==LAYERTAG.LAYER_ISlAND then
                local campaignLayer = campaignLayer.showBox(self,self.type);
                local IslandMainLayer = IslandMainLayer.showBox(campaignLayer,_G.sceneData.sceneType);
        elseif _G.sceneData.layerType==LAYERTAG.LAYER_TRIAL then
                local campaignLayer = campaignLayer.showBox(self,self.type);
                local trialMainLayer = trialMainLayer.showBox(campaignLayer,_G.sceneData.sceneType);
                trialMainLayer:setData();
        elseif _G.sceneData.layerType==LAYERTAG.LAYER_RECOVERROAD then
                local campaignLayer = campaignLayer.showBox(self,self.type);
                local recoverroadLayer = recoverroadLayer.showBox(campaignLayer,_G.sceneData.sceneType);
        elseif _G.sceneData.layerType==LAYERTAG.LAYER_INVADE then
                self:openInvadeLayer(true,_G.sceneData.layerData);
        elseif _G.sceneData.layerType==LAYERTAG.LAYER_MAINTAINERS then
                local campaignLayer = campaignLayer.showBox(self,self.type);
                local vindicatorLayer = vindicatorLayer.showBox(campaignLayer,_G.sceneData.sceneType);
        end
end

--刷新玩家金币钻石
function MainLayer:updataMoney()
        self.Label_gold:setText(MGDataHelper:formatNumber(ME:getCoin()));
        self.Label_mas:setText(MGDataHelper:formatNumber(ME:getGold()));
end

function MainLayer:rollAction()
    self.ListView:removeAllItems();
    local itemLay = ccui.Layout:create();
    itemLay:setSize(cc.size(self.ListView:getContentSize().width, self.ListView:getContentSize().height));
    self.ListView:pushBackCustomItem(itemLay);

    local layout1 = ccui.Layout:create();
    layout1:setSize(cc.size(self.ListView:getContentSize().width, self.ListView:getContentSize().height));
    itemLay:addChild(layout1);

    local Label_power = cc.Label:createWithTTF(MG_TEXT("MainLayer_3"), ttf_msyh, 22);
    Label_power:setColor(cc.c3b(190,170,100));
    Label_power:setPosition(cc.p(Label_power:getContentSize().width/2,
        itemLay:getContentSize().height/2));
    layout1:addChild(Label_power);

    labelAtlas = cc.LabelBMFont:create("0", "warscore_num.fnt");
    labelAtlas:setAnchorPoint(cc.p(0,0.5));
    labelAtlas:setPosition(cc.p(Label_power:getPositionX()+Label_power:getContentSize().width/2+5,
    itemLay:getContentSize().height/2-5));
    layout1:addChild(labelAtlas);

    Label_power:setString(MG_TEXT("MainLayer_3"));--最强战力
    labelAtlas:setString(ME:getWarMax());
    local isPower = true;--最强战力
    local function callFunc()
        if isPower == true then
            Label_power:setString(MG_TEXT("MainLayer_4"));--全体战力
            labelAtlas:setString(ME:getWarScore());
        else
            Label_power:setString(MG_TEXT("MainLayer_3"));--最强战力
            labelAtlas:setString(ME:getWarMax());
        end
        isPower = not isPower;
        layout1:setPositionY(-itemLay:getContentSize().height);
    end
    local moveBy1 = cc.MoveBy:create(0.6, cc.p(0, itemLay:getContentSize().height));
    local func = cc.CallFunc:create(callFunc);
    local moveBy2 = cc.MoveBy:create(0.6, cc.p(0, itemLay:getContentSize().height));
    
    local seq = cc.Sequence:create(cc.DelayTime:create(3),moveBy1,func,moveBy2);
    layout1:runAction(cc.RepeatForever:create(seq));
end

function MainLayer:updateTime()
    if nil == chatInstance:getInstance() then
        self.ListView_chat:removeAllItems();
        local chatInstance = chatInstance:createInstance();
        self.ListView_chat:pushBackCustomItem(chatInstance);
    end
end

function MainLayer:onButtonClick(sender, eventType)
    if eventType == ccui.TouchEventType.began then
        local sc = cc.ScaleTo:create(0.1, 1.1)
        sender:runAction(cc.EaseOut:create(sc ,2))
    end
    if eventType == ccui.TouchEventType.canceled then
        local sc = cc.ScaleTo:create(0.1, 1)
        sender:runAction(sc)
    end
    if eventType == ccui.TouchEventType.ended then
        chatInstance:dispose();
        chatLayer:dispose();
        local sc = cc.ScaleTo:create(0.1, 1)
        sender:runAction(sc)
        if sender == self.Button_sieve then
            print("---------筛子迷宫按钮----------");
            NetHandler:sendData(Post_Main_getUserExp, "");--初始化数据
            NetHandler:sendData(Post_Main_getUserAction, "");--初始化数据
        elseif sender == self.Button_sieve1 then--君王之路按钮
            require "kingRoadMainLayer"
            local kingRoadMainLayer = kingRoadMainLayer.showBox(self,self.type);
        elseif sender == self.Button_rec then--充值按钮
            print("---------充值按钮----------");
        elseif sender == self.Button_act then--活动按钮
            print("---------活动按钮----------");
        elseif sender == self.Button_chat or sender == self.Panel_chatBtn then--聊天按钮
            print("---------聊天按钮----------");
            if ME:Lv() < self.value1 then
                MGMessageTip:showFailedMessage(string.format(MG_TEXT("chatLayer_14"),self.value1));
            else
                chatLayer:createInstance();
            end
        elseif sender == self.Button_pre then--特惠按钮
            print("---------特惠按钮----------");
        elseif sender == self.Button_gift then--礼包按钮
            print("---------礼包按钮----------");
        elseif sender == self.Button_city then--主城按钮
            if self.type and self.type == SCENEINFO.MAP_SCENE then--跳转到主城场景
                enterLuaScene(SCENEINFO.MAIN_SCENE);
            elseif self.type and self.type == SCENEINFO.MAIN_SCENE then--跳转到征战场景
                enterLuaScene(SCENEINFO.MAP_SCENE);
            end
        elseif sender == self.Button_war then--征战按钮
            --print("---------征战按钮----------");
            require "campaignLayer";
            local campaignLayer = campaignLayer.showBox(self,self.type);
        elseif sender == self.Button_legion then--军团按钮
            self.isUpdaUnion = true;
            NetHandler:sendData(Post_getUserMain, "");
        elseif sender == self.Button_warehouse then--仓库按钮
            require "PackageLayer"
            local packageLayer = PackageLayer.showBox(self,self.type);
            self:removeCurLayer();
        elseif sender == self.Button_shop then--商店按钮
            local shopLayer = shopLayer.showBox(self,1);
        elseif sender == self.Button_military then--军事按钮
            print("---------军事按钮----------");
        elseif sender == self.Button_keji then--科技按钮
            require "scienceLayer";
            local scienceLayer = scienceLayer.showBox(self);
        elseif sender == self.Button_hero then--英雄按钮
            require "GeneralMapLayer";
            local generalMapLayer = GeneralMapLayer.showBox(self,self.type);
        elseif sender == self.Button_task then--任务按钮
            local taskLayer = require "taskLayer";
            local task = taskLayer.new(self,self.type);
            self:addChild(task);
        elseif sender == self.Button_mail then--邮件按钮
            require "mailLayer";
            local mailLayer = mailLayer.showBox(self);
        elseif sender == self.Button_rank then--排行按钮
            require "rankLayer";
            local rankLayer = rankLayer.showBox(self);
        elseif sender == self.Button_pack then--群雄按钮
            print("---------群雄按钮----------");
        elseif sender == self.Button_event then--事件按钮
                if not self.plotListIsOpen then
                        self:openPlotList(true);
                        if self.plotListLayer then
                                local pos=sender:getWorldPosition();
                                self.plotListLayer:setPosition(cc.p(pos.x-90,pos.y-50));
                                self.plotListLayer:setShopData(self.getusermain);
                        end
                else
                        self:openPlotList(false);
                end
        elseif sender == self.Button_country then--国战按钮
                if not self.uwIsOpen then
                        self:openUWList(true);
                        if self.uwListLayer then
                                local pos=sender:getWorldPosition();
                                self.uwListLayer:setPosition(cc.p(pos.x-106,pos.y-50));
                                self.uwListLayer:initData();
                        end
                else
                        self:openPlotList(false);
                end
        elseif sender == self.Button_open then--收缩按钮
            self:runMenuAction();
        elseif sender == self.Button_add1 then--砖石添加按钮
            print("---------砖石添加按钮----------");
        elseif sender == self.Button_add2 then--金币添加按钮
            print("---------金币添加按钮----------");
        elseif sender == self.Button_add3 then--体力添加按钮
            print("---------体力添加按钮----------");
        elseif sender == self.Button_show then--显示战报
            Fight_ReadReport(self.type);
        elseif sender == self.Button_upload then--上传战报
            LuaBackCpp:uploadReport();
        end
    end
end

function MainLayer:runMenuAction(callBack)
    local btmBtns=self.allShowBtns[4];
    if self.isSpread == true then
        self.isSpread=false;
        local moveBy;
        for i=1,#btmBtns do
            moveBy = cc.MoveBy:create(0.2, cc.p(1000, 0));
            btmBtns[i]:runAction(cc.Sequence:create(moveBy));
        end
        self.Button_open:setRotation(180);
        moveBy = cc.MoveBy:create(0.2, cc.p(self.Image_bottom:getSize().width-146, 0));
        self.Image_bottom:runAction(cc.Sequence:create(moveBy));
    elseif self.isSpread == false then
        self.isSpread=true;
        local function callFunc()
            local itemIndex = 1
            local function loadEachItem(dt)
                local moveBy = cc.MoveBy:create(0.2, cc.p(-1000, 0));
                btmBtns[itemIndex]:setOpacity(0);
                local action = cc.FadeIn:create(0.2);
                action=cc.Spawn:create(moveBy,action);
                if itemIndex ==#btmBtns then
                        if self.schedulerID~=0 then
                                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
                                self.schedulerID=0;
                        end
                        if callBack then
                                action=cc.Sequence:create(action,cc.DelayTime:create(0.2),cc.CallFunc:create(callBack));
                        end
                end
                btmBtns[itemIndex]:runAction(action);
                itemIndex = itemIndex+1;
            end

            if self.schedulerID~=0 then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
            end
            self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(loadEachItem, 0.05, false);
        end

        self.Button_open:setRotation(0);
        local moveBy = cc.MoveBy:create(0.2, cc.p(-self.Image_bottom:getSize().width+146, 0));
        local func = cc.CallFunc:create(callFunc);
        self.Image_bottom:runAction(cc.Sequence:create(moveBy,func));
    end
end

function MainLayer:removeCurLayer()
    if self.type and self.type == SCENEINFO.MAP_SCENE then
        if self.delegate and self.delegate.removeMapManager then
            self.delegate:removeMapManager();
        end
    elseif self.type and self.type == SCENEINFO.MAIN_SCENE then
        if self.delegate and self.delegate.removeMainCityManager then
            self.delegate:removeMainCityManager();
        end
    end
end

function MainLayer:HeroHeadSelect(head)
    require "RoleInfoLayer"
    local roleInfoLayer = RoleInfoLayer.showBox(self);
    roleInfoLayer:setData();
end

function MainLayer:onTouchClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        if sender == self.Image_sieve1 then--君王之路跳转
            print("---------君王之路跳转----------");
            if nil == self.kingRoadData or 0 == #self.kingRoadData then
                require "kingRoadMainLayer"
                local kingRoadMainLayer = kingRoadMainLayer.showBox(self,self.type);
                return;
            end

            if tonumber(self.kingRoadData.status) == 1 then--可领取
                NetHandler:addAckCode(self,Post_Achievement_getReward);
                NetHandler:sendData(Post_Achievement_getReward, "&id="..tonumber(self.kingRoadData.a_id));
            else
                require "kingRoadMainLayer"
                local kingRoadMainLayer = kingRoadMainLayer.showBox(self,self.type,tonumber(self.kingRoadData.a_id));
                kingRoadMainLayer:jump();
            end
        end
    end
end

function MainLayer:createGuildMainLayer()
    require "guildMainLayer";
    local guildMainLayer = guildMainLayer.showBox(self,self.type);
end

function MainLayer:onReciveData(msgId, netData)
        if msgId == Post_getUserMain then
                self.getusermain=netData.getusermain;
                NetHandler:sendData(Post_Achievement_getAchievementTips, "");
                if netData.state == 1 then
                    ME:setName(self.getusermain.name);
                    ME:setExp(tonumber(self.getusermain.exp));
                    ME:setLv(tonumber(self.getusermain.lv));
                    ME:setVipLv(tonumber(self.getusermain.vip_lv));
                    -- ME:setCountry(tonumber(self.getusermain.country));
                    ME:setCoin(tonumber(self.getusermain.coin));
                    ME:setGold(tonumber(self.getusermain.gold));
                    ME:setAction(tonumber(self.getusermain.action));
                    ME:setWarScore(tonumber(self.getusermain.war_score));
                    ME:setWarMax(tonumber(self.getusermain.war_max));
                    ME:setVipExp(tonumber(self.getusermain.vip_exp));
                    ME:setUnionId(tonumber(self.getusermain.union_id));
                    ME:setAchLv(tonumber(self.getusermain.a_lv));
                    if self.getusermain.head ~= "" then
                        ME:setHeadId(tonumber(self.getusermain.head));
                    end
                    self:setData(self.getusermain);
                else
                    NetHandler:showFailedMessage(netData)
                end
        elseif msgId == Post_Plot_plotList then
                 NetHandler:delAckCode(self,Post_Plot_plotList);
                
                 if netData.state == 1 then
                        local userPlot=netData.plotlist.user_plot;
                        local itemData=nil;
                        for k,v in pairs(userPlot) do
                                if v.p_id==_G.sceneData.layerData.p_id then
                                        itemData=v;
                                end
                        end

                        if itemData then
                                _G.sceneData.layerData.end_time=itemData.end_time;
                                _G.sceneData.layerData.win_c_id=itemData.win_c_id;
                                _G.sceneData.layerData.is_win=itemData.is_win;
                                local leftTime=tonumber(_G.sceneData.layerData.end_time)-os.time();--判断时间是否结束了
                                if leftTime>0 then
                                        self:openPlotLayer(true,_G.sceneData.layerData);
                                end
                        end
                else
                    NetHandler:showFailedMessage(netData);
                end
        elseif msgId == Post_Achievement_getAchievementTips then
            if netData.state == 1 then
                self:setKingRoadData(netData.getachievementtips.tips_info);
            else
                NetHandler:showFailedMessage(netData);
            end
        elseif msgId == Post_Achievement_getReward then
            NetHandler:delAckCode(self,Post_Achievement_getReward);
            if netData.state == 1 then
                getItem.showBox(NetData.getReward);
                self:setKingRoadData(netData.getachievementtips.tips_info);
            else
                NetHandler:showFailedMessage(netData);
            end
        end
end

function MainLayer:pushAck()
    NetHandler:addAckCode(self,Post_getUserMain);
    NetHandler:addAckCode(self,Post_Achievement_getAchievementTips);
end

function MainLayer:popAck()
    NetHandler:delAckCode(self,Post_getUserMain);
    NetHandler:delAckCode(self,Post_Achievement_getAchievementTips);
end

function MainLayer:sendReq()
    NetHandler:sendData(Post_getUserMain, "");
end

function MainLayer:onEnter()
    self:pushAck();
    self:sendReq();
    _G.mainLayer=self;
end

function MainLayer:onExit()
    MGRCManager:releaseResources("MainLayer");
    self:popAck();
    if self.schedulerID~=0 then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
        self.schedulerID=0;
    end
    chatInstance:dispose();
    chatLayer:dispose();
    _G.mainLayer=nil;
    if self.timer~=nil then
        self.timer:stopTimer();
    end
end

--打开神秘商店
function MainLayer:openMysteryStore(value)
        local curScene=cc.Director:getInstance():getRunningScene();
        if value then
                if self.mysteryStoreLayer==nil then
                    local MysteryStoreLayer=require "MysteryStoreLayer";
                    self.mysteryStoreLayer=MysteryStoreLayer.new(self,self.getusermain);
                    curScene:addChild(self.mysteryStoreLayer,ZORDER_MAX);
                end
        else
                if self.mysteryStoreLayer then
                    self.mysteryStoreLayer:removeFromParent();
                    self.mysteryStoreLayer=nil;
                end
        end
end

--打开剧情列表
function MainLayer:openPlotList(value)
        local curScene=cc.Director:getInstance():getRunningScene();
        if value then
                if self.plotListLayer==nil then
                    self.plotListIsOpen=true;
                    local PlotListLayer=require "PlotListLayer";
                    self.plotListLayer=PlotListLayer.new(self,self.getusermain);
                    curScene:addChild(self.plotListLayer,ZORDER_MAX);
                end
        else
                if self.plotListLayer then
                    self.plotListIsOpen=false;
                    self.plotListLayer:removeFromParent();
                    self.plotListLayer=nil;
                end
        end
end

function MainLayer:reopenPlotList()
        self:openPlotList(false);
        self:openPlotList(true);
        if self.plotListLayer then
                local pos=self.Button_event:getWorldPosition();
                self.plotListLayer:setPosition(cc.p(pos.x-90,pos.y-50));
                self.plotListLayer:setShopData(self.getusermain);
        end
end

--打开事件剧情详细页
function MainLayer:openPlotLayer(value,data)
        local curScene=cc.Director:getInstance():getRunningScene();
        if value then
                if self.plotLayer==nil then
                    local PlotLayer=require "PlotLayer";
                    self.plotLayer=PlotLayer.new(self);
                    curScene:addChild(self.plotLayer,ZORDER_MAX);
                end
                self.plotLayer:initData(data);
        else
                if self.plotLayer then
                    self.plotLayer:removeFromParent();
                    self.plotLayer=nil;
                end
        end
end

--打开入侵事件
function MainLayer:openInvadeLayer(value,data)
        local curScene=cc.Director:getInstance():getRunningScene();
        if value then
                if self.invadeLayer==nil then
                    local InvadeLayer=require "InvadeLayer";
                    self.invadeLayer=InvadeLayer.new(self,data);
                    curScene:addChild(self.invadeLayer,ZORDER_MAX);
                end
        else
                if self.invadeLayer then
                    self.invadeLayer:removeFromParent();
                    self.invadeLayer=nil;
                end
        end
end

--打开剧情列表
function MainLayer:openUWList(value)
        local curScene=cc.Director:getInstance():getRunningScene();
        if value then
                if self.uwListLayer==nil then
                    self.uwIsOpen=true;
                    local UWListLayer=require "UWListLayer";
                    self.uwListLayer=UWListLayer.new(self);
                    curScene:addChild(self.uwListLayer,ZORDER_MAX);
                end
        else
                if self.uwListLayer then
                    self.uwIsOpen=false;
                    self.uwListLayer:removeFromParent();
                    self.uwListLayer=nil;
                end
        end
end

function MainLayer.create(delegate,type)
    local layer = MainLayer.new(delegate,type,layerType)
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

function MainLayer.showBox(delegate,type)
    local layer = MainLayer.create(delegate,type);
    cc.Director:getInstance():getRunningScene():addChild(layer,10);
    return layer;
end
