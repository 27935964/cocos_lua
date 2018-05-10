----资源变化文本提醒功能----
--author:hhh time:2017.10.17


ResourceTip=class("ResourceTip");

function ResourceTip:ctor()
	self.callFun={}
	self.callFun[1]=handler(self,self.getCoin);
	self.callFun[2]=handler(self,self.getGold);

	self.data={};
	self.addData={};
	self.timer=CCTimer:new();
end

--检测金币，钻石变化
function ResourceTip:init()
	self.data={};
	for k,v in pairs(self.callFun) do
		local value=v();
		table.insert(self.data,{value1=value,value2=0,msg=MG_TEXT(string.format("resourceTip_%d",k))});
	end
end

function ResourceTip:show()
	local item;
	for k,v in pairs(self.callFun) do
		item=self.data[k];
		if item then
			item.value2=v();
		end
	end

	self.addData={};
	for k,v in pairs(self.data) do
		value=v.value2-v.value1;
		if value>0 then
			table.insert(self.addData,string.format(v.msg,value));
		end
	end

	if #self.addData>0 then
		self.timer:startTimer(500,handler(self,self.updateTime),false);--每秒回调一次
	end
end

--文字提示获得资源
function ResourceTip:showData(get_item)
	local list = getneedlist(get_item);
	local localInfo;
	self.addData={};
	for k,v in pairs(list) do
		local id=tonumber(v.id); -- 物品ID
        		local type=tonumber(v.type);-- 物品类型
        		local num=tonumber(v.num);-- 物品数量
        		if type==8 then
        			localInfo=GENERAL:getAllGeneralModel(id);
        			if localInfo then
        				table.insert(self.addData,string.format(MG_TEXT("resourceTip_0"),localInfo:name(),num));
        			end
        		elseif type==3 or type==9 or type==10 or type==11 or type==12 or type==13 or type==14 or type==15 then
        			localInfo=RESOURCE:getDBResourceListByItemId(id);
        			if localInfo then
        				table.insert(self.addData,string.format(MG_TEXT("resourceTip_0"),localInfo:name(),num));
        			end
        		else
        			local sql = string.format("select * from item_type where id=%d and isonly=%d",type,id);
    			local DBData = LUADB.select(sql, "name:desc:icon:quality");
    			if DBData then
    				table.insert(self.addData,string.format(MG_TEXT("resourceTip_0"),DBData.info.name,num));
    			end
        		end
	end

	if #self.addData>0 then
		self.timer:startTimer(500,handler(self,self.updateTime),false);--每秒回调一次
	end
end

function ResourceTip:getResData(reward)
	rewards=getneedlist(reward);

	local strArr=spliteStr(reward,':');
	local resData={};
	resData.id=tonumber(strArr[2]);-- 物品ID
	resData.type=tonumber(strArr[1]);-- 物品类型
	resData.num=tonumber(strArr[3]);-- 物品数量
	resData.name="name";--物品名称
	resData.desc="desc";--物品描述
	resData.icon="icon";--物品图标
	resData.quality=1;--物品品质
	if resData.type==8 then
		localInfo=GENERAL:getAllGeneralModel(resData.id);
		if localInfo then
		    	resData.name=localInfo:name();
		    	resData.desc=localInfo:desc();
		    	resData.icon=localInfo:head();
		    	resData.pic=localInfo:pic();
		    	resData.bust=localInfo:bust();
		    	resData.quality=localInfo:getQuality();
		end
	elseif resData.type==3 or resData.type==9 or resData.type==10 or resData.type==11 or resData.type==12 or resData.type==13 or resData.type==14 or resData.type==15 then
		localInfo=RESOURCE:getDBResourceListByItemId(resData.id);
		if localInfo then
		    	resData.name=localInfo:name();
		    	resData.desc=localInfo:desc();
			resData.icon=localInfo:pic();
			resData.quality=localInfo:getQuality();
		end
	else
		local sql = string.format("select * from item_type where id=%d and isonly=%d",resData.type,resData.id);
		local DBData = LUADB.select(sql, "name:desc:icon:quality");
		if DBData then
			resData.name=DBData.info.name;
			resData.desc=DBData.info.desc;
			resData.icon=DBData.info.icon..".png";
			resData.quality=DBData.info.quality;
		end
	end
	return resData;
end

function ResourceTip:updateTime()
	local curCount=self.timer.count;
	local msg=self.addData[curCount];
	
	local winSize=cc.Director:getInstance():getWinSize();
	local curScene=cc.Director:getInstance():getRunningScene();

	local startX=winSize.width*0.5;
	local startY=winSize.height*0.5+110;
	local rankLabel=cc.Label:createWithTTF(msg, ttf_msyh, 22);
	rankLabel:setColor(cc.c3b(0,221,94));
	rankLabel:enableOutline(Color4B.BLACK,1);
	rankLabel:setPosition(cc.p(startX,startY));
	curScene:addChild(rankLabel,ZORDER_MAX);

	local moveTo=cc.MoveTo:create(1.5,cc.p(startX,startY+80));
	local fadeOut=cc.FadeOut:create(1.5);
	local spawnAction=cc.Spawn:create(moveTo,fadeOut);
	local seqAction=cc.Sequence:create(spawnAction,cc.CallFunc:create(function()
		rankLabel:removeFromParent();
	end));
	rankLabel:runAction(seqAction);
	
	if curCount>=#self.addData then
		self.timer:stopTimer();
	end
end

function ResourceTip:getCoin()
	return ME:getCoin();
end

function ResourceTip:getGold()
	return ME:getGold();
end

local _resourceTip=nil;

function ResourceTip.getInstance()
	if _resourceTip==nil then
		_resourceTip=ResourceTip.new();
	end
	return _resourceTip;
end

function ResourceTip.dispose()
	if _resourceTip then
		_resourceTip=nil;
	end
end