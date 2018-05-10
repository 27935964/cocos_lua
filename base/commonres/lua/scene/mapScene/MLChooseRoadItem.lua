
MLChooseRoadItem = class("MLChooseRoadItem", MGLayer)

function MLChooseRoadItem:ctor()
    self:init();
end

function MLChooseRoadItem:init()
    local pWidget = MGRCManager:widgetFromJsonFile("MLChooseRoadItem","checkpoint_choose_road_item_ui.ExportJson");
    self:addChild(pWidget);
    self:setContentSize(pWidget:getContentSize());

    self.Label_name = pWidget:getChildByName("Label_name");
    self.Button_choose = pWidget:getChildByName("Button_choose");
    self.Button_choose:addTouchEventListener(handler(self,self.onButtonClick));

    self.Image_mark = pWidget:getChildByName("Image_mark");
    self.Image_mark:setVisible(false);
    self.Panel_tip = pWidget:getChildByName("Panel_tip");

    self.desLabel = MGColorLabel:label();
    self.desLabel:setAnchorPoint(cc.p(0.5, 1));
    self.desLabel:setPosition(cc.p(self.Panel_tip:getContentSize().width/2,self.Panel_tip:getContentSize().height));
    self.Panel_tip:addChild(self.desLabel);

end

function MLChooseRoadItem:setData(checkpointList,next,index,isShow)
    self.checkpointList = checkpointList;
    self.isShow = isShow;
    self.next = next;
    self.checkpointData = self.checkpointList[next.nextId];
    self.Label_name:setText(string.format("%d.%s",index,self.checkpointData.name));
    self:setDescribe();

    self.Image_mark:setVisible(isShow);
end

function MLChooseRoadItem:setDescribe()
    if self.next.type == 0 then
        return;
    end
    local id = self.next.type;
    local sql = string.format("select * from stage_pass_condition where id=%d", id);
    local DBData = LUADB.select(sql, "id:desc");

    local DBData1 = nil;
    local str = "";
    if id == 1 then
        DBData1 = LUADB.select(string.format("select * from soldier_list where id=%d", self.next.value), "id:name");
        str = string.format(DBData.info.desc,DBData1.info.name,self.next.needValue);
    elseif id == 2 then
        str = string.format(DBData.info.desc,MG_TEXT("sex_"..self.next.value),self.next.needValue);
    elseif id == 4 then
        DBData1 = LUADB.select(string.format("select * from quality where id=%d", self.next.value), "id:desc");
        str = string.format(DBData.info.desc,DBData1.info.desc,self.next.needValue);
    elseif id == 5 then
        str = string.format(DBData.info.desc,self.next.needValue);
    elseif id == 3 or id == 6 or id == 7 or id == 8 or id == 9 or id == 10 or id == 11 or id == 12 or id == 13 then
        str = string.format(DBData.info.desc,self.next.value,self.next.needValue);
    elseif id == 14 then
        str = string.format(DBData.info.desc,MG_TEXT("hero_type_"..self.next.value),self.next.needValue);
    elseif id == 15 then
        DBData1 = LUADB.select(string.format("select * from general_list where id=%d", self.next.value), "id:name");
        str = string.format(DBData.info.desc,DBData1.info.name);
    end
    
    self.desLabel:clear();
    self.desLabel:appendStringAutoWrap(str,16,1,cc.c3b(255,255,255),20);
end

function MLChooseRoadItem:onButtonClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        if self.isShow then
            MGMessageTip:showFailedMessage(MG_TEXT("ML_CheckpointLayer_7"));
        else
            if self.delegate and self.delegate.runAction then
                self.delegate:runAction(self.next.nextId);
            end
        end
    end
end

function MLChooseRoadItem:onEnter()
    
end

function MLChooseRoadItem:onExit()
    MGRCManager:releaseResources("MLChooseRoadItem")
end

function MLChooseRoadItem.create(delegate)
    local layer = MLChooseRoadItem:new()
    layer.delegate = delegate;
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
