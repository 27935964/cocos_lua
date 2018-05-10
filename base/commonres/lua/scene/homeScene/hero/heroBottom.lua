-----------------------英雄底界面------------------------

heroBottom = class("heroBottom", MGLayer)
function heroBottom:ctor()
    
end

function heroBottom:init()
    MGRCManager:cacheResource("heroBottom", "hero_bottom_line.png");
    MGRCManager:cacheResource("heroBottom", "heroui.png","heroui.plist");
    local pWidget = MGRCManager:widgetFromJsonFile("heroBottom","herobottom_ui_1.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);

    local Panel_2 = pWidget:getChildByName("Panel_2");
    local Panel_left = Panel_2:getChildByName("Panel_left");
    self.CheckBoxs = {};
    for i=1,7 do
        local checkBox = Panel_left:getChildByName(string.format("CheckBox_%d",i))
        checkBox:setTag(i)
        checkBox:addEventListenerCheckBox(handler(self,self.selectedEvent))
        table.insert(self.CheckBoxs, checkBox)
    end
    self.CheckBoxs[1]:setSelectedState(true)

    local Panel_bottom = Panel_2:getChildByName("Panel_bottom");
    self.list_hero = Panel_bottom:getChildByName("ListView_hero");
    self.gmlist = GENERAL:getGeneralList();
    local itemLay = ccui.Layout:create();
    local _width = 15;
    local _hight = 0;

    table.sort(self.gmlist,function(a,b) return a:getWarScore() > b:getWarScore(); end);
    for i=1,#self.gmlist do
        local item = HeroHeadEx.create(self);
        item:setData(self.gmlist[i]);
        item:setPosition(cc.p(15+item:getContentSize().width/2+(15+item:getContentSize().width)*(i-1),item:getContentSize().height/2));
        itemLay:addChild(item);
        _width=15+item:getContentSize().width+(15+item:getContentSize().width)*(i-1);
        _hight=item:getContentSize().height;

        if self.gm:getId() == self.gmlist[i]:getId() then
            self.selitem = item;
        end
    end
    itemLay:setSize(cc.size(_width, _hight));
    self.list_hero:pushBackCustomItem(itemLay);
    self.selitem:setSel(true);
    self:HeroHeadSelect(self.selitem);
end

function heroBottom:selectedEvent(sender,eventType)
    for k,v in pairs(self.CheckBoxs) do
        v:setSelectedState(false)
    end
    sender:setSelectedState(true)
    local kind =  sender:getTag();
    if self.delegate and self.delegate.changeKind then
        self.delegate:changeKind(kind);
    end
end

function heroBottom:HeroHeadSelect(head)
    if self.selitem~= head then
        self.selitem:setSel(false);
        self.selitem=head;
        self.selitem:setSel(true);
    end
    if self.delegate and self.delegate.changeHero then
        self.delegate:changeHero(head.gm);
    end
end


function heroBottom:onEnter()
end

function heroBottom:onExit()

    MGRCManager:releaseResources("heroBottom");
end

function heroBottom.create(delegate,gm)
    local layer = heroBottom:new()
    layer.delegate = delegate
    layer.gm = gm
    layer:init();
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
