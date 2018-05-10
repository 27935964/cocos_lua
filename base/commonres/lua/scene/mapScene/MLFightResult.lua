require "Item"

MLFightResult = class("MLFightResult", MGLayer)

function MLFightResult:ctor()

end

function MLFightResult:init()
    MGRCManager:cacheResource("MLFightResult", "fight_resultf_bg.png");
    MGRCManager:cacheResource("MLFightResult", "fight_resultv_bg.png");
    MGRCManager:cacheResource("MLFightResult", "MLFightResult_ui.png","MLFightResult_ui.plist");
    local pWidget = MGRCManager:widgetFromJsonFile("MLFightResult","MLFightResult_ui_1.ExportJson");
    self:addChild(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);

    local Panel_2 = pWidget:getChildByName("Panel_2");
    local Panel_award = Panel_2:getChildByName("Panel_award");
    self.Image_bg = Panel_2:getChildByName("Image_bg");

    self.Label_actionNum = Panel_2:getChildByName("Label_actionNum");
    self.Label_expNum = Panel_2:getChildByName("Label_expNum");
    

    local Image_head = Panel_2:getChildByName("Image_head");
    self.Image_title = Image_head:getChildByName("Image_title");
    self.stars = {};
    for i=1,3 do
        local starbg = Image_head:getChildByName("Image_starbg_"..i);
        local star = Image_head:getChildByName("Image_star_"..i);
        table.insert(self.stars,{starbg=starbg,star=star});
    end

    self.ListView = Panel_award:getChildByName("ListView_award");
    self.ListView:setScrollBarVisible(false);
    self.ListView:setItemsMargin(10);

    self.Button_exit = Panel_2:getChildByName("Button_exit");--关闭
    self.Button_exit:addTouchEventListener(handler(self,self.onButtonClick));
    -- self.Button_exit:setEnabled(false);

    self.Button_choose = Panel_2:getChildByName("Button_choose");--重新选路
    self.Button_choose:addTouchEventListener(handler(self,self.onButtonClick));
    self.Button_choose:setEnabled(false);

    self.Button_sweep = Panel_2:getChildByName("Button_sweep");--再次扫荡
    self.Button_sweep:addTouchEventListener(handler(self,self.onButtonClick));
    self.Button_sweep:setEnabled(false);

    local Label_action = Panel_2:getChildByName("Label_action");
    local Label_exp = Panel_2:getChildByName("Label_exp");
    local Label_exit = self.Button_exit:getChildByName("Label_exit");
    local Label_choose = self.Button_choose:getChildByName("Label_choose");
    local Label_sweep = self.Button_sweep:getChildByName("Label_sweep");
    self.Label_tip = Panel_2:getChildByName("Label_tip");
    self.Label_tip:setEnabled(false);
    Label_action:setText(MG_TEXT_COCOS("MLFightResult_ui_1"));
    Label_exp:setText(MG_TEXT_COCOS("MLFightResult_ui_2"));
    Label_exit:setText(MG_TEXT_COCOS("MLFightResult_ui_3"));
    Label_choose:setText(MG_TEXT_COCOS("MLFightResult_ui_4"));
    Label_sweep:setText(MG_TEXT_COCOS("MLFightResult_ui_5"));
    self.Label_tip:setText(MG_TEXT_COCOS("MLFightResult_ui_6"));
end

function MLFightResult:setData(data)
    self.data = data;

    self.Label_actionNum:setText(self.data.use_action);
    self.Label_expNum:setText(self.data.user_exp);
    self.itemDatas = getneedlist(self.data.war_get_item);
    if self.data.isSweep == 1 then--1是扫荡的讨伐结束
        self.Button_sweep:setEnabled(true);
        self.Button_choose:setEnabled(true);
        self.Button_exit:setEnabled(false);
        self.Label_tip:setEnabled(true);
    else
        if tonumber(self.data.is_war_win) == 0 then
            self.Image_title:loadTexture("checkpoint_fail_title.png",ccui.TextureResType.plistType);
        elseif tonumber(self.data.is_war_win) == 1 then
            self.Image_title:loadTexture("checkpoint_win_title.png",ccui.TextureResType.plistType);
        end

    end

    if #self.itemDatas > 0 then
        self:cteatReward();
    end
end

function MLFightResult:cteatReward()
    self.ListView:removeAllItems();
    local itemLay = ccui.Layout:create();
    itemLay:setSize(cc.size(self.ListView:getContentSize().width, self.ListView:getContentSize().height));
    if #self.itemDatas > 5 then
        itemLay:setSize(cc.size(#self.itemDatas*130, self.ListView:getContentSize().height));
    end
    self.ListView:pushBackCustomItem(itemLay);

    self.items = {};
    for i=1,#self.itemDatas do
        local item = resItem.create(self);
        item:setData(self.itemDatas[i].type,self.itemDatas[i].id,self.itemDatas[i].num);
        itemLay:addChild(item);
        item:setNum(self.itemDatas[i].num);
        item:setPosition(cc.p(item:getContentSize().width/2+(i-1)*(item:getContentSize().width+20),itemLay:getContentSize().height/2));
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

function MLFightResult:onButtonClick(sender, eventType)
    buttonClickScale(sender, eventType);
    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_exit then
            local mapInfo = _G.sceneData.layerData.mapInfo;
            print_lua_table(mapInfo);
            if self.data.is_first and mapInfo.city_type <= 4 then--首次通关并且要类型小等于4的城池
                local layer1 = cc.Director:getInstance():getRunningScene():getChildByTag(5201);
                layer1:isUpLevel(false);
                require "MLFirstReward";
                local firstReward = MLFirstReward.showBox(layer1);
                firstReward:setData(mapInfo);

                local layer = cc.Director:getInstance():getRunningScene():getChildByTag(5200);
                if layer then
                    layer:back();
                end
            end
            self:removeFromParent();
            
        elseif sender == self.Button_choose then--重新选路
            if self.delegate and self.delegate.addSweepLayer then
                self.delegate:addSweepLayer(2);
            end
            self:removeFromParent();
        elseif sender == self.Button_sweep then--再次扫荡
            if self.delegate and self.delegate.addSweepLayer then
                self.delegate:addSweepLayer(3);
            end
            self:removeFromParent();
        end
    end
end

function MLFightResult:onEnter()

end

function MLFightResult:onExit()
    MGRCManager:releaseResources("MLFightResult");
end

function MLFightResult.create(delegate)
    local layer = MLFightResult:new()
    layer:init()
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

function MLFightResult.showBox(delegate)
    local layer = MLFightResult.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_PRIORITY);
    return layer;
end
