function ccp(x,y)
	return CCPoint(x,y)
end

function log(...)
    if DEBUG then
        print(...)
    end
end

local isPrintLua = true;
function print_lua_table (lua_table, indent ,_isPrintLua)
	if _isPrintLua == nil then
		if not isPrintLua then
			return
		end
	else
		if not _isPrintLua  then
			return
		end
	end
	
	
	indent = indent or 0
	if indent==0 then
		print("******!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!******");
	end
	for k, v in pairs(lua_table) do
		if type(k) == "string" then
			k = string.format("%q", k)
		end
		local szSuffix = ""
		if type(v) == "table" then
			szSuffix = "{"
		end
		local szPrefix = string.rep("    ", indent)
		formatting = szPrefix.."["..k.."]".." = "..szSuffix
		if type(v) == "table" then
			--print(formatting)
			print(formatting)
			print_lua_table(v, indent + 1,_isPrintLua)
			--print(szPrefix.."},")
			print(szPrefix.."},")
		else
			local szValue = ""
			if type(v) == "string" then
				szValue = string.format("%q", v)
			else
				szValue = tostring(v)
			end
			--print(formatting..szValue..",")
			print(formatting..szValue..",")
		end
	end
end


--------------------------------
function reload( moduleName )
    local luaPath = luaFilePath(moduleName)
    local load = false
    if package.loaded[luaPath] ~= nil then
        load = true
        package.loaded[luaPath] = nil
    end
    
    if luaPath~=moduleName and package.loaded[moduleName] ~= nil then
        load = true
        package.loaded[moduleName] = nil
    end
    if load then
        log("reload lua:"..moduleName)
        req(moduleName)
    end
end


local function search (k, plist)
	 for kk, vv in pairs(plist) do
		  local v = vv[k]     -- try `i'-th superclass
		  if v then return v end
	 end
end

function createClass (p)
	 local c = {}        -- new class
	
	 c.super = p;     --保留父类，以便可以重用父类的方法
	
	 --将当前类的索引知道超类上，本地找不到，向上追溯
	 setmetatable(c, {__index = function (t, k)
			  local v = search(k, p);
			  t[k] = v;
			  return v;
		 end
	 })
	
	 -- prepare `c' to be the metatable of its instances
	 c.__index = c
	
	 -- define a new constructor for this new class
	 function c:new (o)
		  o = o or {}
		  setmetatable(o, c)
		  --o:init();
		  return o
	 end      
	
	 return c
end
----------------------------
