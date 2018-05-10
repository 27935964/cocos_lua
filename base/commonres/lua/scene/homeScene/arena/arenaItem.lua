require "utf8"
arenaItem = class("arenaItem", function()
    return ccui.Layout:create();
end)

function arenaItem:ctor()

end

function arenaItem:init(delegate,widget)
    self.delegate=delegate;
    self:addChild(widget);
    self.pWidget = widget;

    local Panel_1 = self.pWidget:getChildByName("Panel_1");
    self:setSize(Panel_1:getSize())

    self.Image_bg = Panel_1:getChildByName("Image_bg");
    self.Image_bg:addTouchEventListener(handler(self,self.onButtonClick));

    self.rankBg = Panel_1:getChildByName("Image_23");

    self.Label_name = Panel_1:getChildByName("Label_name");
    self.Label_lv = Panel_1:getChildByName("Label_lv");
    self.Label_lv:setVisible(false);

    self.lvLabel = cc.Label:createWithTTF("",ttf_msyh,22);
    self.lvLabel:setPosition(self.Label_lv:getPosition());
    Panel_1:addChild(self.lvLabel,3);
    self.lvLabel:enableShadow(cc.c4b( 0,   0,   0, 191), cc.size(2, -2),1);

    self.Label_rank = Panel_1:getChildByName("Label_rank");
    self.Label_rank:setVisible(false);
    self.rankLabel = cc.Label:createWithTTF("",ttf_msyh,22);
    self.rankLabel:setPosition(self.Label_rank:getPosition());
    Panel_1:addChild(self.rankLabel,4);
    self.rankLabel:enableShadow(cc.c4b( 0,   0,   0, 191), cc.size(2, -2),1);

    local Image_sorce = Panel_1:getChildByName("Image_sorce");
    local Label_score_name = Image_sorce:getChildByName("Label_score_name");
    Label_score_name:setText(MG_TEXT_COCOS("arena_ui_1"));
    self.Label_score = Image_sorce:getChildByName("Label_score");

    self.Image_award = Panel_1:getChildByName("Image_award");
    local Label_award_name = self.Image_award:getChildByName("Label_award_name");
    Label_award_name:setText(MG_TEXT_COCOS("arena_ui_2"));
    self.Label_award = self.Image_award:getChildByName("Label_award");

    self.Button_do= Panel_1:getChildByName("Button_do");
    self.Button_do:addTouchEventListener(handler(self,self.onButtonClick));
    self.Label_do = self.Button_do:getChildByName("Label_do");
    self.Label_do:setText(MG_TEXT_COCOS("arena_ui_3"));
    self.Label_do:getLabel():enableShadow(Color4B.BLACK, cc.size(1, -1),1);

    local Panel_hero = Panel_1:getChildByName("Panel_hero");
    Panel_hero:setClippingEnabled(true);
    self.Image_hero = Panel_hero:getChildByName("Image_hero");

end

function arenaItem:setData(data)
    self.data = data;
    self.Label_name:setText(data.name);
    self.lvLabel:setString("Lv."..data.lv);
    self.rankLabel:setString(data.ranking);
    self.Label_score:setText(data.score);
    self.Image_hero:loadTexture(data.pic, ccui.TextureResType.plistType)

    if data.is_worship ==0 then
        self.Label_do:setText(MG_TEXT_COCOS("arena_ui_3"));
        if data.is_atk==1 then
            self.Button_do:setBright(true);
            self.Button_do:setTouchEnabled(true);
        else
            self.Button_do:setBright(false);
            self.Button_do:setTouchEnabled(false);
        end
    else
        
        self.Label_do:setText(MG_TEXT_COCOS("arena_ui_4"));
    end


    if data.gold == 0 then
        self.Image_award:setVisible(false);
    else
        self.Image_award:setVisible(true);
        self.Label_award:setText(data.gold);
    end

    self:setRankBg(tonumber(data.ranking));
end

function arenaItem:setRankBg(rank)
    local pic = "arena_bg_1.png";
    if rank == 1 then
        pic = "arena_bg_1.png";
    elseif rank == 2 then
        pic = "arena_bg_2.png";
    elseif rank == 3 then
        pic = "arena_bg_3.png";
    elseif rank >= 4 and rank <= 10 then
        pic = "arena_bg_4.png";
    elseif rank > 10 then
        pic = "arena_bg_5.png";
    end
    self.rankBg:loadTexture(pic,ccui.TextureResType.plistType);
end


function arenaItem:onButtonClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        if sender == self.Image_bg then
            if self.delegate and self.delegate.arenaItemSelect then
                self.delegate:arenaItemSelect(self,0); --查看信息
            end
        else
            if self.delegate and self.delegate.arenaItemSelect then
                if self.data.is_worship ==0 then
                    self.delegate:arenaItemSelect(self,1); --挑战
                else
                    self.delegate:arenaItemSelect(self,2); --膜拜
                end
            end
        end
    end
end

function arenaItem:onEnter()

end

function arenaItem:onExit()
    MGRCManager:releaseResources("arenaItem")
end

function arenaItem.create(delegate,widget)
    local layer = arenaItem:new()
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
