-----------------------将领属性界面------------------------
require "Item"
require "HeroHeadEx"

usercardlook = class("usercardlook", MGLayer)

function usercardlook:ctor()
    self:init();
end

function usercardlook:init()
    local pWidget = MGRCManager:widgetFromJsonFile("usercardlook","usercard_ui_2.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);--设置描边或者阴影
    
    local Panel_2 = pWidget:getChildByName("Panel_2");
    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_close = Panel_2:getChildByName("Button_close");
    self.Button_close:addTouchEventListener(handler(self,self.onButtonClick));

    self.List =  Panel_2:getChildByName("ListView");
    self.CheckBoxs = {};
    self.Label_check = {};
    for i=1,2 do
        local checkBox = Panel_2:getChildByName(string.format("CheckBox_%d",i))
        local Label_check = checkBox:getChildByName("Label_check");
        if i==1 then
            Label_check:setText(MG_TEXT_COCOS("usercard_ui_1"));
        else
            Label_check:setText(MG_TEXT_COCOS("usercard_ui_2"));
        end
        Label_check:setColor(cc.c3b(130,130,111));
        checkBox:setTag(i)
        checkBox:addEventListenerCheckBox(handler(self,self.selectedEvent))
        table.insert(self.CheckBoxs, checkBox)
        table.insert(self.Label_check, Label_check)
    end
    self.CheckBoxs[1]:setSelectedState(true)
    self.Label_check[1]:setColor(cc.c3b(255,255,255));
    self.kind=1;
    
end

function usercardlook:selectedEvent(sender,eventType)
    for k,v in pairs(self.CheckBoxs) do
        v:setSelectedState(false)
    end
    sender:setSelectedState(true)
    if sender == self.CheckBoxs[1] then
        self.Label_check[1]:setColor(cc.c3b(255,255,255));
        self.Label_check[2]:setColor(cc.c3b(130,130,111));
    else
        self.Label_check[2]:setColor(cc.c3b(255,255,255));
        self.Label_check[1]:setColor(cc.c3b(130,130,111));
    end
    if self.kind ~= sender:getTag() then
        self.kind =  sender:getTag();
        self:changeKind();
    end
end

function usercardlook:changeKind()
    if self.kind==1 then
        local sql = string.format("select item_id from general_card_bag_value where b_id=%d and item_type=8 order by quality desc",self.id)
        local DBDataList = LUADB.selectlist(sql, "item_id");

        if DBDataList == nil then
            self.List:removeAllItems();
            return;
        end
        self.gmlist = {}
        for i=1,#DBDataList.info do
            local gm = GENERAL:getDBGeneralModel(DBDataList.info[i].item_id);
            if gm then
                table.insert(self.gmlist,gm);
            end
        end
        local itemLay = ccui.Layout:create();
        local _width = 0;
        local _hight = 0;

        local t1;
        local t2;
        t1,t2 = math.modf(#self.gmlist/6);
        if t2>0 then
            t1 = t1+1;
        end
        if t1 < 3 then
            t1=3;
        end
    
        self.List:removeAllItems();
        for i=1,t1 do
            for j=1,6 do
                local x = (i-1)*6 + j;
                if x>#self.gmlist then
                    break;
                end
                local item = HeroHeadEx.create();
                item:setData(self.gmlist[x]);
                item.boxSpr:loadTexture("com_item_kuan_1.png",ccui.TextureResType.plistType);
                item.lvLabel:setVisible(false);
                item:setPosition(cc.p(25+item:getContentSize().width/2+(item:getContentSize().width+15)*(j-1),40+item:getContentSize().height/2+(item:getContentSize().height+15)*(t1-i)));
                itemLay:addChild(item);
                _width=item:getContentSize().width;
                _hight=item:getContentSize().height;
            end
        end
        itemLay:setSize(cc.size(40+(_width+15)*6, 40+(_hight+15)*t1));
        self.List:pushBackCustomItem(itemLay);

    else
        local sql = string.format("select item_id from general_card_bag_value where b_id=%d and item_type<>8 order by item_type desc",self.id)
        local DBDataList = LUADB.selectlist(sql, "item_id");

        if DBDataList == nil then
            self.List:removeAllItems();
            return;
        end
        self.gmlist = {}
        for i=1,#DBDataList.info do
            local gm = ResourceModel:create(DBDataList.info[i].item_id,true);
            if gm then
                table.insert(self.gmlist,gm);
            end
        end
        local itemLay = ccui.Layout:create();
        local _width = 0;
        local _hight = 0;

        local t1;
        local t2;
        t1,t2 = math.modf(#self.gmlist/6);
        if t2>0 then
            t1 = t1+1;
        end
        if t1 < 3 then
            t1=3;
        end
    
        self.List:removeAllItems();
        for i=1,t1 do
            for j=1,6 do
                local x = (i-1)*6 + j;
                if x>#self.gmlist then
                    break;
                end
                local item = Item.create();
                item:setData(self.gmlist[x]);
                item:numHide();
                item:setPosition(cc.p(25+item:getContentSize().width/2+(item:getContentSize().width+15)*(j-1),40+item:getContentSize().height/2+(item:getContentSize().height+15)*(t1-i)));
                itemLay:addChild(item);
                _width=item:getContentSize().width;
                _hight=item:getContentSize().height;
            end
        end
        itemLay:setSize(cc.size(40+(_width+15)*6, 40+(_hight+15)*t1));
        self.List:pushBackCustomItem(itemLay);
    end
end

function usercardlook:setData(id)
    self.id = id;
    self:changeKind();

end

function usercardlook:onButtonClick(sender, eventType)
    buttonClickScale(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_close then
            self:removeFromParent();
        elseif sender == self.Panel_1 then
            self:removeFromParent();
        end
    end
end



function usercardlook:onEnter()

end

function usercardlook:onExit()
    MGRCManager:releaseResources("usercardlook");
end

function usercardlook.create(delegate)
    local layer = usercardlook:new()
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
