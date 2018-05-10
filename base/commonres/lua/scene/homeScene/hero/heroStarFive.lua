-----------------------将领属性界面------------------------
require "HeroHead"
heroStarFive = class("heroStarFive", MGLayer)

function heroStarFive:ctor()
    self:init();
end

function heroStarFive:init()
    MGRCManager:cacheResource("heroStarLayer", "user_card_get_bg.png");
    local pWidget = MGRCManager:widgetFromJsonFile("heroStarFive","hero_star_ui_2.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);
    --MGRCManager:changeWidgetTextFont(pWidget,true);--设置描边或者阴影
    
    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));
    local Panel_2 = pWidget:getChildByName("Panel_2");
    self.Panel_2 = Panel_2;
    self.Button_share = Panel_2:getChildByName("Button_share");
    self.Button_share:addTouchEventListener(handler(self,self.onButtonClick));
    self.Label_share = self.Button_share:getChildByName("Label_share");
    self.Label_share:setText(MG_TEXT("Share"));

    self.Panel_atts = {}
    for i=1,4 do
        local Panel_att = Panel_2:getChildByName("Panel_att"..i);
        table.insert(self.Panel_atts, Panel_att );
    end
    
    local Label_tip = Panel_2:getChildByName("Label_tip");
    Label_tip:setText(MG_TEXT("Click_anywhere_to_close"));

    self.Image_head1 = Panel_2:getChildByName("Image_head1");
    self.Image_head2 = Panel_2:getChildByName("Image_head2");
end

function heroStarFive:setData(attList,skill_lv1,skill_lv2,gm)

    self.Image_head1:setVisible(false);
    self.heroHead1 = HeroHead.create();
    self.heroHead1:setAnchorPoint(self.Image_head1:getAnchorPoint());
    self.heroHead1:setPosition(self.Image_head1:getPosition());
    self.heroHead1:setData(gm)
    self.heroHead1:setStar(gm:getStar()-1);
    self.Panel_2:addChild(self.heroHead1,2);

    self.Image_head2:setVisible(false);
    self.heroHead2 = HeroHead.create();
    self.heroHead2:setAnchorPoint(self.Image_head2:getAnchorPoint());
    self.heroHead2:setPosition(self.Image_head2:getPosition());
    self.heroHead2:setData(gm)
    self.Panel_2:addChild(self.heroHead2,2);


    for i=1,4 do
        local Label_name = self.Panel_atts[i]:getChildByName("Label_name");
        local Label_num = self.Panel_atts[i]:getChildByName("Label_num");
        local Label_num_1 = self.Panel_atts[i]:getChildByName("Label_num_1");
        if i==1 then
            Label_name:setText(attList[1].name);
            Label_num:setText(""..gm:getPower()-attList[1].add);
            Label_num_1:setText(""..gm:getPower());
        elseif i==2 then
            Label_name:setText(attList[2].name);
            Label_num:setText(""..gm:getCommand()-attList[2].add);
            Label_num_1:setText(""..gm:getCommand());
        elseif i==3 then
            Label_name:setText(attList[3].name);
            Label_num:setText(""..gm:getStrategy()-attList[3].add);
            Label_num_1:setText(""..gm:getStrategy());
        elseif i==4 then
            Label_name:setText(MG_TEXT("Skill"));
            Label_num:setText("Lv"..skill_lv1);
            Label_num_1:setText("Lv"..skill_lv2);
        end
    end

end

function heroStarFive:onButtonClick(sender, eventType)
    buttonClickScale(sender, eventType);
    if eventType == ccui.TouchEventType.ended then
        if sender == self.Panel_1 then
            if self.delegate and self.delegate.StarFiveOver then
                self.delegate:StarFiveOver();
            end
            self:removeFromParent();
        elseif sender == self.Button_share then
            if self.delegate and self.delegate.Share then
                self.delegate:Share();
            end
            self:removeFromParent();
        end
    end
end


function heroStarFive:onEnter()

end

function heroStarFive:onExit()
    MGRCManager:releaseResources("heroStarFive");
end

function heroStarFive.create(delegate)
    local layer = heroStarFive:new()
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
