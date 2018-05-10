-- 武将列表Item
local CCHeroItem=class("CCHeroItem",function()
    return cc.Layer:create();
end);

function CCHeroItem:ctor(type)
    -- 1祈祷/2祝福
    self.type=type;
    self.delegate=nil;
    self.isChoose=false;

    self.bgImg=ccui.ImageView:create("com_checkbox.png", ccui.TextureResType.plistType);
    self.bgImg:setAnchorPoint(cc.p(0,0));
    self:addChild(self.bgImg);
    self.bgImg:setScale9Enabled(true);
    self.bgImg:setCapInsets(cc.rect(29, 19, 1, 10));
    -- 
    self.bgImg:setSize(cc.size(118, 160));

    local size=self.bgImg:getContentSize();
    self.bgRect=cc.rect(0, 0, size.width, size.height);

    self.headItem=HeroHeadEx.create(self);
    self.headItem:setPosition(cc.p(size.width/2,size.height/2+20));
    self:addChild(self.headItem,1);
    self.headItem:setTouchEnabled(false);
    -- 名字
    self.nameLabel = cc.Label:createWithTTF("", ttf_msyh, 22);
    self:addChild(self.nameLabel);
    -- 
    if self.type==1 then
        -- 经验
        self.panel_exp = ccui.ImageView:create("com_progress_bar_bg.png", ccui.TextureResType.plistType);
        self:addChild(self.panel_exp,1);
        self.panel_exp:setScaleX((size.width-20)/self.panel_exp:getContentSize().width);
        self.panel_exp:setScaleY(12/self.panel_exp:getContentSize().height);
        self.panel_exp:setAnchorPoint(cc.p(0.5, 0.5));
        self.panel_exp:setPosition(cc.p(size.width/2, size.height/2-self.headItem:getContentSize().height/2+7));

        self.progressbar_exp = ccui.LoadingBar:create();
        self.progressbar_exp:loadTexture("com_progress_bar.png", ccui.TextureResType.plistType);
        self.panel_exp:addChild(self.progressbar_exp);
        self.progressbar_exp:setScaleX(self.panel_exp:getContentSize().width/self.progressbar_exp:getContentSize().width);
        self.progressbar_exp:setScaleY(12/self.progressbar_exp:getContentSize().height);
        self.progressbar_exp:setAnchorPoint(cc.p(0, 0.5));
        self.progressbar_exp:setPosition(cc.p(2, self.panel_exp:getContentSize().height/2));
        -- 
        self.nameLabel:setPosition(cc.p(size.width/2,size.height/2-self.headItem:getContentSize().height/2-15));
        -- 选中标记
        self.selspr=cc.Sprite:createWithSpriteFrameName("com_checkbox_tick.png");
        self:addChild(self.selspr,10);
        self.selspr:setPosition(size.width/2,size.height/2+20);
        self.selspr:setVisible(false);
    else
        self.nameLabel:setPosition(cc.p(size.width/2,size.height/2-self.headItem:getContentSize().height/2-10));
    end
end

function CCHeroItem:addTouch(touchHandler)
    local listenner=cc.EventListenerTouchOneByOne:create();
    listenner:setSwallowTouches(false);
    listenner:registerScriptHandler(handler(self,self.onTouchBegin),cc.Handler.EVENT_TOUCH_BEGAN);
    listenner:registerScriptHandler(handler(self,self.onTouchMove),cc.Handler.EVENT_TOUCH_MOVED);
    listenner:registerScriptHandler(touchHandler,cc.Handler.EVENT_TOUCH_ENDED);
    local eventDispatcher=self:getEventDispatcher();
    eventDispatcher:removeEventListenersForTarget(self);
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner,self);
end

function CCHeroItem:onTouchBegin(touch, event)
    local point=self.bgImg:convertToNodeSpace(touch:getLocation());
    if not cc.rectContainsPoint(self.bgRect, point) then
        return false
    end
    self.isMove=false;
    self.touchPoint=touch:getLocation();
    return true;
end

function CCHeroItem:onTouchMove(touch,event)
    local oldPoint=touch:getLocation();
    if math.abs(oldPoint.y-self.touchPoint.y)>10 then
        self.isMove=true;
    end
end

function CCHeroItem:updataData()
    self.headItem:setData(self.data);
    self.nameLabel:setString(self.data:name());
    self.nameLabel:setColor(ResourceData:getTitleColor(self.data:getQuality()));
    -- 
    if self.type==1 then
        local expVal=self.data:getExp();
        -- print("expVal===",expVal)
        local DBData=LUADB.select(string.format("select need_exp from general_lv where lv=%d",self.data:getLevel()+1), "need_exp");
        if DBData==nil then
            DBData=LUADB.select(string.format("select need_exp from general_lv where lv=%d",self.data:getLevel()), "need_exp");
        end
        local maxExpVal=tonumber(DBData.info.need_exp);
        -- print("maxExpVal===",maxExpVal)
        if maxExpVal<=0 then
            maxExpVal=1;
        end
        local percent=expVal*100/maxExpVal;
        percent=math.ceil(percent);
        self.progressbar_exp:setPercent(percent);
    end
end
--
function CCHeroItem:initData(delegate, data)
    self.delegate=delegate;
    if data then
        self.data=data;
        self:updataData();
        self:addTouch(handler(self,self.onClick));
    else
        self:setVisible(false);
        self:getEventDispatcher():removeEventListenersForTarget(self);
    end
end

function CCHeroItem:onClick(touch, event)
    local y=touch:getLocation().y;
    print("y=== %d", y)
    -- 
    local y1=110;
    local y2=580;
    if self.type==1 then
        y1=110;
        y2=625;
    end
    if not self.isMove and y>y1 and y<y2 then
        if self.type==1 then
            if self.isChoose then
                self.isChoose=false;
            else
                self.isChoose=true;
            end
            -- 
            if self.isChoose then
                if self.delegate.label_chNum then
                    if self.delegate.label_chNum:isVisible()==false then
                        MGMessageTip:showFailedMessage(MG_TEXT("PrayerPoint_3"));
                        return
                    end
                end
            end
            self.selspr:setVisible(self.isChoose);
        end
        if self.delegate then
            self.delegate:clickHeroItem(self);
        end
    end
end

-- function CCHeroItem:setView(view)
--     self.view=view;
-- end

return CCHeroItem;
