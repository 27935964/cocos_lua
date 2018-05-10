--------------------------公会爵位Item-----------------------

local guildNobilityItem = class("guildNobilityItem", MGWidget)

function guildNobilityItem:init(delegate,widget)
    self.delegate=delegate;
    self:addChild(widget);
    self.pWidget = widget;

    local Panel_2 = self.pWidget:getChildByName("Panel_2");
    self:setContentSize(Panel_2:getContentSize());

    self.Panel_6 = Panel_2:getChildByName("Panel_6");
    self.Panel_6:setAnchorPoint(cc.p(0.5,0.5));

    self.Panel_3 = self.Panel_6:getChildByName("Panel_3");
    self.Image_frame1 = self.Panel_3:getChildByName("Image_frame1");
    self.Image_back = self.Image_frame1:getChildByName("Image_back");
    self.Image_back:setTouchEnabled(true);
    self.Image_back:addTouchEventListener(handler(self,self.onButtonClick));
    self.Panel_desc1 = self.Panel_3:getChildByName("Panel_desc1");

    self.ListView = self.Panel_desc1:getChildByName("ListView_1");
    self.ListView:setScrollBarVisible(false);

    self.Label_tip = self.Image_frame1:getChildByName("Label_tip");
    self.Label_tip:setVisible(false);

    local Panel_5 = Panel_2:getChildByName("Panel_5");
    self.Image_progress_bar_bg = Panel_5:getChildByName("Image_progress_bar_bg");

    self.progressBar = cc.ProgressTimer:create(cc.Sprite:createWithSpriteFrameName("guild_progress_bar.png"));
    self.progressBar:setType(cc.PROGRESS_TIMER_TYPE_BAR);
    self.progressBar:setBarChangeRate(cc.p(1,0));
    self.progressBar:setMidpoint(cc.p(0,0));
    self.progressBar:setPosition(self.Image_progress_bar_bg:getPositionX(),self.Image_progress_bar_bg:getPositionY());
    self.progressBar:setAnchorPoint(cc.p(0,0.5));
    Panel_5:addChild(self.progressBar);
    self.progressBar:setScaleX(0.8);
    self.progressBar:setPercentage(10);

    self.Image_medal = Panel_5:getChildByName("Image_medal");
    self.Image_ribbon = Panel_5:getChildByName("Image_ribbon");
    self.Image_prestige_name = Panel_5:getChildByName("Image_prestige_name");
    self.Label_limit = Panel_5:getChildByName("Label_limit");
    self.numLabel = Panel_5:getChildByName("Label_prestige_number");

    self.Panel_4 = self.Panel_6:getChildByName("Panel_4");
    self.Panel_4:setVisible(false);
    self.Panel_desc2 = self.Panel_4:getChildByName("Panel_desc2");

    self.Image_frame2 = self.Panel_4:getChildByName("Image_frame2");
    self.Image_turn = self.Image_frame2:getChildByName("Image_turn");
    self.Image_turn:setTouchEnabled(false);
    self.Image_turn:addTouchEventListener(handler(self,self.onButtonClick));

    self.ListView_1 = self.Panel_desc2:getChildByName("ListView_2");
    self.ListView_1:setScrollBarVisible(false);

    self.Label_number = self.Panel_desc2:getChildByName("Label_number");
    local Panel_sodier = self.Panel_desc2:getChildByName("Panel_sodier");

    local Label_people = self.Panel_desc2:getChildByName("Label_people");
    Label_people:setText(MG_TEXT_COCOS("guild_nobility_item_ui_1"));

    local Label_fight = self.Panel_desc2:getChildByName("Label_fight");
    Label_fight:setText(MG_TEXT_COCOS("guild_nobility_item_ui_2"));

    local Label_buff = self.Panel_desc2:getChildByName("Label_buff");
    Label_buff:setText(MG_TEXT_COCOS("guild_nobility_item_ui_3"));

    local Label_need_prestige = Panel_5:getChildByName("Label_need_prestige");
    Label_need_prestige:setText(MG_TEXT_COCOS("guild_nobility_item_ui_4"));

    self.children = {};
    self:walkNode(self.pWidget);
end

function guildNobilityItem:walkNode(node)
    -- 递归访问所有节点，当前节点node
    if not node then return end
    if node.getChildrenCount and node:getChildrenCount() > 0 then
        for k,v in pairs(node:getChildren()) do
            if v.loadTexture then
                table.insert(self.children,{obj=v,d1=v:getShaderProgram()});
            elseif v.setText then
                table.insert(self.children,{obj=v,d1=v:getColor()});
            else
                table.insert(self.children,{obj=v,d1=nil});
            end
            self:walkNode(v);
        end
    end
