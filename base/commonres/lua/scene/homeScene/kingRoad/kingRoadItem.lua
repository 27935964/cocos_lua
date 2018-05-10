--------------------------君王之路Item-----------------------

local kingRoadItem = class("kingRoadItem", MGWidget)

function kingRoadItem:init(delegate,widget)
    self.delegate=delegate;
    self:addChild(widget);
    self.pWidget = widget;

    local Panel_2 = self.pWidget:getChildByName("Panel_2");
    self:setContentSize(Panel_2:getContentSize());

    self.Image_CrownFlag = Panel_2:getChildByName("Image_CrownFlag");
    self.Image_AchievementPoints = Panel_2:getChildByName("Image_AchievementPoints");

    self.Image_mark = Panel_2:getChildByName("Image_mark");
    self.Image_name = Panel_2:getChildByName("Image_name");
    self.oldHeadProgram = self.Image_mark:getSprit():getShaderProgram();

    self.Label_Instrution = Panel_2:getChildByName("Label_Instrution");
    self.Label_Instrution:setVisible(false);
    self.descLabel = MGColorLabel:label();
    self.descLabel:setPosition(self.Label_Instrution:getPosition());
    Panel_2:addChild(self.descLabel);

    self.Label_Need = Panel_2:getChildByName("Label_Need");
    self.Label_Need:setVisible(false);
    self.tipLabel = MGColorLabel:label();
    self.tipLabel:setPosition(self.Label_Need:getPosition());
    Panel_2:addChild(self.tipLabel);
    self.tipLabel:clear();
    self.tipLabel:appendStringAutoWrap(MG_TEXT("kingRoadMainLayer_1"),2,1,cc.c3b(255,255,255),22);
    self.tipLabel:enableShadow(cc.c4b(0,   0,   0, 191), cc.size(2, -2),2);

    self.Label_Point = Panel_2:getChildByName("Label_Point");
    self.Label_Point:setVisible(false);
    self.numLabel = MGColorLabel:label();
    -- self.numLabel:setAnchorPoint(cc.p(0,0.5));
    self.numLabel:setPosition(self.Label_Point:getPosition());
    Panel_2:addChild(self.numLabel);
end

function kingRoadItem:setData(data,king_lv)
    self.data = data;
    self.king_lv = king_lv;

    local curLv = tonumber(data.a_lv);
    self.Image_mark:loadTexture(self.king_lv.pic..".png",ccui.TextureResType.plistType);
    self.Image_name:loadTexture(self.king_lv.name_pic..".png",ccui.TextureResType.plistType);
    
    self.descLabel:clear();
    self.descLabel:appendStringAutoWrap(self.king_lv.des,5,1,cc.c3b(255,255,255),22);
    self.descLabel:enableShadow(cc.c4b(0,   0,   0, 191), cc.size(2, -2),2);

    self.numLabel:clear();
    self.numLabel:appendStringAutoWrap(self.king_lv.need_achievement,2,1,cc.c3b(255,255,255),22);
    self.numLabel:enableShadow(cc.c4b(0,   0,   0, 191), cc.size(2, -2),2);

    self:setIsGray(true);
    if self.king_lv.lv <= tonumber(data.a_lv) then
        self:setIsGray(false);
    end
end

function kingRoadItem:setIsGray(isGray)
    if isGray then
        self.Image_CrownFlag:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
        self.Image_AchievementPoints:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
        self.Image_mark:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());
        self.Image_name:getSprit():setShaderProgram(MGGraySprite:getGrayShaderProgram());

        for i=0,10 do
            self.descLabel:setColor(i,cc.c3b(127,127,127));
        end
        self.tipLabel:setColor(0,cc.c3b(127,127,127));
        self.numLabel:setColor(0,cc.c3b(127,127,127));
    else
        self.Image_CrownFlag:getSprit():setShaderProgram(self.oldHeadProgram);
        self.Image_AchievementPoints:getSprit():setShaderProgram(self.oldHeadProgram);
        self.Image_mark:getSprit():setShaderProgram(self.oldHeadProgram);
        self.Image_name:getSprit():setShaderProgram(self.oldHeadProgram);

        self.descLabel:clear();
        self.descLabel:appendStringAutoWrap(self.king_lv.des,5,1,cc.c3b(255,255,255),22);
        self.descLabel:enableShadow(cc.c4b(0,   0,   0, 191), cc.size(2, -2),2);

        self.tipLabel:setColor(0,cc.c3b(255,255,255));
        self.numLabel:setColor(0,cc.c3b(255,255,255));
    end
end

function kingRoadItem:onEnter()
    
end

function kingRoadItem:onExit()
    MGRCManager:releaseResources("kingRoadItem");
end

function kingRoadItem.create(delegate,widget)
    local layer = kingRoadItem:new()
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

return kingRoadItem