-----------------------将领属性界面------------------------
require "treasureInfoItem"
treasureInfo = class("treasureInfo", MGLayer)

function treasureInfo:ctor()
    self:init();
    self.isequit = false;
end

function treasureInfo:init()
    local pWidget = MGRCManager:widgetFromJsonFile("treasureInfo","treasure_ui_2.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);--设置描边或者阴影
    
    local Panel_2 = pWidget:getChildByName("Panel_2");

    self.Label_name =  Panel_2:getChildByName("Label_name");
    self.Label_att_name_1 =  Panel_2:getChildByName("Label_att_name_1");
    self.Label_att_name_2 =  Panel_2:getChildByName("Label_att_name_2");
    self.Label_att_num1 =  Panel_2:getChildByName("Label_att_num1");
    self.Label_att_num2 =  Panel_2:getChildByName("Label_att_num2");

    self.Image_need = Panel_2:getChildByName("Image_need");
    self.Label_need =  self.Image_need:getChildByName("Label_need");
    self.Label_need:setText(MG_TEXT_COCOS("treasureInfo_ui_1"));
    self.Label_need_lv =  self.Image_need:getChildByName("Label_need_lv");

    self.Image_need_0 = Panel_2:getChildByName("Image_need_0");
    self.Label_need_glod =  self.Image_need_0:getChildByName("Label_need_glod");
    self.Label_need_num =  self.Image_need_0:getChildByName("Label_need_num");
    self.Label_have_num =  self.Image_need_0:getChildByName("Label_have_num");

    self.Button_close = Panel_2:getChildByName("Button_close");
    self.Button_close:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_go = Panel_2:getChildByName("Button_go");
    self.Button_go:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_goods = Panel_2:getChildByName("Button_goods");

    self.Label_go = self.Button_go:getChildByName("Label_go");
    self.Label_go:setText(MG_TEXT_COCOS("treasureInfo_ui_2"));

    self.List =  Panel_2:getChildByName("ListView");

end

function treasureInfo:setData(heroid,treasureInfo,need_lv,treasureState)
    self.id = treasureInfo:id();

    local  Image_goods =  self.Button_goods:getChildByName("Image_goods");
    Image_goods:loadTexture(treasureInfo:pic(),ccui.TextureResType.plistType);
    self.Label_name:setText(treasureInfo:name());

    local attInfo= treasureInfo:getAttInfo()
    self.Label_att_name_1:setText(string.format("%s:",attInfo[1]:name())); 
    self.Label_att_name_2:setText(string.format("%s:",attInfo[2]:name())); 
    self.Label_att_num1:setText(string.format("%d",attInfo[1]:getAttCount()));
    self.Label_att_num2:setText(string.format("%d",attInfo[2]:getAttCount()));

    local needItem= treasureInfo:getNeedItem()
    self.Label_need_glod:setText(string.format("%d",needItem[2]:getNum()));
    self.Label_need_num:setText(string.format("/%d",needItem[1]:getNum()));
    self.Label_need_lv:setText(string.format("%d",need_lv));
    local havenum = 0;
    local item =  RESOURCE:getResModelByItemId(needItem[1]:getItemId());
    if item then
        havenum = item:getNum();
    end
    local neednum = needItem[1]:getNum();
    if treasureState then
        if treasureState:gettreasure(self.id)==0 then
            self.Label_have_num:setText(string.format("%d",havenum));
            if havenum>= neednum then
                self.Label_have_num:setColor(Color3B.GREEN);
                self.Label_go:setText(MG_TEXT_COCOS("treasureInfo_ui_3"));
                self.isequit = true;
            end
        else
            self.Image_need_0:setVisible(false);
            self.Image_need:setVisible(true);
            self.Label_need:setColor(Color3B.GREEN);

            self.Label_need:setText(MG_TEXT_COCOS("treasureInfo_ui_4"));
            self.Label_need:setPositionX(self.Image_need:getContentSize().width/2+self.Label_need:getContentSize().width/2);
            self.Label_need_lv:setVisible(false);
        end
            
    else
        self.Image_need_0:setVisible(false);
        self.Image_need:setVisible(true);
    end

    self.gmlist = GENERAL:getGeneralList();
    local itemLay = ccui.Layout:create();
    local _width = 0;
    local _hight = 0;

    local t1;
    local t2;
    t1,t2 = math.modf(#self.gmlist/2);
    if t2>0 then
        t1 = t1+1;
    end
    if t1 == 1 then
        t1=2;
    end
    

    for i=1,t1 do
        for j=1,2 do
            local x = (i-1)*2 + j;
            if x>#self.gmlist then
                break;
            end
        --if self.gmlist[i]:getId() ~= heroid then
            local item = treasureInfoItem.create();
            item:setData(self.gmlist[x],neednum,havenum);
            item:setPosition(cc.p(item:getContentSize().width*(j-1),item:getContentSize().height*(t1-i)));
            itemLay:addChild(item);
            _width=item:getContentSize().width;
            _hight=item:getContentSize().height;
        --end
        end
    end
    itemLay:setSize(cc.size(_width*2, _hight*t1));
    self.List:pushBackCustomItem(itemLay);
end

function treasureInfo:onButtonClick(sender, eventType)
    if eventType == ccui.TouchEventType.began then
        local sc = cc.ScaleTo:create(0.1, 1.1)
        sender:runAction(cc.EaseOut:create(sc ,2))
    end
    if eventType == ccui.TouchEventType.canceled then
        local sc = cc.ScaleTo:create(0.1, 1)
        sender:runAction(sc)
    end
    if eventType == ccui.TouchEventType.ended then
        local sc = cc.ScaleTo:create(0.1, 1)
        sender:runAction(sc)
        if sender == self.Button_close then
            self:removeFromParent();
        elseif sender == self.Button_go then
            if self.isequit == true then
                if self.delegate and self.delegate.setTreasure then
                    self.delegate:setTreasure(self.id);
                end
            end
            self:removeFromParent();
        end
    end
end



function treasureInfo:onEnter()

end

function treasureInfo:onExit()
    MGRCManager:releaseResources("treasureInfo");
end

function treasureInfo.create(delegate)
    local layer = treasureInfo:new()
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
