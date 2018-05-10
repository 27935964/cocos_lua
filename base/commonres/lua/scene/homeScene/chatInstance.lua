-----------------------主城下方聊天显示窗口------------------------

chatInstance = class("chatInstance",function()  
    return ccui.Layout:create(); 
end)

function chatInstance:ctor()
    self.items = {};
    self:init();
end

function chatInstance:init()
    self:setSize(cc.size(369, 103));
    self:setAnchorPoint(cc.p(0,0));

    self.chatData = {};
    self.chatData = _G.CHAT.chatAllData;
    self:creatItem();
end

function chatInstance:updata()
    self.chatData = _G.CHAT.chatAllData;
    self:creatItem();
end

function chatInstance:creatItem()
    self:removeAllChildren();
    self.items = {};

    if #self.chatData <= 0 then
        return;
    end

    local posY = self:getContentSize().height-5;
    local h = 0;
    for i=1,#self.chatData do
        local descLabel = MGColorLabel:label();
        descLabel:setAnchorPoint(cc.p(0, 1));
        self:addChild(descLabel);

        local str = self:setDesc(self.chatData[i]);
        descLabel:clear();
        descLabel:appendStringAutoWrap(str,15,1,cc.c3b(255,255,255),22);

        descLabel:setPosition(cc.p(0,posY));
        posY = posY-descLabel:getContentSize().height;
        h = h + descLabel:getContentSize().height;
        table.insert(self.items,descLabel);
    end

    if h > self:getContentSize().height then
        local itemIndex = 1;
        posY = 0;
        for i=#self.items,1,-1 do
            posY = posY+self.items[i]:getContentSize().height;
            self.items[i]:setPositionY(posY);
        end
    end
end

function chatInstance:setDesc(data)
    local str = "";
    local attData = spliteStr(data.att,':');--1.头像，名称，玩家等级，vip等级等
    if tonumber(data.type) == 203 then--203是频道聊天，204是私聊
        if tonumber(data.channel) == 100 then--系统聊天
            str = MG_TEXT("chat_channel_2");
        elseif tonumber(data.channel) == 200 then--世界聊天
            str = MG_TEXT("chat_channel_1");
        elseif string.sub(data.channel,1,3) == "201" then--公会聊天
            str = MG_TEXT("chat_channel_3");
        end

        if tonumber(data.uid) == 0 then
            str = str..data.text;
        else
            str = str..string.format("%s:",attData[2])..data.text;
        end
    elseif tonumber(data.type) == 204 then
        str = MG_TEXT("chat_channel_4");
        str = str..string.format("%s:",attData[2])..data.text;
    end

    return str;
end

function chatInstance:onEnter()

end

function chatInstance:onExit()
    MGRCManager:releaseResources("chatInstance");
end

function chatInstance.create(delegate)
    local layer = chatInstance:new()
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

local _instance;
function chatInstance:getInstance()
    if _instance then
        return _instance;
    end
end

function chatInstance:createInstance()
    if _instance==nil then
        _instance=chatInstance.create();
    end
    return _instance;
end

function chatInstance:dispose()
    if _instance then
        if _instance:getParent() then
            _instance:removeFromParent();
        end
        _instance=nil;
    end
end
