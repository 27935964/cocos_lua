-----------------------公会战争作坊--获取宝物界面------------------------

guildBoxObtain = class("guildBoxObtain", MGLayer)

function guildBoxObtain:ctor()
    self.curItem = nil;
    self:init();
end

function guildBoxObtain:init()
    MGRCManager:cacheResource("guildBoxObtain", "jump_ui.png","jump_ui.plist");
    local pWidget = MGRCManager:widgetFromJsonFile("guildBoxObtain","WarWorkshopUi_2.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:setAnchorPoint(cc.p(0.5, 0.5));
    CommonMethod:setFullBgScale(self.Panel_1);
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));

    local Panel_2 = pWidget:getChildByName("Panel_2");

    self.ListView = Panel_2:getChildByName("ListView");
    self.ListView:setScrollBarVisible(false);

    self.Button_close = Panel_2:getChildByName("Button_close");--关闭
    self.Button_close:addTouchEventListener(handler(self,self.onButtonClick));

    self.Image_title = Panel_2:getChildByName("Image_title");
    
end

function guildBoxObtain:readSql(typeid)--解析数据库数据
    self.union_box = {};
    local sql = string.format("select * from union_box_accessway where typeid="..typeid);
    local DBDataList = LUADB.selectlist(sql, "id:name:pic:des");

    for index=1,#DBDataList.info do
        local DBData = {};
        DBData.id = tonumber(DBDataList.info[index].id);
        DBData.name = DBDataList.info[index].name;
        DBData.pic = DBDataList.info[index].pic;
        DBData.des = DBDataList.info[index].des;

        self.union_box[DBData.id]=DBData;
    end
end

function guildBoxObtain:setData(type)--1.获取秘宝,2.获取功勋
    self.data = data;
    self.type = type;
    self:readSql(self.type);

    self:creatItem();
end

function guildBoxObtain:setTitle(fileName)
    self.Image_title:loadTexture(fileName,ccui.TextureResType.plistType);
end

function guildBoxObtain:creatItem()
    self.ListView:removeAllItems();
    for i=1,#self.union_box do
        local layout = ccui.Layout:create();
        layout:setAnchorPoint(cc.p(0.5,0.5));
        layout:setSize(cc.size(self.ListView:getContentSize().width, 132));

        local img = ccui.ImageView:create(self.union_box[i].pic..".png", ccui.TextureResType.plistType);
        img:setPosition(cc.p(layout:getContentSize().width/2, layout:getContentSize().height/2));
        layout:addChild(img);

        local descLabel = MGColorLabel:label();
        descLabel:setAnchorPoint(cc.p(0, 0.5));
        descLabel:setPosition(cc.p(17, layout:getContentSize().height/4+10));
        layout:addChild(descLabel);

        descLabel:clear();
        descLabel:appendStringAutoWrap(self.union_box[i].des,14,1,cc.c3b(255,255,255),22);


        self.ListView:pushBackCustomItem(layout);
    end
end

function guildBoxObtain:onButtonClick(sender, eventType)
    if sender == self.Button_close then
        buttonClickScale(sender, eventType);
    end
    if eventType == ccui.TouchEventType.ended then
        self:removeFromParent();
    end
end

function guildBoxObtain:onEnter()

end

function guildBoxObtain:onExit()
    MGRCManager:releaseResources("guildBoxObtain");
end

function guildBoxObtain.create(delegate)
    local layer = guildBoxObtain:new()
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

function guildBoxObtain.showBox(delegate)
    local layer = guildBoxObtain.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