end

function guildNobilityItem:setData(data,peerageDatas,index)
    self.data = data;
    self.peerageData = peerageDatas[index];
    self.index = index;

    self.peerageList = {};
    for i=1,#self.data.peerages_list do
        if self.peerageData.id == tonumber(self.data.peerages_list[i].peerages) then
            self.peerageList = self.data.peerages_list[1].data;
            break;
        end
    end
    table.sort(self.peerageList,function(data1,data2) return data1.exp > data2.exp end)

    local picName = string.format("guild_name_icon_%d.png",self.peerageData.id);
    self.Image_medal:loadTexture(self.peerageData.pic..".png",ccui.TextureResType.plistType);
    self.Image_prestige_name:loadTexture(picName,ccui.TextureResType.plistType);
    if self.peerageData.pic_star == "" or self.peerageData.pic_star == "0" then
        self.Image_ribbon:setVisible(false);
    else
        self.Image_ribbon:loadTexture(self.peerageData.pic_star..".png",ccui.TextureResType.plistType);
    end
    self.Label_limit:setText(string.format(MG_TEXT("guildNobilityItem_1"),self.peerageData.union_lv));
    self.numLabel:setText(self.peerageData.exp);
    if self.index >= #peerageDatas then
        self.progressBar:setVisible(false);
        self.Image_progress_bar_bg:setVisible(false);
    end

    if self.peerageData.num <= 0 then
        self.Label_number:setText(string.format(MG_TEXT("guildNobilityItem_2"),20));
    else
        self.Label_number:setText(string.format("%d/%d",20,self.peerageData.num));
    end

    self.Label_tip:setVisible(false);
    if #self.peerageList <= 0 then
        self.Label_tip:setVisible(true);
    end

    self.ListView:removeAllItems();
    self.children_1 = {};
    self.items = {};
    for i=1,#self.peerageList do
        local item = self:createItem(self.peerageList[i]);
        self.ListView:pushBackCustomItem(item);
        local children = getChildren(item);
        for j=1,#children do
            table.insert(self.children_1,children[j]);
        end
    end

    self:createBonus();

    self:setIsGray(false);
    if tonumber(self.data.my_peerages) < self.peerageData.id then
        self:setIsGray(true);
    end

    if tonumber(self.data.my_peerages) >= self.peerageData.id+1 then
        self.progressBar:setPercentage(100);
    end
    
end

function guildNobilityItem:createBonus()
    self.ListView_1:removeAllItems();
    self.itemLay = ccui.Layout:create();
    self.itemLay:setSize(cc.size(self.ListView_1:getContentSize().width, self.ListView_1:getContentSize().height));
    self.ListView_1:pushBackCustomItem(self.itemLay);
    local bonusItem = {};
    for i=1,#self.peerageData.plus_num do
        local item = self:createBonusItem(self.peerageData.plus_num[i]);
        local h = self.itemLay:getContentSize().height-item:getContentSize().height-5;
        item:setPosition(cc.p(0,h-(i-1)*(item:getContentSize().height+10)));
        self.itemLay:addChild(item);
        table.insert(bonusItem,item);
    end

    if #bonusItem == 1 then
        bonusItem[1]:setPositionY(self.itemLay:getContentSize().height/2-bonusItem[1]:getContentSize().height/2);
    elseif #bonusItem == 2 then
        bonusItem[1]:setPositionY(self.itemLay:getContentSize().height/2+bonusItem[2]:getContentSize().height/4);
        bonusItem[2]:setPositionY(self.itemLay:getContentSize().height/2-bonusItem[2]:getContentSize().height*5/4);
    end
end

function guildNobilityItem:createItem(data)
    local layout = ccui.Layout:create();
    layout:setSize(cc.size(self.ListView:getContentSize().width, 75));
    -- layout:setBackGroundColorType(1);
    -- layout:setBackGroundColor(cc.c3b(0,255,250));

    local nameLabel = cc.Label:createWithTTF(unicode_to_utf8(data.name), ttf_msyh, 20);
    nameLabel:setAnchorPoint(cc.p(0,0.5));
    nameLabel:setPosition(cc.p(10,layout:getContentSize().height-10));
    layout:addChild(nameLabel);

    local spr = cc.Sprite:createWithSpriteFrameName("com_icon_prestige.png");
    spr:setPosition(cc.p(nameLabel:getPositionX()+20, nameLabel:getPositionY()-35));
    layout:addChild(spr);

    local numLabel = cc.Label:createWithTTF(tonumber(data.exp), ttf_msyh, 20);
    numLabel:setAnchorPoint(cc.p(0,0.5));
    numLabel:setPosition(cc.p(spr:getPositionX()+spr:getContentSize().width+10,spr:getPositionY()));
    layout:addChild(numLabel);

    return layout;
