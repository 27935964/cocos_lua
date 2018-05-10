require "LuaScene"

Fight_common=1--普通战斗布阵
Fight_arena_att=2--竞技场战斗布阵
Fight_arena_def=3--竞技场防守布阵
Fight_Expedition=4--隐士岛远征战斗布阵
Fight_Plot=5--事件剧情战斗布阵
Fight_Practice=6--英雄试炼战斗布阵
Fight_Invade=7--入侵事件
Fight_load=8--光复之路
Fight_union_troops=9--公会攻城部队
Fight_union_war=10--公会战
Fight_Maintainers=11--维护者之誓

FightOP=createClass({});

function FightOP:init()
    self.getflipreward = nil;
    self.getUserCorps =  0;
	
    self.fightinfo={
        [Fight_common]={team_post=Post_Pve_embattle,
                            team_handle=handler(self,self.team_common),
                            fight_post=Post_fighting,
                            fight_handle=handler(self,self.fight_common),
                            corps_type=1}
        ,[Fight_arena_att]={team_post=Post_embattle,
                            team_handle=handler(self,self.team_arena_att),
                            fight_post=Post_doSports,
                            fight_handle=handler(self,self.fight_arena),
                            corps_type=2}
        ,[Fight_arena_def]={team_post=Post_getUserCorps,
                            team_handle=handler(self,self.team_arena_def),
                            fight_post=0,
                            corps_type=3}
        ,[Fight_Expedition]={team_post=Post_Expedition_embattle,
                            team_handle=handler(self,self.team_expedition),
                            fight_post=Post_entryStage,
                            fight_handle=handler(self,self.fight_expedition),
                            corps_type=4}
        ,[Fight_Plot]={team_post=Post_Plot_embattle,
                            team_handle=handler(self,self.team_Plot),
                            fight_post=Post_Plot_fighting,
                            fight_handle=handler(self,self.fight_Plot),
                            corps_type=5}
        ,[Fight_Practice]={team_post=Post_Practice_embattle,
                            team_handle=handler(self,self.team_practice),
                            fight_post=Post_Practice_fighting,
                            fight_handle=handler(self,self.fight_practice),
                            corps_type=0}
        ,[Fight_Invade]={team_post=Post_Invade_embattle,
                            team_handle=handler(self,self.team_invade),
                            fight_post=Post_Invade_fighting,
                            fight_handle=handler(self,self.fight_invade),
                            corps_type=5}
        ,[Fight_load]={team_post=Post_load_embattle,
                            team_handle=handler(self,self.team_load),
                            fight_post=Post_load_fighting,
                            fight_handle=handler(self,self.fight_load),
                            corps_type=0}
        ,[Fight_union_troops]={team_post=Post_Union_Troops_embattle,
                            team_handle=handler(self,self.team_union_troops),
                            fight_post=0,
                            corps_type=0}
        ,[Fight_union_war]={team_post=Post_Union_War_embattle,
                            team_handle=handler(self,self.teamUnionWar),
                            fight_post=0,
                            corps_type=0}
        ,[Fight_Maintainers]={team_post=Post_Maintainers_embattle,
                            team_handle=handler(self,self.team_maintainers),
                            fight_post=Post_Maintainers_fighting,
                            fight_handle=handler(self,self.fight_maintainers),
                            corps_type=0}
    }

    self:pushAck()
end

function FightOP:pushAck()
    local postArr={};
    for k,v in pairs(self.fightinfo) do
            if v.team_post>0 then
                    table.insert(postArr,v.team_post);
            end
            if v.fight_post>0 then
                    table.insert(postArr,v.fight_post);
            end
    end
    
    -- for k, v in pairs(self.fightinfo) do 
    --     local havesame = false;
    --     if v.team_post>0 then
    --         for i=1,#postArr do
    --             if postArr[i] == v.team_post then
    --                 havesame = true;
    --                 break;
    --             end
    --         end
    --         if havesame == false then
    --             table.insert( postArr, v.team_post )
    --         end
    --     end

    --     havesame = false;
    --     if v.fight_post>0 then
    --         for i=1,#postArr do
    --             if postArr[i] == v.fight_post then
    --                 havesame = true;
    --                 break;
    --             end
    --         end
    --         if havesame==false then
    --             table.insert( postArr, v.fight_post )
    --          end
    --     end
    -- end
    table.insert(postArr, Post_changeUseGeneral );
    table.insert(postArr, Post_Union_Troops_doDispatch);
    table.insert(postArr, Post_Union_War_buyGeneralPrepareNum);
    table.insert(postArr, Post_Union_War_prepareWar);
    for i=1,#postArr do
        NetHandler:addAckCode(self,postArr[i]);
    end
