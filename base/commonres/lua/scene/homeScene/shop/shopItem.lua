require "utf8"
require "Item"
shopItem = class("shopItem", function()
    return ccui.Layout:create();
end)

function shopItem:ctor()
    self.gmList = {};
end

function shopItem:init(delegate,widget)
    self.delegate=delegate;
    self:addChild(widget);
    self.pWidget = widget;

    local Panel_1 = self.pWidget:getChildByName("Panel_1");
    self:setContentSize(Panel_1:getContentSize())
    self.Panel = Panel_1;
    self.Panel:addTouchEventListener(handler(self,self.onButtonClick));

    self.Image_icon = Panel_1:getChildByName("Image_icon");
    self.Label_name = Panel_1:getChildByName("Label_name");

    local Image_goods = Panel_1:getChildByName("Image_goods");
    Image_goods:setVisible(false);
    self.goods = resItem.create(self);
    self.goods:setPosition(Image_goods:getPosition());
    Panel_1:addChild(self.goods);

    self.Image_zhekou = Panel_1:getChildByName("Image_zhekou");
    self.Label_zhekou = self.Image_zhekou:getChildByName("Label_zhekou");
    self.Image_beishu = Panel_1:getChildByName("Image_beishu");
    self.Image_beishu:setVisible(false);
    self.Image_need = Panel_1:getChildByName("Image_need");
    self.Image_delline = Panel_1:getChildByName("Image_delline");
    self.Image_selled_mask = Panel_1:getChildByName("Image_selled_mask");
    self.Label_price = Panel_1:getChildByName("Label_price");
    self.Label_price_old = Panel_1:getChildByName("Label_price_old");
    self.Image_selled = self.Image_selled_mask:getChildByName("Image_selled");
end

function shopItem:setData(info,treasureData)
    self.info = info;
    self.treasureData = treasureData;

    self.item = getDataList(self.info.item);
    self.price = getDataList(self.info.price);
    self.sellPrice = getDataList(self.info.sell_price);
    self.priceInfo = itemInfo(self.price[1].value1,self.price[1].value2);
    self.sellPriceInfo = itemInfo(self.sellPrice[1].value1,self.sellPrice[1].value2);

    self.goods:setData(self.item[1].value1,self.item[1].value2);
    self.itemInfo = self.goods:getItemInfo();
    self.goods:setNum(self.item[1].value3);
    self.goods:setShowTip(false);
    self.goods:setTouchEnabled(false);
    self.Label_name:setText(self.itemInfo.name);
    self.Label_zhekou:setText(string.format(MG_TEXT("shopLayer_1"),self.info.discount));
    self.Label_price:setText(self.sellPrice[1].value3);
    self.Label_price_old:setText(self.price[1].value3);

    MGRCManager:cacheResource("shopItem", self.sellPriceInfo.samll_pic);
    self.Image_icon:loadTexture(self.sellPriceInfo.samll_pic,ccui.TextureResType.plistType);

    self.Image_selled_mask:setVisible(false);
    self.Image_selled_mask:setTouchEnabled(false);
    if tonumber(self.info.is_buy) == 1 then
        self.Image_selled_mask:setVisible(true);
        self.Image_selled_mask:setTouchEnabled(true);
    end

    self.Label_price_old:setVisible(false);
    self.Image_delline:setVisible(false);
    self.Image_zhekou:setVisible(false);
    if tonumber(self.info.discount) < 10 then
        self.Label_price_old:setVisible(true);
        self.Image_delline:setVisible(true);
        self.Image_zhekou:setVisible(true);
    end

    self:setTreasureData();
    self.Image_need:setVisible(false);
    if #self.gmList > 0 then
        self.Image_need:setVisible(true);
    end
end

function shopItem:setTreasureData()
    self.gmList = {}
    local index = 0;
    local gmMyList = GENERAL:getGeneralList();
    table.sort(gmMyList,function (gm1,gm2) return gm1:getWarScore() > gm2:getWarScore(); end);
    if self.item[1].value1 == 11 then--宝物碎片
        local needLevel = treasureData:gettreasureSuit(1):needlv();
        for i=1,#gmMyList do
            if gmMyList[i]:getLevel() >= needLevel then--达到穿戴等级
                local isPutOnTreasure = false;--该武将是否装有宝物 false:无 true:有
                for j=1,#self.treasureData do
                    local treasureIds = getDataList(self.treasureData[j].treasure_info);
                    if tonumber(treasureIds) == 0 or #treasureIds == 0 then
                        break;
                    end

                    local isHave = true;--是否缺少的宝物碎片 false:缺少 true:不缺少
                    if gmMyList[i]:getId() == tonumber(self.treasureData[j].g_id) then
                        isPutOnTreasure = true;
                        local spl = string.format("select need_treasure from treasure_suit where id>=%d and need_g_lv<=%d",
                                tonumber(self.treasureData[j].suit_id),gmMyList[i]:getLevel());
                        local DBDataList = LUADB.selectlist(spl, "need_treasure");--可装备的宝物
                        for m=1,#treasureIds do
                            for x=1,#DBDataList.info do
                                local ids = getDataList(DBDataList.info[x].need_treasure);
                                for y=1,#ids do
                                    if treasureIds[m] ~= ids[y].value1 then
                                        local NeedItems = treasureData:gettreasureInfo(ids[y].value1):getNeedItem();
                                        for n=1,#NeedItems do
                                            if NeedItems[n]:getItemId() == self.item[1].value2 then
                                                local good = RESOURCE:getResModelByItemId(self.item[1].value2);
                                                if good then
                                                    if good:getNum() < NeedItems[n]:getNum() then--缺少的宝物碎片
                                                        index = index + 1;
                                                        table.insert(self.gmList,gmMyList[i]);
                                                        isHave = false;
                                                        break;
                                                    end
                                                end
                                            end
                                        end
                                    end
                                    if isHave == false then
                                        break;
                                    end
                                end
                                if isHave == false then
                                    break;
                                end
                            end
                            if isHave == false then
                                break;
                            end
                        end
                        break;
                    end
                end
                if isPutOnTreasure == false then
                    index = index + 1;
                    table.insert(self.gmList,gmMyList[i]);
                end
            end
            if index >= 4 then
                break;
            end
        end
    elseif self.item[1].value1 == 12 then--军械
        for i=1,#gmMyList do
            local equipInfo = EquipData:getEquipInfo(gmMyList[i]:soldierid(),gmMyList[i]:getQuality());
            if equipInfo then
                local equipItems = equipInfo:getEquipItem();
                for j=1,#equipItems do
                    if gmMyList[i]:getEquipState(j) == 0 then--未装备
                        if equipItems[j]:getItemId() == self.item[1].value2 then
                            local good = RESOURCE:getResModelByItemId(self.item[1].value2);
                            if good then
                                if good:getNum() < equipItems[j]:getNum() and gmMyList[i]:getLevel() >= equipItems[j]:getLevel() then--缺少的装备
                                    index = index + 1;
                                    table.insert(self.gmList,gmMyList[i]);
                                end
                            else
                                print("找不到物品==",self.item[1].value2)
                            end
                            break;
                        end
                    end
                end
            end
            if index >= 4 then
                break;
            end
        end
    end
end

function shopItem:onButtonClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        if self.delegate and self.delegate.checkIsFirstBuy then
            self.delegate:checkIsFirstBuy(self);
        end
    end
end

function shopItem:onEnter()

end

function shopItem:onExit()
    MGRCManager:releaseResources("shopItem")
end

function shopItem.create(delegate,widget)
    local layer = shopItem:new()
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
