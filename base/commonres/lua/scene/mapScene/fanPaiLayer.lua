-------------------------翻牌界面--------------------------
require "fanPaiItem"
require "getItem"
require "ItemJump"

fanPaiLayer = class("fanPaiLayer", MGLayer)
fanPaiLayer.TIME = 30;
function fanPaiLayer:ctor()
    self.curTime = fanPaiLayer.TIME;
    self.curLayer = 1;
    self.indexs = {};--保存已翻牌的索引
    self.num = 0;--免费次数
    self.isGetAllReward = false;
    self:init();
end

function fanPaiLayer:init()
    self.timer = CCTimer:new();
    MGRCManager:cacheResource("fanPaiLayer", "fanpai_ui.png", "fanpai_ui.plist");
    MGRCManager:cacheResource("fanPaiLayer", "user_card_get_bg.png");
    local pWidget = MGRCManager:widgetFromJsonFile("fanPaiLayer","reward_ui_3.ExportJson");
    self:addChild(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);

    self.Panel_1 = pWidget:getChildByName("Panel_1");

    local Panel_2 = pWidget:getChildByName("Panel_2");
    self.Label_time = Panel_2:getChildByName("Label_time");
    
    self.Panel_3 = Panel_2:getChildByName("Panel_3");
    self.ListView = Panel_2:getChildByName("ListView");

    self.Button_extract = self.Panel_3:getChildByName("Button_extract");--抽奖
    self.Button_extract:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_receive = self.Panel_3:getChildByName("Button_receive");--领去
    self.Button_receive:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_end = Panel_2:getChildByName("Button_end");--结束
    self.Button_end:addTouchEventListener(handler(self,self.onButtonClick));

    self.Label_mas = self.Panel_3:getChildByName("Label_mas");

    self.Label_tip = Panel_2:getChildByName("Label_tip");
    self.Label_tip:setText(MG_TEXT("fanPaiLayer_3"));

    local Label_end = self.Button_end:getChildByName("Label_end");
    Label_end:setText(MG_TEXT_COCOS("reward_ui_3_1"));
    local Label_receive = self.Button_receive:getChildByName("Label_receive");
    Label_receive:setText(MG_TEXT_COCOS("reward_ui_3_2"));
    local Label_extract = self.Button_extract:getChildByName("Label_extract");
    Label_extract:setText(MG_TEXT_COCOS("reward_ui_3_3"));

    local sql = "select * from config where id=66";
    local DBData = LUADB.select(sql, "value");
    self.allGold = tonumber(DBData.info.value);
    self.Label_mas:setText(self.allGold);
end

function fanPaiLayer:setData(data,flipType)
    self.data = data;
    self.flipType = flipType;
    if nil == self.flipType then
        self.flipType = 1;
    end
    local dataList = getDataList(self.data.num);
    self.num = dataList[1].value2-dataList[1].value1;
    if self.num <= 0 then
        self.num = 0;
    end
    
    self:createItem();
    if self.curLayer == 1 then
        self:setBtn(true);
        self.Button_end:setEnabled(false);
        self.Label_tip:setText(MG_TEXT("fanPaiLayer_3"));
        for i=1,#self.items do
            self.items[i]:setTouchEnabled(false);
        end
    elseif self.curLayer == 2 then
        self.get = {};
        if self.data.get and #self.data.get > 0 then
            self.get = getefflist(self.data.get);
        end

        self:setBtn(false);
        if #self.get > 0 then
            self.Button_end:setEnabled(true);
        end
        self.Label_tip:setText(string.format(MG_TEXT("fanPaiLayer_4"),self.num));
    end

    self.timer:startTimer(1000,handler(self,self.updateTime));--每秒回调一次
    self.Label_time:setText(string.format(MG_TEXT("fanPaiLayer_1"),self.curTime));
end

function fanPaiLayer:setBtn(isShow)
    self.Panel_3:setVisible(isShow);
    self.Button_extract:setEnabled(isShow);
    self.Button_receive:setEnabled(isShow);
end

function fanPaiLayer:setSweepFlip(num)--扫荡翻牌专用
    self.Label_tip:setText(string.format(MG_TEXT("fanPaiLayer_5"),num));
    if num <= 0 then
        self.Label_tip:setText(MG_TEXT("fanPaiLayer_3"));
    end
