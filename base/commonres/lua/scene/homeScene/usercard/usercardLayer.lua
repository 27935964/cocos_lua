-----------------------将领属性界面------------------------
require "PanelTop"
require "usercardItem"
require "usercardlook"
require "usercardGetItem"

usercardLayer = class("usercardLayer", MGLayer)

function usercardLayer:ctor()
    self:init();
end

function usercardLayer:init()
    MGRCManager:cacheResource("usercardLayer", "user_cart_bg.jpg");
    MGRCManager:cacheResource("usercardLayer", "user_card_get_bg.png");
    MGRCManager:cacheResource("usercardLayer", "userCard_ui0.png","userCard_ui0.plist");

    local size = cc.Director:getInstance():getWinSize();
    local bgSpr = cc.Sprite:create("user_cart_bg.jpg");
    bgSpr:setPosition(cc.p(size.width/2, size.height/2));
    self:addChild(bgSpr);
    CommonMethod:setFullBgScale(bgSpr);

    self.pPanelTop = PanelTop.create(self)
    self.pPanelTop:setData("user_card_title.png");
    self:addChild(self.pPanelTop,10);

    local pWidget = MGRCManager:widgetFromJsonFile("usercardLayer","usercard_ui_1.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);--设置描边或者阴影
    
    local Panel_2 = pWidget:getChildByName("Panel_2");
    self.list = Panel_2:getChildByName("ListView");

    self:sendReq();
end

function usercardLayer:createlist()
    self.list:removeAllItems();
    local DBDataList = LUADB.selectlist("select id,name,desc,pic,need,type,num,free_time from general_card_bag order by show", "id:name:desc:pic:need:type:num:free_time");

    local itemLay = ccui.Layout:create();
    local _width = 0;
    local _hight = 0;


    self.usercardItems = {};
    local x = 0
    for i=1,#DBDataList.info do
        local bcan = true;
        if tonumber(DBDataList.info[i].type)==2 then
            bcan = false;
        end
        local usercb=nil;
        for j=1,#self.usercb do
            if tostring(self.usercb[j].b_id) == DBDataList.info[i].id then
                usercb = self.usercb[j];
                bcan = true;
                break;
            end
        end
        
        if bcan then
            local usercardItem = usercardItem.create(self);
            MGRCManager:cacheResource("usercardLayer",DBDataList.info[i].pic..".png");
            usercardItem:setData(DBDataList.info[i],usercb);
            usercardItem:setPosition(cc.p(145+usercardItem:getContentSize().width/2+(usercardItem:getContentSize().width+83)*x,usercardItem:getContentSize().height/2));
            itemLay:addChild(usercardItem);
            _width=usercardItem:getContentSize().width;
            _hight=usercardItem:getContentSize().height;
            x= x+1;
            table.insert(self.usercardItems, usercardItem);
        end
    end
    itemLay:setSize(cc.size(145+(_width+83)*x, _hight));
    self.list:pushBackCustomItem(itemLay);

    local function updateTimef(dt)
        for i=1,#self.usercardItems do
            self.usercardItems[i]:updata();
        end
    end
    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
    end
    self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(updateTimef, 1, false);
end

function usercardLayer:back()
    self:removeFromParent();
end

function usercardLayer:cardDo(item)
    self.selItemData = item.data;
    local id = tonumber(item.data.id);
    self:senduseCardBag(id);

end

function usercardLayer:cardlook(item)
    self.selItemData = item.data;
    local id = tonumber(item.data.id);
    local usercardlook = usercardlook.create(self);
    usercardlook:setData(id);
    cc.Director:getInstance():getRunningScene():addChild(usercardlook,ZORDER_MAX);
end


function usercardLayer:sendReq()
    NetHandler:sendData(Post_getUserCardBag, "");
end

function usercardLayer:senduseCardBag(id)
    -- @Summary  抽卡
    -- @Input    id Int 卡包ID
    local str = string.format("&id=%d",id)
    NetHandler:sendData(Post_useCardBag, str);
end

function usercardLayer:onReciveData(MsgID, NetData)
    print("LoadingPanel onReciveData MsgID:"..MsgID)
    
    if MsgID == Post_getUserCardBag then
        local ackData = NetData
        if ackData.state == 1 then
            self.usercb = ackData.getusercardbag.usercb;
            self:createlist();
        else
            NetHandler:showFailedMessage(ackData)
        end
    elseif  MsgID == Post_useCardBag then
        local ackData = NetData
        if ackData.state == 1  then

            if ackData.usecardbag.getitem then
                local usercardGetItem = usercardGetItem.create(self);
                usercardGetItem:setData(ackData.usecardbag.getitem,self.selItemData);
                cc.Director:getInstance():getRunningScene():addChild(usercardGetItem,ZORDER_MAX);
            end

            self.usercb = ackData.getusercardbag.usercb;
            self:createlist();
            self.pPanelTop:upData()
        else
            NetHandler:showFailedMessage(ackData)
        end
    end
    
end



function usercardLayer:pushAck()
    NetHandler:addAckCode(self,Post_getUserCardBag);
    NetHandler:addAckCode(self,Post_useCardBag);

end

function usercardLayer:popAck()
    NetHandler:delAckCode(self,Post_getUserCardBag);
    NetHandler:delAckCode(self,Post_useCardBag);
end

function usercardLayer:onEnter()
    self:pushAck();
end

function usercardLayer:onExit()
    MGRCManager:releaseResources("usercardLayer");
    self:popAck();
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
end

function usercardLayer.create(delegate)
    local layer = usercardLayer:new()
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

function usercardLayer.showBox(delegate)
    local layer = usercardLayer.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
