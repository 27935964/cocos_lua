require "Cocos2d"

MGLayer = class("MGLayer",function()
        return cc.Layer:create();
end);

MGWidget = class("MGWidget",function()
        return ccui.Widget:create();
end);

MGImageView = class("MGImageView",function()
        return ccui.ImageView:create();
end);

-------------------------------------------------
ttf_msyh="SIMHEI.TTF";
SOUND_COM_CLICK="targebutton.wav";
-----------------------------------------------

TXT_COMMON_CN = "common_CN.json"
function MG_TEXT(_key_)
    return MGTextManage:instance():get(TXT_COMMON_CN,_key_);
end

function GET_ERR_DEFINE(_key_)
    return MGTextManage:instance():geterrdb(_key_);
end

function MG_TEXT_COCOS(_key_)
     return MGTextManage:instance():get("cocos.json",_key_);
end

function to_utf8(txt)
        local p1,p2=string.find(txt,"\\");
        if p1 then
                return unicode_to_utf8(txt);
        end
        return txt;
end
---------------------------------------------
--场景类型
SCENEINFO =
{
    LOGIN_SCENE    = 0,--登录
    MAIN_SCENE     = 1,--主城
    MAP_SCENE      = 2,--副本地图
    UNIONWAR_SCENE =3--公会战
}

--界面类型
LAYERTAG = 
{
    LAYER_CITY_TAG = 0,
    LAYER_ARENA = 1,
    LAYER_LOGIN = 2,--登录界面
    LAYER_PLOT=3,--事件剧情界面
    LAYER_ISlAND=4,--隐士岛界面
    LAYER_TRIAL=5,--英雄试炼界面
    LAYER_INVADE=6,--入侵事件
    LAYER_CHECKPOINT=7,--主线关卡界面
    LAYER_RECOVERROAD=8,--光复之路界面
    LAYER_MAINTAINERS=9,--维护者之誓界面
}

----------------------------------------------------------
ZORDER_MAX=10000
ZORDER_PRIORITY=10001  --特殊情况， 优先在最前
ZORDER_EXTREME=10002  --极端情况， 绝对再最前
----------------------------------------------------------

Color3B = class("Color3B")
Color3B.WHITE  = cc.c3b(255, 255, 255)
Color3B.YELLOW = cc.c3b(255, 255,   0)
Color3B.GREEN  = cc.c3b(  0, 255,   0)
Color3B.BLUE   = cc.c3b(  0,   0, 255)
Color3B.RED    = cc.c3b(255,   0,   0)
Color3B.MAGENTA= cc.c3b(255,   0, 255)
Color3B.BLACK  = cc.c3b(  0,   0,   0)
Color3B.ORANGE = cc.c3b(255, 127,   0)
Color3B.GRAY   = cc.c3b(166, 166, 166)

Color4B = class("Color4B")
Color4B.WHITE  = cc.c4b(255, 255, 255, 255)
Color4B.YELLOW = cc.c4b(255, 255,   0, 255)
Color4B.GREEN  = cc.c4b(  0, 255,   0, 255)
Color4B.BLUE   = cc.c4b(  0,   0, 255, 255)
Color4B.RED    = cc.c4b(255,   0,   0, 255)
Color4B.MAGENTA= cc.c4b(255,   0, 255, 255)
Color4B.BLACK  = cc.c4b(  0,   0,   0, 255)
Color4B.ORANGE = cc.c4b(255, 127,   0, 255)
Color4B.GRAY   = cc.c4b(166, 166, 166, 255)

------------------------------------------
ME=UserData:instance();
SAVEFILE = SaveFile:getInstance();
SAVESET = SAVEFILE:setInfo();

MARQUEE=MGLuaMarquee:getInstance();
GENERAL = GeneralManager:getInstance();
RESOURCE = ResourceManager:getInstance();

LUADB = {}
LUADB.select = function(sql,column)
    local DBInfo =LuaDBReader:executeReader(sql, column,0);
    local DBData = nil;
    if DBInfo ~="" then
        DBData = cjson.decode(DBInfo); 
    end
    return DBData;
end

LUADB.selectlist = function(sql,column)
    local DBInfo =LuaDBReader:executeReader(sql, column,1);
    local DBData = nil;
    if DBInfo ~="" then
        DBData = cjson.decode(DBInfo); 
    end
    return DBData;
end

LUADB.readConfig=function (id)
        local sql = string.format("select value from config where id=%d",id);
        local dbData = LUADB.select(sql, "value");
        return dbData.info.value or "1";
end

function getneedlist(strneed)
    local needlist ={};
    local str_list = spliteStr(strneed,'|');
    for i=1,#str_list do
        local str_list1 = spliteStr(str_list[i],':');
        local need = {};
        need.id   = tonumber(str_list1[2]);    -- 物品ID
        need.type = tonumber(str_list1[1]);    -- 物品类型
        need.num  = tonumber(str_list1[3]);    -- 物品数量
        table.insert( needlist,need);
    end
    return needlist;
end

