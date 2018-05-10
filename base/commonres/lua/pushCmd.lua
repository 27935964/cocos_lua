_G.CHAT={};
_G.CHAT.curData={};--聊天时时推送的当前消息
_G.CHAT.chatUserData={};--私聊聊天消息数据（有上限）
_G.CHAT.chatData={};--频道聊天消息数据（有上限）
_G.CHAT.shields={};--屏蔽的玩家id
_G.CHAT.recentPri={};--最近私聊的玩家id
_G.CHAT.chatAllData={};--除了屏蔽玩家发的消息外的所有聊天数据（只保存最近5条）

pushCmd=createClass({});
function pushCmd:init()
    self:pushAck();
end

function pushCmd:onReciveData(MsgID, NetData)
    print("pushCmd onReciveData MsgID:"..MsgID)

    if MsgID == TCP_APP_CHAT_CHANNEL_NTF then
        --聊天信息 203|频道|uid|附带信息|内容
        local str_list=spliteStr(NetData,'|');
        local NetData={}
        NetData.type = str_list[1];
        NetData.channel =str_list[2];
        NetData.uid = str_list[3];
        NetData.att = str_list[4];
        NetData.text = str_list[5];

        for i=1,#_G.CHAT.shields do
            if _G.CHAT.shields[i] == tonumber(NetData.uid) then
                return;
            end
        end
        _G.CHAT.curData = NetData;
        if nil == _G.CHAT.chatData[tonumber(NetData.channel)] then
            _G.CHAT.chatData[tonumber(NetData.channel)] = {};
        end
        table.insert(_G.CHAT.chatData[tonumber(NetData.channel)],NetData);
        if #_G.CHAT.chatData[tonumber(NetData.channel)] > 50 then
            table.remove(_G.CHAT.chatData[tonumber(NetData.channel)],1);
        end

        --保存所有聊天数据
        table.insert(_G.CHAT.chatAllData,NetData);
        if #_G.CHAT.chatAllData > 5 then
            table.remove(_G.CHAT.chatAllData,1);
        end

        require "chatLayer"
        --同步聊天界面的数据
        if chatLayer:getInstance() then
            chatLayer:getInstance():updata();
        end

        --同步左下方聊天界面的数据
        if chatInstance:getInstance() then
            chatInstance:getInstance():updata();
        end
    elseif MsgID == TCP_APP_CHAT_USER_NTF then
        --私聊信息 204|uid|附带信息|内容
        local str_list=spliteStr(NetData,'|');
        local NetData = {}
        NetData.type = str_list[1];
        NetData.uid = str_list[2];
        NetData.att = str_list[3];
        NetData.text = str_list[4];


        for i=1,#_G.CHAT.shields do
            if _G.CHAT.shields[i] == tonumber(NetData.uid) then
                return;
            end
        end

        --保存私聊数据
        _G.CHAT.curData = NetData;
        table.insert(_G.CHAT.chatUserData,NetData);
        if #_G.CHAT.chatUserData > 50 then
            table.remove(_G.CHAT.chatUserData,1);
        end
        savePrivateChat(_G.CHAT.chatUserData);

        --保存最近私聊玩家数据
        local isInsert = true;--是否要保存最近私聊的玩家
        for i=1,#_G.CHAT.recentPri do
            if _G.CHAT.recentPri[i].uid == NetData.uid then--已保存的玩家不需要在保存
                isInsert = false;
                break;
            end
        end
        if isInsert then
            table.insert(_G.CHAT.recentPri,{uid=NetData.uid,att=NetData.att});
        end
        if #_G.CHAT.recentPri > 5 then
            table.remove(_G.CHAT.recentPri,1);
        end
        saveRecentPrivateChat(_G.CHAT.recentPri);

        --保存所有聊天数据
        table.insert(_G.CHAT.chatAllData,NetData);
        if #_G.CHAT.chatAllData > 5 then
            table.remove(_G.CHAT.chatAllData,1);
        end

        --同步聊天界面的数据
        if chatLayer:getInstance() then
            chatLayer:getInstance():updata();
        end

        --同步左下方聊天界面的数据
        if chatInstance:getInstance() then
            chatInstance:getInstance():updata();
        end
    end
end

function pushCmd:pushAck()
    NetHandler:addAckCode(self,TCP_APP_CHAT_USER_NTF);--推送私聊消息
    NetHandler:addAckCode(self,TCP_APP_CHAT_CHANNEL_NTF);--推送频道聊天消息
end

--初始化聊天数据
function initChatData()
    _G.CHAT={};
    _G.CHAT.curData={};--聊天时时推送的当前消息
    _G.CHAT.chatUserData={};--私聊聊天消息数据（有上限）
    _G.CHAT.chatData={};--频道聊天消息数据（有上限）
    _G.CHAT.shields={};
    _G.CHAT.chatAllData={};
    _G.CHAT.chatUserData=ReadPrivateChat();
    _G.CHAT.recentPri=ReadRecentPrivateChat();
end

--私聊需要保存到本地（50条上限）
function savePrivateChat(data)
    local str = cjson.encode(data);
    local path = cc.FileUtils:getInstance():getWritablePath()
    local f = io.open(path .. "privateChat.json", "w+")
    f:write(str);
    f:close();
end

--读取私聊信息
function ReadPrivateChat()
    local data = {};
    local filePath =  cc.FileUtils:getInstance():getWritablePath().."privateChat.json";
    local f = io.open( filePath, "r" )
    if f then
        local privateChatInfo = f:read( "*all" )
        f:close()
        print(privateChatInfo);
        data = cjson.decode(privateChatInfo);
    end

    return data;
end

--最近私聊需要保存到本地（5条上限）
function saveRecentPrivateChat(data)
    local str = cjson.encode(data);
    local path = cc.FileUtils:getInstance():getWritablePath()
    local f = io.open(path .. "recentPrivateChat.json", "w+")
    f:write(str);
    f:close();
end

--读取最近私聊的数据
function ReadRecentPrivateChat()
    local data = {};
    local filePath =  cc.FileUtils:getInstance():getWritablePath().."recentPrivateChat.json";
    local f = io.open( filePath, "r" )
    if f then
        local privateChatInfo = f:read( "*all" )
        f:close()
        print(privateChatInfo);
        data = cjson.decode(privateChatInfo);
    end

    return data;
end