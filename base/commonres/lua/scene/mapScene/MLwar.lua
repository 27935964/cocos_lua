-----------------------宣战-------------------------

MLwar = class("MLwar", MGLayer)

function MLwar:ctor()
    self.tag = 1;
    self.emptyPos = 0;--空位数量
    self:init();
end

function MLwar:init()
    local pWidget = MGRCManager:widgetFromJsonFile("MLwar","GuildWar_Ui_CityDetail.ExportJson");
    self:addChild(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);

    self.Panel_mask = pWidget:getChildByName("Panel_mask");
    local Panel_content = pWidget:getChildByName("Panel_content");
    self.Panel_mask:addTouchEventListener(handler(self,self.onButtonClick));

    local Image_Size = Panel_content:getChildByName("Image_Size");
    self.Label_Size = Image_Size:getChildByName("Label_Size");

    self.Image_City = Panel_content:getChildByName("Image_City");
    self.Label_Ownership_1 = Panel_content:getChildByName("Label_Ownership_1");
    self.Label_DefendForce_1 = Panel_content:getChildByName("Label_DefendForce_1");
    self.Label_Revenue_1 = Panel_content:getChildByName("Label_Revenue_1");
    self.Label_num = Panel_content:getChildByName("Label_Surplus_number");

    self.Button_close = Panel_content:getChildByName("Button_close");
    self.Button_close:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_Fight = Panel_content:getChildByName("Button_Fight");--宣战
    self.Button_Fight:addTouchEventListener(handler(self,self.onButtonClick));

    local Label_Ownership = Panel_content:getChildByName("Label_Ownership");
    Label_Ownership:setText(MG_TEXT_COCOS("GuildWar_Ui_CityDetail_1"));

    local Label_DefendForce = Panel_content:getChildByName("Label_DefendForce");
    Label_DefendForce:setText(MG_TEXT_COCOS("GuildWar_Ui_CityDetail_2"));

    local Label_Revenue = Panel_content:getChildByName("Label_Revenue");
    Label_Revenue:setText(MG_TEXT_COCOS("GuildWar_Ui_CityDetail_3"));

    local Label_Surplus = Panel_content:getChildByName("Label_Surplus");
    Label_Surplus:setText(MG_TEXT_COCOS("GuildWar_Ui_CityDetail_4"));

    local Label_Fight = self.Button_Fight:getChildByName("Label_Fight");
    Label_Fight:setText(MG_TEXT_COCOS("GuildWar_Ui_CityDetail_5"));

    local Label_Tips1 = Panel_content:getChildByName("Label_Tips1");
    Label_Tips1:setText(MG_TEXT_COCOS("GuildWar_Ui_CityDetail_6"));

    local Label_Tips2 = Panel_content:getChildByName("Label_Tips2");
    Label_Tips2:setText(MG_TEXT_COCOS("GuildWar_Ui_CityDetail_7"));

    local Label_Tip3 = Panel_content:getChildByName("Label_Tip3");
    Label_Tip3:setText(MG_TEXT_COCOS("GuildWar_Ui_CityDetail_8"));

    self.value1 = tonumber(LUADB.readConfig(127));--公会战每日最大宣战次数
    self.value2 = tonumber(LUADB.readConfig(57));--城池每日税收
end

function MLwar:setData(data,mapInfo)
    self.data = data;
    self.mapInfo = mapInfo;

    self.Image_City:loadTexture(self.mapInfo.icon,ccui.TextureResType.plistType);
    local num = self.value1-tonumber(self.data.my_union_declear_num);
    self.Label_num:setText(string.format("%d/%d",num,self.value1));
    self.Label_Ownership_1:setText(MG_TEXT("ML_MLwar_1"));
    self.Label_Revenue_1:setText(string.format(MG_TEXT("ML_CheckpointLayer_1"),self.value2));
    self.Label_Size:setText(MG_TEXT("city_type_"..self.mapInfo.city_type));--1城，2郡，3乡，4关
    local lv = tonumber(self.data.npc_lv);
    self.Label_DefendForce_1:setText(string.format(MG_TEXT("ML_MLwar_2"),self.mapInfo.army_num,lv));
    for i=1,#self.data.city_flag do--城池归属
        if self.mapInfo.id == tonumber(self.data.city_flag[i].city_id) then
            self.Label_Ownership_1:setText(unicode_to_utf8(self.data.city_flag[i].name));
            break;
        end
    end
end

function MLwar:onButtonClick(sender, eventType)
    if sender ~= self.Panel_mask then
        buttonClickScale(sender, eventType);
    end

    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_Fight then--宣战
            self:sendReq();
        else
            self:removeFromParent();
        end
    end
end

function MLwar:onReciveData(MsgID, NetData)
    print("MLwar onReciveData MsgID:"..MsgID)
    
    if MsgID == Post_Union_War_declareWar then
        if NetData.state == 1 then
            if self.delegate and self.delegate.updataCityInfo then
                self.delegate:updataCityInfo(NetData.getcityinfo);
            end
            self:removeFromParent();
        else
            NetHandler:showFailedMessage(NetData);
        end
    end
end

function MLwar:sendReq()
    local str = "&city_id="..self.mapInfo.id;
    NetHandler:sendData(Post_Union_War_declareWar, str);
end

function MLwar:pushAck()
    NetHandler:addAckCode(self,Post_Union_War_declareWar);
end

function MLwar:popAck()
    NetHandler:delAckCode(self,Post_Union_War_declareWar);
end

function MLwar:onEnter()
    self:pushAck();
end

function MLwar:onExit()
    self:popAck();
    MGRCManager:releaseResources("MLwar");
end

function MLwar.create(delegate)
    local layer = MLwar:new()
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

function MLwar.showBox(delegate)
    local layer = MLwar.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end
