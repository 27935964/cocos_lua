----------------------物品-----------------------

resItem = class("resItem",function()  
    return ccui.Layout:create(); 
end)

function resItem:ctor()
    self.isShowTip = true;
    self.numLabel = nil;
    self.nameLabel = nil;
    self.curItem=nil;
    self.itemInfo = {};
    self:init();
end

function resItem:init()
    self:setSize(cc.size(105, 105));
    self:setAnchorPoint(cc.p(0.5,0.5));

    local boxSpr = cc.Sprite:createWithSpriteFrameName("com_icon_box.png");
    boxSpr:setPosition(cc.p(self:getContentSize().width/2,self:getContentSize().height/2));
    self:addChild(boxSpr);
end

function resItem:setData(type,id,num)
    -- print("==%d ==%d ==%d",type,id,num)
    local itemType = tonumber(type);
    id = tonumber(id);
    num = tonumber(num);
    if nil == num then
        num = 0;
    end

    local gm = nil;
    local sql = "select isonly from item_type where id="..itemType;
    local DBData = LUADB.select(sql, "isonly");
    if DBData and tonumber(DBData.info.isonly) == 0 then
        if itemType == 8 then--将领卡
            gm = GENERAL:getAllGeneralModel(id);
            if gm then
                self.curItem = HeroHeadEx.create(self);
                self.curItem:setPosition(self:getContentSize().width/2,self:getContentSize().height/2);
                self:addChild(self.curItem);
                self.curItem:setData(gm);
            end
        else
            gm = RESOURCE:getDBResourceListByItemId(id);
            if gm then
                self.curItem = Item.create(self);
                self.curItem:setPosition(self:getContentSize().width/2,self:getContentSize().height/2);
                self:addChild(self.curItem);
                self.curItem:setData(gm);
            end
        end
    elseif DBData and tonumber(DBData.info.isonly) == 1 then--特殊物品
        self.curItem = OtherItem.create(self);
        self.curItem:setPosition(self:getContentSize().width/2,self:getContentSize().height/2);
        self:addChild(self.curItem);
        self.curItem:setData(itemType,id,num);
    end

    if itemType ~= 8 then 
        self.curItem:setShowTip(self.isShowTip);
    end
    self.numLabel = self.curItem.numLabel;
    self.nameLabel = self.curItem.nameLabel;
    if  self.curItem.gm then
        self.gm = self.curItem.gm
    end
    self.itemInfo = self.curItem:getItemInfo();
end

function resItem:getItemInfo()
    return self.itemInfo;
end

function resItem:setNum(num)
    self.numLabel:setString(num);
end

function resItem:setNumVisible(isVisible)
    self.numLabel:setVisible(isVisible);
end

function resItem:setShowTip(isShowTip)--设置是否显示Tip
    if nil == isShowTip then
        self.isShowTip = true;
    else
        self.isShowTip = isShowTip;
    end
    if self.curItem then
        self.curItem:setShowTip(self.isShowTip);
    end
end

function resItem:setTouchEnabled(isTouch)
    if self.curItem then
        self.curItem:setTouchEnabled(isTouch);
    end
end

function resItem:ItemSelect(head)
    if self.delegate and self.delegate.ItemSelect then
        self.delegate:ItemSelect(head,self);
    end
end

function resItem:setEmpty()
        if self.curItem then
            self.curItem:removeFromParent();
            self.curItem=nil;
        end
end

function resItem:onEnter()

end

function resItem:onExit()
    MGRCManager:releaseResources("resItem");
end

function resItem.create(delegate)
    local layer = resItem:new()
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

-----------------------------------------------------------

local MGShowItemLayer = nil
local ShowItemLayer = class("ShowItemLayer",MGImageView)