end

--进入战斗
function FightOP:setTeam(scenetype,teamtype,teamdata,fightdata,title)
    self.scenetype =  scenetype;
    self.teamtype  =  teamtype;
    self.fightdata =  fightdata;
    self.title     =  title;
    self.info = self.fightinfo[teamtype];
    NetHandler:sendData(self.info.team_post, teamdata);
    if self.info.team_post==Post_getUserCorps then
        self.getUserCorps = 1;
    end
end

function FightOP:setUnionWar(scenetype)
        self.scenetype=scenetype;
end

--防守保存阵型，点击开始保存阵型
function FightOP:sendChangeCrop(teamStr,ret,upNum)
	if ret ==0 then  --没上人
		MGMessageTip:showFailedMessage(MG_TEXT("team_5"));
	elseif ret ==1 then  --阵型不变
		if self.teamtype== Fight_arena_def then
			  MGMessageTip:showFailedMessage(MG_TEXT("team_4"));
		else
                                    NetHandler:sendData(self.info.fight_post, self.fightdata);
     	           end
	elseif ret == 2 then  --阵型改变
                    if self.teamtype== Fight_common then
                                    local str = string.format("&gids=%s",teamStr);
                                    NetHandler:sendData(Post_Pve_changeUseGeneral, str);
                    elseif self.teamtype == Fight_union_troops then
                                    local str = string.format("&gids=%s",teamStr);
                                    NetHandler:sendData(Post_Union_Troops_doDispatch, str);
                    elseif self.teamtype==Fight_union_war then
                                    if upNum<5 then
                                            MGMessageTip:showFailedMessage(MG_TEXT("unionWar_4"));
                                    else
                                            local str = string.format("&gids=%s&city_id=%d",teamStr,_G_UN_CITY_ID);
                                            NetHandler:sendData(Post_Union_War_prepareWar,str)
                                    end
                    else
                    	               local str = string.format("&gids=%s&type=%d",teamStr,self.corps_type);
                        	    NetHandler:sendData(Post_changeUseGeneral, str);
                    end
	end
end

function FightOP:buyHeroUpNum(heroId)
        if self.teamtype==Fight_union_war then
                local cost=tonumber(LUADB.readConfig(178));
                GobalDialog:getInstance():showComfirm(string.format(MG_TEXT("unionWar_5"),cost),function()
                            local str = string.format("&g_id=%d",heroId);
                            NetHandler:sendData(Post_Union_War_buyGeneralPrepareNum,str)
                end);
        end
end

function FightOP:onReciveData(MsgID, NetData)
    if MsgID == Post_getUserCorps then
        if self.getUserCorps == 0 then
    	    return;
        else
            self.getUserCorps = 0;
        end
    end


    if MsgID==self.info.team_post then
        if NetData.state == 1 then
            self.info:team_handle(NetData);
        else
            NetHandler:showFailedMessage(NetData)
        end
    elseif MsgID==self.info.fight_post then
        if NetData.state == 1 then
            self.info:fight_handle(NetData)
        else
            NetHandler:showFailedMessage(NetData)
        end
    elseif  MsgID == Post_changeUseGeneral then
        if NetData.state == 1 then
            if self.teamtype== Fight_arena_def then
                MGMessageTip:showSuccessMessage(MG_TEXT("arena_Savedefense_suc"));
            else
                NetHandler:sendData(self.info.fight_post, self.fightdata);
            end
        else
            NetHandler:showFailedMessage(NetData)
        end
    elseif  MsgID == Post_Pve_changeUseGeneral then
        if NetData.state == 1 then
            NetHandler:sendData(self.info.fight_post, self.fightdata);
        else
            NetHandler:showFailedMessage(NetData)
        end
    elseif  MsgID == Post_Union_Troops_doDispatch then
        if NetData.state == 1 then
            LuaBackCpp:closeTeamLayer();
            NetHandler:sendData(Post_Union_Troops_index, "");
        else
            NetHandler:showFailedMessage(NetData)
        end
    elseif MsgID==Post_Union_War_prepareWar then
            if NetData.state == 1 then
                LuaBackCpp:closeTeamLayer();--"公会战保存阵型成功"
            else
                NetHandler:showFailedMessage(NetData)
            end
    elseif MsgID==Post_Union_War_buyGeneralPrepareNum then
            if NetData.state == 1 then
                local str = cjson.encode(NetData.buygeneralpreparenum.info);
                enterLuaScene(self.scenetype,3,1,str,"");--购买武将次数
            else
                NetHandler:showFailedMessage(NetData);
            end
    end