end

function fanPaiLayer:createItem()
    self.ListView:removeAllItems();
    local itemLay = ccui.Layout:create();
    itemLay:setSize(cc.size(self.ListView:getContentSize().width, self.ListView:getContentSize().height));
    if #self.data.flip_item > 5 then
        itemLay:setSize(cc.size(#self.data.flip_item*200, self.ListView:getContentSize().height));
    end
    self.ListView:pushBackCustomItem(itemLay);

    self.items = {};
    for i=1,#self.data.flip_item do
        local item = fanPaiItem.create(self);
        item:setData(self.data,i,self.curLayer,self.num);
        itemLay:addChild(item);
        item:setPosition(cc.p(item:getContentSize().width/2+(i-1)*(item:getContentSize().width+20),itemLay:getContentSize().height/2+20));
        table.insert(self.items,item);
    end

    local average = math.ceil(#self.items/2);
    local mod = math.mod(#self.items,2);
    local posX = itemLay:getContentSize().width/2;
    if mod == 0 then
        posX = posX-self.items[1]:getContentSize().width/2-10;
        for i=1,#self.items do
            if i < average then
                self.items[i]:setPositionX(posX-(average-i)*(self.items[i]:getContentSize().width+20));
            elseif i == average then
                self.items[i]:setPositionX(posX);
            else
                self.items[i]:setPositionX(posX+(i-average)*(self.items[i]:getContentSize().width+20));
            end
        end
    elseif mod == 1 then
        for i=1,#self.items do
            if i < average then
                self.items[i]:setPositionX(posX-(average-i)*(self.items[i]:getContentSize().width+20));
            elseif i == average then
                self.items[i]:setPositionX(posX);
            else
                self.items[i]:setPositionX(posX+(i-average)*(self.items[i]:getContentSize().width+20));
            end
        end
    end
end

function fanPaiLayer:updateTime()
    if self.curTime <= 0 then
        if self.curLayer == 1 then
            if self.isGetAllReward == true then
                self:onClose();
                return;
            else
                self:update();
                self.curTime = fanPaiLayer.TIME;
            end
        elseif self.curLayer == 2 then
            self:onClose();
            return;
        end
    end
    self.Label_time:setText(string.format(MG_TEXT("fanPaiLayer_1"),self.curTime));
    self.curTime = self.curTime - 1;
end

function fanPaiLayer:onButtonClick(sender, eventType)
    buttonClickScale(sender, eventType);

    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_receive then--领奖
            self:getAllRewardSendReq();
        elseif sender == self.Button_extract then--抽奖
            self:update();
        else
            self:onClose();
        end
    end
end

function fanPaiLayer:update()
    self.curLayer = 2;
    self.curTime = fanPaiLayer.TIME;
    self:setData(self.data,self.flipType);
end

function fanPaiLayer:onClose()
    if self.num > 0 then
        self:automaticFlip();
    end
    if self.flipType == 2 then
        if self.delegate and self.delegate.flip then
            self.delegate:flip();
        end
    end
    if self.isGetAllReward == false then--全部领取后就不要发结束翻牌请求
        self:endFlipRewardSendReq();
    end
    if self.delegate and self.delegate.flipCallBack then
        self.delegate:flipCallBack(self);
    end
    self:removeFromParent();
end

function fanPaiLayer:updateFlipReward(ackData)
    local flipData = ackData.doflipreward;
    self.num = self.num - 1;
    if self.num <= 0 then
        self.num = 0;
    end
    self.Label_tip:setText(string.format(MG_TEXT("fanPaiLayer_4"),self.num));
    self.Button_end:setEnabled(true);
    local get_item = getDataList(flipData.get_item);
    if self.num > 0 then
        for i=1,#self.items do
            self.items[i]:setShow(false);
            if self.index == i then
                self.items[i]:createItem(get_item[1].value1,get_item[1].value2,get_item[1].value3);
            end
        end
    else
        for i=1,#self.items do
            self.items[i]:setShow(true);
            self.items[i]:setMasNum(flipData.next_use_gold);
            for j=1,#self.indexs do--已翻牌的不需要显示砖石数量
                if self.indexs[j] == i then
                    self.items[i]:setShow(false);
                    if self.index == i then
                        self.items[i]:createItem(get_item[1].value1,get_item[1].value2,get_item[1].value3);
                    end
                    break;
                end
            end
        end
    end
end

function fanPaiLayer:automaticFlip()--时间到了还有免费次数自动翻牌
    if self.num > 0 then--还有免费次数
        local num = self.num;
        for i=1,#self.items do
            local isUnFlip = false;--没翻的牌
            for j=1,#self.indexs do
                if self.indexs[j] == self.items[i].index then
                    isUnFlip = true;
                    break;
                end
            end

            if isUnFlip == false then
                num = num - 1;
                self:doFlipSendReq(self.items[i].index);
            end

            if num <= 0 then
                break;
            end
        end
    end
end

function fanPaiLayer:onReciveData(MsgID, NetData)
    print("fanPaiLayer onReciveData MsgID:"..MsgID)
    local ackData = NetData;
    if MsgID == Post_getFlipReward then
        if ackData.state == 1 then

        else
            NetHandler:showFailedMessage(ackData)
        end
    elseif MsgID == Post_doFlipReward then
        if ackData.state == 1 then
            self:updateFlipReward(ackData);
            if self.flipType == 2 then
                if self.delegate and self.delegate.addReward then
                    self.delegate:addReward(ackData.doflipreward.get_item);
                end
            end
            -- getItem.showBox(ackData.doflipreward.get_item);
        else
            NetHandler:showFailedMessage(ackData)
        end
    elseif MsgID == Post_endFlipReward then
        if ackData.state == 1 then

        else
            NetHandler:showFailedMessage(ackData)
        end
    elseif MsgID == Post_getAllReward then
        if ackData.state == 1 then
            if self.flipType == 2 then
                if self.delegate and self.delegate.addReward then
                    self.delegate:addReward(ackData.getallreward.get_item);
                end
            end

            self.isGetAllReward = true;
            self.num = 0;
            self:setBtn(false);
            self.Button_end:setEnabled(true);
            for i=1,#self.items do
                self.items[i]:setTouchEnabled(false);
            end


            if self.delegate and self.delegate.getItem then
                self.delegate:getItem(ackData.getallreward.get_item);
            end
            self:removeFromParent();
        else
            NetHandler:showFailedMessage(ackData)
        end
    end
end

function fanPaiLayer:sendReq()
    local str = string.format("&type=%d",1);
    NetHandler:sendData(Post_getFlipReward, str);
end

function fanPaiLayer:doFlipSendReq(index)
    self.index = index;
    table.insert(self.indexs,index);
    if #self.indexs == #self.items then--所有的牌已翻
        self.isGetAllReward = true;
    end
    local str = string.format("&flip=%d&name=%s&type=%d",index,self.data.flip_name,self.data.flip_type);
    NetHandler:sendData(Post_doFlipReward, str);
    self.items[index]:setTouchEnabled(false);
end

function fanPaiLayer:endFlipRewardSendReq()
    local str = string.format("&name=%s&type=%d",self.data.flip_name,self.data.flip_type);
    NetHandler:sendData(Post_endFlipReward, str);
end

function fanPaiLayer:getAllRewardSendReq()
    local str = string.format("&name=%s&type=%d",self.data.flip_name,self.data.flip_type);
    NetHandler:sendData(Post_getAllReward, str);
end

function fanPaiLayer:pushAck()
    NetHandler:addAckCode(self,Post_getFlipReward);
    NetHandler:addAckCode(self,Post_doFlipReward);
    NetHandler:addAckCode(self,Post_endFlipReward);
    NetHandler:addAckCode(self,Post_getAllReward);
end

function fanPaiLayer:popAck()
    NetHandler:delAckCode(self,Post_getFlipReward);
    NetHandler:delAckCode(self,Post_doFlipReward);
    NetHandler:delAckCode(self,Post_endFlipReward);
    NetHandler:delAckCode(self,Post_getAllReward);
end

function fanPaiLayer:onEnter()
    self:pushAck();
end

function fanPaiLayer:onExit()
    MGRCManager:releaseResources("fanPaiLayer");
    self:popAck();
    if self.timer~=nil then
        self.timer:stopTimer();
    end
end

function fanPaiLayer.create(delegate)
    local layer = fanPaiLayer:new()
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

function fanPaiLayer.showBox(delegate)
    local layer = fanPaiLayer.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_PRIORITY);
    return layer;
end