function ShowItemLayer:init()
    MGRCManager:cacheResource("ShowItemLayer", "tips_bg.jpg");

    self:setSize(cc.size(325, 130));
    self:loadTexture("tips_bg.jpg");
    self:setScale9Enabled(true);
    self:setCapInsets(cc.rect(37, 33, 1, 1));
    self:setTouchEnabled(false);

    --背景
    self.bgSpr = cc.Sprite:createWithSpriteFrameName("com_item_bg.png");
    self.bgSpr:setPosition(cc.p(60, self:getContentSize().height-65));
    self:addChild(self.bgSpr);

    --头像框
    self.boxSpr = ccui.ImageView:create("com_item_kuan_1.png", ccui.TextureResType.plistType);
    self.boxSpr:setPosition(self.bgSpr:getPosition());
    self:addChild(self.boxSpr,1);

    --头像
    self.headSpr = cc.Sprite:create();
    self.headSpr:setPosition(self.bgSpr:getPosition());
    self:addChild(self.headSpr,2);

    local ttfConfig  = {}
    ttfConfig.fontFilePath= ttf_msyh
    ttfConfig.fontSize = 22

    self.nameLabel = cc.Label:createWithTTF(ttfConfig, "");
    self.nameLabel:setColor(cc.c3b(0,255,255));
    self.nameLabel:setAnchorPoint(cc.p(0, 1.0));
    self.nameLabel:setPosition(cc.p(self:getContentSize().width/2-40, self:getContentSize().height-20));
    self:addChild(self.nameLabel);

    self.descLabel = MGColorLabel:label();
    self.descLabel:setAnchorPoint(cc.p(0, 1));
    self.descLabel:setPosition(cc.p(self.nameLabel:getPositionX(), self.nameLabel:getPositionY()-self.nameLabel:getContentSize().height-4));
    self:addChild(self.descLabel);

end

function ShowItemLayer:setData(infoex,itemType)
    if infoex == nil then
        return;
    end

    self.itemInfo = {};
    self.descLabel:clear();
    local sql = "select isonly from item_type where id="..itemType;
    local DBData = LUADB.select(sql, "isonly");
    if DBData and tonumber(DBData.info.isonly) == 0 then--数据处理
        if itemType == 21 then
            self.itemInfo.pic = infoex.pic;
            self.itemInfo.quality = infoex.quality;
            self.itemInfo.name = infoex.name;
            self.itemInfo.desc = infoex.desc;
        else
            self.itemInfo.pic = infoex:pic();
            self.itemInfo.quality = infoex:getQuality();
            self.itemInfo.name = infoex:name();
            self.itemInfo.desc = infoex:desc();
        end
    else
        self.itemInfo.pic = infoex.pic;
        self.itemInfo.quality = infoex.quality;
        self.itemInfo.name = infoex.name;
        self.itemInfo.desc = infoex.desc;
    end

    MGRCManager:cacheResource("ShowItemLayer", self.itemInfo.pic);
    self.headSpr:setSpriteFrame(self.itemInfo.pic);
    local filename = ResourceData:getBoxPic(self.itemInfo.quality)
    self.boxSpr:loadTexture(filename,ccui.TextureResType.plistType);
    if self.itemInfo.quality <= 1 then
        self.boxSpr:setVisible(false);
    end
    self.nameLabel:setString(self.itemInfo.name);
    local str_list = spliteStr(self.itemInfo.desc,"\\n");
    local str1 = str_list[1];
    local str2 = str_list[2];
    self.descLabel:appendStringAutoWrap(str1,8,1,cc.c3b(255,255,255),22);
    self.descLabel:appendLine(10);
    self.descLabel:appendStringAutoWrap(str2,8,1,cc.c3b(255,255,255),22);

    local h = self.descLabel:getContentSize().height+4+self.nameLabel:getContentSize().height+40;
    if h < 130 then
        h = 130;
    end

    self.headSpr:setScale(85/self.headSpr:getContentSize().width);
    self:setSize(cc.size(self:getSize().width, h));
    self.bgSpr:setPosition(cc.p(60, self:getContentSize().height-65));
    self.headSpr:setPosition(self.bgSpr:getPosition());
    self.boxSpr:setPosition(self.bgSpr:getPosition());
    self.nameLabel:setPosition(cc.p(self:getContentSize().width/2-40, self:getContentSize().height-20));
    self.descLabel:setPosition(cc.p(self.nameLabel:getPositionX(), self.nameLabel:getPositionY()-self.nameLabel:getContentSize().height-4));
