local helper=require "helper"
local posturl=require "posturl"
local tcpurl=require "tcpurl"
NetHandler=createClass({});
NetHandler.net=nil;
NetHandler.delegates={};

function NetHandler:init()
	if not self.net then
		self.net=LuaNetwork:instance();
	end
end

function NetHandler:sendData(MsgID, josndata,title,fightflat)
	if fightflat==nil then
		fightflat = 0;
	end
	local post = posturl[MsgID];
	local str=string.format("c=%s&a=%s%s",post.c,post.a,josndata)
    	if  title==nil then
    		self.net:send(Post_png,MsgID,str,"",fightflat);
    	else
    		self.net:send(Post_png,MsgID,str,title,fightflat);
	end
end

function NetHandler:sendSocket(MsgID, str_a)
    self.net:sendSocket(MsgID,str_a);
end

function NetHandler:showFailedMessage(ackData)
    local report_msg = string.format("report_msg_%s",ackData.reportMsg)
    local DBData = LUADB.select(string.format("select value from lang_chs where name='%s'",report_msg), "value");
    if DBData then
        if ackData.args then
            for i=1,#ackData.args do
                local str = "%%"..(i-1);
                 DBData.info.value = string.gsub(DBData.info.value, str, ackData.args[i]);
            end
        end
        report_msg=DBData.info.value;
    end
    MGMessageTip:showFailedMessage(report_msg);
end

function NetHandler:addAckCode(delegate,MsgID)
	local netobj = {}
	netobj.delegate = delegate
	netobj.MsgID = MsgID
	table.insert(self.delegates, netobj)
end

function NetHandler:delAckCode(delegate,MsgID)
	for key, var in pairs(self.delegates) do
		if var.MsgID ==  MsgID and  var.delegate == delegate then
			table.remove(self.delegates,key)
		end
	end
end

--[[
function NetHandler:addAckCode(delegate,MsgID)
	local hasFound=false;
	for key, var in pairs(self.delegates) do
		if var.MsgID == MsgID then
			print("NetHandler:addAckCode error has found MsgID:",MsgID);
			hasFound=true;
			break
		end
	end
	
	if not hasFound then
		local netobj={};
		netobj.delegate=delegate;
		netobj.MsgID=MsgID;
		table.insert(self.delegates, netobj);
	end
end

function NetHandler:delAckCode(delegate,MsgID)
	local hasFound=false;
	local reKey;
	for key, var in pairs(self.delegates) do
		if var.MsgID==MsgID and  var.delegate==delegate then
			hasFound=true;
			reKey=key;
		end
	end

	if hasFound then
		table.remove(self.delegates,reKey)
	end
end
]]
--接收接口
function NetHandler:onReciveData(MsgID, NetData)
	print("NetHandler onReciveData MsgID:"..MsgID)

	for key, var in pairs(self.delegates) do
		if var.MsgID ==  MsgID and var.delegate.onReciveData then
			var.delegate:onReciveData(MsgID, NetData)
		end
	end
end

--发送失败
function NetHandler:onSendFialed(MsgID, NetData)
	print("NetHandler onSendFialed MsgID:"..MsgID)

	for key, var in pairs(self.delegates) do
		if var.MsgID ==  MsgID and var.delegate.onSendFialed then
			var.delegate:onSendFialed(MsgID, NetData)
		end
	end
end

-- 释放资源
function NetHandler:close()
	--MGLuaNetwork:purge()
	--self.net = nil
	--table.remove(self.delegates)
end



--------------------------------------------------------
--------------------------------------------------------
--全局数据处理
function handlerGobal(NetData)
	if NetData.getuserexp then
		local getuserexp=NetData.getuserexp;
		local newLv=tonumber(getuserexp.lv);
		local newExp=tonumber(getuserexp.exp);
		local oldLv=ME:Lv();

		ME:setLv(newLv);
		ME:setExp(newExp);
		
		--刷新玩家等级经验显示
		print("handlerGobal 玩家等级变化",oldLv,newLv,newExp);
		if newLv>oldLv then--显示升级界面
			require "LevelUpLayer";
			openLevelUp(true,oldLv,newLv,newExp);
		end
	elseif NetData.getuseraction then
		local getuseraction=NetData.getuseraction;
		local action=tonumber(getuseraction.action);
		print("handlerGobal 玩家体力变化 action",action);
	elseif NetData.getusercoin then
		local getusercoin=NetData.getusercoin;
		local coin=tonumber(getusercoin.coin);
		ME:setCoin(coin);
	elseif NetData.getusergold then
		local getusergold=NetData.getusergold;
		local gold=tonumber(getusergold.gold);
		ME:setCoin(gold);
	elseif NetData.getwarscore then
		local getwarscore=NetData.getwarscore;
		local warScore=tonumber(getwarscore.war_score);
		ME:setCoin(warScore);
	end
end

--接收接口
function handlerSocket(MsgID, backInfo)
	NetHandler:onReciveData(MsgID, backInfo);
end

--接收接口
function net_recive(MsgID, backInfo)
	print("NetHandler recive MsgID:"..MsgID);
	if MsgID>10000 then
		--socket
		handlerSocket(MsgID, backInfo);
	else
		--http
		backInfo = string.gsub(backInfo,"\\u","\\\\u");
		local NetData=cjson.decode(backInfo);
		handlerGobal(NetData);
		NetHandler:onReciveData(MsgID, NetData);
	end
end

--发送失败接口
function net_netFialed(MsgID, NetData)
	print("NetHandler netFialed");
	NetHandler:onSendFialed(MsgID, NetData);
end