-----------------------将领特性界面------------------------
require "heroIntroduceLayer"
require "heroDetailsLayer"
require "heroFeaturesItem"
require "heroFeaturesInfo"
require "heroComLayer"

heroFeaturesLayer = class("heroFeaturesLayer", MGLayer)

function heroFeaturesLayer:ctor()
    self:init();
end

function heroFeaturesLayer:init()
    local pWidget = MGRCManager:widgetFromJsonFile("heroFeaturesLayer","hero_features_ui_1.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);--设置描边或者阴影

    self.heroComLayer = heroComLayer.create(self);
    self:addChild(self.heroComLayer,-1);
    
    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:setAnchorPoint(cc.p(0.5, 0.5));
    CommonMethod:setFullBgScale(self.Panel_1);

    local Panel_2 = pWidget:getChildByName("Panel_2");
    local Panel_right = Panel_2:getChildByName("Panel_right");

    local Label_tip = Panel_right:getChildByName("Label_tip");
    Label_tip:setText(MG_TEXT_COCOS("hero_features_ui_1"));

    self.Button_star= Panel_right:getChildByName("Button_star");--一键升级按钮
    self.Button_star:addTouchEventListener(handler(self,self.onButtonClick));
    local Label_btn = self.Button_star:getChildByName("Label_btn");
    Label_btn:setText(MG_TEXT_COCOS("hero_features_ui_2"));

    self.list = Panel_right:getChildByName("ListView");

    if not self.heroFeaturesInfoWidget then
        self.heroFeaturesInfoWidget = MGRCManager:widgetFromJsonFile("heroFeaturesLayer", "hero_features_ui_3.ExportJson",false);
        self.heroFeaturesInfoWidget:retain()
    end
    if not self.heroFeaturesItemWidget then
        self.heroFeaturesItemWidget = MGRCManager:widgetFromJsonFile("heroFeaturesLayer", "hero_features_ui_2.ExportJson",false);
        self.heroFeaturesItemWidget:retain()
    end
end

function heroFeaturesLayer:setData(gm)
    self.gm = gm;
    self.heroComLayer:setHero(gm);
    self:sendReq();
end


function heroFeaturesLayer:sendReq()
    --@Summary  获取用户将领特性
    --@Input    g_id Int 将领ID
    local str = string.format("&g_id=%d",self.gm:getId());
    NetHandler:sendData(Post_getFeatures, str);
end

function heroFeaturesLayer:upData()
    self.heroComLayer:setHero(self.gm);
    local sql = string.format("select features from soldier_list where id=%d",self.gm:soldierid());
    local DBData = LUADB.select(sql, "features");
    local  str = DBData.info.features;
    local str_list = spliteStr(str,'|');  
    self.features = {};
    for i=1,#str_list do
        local str_list1 = spliteStr(str_list[i],':');  
        sql = "select * from features where f_id="..str_list1[1];
        local lv = 1;
        local islock = 1;
        if self.getfeatures then
          for j=1,#self.getfeatures do
            print(j)
            if self.getfeatures[j].f_id == tonumber(str_list1[1]) then
                lv = self.getfeatures[j].lv;
                islock = 0;
                break;
            end
          end
        end
        sql = sql..' and lv='..lv;
        print(sql);
        local DBData1 = LUADB.select(sql, "f_id:lv:need:f_name:pic:desc:f_info");
        if DBData1 then
            DBData1.info.quality = tonumber(str_list1[2]);
            DBData1.info.islock = islock;
            DBData1.info.f_id = tonumber(DBData1.info.f_id);
            table.insert(self.features,DBData1.info);
        end
    end

    self.list:removeAllItems();
    for i=1,#self.features do
        local item = heroFeaturesItem.create(self,self.heroFeaturesItemWidget:clone())
        MGRCManager:cacheResource("heroFeaturesLayer",self.features[i].pic..".png");
        item:setData(self.features[i],i)
        self.list:pushBackCustomItem(item)
    end
end

function heroFeaturesLayer:UpFeatures(item)
    -- @Summary  将领特性升级
    -- @Input    g_id Int 将领ID
    -- f_id Int 特性ID
    -- is_all Int 是否一键升级 default 0 一键为1
    local str = string.format("&g_id=%d&f_id=%d&is_all=0",self.gm:getId(),item.data.f_id);
    NetHandler:sendData(Post_doUpFeatures, str);
    
end

function heroFeaturesLayer:showInfo(item)
    local index = 0; 
    if self.info then
        index = self.info.index;
        self.list:removeItem(index);
        self.info=nil;
    end
    if index ~= item.index then
        self.info = heroFeaturesInfo.create(self,self.heroFeaturesInfoWidget:clone());
        self.info:setData(item.data,item.index);
        self.list:insertCustomItem(self.info,item.index);
    end
end



function heroFeaturesLayer:onButtonClick(sender, eventType)
    if sender == self.Button_star then
        buttonClickScale(sender, eventType,0.8)
    else
        buttonClickScale(sender, eventType)
    end
    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_star then
            -- @Summary  将领特性升级
            -- @Input    g_id Int 将领ID
            -- f_id Int 特性ID
            -- is_all Int 是否一键升级 default 0 一键为1
            local str = string.format("&g_id=%d&f_id=0&is_all=1",self.gm:getId());
            NetHandler:sendData(Post_doUpFeatures, str);
        end
    end
end

function heroFeaturesLayer:onReciveData(MsgID, NetData)
    print("heroFeaturesLayer onReciveData MsgID:"..MsgID)
    
    if MsgID == Post_getFeatures then
        local ackData = NetData
        if ackData.state == 1 then
            self.getfeatures =  ackData.getfeatures.features;
            self:upData();
        else
            NetHandler:showFailedMessage(ackData)
        end
    elseif  MsgID == Post_doUpFeatures then
        local ackData = NetData
        if ackData.state == 1  then
            local  items= ackData.doupfeatures.new_info
            for i=1,#items do
                print("222"..items[i].f_id)
                self:upDataLv(items[i].f_id,items[i].lv);
            end

            if self.delegate and self.delegate.upData then
                self.delegate:upData();
            end
        else
            NetHandler:showFailedMessage(ackData)
        end
    end
    
end


function heroFeaturesLayer:upDataLv(f_id,lv)
    local  items= self.list:getItems()
    for i=1,#items do
        print("333  "..items[i].data.f_id..":"..f_id)
        if items[i].data.f_id == f_id then
            sql = "select need,f_info from features where f_id="..f_id;
            sql = sql..' and lv='..lv;
            local DBData1 = LUADB.select(sql, "need:f_info");
            if DBData1 then
                items[i].data.need = DBData1.info.need;
                items[i].data.f_info = DBData1.info.f_info;
            end
            items[i].data.lv = lv;
            items[i]:setlv(lv);
            if self.info then
                self.info:upData();
            end
            return;
        end
    end
end

function heroFeaturesLayer:pushAck()
    NetHandler:addAckCode(self,Post_getFeatures);
    NetHandler:addAckCode(self,Post_doUpFeatures);
end

function heroFeaturesLayer:popAck()
    NetHandler:delAckCode(self,Post_getFeatures);
    NetHandler:delAckCode(self,Post_doUpFeatures);
end

function heroFeaturesLayer:onEnter()
    self:pushAck();
end

function heroFeaturesLayer:onExit()
    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
    end
    MGRCManager:releaseResources("heroFeaturesLayer");
    self:popAck();
    if self.heroFeaturesInfoWidget then
        self.heroFeaturesInfoWidget:release()
    end
    if self.heroFeaturesItemWidget then
        self.heroFeaturesItemWidget:release()
    end

end

function heroFeaturesLayer.create(delegate,type)
    local layer = heroFeaturesLayer:new()
    layer.delegate = delegate
    layer.type = type
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