end

function ShowItemLayer:setPos(pos)
    self:setPosition(pos);
end

function ShowItemLayer:destroy()
    MGRCManager:releaseResources("ShowItemLayer")
end

function ShowItemLayer:onEnter()
    
end

function ShowItemLayer:onExit()
    self:destroy()
end
 
function ShowItemLayer.create()
    local item = ShowItemLayer:new()
    item:init()
    local function onNodeEvent(event)
        if event == "enter" then
            item:onEnter()
        elseif event == "exit" then
            item:onExit()
        end
    end
    
    item:registerScriptHandler(onNodeEvent)

    return item   
end

function ShowItemLayer.getInstance()
    if not MGShowItemLayer then
        MGShowItemLayer = ShowItemLayer.create()
    end
    return MGShowItemLayer
end

function ShowItemLayer.show(pos, infoex,itemType)
    local runScene = cc.Director:getInstance():getRunningScene();
    ShowItemLayer.getInstance():setAnchorPoint(cc.p(0,0));
    ShowItemLayer.getInstance():setPosition(pos);
    ShowItemLayer.getInstance():setData(infoex,itemType);
    runScene:addChild(ShowItemLayer.getInstance(),ZORDER_EXTREME);
end

function ShowItemLayer.hide()
    if MGShowItemLayer then
        if MGShowItemLayer:getParent() then
            MGShowItemLayer:removeFromParent();
        end
        MGShowItemLayer = nil;
    end
end

---------------------------------------------------------------------


Item = class("Item", function()
    return ccui.ImageView:create();
end)


function Item:ctor()
    self.itemInfo = {};
    self.gm = nil;
    self.isShowTip = true;
    self.isVisible = true;
    self.nodes = {};
    self:init();
end

function Item:init()
    --背景
    self:loadTexture("com_item_bg.png",ccui.TextureResType.plistType);
    self:setPosition(cc.p(self:getContentSize().width/2, self:getContentSize().height/2));
    self:setTouchEnabled(true);
    self:addTouchEventListener(handler(self,self.onBtnClick));
    self.size = self:getContentSize();

    --头像框
    self.boxSpr = cc.Sprite:createWithSpriteFrameName("com_item_box_2.png");
    self.boxSpr:setPosition(cc.p(self:getContentSize().width/2, self:getContentSize().height/2));
    self:addChild(self.boxSpr);
    table.insert(self.nodes,self.boxSpr);

    --头像
    self.headSpr = cc.Sprite:create();
    self.headSpr:setPosition(cc.p(self:getContentSize().width/2, self:getContentSize().height/2));
    self:addChild(self.headSpr);
    self.oldHeadProgram = self.headSpr:getShaderProgram();
    table.insert(self.nodes,self.headSpr);

    --数量
    self.numLabel = cc.Label:createWithTTF("0", ttf_msyh, 22);
    self.numLabel:setAnchorPoint(cc.p(1,0.5));
    self.numLabel:setPosition(cc.p(self.size.width-5,12));
    self.numLabel:enableOutline(cc.c4b(  0,   0,   0, 255),1);
    self:addChild(self.numLabel,2);
    self.numLabel:setAdditionalKerning(-2);

    self.nameLabel = cc.Label:createWithTTF("", ttf_msyh, 22);
    self.nameLabel:setPosition(cc.p(self:getContentSize().width/2, -30));
    self.nameLabel:setVisible(false);
    self:addChild(self.nameLabel);
end

