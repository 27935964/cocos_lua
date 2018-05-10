----公会战view----
--author:hhh time:2017.11.6
local UWTopView=class("UWTopView",View);

function UWTopView:ctor(component)
    	UWTopView.super.ctor(self,component);
    	self.rankLayer=nil;
    	self.rewardLayer=nil;
    	self.jiaoZhenLayer=nil;
    	self.diaoBinLayer=nil;
    	self.dispatchLayer=nil;
    	self.teamInfoLayer=nil;
    	self.selectCampLayer=nil;
    	self.callDefendLayer=nil;
    	self.resuldLayer=nil;
end

function UWTopView:onAdd()
	self:addObserver(UWNN.UWInitProxyOpenRank,self.openRank);
	self:addObserver(UWNN.UWInitProxyOpenReward,self.openReward);
	self:addObserver(UWNN.UWInitProxyOpenJiaoZhen,self.openJiaoZhen);
	self:addObserver(UWNN.UWInitProxyOpenDiaoBin,self.openDiaoBin);
	self:addObserver(UWNN.UWInitProxyOpenTeamInfo,self.openTeamInfo);
	self:addObserver(UWNN.UWInitProxyOpenSelectCamp,self.openSelectCamp);
	self:addObserver(UWNN.UWInitProxyOpenCallDefend,self.openCallDefend);
	self:addObserver(UWNN.UWInitProxyFightResult,self.openResult);
	self:addObserver(UWNN.UWInitProxyUpdateJiaoZhen,self.updateJiaoZhen);
	self:addObserver(UWNN.UWInitProxyUpdataDiaoBin,self.updateDiaoBin);
end

function UWTopView:onRemove()
	self:removeObserver(UWNN.UWInitProxyOpenRank);
	self:removeObserver(UWNN.UWInitProxyOpenReward);
	self:removeObserver(UWNN.UWInitProxyOpenJiaoZhen);
	self:removeObserver(UWNN.UWInitProxyOpenDiaoBin);
	self:removeObserver(UWNN.UWInitProxyOpenTeamInfo);
	self:removeObserver(UWNN.UWInitProxyOpenSelectCamp);
	self:removeObserver(UWNN.UWInitProxyOpenCallDefend);
	self:removeObserver(UWNN.UWInitProxyFightResult);
	self:removeObserver(UWNN.UWInitProxyUpdateJiaoZhen);
	self:removeObserver(UWNN.UWInitProxyUpdataDiaoBin);
end

function UWTopView:openRank(notification)
	local initProxy=self:getProxy(UWNN.UWInitProxy);
	local UWRankLayer=require "UWRankLayer";
	self.rankLayer=coreLayerHelp(self,notification,self.rankLayer,UWRankLayer);
	if self.rankLayer then
		self.rankLayer:initData(initProxy);
	end
end

function UWTopView:openReward(notification)
	local initProxy=self:getProxy(UWNN.UWInitProxy);
	local UWRewardLayer=require "UWRewardLayer";
	self.rewardLayer=coreLayerHelp(self,notification,self.rewardLayer,UWRewardLayer);
	if self.rewardLayer then
		self.rewardLayer:initData(initProxy);
	end
end

function UWTopView:openJiaoZhen(notification)
	local initProxy=self:getProxy(UWNN.UWInitProxy);
	local UWJiaoZhenLayer=require "UWJiaoZhenLayer";
	self.jiaoZhenLayer=coreLayerHelp(self,notification,self.jiaoZhenLayer,UWJiaoZhenLayer);
	if self.jiaoZhenLayer then
		self.jiaoZhenLayer:initData(initProxy);
	end
end

function UWTopView:updateJiaoZhen(notification)
	local initProxy=self:getProxy(UWNN.UWInitProxy);
	if self.jiaoZhenLayer then
		self.jiaoZhenLayer:updata(initProxy);
	end
end

function UWTopView:openDiaoBin(notification)
	local initProxy=self:getProxy(UWNN.UWInitProxy);
	local UWDiaoBinLayer=require "UWDiaoBinLayer";
	self.diaoBinLayer=coreLayerHelp(self,notification,self.diaoBinLayer,UWDiaoBinLayer);
	if self.diaoBinLayer then
		self.diaoBinLayer:initData(initProxy);
	end
end

function UWTopView:updateDiaoBin(notification)
	if self.diaoBinLayer then
		local initProxy=self:getProxy(UWNN.UWInitProxy);
		self.diaoBinLayer:updataData(initProxy);
	end
end

function UWTopView:openTeamInfo(notification)
	local initProxy=self:getProxy(UWNN.UWInitProxy);
	local UWTeamInfoLayer=require "UWTeamInfoLayer";
	self.teamInfoLayer=coreLayerHelp(self,notification,self.teamInfoLayer,UWTeamInfoLayer);
	if self.teamInfoLayer then
		self.teamInfoLayer:initData(initProxy);
	end
end

function UWTopView:openSelectCamp(notification)
	local initProxy=self:getProxy(UWNN.UWInitProxy);
	local UWSelectCampLayer=require "UWSelectCampLayer";
	self.selectCampLayer=coreLayerHelp(self,notification,self.selectCampLayer,UWSelectCampLayer);
	if self.selectCampLayer then
		self.selectCampLayer:initData(initProxy);
	end
end

function UWTopView:openCallDefend(notification)
	local initProxy=self:getProxy(UWNN.UWInitProxy);
	local UWCallDefend=require "UWCallDefend";
	self.callDefendLayer=coreLayerHelp(self,notification,self.callDefendLayer,UWCallDefend);
	if self.callDefendLayer then
		self.callDefendLayer:initData(initProxy);
	end
end

function UWTopView:openResult(notification)
	local initProxy=self:getProxy(UWNN.UWInitProxy);
	local UWResultLayer=require "UWResultLayer";
	self.resuldLayer=coreLayerHelp(self,notification,self.resuldLayer,UWResultLayer);
	if self.resuldLayer then
		self.resuldLayer:initData(initProxy);
	end
end

function UWTopView:getBox()
    	return self.component;
end

return UWTopView;