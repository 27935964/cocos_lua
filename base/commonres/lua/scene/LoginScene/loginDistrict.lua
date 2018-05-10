------------------------选区界面-------------------------

local loginDistrict = class("loginDistrict", MGLayer)

function loginDistrict:ctor()
    self:init();
end

function loginDistrict:init()
    MGRCManager:cacheResource("LoginLayer", "login_bg.jpg");
    MGRCManager:cacheResource("loginDistrict", "login_server_ui0.png","login_server_ui0.plist");
    local pWidget = MGRCManager:widgetFromJsonFile("loginDistrict","login_district_ui.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);

    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:setAnchorPoint(cc.p(0.5, 0.5));
    CommonMethod:setFullBgScale(self.Panel_1);

    self.Panel_1:setTouchEnabled(false);
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));

    local Panel_2 = pWidget:getChildByName("Panel_2");

    self.ListView = Panel_2:getChildByName("ListView");
    self.ListView:setScrollBarVisible(false);

    self.ListView_btn = Panel_2:getChildByName("ListView_btn");
    self.ListView:setScrollBarVisible(false);

    --关 闭
    self.Button_close = Panel_2:getChildByName("Button_close");
    self.Button_close:addTouchEventListener(handler(self,self.onButtonClick));

    local Label_tip1 = Panel_2:getChildByName("Label_tip1");
    Label_tip1:setText(MG_TEXT_COCOS("login_district_ui_1"));

    local Label_tip2 = Panel_2:getChildByName("Label_tip2");
    Label_tip2:setText(MG_TEXT_COCOS("login_district_ui_2"));

    local Label_tip3 = Panel_2:getChildByName("Label_tip3");
    Label_tip3:setText(MG_TEXT_COCOS("login_district_ui_2"));

    NodeListener(self);

    if not self.itemWidget then
        self.itemWidget = MGRCManager:widgetFromJsonFile("loginDistrict", "login_district_item_ui.ExportJson",false);
        self.itemWidget:retain();
    end

    self:createBtn();
    self:createItem();
end

function loginDistrict:upData()
    

end

function loginDistrict:setData(data)
    self.data = data;

    -- self.ListView:removeAllItems();
    -- for i=1,#self.mercenary.union_mercenary do
    --     local loginDistrictItem = require "loginDistrictItem"
    --     local item = loginDistrictItem.create(self,self.itemWidget:clone());
    --     item:setData(self.data,self.mercenary,i);
    --     self.ListView:pushBackCustomItem(item);
    -- end
end

function loginDistrict:createItem()

    local count = 7--#self.data.item;
    local col = 2;
    local row = math.ceil(count/col);
    

    self.ListView:removeAllItems();
    local loginDistrictItem = require "loginDistrictItem"
    local modItem = loginDistrictItem.create(self,self.itemWidget:clone());

    local itemLay = ccui.Layout:create();
    itemLay:setSize(cc.size(self.ListView:getContentSize().width,(modItem:getContentSize().height+5)*row));
    self.ListView:pushBackCustomItem(itemLay);


    for i=1,row do
        for j=1,col do
            local x = (i-1)*col + j;
            if x>count then
                break;
            end
            local item = loginDistrictItem.create(self,self.itemWidget:clone());
            -- item:setData(self.data.item[x],self.treasureData);
            item:setPosition(cc.p(itemLay:getContentSize().width/4+itemLay:getContentSize().width/2*(j-1),
                itemLay:getContentSize().height-item:getContentSize().height/2-10-
                (item:getContentSize().height+5)*(i-1)));
            itemLay:addChild(item);
        end
    end
end

function loginDistrict:createBtn()
    self.ListView_btn:removeAllItems();
    self.btnInfo = {};

    local itemLay = ccui.Layout:create();
    itemLay:setSize(cc.size(self.ListView_btn:getContentSize().width,80*10));
    self.ListView_btn:pushBackCustomItem(itemLay);

    for i=1,10 do
        local btnImg = ccui.ImageView:create("pagetab_up.png", ccui.TextureResType.plistType);
        btnImg:setTouchEnabled(true);
        btnImg:addTouchEventListener(handler(self,self.onClick));
        btnImg:setPosition(cc.p(itemLay:getContentSize().width/2,itemLay:getContentSize().height
            -btnImg:getContentSize().height/2-(i-1)*(btnImg:getContentSize().height+5)));
        itemLay:addChild(btnImg)

        local nameLabel = cc.Label:createWithTTF("投 影",ttf_msyh,22);
        nameLabel:enableShadow(cc.c4b(0,   0,   0, 191), cc.size(2, -2),2);--投影
        nameLabel:setPosition(cc.p(btnImg:getContentSize().width/2,btnImg:getContentSize().height/2));
        btnImg:addChild(nameLabel);

        -- self.ListView_btn:pushBackCustomItem(btnImg);

        table.insert(self.btnInfo,{btn=btnImg,name=nameLabel});
    end
end

function loginDistrict:onClick(sender, eventType)
    
    if eventType == ccui.TouchEventType.ended then

    end

end

function loginDistrict:onButtonClick(sender, eventType)
    buttonClickScale(sender, eventType);
    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_register then
            if self.editBox_1:getText() == "" then
                MGMessageTip:showFailedMessage(MG_TEXT("loginDistrict_6"));
                return;
            end
            if self.editBox_2:getText() == "" then
                MGMessageTip:showFailedMessage(MG_TEXT("loginDistrict_2"));
                return;
            end
            if self.editBox_3:getText() == "" then
                MGMessageTip:showFailedMessage(MG_TEXT("loginDistrict_3"));
                return;
            end

            if self.editBox_2:getText() == self.editBox_3:getText() then
                if self.state then
                    self:sendReq();
                else
                    MGMessageTip:showFailedMessage(MG_TEXT("loginDistrict_5"));
                end
            else
                MGMessageTip:showFailedMessage(MG_TEXT("loginDistrict_4"));
            end
        elseif sender == self.Button_close then
            self:removeFromParent();
        end
    end
end

-- function loginDistrict:onReciveData(MsgID, NetData)
--     print("loginDistrict onReciveData MsgID:"..MsgID)
--     if MsgID == Post_Mobile_App_doRegister then
--         if NetData.state == 1 then
            
--         else
--             NetHandler:showFailedMessage(NetData);
--         end
--     end
-- end

-- function loginDistrict:sendReq()
--     local str = string.format("&act=%s&pwd=%s",self.editBox_1:getText(),self.editBox_2:getText());
--     NetHandler:sendData(Post_Mobile_App_doRegister, str);
-- end

-- function loginDistrict:pushAck()
--     NetHandler:addAckCode(self,Post_Mobile_App_doRegister);
-- end

-- function loginDistrict:popAck()
--     NetHandler:delAckCode(self,Post_Mobile_App_doRegister);
-- end

function loginDistrict:onEnter()
    -- self:pushAck();
end

function loginDistrict:onExit()
    -- self:popAck();
    MGRCManager:releaseResources("loginDistrict");
end

return loginDistrict;