end

--主线
function FightOP:team_common(send,ackData)
    local str = cjson.encode(ackData.embattle);
    self.corps_type = ackData.embattle.corps_type;

    enterLuaScene(self.scenetype,2,2,self.title,str);--布阵，有防守方布阵完直接战斗
end

function FightOP:fight_common(send,ackData)
    local str = cjson.encode(ackData.fighting.report);
    self.get_item =  ackData.fighting.get_item;
    self.result_army =  ackData.fighting.report.result_army;
    self.result_army.result = ackData.fighting.report.result;
    self.fighting = ackData.fighting;
    if ackData.getflipreward then
        self.getflipreward=ackData.getflipreward;
    end

    enterLuaScene(self.scenetype,1,0,self.title,str);

    ackData.dosports = ackData.fighting;
    ackData.fighting = nil;
    self:saveReport(ackData);
end

--竞技场进攻 Post_embattle
function FightOP:team_arena_att(send,ackData)
    local title = MG_TEXT("team_6")..unicode_to_utf8(ackData.embattle.dfd_name);
    local str = cjson.encode(ackData.embattle);
    self.corps_type = ackData.embattle.corps_type;

    enterLuaScene(self.scenetype,2,2,title,str);--布阵，有防守方布阵完直接战斗
end

function FightOP:fight_arena(send,ackData)
    local title = MG_TEXT("team_6")..unicode_to_utf8(ackData.dosports.report.dfd_name);
    local str = cjson.encode(ackData.dosports.report);
    self.get_item =  ackData.dosports.get_item;
    self.result_army =  ackData.dosports.report.result_army;
    self.result_army.result = ackData.dosports.report.result;

    enterLuaScene(self.scenetype,1,0,title,str);--战斗
    self:saveReport(ackData);
end

--竞技场防守Post_getUserCorps 进入布阵
function FightOP:team_arena_def(send,ackData)
    self.title = MG_TEXT("team_1");
    local str = cjson.encode(ackData.getusercorps);
    self.corps_type = self.info.corps_type;
    enterLuaScene(self.scenetype,2,1,self.title,str);--布阵，无防守方单纯布阵
end

--公会攻城部队 进入布阵
function FightOP:team_union_troops(send,ackData)
    self.title = MG_TEXT("team_7");
    
    local embattle = {};
    embattle.corps = ackData.embattle.corps;
    embattle.use_general = "";
    local str = cjson.encode(embattle);

    enterLuaScene(self.scenetype,2,1,self.title,str);
end

--隐士岛远征
function FightOP:team_expedition(send,ackData)
    local str = cjson.encode(ackData.embattle);
    self.corps_type = ackData.embattle.corps_type;

    enterLuaScene(self.scenetype,2,2,self.title,str);
end

function FightOP:fight_expedition(send,ackData)
    local str = cjson.encode(ackData.entrystage.report);
    self.get_item =  ackData.entrystage.get_item;
    self.result_army =  ackData.entrystage.report.result_army;
    self.result_army.result = ackData.entrystage.report.result;

    enterLuaScene(self.scenetype,1,0,self.title,str);

    ackData.dosports = ackData.entrystage;
    ackData.entrystage = nil;
    self:saveReport(ackData);
    if ackData.getflipreward then--翻牌数据
        self.getflipreward = ackData.getflipreward;
    end
end

--英雄试炼
function FightOP:team_practice(send,ackData)
    local str = cjson.encode(ackData.embattle);
    self.corps_type = ackData.embattle.corps_type;
    enterLuaScene(self.scenetype,2,2,self.title,str);
end