function Item:setData(gm)
    if self.gm then
        self.gm:release();
        self.gm = nil;
    end
    self.gm = gm;
    self.gm:retain();

    if self.gm then
        self.itemType = self.gm:getItemType();
        MGRCManager:cacheResource("Item", self.gm:pic());
        self.headSpr:setSpriteFrame(self.gm:pic());
        self.headSpr:setScale(85/self.headSpr:getContentSize().width);
        local filename = ResourceData:getBoxPic(self.gm:getQuality());
        self.boxSpr:setSpriteFrame(filename);
        if self.gm:getQuality() <= 1 then
            self.boxSpr:setVisible(false);
        end
        self.headSpr:setVisible(true);
        self.numLabel:setVisible(self.isVisible);
        self.numLabel:setString(self.gm:getNum());
        self.nameLabel:setString(self.gm:name());
        self.nameLabel:setColor(ResourceData:getTitleColor(self.gm:getQuality()));

        self:setItemInfo(self.gm);
    else
        self.gid = 0;
        self.headSpr:setVisible(false);
        self.numLabel:setVisible(false);
        self.nameLabel:setVisible(false);
        self.boxSpr:setSpriteFrame("com_item_box_2.png");
    end
end

function Item:setItemInfo(gm)
    self.itemInfo = {};
    self.itemInfo.type = gm:getItemType();
    self.itemInfo.id = gm:getItemId();
    self.itemInfo.num = gm:getNum();
    self.itemInfo.name = gm:name();
    self.itemInfo.desc = gm:desc();
    self.itemInfo.pic = gm:pic();
    self.itemInfo.quality = gm:getQuality();
    self.itemInfo.get_go = gm:getGetGoInfo();
end

function Item:getItemInfo()
    return self.itemInfo;
end

function Item:setShowTip(isShowTip)--设置是否显示Tip
    if nil == isShowTip then
        self.isShowTip = true;
    else
        self.isShowTip = isShowTip;
    end
end

function Item:setNeedNum(num)
    self.numLabel:setPosition(cc.p(self.size.width-2,12));
    self.numLabel:setString(string.format("/%d",num));
    --数量
    self.needLabel = cc.Label:createWithTTF("1", ttf_msyh, 22);
    self.needLabel:setAnchorPoint(cc.p(1,0.5))
    self.needLabel:setPosition(cc.p(self.size.width-2-self.numLabel:getContentSize().width,12));
    self.needLabel:enableOutline(Color4B.BLACK,1);
    self:addChild(self.needLabel,2);
    if num<=self.gm:getNum() then
        self.needLabel:setColor(Color3B.GREEN);
    else
        self.needLabel:setColor(Color3B.RED);
    end
    self.needLabel:setString(string.format("%d",self.gm:getNum()));
end

function Item:setSel(isel)
    if isel then
        if self.selspr==nil then
            self.selspr = cc.Sprite:createWithSpriteFrameName("com_selected_box.png");
            self.selspr:setPosition(cc.p(self:getContentSize().width/2, self:getContentSize().height/2));
            self.selspr:setScale(115/self.selspr:getContentSize().width);
            self:addChild(self.selspr,10);
        else
            self.selspr:setVisible(true);
        end
    else
        if self.selspr then
            self.selspr:setVisible(false);
        end
    end
end

function Item:numHide()
    self.numLabel:setVisible(false);
end

function Item:setNum(num)
    self.numLabel:setString(num);
end

function Item:setNumVisible(isVisible)
    self.isVisible = isVisible;
    self.numLabel:setVisible(isVisible);
end

function Item:setNameVisible(isVisible)
    self.nameLabel:setVisible(isVisible);
end

function Item:setIsGray(isGray)
    self.isGray = isGray;
    if isGray then
        self.numLabel:setColor(Color3B.GRAY);
        self.nameLabel:setColor(Color3B.GRAY);
        for i=1,#self.nodes do
            self.nodes[i]:setShaderProgram(MGGraySprite:getGrayShaderProgram());
        end
    else
        self.boxSpr:setColor(Color3B.WHITE);
        self.numLabel:setColor(cc.c3b(255,230,116));
        self.nameLabel:setString(self.gm:name());
        for i=1,#self.nodes do
            self.nodes[i]:setShaderProgram(self.oldHeadProgram);
        end
    end
end

