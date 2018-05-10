-----------------------将领属性界面------------------------
require "scienceItem"
require "SciSoldierLayer"

scienceLayer = class("scienceLayer", MGLayer)

function scienceLayer:ctor()
    self:init();
end

function scienceLayer:init()

    local pWidget = MGRCManager:widgetFromJsonFile("scienceLayer","science_ui_1.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);
    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));

    self.Panel_2 = pWidget:getChildByName("Panel_2");
    self.Panel_2:addTouchEventListener(handler(self,self.onButtonClick));
    self.list = self.Panel_2:getChildByName("ListView");
    self:createlist();
end

function scienceLayer:createlist()
    self.list:removeAllItems();
    local DBDataList = LUADB.selectlist("select science_id,name,des,pic,introduce,open_lv from science order by show", "science_id:name:des:pic:introduce:open_lv");

    local itemLay = ccui.Layout:create();
    local _width = 0;
    local _hight = 0;  

    for i=1,#DBDataList.info do
        local scienceItem = scienceItem.create(self);
        MGRCManager:cacheResource("scienceLayer",DBDataList.info[i].pic..".jpg");
            scienceItem:setData(DBDataList.info[i]);
            scienceItem:setPosition(cc.p(125+scienceItem:getContentSize().width/2+(scienceItem:getContentSize().width+38)*(i-1),scienceItem:getContentSize().height/2));
            itemLay:addChild(scienceItem);
            _width=scienceItem:getContentSize().width;
            _hight=scienceItem:getContentSize().height;
    end
    itemLay:setSize(cc.size(125+(_width+83)*#DBDataList.info, _hight));
    if itemLay:getSize().width<self.list:getSize().width then
        self.list:setSize(itemLay:getSize());
        self.list:setPositionX((self.Panel_2:getSize().width - self.list:getSize().width)/2);
    end
    self.list:pushBackCustomItem(itemLay);
end

function scienceLayer:onButtonClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        if sender == self.Panel_2  or sender == self.Panel_1 then
            self:removeFromParent();
        end
    end
end

function scienceLayer:EnterSci(item)
    self.selItemData = item.data;
    print(self.selItemData.science_id);
    if self.selItemData.science_id ==1 then
        local SciSoldierLayer = SciSoldierLayer.create(self);
        cc.Director:getInstance():getRunningScene():addChild(SciSoldierLayer,ZORDER_MAX);
    end
end

function scienceLayer:onEnter()

end

function scienceLayer:onExit()
    MGRCManager:releaseResources("scienceLayer");
end

function scienceLayer.create(delegate)
    local layer = scienceLayer:new()
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

function scienceLayer.showBox(delegate)
    local layer = scienceLayer.create(delegate);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    return layer;
end