require "bitExtend"

function handler(target, method)
    return function(...)
        return method(target, ...)
    end
end

function io.readfile(path)
    local file = io.open(path, "r")
    if file then
        local content = file:read("*a")
        io.close(file)
        return content
    end
    return nil
end

function io.writefile(path, content, mode)
    mode = mode or "w+b"
    local file = io.open(path, mode)
    if file then
        if file:write(content) == nil then return false end
        io.close(file)
        return true
    else
        return false
    end
end

function io.pathinfo(path)
    local pos = string.len(path)
    local extpos = pos + 1
    while pos > 0 do
        local b = string.byte(path, pos)
        if b == 46 then -- 46 = char "."
            extpos = pos
        elseif b == 47 then -- 47 = char "/"
            break
        end
        pos = pos - 1
    end

    local dirname = string.sub(path, 1, pos)
    local filename = string.sub(path, pos + 1)
    extpos = extpos - pos
    local basename = string.sub(filename, 1, extpos - 1)
    local extname = string.sub(filename, extpos)
    return {
        dirname = dirname,
        filename = filename,
        basename = basename,
        extname = extname
    }
end

function io.filesize(path)
    local size = false
    local file = io.open(path, "r")
    if file then
        local current = file:seek()
        size = file:seek("end")
        file:seek("set", current)
        io.close(file)
    end
    return size
end

function table.nums(t)
    local count = 0
    for k, v in pairs(t) do
        count = count + 1
    end
    return count
end

function table.keys(t)
    local keys = {}
    for k, v in pairs(t) do
        keys[#keys + 1] = k
    end
    return keys
end

function table.values(t)
    local values = {}
    for k, v in pairs(t) do
        values[#values + 1] = v
    end
    return values
end

function table.walk(t, fun)
    for k,v in pairs(t) do
        fun(v, k)
    end
end

function table.check(obj,t)
    t=t or 1;

    local span="";
    for i=1,t do
        span=span.." "
    end

    print(span.."{");
    table.walk(obj,function(v,k)
        if(type(v)=="table")then
           print(span..k.."=");
           table.check(v,t+1);
        else
           if(type(v)=="boolean")then
               if(v)then
                    v="true";
               else
                    v="false";
               end
           end
           print(span..k.."="..v..",");
        end    
    end);
    print(span.."},");
end


function table.copy(obj)
    local newObj={};
    for key, value in pairs(obj) do
        newObj[key] = value;
    end
    return newObj;
end

function string.split(str, delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    -- for each divider found
    for st,sp in function() return string.find(str, delimiter, pos, true) end do
        table.insert(arr, string.sub(str, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(str, pos))
    return arr
end

function string.ltrim(str)
    return string.gsub(str, "^[ \t\n\r]+", "")
end

function string.rtrim(str)
    return string.gsub(str, "[ \t\n\r]+$", "")
end

function string.trim(str)
    str = string.gsub(str, "^[ \t\n\r]+", "")
    return string.gsub(str, "[ \t\n\r]+$", "")
end

function string.charCount(str)
    local n=0;
    local index=1;
    local wordArr={};
    local ch=string.byte(str,index);
    while (ch~=nil) do
        if (0x80 ~= bit.band(0xC0,ch)) then
            n=n+1;
            table.insert(wordArr,index);
        end
        index=index+1;
        ch=string.byte(str,index);
    end
    table.insert(wordArr,index+1);
    return n,wordArr;
end

local function urlencodeChar(c)
    return "%" .. string.format("%02X", string.byte(c))
end

function string.urlencode(str)
    -- convert line endings
    str = string.gsub(tostring(str), "\n", "\r\n")
    -- escape all characters but alphanumeric, '.' and '-'
    str = string.gsub(str, "([^%w%.%- ])", urlencodeChar)
    -- convert spaces to "+" symbols
    return string.gsub(str, " ", "+")
end

function string.urldecode(str)
    str = string.gsub (str, "+", " ")
    str = string.gsub (str, "%%(%x%x)", function(h) return string.char(tonum(h,16)) end)
    str = string.gsub (str, "\r\n", "\n")
    return str
end

function string.formatNumberThousands(num)
    local formatted = tostring(tonum(num))
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

function NodeListener(node)

    local function onNodeEvent(event)
        if event == "enter" and node.onEnter~=nil then
            node:onEnter();
        elseif event == "exit" and node.onExit~=nil then
            node:onExit();
            node:unregisterScriptHandler();
        end
    end
    node:registerScriptHandler(onNodeEvent);
end

--居中的node 锚点在(0,0)
function NodeCenter(node)
    local winSize=cc.Director:getInstance():getWinSize();
    local cSize=node:getContentSize();
    node:setPosition(cc.p((winSize.width-cSize.width)/2,0));
end

function NodeShow(node)
    if node:getNumberOfRunningActions()>0 then
        node:stopAllActions();
    end
    node:setScale(0.8);
    node:runAction(cc.EaseOut:create(cc.ScaleTo:create(0.1,1),4));
end

function NodeRemoveFromParent(node)
    if node:getNumberOfRunningActions()>0 then
        node:stopAllActions();
    end
    node:setScale(1);
    local function callFunc()
        node:removeFromParent();
    end
    local func = cc.CallFunc:create(callFunc);
    local easeOut = cc.EaseOut:create(cc.ScaleTo:create(0.2,0),4);
    node:runAction(cc.Sequence:create(easeOut,func));
end

function fuGetAnimate(name,i,j,time,forever)
    forever=forever or false;
    local ktime= time or 0.1;
    local animation = CCAnimation:create();
    local spriteFrame=nil;
    local frameName=nil;
    if i<=j then
        for k=i,j do
            frameName = name..k..".png";
            spriteFrame=cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName);
            animation:addSpriteFrame(spriteFrame);
        end
    else
        for k=i,j,-1 do
            frameName = name..k..".png";
            spriteFrame=cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName);
            animation:addSpriteFrame(spriteFrame);
        end
    end

    animation:setDelayPerUnit(ktime);
    animation:setRestoreOriginalFrame(true);
    local animate = CCAnimate:create(animation);
    if forever then
            animate=cc.RepeatForever:create(animate);
    end
    return animate;
end

function io.jsonFile(data)
    local filePath="C:\\Users\\Administrator\\Desktop\\luaJson.txt";
    local date=os.date("%Y-%m-%d %H:%M:%S",os.time());
    local jsonStr=cjson.encode(data);
    local data="=====Date:"..date.."=====\r\n\r\n"..jsonStr.."\r\n\r\n\r\n"
    io.writefile(filePath,data,"a+b");
end