function Item:onBtnClick(sender, eventType)
    if eventType == ccui.TouchEventType.began then
        if self.isShowTip == true then
            local winSize = cc.Director:getInstance():getWinSize();
            local startPos = nil;
            startPos = self:getParent():convertToWorldSpace(cc.p(self:getPositionX(),self:getPositionY()));
            ShowItemLayer.show(startPos, self.gm, self.itemType);
            if startPos.x + ShowItemLayer.getInstance():getContentSize().width > winSize.width-10 then
                startPos.x = startPos.x-ShowItemLayer.getInstance():getContentSize().width;
            end

            if startPos.y + ShowItemLayer.getInstance():getContentSize().height > winSize.height-10 then
                startPos.y = startPos.y-ShowItemLayer.getInstance():getContentSize().height;
            end
            
            ShowItemLayer.getInstance():setPos(startPos);
        end
    elseif eventType==ccui.TouchEventType.moved then
            local startPos=self:getTouchStartPos();
            local movePos=self:getTouchMovePos();
            if math.abs(movePos.x-startPos.x)>6 or math.abs(movePos.y-startPos.y)>6 then
                    if self.isShowTip == true then
                            ShowItemLayer.hide();
                    end
            end
    elseif eventType == ccui.TouchEventType.canceled then
            if self.isShowTip == true then
                ShowItemLayer.hide();
            end
    elseif eventType == ccui.TouchEventType.ended then
        if self.isShowTip == true then
            ShowItemLayer.hide();
        else
            if self.delegate and self.delegate.ItemSelect then
                self.delegate:ItemSelect(self);
            end
        end
    end
end

function Item:onEnter()

end

function Item:onExit()
    MGRCManager:releaseResources("Item")
    if self.gm then
        self.gm:release();
        self.gm = nil;
    end
end

function Item.create(delegate)
    local layer = Item:new()
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

ItemFunc = function(delegate)
    local item = Item.create(delegate)
    return item
end
MGItem = class("MGItem",ItemFunc)

---------------------------------------------------------------------


OtherItem = class("OtherItem", MGItem)

function OtherItem:ctor()
    self.itemInfo = {};
    self:init();
end

function OtherItem:init()

end

function OtherItem:setData(type,id,num)
    if nil == num then
        num = 0;
    end

    local sql = string.format("select * from item_type where id=%d and isonly=%d",type,id);
    local DBData = LUADB.select(sql, "name:desc:icon:get_go");
    if DBData then
        self.gm = {};
        self.gm.type = type;
        self.gm.id = id;
        self.gm.num = num;
        self.gm.name = DBData.info.name;
        self.gm.desc = DBData.info.desc;
        self.gm.pic = DBData.info.icon..".png";
        self.gm.quality = 2;
        self.gm.get_go = {};
        if tonumber(DBData.info.get_go) == 0 then
            self.gm.get_go = 0
        else
            self.gm.get_go = getneedlist(DBData.info.get_go);
        end
        self.itemType = self.gm.type;

        MGRCManager:cacheResource("OtherItem", self.gm.pic);
        self.headSpr:setSpriteFrame(self.gm.pic);
        self.headSpr:setScale(85/self.headSpr:getContentSize().width);
        local filename = ResourceData:getBoxPic(self.gm.quality);
        self.boxSpr:setSpriteFrame(filename);
        if self.gm.quality <= 1 then
            self.boxSpr:setVisible(false);
        end
        self.headSpr:setVisible(true);
        self.numLabel:setVisible(self.isVisible);
        self.numLabel:setString(self.gm.num);
        self.nameLabel:setString(self.gm.name);
        self.nameLabel:setColor(ResourceData:getTitleColor(self.gm.quality));
        self.itemInfo = self.gm;
    else
        self.gid = 0;
        self.headSpr:setVisible(false);
        self.numLabel:setVisible(false);
        self.nameLabel:setVisible(false);
        self.boxSpr:setSpriteFrame("com_item_box_2.png");
    end
end

function OtherItem:getItemInfo()
    return self.itemInfo;
end

function OtherItem:onEnter()

end

function OtherItem:onExit()
    MGRCManager:releaseResources("OtherItem");
end

function OtherItem.create(delegate)
    local layer = OtherItem:new()
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
