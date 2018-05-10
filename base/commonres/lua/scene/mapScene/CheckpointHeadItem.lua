require "itemInfo"

CheckpointHeadItem = class("CheckpointHeadItem", function()
    return ccui.Layout:create();
end)

function CheckpointHeadItem:ctor(pic)
    self.pic = pic;
    if nil == pic then
        self.pic = "checkpoint_head_prismatic_big.png";
    end
    self.width = 160;
    self.height = 160;
    self:init();
end

function CheckpointHeadItem:init()
    self:setTouchEnabled(true);
    self:setSize(cc.size(self.width, self.height));
    self:setAnchorPoint(cc.p(0.5,0.5));
    self:addTouchEventListener(handler(self,self.onButtonClick));

    --头像框
    self.boxSpr = cc.Sprite:createWithSpriteFrameName("checkpoint_head_normal_box.png");
    self.boxSpr:setPosition(cc.p(self.width/2, self.height/2));
    self:addChild(self.boxSpr);

    local HeroCircleHead=require "HeroCircleHead";--菱形头像
    self.circleHead=HeroCircleHead.new(self.pic,0.98);
    self.circleHead:setPosition(cc.p(self.width/2, self.height/2+5));
    self:addChild(self.circleHead,1);

	self.Label_num = cc.Label:createWithTTF("0", ttf_msyh, 22);
    self.Label_num:setPosition(cc.p(self.width/2, self.height-30));
    self:addChild(self.Label_num,2);
    self.Label_num:setVisible(false);
    self.posY = self.Label_num:getPositionY();
end

function CheckpointHeadItem:setData(checkpointData,c_id,data)
    self.checkpointData = checkpointData;
    if 0 ~= self.checkpointData.npc_id then--是否守关大将
        self.boxSpr:setSpriteFrame("checkpoint_head_box.png");
        if tonumber(data.is_npc) == 1 then
            self:showHead();
        else
            local sql = string.format("select bust from npc where id=%d",self.checkpointData.npc_id);
            local DBData = LUADB.select(sql, "bust");
            if DBData then
                MGRCManager:cacheResource("CheckpointHeadItem",DBData.info.bust..".png");
                self.circleHead:setHeroFace(DBData.info.bust..".png");
                self.circleHead:setStencilPic("checkpoint_head_prismatic_big.png");
                self.circleHead:setHeadScale(0.8);
            end
        end
    else
        if 0 ~= self.checkpointData.reward_limit then--0表示没次数限制，有次数限制是展示资源图标
            self:showHead();
        end
    end

    if self.checkpointData.reward_limit > 0 then
        local num = self.checkpointData.reward_limit;
        for i=1,#data.stage_c_info do
            if c_id == tonumber(data.stage_c_info[i].c_id) then
                num = self.checkpointData.reward_limit-tonumber(data.stage_c_info[i].reward_num);
                break;
            end
        end
        
        self.Label_num:setVisible(false);
        if num > 0 then
            self.Label_num:setString(num);
            self.Label_num:setVisible(true);
        else
            self:setGray(true);
        end
    end
end

function CheckpointHeadItem:showHead()
    if 0 ~= self.checkpointData.reward_flip_show and #self.checkpointData.reward_flip_show >= 1 then
        local reward_flip_show = self.checkpointData.reward_flip_show;
        local infos = itemInfo(reward_flip_show[1].type,reward_flip_show[1].Id);
        MGRCManager:cacheResource("CheckpointHeadItem",infos.item_pic);
        self.circleHead:setHeroFace(infos.item_pic);
        self.circleHead:setHeadScale(0.9);
    else
        if 0 ~= self.checkpointData.reward_show and #self.checkpointData.reward_show >= 1 then
            local reward_show = self.checkpointData.reward_show;
            local infos = itemInfo(reward_show[1].type,reward_show[1].Id);
            MGRCManager:cacheResource("CheckpointHeadItem",infos.item_pic);
            self.circleHead:setHeroFace(infos.item_pic);
            self.circleHead:setHeadScale(0.9);
        end
    end
end

function CheckpointHeadItem:setForeignData(id)--外交头像专用
    local gm = GENERAL:getAllGeneralModel(id);
    self.boxSpr:setSpriteFrame("checkpoint_foreign_box.png");
    self.circleHead:setPosition(cc.p(self.width/2, self.height/2));
    self.Label_num:enableOutline(cc.c4b(81,48,0,255),2);
    self.Label_num:setVisible(true);
    self.Label_num:setString(MG_TEXT_COCOS("checkpoint_ui_1_1"));
    self.Label_num:setPositionY(self.posY-self.boxSpr:getContentSize().height+30);
    MGRCManager:cacheResource("CheckpointHeadItem",gm:bust());
    self.circleHead:setHeroFace(gm:bust());
    self.circleHead:setHeadScale(0.8);
end

function CheckpointHeadItem:setGray(isGray)
    if isGray then
        self.Label_num:setColor(Color3B.GRAY);
        self.boxSpr:setShaderProgram(MGGraySprite:getGrayShaderProgram());
    else
        self.Label_num:setColor(Color3B.WHITE);
        self.boxSpr:setShaderProgram(self:getDefaultProgram());
    end
    self.circleHead:setGray(isGray);
end

function CheckpointHeadItem:onButtonClick(sender, eventType)
    buttonClickScale(sender, eventType);
    if eventType == ccui.TouchEventType.ended then
        if self.delegate and self.delegate.ItemSelect then
            self.delegate:ItemSelect();
        end
    end
end

function CheckpointHeadItem:getDefaultProgram()
    return cc.ShaderCache:getInstance():getProgram("ShaderPositionTextureColor_noMVP");
end

function CheckpointHeadItem:onEnter()

end

function CheckpointHeadItem:onExit()
	MGRCManager:releaseResources("CheckpointHeadItem")
end

function CheckpointHeadItem.create(delegate,pic)
	local layer = CheckpointHeadItem.new(pic)
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