function getrewardlist(strreward)
    local rewardlist ={};
    local str_list = spliteStr(strreward,'|');
    for i=1,#str_list do
        local str_list1 = spliteStr(str_list[i],':');
        local reward = {};
        reward.id   = tonumber(str_list1[2]);    -- 物品ID
        reward.type = tonumber(str_list1[1]);    -- 物品类型
        table.insert( rewardlist,reward);
    end
    return rewardlist;
end

function getefflist(streff)
    local efflist ={};
    if nil == streff then
        return efflist;
    end
    
    local str_list = spliteStr(streff,'|');
    for i=1,#str_list do
        local str_list1 = spliteStr(str_list[i],':');
        local eff = {};
        eff.id    = tonumber(str_list1[1]);      --属性ID
        eff.count = tonumber(str_list1[2]);      --属性值
        eff.name  = EffectDB:getName(eff.id);
        table.insert( efflist,eff);
    end
    return efflist;
end

function getDataList(strneed)
    local dataList ={};
    if nil == strneed then
        return dataList;
    end
    local str_list = spliteStr(strneed,'|');
    for i=1,#str_list do
        local str_list1 = spliteStr(str_list[i],':');
        local need = {};
        need.value1 = tonumber(str_list1[1]);   
        need.value2 = tonumber(str_list1[2]);   
        need.value3 = tonumber(str_list1[3]);     
        need.value4 = tonumber(str_list1[4]);    
        need.value5 = tonumber(str_list1[5]);     
        table.insert( dataList,need);
    end
    return dataList;
end

function spliteStr(str, splite)
    local splitlist = {};
    string.gsub(str, '[^'..splite..']+', function(w) table.insert(splitlist, w) end );  --[^,] 除了逗号之外的任何字符
    return splitlist;
end

function buttonClickScale(sender,eventType,oldscale)
    local scale=oldscale or 1;
    if eventType == ccui.TouchEventType.began then
        local sc = cc.ScaleTo:create(0.1, scale*1.1)
        sender:runAction(cc.EaseOut:create(sc ,2))
    end
    if eventType == ccui.TouchEventType.canceled then
        local sc = cc.ScaleTo:create(0.1, scale)
        sender:runAction(sc)
    end
    if eventType == ccui.TouchEventType.ended then
        local sc = cc.ScaleTo:create(0.1, scale)
        sender:runAction(sc)
    end
end

function newline(totalNum,singleNum)--totalNum总数，每行singleNum个
    local ranks = {};
    for i=1,totalNum do
        local t = ((i-1)*singleNum)+1;
        local icount = (t-1)+singleNum;

        if icount > totalNum then
            icount = totalNum;
        end

        for k=t,icount do
            table.insert(ranks,{row=i,col=(k-1)-(i-1)*singleNum});
        end
    end
    return ranks;
end

function getItemPositionX(items,centerPosX,dis)
    local offset = dis or 20;
    local pos = {};
    local totalNum = #items;
    local itemWidth = items[1]:getContentSize().width;
    local average = math.ceil(totalNum/2);
    local mod = math.mod(totalNum,2);
    if mod == 0 then
        centerPosX = centerPosX-itemWidth/2-offset/2;
        for i=1,totalNum do
            if i < average then
                pos[i] = centerPosX-(average-i)*(itemWidth+offset);
            elseif i == average then
                pos[i] = centerPosX;
            else
                pos[i] = centerPosX+(i-average)*(itemWidth+offset);
            end
        end
    elseif mod == 1 then
        for i=1,totalNum do
            if i < average then
                pos[i] = centerPosX-(average-i)*(itemWidth+offset);
            elseif i == average then
                pos[i] = centerPosX;
            else
                pos[i] = centerPosX+(i-average)*(itemWidth+offset);
            end
        end
    end
    return pos;
end

function getChildren(node)
    -- 递归访问所有节点，当前节点node
    local nodes = {};
    local function walkNode(node)
        if not node then return end
        if node.getChildrenCount and node:getChildrenCount() > 0 then
            for k,v in pairs(node:getChildren()) do
                table.insert(nodes,v);
                walkNode(v);
            end
        end
    end
    walkNode(node);
    
    return nodes;
end

function getColorTitle(name,quality)
    local str = "";
    local sql = "select color from quality where id="..quality;
    local DBData = LUADB.select(sql, "color");
    if tonumber(DBData.info.color) == 1 then
        str = string.format("<c=255,255,255>%s</c>",name);
    elseif tonumber(DBData.info.color) == 2 then
        str = string.format("<c=006,236,000>%s</c>",name);
    elseif tonumber(DBData.info.color) == 3 then
        str = string.format("<c=000,129,249>%s</c>",name);
    elseif tonumber(DBData.info.color) == 4 then
        str = string.format("<c=180,000,255>%s</c>",name);
    elseif tonumber(DBData.info.color) == 5 then
        str = string.format("<c=255,180,000>%s</c>",name);
    elseif tonumber(DBData.info.color) == 6 then
        str = string.format("<c=239,000,006>%s</c>",name);
    end
    return str;
end

function getTimeStamp(hour,min)--把时间点转换时间戳
    local time = 0;
    local nowTime=ME:getServerTime();
    local temData=os.date("*t", nowTime);
    temData.hour=tonumber(hour or 0);
    temData.min=tonumber(min or 0);
    time=os.time(temData);
    return time;
end