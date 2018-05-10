----公会战数据----
--author:hhh time:2017.11.6
local UWInitProxy=class("UWInitProxy",Proxy);
UWInitProxy.REFLASH_TIME=60;

function UWInitProxy:ctor()
	UWInitProxy.super.ctor(self);

	self.timer=CCTimer:new();
	self.index=nil;--主场景数据
	self.userCamp=0;--玩家阵营
	self.getcamplist=nil;--叫阵队伍数据
	self.getkillrank=nil;--杀敌排行
	self.getreward=nil;--累计奖励
	self.status=0;--0战斗未开始，1战斗已经开始
	self.leftTime=0;
	self.teamData=nil;--队伍详情
	self.teamDataEx=nil;
	self.isTeamInfoOpen=false;
	self.affterCamp=0;--选择完阵营后，玩家操作1出兵2收兵3叫阵4调兵
	self.troopsData=nil;--调兵数据
	self.resultData=nil;--战斗结果
	self.isFightBack=false;
	self.isWillOver=false;--战斗即将结束
	self.killNum=nil;--杀敌数
	self.myKillRank=0;
	self.isOver=false;
end

--服务端返回初始化数据
function UWInitProxy:initBack(netData)
	self.index=netData.index;
	self:updataCamp();
	self:updataTime();
	self:postNotificationName(UWNN.UWInitProxyInit);

	local waitWin=self.index.wait_win_info;
	if waitWin then--有结束战斗倒记
		self:willOver({row=waitWin.camp,time=waitWin.time})
	end

	self.timer:startTimer(1000,handler(self,self.onTimer));
end

function UWInitProxy:onTimer()
	if self.timer.count%self.REFLASH_TIME==0 then
		self.core:executeCommand(UWNN.UWMyKillRankCmd);
	end
end

function UWInitProxy:updataTime()
	local startTime=LUADB.readConfig(152);
	local timeArr=string.split(startTime,":");

	local nowTime=ME:getServerTime();
	local temData=os.date("*t", nowTime);
	temData.hour=tonumber(timeArr[1]);
	temData.min=tonumber(timeArr[2]);
	startTime=os.time(temData);

	if nowTime>startTime then
		self.status=1;
		self.leftTime=tonumber(LUADB.readConfig(153))-nowTime+startTime;--剩余投兵时间
	else
		self.status=0;
		self.leftTime=startTime-nowTime;--战斗倒计时间
	end
end

function UWInitProxy:addCampBack(addcamp)
	self.index.user_war_info=addcamp.user_war_info;
	self:updataCamp();
end

function UWInitProxy:updataCamp()
	local userWarInfo=self.index.user_war_info;
	self.userCamp=0;
	if userWarInfo.camp~=nil then
		self.userCamp=tonumber(userWarInfo.camp);
	end

	self.index.my_post=tonumber(self.index.my_post);
	self.index.war_city_type=tonumber(self.index.war_city_type);

	if self.index.dfd_union_id==0 then--NPC公会旗子，公会名称读配置
		local sql = string.format("select npc_uflag,npc_uname from stage_list where id=%d",_G_UN_CITY_ID);
		local DBData = LUADB.select(sql, "npc_uflag:npc_uname");
		local npc_uflag=DBData.info.npc_uflag;
		if npc_uflag~="" then
			local arr=string.split(npc_uflag,":");
			self.index.npcFlagBgId=tonumber(arr[1]);
			self.index.npcFlagIconId=tonumber(arr[2]);
		end
		self.index.npcUnionName=DBData.info.npc_uname;
	end
end

--打开杀敌排行
function UWInitProxy:openRank(value)
	self:postNotificationName(UWNN.UWInitProxyOpenRank,{isOpen=value});
end

--打开累计奖励
function UWInitProxy:openReward(value)
	self:postNotificationName(UWNN.UWInitProxyOpenReward,{isOpen=value});
end

--叫阵
function UWInitProxy:openJiaoZhen(value)
	self:postNotificationName(UWNN.UWInitProxyOpenJiaoZhen,{isOpen=value});
end

