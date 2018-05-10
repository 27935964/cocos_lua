-----------------------将领属性界面------------------------

getItem = class("getItem", MGLayer)

function getItem:ctor()

end

function getItem:init(strgetitem,title)
    local pWidget = MGRCManager:widgetFromJsonFile("getItem","getitem_ui.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);--设置描边或者阴影
    
    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));

    if title then
        local Label_show = self.Panel_1:getChildByName("Label_show");
        Label_show:setText(title);
    end

    local Label_get = self.Panel_1:getChildByName("Label_get");
    Label_get:setText(MG_TEXT_COCOS("getitem_ui_get"));

    local _width = self.Panel_1:getSize().width;
    local _hight = self.Panel_1:getSize().height;
    local list = getneedlist(strgetitem);
    for i=1,#list do
        local item = resItem.create();
        item:setData(list[i].type,list[i].id);
        item:setNum(list[i].num);
        item:setScale(0.7);
        item:setPosition(cc.p(_width/2-160-item:getContentSize().width*#list*0.7/2+item:getContentSize().width*0.7/2,_hight/2));
        self.Panel_1:addChild(item);
        -- 模仿跳跃的轨迹移动节点，第一个参数为持续时间，第二个参数为位置，第三个参数为跳的高度，第四个参数跳的次数
        local actionTo1 = cc.JumpTo:create(0.25, cc.p(item:getPositionX()+40+item:getContentSize().width*(i-1)*0.2,item:getPositionY()), 60, 1)
        local actionTo2 = cc.JumpTo:create(0.25, cc.p(item:getPositionX()+80+item:getContentSize().width*(i-1)*0.35,item:getPositionY()), 40, 1)
        local actionTo3 = cc.JumpTo:create(0.25, cc.p(item:getPositionX()+120+item:getContentSize().width*(i-1)*0.5,item:getPositionY()), 20, 1)
        local actionTo4 = cc.JumpTo:create(0.25, cc.p(item:getPositionX()+160+item:getContentSize().width*(i-1)*0.7,item:getPositionY()), 10, 1)
        local sequence = cc.Sequence:create(actionTo1, actionTo2,actionTo3,actionTo4)
        -- 执行actionTo动作
        item:runAction(sequence)
    end
end

function getItem:onButtonClick(sender, eventType)
    --buttonClickScale(sender, eventType);
    if eventType == ccui.TouchEventType.ended then
        if sender == self.Panel_1 then
            self:removeFromParent();
        end
    end
end

function getItem:onEnter()

end

function getItem:onExit()
    MGRCManager:releaseResources("getItem");
end

function getItem.create(strgetitem,title)
    local layer = getItem:new()
    layer:init(strgetitem,title);
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


function getItem.showBox(strgetitem,title)
    local layer = getItem.create(strgetitem,title);
    cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_PRIORITY);
    return layer;
end
