-----------------------将领属性界面------------------------
require "PanelTop"
require "shopItem"
require "shopleftItem"
require "shopInfo1"
require "shopInfo2"
local shop=require "shop"

shopLayer = class("shopLayer", MGLayer)

function shopLayer:ctor()
    self.shopItemWidget = nil;
    self.rtime = 0;
end

function shopLayer:init(delegate,selid)
    self.delegate =  delegate;
    self.selid =  selid;
    MGRCManager:cacheResource("shopLayer", "package_bg.jpg");
    local size = cc.Director:getInstance():getWinSize();
    local bgSpr = cc.Sprite:create("package_bg.jpg");
    bgSpr:setPosition(cc.p(size.width/2, size.height));
    bgSpr:setAnchorPoint(cc.p(0.5,1));
    self:addChild(bgSpr);


    local pWidget = MGRCManager:widgetFromJsonFile("shopLayer","shop_ui_1.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);--设置描边或者阴影


    self.pPanelTop = PanelTop.create(self)
    self.pPanelTop:setData("shop_title.png");
    self:addChild(self.pPanelTop,10);
    
    local Panel_2 = pWidget:getChildByName("Panel_2");
    local Panel_left = Panel_2:getChildByName("Panel_left");
    self.list = Panel_left:getChildByName("ListView_left");

    local Panel_mid = Panel_2:getChildByName("Panel_mid");
    self.Panel_23 = Panel_mid:getChildByName("Panel_23");

    self.listshop = Panel_mid:getChildByName("ListView");
    local Label_times_name = self.Panel_23:getChildByName("Label_times_name");
    Label_times_name:setText(MG_TEXT_COCOS("shop_ui_2"));
    self.Label_tip = Panel_mid:getChildByName("Label_tip");
    self.Label_times = self.Panel_23:getChildByName("Label_times");

    local Image_fresh = Panel_mid:getChildByName("Image_fresh");
    self.Button_fresh = Image_fresh:getChildByName("Button_fresh");
    self.Image_glod = Image_fresh:getChildByName("Image_glod");
    self.Label_glod = Image_fresh:getChildByName("Label_glod");
    self.Label_fessh_tip = Image_fresh:getChildByName("Label_fessh_tip");
    self.Label_fessh_tip:setVisible(false);
    self.Button_fresh:addTouchEventListener(handler(self,self.onButtonClick));
    if not self.shopItemWidget then
        self.shopItemWidget = MGRCManager:widgetFromJsonFile("shopLayer", "shop_ui_2.ExportJson",true);
        self.shopItemWidget:retain()
    end

    self:readSql();
    self:createlist();
end

function shopLayer:readSql()--解析数据库数据
    self.shopList = {};
    local sql = string.format("select * from shop");
    local DBDataList = LUADB.selectlist(sql, "id:name:buy_limit:reset_hour");

    for index=1,#DBDataList.info do
        local DBData = {};
        DBData.id = tonumber(DBDataList.info[index].id);
        DBData.name = DBDataList.info[index].name;
        DBData.buy_limit = tonumber(DBDataList.info[index].buy_limit);
        DBData.reset_hour = getDataList(DBDataList.info[index].reset_hour);

        table.insert(self.shopList,DBData);
    end
end

function shopLayer:onButtonClick(sender, eventType)
    buttonClickScale(sender, eventType);
    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_fresh then
            if ME:getGold() >= self.reset_need[1].value3 then
                self:reSetItemSendReq();
            else
                MGMessageTip:showFailedMessage(MG_TEXT("IslandMainLayer_4"));
            end
        end
    end
end

function shopLayer:createlist()
    self.list:removeAllItems();
    for i=1,#self.shopList do
        local shopleftItem = shopleftItem.create(self);
        shopleftItem:setData(self.shopList[i]);
        self.list:pushBackCustomItem(shopleftItem);
        if i==self.selid  then
            self.selItem = shopleftItem;
            self.selItem:Select(true);
            self:shopleftItemSelect(shopleftItem);
        end
    end
end

function shopLayer:back()
    self:removeFromParent();
end

function shopLayer:shopleftItemSelect(item)
    if  self.selItem~=item then
        if self.selItem then
            self.selItem:Select(false);
        end
        self.selItem = item;
        self.selItem:Select(true);

        self.selid = item.info.id;
        self:sendReq();
    end
end

function shopLayer:shopItemSelect(item)
    self.space = tonumber(item.info.space_id);
    if item.item[1].value1 == 11 or item.item[1].value1 == 12 then--宝物碎片 军械
        local shopInfo2 = shopInfo2.showBox(self);
        shopInfo2:setData(item.info,item.gmList);
    else
        local shopInfo1 = shopInfo1.showBox(self);
        shopInfo1:setData(item.info);
    end
end

--登录后首次购买需要弹框
function shopLayer:checkIsFirstBuy(item)
    self.space = tonumber(item.info.space_id);
    local userDefault=cc.UserDefault:getInstance();
    local data=nil;
    local dataKey="shopLayer";
    local dataStr=userDefault:getStringForKey(dataKey);
    if dataStr==nil or dataStr=="" then--登录后首次购买需要弹框
        self:shopItemSelect(item);
    else
        -- data=json.decode(dataStr);
        data=cjson.decode(dataStr);
        if nil==data.isFirst or data.isFirst==true then
            self:shopItemSelect(item);
        else
            self:buyItemSendReq();
        end
    end
end

--登录后首次购买需要弹框
function shopLayer:setIsFirstBuy()
    local userDefault=cc.UserDefault:getInstance();
    local data=nil;
    local dataKey="shopLayer";
    local dataStr=userDefault:getStringForKey(dataKey);
    if dataStr==nil or dataStr=="" then--登录后首次购买需要弹框
        data={};
        data.isFirst=false;
        dataStr=cjson.encode(data);
        userDefault:setStringForKey(dataKey,dataStr);
        userDefault:flush();
    else
        -- data=cjson.decode(dataStr);
        data=cjson.decode(dataStr);
        if nil==data.isFirst or data.isFirst==true then
            data.isFirst=false;
            dataStr=cjson.encode(data);
            userDefault:setStringForKey(dataKey,dataStr);
            userDefault:flush();
        end
    end
end

function shopLayer:setData(data)
    self.data = data;
    self.rtime = tonumber(self.data.reset_time);

    self.reset_need = getDataList(self.data.reset_need);
    self.Panel_23:setVisible(false);
    local shopInfo = self.shopList[self.selid];
    if shopInfo.buy_limit > 0 then
        self.Panel_23:setVisible(true);
        local num = tonumber(self.data.free_num);
        self.Label_times:setText(string.format(MG_TEXT("trialMainLayer_1"),num));
    end
    self.Label_tip:setText(string.format(MG_TEXT("shopLayer_2"),shopInfo.reset_hour[1].value1,
        shopInfo.reset_hour[2].value1,shopInfo.reset_hour[3].value1));

    self:showshop();
end

function shopLayer:showshop()

    local count = #self.data.item;
    local t1 = math.modf((count-1)/4);
    local t2 = count-t1*4;
    if t2>0 then
        t1 = t1+1;
    end

    local item = shopItem.create(self,self.shopItemWidget:clone());
    local itemLay = ccui.Layout:create();
    local _width = 66+(item:getContentSize().width+45)*4;
    local _hight = 20+(item:getContentSize().height+40)*t1;
    self.listshop:removeAllItems();
    for i=1,t1 do
        for j=1,4 do
            local x = (i-1)*4 + j;
            if x>#self.data.item then
                break;
            end
            local item = shopItem.create(self,self.shopItemWidget:clone());
            item:setData(self.data.item[x],self.treasureData);
            item:setPosition(cc.p(66+(item:getContentSize().width+45)*(j-1),_hight-20-item:getContentSize().height-(item:getContentSize().height+40)*(i-1)));
            itemLay:addChild(item);
        end
    end
    itemLay:setSize(cc.size(_width, _hight));
    self.listshop:pushBackCustomItem(itemLay);

end

function shopLayer:sendReq()
    local str = "&shop="..self.selid;
    NetHandler:sendData(Post_Shop_getShopInfo, str);
end

function shopLayer:reSetItemSendReq()
    local str = "&shop="..self.selid;
    NetHandler:sendData(Post_Shop_reSetItem, str);
end

function shopLayer:buyItemSendReq()
    local str = string.format("&shop=%d&space=%d&rtime=%d",self.selid,self.space,self.rtime);
    NetHandler:sendData(Post_Shop_buyItem, str);
end

function shopLayer:onReciveData(MsgID, NetData)
    if MsgID == Post_Shop_getShopInfo then
        local ackData = NetData
        if ackData.state == 1 then
            self:setData(ackData.getshopinfo);
            NetHandler:sendData(Post_General_getTreasure, "");
        else
            NetHandler:showFailedMessage(ackData)
        end
    elseif MsgID == Post_General_getTreasure then
        local ackData = NetData
        if ackData.state == 1 then
            self.treasureData = ackData.gettreasure.treasure;
        else
            NetHandler:showFailedMessage(ackData)
        end
    elseif MsgID == Post_Shop_reSetItem then
        local ackData = NetData
        if ackData.state == 1 then
            self.pPanelTop:upData();
            self:setData(ackData.getshopinfo);
        else
            NetHandler:showFailedMessage(ackData)
        end
    elseif MsgID == Post_Shop_buyItem then
        local ackData = NetData
        if ackData.state == 1 then
            getItem.showBox(ackData.buyitem.get_item);
            self.pPanelTop:upData();
            self:setData(ackData.getshopinfo);
        else
            NetHandler:showFailedMessage(ackData)
        end
    end
end

function shopLayer:pushAck()
    NetHandler:addAckCode(self,Post_Shop_getShopInfo);
    NetHandler:addAckCode(self,Post_General_getTreasure);
    NetHandler:addAckCode(self,Post_Shop_reSetItem);
    NetHandler:addAckCode(self,Post_Shop_buyItem);
end

function shopLayer:popAck()
    NetHandler:delAckCode(self,Post_Shop_getShopInfo);
    NetHandler:delAckCode(self,Post_General_getTreasure);
    NetHandler:delAckCode(self,Post_Shop_reSetItem);
    NetHandler:delAckCode(self,Post_Shop_buyItem);
end

function shopLayer:onEnter()
    self:pushAck();
    self:sendReq();
end

function shopLayer:onExit()
    if self.shopItemWidget then
        self.shopItemWidget:release()
    end
    MGRCManager:releaseResources("shopLayer");
    self:popAck();
end

function shopLayer.create(delegate,selid)
    local layer = shopLayer:new()
    layer:init(delegate,selid)
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


function shopLayer.showBox(delegate,selid)
    local layer = shopLayer.create(delegate,selid);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