--叫阵后刷新
function UWInitProxy:updataJiaoZhen()
	self:postNotificationName(UWNN.UWInitProxyUpdateJiaoZhen);
end

--调兵
function UWInitProxy:openDiaoBin(value)
	self:postNotificationName(UWNN.UWInitProxyOpenDiaoBin,{isOpen=value});
end

--队伍信息
function UWInitProxy:openTeamInfo(value)
	self.isTeamInfoOpen=value;
	self:postNotificationName(UWNN.UWInitProxyOpenTeamInfo,{isOpen=value});
end

--选择阵营
function UWInitProxy:openSelectCamp(value)
	self:postNotificationName(UWNN.UWInitProxyOpenSelectCamp,{isOpen=value});
end

--招募守卫
function UWInitProxy:openCallDefend(value)
	self:postNotificationName(UWNN.UWInitProxyOpenCallDefend,{isOpen=value});
end

function UWInitProxy:actionNTF(data)
	self:postNotificationName(UWNN.UWInitProxyFightAction,data);
	if self.isWillOver==true and data.data.report~=nil then
		self:endOver();
	end
end

function UWInitProxy:backNTF(data)
	self:postNotificationName(UWNN.UWInitProxyFightBack,data);
end

--战斗结果
function UWInitProxy:resultNTF(data)
	self.resultData=data;
	self.isOver=true;
	self.timer:stopTimer();
	self:postNotificationName(UWNN.UWInitProxyFightResult,{isOpen=true});
end

--双方军队数量改变
function UWInitProxy:armyNumNTF(data)
	self:postNotificationName(UWNN.UWInitProxyArmyNum,data);
end

--帐篷头像改变
function UWInitProxy:armyHeadNTF(data)
	self:postNotificationName(UWNN.UWInitProxyHeadNum,data);
end

function UWInitProxy:willOver(data)
	data.leftTime=tonumber(data.time)-ME:getServerTime();
	if not self.isWillOver and data.leftTime>0 then
		self.isWillOver=true;
		self:postNotificationName(UWNN.UWInitProxyWillOver,data);
	end
end

function UWInitProxy:endOver()
	self.isWillOver=false;
	self:postNotificationName(UWNN.UWInitProxyWillOver);
end

function UWInitProxy:killNumNTF(data)
	self.killNum=data;
end

function UWInitProxy:updateKillNum()
	self:postNotificationName(UWNN.UWInitProxyKillNum,self.killNum);
end

--调兵成功刷新数据
function UWInitProxy:updataTroops(data)
	local idsMap={};
	for k,v in pairs(data.ids) do
		idsMap[v]=true;
	end

	local moveArr={};
	for k,v in pairs(self.troopsData.corps) do
		v.select=false;
		if idsMap[v.id]==true then
			table.insert(moveArr,k);
		end
	end

	for i=#moveArr,1,-1 do
		key=moveArr[i];
		table.remove(self.troopsData.corps,key);
	end
	self:postNotificationName(UWNN.UWInitProxyUpdataDiaoBin);
end

--解析叫阵队伍数据
function UWInitProxy:parseCamplist(data)
	local corps_list=data.corps_list;
	local temArr;
	for k,v in pairs(corps_list) do
		temArr=getrewardlist(v.corps);
		if #temArr>0 then
			v.leadId=temArr[1].id;
		end
		v.select=false;
	end
	return data;
end

function UWInitProxy:parseTroops(data)
	local corps=data.corps;

	local tempArr;
	for k,v in pairs(corps) do

		tempArr={};
		for k1,v1 in pairs(v.general_info) do
			table.insert(tempArr,v1);
		end
		table.sort(tempArr,function(a,b)
			return a.lv<b.lv;
		end);

		if #v.general_info>0 then
			v.leadId=v.general_info[1].g_id;
			v.leadQuality=v.general_info[1].quality;
			v.lowLv=tempArr[1].lv;
		end
		v.select=false;
	end
	io.jsonFile(data);
	return data;
end

function UWInitProxy:onRemove()
	if self.timer~=nil then
		self.timer:stopTimer();
		self.timer=nil;
	end
end

return UWInitProxy;