function FightOP:fight_practice(send,ackData)
    local str = cjson.encode(ackData.fighting.report);
    self.get_item =  ackData.fighting.get_item;
    self.result_army =  ackData.fighting.report.result_army;
    self.result_army.result = ackData.fighting.report.result;

    enterLuaScene(self.scenetype,1,0,self.title,str);
    ackData.dosports = ackData.fighting;
    ackData.fighting = nil;
    self:saveReport(ackData);
end

--光复之路
function FightOP:team_load(send,ackData)
    self.title = MG_TEXT("recoverroadLayer_9");
    local str = cjson.encode(ackData.embattle);
    self.corps_type = ackData.embattle.corps_type;

    enterLuaScene(self.scenetype,2,2,self.title,str);
end

function FightOP:fight_load(send,ackData)
    local str = cjson.encode(ackData.fighting.report);
    self.get_item =  ackData.fighting.get_item;
    self.result_army =  ackData.fighting.report.result_army;
    self.result_army.result = ackData.fighting.report.result;
    enterLuaScene(self.scenetype,1,0,self.title,str);

    ackData.dosports = ackData.fighting;
    ackData.fighting = nil;
    self:saveReport(ackData);
end

--维护者之誓
function FightOP:team_maintainers(send,ackData)
    self.title = MG_TEXT("vindicatorLayer_4");
    local str = cjson.encode(ackData.embattle);
    self.corps_type = ackData.embattle.corps_type;

    enterLuaScene(self.scenetype,2,2,self.title,str);
end

function FightOP:fight_maintainers(send,ackData)
    local str = cjson.encode(ackData.fighting.report);
    self.get_item =  ackData.fighting.get_item;
    self.result_army =  ackData.fighting.report.result_army;
    self.result_army.result = ackData.fighting.report.result;
    enterLuaScene(self.scenetype,1,0,self.title,str);

    ackData.dosports = ackData.fighting;
    ackData.fighting = nil;
    self:saveReport(ackData);
end

--事件剧情
function FightOP:team_Plot(send,ackData)
    local str=cjson.encode(ackData.embattle);
    self.corps_type = ackData.corps_type;

    enterLuaScene(self.scenetype,2,2,self.title,str);
end

function FightOP:fight_Plot(send,ackData)
    local title = MG_TEXT("team_6")..unicode_to_utf8(ackData.fighting.report.dfd_name);
    local str = cjson.encode(ackData.fighting.report);
    self.get_item =  ackData.fighting.get_item;
    self.result_army =  ackData.fighting.report.result_army;
    self.result_army.result = ackData.fighting.report.result;

    enterLuaScene(self.scenetype,1,0,title,str);

    ackData.dosports = ackData.fighting;
    ackData.fighting = nil;
    self:saveReport(ackData);
end

--入侵事件
function FightOP:team_invade(send,ackData)
    local str=cjson.encode(ackData.embattle);
    self.corps_type = ackData.embattle.corps_type;

    enterLuaScene(self.scenetype,2,2,self.title,str);
end

function FightOP:fight_invade(send,ackData)
    local title =self.title;
    local str = cjson.encode(ackData.fighting.report);
    self.get_item =  ackData.fighting.get_item;
    self.result_army =  ackData.fighting.report.result_army;
    self.result_army.result = ackData.fighting.report.result;
    self.getflipreward=ackData.getflipreward;

    enterLuaScene(self.scenetype,1,0,title,str);

    ackData.dosports = ackData.fighting;
    ackData.fighting = nil;
    self:saveReport(ackData);
end

--公会战
function FightOP:teamUnionWar(send,ackData)
        local embattle={};
        embattle.corps=ackData.embattle.corps;--可上阵的武将ID
        embattle.general_use_num=ackData.embattle.general_use_num;--武将上阵次数使用情况
        embattle.general_need_lv=ackData.embattle.general_need_lv;--武将上阵需要等级
        embattle.is_other=ackData.embattle.is_other;--1是第三方玩家 0不是
        embattle.use_gids=ackData.embattle.use_gids ;--已上阵的武将ID
        embattle.teamtype = self.teamtype;
        local str=cjson.encode(embattle);
        enterLuaScene(self.scenetype,2,1,self.title,str);
end

