-----------------------商店宝物或者军械购买界面------------------------
require "shopInfoItem"

shopInfo2 = class("shopInfo2", MGLayer)

function shopInfo2:ctor()
    self.isSelect = false;
    self:init();
end

function shopInfo2:init()
    local pWidget = MGRCManager:widgetFromJsonFile("shopInfo2","shop_ui_4.ExportJson");
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
    
    self.CheckBox = Panel_mid:getChildByName("CheckBox");
    self.CheckBox:addEventListenerCheckBox(handler(self,self.onCheckBoxClick));
    local Label_check = self.CheckBox:getChildByName("Label_check");
    Label_check:setText(MG_TEXT_COCOS("shop_ui_1"));

    self.list = Panel_mid:getChildByName("ListView");
end


function shopInfo2:onButtonClick(sender, eventType)
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

function shopInfo2:onCheckBoxClick(sender, eventType)
    self.isSelect = not self.isSelect;
end

function shopInfo2:setData(info,gmList)
    self.info = info;
    self.gmList = gmList;

    self.item = getDataList(self.info.item);
    self.sellPrice = getDataList(self.info.sell_price);
    self.sellPriceInfo = itemInfo(self.sellPrice[1].value1,self.sellPrice[1].value2);

    self.goods:setData(self.item[1].value1,self.item[1].value2);
    self.itemInfo = self.goods:getItemInfo();
    self.goods:setNumVisible(false);

    MGRCManager:cacheResource("shopInfo2", self.sellPriceInfo.samll_pic);
    self.Image_ico:loadTexture(self.sellPriceInfo.samll_pic,ccui.TextureResType.plistType);

    self.Label_ok:setText(self.sellPrice[1].value3);
    local resInfo = RESOURCE:getResModelByItemId(self.item[1].value2);
    if resInfo then
        self.Label_num1:setText(resInfo:getNum());
        self.Label_name:setText(resInfo:name());
        self.Label_name:setColor(ResourceData:getTitleColor(resInfo:getQuality()));
    end

    self:createItem();
end

function shopInfo2:createItem()
    local totalNum = #self.gmList
    if totalNum <= 0 then
        return;
    end

    local queues = {};
    queues = newline(totalNum,2);

    self.list:removeAllItems();
    local itemLay = ccui.Layout:create();
    itemLay:setSize(cc.size(self.list:getContentSize().width, queues[totalNum].row*125));
    self.list:pushBackCustomItem(itemLay);
    for i=1,totalNum do
        local item = shopInfoItem.create(self);
        item:setData(self.gmList[i]);
        item:setPosition(cc.p(queues[i].col*item:getContentSize().width+item:getContentSize().width/2,
            itemLay:getContentSize().height-queues[i].row*item:getContentSize().height+item:getContentSize().height/2));
        itemLay:addChild(item);
    end
end

function shopInfo2:onEnter()

end

function shopInfo2:onExit()
    MGRCManager:releaseResources("shopInfo2");
end

function shopInfo2.create(delegate)
    local layer = shopInfo2:new()
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


function shopInfo2.showBox(delegate)
    local layer = shopInfo2.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
