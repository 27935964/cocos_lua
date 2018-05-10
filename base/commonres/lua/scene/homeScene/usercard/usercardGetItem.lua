-----------------------将领属性界面------------------------
require "Item"
require "HeroHeadEx"
require "usercardGetHero"

usercardGetItem = class("usercardGetItem", MGLayer)

function usercardGetItem:ctor()
    self:init();
end

function usercardGetItem:init()
    local pWidget = MGRCManager:widgetFromJsonFile("usercardGetItem","usercard_ui_4.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);--设置描边或者阴影
    
    local Panel_2 = pWidget:getChildByName("Panel_2");



    self.Button_back = Panel_2:getChildByName("Button_back");
    self.Button_back:addTouchEventListener(handler(self,self.onButtonClick));
    local Label_back = self.Button_back:getChildByName("Label_back");
    Label_back:setText(MG_TEXT_COCOS("usercard_ui_5"));
    self.Button_again = Panel_2:getChildByName("Button_again");
    self.Button_again:addTouchEventListener(handler(self,self.onButtonClick));
    local Label_again = self.Button_again:getChildByName("Label_again");
    Label_again:setText(MG_TEXT_COCOS("usercard_ui_4"));
    self.List =  Panel_2:getChildByName("ListView");

    self.Image_icon= Panel_2:getChildByName("Image_icon");
    self.Label_need = MGColorLabel:label()
    self.Label_need:setAnchorPoint(cc.p(0,0.5));
    self.Label_need:setPosition(cc.p(self.Image_icon:getPositionX()+self.Image_icon:getContentSize().width/2+10,self.Image_icon:getPositionY()));
    Panel_2:addChild(self.Label_need,2)

end

function usercardGetItem:setData(getitem,data)
    self.data = data;
    local str_list = spliteStr(data.need,':');  
    local havenum = 0;
    local item =  RESOURCE:getResModelByItemId(tonumber(str_list[2]));
    if item then
        havenum = item:getNum();
    end
    local neednum = tonumber(str_list[3]);
    self.Label_need:clear()
    if neednum<=havenum then
        self.Label_need:appendString(string.format("%d",havenum), Color3B.GREEN, ttf_msyh, 22);
    else
        self.Label_need:appendString(string.format("%d",havenum), Color3B.RED, ttf_msyh, 22);
    end
    self.Label_need:appendString(string.format("/%d",neednum), Color3B.WHITE, ttf_msyh, 22)
    self.Image_icon:loadTexture(string.format("user_card_icon_%s.png",str_list[2]), ccui.TextureResType.plistType)

    if getitem == nil then
        self.List:removeAllItems();
        return;
    end


    local t1 = math.modf(#getitem/5);
    local t2 = #getitem - t1*5
    if t2>0 then
        t1 = t1+1;
    end
    self.itemlist = {}
    self.List:removeAllItems();
    for i=1,t1 do
        local count = 5;
        if i==t1 and t2>0 then
            count = t2;
        end
        local itemLay = ccui.Layout:create();
        local _width = 0;
        local _hight = 160;
        for j=1,count do
            local x = (i-1)*5 + j;
            if x>#getitem then
                break;
            end
            getitem[x].item_type = tonumber(getitem[x].item_type);
            getitem[x].item_id = tonumber(getitem[x].item_id);
            getitem[x].item_num = tonumber(getitem[x].item_num);

            local item = resItem.create();
            item:setData(getitem[x].item_type,getitem[x].item_id,getitem[x].item_num);
            item:setVisible(false);
            local newitem = {}
            newitem.item = item;
            if getitem[x].item_type==8 then
                newitem.type = 1;
            else
                newitem.type = 2;
                item:setNum(getitem[x].item_num);
            end
            newitem.sliptitem = "";
            table.insert( self.itemlist, newitem);
            item:setPosition(cc.p(item:getContentSize().width/2+(item:getContentSize().width+40)*(j-1),80));
            itemLay:addChild(item);

            if getitem[x].item_type==8 and getitem[x].item then
                    getitem[x].item.item_type = tonumber(getitem[x].item.item_type);
                    getitem[x].item.item_id   = tonumber(getitem[x].item.item_id);
                    getitem[x].item.item_num  = tonumber(getitem[x].item.item_num);

                    local item = resItem.create();
                    item:setData(getitem[x].item.item_type,getitem[x].item.item_id,getitem[x].item.item_num);
                    item:setVisible(false);
                    item:setNum(getitem[x].item.item_num);
                    newitem.sliptitem = item.gm:name();

                    local newitem1 = {}
                    newitem1.item = item;
                    newitem1.type = 2;
                    newitem1.sliptitem = "";
                    table.insert( self.itemlist, newitem1);

                    item:setPosition(cc.p(item:getContentSize().width/2+(item:getContentSize().width+40)*(j-1),80));
                    itemLay:addChild(item);
            end

            _width=item:getContentSize().width;
        end
        if t1==1 and t2>0 then
            itemLay:setSize(cc.size(_width*t2+40*(t2-1), _hight));
        else
            itemLay:setSize(cc.size(_width*5+40*4, _hight));
        end
        self.List:pushBackCustomItem(itemLay);
    end

    if t1 == 1 then
        self.List:setSize(cc.size(self.List:getSize().width, 160));
        self.List:setPositionY(260);
    end

    local function updateTimef(dt)
        if self.ishero == false then
            if self.itemlist[self.index].type == 1 then
                self.ishero = true;
                self.itemlist[self.index].type = 0;
                local usercardGetHero = usercardGetHero.create(self);
                usercardGetHero:setData(self.itemlist[self.index].item.gm);
                cc.Director:getInstance():getRunningScene():addChild(usercardGetHero,ZORDER_MAX+1);
            elseif self.itemlist[self.index].type == 0 then
                if self.itemlist[self.index].sliptitem == "" then

                    self.index = self.index+1;
                else
                    MGMessageTip:showFailedMessage(string.format(MG_TEXT("usercard_4"),self.itemlist[self.index].sliptitem));

                    local upAnim = MGCartoon:create("pub_1", "pub_1")
                    upAnim:setAnchorPoint(cc.p(0.5,0.5))
                    upAnim:setScale(0.3);
                    upAnim:setPosition(self.itemlist[self.index].item:getPosition())
                    self.itemlist[self.index].item:getParent():addChild(upAnim,ZORDER_MAX)
                    local function removeAnim()
                        upAnim:stop()
                        upAnim:removeFromParent()
                    end

                    local func = cc.CallFunc:create(removeAnim)
                    upAnim:playEx(false,func)

                    self.itemlist[self.index].item:setVisible(false);
                    self.index = self.index+1;
                    return;
                end
                
            end
            self.itemlist[self.index].item:setVisible(true);
            if self.index==#self.itemlist  then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
            end
            if self.itemlist[self.index].type == 2 then
                self.index = self.index+1;
            end
        end
    end
    self.index = 1;
    self.ishero = false;
    self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(updateTimef, 0.1, false)

end

function usercardGetItem:GetHeroShow()
    self.ishero = false;
end

function usercardGetItem:onButtonClick(sender, eventType)
    buttonClickScale(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_back then
            self:removeFromParent();
        end
        if sender == self.Button_again then
            if self.delegate and self.delegate.senduseCardBag then
                local id = tonumber(self.data.id);
                self.delegate:senduseCardBag(id);
            end
            self:removeFromParent();
        end

    end
end



function usercardGetItem:onEnter()

end

function usercardGetItem:onExit()
    MGRCManager:releaseResources("usercardGetItem");
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
end

function usercardGetItem.create(delegate)
    local layer = usercardGetItem:new()
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
