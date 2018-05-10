-----------------------将领属性界面------------------------
require "PanelTop"
require "arenaItem"
require "utf8"
require "userHead"
require "arena_player_Info"
require "arena_say"
require "arena_rank"
require "arena_award"
require "arena_active"
require "arena_record"
require "shopLayer"
require "arena_buy"
require "rule"
require "getItem"


arenaLayer = class("arenaLayer", MGLayer)

function arenaLayer:ctor()
    self.anim = nil;
    self:init();
end

function arenaLayer:init()
    MGRCManager:cacheResource("arenaLayer", "package_bg.jpg");
    MGRCManager:cacheResource("arenaLayer", "general_pic_1.png");
    
    local size = cc.Director:getInstance():getWinSize();
    local bgSpr = cc.Sprite:create("package_bg.jpg");
    bgSpr:setPosition(cc.p(size.width/2, size.height));
    bgSpr:setAnchorPoint(cc.p(0.5,1));
    self:addChild(bgSpr);

    local pWidget = MGRCManager:widgetFromJsonFile("arenaLayer","arena_ui_1.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);--设置描边或者阴影


    self.pPanelTop = PanelTop.create(self)
    self.pPanelTop:setData("arena_title.png");
    self.pPanelTop:showRankCoin(true);
    self:addChild(self.pPanelTop,10);
    
    local Panel_2 = pWidget:getChildByName("Panel_2");
    local Panel_mid = Panel_2:getChildByName("Panel_mid");
    self.Panel_mid=Panel_mid;
    self.list = Panel_mid:getChildByName("ListView");

    local Label_rank_name = Panel_mid:getChildByName("Label_rank_name");
    Label_rank_name:setText(MG_TEXT_COCOS("arena_ui_5"));
    local Label_score_name = Panel_mid:getChildByName("Label_score_name");
    Label_score_name:setText(MG_TEXT_COCOS("arena_ui_1"));
    local Label_times_name = Panel_mid:getChildByName("Label_times_name");
    Label_times_name:setText(MG_TEXT_COCOS("arena_ui_6"));

    self.Label_score = Panel_mid:getChildByName("Label_score");
    self.Label_rank = Panel_mid:getChildByName("Label_rank");
    self.Label_times = Panel_mid:getChildByName("Label_times");

    local Image_head = Panel_mid:getChildByName("Image_head");
    Image_head:setVisible(false);
    self.heroHead = userHead.create(self);
    self.heroHead:setAnchorPoint(Image_head:getAnchorPoint());
    self.heroHead:setPosition(Image_head:getPosition());
    Panel_mid:addChild(self.heroHead,2);
    local gm = GENERAL:getGeneralModel(ME:getHeadId());
    if gm then
        self.heroHead:setData(gm)
    end

    self.Button_times= Panel_mid:getChildByName("Button_times");
    self.Button_times:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_say= Panel_mid:getChildByName("Button_say");
    self.Button_say:addTouchEventListener(handler(self,self.onButtonClick));
    local Label_btn = self.Button_say:getChildByName("Label_btn");
    Label_btn:setText(MG_TEXT_COCOS("arena_ui_7"));

    self.Button_award= Panel_mid:getChildByName("Button_award");
    self.Button_award:addTouchEventListener(handler(self,self.onButtonClick));
    Label_btn = self.Button_award:getChildByName("Label_btn");
    Label_btn:setText(MG_TEXT_COCOS("arena_ui_8"));

    self.Button_shop= Panel_mid:getChildByName("Button_shop");
    self.Button_shop:addTouchEventListener(handler(self,self.onButtonClick));
    Label_btn = self.Button_shop:getChildByName("Label_btn");
    Label_btn:setText(MG_TEXT_COCOS("arena_ui_9"));

    self.Button_rank= Panel_mid:getChildByName("Button_rank");
    self.Button_rank:addTouchEventListener(handler(self,self.onButtonClick));
    Label_btn = self.Button_rank:getChildByName("Label_btn");
    Label_btn:setText(MG_TEXT_COCOS("arena_ui_10"));

    self.Button_record= Panel_mid:getChildByName("Button_record");
    self.Button_record:addTouchEventListener(handler(self,self.onButtonClick));
    Label_btn = self.Button_record:getChildByName("Label_btn");
    Label_btn:setText(MG_TEXT_COCOS("arena_ui_11"));

    self.Button_team= Panel_mid:getChildByName("Button_team");
    self.Button_team:addTouchEventListener(handler(self,self.onButtonClick));
    Label_btn = self.Button_team:getChildByName("Label_btn");
    Label_btn:setText(MG_TEXT_COCOS("arena_ui_12"));

    self.Button_rule= Panel_mid:getChildByName("Button_rule");
    self.Button_rule:addTouchEventListener(handler(self,self.onButtonClick));
    Label_btn = self.Button_rule:getChildByName("Label_btn");
    Label_btn:setText(MG_TEXT_COCOS("arena_ui_13"));


    self.Button_active= Panel_mid:getChildByName("Button_active");
    self.Button_active:addTouchEventListener(handler(self,self.onButtonClick));
    Label_btn = self.Button_active:getChildByName("Label_btn");
    Label_btn:setText(MG_TEXT_COCOS("arena_ui_14"));

    self.Button_refresh= Panel_mid:getChildByName("Button_refresh");
    self.Button_refresh:addTouchEventListener(handler(self,self.onButtonClick));
    Label_btn = self.Button_refresh:getChildByName("Label_btn");
    Label_btn:setText(MG_TEXT_COCOS("arena_ui_15"));


    if not self.arenaItemWidget then
        self.arenaItemWidget = MGRCManager:widgetFromJsonFile("arenaLayer", "arena_ui_2.ExportJson");
        self.arenaItemWidget:retain()
    end

    local sql = "select value from config where id in (34,35,38)";
    local DBData = LUADB.selectlist(sql, "value");
    self.sports_pay_num_vip = tonumber(DBData.info[1].value);
    self.sports_pay_times = tonumber(DBData.info[2].value);
    self.sport_can_war_num = tonumber(DBData.info[3].value);
    self:sendReq();
end


function arenaLayer:onButtonClick(sender, eventType)
    if sender == self.Button_refresh then
        buttonClickScale(sender, eventType,0.8)
    elseif sender == self.Button_times then
        buttonClickScale(sender, eventType,0.7)
    else
        buttonClickScale(sender, eventType)
    end
    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_say then
            local arena_say = arena_say.create(self);
            arena_say:setData(self.getsportsinfo.signature);
            cc.Director:getInstance():getRunningScene():addChild(arena_say,ZORDER_MAX);
        elseif sender == self.Button_rank then
            NetHandler:sendData(Post_rankList, "");
        elseif sender == self.Button_award then
            if  self.getsportsinfo.is_get_day_reward==1 then
                NetHandler:sendData(Post_doGetDayRank, "");
            else
                if self.rankdb==nil then
                    local sql = "select * from reward_sports_rank";
                    local DBData = LUADB.selectlist(sql, "min_rank:max_rank:reward");
                    self.rankdb = DBData.info;
                end
                local arena_award = arena_award.create(self);
                arena_award:setData(self.rankdb,self.getsportsinfo.ranking);
                cc.Director:getInstance():getRunningScene():addChild(arena_award,ZORDER_MAX);
            end

        elseif sender == self.Button_active then
            if self.activedb==nil then
                local sql = "select * from reward_sports_active";
                local DBData = LUADB.selectlist(sql, "active:reward");
                self.activedb = DBData.info;
            end
            local arena_active = arena_active.create(self);
            arena_active:setData(self.activedb,self.getsportsinfo.active,self.getsportsinfo.get_active_reward);
            cc.Director:getInstance():getRunningScene():addChild(arena_active,ZORDER_MAX);
            
        elseif sender == self.Button_record then
            NetHandler:sendData(Post_Sportslogs, "");
        elseif sender == self.Button_shop then
            local shopLayer = shopLayer.showBox(self,6);
        elseif sender == self.Button_times then
            if  ME:vipLevel()<self.sports_pay_num_vip then
                MGMessageTip:showFailedMessage(string.format(MG_TEXT("lockneed"),self.sports_pay_num_vip));
            else
                local arena_buy = arena_buy.create(self);
                arena_buy:setData(self.sports_pay_times,self.getsportsinfo.pay_use)
                cc.Director:getInstance():getRunningScene():addChild(arena_buy,ZORDER_MAX);
            end
        elseif sender == self.Button_rule then
            local rule = rule.create(self,1);
            cc.Director:getInstance():getRunningScene():addChild(rule,ZORDER_MAX);
        elseif sender == self.Button_refresh then
            self:sendReq();

        elseif sender == self.Button_team then
            local str = "&type="..Fight_arena_def;
            FightOP:setTeam(self.scenetype,Fight_arena_def,str);
        end
    end
end


function arenaLayer:createlist()
    if  self.getsportsinfo.is_get_day_reward==1 then
        if not self.anim then
            local anim = MGCartoon:create("activityicon_aroundlight", "activityicon_aroundlight")
            anim:setScale(self.Button_award:getContentSize().width/anim:getContentSize().width)
            anim:setAnchorPoint(cc.p(0.5,0.5))
            anim:setPosition(self.Button_award:getContentSize().width/2, self.Button_award:getContentSize().height/2)
            self.Button_award:addChild(anim,10)
            anim:play(true)
            self.anim = anim
        end
    else
        if self.anim then
            self.anim:removeFromParent();
        end
    end
    if self.getsportsinfo.signature == "" then
        self.getsportsinfo.signature = MG_TEXT("arena_signature");
    else
        self.getsportsinfo.signature = unicode_to_utf8(self.getsportsinfo.signature);
    end
    self.Label_rank:setText(self.getsportsinfo.ranking);
    self.Label_score:setText(ME:getWarScore());
    self.Label_times:setText(self.getsportsinfo.s_atk_num.."/"..self.sport_can_war_num);
    self.list:removeAllItems();

    local sql = "select id,pic from general_list where id in (";
    for i=1,#self.getsportsinfo.list do
        if i==#self.getsportsinfo.list then
            sql = sql..self.getsportsinfo.list[i].head..")";
        else
            sql = sql..self.getsportsinfo.list[i].head..","
        end
        self.getsportsinfo.list[i].head = tonumber(self.getsportsinfo.list[i].head);
    end
    local DBDataList = LUADB.selectlist(sql, "id:pic");
    for i=1,#DBDataList.info do
        DBDataList.info[i].id = tonumber(DBDataList.info[i].id);
        DBDataList.info[i].pic = DBDataList.info[i].pic..".png"
        MGRCManager:cacheResource("arenaLayer",DBDataList.info[i].pic);
    end

    local itemLay = ccui.Layout:create();
    local _width = 0;
    local _hight = 0;  

    for i=1,#self.getsportsinfo.list do
        local arenaItem = arenaItem.create(self,self.arenaItemWidget:clone());
        for j=1,#DBDataList.info do
            if DBDataList.info[j].id == self.getsportsinfo.list[i].head then
                self.getsportsinfo.list[i].pic = DBDataList.info[j].pic;
                break;
            end
        end

        self.getsportsinfo.list[i].name = unicode_to_utf8(self.getsportsinfo.list[i].name);
        self.getsportsinfo.list[i].union = unicode_to_utf8(self.getsportsinfo.list[i].union);
        if self.getsportsinfo.list[i].signature == "" then
            self.getsportsinfo.list[i].signature = MG_TEXT("arena_signature");
        else
            self.getsportsinfo.list[i].signature = unicode_to_utf8(self.getsportsinfo.list[i].signature);
        end
        

        arenaItem:setData(self.getsportsinfo.list[i]);
        arenaItem:setPosition(cc.p(20+arenaItem:getContentSize().width*(i-1),0));
        itemLay:addChild(arenaItem);
        _width=arenaItem:getContentSize().width;
        _hight=arenaItem:getContentSize().height;
    end
    itemLay:setSize(cc.size(20+_width*#self.getsportsinfo.list, _hight));
    if itemLay:getSize().width<self.list:getSize().width then
        self.list:setSize(itemLay:getSize());
        self.list:setPositionX((self.Panel_2:getSize().width - self.list:getSize().width)/2);
    end
    self.list:pushBackCustomItem(itemLay);

    self.list:refreshView()
    self.list:sortAllChildren();
    self.list:getInnerContainer():setPositionX(-_width*10)
end

function arenaLayer:back()
    self:removeFromParent();
end


function arenaLayer:arenaItemSelect(item,type)
    self.item = item;
    local str ="";
    if type == 0 then
        str = "&rank="..item.data.ranking;
        NetHandler:sendData(Post_getRankUserInfo, str);
    elseif type == 1 then
        local str = "&atk="..item.data.ranking;
        FightOP:setTeam(self.scenetype,Fight_arena_att,str,str);
    else
        str = "&ranking="..item.data.ranking;
        NetHandler:sendData(Post_doWorship, str);
    end
    
end

function arenaLayer:arenaPlayerInfo(type)
    if type == 1 then
        local str = "&atk="..self.item.data.ranking;
        FightOP:setTeam(self.scenetype,Fight_arena_att,str,str);
    else
        str = "&ranking="..self.item.data.ranking;
        NetHandler:sendData(Post_doWorship, str);
    end
    
end

function arenaLayer:recordItemPlay(report)
    local str = "&name="..report;
    NetHandler:sendData(Post_doGetSportsReport, str);
end


function arenaLayer:sendChangeCrop(teamStr,teamType)
    local str = string.format("&gids=%s&type=%d",teamStr,teamType);
    NetHandler:sendData(Post_changeUseGeneral, str);
end

function arenaLayer:getItemActive(item)
    self.activeItem = item;
    local str = "&active="..item.data.active;
    NetHandler:sendData(Post_doGetActiveRank, str);
end



function arenaLayer:payAtkNum()
    NetHandler:sendData(Post_doPayAtkNum, "");
end

function arenaLayer:sendReq()
    NetHandler:sendData(Post_getSportsInfo, "");
end


function arenaLayer:sendSay(sign)
    self.getsportsinfo.signature = sign;
    local str = "&text="..sign;
    NetHandler:sendData(Post_setSignature, str);
end


function arenaLayer:onReciveData(MsgID, NetData)
    print("arenaLayer onReciveData MsgID:"..MsgID)
    if NetData.getusersportscoin then
         self.pPanelTop:setRankCoin(NetData.getusersportscoin.sports_coin);
    end
    
    if MsgID == Post_getSportsInfo then
        local ackData = NetData
        if ackData.state == 1 then
            self.getsportsinfo = ackData.getsportsinfo;
            self:createlist();
            self.pPanelTop:setRankCoin(ackData.getsportsinfo.sports_coin);
        else
            NetHandler:showFailedMessage(ackData)
        end
    elseif  MsgID == Post_getRankUserInfo then
        local ackData = NetData
        if ackData.state == 1 then
            self.getrankuserinfo = ackData.getrankuserinfo;
            self.getrankuserinfo.name = unicode_to_utf8(self.getrankuserinfo.name);
            self.getrankuserinfo.union = unicode_to_utf8(self.getrankuserinfo.union);
            self.getrankuserinfo.head =  tonumber(self.getrankuserinfo.head);
            self.getrankuserinfo.is_worship  = self.item.data.is_worship
            self.getrankuserinfo.is_atk = self.item.data.is_atk
            
            local arena_player_Info = arena_player_Info.create(self);
            arena_player_Info:setData(self.getrankuserinfo);
            cc.Director:getInstance():getRunningScene():addChild(arena_player_Info,ZORDER_MAX);

        else
            NetHandler:showFailedMessage(ackData)
        end
    elseif  MsgID == Post_doWorship then
        local ackData = NetData
        if ackData.state == 1 then
            getItem.showBox(ackData.doworship.get_item, MG_TEXT("arena_Worship_suc"));
            self.pPanelTop:upData();
            self:sendReq();
        else
            NetHandler:showFailedMessage(ackData)
        end
    elseif  MsgID == Post_setSignature then
        local ackData = NetData
        if ackData.state == 1 then
            MGMessageTip:showSuccessMessage(MG_TEXT("arena_sign_suc"));
        else
            NetHandler:showFailedMessage(ackData)
        end

    elseif  MsgID == Post_doGetDayRank then
        local ackData = NetData
        if ackData.state == 1 then
            getItem.showBox(ackData.dogetdayrank.get_item, MG_TEXT("arena_GetDayRank_suc"));
            self.pPanelTop:upData();
            self.getsportsinfo.is_get_day_reward = 0; 
            if self.anim then
                self.anim:removeFromParent();
            end
        else
            NetHandler:showFailedMessage(ackData)
        end
    elseif  MsgID == Post_doPayAtkNum then
        local ackData = NetData
        if ackData.state == 1 then
            MGMessageTip:showSuccessMessage(MG_TEXT("arena_payAtkNum_suc"));
            self.pPanelTop:upData();
            self.getsportsinfo.pay_use = ackData.dopayatknum.pay_use;
            self.getsportsinfo.s_atk_num = ackData.dopayatknum.s_atk_num;
            self.Label_times:setText(self.getsportsinfo.s_atk_num.."/"..self.sport_can_war_num);
        else
            NetHandler:showFailedMessage(ackData)
        end
    elseif  MsgID == Post_Sportslogs then
        local ackData = NetData
        if ackData.state == 1 then
            local arena_record = arena_record.create(self);
            arena_record:setData(ackData.logs.log);
            cc.Director:getInstance():getRunningScene():addChild(arena_record,ZORDER_MAX);
        else
            NetHandler:showFailedMessage(ackData)
        end
    elseif  MsgID == Post_rankList then
        local ackData = NetData
        if ackData.state == 1 then
            local arena_rank = arena_rank.create(self);
            arena_rank:setData(ackData.ranklist.rank_list);
            cc.Director:getInstance():getRunningScene():addChild(arena_rank,ZORDER_MAX);
        else
            NetHandler:showFailedMessage(ackData)
        end
    elseif  MsgID == Post_doGetSportsReport then
        local ackData = NetData
        if ackData.state == 1 then

        else
            NetHandler:showFailedMessage(ackData)
        end
    elseif  MsgID == Post_doGetActiveRank then
        local ackData = NetData
        if ackData.state == 1 then
            getItem.showBox(ackData.dogetactiverank.get_item, MG_TEXT("arena_getActive_suc"));
            self.pPanelTop:upData();
            self.getsportsinfo.get_active_reward = ackData.dogetactiverank.get_active_reward; 
            if self.activeItem then
                self.activeItem:upData();
            end
        else
            NetHandler:showFailedMessage(ackData)
        end
    end
end

function arenaLayer:pushAck()
    NetHandler:addAckCode(self,Post_getSportsInfo);
    NetHandler:addAckCode(self,Post_getRankUserInfo);
    NetHandler:addAckCode(self,Post_doWorship);
    NetHandler:addAckCode(self,Post_setSignature);
    NetHandler:addAckCode(self,Post_doGetDayRank);
    NetHandler:addAckCode(self,Post_doPayAtkNum);
    NetHandler:addAckCode(self,Post_Sportslogs);
    NetHandler:addAckCode(self,Post_rankList);
    NetHandler:addAckCode(self,Post_doGetSportsReport);
    NetHandler:addAckCode(self,Post_doGetActiveRank);
end

function arenaLayer:popAck()
    NetHandler:delAckCode(self,Post_getSportsInfo);
    NetHandler:delAckCode(self,Post_getRankUserInfo);
    NetHandler:delAckCode(self,Post_doWorship);
    NetHandler:delAckCode(self,Post_setSignature);
    NetHandler:delAckCode(self,Post_doGetDayRank);
    NetHandler:delAckCode(self,Post_doPayAtkNum);
    NetHandler:delAckCode(self,Post_Sportslogs);
    NetHandler:delAckCode(self,Post_rankList);
    NetHandler:delAckCode(self,Post_doGetSportsReport);
    NetHandler:delAckCode(self,Post_doGetActiveRank);
end

function arenaLayer:onEnter()
    self:pushAck();
end

s_arenaLayer=nil;
function arenaLayer:onExit()
    s_arenaLayer = nil;
    if self.arenaItemWidget then
        self.arenaItemWidget:release()
    end
    MGRCManager:releaseResources("arenaLayer");
    self:popAck();
end

function arenaLayer.create(delegate,scenetype)
    local layer = arenaLayer:new()
    layer.delegate = delegate
    layer.scenetype = scenetype
    local function onNodeEvent(event)
        if event == "enter" then
            layer:onEnter()
        elseif event == "exit" then
            layer:onExit()
        end
    end
    layer:registerScriptHandler(onNodeEvent)
    return layer; 
end


function arenaLayer.showBox(delegate,scenetype)
    s_arenaLayer = arenaLayer.create(delegate,scenetype);
    cc.Director:getInstance():getRunningScene():addChild(s_arenaLayer,ZORDER_MAX);
    return s_arenaLayer;
end

