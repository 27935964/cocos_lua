----云中城天使转生效果Item界面----

local AngelTransItem=class("AngelTransItem",function()
	return cc.Layer:create();
end);

function AngelTransItem:ctor()
    self.height=30;
    local sy=self.height/2;

    self.descLabel=cc.Label:createWithTTF("0",ttf_msyh,20);
    self.descLabel:setAnchorPoint(cc.p(0, 0.5));
    self.descLabel:setPosition(cc.p(5,sy));
    self:addChild(self.descLabel);

    self.beforeLabel=cc.Label:createWithTTF("0",ttf_msyh,20);
    self.beforeLabel:setColor(cc.c3b(188,169,102));
    self.beforeLabel:setAnchorPoint(cc.p(0.5, 0.5));
    self.beforeLabel:setPosition(cc.p(185+70, sy));
    self:addChild(self.beforeLabel);
    self.beforeLabel:setVisible(false);

    self.arrowSp=cc.Sprite:createWithSpriteFrameName("com_arrow.png");
    self:addChild(self.arrowSp);
    self.arrowSp:setPosition(280+60,sy);
    self.arrowSp:setVisible(false);

    self.laterLabel=cc.Label:createWithTTF("0",ttf_msyh,20);
    self.laterLabel:setColor(Color3B.GREEN);
    self.laterLabel:setAnchorPoint(cc.p(0.5, 0.5));
    self.laterLabel:setPosition(cc.p(370+60,sy));
    self:addChild(self.laterLabel);
    self.laterLabel:setVisible(false);
end

function AngelTransItem:setData(beforeDb,laterDb)
    local descStr="";
    local beforeStr="";
    local laterStr="";
    -- 
    local before_info=spliteStr(beforeDb.effect,'|');
    print("#before_info=====1111",#before_info)
    print("before_info==",beforeDb.effect)
    
    local later_info=spliteStr(laterDb.effect,'|');
    print("#later_info=====2222",#later_info)
    print("later_info==",laterDb.effect)
    for i=1,#later_info do
        local beforeVal=0; --左边的值
        if i<=#before_info then
            local eff_before=spliteStr(before_info[i],':');
            beforeVal=eff_before[2];
        end
        -- 
        local eff_later=spliteStr(later_info[i],':');
        print("eff_later==",later_info[i])
        local sql=string.format("select * from effect where id=%d",eff_later[1]);
        local tmpDb=LUADB.select(sql, "name:value_type:desc");
        if tonumber(eff_later[1])>100 then
            -- beforeVal=eff_later[2];
            -- if tonumber(tmpDb.info.value_type)==1 then
            --     descStr=descStr..tmpDb.info.name..string.format("%d",beforeVal);
            -- else
            --     descStr=descStr..tmpDb.info.name..string.format("%d%s",beforeVal,"%");
            -- end
            -- laterStr="";

            descStr=descStr..tmpDb.info.name;
            if tonumber(tmpDb.info.value_type)==1 then
                beforeStr=beforeStr..string.format("%d",beforeVal);
                laterStr=laterStr..string.format("%d",eff_later[2]);
            else
                beforeStr=beforeStr..string.format("%d%s",beforeVal,"%");
                laterStr=laterStr..string.format("%d%s",eff_later[2],"%");
            end
        else
            descStr=descStr..MG_TEXT("AngelTransItem_1")..tmpDb.info.name..MG_TEXT("AngelTransItem_2");
            beforeStr=beforeStr..string.format("%d",beforeVal);
            laterStr=laterStr..string.format("%d",eff_later[2]);
        end
        descStr=descStr.."\n";
        if string.len(beforeStr)>0 then
            beforeStr=beforeStr.."\n";
            laterStr=laterStr.."\n";
        end
    end
    self:setContentSize(self:getContentSize().width,self.height*#later_info);
    local sy=self:getContentSize().height/2;
    self.descLabel:setString(descStr);
    self.descLabel:setPositionY(sy);
    if string.len(beforeStr)>0 then
        self.beforeLabel:setString(beforeStr);
        self.beforeLabel:setVisible(true);
        self.beforeLabel:setPositionY(sy);
        self.arrowSp:setVisible(true);
        self.arrowSp:setPositionY(sy);
        self.laterLabel:setString(laterStr);
        self.laterLabel:setVisible(true);
        self.laterLabel:setPositionY(sy);
    end
end

function AngelTransItem:onEnter()
end

function AngelTransItem:onExit()
	MGRCManager:releaseResources("AngelTransItem");
end

return AngelTransItem;