end

function guildNobilityItem:createBonusItem(data)
    local layout = ccui.Layout:create();
    layout:setSize(cc.size(self.ListView:getContentSize().width, 30));

    local str = ""
    local sql = "select name from effect where id="..data.value1;
    local DBData = LUADB.select(sql, "name");
    if DBData then
        str = DBData.info.name;
    end

    local nameLabel = cc.Label:createWithTTF(str, ttf_msyh, 20);
    nameLabel:setAnchorPoint(cc.p(0,0.5));
    nameLabel:setPosition(cc.p(30,layout:getContentSize().height/2));
    nameLabel:setColor(cc.c3b(190,170,100));
    layout:addChild(nameLabel);

    str = string.format("+%d%%",data.value2);
    if data.value1 <= 7 or data.value1 == 30 or data.value1 == 31 then
        str = string.format("+%d",data.value2);
    end
    local numLabel = cc.Label:createWithTTF(str, ttf_msyh, 20);
    numLabel:setAnchorPoint(cc.p(0,0.5));
    numLabel:setPosition(cc.p(nameLabel:getPositionX()+nameLabel:getContentSize().width+20,nameLabel:getPositionY()));
    layout:addChild(numLabel);

    return layout;
end

function guildNobilityItem:setIsGray(isGray)
    self.isGray = isGray;
    if isGray then
        for k,v in pairs(self.children) do
            if v.obj.loadTexture and v.obj:getName() ~= "Image_progress_bar_bg" then
                v.obj:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
            elseif v.obj.setText then
                v.obj:setColor(Color3B.GRAY);
            end
        end
        self.Image_frame1:loadTexture("common_two_box_disable.png",ccui.TextureResType.plistType);
        self.Image_frame2:loadTexture("common_two_box_disable.png",ccui.TextureResType.plistType);

        for i,v in ipairs(self.children_1) do
            if v.setSpriteFrame then
                v:setShaderProgram(MGGraySprite:getGrayShaderProgram());
            elseif v.setString then
                v:setColor(Color3B.GRAY);
            end
        end
    else

    end
end

function guildNobilityItem:runAction(sender)
    self.Panel_3:setVisible(false);
    self.Panel_4:setVisible(false);
    self.Image_turn:setTouchEnabled(false);
    self.Image_back:setTouchEnabled(false);
    self.Panel_desc1:setVisible(false);
    self.Panel_desc2:setVisible(false);

    if sender == self.Image_turn then
        self.Panel_3:setVisible(true);
    elseif sender == self.Image_back then
        self.Panel_4:setVisible(true);
    end

    local function setState()
        if sender == self.Image_turn then
            self.Image_back:setTouchEnabled(true);
            self.Panel_desc1:setVisible(true);
        elseif sender == self.Image_back then
            self.Image_turn:setTouchEnabled(true);
            self.Panel_desc2:setVisible(true);
        end

    end
    --旋转的时间、起始半径、半径差、起始z角、旋转z角差、起始x角、旋转x角差
    local orbit = cc.OrbitCamera:create(0.5, 1, 0, 0, -180, 0, 0);
    local function setScaleX()
        self.Panel_6:setScaleX(-1);
    end
    local callFunc = cc.CallFunc:create(setScaleX);
    local callFunc1 = cc.CallFunc:create(setState);
    self.Panel_6:runAction(cc.Sequence:create(callFunc,orbit,callFunc1));
end

function guildNobilityItem:onButtonClick(sender, eventType)
    buttonClickScale(sender, eventType, 0.9);

    if eventType == ccui.TouchEventType.ended then
        if sender == self.Image_turn then
            self:runAction(sender);
        elseif sender == self.Image_back then
            self:runAction(sender);
        end
    end
end

function guildNobilityItem:onEnter()
    
end

function guildNobilityItem:onExit()
    MGRCManager:releaseResources("guildNobilityItem")
end

function guildNobilityItem.create(delegate,widget)
    local layer = guildNobilityItem:new()
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

return guildNobilityItem