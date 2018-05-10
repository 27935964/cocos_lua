-----------------------商店购买界面------------------------

shopInfo1 = class("shopInfo1", MGLayer)

function shopInfo1:ctor()
    self.isSelect = false;
    self:init();
end

function shopInfo1:init()
    local pWidget = MGRCManager:widgetFromJsonFile("shopInfo1","shop_ui_3.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);--设置描边或者阴影
    
    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));
    local Panel_2 = pWidget:getChildByName("Panel_2");
    self.Button_close = Panel_2:getChildByName("Button_close");
    self.Button_close:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_ok = Panel_2:getChildByName("Button_ok");
    self.Button_ok:addTouchEventListener(handler(self,self.onButtonClick));
    self.Label_ok = self.Button_ok:getChildByName("Label_ok");
    self.Image_ico = self.Button_ok:getChildByName("Image_ico");


    local Panel_mid = Panel_2:getChildByName("Panel_mid");
    self.Panel_mid = Panel_mid;

    local Image_goods = Panel_mid:getChildByName("Image_goods");
    Image_goods:setVisible(false);
    self.goods = resItem.create(self);
    self.goods:setPosition(Image_goods:getPosition());
    Panel_mid:addChild(self.goods);

    self.Label_name  = Panel_mid:getChildByName("Label_name");
    self.Label_num1  = Panel_mid:getChildByName("Label_num1");

    local Label_num  = Panel_mid:getChildByName("Label_num");
    Label_num:setText(MG_TEXT_COCOS("shop_ui_3"));

    self.Label_desc  = Panel_mid:getChildByName("Label_desc");
    self.Label_desc:setVisible(false);
    self.descLabel = MGColorLabel:label();
    self.descLabel:setAnchorPoint(cc.p(0.5, 1));
    self.descLabel:setPosition(self.Label_desc:getPosition());
    Panel_mid:addChild(self.descLabel);

    self.CheckBox = Panel_mid:getChildByName("CheckBox");
    self.CheckBox:addEventListenerCheckBox(handler(self,self.onCheckBoxClick));
    local Label_check = self.CheckBox:getChildByName("Label_check");
    Label_check:setText(MG_TEXT_COCOS("shop_ui_1"));
end


function shopInfo1:onButtonClick(sender, eventType)
    buttonClickScale(sender, eventType);
    if eventType == ccui.TouchEventType.ended then
        if sender == self.Panel_1 then

        elseif sender == self.Button_close then

        elseif sender == self.Button_ok then
            if self.delegate and self.delegate.buyItemSendReq then
                self.delegate:buyItemSendReq();
            end
        end

        if self.isSelect == true then
            if self.delegate and self.delegate.setIsFirstBuy then
                self.delegate:setIsFirstBuy();
            end
        end
        self:removeFromParent();
    end
end

function shopInfo1:onCheckBoxClick(sender, eventType)
    self.isSelect = not self.isSelect;
end

function shopInfo1:setData(info)
    self.info = info;

    self.item = getDataList(self.info.item);
    self.sellPrice = getDataList(self.info.sell_price);
    self.sellPriceInfo = itemInfo(self.sellPrice[1].value1,self.sellPrice[1].value2);

    self.goods:setData(self.item[1].value1,self.item[1].value2);
    self.itemInfo = self.goods:getItemInfo();
    -- self.goods:setNumVisible(false);
    self.goods:setNum(self.item[1].value3);

    MGRCManager:cacheResource("shopInfo1", self.sellPriceInfo.samll_pic);
    self.Image_ico:loadTexture(self.sellPriceInfo.samll_pic,ccui.TextureResType.plistType);

    self.Label_ok:setText(self.sellPrice[1].value3);
    local resInfo = RESOURCE:getResModelByItemId(self.item[1].value2);
    if resInfo then
        self.Label_num1:setText(resInfo:getNum());
        self.Label_name:setText(resInfo:name());
        self.Label_name:setColor(ResourceData:getTitleColor(resInfo:getQuality()));
        self.Label_desc:setText(resInfo:desc());

        self.descLabel:clear();
        local str_list = spliteStr(gm:desc(),"\\n");
        local str1 = str_list[1];
        local str2 = str_list[2];
        self.descLabel:appendStringAutoWrap(str1,18,1,cc.c3b(255,255,255),22);
        self.descLabel:appendLine(10);
        self.descLabel:appendStringAutoWrap(str2,18,1,cc.c3b(255,255,255),22);
    end
end

function shopInfo1:onEnter()

end

function shopInfo1:onExit()
    MGRCManager:releaseResources("shopInfo1");
end

function shopInfo1.create(delegate)
    local layer = shopInfo1:new()
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


function shopInfo1.showBox(delegate)
    local layer = shopInfo1.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
