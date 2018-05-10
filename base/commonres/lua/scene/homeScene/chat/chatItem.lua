require "userHead"

chatItem = class("chatItem",function()  
    return ccui.Layout:create();
end)

function chatItem:ctor()
    self:init()
end

function chatItem:init()
    self:setSize(cc.size(586, 120));
    self:setAnchorPoint(cc.p(0.5,0.5));

    self.heroHead = userHead.create(self);
    self.heroHead:setAnchorPoint(cc.p(0.5, 0.5));
    self.heroHead:setPosition(cc.p(60,self:getContentSize().height-60));
    self:addChild(self.heroHead,1);

    self.lvLabel = cc.Label:createWithTTF("10", ttf_msyh, 20);
    self.lvLabel:setAnchorPoint(cc.p(1,0.5));
    self.lvLabel:setPosition(cc.p(self.heroHead:getContentSize().width-5,15));
    self.lvLabel:enableOutline(cc.c4b(  0,   0,   0, 255),1);
    self.heroHead:addChild(self.lvLabel,2);
    self.lvLabel:setAdditionalKerning(-2);

    self.vipBg = cc.Sprite:createWithSpriteFrameName("com_vip_bg.png");
    self.vipBg:setPosition(cc.p(5,self.heroHead:getContentSize().height-5));
    self.heroHead:addChild(self.vipBg,2);

    self.vipSpr = cc.Sprite:createWithSpriteFrameName("com_vip.png");
    self.vipSpr:setPosition(cc.p(12,self.vipBg:getContentSize().height/2));
    self.vipBg:addChild(self.vipSpr);

    self.numLabel = cc.LabelBMFont:create("0", "warscore_num.fnt");
    self.numLabel:setAnchorPoint(cc.p(0,0.5));
    self.numLabel:setScale(0.8);
    self.numLabel:setPosition(cc.p(self.vipSpr:getPositionX()+3,self.vipSpr:getPositionY()-2));
    self.vipBg:addChild(self.numLabel);

    self.markSpr = cc.Sprite:createWithSpriteFrameName("Chat_Channel_System.png");
    self.markSpr:setPosition(cc.p(120+self.markSpr:getContentSize().width/2,self:getSize().height-self.markSpr:getContentSize().height/2-10));
    self:addChild(self.markSpr);

    self.nameLabel = cc.Label:createWithTTF("",ttf_msyh,22);
    self.nameLabel:setAnchorPoint(cc.p(0, 0.5));
    self.nameLabel:setPosition(cc.p(self.markSpr:getPositionX()+50, self.markSpr:getPositionY()));
    self:addChild(self.nameLabel);

    self.statusSpr = cc.Sprite:createWithSpriteFrameName("Chat_elite.png");
    self.statusSpr:setAnchorPoint(cc.p(0,0.5));
    self.statusSpr:setPosition(cc.p(self.nameLabel:getPositionX()+self.nameLabel:getContentSize().width
        +10,self.markSpr:getPositionY()));
    self:addChild(self.statusSpr);
    self.statusSpr:setVisible(false);

    self.bgSpr = ccui.ImageView:create("Chat_Bubble.png", ccui.TextureResType.plistType);
    self.bgSpr:setAnchorPoint(cc.p(0, 1));
    self.bgSpr:setPosition(cc.p(self.markSpr:getPositionX()-35, self.markSpr:getPositionY()-30));
    self.bgSpr:setScale9Enabled(true);
    self.bgSpr:setCapInsets(cc.rect(35, 35, 1, 1));
    self.bgSpr:setSize(cc.size(445, 60));
    self:addChild(self.bgSpr);

    self.descLabel = MGColorLabel:label();--聊天内容
    self.descLabel:setAnchorPoint(cc.p(0, 0.5));
    self.descLabel:setPosition(cc.p(self.markSpr:getPositionX(),self.bgSpr:getPositionY()-self.bgSpr:getContentSize().height/2));
    self:addChild(self.descLabel,1);
end

function chatItem:setData(data)
    self.data = data;
    if tonumber(self.data.type) == 203 then--203是频道聊天，204是私聊
        if tonumber(self.data.channel) == 100 then--系统聊天
            self.markSpr:setSpriteFrame("Chat_Channel_System.png");
        elseif tonumber(self.data.channel) == 200 then--世界聊天
            self.markSpr:setSpriteFrame("Chat_Channel_World.png");
        elseif string.sub(self.data.channel,1,3) == "201" then--公会聊天
            self.markSpr:setSpriteFrame("Chat_Channel_Guild.png");
            self.statusSpr:setVisible(true);
        end
    elseif tonumber(self.data.type) == 204 then
        self.markSpr:setSpriteFrame("Chat_Channel_PrivateChat.png");
    end

    if 0 ~= tonumber(self.data.uid) then
        self.attData = spliteStr(self.data.att,':');--1.头像，名称，玩家等级，vip等级等
        self.nameLabel:setString(self.attData[2]);
        self.numLabel:setString(self.attData[4]);
        if tonumber(self.attData[4]) <= 0 then
            self.vipBg:setVisible(false);
        end
        self.lvLabel:setVisible(true);
        self.lvLabel:setString(self.attData[3]);
        local gm = GENERAL:getAllGeneralModel(tonumber(self.attData[1]));
        if gm then
            self.heroHead:setData(gm);
        end
    elseif 0 == tonumber(self.data.uid) then--系统
        self.markSpr:setSpriteFrame("Chat_Channel_System.png");
        self.nameLabel:setVisible(false);
        self.vipBg:setVisible(false);
        self.lvLabel:setVisible(false);
    end
    self.descLabel:clear();
    self.descLabel:appendStringAutoWrap(self.data.text,18,1,cc.c3b(109,005,000),22);
    
    local x = 445;
    local y = 60;
    if self.descLabel:getContentSize().width < 445 then
        x = self.descLabel:getContentSize().width+50;
    end
    if self.descLabel:getContentSize().height > 50 then
        y = self.descLabel:getContentSize().height+10;
    end
    self.bgSpr:setSize(cc.size(x, y));
    self.descLabel:setPosition(cc.p(self.markSpr:getPositionX(),self.bgSpr:getPositionY()-self.bgSpr:getContentSize().height/2));

    if self.data.uid == ME:getUid() then
        self.heroHead:setPositionX(self:getContentSize().width-60);
        self.vipBg:setPositionX(self.heroHead:getContentSize().width-5);
        self.markSpr:setPositionX(self:getContentSize().width-(120+self.markSpr:getContentSize().width/2));
        self.nameLabel:setAnchorPoint(cc.p(1, 0.5));
        self.nameLabel:setPositionX(self.markSpr:getPositionX()-50);
        self.statusSpr:setPositionX(self.nameLabel:getPositionX()+self.nameLabel:getContentSize().width-10)
        self.bgSpr:setPositionX(self.markSpr:getPositionX()+35);
        self.bgSpr:setScaleX(-1);
        self.descLabel:setAnchorPoint(cc.p(1, 0.5));
        self.descLabel:setPositionX(self.markSpr:getPositionX());
    end
end

function chatItem:HeroHeadSelect(item)
    if self.data.uid == ME:getUid() or 0 == tonumber(self.data.uid) then
        return;
    end
    if self.delegate and self.delegate.HeroHeadSelect then
        self.delegate:HeroHeadSelect(self);
    end
end

function chatItem:onEnter()

end

function chatItem:onExit()
    MGRCManager:releaseResources("chatItem");
end

function chatItem.create(delegate)
    local layer = chatItem:new()
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
