guildBoxItem = class("guildBoxItem", MGItem)

function guildBoxItem:ctor()
    self.itemInfo = {};
    self:init();
end

function guildBoxItem:init()
    local boxSpr = cc.Sprite:createWithSpriteFrameName("com_icon_box.png");
    boxSpr:setPosition(cc.p(self:getContentSize().width/2,self:getContentSize().height/2));
    self:addChild(boxSpr,-1);
end

function guildBoxItem:setData(type,id,itemNum)
    local num = itemNum or 0;
    type = 21;
    local sql = "select * from union_box where id="..id;
    local DBData = LUADB.select(sql, "name:pic:des:quality:is_need_box");
    if DBData then
        self.gm = {};
        self.gm.type = type;
        self.gm.id = id;
        self.gm.num = num;
        self.gm.name = DBData.info.name;
        self.gm.desc = DBData.info.des;
        self.gm.pic = DBData.info.pic..".png";
        self.gm.quality = tonumber(DBData.info.quality);
        self.gm.is_need_box = tonumber(DBData.info.is_need_box);
        self.gm.get_go = {};
        self.itemType = self.gm.type;

        MGRCManager:cacheResource("guildBoxItem", self.gm.pic);
        self.headSpr:setSpriteFrame(self.gm.pic);
        self.headSpr:setScale(85/self.headSpr:getContentSize().width);
        local filename = ResourceData:getBoxPic(self.gm.quality);
        self.boxSpr:setSpriteFrame(filename);
        if self.gm.quality <= 1 then
            self.boxSpr:setVisible(false);
        end
        self.headSpr:setVisible(true);
        self.numLabel:setString(self.gm.num);
        self.nameLabel:setString(self.gm.name);
        self.nameLabel:setColor(ResourceData:getTitleColor(self.gm.quality));
        self.itemInfo = self.gm;
    else
        self.headSpr:setVisible(false);
        self.numLabel:setVisible(false);
        self.nameLabel:setVisible(false);
        self.boxSpr:setSpriteFrame("com_item_box_2.png");
    end
end

function guildBoxItem:getItemInfo()
    return self.itemInfo;
end

function guildBoxItem:onEnter()

end

function guildBoxItem:onExit()
    MGRCManager:releaseResources("guildBoxItem");
end

function guildBoxItem.create(delegate)
    local layer = guildBoxItem:new()
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

-- guildBoxItem = class("guildBoxItem",function()  
--     return ccui.Layout:create(); 
-- end)

-- function guildBoxItem:ctor()

-- end

-- function guildBoxItem:init()
--     self:setSize(cc.size(105, 170));
--     self:setAnchorPoint(cc.p(0.5,0.5));

--     self.boxImg = ccui.ImageView:create("com_icon_box.png", ccui.TextureResType.plistType);
--     local y = self:getContentSize().height-self.boxImg:getContentSize().height/2-15;
--     self.boxImg:setPosition(cc.p(self:getContentSize().width/2, y));
--     self.boxImg:setTouchEnabled(true);
--     self.boxImg:addTouchEventListener(handler(self,self.onButtonClick));
--     self:addChild(self.boxImg);

--     --物品底图
--     self.bgSpr = cc.Sprite:create();
--     self.bgSpr:setPosition(self.boxImg:getPosition());
--     self:addChild(self.bgSpr);

--     --物品头像
--     self.headSpr = cc.Sprite:create();
--     self.headSpr:setPosition(cc.p(self:getContentSize().width/2, self:getContentSize().height/2));
--     self:addChild(self.headSpr);

--     --品质框
--     -- self.boxSpr = cc.Sprite:createWithSpriteFrameName("com_item_kuan_1.png");
--     -- self.boxSpr:setPosition(cc.p(self:getContentSize().width/2, self:getContentSize().height/2));
--     -- self:addChild(self.boxSpr);

--     --选中框
--     self.selspr = cc.Sprite:createWithSpriteFrameName("com_selected_box.png");
--     self.selspr:setPosition(self.boxImg:getPosition());
--     self.selspr:setScale(self.boxImg:getContentSize().width/self.selspr:getContentSize().width);
--     self:addChild(self.selspr,1);
--     self.selspr:setVisible(false);

--     --数量
--     self.numLabel = cc.Label:createWithTTF("", ttf_msyh, 22);
--     self.numLabel:setAnchorPoint(cc.p(1,0.5));
--     self.numLabel:setPosition(cc.p(self.boxImg:getPositionX()+40,self.boxImg:getPositionY()-35));
--     self.numLabel:enableOutline(cc.c4b(  0,   0,   0, 255),1);
--     self:addChild(self.numLabel,2);
--     self.numLabel:setAdditionalKerning(-2);
--     self.numLabel:setVisible(false);

--     self.nameLabel = cc.Label:createWithTTF("我的宝箱",ttf_msyh,22);
--     self.nameLabel:setAlignment(cc.TEXT_ALIGNMENT_CENTER,cc.VERTICAL_TEXT_ALIGNMENT_CENTER);
--     self.nameLabel:setDimensions(360, 0);
--     self.nameLabel:setAnchorPoint(cc.p(0.5, 0.5));
--     self.nameLabel:setPosition(cc.p(self:getContentSize().width/2, 25));
--     self:addChild(self.nameLabel);
-- end

-- function guildBoxItem:setData(data)
--     self.data = data;

--     MGRCManager:cacheResource("guildBoxItem", self.data.pic..".png");
--     self.headSpr:setSpriteFrame(self.data.pic..".png");
--     if tonumber(self.data.id) >= 2 then
--         self.bgSpr:setSpriteFrame(string.format("com_item_box_%d.png",id));
--     end
-- end

-- function guildBoxItem:setNum(num)
--     self.numLabel:setString(num);
--     self.numLabel:setVisible(true);
-- end

-- function guildBoxItem:setNameToId(id)
--     if id == 1 then
--         self.nameLabel:setString(self.data.name);
--         self.nameLabel:setColor(cc.c3b(190,170,100));
        
--     elseif id == 2 then

--     elseif id == 3 then

--     elseif id == 4 then

--     elseif id == 5 then

--     end
-- end

-- function guildBoxItem:onButtonClick(sender, eventType)
--     if eventType == ccui.TouchEventType.ended then
        
--     end
-- end

-- function guildBoxItem:onEnter()

-- end

-- function guildBoxItem:onExit()
--     MGRCManager:releaseResources("guildBoxItem");
-- end

-- function guildBoxItem.create()
--     local layer = guildBoxItem:new()
--     layer:init()
--     local function onNodeEvent(event)
--         if event == "enter" then
--             layer:onEnter()
--         elseif event == "exit" then
--             layer:onExit()
--         end
--     end
--     layer:registerScriptHandler(onNodeEvent)
--     return layer   
-- end
