-----------------------公会议会厅公会成员界面------------------------
require "guildAppointLayer"
require "MessageTip"
require "guildImpeachTip"

local guildMemberItem = require "guildMemberItem";
guildMemberLayer = class("guildMemberLayer", MGLayer)

function guildMemberLayer:ctor()
    self.myPost = 0;
    self.curItem = nil;
    self.memberNum1 = 0;--副会长数量
    self.memberNum2 = 0;--精英数量
    self.curTag = 0;
    self.timeStr = "";
    self.guildAppointLayer = nil;

    self:init();
end

function guildMemberLayer:init()
    --创建listView
    self.listView = ccui.ListView:create();
    self.listView:setDirection(ccui.ScrollViewDir.vertical);
    self.listView:setBounceEnabled(false);
    self.listView:setAnchorPoint(cc.p(0,0));
    self.listView:setSize(cc.size(1100, 660));
    self.listView:setScrollBarVisible(false);--true添加滚动条
    self.listView:setPosition(cc.p(223,10));
    self.listView:setItemsMargin(5);
    self:addChild(self.listView);

    --遮罩
    self.img = ccui.ImageView:create("com_shade.png", ccui.TextureResType.plistType);
    self.img:setAnchorPoint(cc.p(0,0));
    self.img:setPosition(cc.p(211,140));
    self.img:setScale9Enabled(true);
    self.img:setCapInsets(cc.rect(30, 30, 1, 1));
    self.img:setSize(cc.size(1123, 60));
    self:addChild(self.img,1);
    self.img:setVisible(false);

    if not self.itemWidget then
        self.itemWidget = MGRCManager:widgetFromJsonFile("guildMemberLayer", "guild_hall_item_1.ExportJson",false);
        self.itemWidget:retain();
    end

    self:readSql();
end

function guildMemberLayer:readSql()--解析数据库数据
    self.nobilitys = {};
    local sql = string.format("select id,name from union_peerages");
    local DBDataList = LUADB.selectlist(sql, "id:name");
    table.sort(DBDataList.info,function(a,b) return a.id < b.id; end);

    for index=1,#DBDataList.info do
        local DBData = {};
        DBData.id = tonumber(DBDataList.info[index].id);
        DBData.name = DBDataList.info[index].name;

        self.nobilitys[DBData.id]=DBData;
    end
end

function guildMemberLayer:setData(data)
    self.data = data;
    if self.delegate and self.delegate.getPost then
        self.myPost = self.delegate:getPost();
    end

    table.sort(data.mem_list, function (data1,data2) return tonumber(data1.post) > tonumber(data2.post); end);
    self:createItem();

    self.img:setVisible(false);
    if #data.mem_list >= 5 then
        self.img:setVisible(true);
    end
end

function guildMemberLayer:createItem()
    self.listView:removeAllItems();
    self.items = {};
    local totalNum = #self.data.mem_list;
    local itemIndex = 1;
    local function loadEachItem(dt)
        if itemIndex > totalNum then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
        else
            local item = guildMemberItem.create(self,self.itemWidget:clone());
            item:setTag(itemIndex);
            item:setData(self.data.mem_list[itemIndex],self.myPost,self.nobilitys);
            self.listView:pushBackCustomItem(item);

            if tonumber(self.data.mem_list[itemIndex].post) == 9 then
                self.memberNum1 = self.memberNum1 + 1;--副会长数量
            elseif tonumber(self.data.mem_list[itemIndex].post) == 8 then
                self.memberNum2 = self.memberNum2 + 1;--精英数量
            end

            itemIndex = itemIndex+1;

            table.insert(self.items,item);
        end
    end

    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
    end
    self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(loadEachItem, 0.001, false);
end

function guildMemberLayer:addAppointLayer(item)
    self.curTag = item:getTag();
    self.timeStr = item.timeStr;
    self.guildAppointLayer = guildAppointLayer.showBox(self);
    self.guildAppointLayer:setData(item.data,item.timeStr,self.myPost,self.memberNum1,self.memberNum2);
end

function guildMemberLayer:addTipLayer(item)
    self.curItem = item;
    if item.btnState == 1 then--1表示开除，2表示弹劾
        local str = string.format(MG_TEXT("guildAppointLayer_9"),unicode_to_utf8(item.data.name));
        local MessageTip = MessageTip.showBox(self);
        MessageTip:setText(str);
    elseif item.btnState == 2 then
        local guildImpeachTip = guildImpeachTip.showBox(self);
    end
end

function guildMemberLayer:updataItem(item)
    self.memberNum1 = item.memberNum1;--副会长数量
    self.memberNum2 = item.memberNum2;--精英数量
    self.data.mem_list[self.curTag] = item.data;
    if self.guildAppointLayer then
        self.guildAppointLayer:setData(item.data,item.timeStr,self.myPost,
            self.memberNum1,self.memberNum2);
        self.items[self.curTag]:setData(self.data.mem_list[self.curTag],self.myPost,self.nobilitys);
    end
end

function guildMemberLayer:removeAppointLayer()
    if self.guildAppointLayer then
        self.guildAppointLayer:removeFromParent();
        self.guildAppointLayer = nil;
    end
end

function guildMemberLayer:callBack(item)
    self:sendFireMemReq(self.curItem);
end

function guildMemberLayer:impeach(item)--弹劾
    NetHandler:sendData(Post_impeachmentOwner, "");
end

function guildMemberLayer:onReciveData(MsgID, NetData)
    print("guildMemberLayer onReciveData MsgID:"..MsgID)
    local ackData = NetData;
    if MsgID == Post_getMemList then
        if ackData.state == 1 then
            self:setData(ackData.getmemlist);
        else
            NetHandler:showFailedMessage(ackData);
        end
    elseif MsgID == Post_fireMem then
        if ackData.state == 1 then
            if self.curItem then
                local index = self.listView:getIndex(self.curItem);
                self.listView:removeItem(index);
            end
            MGMessageTip:showFailedMessage(MG_TEXT("operate_successfully"));
        else
            NetHandler:showFailedMessage(ackData);
        end
    end
end

function guildMemberLayer:sendFireMemReq(item)--开除
    local str = string.format("&id=%s&no_lose=%d",item.uid,1);
    NetHandler:sendData(Post_fireMem, str);
end

function guildMemberLayer:pushAck()
    NetHandler:addAckCode(self,Post_getMemList);
    NetHandler:addAckCode(self,Post_fireMem);
    NetHandler:addAckCode(self,Post_impeachmentOwner);
end

function guildMemberLayer:popAck()
    NetHandler:delAckCode(self,Post_getMemList);
    NetHandler:delAckCode(self,Post_fireMem);
    NetHandler:delAckCode(self,Post_impeachmentOwner);
end

function guildMemberLayer:onEnter()
    self:pushAck();
    NetHandler:sendData(Post_getMemList, "");
end

function guildMemberLayer:onExit()
    self:popAck();
    MGRCManager:releaseResources("guildMemberLayer");
    if self.itemWidget then
        self.itemWidget:release();
    end
    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
    end
end

function guildMemberLayer.create(delegate)
    local layer = guildMemberLayer:new()
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