function FightOP:ReadReport(scenetype)
    self.scenetype = scenetype;
    self.teamtype  = 0;
    local filePath =  cc.FileUtils:getInstance():getWritablePath().."report.json";
    local f = io.open( filePath, "r" )
    local backInfo = f:read( "*all" )
    f:close()
   
    local ackData = cjson.decode(backInfo); 
    local title = MG_TEXT("team_6")..unicode_to_utf8(ackData.dosports.report.dfd_name);
    local str = cjson.encode(ackData.dosports.report);
    self.get_item =  ackData.dosports.get_item;
    self.result_army =  ackData.dosports.report.result_army;
    self.result_army.result = ackData.dosports.report.result;
    enterLuaScene(self.scenetype,1,10,title,str);--测试战斗战报
end

function FightOP:saveReport(ackData)
    local str = cjson.encode(ackData);
    local path = cc.FileUtils:getInstance():getWritablePath()
    local f = io.open(path .. "report.json", "w+")
    f:write(str);
    f:close();
end

function FightOP:showReSult()
    if self.scenetype==SCENEINFO.UNIONWAR_SCENE then--公会战
        enterUnionWar(_G.sceneData.layerData,function()
            GobalDialog:getInstance():showAlert(MG_TEXT("unionWar_38"),function()--提示公会战已经结束了
                    enterLuaScene(_G.sceneData.lastSceneType);--返回最后一个场景
            end);
        end,false);
    else
        require "FightResult"
        local layer = FightResult.create(self);
        layer:setData(self.get_item,self.result_army);
        cc.Director:getInstance():getRunningScene():addChild(layer,ZORDER_MAX);
    end
end

function FightOP:ResultBack()
    require "fanPaiLayer"
    enterLuaScene(self.scenetype,1,1);--关闭战斗
    if self.teamtype==0 then   --显示战报
        if self.scenetype==SCENEINFO.MAP_SCENE then
            addMap();
        elseif self.scenetype==SCENEINFO.MAIN_SCENE then
            addMainCity();
        end
    elseif self.teamtype==1 then--征战（主线）
            enterLuaLayer(self.scenetype,LAYERTAG.LAYER_CHECKPOINT);
            if self.fighting.is_end == 1 then--1结束讨伐战
                require "MLFightResult"
                local fightResult = MLFightResult.showBox(self);--征战结算界面
                fightResult:setData(self.fighting);
            end
            if self.getflipreward then--翻牌
                local fanPai = fanPaiLayer.showBox(self);
                fanPai:setData(self.getflipreward);
                self.getflipreward = nil;
            end
    elseif self.teamtype==2 then--竞技场
            enterLuaLayer(self.scenetype,LAYERTAG.LAYER_ARENA);
    elseif self.teamtype==4 then--隐士岛远征
            enterLuaLayer(self.scenetype,LAYERTAG.LAYER_ISlAND);
            if self.getflipreward then--翻牌
                local fanPai = fanPaiLayer.showBox(self);
                fanPai:setData(self.getflipreward);
                self.getflipreward = nil;
            end
    elseif self.teamtype==Fight_Plot then--玩家剧情
            enterLuaLayer(self.scenetype,LAYERTAG.LAYER_PLOT);
    elseif self.teamtype==Fight_Practice then--英雄试炼
            enterLuaLayer(self.scenetype,LAYERTAG.LAYER_TRIAL);
    elseif self.teamtype==Fight_load then--光复之路
            enterLuaLayer(self.scenetype,LAYERTAG.LAYER_RECOVERROAD);
    elseif self.teamtype==Fight_Maintainers then--维护者之誓
            enterLuaLayer(self.scenetype,LAYERTAG.LAYER_MAINTAINERS);
    elseif self.teamtype==Fight_Invade then--入侵事件
            if self.result_army.result==1 then--战斗胜利
                     enterLuaLayer(self.scenetype,-1);
                    local fanPai=fanPaiLayer.showBox(self);
                    fanPai:setData(self.getflipreward);
                    self.getflipreward = nil;
            else--失败
                    enterLuaLayer(self.scenetype,LAYERTAG.LAYER_INVADE);
            end
    else

    end
    
end

-- 释放资源
function FightOP:close()

end

function Fight_ChangeCrop(teamStr,ret,upNum)
    FightOP:sendChangeCrop(teamStr,ret,upNum)
end

function Fight_ReSult()
    FightOP:showReSult();
end

function Fight_ReadReport(scenetype)
    FightOP:ReadReport(scenetype);
end

function Fight_BuyHeroUpNum(heroId)
     FightOP:buyHeroUpNum(heroId)
end
