-----------------------将领属性界面------------------------

arena_player_Info = class("arena_player_Info", MGLayer)

function arena_player_Info:ctor()
    self:init();
end

function arena_player_Info:init()
    local pWidget = MGRCManager:widgetFromJsonFile("arena_player_Info","arena_ui_3.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);--设置描边或者阴影
    
    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));
    local Panel_2 = pWidget:getChildByName("Panel_2");
    local Image_arena_player_Info = Panel_2:getChildByName("Image_arena_player_Info");
    self.Button_close = Panel_2:getChildByName("Button_close");
    self.Button_close:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_ok = Panel_2:getChildByName("Button_ok");
    self.Button_ok:addTouchEventListener(handler(self,self.onButtonClick));
    self.Label_ok = self.Button_ok:getChildByName("Label_ok");
    self.Label_ok:setText(MG_TEXT_COCOS("arena_ui_3"));


    local Panel_mid = Panel_2:getChildByName("Panel_mid");
    self.Panel_mid = Panel_mid;
    self.Label_name = Panel_mid:getChildByName("Label_name");
    local Label_lv_name = Panel_mid:getChildByName("Label_lv_name");
    Label_lv_name:setText(MG_TEXT_COCOS("arena_ui_16"));
    local Label_score_name = Panel_mid:getChildByName("Label_score_name");
    Label_score_name:setText(MG_TEXT_COCOS("arena_ui_1"));
    local Label_union_name = Panel_mid:getChildByName("Label_union_name");
    Label_union_name:setText(MG_TEXT_COCOS("arena_ui_17"));

    self.Label_lv = Panel_mid:getChildByName("Label_lv");
    self.Label_score = Panel_mid:getChildByName("Label_score");
    self.Label_union = Panel_mid:getChildByName("Label_union");

    self.herolist = Panel_mid:getChildByName("ListView");

    local Image_head = Panel_mid:getChildByName("Image_head");
    Image_head:setVisible(false);
    self.heroHead = userHead.create(self);
    self.heroHead:setAnchorPoint(Image_head:getAnchorPoint());
    self.heroHead:setPosition(Image_head:getPosition());
    Panel_mid:addChild(self.heroHead,2);



end


function arena_player_Info:setData(data)
    self.data = data;
    self.Label_name:setText(data.name);
    self.Label_lv:setText(data.lv);
    self.Label_union:setText(data.union);
    self.Label_score:setText(data.score);
    local gm = GENERAL:getAllGeneralModel(data.head);
    if gm then
        self.heroHead:setData(gm)
    end

    if data.is_worship ==0 then
        self.Label_ok:setText(MG_TEXT_COCOS("arena_ui_3"));
        if data.is_atk==1 then
            self.Button_ok:setBright(true);
            self.Button_ok:setTouchEnabled(true);
        else
            self.Button_ok:setEnabled(false);
            self.Button_ok:setTouchEnabled(false);
        end
    else
        
        self.Label_ok:setText(MG_TEXT_COCOS("arena_ui_4"));
    end

    self.herolist:removeAllItems();
    local itemLay = ccui.Layout:create();
    local _width = 0;
    local _hight = self.herolist:getSize().height;
    for i=1,#self.data.corps do
        local id = self.data.corps[i].g_id;
        local gm = GeneralModel:create(id,false);
        local str = cjson.encode(self.data.corps[i])
        gm:updata(str)
        local item = HeroHeadEx.create(self);
        item:setData(gm);
        item:showname();
        item:setPosition(cc.p(31+item:getContentSize().width/2+(31+item:getContentSize().width)*(i-1),_hight/2+10));
        itemLay:addChild(item);
        _width=item:getContentSize().width;
    end
    itemLay:setSize(cc.size((31+_width)*#self.data.corps, _hight));
    _width = itemLay:getSize().width; 
    self.herolist:pushBackCustomItem(itemLay);
end

function arena_player_Info:onButtonClick(sender, eventType)
    buttonClickScale(sender, eventType);
    if eventType == ccui.TouchEventType.ended then
        if sender == self.Panel_1 then
            self:removeFromParent();
        elseif sender == self.Button_close then
            self:removeFromParent();
        elseif sender == self.Button_ok then
            if self.delegate and self.delegate.arenaPlayerInfo then
                if self.data.is_worship ==0 then
                    self.delegate:arenaPlayerInfo(1); --挑战
                else
                    self.delegate:arenaPlayerInfo(2); --膜拜
                end
            end
            self:removeFromParent();
        end
    end
end


function arena_player_Info:onEnter()

end

function arena_player_Info:onExit()
    MGRCManager:releaseResources("arena_player_Info");
end

function arena_player_Info.create(delegate)
    local layer = arena_player_Info:new()
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

