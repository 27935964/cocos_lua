--------------------------君王之路入口-----------------------


local kingRoadBtn = class("kingRoadBtn",function()  
    return ccui.Layout:create(); 
end)

function kingRoadBtn:ctor(delegate)
    self.delegate = delegate;
    self.items = {};
    self.isOpen = false;--是否展开
    self:init();
end

function kingRoadBtn:init()
    self:setSize(cc.size(215, 105));
    self:setAnchorPoint(cc.p(0.5,0.5));

    -- self:setBackGroundColorType(1);
    -- self:setBackGroundColor(cc.c3b(0,255,250));

    --父按钮
    self.parentBtn = ccui.ImageView:create("TheRoadOfKings_Button_Title_0.png", ccui.TextureResType.plistType);
    self.parentBtn:setPosition(cc.p(self:getContentSize().width/2, 
        self:getContentSize().height-self.parentBtn:getContentSize().height/2-3));
    self.parentBtn:setTouchEnabled(true);
    self.parentBtn:addTouchEventListener(handler(self,self.onButtonClick));
    self:addChild(self.parentBtn);

    self.selectImg = ccui.ImageView:create("TheRoadOfKings_elect_big.png", ccui.TextureResType.plistType);
    self.selectImg:setPosition(self.parentBtn:getPosition());
    self:addChild(self.selectImg,1);
    self.selectImg:setVisible(false);
end

function kingRoadBtn:setData(kingRoadInfos,index)
    self.kingRoadInfos = kingRoadInfos;
    self.index = index;

    local pic = string.format("TheRoadOfKings_Button_Title_%d.png",index);
    self.parentBtn:loadTexture(pic,ccui.TextureResType.plistType);
    self.selectImg:loadTexture("TheRoadOfKings_elect_small.png",ccui.TextureResType.plistType);
    self:setSize(cc.size(215, self.parentBtn:getContentSize().height));
    self.parentBtn:setPositionY(self:getContentSize().height-self.parentBtn:getContentSize().height/2);
    self.selectImg:setPosition(self.parentBtn:getPosition());

end

function kingRoadBtn:createItem(data,tag)
    if #data <= 0 then
        return;
    end

    self.items = {};
    local height = 0;
    local posY = 0;
    for i=1,#data do
        local item = ccui.ImageView:create("TheRoadOfKings_Button_normal.png", ccui.TextureResType.plistType);
        item:setPosition(self.parentBtn:getPosition());
        item:setTouchEnabled(true);
        item:setTag(data[i].type);
        item:addTouchEventListener(handler(self,self.onButtonClick));
        self:addChild(item);

        local nameLabel = cc.Label:createWithTTF("",ttf_msyh,22);
        nameLabel:setPosition(cc.p(item:getContentSize().width/2,item:getContentSize().height/2))
        item:addChild(nameLabel);
        nameLabel:enableShadow(cc.c4b(0,   0,   0, 191), cc.size(2, -2),2);
        nameLabel:setString(data[i].type_name);

        table.insert(self.items,item);
        height = item:getContentSize().height;

        if tag == item:getTag() then
            item:loadTexture("TheRoadOfKings_Button_selected.png",ccui.TextureResType.plistType);
            self:onButtonClick(item, ccui.TouchEventType.ended);
        end
    end

    local sizeH = self.parentBtn:getContentSize().height + #data*(height+5)+10;
    self:setSize(cc.size(215, sizeH));
    posY = self:getContentSize().height-self.parentBtn:getContentSize().height/2;
    self.parentBtn:setPositionY(posY);
    self.selectImg:setPosition(self.parentBtn:getPosition());
    posY = self.parentBtn:getPositionY()-height/2-self.parentBtn:getContentSize().height/2-10;
    for i=1,#self.items do
        self.items[i]:setPositionY(posY);
        posY = posY - height-5;
    end
end

function kingRoadBtn:removeItems()
    if self.items then
        for i=1,#self.items do
            if self.items[i] and self.items[i]:getParent() then
                self.items[i]:removeFromParent();
            end
        end
        self.items = {};
    end

    self:setSize(cc.size(215, self.parentBtn:getContentSize().height));
    self.parentBtn:setPositionY(self:getContentSize().height-self.parentBtn:getContentSize().height/2);
    self.selectImg:setPosition(self.parentBtn:getPosition());
end

function kingRoadBtn:onClick()
    self:onButtonClick(self.parentBtn, ccui.TouchEventType.ended);
end

function kingRoadBtn:onButtonClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        if sender == self.parentBtn then--父按钮
            if self.delegate and self.delegate.onSelect then
                self.isOpen = not self.isOpen;
                self.delegate:onSelect(self);
            end
        else--子按钮事件
            for i=1,#self.items do
                self.items[i]:loadTexture("TheRoadOfKings_Button_normal.png",ccui.TextureResType.plistType);
                if sender == self.items[i] then
                    self.items[i]:loadTexture("TheRoadOfKings_Button_selected.png",ccui.TextureResType.plistType);
                end

                if self.delegate and self.delegate.creatTaskList then
                    self.delegate:creatTaskList(self,sender:getTag());
                end
            end
        end
    end
end

function kingRoadBtn:setSelectImgVisible(isVisible)
    self.selectImg:setVisible(isVisible);
end

function kingRoadBtn:onEnter()

end

function kingRoadBtn:onExit()
    MGRCManager:releaseResources("kingRoadBtn");
end

return kingRoadBtn;
