--------------------------公会议会厅公————会成员界面-----------------------
require "userHead"

local guildMemberItem = class("guildMemberItem", MGWidget)

function guildMemberItem:init(delegate,widget)
    self.timeNum = 0;
    self.myPost = 0;
    self.btnState = 1;--1表示开除，2表示弹劾
    self.uid = "";
    self.timeStr = "";
    
    self.timer = CCTimer:new();
    self.delegate=delegate;
    self:addChild(widget);
    self.pWidget = widget;

    widget:setBackGroundColorType(1);
    widget:setBackGroundColor(cc.c3b(255,255,0));

    local Panel_2 = self.pWidget:getChildByName("Panel_2");
    self:setContentSize(Panel_2:getContentSize());

    local Panel_3 = Panel_2:getChildByName("Panel_3");
    self.heroHead = userHead.create(self);
    self.heroHead:setAnchorPoint(cc.p(0.5, 0.5));
    self.heroHead:setPosition(cc.p(Panel_3:getContentSize().width/2,Panel_3:getContentSize().height/2));
    Panel_3:addChild(self.heroHead);

    self.Label_name = Panel_2:getChildByName("Label_name");
    self.Label_level = Panel_2:getChildByName("Label_level");
    self.label_position = Panel_2:getChildByName("label_position");
    self.BitmapLabel = Panel_2:getChildByName("BitmapLabel");
    self.Label_time = Panel_2:getChildByName("Label_time");
    self.Label_nobility_name = Panel_2:getChildByName("Label_nobility_name");--爵位
    self.Label_max_number = Panel_2:getChildByName("Label_max_number");--最强战力
    self.Label_prestige_number = Panel_2:getChildByName("Label_prestige_number");--声望

    self.Button_appoint = Panel_2:getChildByName("Button_appoint");--任命
    self.Button_appoint:addTouchEventListener(handler(self,self.onButtonClick));

    self.Button_expel = Panel_2:getChildByName("Button_expel");--开除
    self.Button_expel:addTouchEventListener(handler(self,self.onButtonClick));

    self.Label_expel = self.Button_expel:getChildByName("Label_expel");
    self.Label_expel:setText(MG_TEXT("guildMemberItem_7"));

    local Label_nobility = Panel_2:getChildByName("Label_nobility");
    Label_nobility:setText(MG_TEXT_COCOS("guild_hall_item_1_1"));

    local Label_max = Panel_2:getChildByName("Label_max");
    Label_max:setText(MG_TEXT_COCOS("guild_hall_item_1_2"));

    local Label_prestige = Panel_2:getChildByName("Label_prestige");
    Label_prestige:setText(MG_TEXT_COCOS("guild_hall_item_1_3"));

    local Label_appoint = self.Button_appoint:getChildByName("Label_appoint");
    Label_appoint:setText(MG_TEXT_COCOS("guild_hall_item_1_4"));


    local sql = string.format("select value from config where id=98");
    local DBData = LUADB.select(sql, "value");
    self.impeachTime = tonumber(DBData.info.value);
end

function guildMemberItem:setData(data,post,nobilitys)
    self.data = data;
    self.myPost = post;
    self.nobilitys = nobilitys;
    self.uid = self.data.uid;

    self.Label_name:setText(unicode_to_utf8(data.name));
    self.Label_level:setText(string.format("Lv.%d",tonumber(data.lv)));
    self.BitmapLabel:setText(tonumber(data.vip));--setString
    self.Label_max_number:setText(tonumber(data.max_score));
    self.Label_prestige_number:setText(tonumber(data.feats));
    self.Label_nobility_name:setText(self.nobilitys[tonumber(data.peerages)].name);
    self.label_position:setText(MG_TEXT("Union_"..tonumber(data.post)));

    local gm = GENERAL:getGeneralModel(tonumber(data.head));
    if gm then
        self.heroHead:setData(gm);
    end


    self:initTime();
    self:setState();
    if 1 == tonumber(self.data.is_online) then--0不在线 1在线
        if self.timer~=nil then
            self.timer:stopTimer();
        end
        self.timeStr = MG_TEXT("guildMemberItem_9");
        self.Label_time:setText(self.timeStr);
    end
end

