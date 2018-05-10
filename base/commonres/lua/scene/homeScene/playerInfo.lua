-----------------------将领属性界面------------------------
require "userHead"
require "heroInfo"

playerInfo = class("playerInfo", MGLayer)

function playerInfo:ctor()
    self:init();
end

function playerInfo:init()
    MGRCManager:cacheResource("playerInfo", "role_info_VIP_number.png");
    local pWidget = MGRCManager:widgetFromJsonFile("playerInfo","player_info_ui.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);--设置描边或者阴影
    
    self.Panel_1 = pWidget:getChildByName("Panel_1");
    self.Panel_1:addTouchEventListener(handler(self,self.onButtonClick));
    local Panel_2 = pWidget:getChildByName("Panel_2");
    local Image_dialog = Panel_2:getChildByName("Image_dialog");
    self.Button_close = Image_dialog:getChildByName("Button_close");
    self.Button_close:addTouchEventListener(handler(self,self.onButtonClick));
    self.Button_ok = Image_dialog:getChildByName("Button_ok");
    self.Button_ok:addTouchEventListener(handler(self,self.onButtonClick));
    local Label_ok = self.Button_ok:getChildByName("Label_ok");
    Label_ok:setText(MG_TEXT_COCOS("playerInfo_ui_1"));

    local Image_frame = Panel_2:getChildByName("Image_frame");
    self.Label_name =  Image_frame:getChildByName("Label_name");
    self.Label_lv_name =  Image_frame:getChildByName("Label_lv_name");
    self.Label_score_name =  Image_frame:getChildByName("Label_score_name");
    self.Label_area_name =  Image_frame:getChildByName("Label_area_name");
    self.Label_union_name =  Image_frame:getChildByName("Label_union_name");
    self.Label_hero_name =  Image_frame:getChildByName("Label_hero_name");
    self.Label_id_name =  Image_frame:getChildByName("Label_id_name");
    self.Label_sign_name =  Image_frame:getChildByName("Label_sign_name");
    self.Label_lv =  Image_frame:getChildByName("Label_lv");
    self.Label_score =  Image_frame:getChildByName("Label_score");
    self.Label_area    =  Image_frame:getChildByName("Label_area");
    self.Label_union =  Image_frame:getChildByName("Label_union");
    self.Label_hero =  Image_frame:getChildByName("Label_hero");
    self.Label_id =  Image_frame:getChildByName("Label_id");
    self.Label_sign =  Image_frame:getChildByName("Label_sign");
    self.AtlasLabel = Image_frame:getChildByName("AtlasLabel");
    local Image_head = Image_frame:getChildByName("Image_hero");
    self.Image_vip = Image_frame:getChildByName("Image_vip");
    self.Image_anger = Panel_2:getChildByName("Image_anger");
    self.angerlist = self.Image_anger:getChildByName("ListView");
    self.Image_hero = Panel_2:getChildByName("Image_hero");
    self.herolist = self.Image_hero:getChildByName("ListView");


    self.Label_lv_name:setText(MG_TEXT_COCOS("playerInfo_ui_2"));
    self.Label_score_name:setText(MG_TEXT_COCOS("playerInfo_ui_3"));
    self.Label_area_name:setText(MG_TEXT_COCOS("playerInfo_ui_4"));
    self.Label_union_name:setText(MG_TEXT_COCOS("playerInfo_ui_5"));
    self.Label_hero_name:setText(MG_TEXT_COCOS("playerInfo_ui_6"));
    self.Label_id_name:setText(MG_TEXT_COCOS("playerInfo_ui_7"));
    self.Label_sign_name:setText(MG_TEXT_COCOS("playerInfo_ui_8"));
    self.Label_sign:setText(MG_TEXT_COCOS("playerInfo_ui_9"));

    -- self.Label_id_name:setVisible(false);
    -- self.Label_id:setVisible(false);

    self.heroHead = userHead.create(self);
    self.heroHead:setTouchEnabled(false);
    self.heroHead:setAnchorPoint(cc.p(0.5, 0.5));
    self.heroHead:setPosition(Image_head:getPosition());
    Image_frame:addChild(self.heroHead,1);
    Image_head:setVisible(false);
    self:setVisible(false);
end

function playerInfo:setData(uid,name)
    self.data = {}
    self.data.name = name;
    self.data.uid = uid;

    --@Input uid String 用户ID
    local str = string.format("&uid=%s",uid);
    NetHandler:sendData(Post_getUserInfo, str);
end

function playerInfo:updata()
    self:setVisible(true);
    self.Label_name:setText(self.data.name);
    self.Label_id:setText(self.data.uid);
    self.Label_lv:setText(""..self.data.lv);
    self.Label_score:setText(""..self.data.rank);
    self.Label_area:setText(""..self.data.sports_rank);
    self.Label_union:setText(self.data.union);
    self.Label_hero:setText(""..self.data.general_num);
    self.Label_sign:setText(self.data.signature);
    self.AtlasLabel:setStringValue(self.data.vip_lv);
    self.gm = GeneralModel:create(self.data.head,true)
    self.heroHead:setData(self.gm);

    self.herolist:removeAllItems();
    self.herolist:setItemsMargin(10);
    for i=1,#self.data.generals do
        local id = self.data.generals[i].g_id;
        local gm = GeneralModel:create(id,false);
        local str = cjson.encode(self.data.generals[i])
        gm:updata(str)
        local item = HeroHeadEx.create(self);
        item:setData(gm);
        self.herolist:pushBackCustomItem(item);

    end

    self.Label_lv:setPositionX(self.Label_lv_name:getPositionX()+self.Label_lv_name:getContentSize().width+10);
    self.Label_score:setPositionX(self.Label_score_name:getPositionX()+self.Label_score_name:getContentSize().width+10);
    self.Label_area:setPositionX(self.Label_area_name:getPositionX()+self.Label_area_name:getContentSize().width+10);
    self.Label_sign:setPositionX(self.Label_sign_name:getPositionX()+self.Label_sign_name:getContentSize().width+10);
    self.Label_union:setPositionX(self.Label_union_name:getPositionX()+self.Label_union_name:getContentSize().width+10);
    self.Label_hero:setPositionX(self.Label_hero_name:getPositionX()+self.Label_hero_name:getContentSize().width+10);
    self.Label_id:setPositionX(self.Label_id_name:getPositionX()+self.Label_id_name:getContentSize().width+10);
end

function playerInfo:onButtonClick(sender, eventType)
    buttonClickScale(sender, eventType);
    if eventType == ccui.TouchEventType.ended then
        if sender == self.Panel_1 then
            self:removeFromParent();
        elseif sender == self.Button_close then
            self:removeFromParent();
        elseif sender == self.Button_ok then
            self:playerVs(self.data.uid);
            self:removeFromParent();
        end
    end
end


function playerInfo:playerVs(uid)
    print("挑战:"..uid);
end


function playerInfo:HeroHeadSelect(head)
    if self.selHero~= head then
        if self.selHero then 
            self.selHero:setSel(false);
        end
        self.selHero=head;
        self.selHero:setSel(true);
    end

    local startPos = self.selHero:getParent():convertToWorldSpace(cc.p(self.selHero:getPositionX(),self.selHero:getPositionY()));
    --print(self.selHero.gm:name());
    local heroInfo =  heroInfo.showBox(self)
    heroInfo:setData(self.data.uid,head.gm);
    heroInfo:setStartPos(startPos,self.selHero:getSize().width/2);
end

function playerInfo:heroInfoClose()
    if self.selHero then 
        self.selHero:setSel(false);
    end
end

function playerInfo:onReciveData(MsgID, NetData)
    print("playerInfo onReciveData MsgID:"..MsgID)
    
    if MsgID == Post_getUserInfo then
        local ackData = NetData
        if ackData.state == 1  then
            self.data.generals  =  ackData.getuserinfo.general;
            self.data.head  =  tonumber(ackData.getuserinfo.head);
            self.data.signature  = unicode_to_utf8(ackData.getuserinfo.signature);
            self.data.union  = unicode_to_utf8(ackData.getuserinfo.union);
            self.data.uid  =  ackData.getuserinfo.uid;
            self.data.sports_rank  =  ackData.getuserinfo.sports_rank;
            self.data.vip_lv  =  tonumber(ackData.getuserinfo.vip_lv);
            self.data.lv  =  ackData.getuserinfo.lv;
            self.data.general_num  =  ackData.getuserinfo.general_num;
            self.data.rank  =  ackData.getuserinfo.rank;
            self:updata();

        else
            NetHandler:showFailedMessage(ackData)
            self:removeFromParent();
        end
    end
end

function playerInfo:pushAck()
    NetHandler:addAckCode(self,Post_getUserInfo);
end

function playerInfo:popAck()
    NetHandler:delAckCode(self,Post_getUserInfo);
end

function playerInfo:onEnter()
    self:pushAck();
end

function playerInfo:onExit()
    MGRCManager:releaseResources("playerInfo");
    self:popAck();
end

function playerInfo.create(delegate)
    local layer = playerInfo:new()
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
