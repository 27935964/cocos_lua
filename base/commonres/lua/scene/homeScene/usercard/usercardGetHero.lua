-----------------------将领属性界面------------------------

usercardGetHero = class("usercardGetHero", MGLayer)

function usercardGetHero:ctor()
    self:init();
end

function usercardGetHero:init()
    MGRCManager:cacheResource("usercardGetHero", "user_card_guang.png");
    local pWidget = MGRCManager:widgetFromJsonFile("usercardGetHero","usercard_ui_5.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);--设置描边或者阴影
    
    local Panel_2 = pWidget:getChildByName("Panel_2");
    self.Panel_2 = Panel_2;
    self.Panel_2:addTouchEventListener(handler(self,self.onButtonClick));

    self.Image_pic = Panel_2:getChildByName("Image_pic");
    local Image_bg2 = Panel_2:getChildByName("Image_bg2");
    local action = cc.RotateBy:create(0.5, 15);
    Image_bg2:runAction(cc.RepeatForever:create(action));

    local Image_titleBg = Panel_2:getChildByName("Image_titleBg");
    local Panel_star = Image_titleBg:getChildByName("Panel_star");
    self.Label_name =  Image_titleBg:getChildByName("Label_name");
    self.Label_name:setSkewX(20);
    self.Image_stars = {};
    for i=1,5 do
        local Image_star = Panel_star:getChildByName(string.format("Image_star_%d",i))
        Image_star:setVisible(false);
        table.insert(self.Image_stars, Image_star)
    end

end

function usercardGetHero:setData(gm)
    local star = gm:getStar();
    for i=1,star do
        local img=string.format("user_card_star%d.png",gm:getRare());
        self.Image_stars[i]:loadTexture(img,ccui.TextureResType.plistType);
        self.Image_stars[i]:setVisible(true); 
    end
    if  star == 1 then
        self.Image_stars[1]:setPosition(cc.p(100,46));
    elseif  star == 2 then
        self.Image_stars[1]:setPosition(cc.p(80,40));
        self.Image_stars[2]:setPosition(cc.p(120,51));
    elseif  star == 3 then
        self.Image_stars[1]:setPosition(cc.p(60,35));
        self.Image_stars[2]:setPosition(cc.p(100,46));
        self.Image_stars[3]:setPosition(cc.p(140,57));
    elseif  star == 4 then
        self.Image_stars[1]:setPosition(cc.p(40,29));
        self.Image_stars[2]:setPosition(cc.p(80,40));
        self.Image_stars[3]:setPosition(cc.p(120,51));
        self.Image_stars[4]:setPosition(cc.p(160,62));
    end
    self.Label_name:setText(gm:name());
    MGRCManager:cacheResource("usercardGetHero", gm:pic());
    self.Image_pic:loadTexture(gm:pic(),ccui.TextureResType.plistType);
end

function usercardGetHero:onButtonClick(sender, eventType)
    buttonClickScale(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        if sender == self.Panel_2 then
            if self.delegate and self.delegate.GetHeroShow then
                self.delegate:GetHeroShow();
            end
            self:removeFromParent();
        end
    end
end



function usercardGetHero:onEnter()

end

function usercardGetHero:onExit()
    MGRCManager:releaseResources("usercardGetHero");
end

function usercardGetHero.create(delegate)
    local layer = usercardGetHero:new()
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