function guildMemberItem:setState()
    self.btnState = 1;
    self.Button_appoint:setEnabled(true);
    self.Button_expel:setEnabled(true);
    if self.myPost == 10 then--会长
        if tonumber(self.data.post) == 10 then
            self.Button_appoint:setEnabled(false);
            self.Button_expel:setEnabled(false);
        end
    elseif self.myPost == 9 then--副会长
        if tonumber(self.data.post) >= self.myPost then
            self.Button_appoint:setEnabled(false);
            self.Button_expel:setEnabled(false);
        end

        local disTime = self.timeNum -tonumber(self.data.last_login_time);
        local disData = disTime/60/60/24;
        if tonumber(self.data.post) == 10 and disData >= self.impeachTime then--self.impeachTime是配置时间
            self.Button_appoint:setEnabled(false);
            self.Button_expel:setEnabled(true);
            self.Label_expel:setText(MG_TEXT("guildMemberItem_8"));
            self.btnState = 2;
        end
    elseif self.myPost == 8 then--精英 0普通成员
        self.Button_appoint:setEnabled(false);
        self.Button_expel:setEnabled(false);
        local disTime = self.timeNum -tonumber(self.data.last_login_time);
        local disData = disTime/60/60/24;
        if tonumber(self.data.post) == 10 and disData >= self.impeachTime then--self.impeachTime是配置时间
            self.Button_appoint:setEnabled(false);
            self.Button_expel:setEnabled(true);
            self.Label_expel:setText(MG_TEXT("guildMemberItem_8"));
            self.btnState = 2;
        end
    elseif self.myPost < 8 then--0普通成员
        self.Button_appoint:setEnabled(false);
        self.Button_expel:setEnabled(false);
    end
end

function guildMemberItem:initTime()
    local systemTime = UserData:instance():getServerTime();
    if tonumber(self.data.last_login_time) == 0 then
        self.timeNum = tonumber(self.data.last_login_time);
    else
        self.timeNum = systemTime-tonumber(self.data.last_login_time);
    end
    self:onDrawTime();
    self.timer:startTimer(1000,handler(self,self.updateTime),false);--每秒回调一次
end

function guildMemberItem:updateTime()
    if self.timeNum ~= nil then
        self.timeNum = self.timeNum+1;
        self:onDrawTime();
    end
end

function guildMemberItem:onDrawTime()
    local day = self.timeNum / (60 * 60)/24;
    local years = math.floor(day/365);
    local month = math.floor(day/30);--向下取整

    if day >= 365 then--n年前
        self.timeStr = string.format(MG_TEXT("guildMemberItem_6"),years);
    elseif day >= 30 and day < 365 then--n个月前
        self.timeStr = string.format(MG_TEXT("guildMemberItem_5"),month);
    elseif day >= 1 and day < 30 then--n天前
        self.timeStr = string.format(MG_TEXT("guildMemberItem_4"),math.floor(day));
    else
        local hours = self.timeNum/(60*60);
        if hours >=1 then--n小时前
            self.timeStr = string.format(MG_TEXT("guildMemberItem_3"),math.floor(hours));
        else
            local minutes = self.timeNum/60;
            if minutes >= 1 then--n分钟前
                self.timeStr = string.format(MG_TEXT("guildMemberItem_2"),math.floor(minutes));
            else--小于一分钟
                self.timeStr = string.format(MG_TEXT("guildMemberItem_1"));
            end
        end
    end
    self.Label_time:setText(self.timeStr);
end

function guildMemberItem:onButtonClick(sender, eventType)
    buttonClickScale(sender, eventType);

    if eventType == ccui.TouchEventType.ended then
        if sender == self.Button_appoint then--任命
            if self.delegate and self.delegate.addAppointLayer then
                self.delegate:addAppointLayer(self);
            end
        elseif sender == self.Button_expel then--1表示开除，2表示弹劾
            if self.delegate and self.delegate.addTipLayer then
                self.delegate:addTipLayer(self);
            end
        end
    end
end

function guildMemberItem:onEnter()
    
end

function guildMemberItem:onExit()
    if self.timer~=nil then
        self.timer:stopTimer();
    end
    MGRCManager:releaseResources("guildMemberItem")
end

function guildMemberItem.create(delegate,widget)
    local layer = guildMemberItem:new()
    layer:init(delegate,widget)
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

return guildMemberItem