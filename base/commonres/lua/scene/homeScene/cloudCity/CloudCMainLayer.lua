----云中城主界面----
require "ItemJump";
require "FloatUpMessage";
require "MGMapScrollView"
require "ResourceTip";

local RemoteDiceItem=require "RemoteDiceItem";
local CloudCMainLayer=class("CloudCMainLayer",function()
	return cc.Layer:create();
end);

function CloudCMainLayer:ctor(main)
	self.main=main;
	self.tabView=nil;
	self.manager=nil;
	self.openLayer=nil;
    self.diceSp=nil;
    self.curUseNum=0;
    self.maxUseNum=0;
    self.isBatchIng=false;
    self.schedulerID=nil;
    self.buildImgTab={};
    self.rewardImgTab={};
    self.grid=0;
    self.diceContent="";
    self.tribute_reward="";
    self.set_info="";
    -- 
    self.jumpIndex=0;
    self.movePosTab={};
    self.roleNode=nil;
    -- 
	MGRCManager:cacheResource("CloudCMainLayer","cloudcity_main_bg.jpg");
	MGRCManager:cacheResource("CloudCMainLayer","main_top_bg.png");
    MGRCManager:cacheResource("CloudCMainLayer","eff_yunzhongcheng_touzi.png","eff_yunzhongcheng_touzi.plist");
	MGRCManager:cacheResource("CloudCMainLayer","CloudCity_ui.png","CloudCity_ui.plist");
	self.pWidget=MGRCManager:widgetFromJsonFile("CloudCMainLayer", "CloudCity_Main_Ui.ExportJson");
	self:addChild(self.pWidget);
    local panel_1=self.pWidget:getChildByName("Panel_1");

    panel_1:setVisible(false);
    panel_1:setTouchEnabled(false);
    -- 
	self.panel_3=self.pWidget:getChildByName("Panel_3");
	self.panel_20=self.panel_3:getChildByName("Panel_20");
    self:setRemoteDiceRect(false);
    -- 
    self.panel_4=self.pWidget:getChildByName("Panel_4");
    self:setNoCanClick(false);
    -- 
	local panel_2=self.pWidget:getChildByName("Panel_2");--Panel
    panel_2:setTouchEnabled(false);
    -- local function closeClick(sender,eventType)
    --     if eventType == ccui.TouchEventType.ended then
    --          self:setRemoteDiceRect(false);
    --     end
    -- end
    -- panel_2:addTouchEventListener(closeClick)
    -- 
	local img_back=panel_2:getChildByName("Image_Back");
	img_back:addTouchEventListener(handler(self,self.closeBtnClick));
    -- 
	local button_shop=panel_2:getChildByName("Button_Shop");--Button
	button_shop:addTouchEventListener(handler(self,self.shopBtnClick));
    -- 十次骰子
    self.button_batchDice=panel_2:getChildByName("Button_BatchDice");--Button
    self.button_batchDice:addTouchEventListener(handler(self,self.batchDiceBtnClick));
    -- 单次骰子
    self.button_normalDice=panel_2:getChildByName("Button_NormalDice");--Button
    self.button_normalDice:addTouchEventListener(handler(self,self.normalDiceBtnClick));
    self.label_normalDice=self.button_normalDice:getChildByName("Label_NormalDice_number");--Label
    -- 遥控骰子
    self.button_remoteDice=panel_2:getChildByName("Button_RemoteDice");--Button
    self.button_remoteDice:addTouchEventListener(handler(self,self.remoteDiceBtnClick));
    self.label_remoteDice=self.button_remoteDice:getChildByName("Label_RemoteDice_number");--Label
    -- 当前圈数
    self.label_cycle=panel_2:getChildByName("Label_Cycle_Number");--Label
    -- 奖励加成
    self.label_bonusPlus=panel_2:getChildByName("Label_BonusPlus_Number");--Label
    -- 本圈累计奖励
    local img_gold =panel_2:getChildByName("Image_Gold");
    self.label_gold=img_gold:getChildByName("Label_Gold_number");--Label
    local img_gem =panel_2:getChildByName("Image_Gem");
    self.label_gem=img_gem:getChildByName("Label_Gem_number");--Label
    -- 
    local label_currentCycles=panel_2:getChildByName("Label_CurrentCycles");
    label_currentCycles:setText(MG_TEXT_COCOS("CloudCMainLayer_Ui_1"));

    local label_bonusPlus=panel_2:getChildByName("Label_BonusPlus");
    label_bonusPlus:setText(MG_TEXT_COCOS("CloudCMainLayer_Ui_2"));

    local label_cumulativeReward=panel_2:getChildByName("Label_CumulativeReward");
    label_cumulativeReward:setText(MG_TEXT_COCOS("CloudCMainLayer_Ui_3"));
    -- 
    self:initMap();
    -- 
 	NodeListener(self);
    -- 
    NetHandler:sendData(Post_Cloud_Main_cloudMain, "");--初始化数据
end

function CloudCMainLayer:setNoCanClick(isVisible)
    self.panel_4:setTouchEnabled(isVisible);
end

function CloudCMainLayer:initData(user_cloud)
	self.label_cycle:setText(string.format("%d",user_cloud.circle));
	self.label_bonusPlus:setText(string.format("%d%s",user_cloud.circle_add,"%"));
	self.label_normalDice:setText(string.format("%d",user_cloud.dice));
	self:changeTopInfo(user_cloud.get_coin,user_cloud.get_stone);
end

function CloudCMainLayer:changeTopInfo(coin,stone)
	self.label_gold:setText(MGDataHelper:formatNumber(coin));
	-- self.label_gold:setText(MGDataHelper:formatNumber(ME:getCoin()));
	self.label_gem:setText(string.format("%d",stone));
    -- 遥控骰子数量
    local hasNum=0;
    local good=RESOURCE:getResModelByItemId(32);
    if good then
        hasNum=good:getNum();
    end
    self.label_remoteDice:setText(string.format("%d",hasNum));
end

function CloudCMainLayer:setRemoteDiceRect(isVisible)
    self.panel_3:setVisible(isVisible);
    self.panel_3:setTouchEnabled(isVisible);
    self.panel_20:setVisible(isVisible);
    self.panel_20:setTouchEnabled(isVisible);
    if self.tabView then
        self.tabView:setVisible(isVisible);
        self.tabView:setTouchEnabled(isVisible);
    end
end

function CloudCMainLayer:playDiceEffect(diceVal)
    if self.diceSp==nil then
        self.diceSp=cc.Sprite:create();
        self.diceSp:setAnchorPoint(1,0.5);
        self.diceSp:setPosition(cc.p(self:getContentSize().width+80,self:getContentSize().height/2));
        -- self.diceSp:setPosition(cc.p(self.button_normalDice:getPositionX(),self.button_normalDice:getPositionY()));
        self:addChild(self.diceSp);

        local action=fuGetAnimate("eff_yunzhongcheng_touzi_",0,11,0.08);
        local function remove()
            self.diceSp:setPositionX(560+560/2+80);
            self.diceSp:setSpriteFrame(string.format("dice_%d.png",diceVal));
            -- 延迟关闭
            local function delayClose()
                self.diceSp:removeFromParentAndCleanup(true);
                self.diceSp=nil;
                -- 
                self:moveRole();
            end
            local delay=cc.DelayTime:create(0.7);
            local callFunc=cc.CallFunc:create(delayClose);
            self:runAction(cc.Sequence:create(delay,callFunc));
        end
        local func=cc.CallFunc:create(remove)
        local seq=cc.Sequence:create(action,func);
        self.diceSp:runAction(seq);
    end
end

function CloudCMainLayer:onReciveData(msgId, netData)
	if msgId == Post_Cloud_Main_cloudMain then
        self.pWidget:setVisible(true);
      	if netData.state == 1 then
      		self.user_cloud=netData.cloudmain.user_cloud;
	        self:initData(self.user_cloud);
	        -- 
	        self.a_id=tonumber(self.user_cloud.angel_id);
	        self.angel_star=tonumber(self.user_cloud.angel_star);
	        self.diceContent=self.user_cloud.content;
	        self.grid=tonumber(self.user_cloud.grid);
	        self.set_info=self.user_cloud.set_info;
            self.tribute_reward=self.user_cloud.tribute_reward;
            self:showTributeReward();

            local gridDb=self:getCloudGridDB();
		    local grid_type=tonumber(gridDb.type);
            self:initRolePos();
		    self:loadCurPoint(grid_type);
      	else
          	NetHandler:showFailedMessage(netData);
      	end
  	elseif msgId==Post_Cloud_Main_doDice then
  		if netData.state == 1 then
            self.user_cloud=netData.cloudmain.user_cloud;
            -- 
            self.dodice=netData.dodice;
            self.a_id=tonumber(self.dodice.angel_id);
            self.angel_star=tonumber(self.dodice.angel_star);
            self.diceContent=self.dodice.content;
            self.grid=tonumber(self.dodice.grid);
            -- 
            local is_reset=self.dodice.is_reset;
            if tonumber(is_reset)==1 then
                -- 重置骰子位置
                self.oldGrid=1;
                local gridDb=self.gridDbDatas[1];
                local str_list=spliteStr(gridDb.pos,',');
                local pos=cc.p(tonumber(str_list[1]),tonumber(str_list[2]));
                self.roleNode:setPosition(pos.x,pos.y);
            end
            -- 
            local diceVal=tonumber(self.dodice.dice_num);
            self:playDiceEffect(diceVal);
      	else
          	NetHandler:showFailedMessage(netData);
            self:setNoCanClick(false);
      	end
    elseif msgId==Post_Cloud_Main_getTribute then
        -- 移掉供品图标
        local pos={}; 
        for i=1,#self.rewardImgTab do
            local tmpImg=self.rewardImgTab[i];
            local tagVal=tmpImg:getTag();
            if tagVal==#self.gridDbDatas+1 then
                pos=cc.p(tmpImg:getPositionX(),tmpImg:getPositionY());
                tmpImg:removeFromParentAndCleanup(true);
                table.remove(self.rewardImgTab,i);
                break
            end
        end
        -- 
        if netData.state == 1 then
            self:showMoveReward(netData.gettribute.reward,self.scrollView,pos);

            -- local size=cc.Director:getInstance():getWinSize();
            -- local pos=cc.p(size.width/2,size.height/2);
            -- self:showMoveReward(netData.gettribute.reward,cc.Director:getInstance():getRunningScene(),pos);
            -- local reward=netData.gettribute.reward;
            -- if string.len(reward)>0 then
            --     local itemPos={};
            --     local list=getneedlist(self.tribute_reward);
            --     local size=cc.Director:getInstance():getWinSize();
            --     local scaleVal=0.7;
            --     for i=1,#list do
            --         local item = resItem.create();
            --         item:setData(list[i].type,list[i].id);
            --         item:setScale(scaleVal);
            --         local pos=cc.p(size.width/2-160-item:getContentSize().width*#list*scaleVal/2+item:getContentSize().width*scaleVal/2,size.height/2);
            --         table.insert(itemPos,pos);
            --     end
            --     ItemJump:getInstance():showItemJump(reward,cc.Director:getInstance():getRunningScene(),itemPos,scaleVal,false);
            -- end
        else
            NetHandler:showFailedMessage(netData);
        end
	end
end

function CloudCMainLayer:getCloudGridDB()
    local sql=string.format("select * from cloud_grid where id=%d",self.grid);
    local DBData=LUADB.select(sql, "id:type:base_pic:des:pos");
    return DBData.info;
end

function CloudCMainLayer:loadCurPoint(grid_type)
	if string.len(self.diceContent)<=0 then
		return
	end
	if grid_type==3 then
        if self.openLayer==nil then
    		local AnswerPoint=require "AnswerPoint";
    	    self.openLayer=AnswerPoint.new(self);
    	    self:addChild(self.openLayer);
        end
	elseif grid_type==4 then
        if self.openLayer==nil then
    		local DivinationPoint=require "DivinationPoint";
    	    self.openLayer=DivinationPoint.new(self);
    	    self:addChild(self.openLayer);
        end
	elseif grid_type==5 then
        if self.openLayer==nil then
    		local TreasureBoxPoint=require "TreasureBoxPoint";
    	    self.openLayer=TreasureBoxPoint.new(self);
    	    self:addChild(self.openLayer);
        end
	elseif grid_type==6 then
        if self.openLayer==nil then
    		local DecisionPoint=require "DecisionPoint";
    	    self.openLayer=DecisionPoint.new(self);
    	    self:addChild(self.openLayer);
        end
    elseif grid_type==7 then
        if self.openLayer==nil then
    		local FightPoint=require "FightPoint";
    	    self.openLayer=FightPoint.new(self);
    	    self:addChild(self.openLayer);
        end
    elseif grid_type==8 then
        if self.openLayer==nil then
    		local RestingPoint=require "RestingPoint";
    	    self.openLayer=RestingPoint.new(self);
    	    self:addChild(self.openLayer);
        end
    elseif grid_type==9 then
        if self.openLayer==nil then
    		local PrayerPoint=require "PrayerPoint";
    	    self.openLayer=PrayerPoint.new(self);
    	    self:addChild(self.openLayer);
        end
    elseif grid_type==10 then
        if self.openLayer==nil then
    		local BlessingPoint=require "BlessingPoint";
    	    self.openLayer=BlessingPoint.new(self);
    	    self:addChild(self.openLayer);
        end
	end
end

function CloudCMainLayer:closeBtnClick(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		if self.main then
            self.main:openCloudCMain(false);
        end
	end
end

function CloudCMainLayer:shopBtnClick(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
        self:setRemoteDiceRect(false);
	    -- 
        require "shopLayer"
        shopLayer.showBox(self,8);
	end
end

function CloudCMainLayer:batchDiceBtnClick(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
        -- 10连摇最多可以使用的次数
        self.maxUseNum=tonumber(self.user_cloud.dice);
        if self.maxUseNum>=10 then
            self.maxUseNum=10;
        end
        self:sendUseDice();
    end
end

function CloudCMainLayer:sendUseDice()
    print("self.curUseNum===",self.curUseNum)
    print("self.maxUseNum===",self.maxUseNum)
    if self.curUseNum<=self.maxUseNum then
        self.curUseNum=self.curUseNum+1;
        self:sendDoDice(2,0);
        self.isBatchIng=true;
    else
        self.curUseNum=0;
        self.maxUseNum=1;
        self.isBatchIng=false;
    end
end

function CloudCMainLayer:normalDiceBtnClick(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		self:sendDoDice(1,0);
	end
end

function CloudCMainLayer:remoteDiceBtnClick(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
        self:setRemoteDiceRect(true);
		self.cell_num=6;
	    self:createTableView();
	end
end

function CloudCMainLayer:sendDoDice(type,dice)
    self:setRemoteDiceRect(false);
	-- type/1单次2多次
	local str=string.format("&type=%d&dice=%d",type,dice);
	NetHandler:sendData(Post_Cloud_Main_doDice, str);
    self:setNoCanClick(true);
end

function CloudCMainLayer:showAngelInfo(img_bubble,img_angel,img_name,node,isRight)
    if img_bubble then
        local sx=10;
        local width=204;
        local gridDb=self:getCloudGridDB();
        local tipsLabel=cc.Label:createWithTTF(gridDb.des, ttf_msyh, 20);
        tipsLabel:setDimensions(width-sx*2, 0);
        tipsLabel:setAnchorPoint(cc.p(0, 1));
        tipsLabel:setColor(cc.c3b(115, 0, 2));
        img_bubble:addChild(tipsLabel);
        -- 
        local height=tipsLabel:getContentSize().height;
        print("height==",height)
        if height>100 then
            height=height+50;
            img_bubble:setScale9Enabled(true);
            img_bubble:setCapInsets(cc.rect(40, 70, 1, 1));
            img_bubble:setSize(cc.size(width,height));
        end
        tipsLabel:setPosition(cc.p(sx, img_bubble:getContentSize().height-10));
    end
    -- 
	if self.a_id<=0 then
        print("出错了")
		self.a_id=1;
	end
    -- self.a_id=2;
    -- self.angel_star=5;

	local sql=string.format("select * from angel where id=%d",self.a_id);
    local tmpDb=LUADB.select(sql, "pic:name_pic");
    local angelDb=tmpDb.info;
    local bigPic=angelDb.pic..".png";
    local namePic=angelDb.name_pic..".png";
    MGRCManager:cacheResource("CloudCMainLayer",bigPic);
    MGRCManager:cacheResource("CloudCMainLayer",namePic);
    img_angel:loadTexture(bigPic, ccui.TextureResType.plistType);
    img_angel:setScale(0.8);
    img_name:loadTexture(namePic, ccui.TextureResType.plistType);
    -- img_name:setAnchorPoint(0,0.5);
    -- img_name:setPositionX(node:getPositionX());
    node:removeAllChildren();
    self:showAngelStar(node,self.angel_star,isRight);
end

function CloudCMainLayer:showAngelStar(node,starLv,isRight)
    for i=1,starLv do
        local starImg=ccui.ImageView:create("com_angel_star.png", ccui.TextureResType.plistType);
        if isRight then
	        starImg:setAnchorPoint(1,0.5);
	        starImg:setPosition(cc.p(node:getContentSize().width-(starImg:getContentSize().width-7)*(i-1), node:getContentSize().height/2));
	    else
	    	starImg:setAnchorPoint(0,0.5);
	        starImg:setPosition(cc.p((starImg:getContentSize().width-7)*(i-1), node:getContentSize().height/2));
	    end
        node:addChild(starImg);
    end
end

function CloudCMainLayer:createTableView()
    if self.tabView==nil then
        self.tabView = cc.TableView:create(self.panel_20:getContentSize())
        self.tabView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.tabView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self.panel_20:addChild(self.tabView)

        local function cellSizeForTable(view, idx)
            return 76,126
        end
        local function numberOfCellsInTableView(view)
            return self.cell_num
        end
        local l_tag = 888
        local function tableCellAtIndex(view, idx)
            local cell = view:dequeueCell()
            if not cell then
                cell = cc.TableViewCell:new()
            end
            local selCell = cell:getChildByTag(l_tag)
            if not selCell then
                selCell = RemoteDiceItem.new();
                NodeListener(selCell);
                selCell:setTag(l_tag)
                cell:addChild(selCell)
            end
            selCell:initData(self,idx+1);
            return cell
        end
        local function tableCellTouched(table, cell)
        end
        self.tabView:setDelegate();
        self.tabView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX);
        self.tabView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX);
        self.tabView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW);
        self.tabView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED);
    end
    if self.tabView then
        self.tabView:reloadData();
    end
end

function CloudCMainLayer:updateSetInfo(set_info)
    self.set_info=set_info;
end

function CloudCMainLayer:closeOpenLayer()
    if self.openLayer then
        self.openLayer:removeFromParentAndCleanup(true);
        self.openLayer=nil;
    end
    -- print("self.isBatchIng====",self.isBatchIng)
    if self.isBatchIng then
        self:sendUseDice();
    end
end

function CloudCMainLayer:closeOpenRReward()
    self:startJump();
end

function CloudCMainLayer:clickRDiceItem(index)
    -- print("clickRDiceItem111 index === ", index)
    if self.tabView:isVisible() then
        -- print("clickRDiceItem2222 index === ", index)
    	self:sendDoDice(1,index);
    end
end

-- 初始化地图
function CloudCMainLayer:initMap()
    local size=cc.Director:getInstance():getWinSize();
    self.m_pMapLayer=cc.Layer:create();
    self.pWidget:addChild(self.m_pMapLayer,0);
    self.m_pMapLayer:setPosition(0,0);
    self.m_pMapLayer:setContentSize(size);

    self.m_pBgMap=cc.Sprite:createWithSpriteFrameName("cloudcity_main_bg.jpg");
    local layerMap=cc.Layer:create();
    layerMap:setContentSize(self.m_pBgMap:getContentSize());
    layerMap:addChild(self.m_pBgMap);
    self.m_pBgMap:setPosition(0,0);
    self.m_pBgMap:setAnchorPoint(0,0);
    self.scrollView=MGMapScrollView.create();
    self.m_pMapLayer:addChild(self.scrollView);

    self.scrollView:setMinMaxScale(1,1);
    -- self.scrollView:setZoomScale(sc,true);
    self.scrollView:setContainer(layerMap);
    self.scrollView:setViewSize(size);
    self.scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_BOTH);
    self.scrollView:setBounceable(false);
    self.scrollView:setMapDelegate(self);
    self.scrollView:setPosition(0,0);
    self.scrollView:getContainer():setPosition(size.width/2-self.m_pBgMap:getContentSize().width/2,size.height/2-self.m_pBgMap:getContentSize().height/2-20);

    self:loadPointPos();
end

function CloudCMainLayer:loadPointPos()
    local sql="select * from cloud_grid";
    local DBData=LUADB.selectlist(sql, "id:type:base_pic:pos:reward_pic:building_name:building_pos:is_flip");
    self.gridDbDatas=DBData.info;
    
    for i=1,#self.gridDbDatas do
        local gridDb=self.gridDbDatas[i];
        local picName=gridDb.base_pic..".png";
        local baseImg=ccui.ImageView:create(picName, ccui.TextureResType.plistType);
        local str_list=spliteStr(gridDb.pos,',');
        baseImg:setPosition(cc.p(tonumber(str_list[1]),tonumber(str_list[2])));
        self.scrollView:getContainer():addChild(baseImg,100);
        -- 建筑
        local buildName=gridDb.building_name;
        if string.len(buildName)>0 then
            buildName=buildName..".png"
            MGRCManager:cacheResource("CloudCMainLayer",buildName);
            local buildImg=ccui.ImageView:create(buildName, ccui.TextureResType.plistType);
            str_list=spliteStr(gridDb.building_pos,',');
            buildImg:setPosition(cc.p(tonumber(str_list[1]),tonumber(str_list[2])));
            buildImg:setTag(i);
            self.scrollView:getContainer():addChild(buildImg,1);
            table.insert(self.buildImgTab,buildImg);
        end
        -- 奖励
        local rewardName=gridDb.reward_pic;
        if string.len(rewardName)>0 then
            rewardName=rewardName..".png"
            -- print("rewardName===",rewardName)
            MGRCManager:cacheResource("CloudCMainLayer",rewardName);
            local rewardImg=ccui.ImageView:create(rewardName, ccui.TextureResType.plistType);
            -- rewardImg:setPosition(cc.p(baseImg:getPositionX(),baseImg:getPositionY()+20));
            rewardImg:setTag(i);
            self.scrollView:getContainer():addChild(rewardImg,200);
            table.insert(self.rewardImgTab,rewardImg);
            -- 2和3类型的不跳
            local gridType=tonumber(gridDb.type);
            if gridType~=2 and gridType~=3 then
                rewardImg:setPosition(cc.p(baseImg:getPositionX(),baseImg:getPositionY()+20));
                local moveDown=cc.MoveBy:create(0.3, cc.p(0, -6));
                local moveUp=cc.MoveBy:create(0.3, cc.p(0, 6));
                local seq=cc.Sequence:create(moveDown,moveUp);
                rewardImg:runAction(cc.RepeatForever:create(seq));
            else
                rewardImg:setPosition(cc.p(baseImg:getPositionX(),baseImg:getPositionY()+12));
                if gridType==2 then
                    -- 宝箱的不能点击
                    rewardImg:setTag(0);
                end
            end
        end
    end
    -- 至高殿堂
    local buildName="CloudCity_SupremeTemple.png";
    MGRCManager:cacheResource("CloudCMainLayer",buildName);
    local buildImg=ccui.ImageView:create(buildName, ccui.TextureResType.plistType);
    buildImg:setPosition(cc.p(828,520));
    buildImg:setTag(#self.gridDbDatas+1);
    self.scrollView:getContainer():addChild(buildImg);
    table.insert(self.buildImgTab, buildImg);
    -- 贡品图标
    local rewardImg=ccui.ImageView:create("main_icon_masonry.png", ccui.TextureResType.plistType);
    rewardImg:setPosition(cc.p(buildImg:getPositionX(),buildImg:getPositionY()+50));
    rewardImg:setTag(#self.gridDbDatas+1);
    self.scrollView:getContainer():addChild(rewardImg);
    rewardImg:setVisible(false);
    table.insert(self.rewardImgTab,rewardImg);
end

function CloudCMainLayer:showTributeReward()
    if string.len(self.tribute_reward)>0 then
        for i=1,#self.rewardImgTab do
            local tmpImg=self.rewardImgTab[i];
            local tagVal=tmpImg:getTag();
            if tagVal==#self.gridDbDatas+1 then
                tmpImg:setVisible(true);
                break
            end
        end
    end
end

function CloudCMainLayer:initRolePos()
    if self.roleNode==nil then
        self.roleNode=cc.Node:create();
        self.scrollView:getContainer():addChild(self.roleNode,300);

        local roleSp=cc.Sprite:createWithSpriteFrameName("CloudCity_Flag.png");
        -- roleSp:setScale(0.2);
        roleSp:setPosition(0,roleSp:getContentSize().height/2-11);
        self.roleNode:addChild(roleSp,0,10);
        
        -- self.grid=1;
        self.oldGrid=self.grid;

        local gridDb=self:getCloudGridDB();
        local str_list=spliteStr(gridDb.pos,',');
        local pos=cc.p(tonumber(str_list[1]),tonumber(str_list[2]));
        self.roleNode:setPosition(pos.x,pos.y);
    end
end

function CloudCMainLayer:setRolePos()
    if self.roleNode then
        -- print("self.jumpIndex===",self.jumpIndex)
        -- print("#self.movePosTab===",#self.movePosTab)
        -- if self.jumpIndex<=#self.movePosTab then
            local pos=self.movePosTab[self.jumpIndex];
            -- self.jumpIndex=self.jumpIndex+1;
            -- self.roleNode:setPosition(pos.x,pos.y);
            local move=cc.MoveTo:create(0.3, cc.p(pos.x,pos.y));
            local delay=cc.DelayTime:create(0.15);
            local callFunc=cc.CallFunc:create(handler(self,self.startJump));
            local seq=cc.Sequence:create(move,delay,callFunc);
            self.roleNode:runAction(seq);
            -- 
            self:updateMapPos();
        -- else
        -- end
    end
end

function CloudCMainLayer:moveRole()
    -- print("self.oldGrid==",self.oldGrid)
    -- print("self.grid==",self.grid)
    self.jumpIndex=0;
    self.movePosTab={};
    local smallTab={};
    for i=1,#self.gridDbDatas do
        local gridDb=self.gridDbDatas[i];
        local isOk=false;
        if self.grid>self.oldGrid then
            if tonumber(gridDb.id)>self.oldGrid and tonumber(gridDb.id)<=self.grid then
                local str_list=spliteStr(gridDb.pos,',');
                local pos=cc.p(tonumber(str_list[1]),tonumber(str_list[2]));
                table.insert(self.movePosTab,pos);
            end
        else
            if tonumber(gridDb.id)>self.oldGrid and tonumber(gridDb.id)<=#self.gridDbDatas then
                -- 加格子数大的点
                local str_list=spliteStr(gridDb.pos,',');
                local pos=cc.p(tonumber(str_list[1]),tonumber(str_list[2]));
                table.insert(self.movePosTab,pos);
            elseif tonumber(gridDb.id)<=self.grid then
                -- 加格子数小的点
                local str_list=spliteStr(gridDb.pos,',');
                local pos=cc.p(tonumber(str_list[1]),tonumber(str_list[2]));
                table.insert(smallTab,pos);
            end
        end
    end
    for i=1,#smallTab do
        table.insert(self.movePosTab,smallTab[i]);
    end
    self.oldGrid=self.grid;
    -- 
    local roleSp=self.roleNode:getChildByTag(10);
    roleSp:stopAllActions();
    self:startJump();
end

function CloudCMainLayer:startJump()
    -- 完成一圈的奖励 路过起点或者停留在起点时候会有值
    local circle_reward=self.dodice.circle_reward;
    if string.len(circle_reward)>0 and self.jumpIndex>0 then
        local pos=self.movePosTab[self.jumpIndex];
        local gridDb=self.gridDbDatas[1];
        local str_list=spliteStr(gridDb.pos,',');
        local pos2=cc.p(tonumber(str_list[1]),tonumber(str_list[2]));
        -- 到第1格算一轮完，弹奖励
        if pos.x==pos2.x and pos.y==pos2.y then
            -- 刷新数据
            self:initData(self.user_cloud);
            local RoundReward=require "RoundReward";
            local reward=RoundReward.new(self,circle_reward,self.user_cloud.circle_add);
            self:addChild(reward);
            self.dodice.circle_reward="";
            return
        end
    end
    -- 
    self.jumpIndex=self.jumpIndex+1;
    if self.jumpIndex<=#self.movePosTab then
        local roleSp=self.roleNode:getChildByTag(10);
        local moveDown=cc.MoveBy:create(0.05, cc.p(0, -6));
        local jump=cc.JumpBy:create(0.3, cc.p(0,0), 30, 1);
        local moveUp=cc.MoveBy:create(0.05, cc.p(0, 6));
        local seq=cc.Sequence:create(moveDown,jump,moveUp);
        roleSp:runAction(seq);
        -- 
        self:setRolePos();
    else
        -- print("111122333")
        self:setNoCanClick(false);
        self.roleNode:stopAllActions();
        -- 
        local gridDb=self:getCloudGridDB();
        local grid_type=tonumber(gridDb.type);
        self:loadCurPoint(grid_type);
        -- 
        self:initData(self.user_cloud);
        -- 
        -- 处理自动完成的奖励
        local coin=self.dodice.get_coin;
        local stone=self.dodice.get_stone;
        self:changeTopInfo(coin,stone);
        -- local pos=cc.p(self.roleNode:getPositionX(),self.roleNode:getPositionY());
        -- local point=self.pWidget:convertToWorldSpace(cc.p(self.roleNode:getPositionX(),self.roleNode:getPositionY()));
        local pos=cc.p(self.roleNode:getPositionX(),self.roleNode:getPositionY());
        -- cc.p(point.x,point.y);
        self:showMoveReward(self.dodice.grid_reward,self.scrollView,pos);
        -- 
        if table.getn(self.dodice.g_ids)>0 then
            self.add_exp=self.dodice.add_exp;
            self.g_ids=self.dodice.g_ids;
            self.index=1;
            self:loadUpHeadInfo();
            local function updateTimef(dt)
                if self.index>#self.g_ids then
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
                else
                    self:loadUpHeadInfo();
                end
            end
            if self.schedulerID then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
            end
            self.schedulerID=cc.Director:getInstance():getScheduler():scheduleScriptFunc(updateTimef, 1.0, false);
        end
        -- 
        if self.openLayer==nil then
            if self.isBatchIng then
                self:sendUseDice();
            end
        end
    end
end

function CloudCMainLayer:showMoveReward(reward,node,pos)
    local size=cc.Director:getInstance():getWinSize();
    local isLeft=false;
    if pos.x>=size.width/2 then
        isLeft=true;
    end
    if string.len(reward)>0 then
        local itemPos={};
        local list=getneedlist(reward);
        local scaleVal=0.7;
        for i=1,#list do
            local item = resItem.create();
            item:setData(list[i].type,list[i].id);
            item:setScale(scaleVal);
            -- local tmpPos=cc.p(pos.x-160-item:getContentSize().width*#list*scaleVal/2+item:getContentSize().width*scaleVal/2,pos.y);
            local tmpPos=cc.p(pos.x-item:getContentSize().width*#list*scaleVal/2+item:getContentSize().width*scaleVal,pos.y);
            if isLeft==false then
                tmpPos=cc.p(pos.x+item:getContentSize().width*#list*scaleVal/2-item:getContentSize().width*scaleVal,pos.y);
            end
            table.insert(itemPos,tmpPos);
        end
        ItemJump:getInstance():showItemJump(reward,node,itemPos,scaleVal,isLeft);
    end
end

function CloudCMainLayer:loadUpHeadInfo()
    local upStr=string.format("%s+%d",MG_TEXT("PrayerPoint_2"),self.add_exp);
    local data=GENERAL:getGeneralModel(self.g_ids[self.index]);
    local headItem=HeroHeadEx.create(self);
    headItem:setData(data);

    local nameLabel=cc.Label:createWithTTF(data:name(), ttf_msyh, 22);
    nameLabel:setAnchorPoint(0.5,1);
    nameLabel:setPosition(headItem:getContentSize().width/2,0);
    nameLabel:setColor(ResourceData:getTitleColor(data:getQuality()));
    headItem:addChild(nameLabel);

    local size=cc.Director:getInstance():getWinSize();
    local pos=cc.p(size.width/2,size.height/2);
    FloatUpMessage:getInstance():showUpItem(headItem,upStr,cc.Director:getInstance():getRunningScene(),pos);
    self.index=self.index+1
end

function CloudCMainLayer:updateMapPos()
    local ptOffsetInView=self.scrollView:getContentOffset();
    local fHeroInLayerY=self.roleNode:getPositionY()+ptOffsetInView.y+self.scrollView:getPositionY();
    local fHeroInLayerX=self.roleNode:getPositionX()+ptOffsetInView.x+self.scrollView:getPositionX();
    local szLayer=self.m_pMapLayer:getContentSize();
    local fMoveY=szLayer.height/2-fHeroInLayerY;
    local fMoveX=szLayer.width/2-fHeroInLayerX;
    ptOffsetInView.y=ptOffsetInView.y+fMoveY;
    -- ptOffsetInView.x=ptOffsetInView.x+fMoveX;
    self.scrollView:setContentOffset(ptOffsetInView);
end

function CloudCMainLayer:mapScrollViewkMove(view)
    print("333333333")
end

function CloudCMainLayer:mapScrollViewClick(view)
    self:setRemoteDiceRect(false);
    local pt=view.nowpt;
    -- print("pt.x==",pt.x)
    -- print("pt.y==",pt.y)
    -- 
    for i=1,#self.rewardImgTab do
        local tmpImg=self.rewardImgTab[i];
        local x=tmpImg:getPositionX()-tmpImg:getContentSize().width/2;
        local y=tmpImg:getPositionY()-tmpImg:getContentSize().height/2;
        local rect=cc.rect(x,y,tmpImg:getContentSize().width,tmpImg:getContentSize().height);
        if cc.rectContainsPoint(rect,pt) then
            local tagVal=tmpImg:getTag();
            print("1111111rewardImgTab==",tagVal)
            if tagVal==#self.gridDbDatas+1 then
                -- 特殊处理的
                if tmpImg:isVisible() then
                    NetHandler:sendData(Post_Cloud_Main_getTribute, "");
                end
            else
                if tagVal>0 then
                    self:openHopeGarden(tagVal);
                end
            end
            return
        end
    end
    -- 
    for i=1,#self.buildImgTab do
        local tmpImg=self.buildImgTab[i];
        local x=tmpImg:getPositionX()-tmpImg:getContentSize().width/2;
        local y=tmpImg:getPositionY()-tmpImg:getContentSize().height/2;
        local rect=cc.rect(x,y,tmpImg:getContentSize().width,tmpImg:getContentSize().height);
        -- print("x==",x)
        -- print("y==",y)
        -- print("w==",tmpImg:getContentSize().width)
        -- print("h==",tmpImg:getContentSize().height)
        if cc.rectContainsPoint(rect,pt) then
            local tagVal=tmpImg:getTag();
            print("1111111buildImg==",tagVal)
            if tagVal==#self.gridDbDatas+1 then
                -- 特殊处理的
                if self.openLayer==nil then
                    local SupremePalace=require "SupremePalace";
                    self.openLayer=SupremePalace.new(self);
                    self:addChild(self.openLayer);
                end
            else
                self:openHopeGarden(tagVal);
            end
            return
        end
    end
end

function CloudCMainLayer:openHopeGarden(tagVal)
    if self.openLayer==nil then
        local HopeGarden=require "HopeGarden";
        self.openLayer=HopeGarden.new(self,tagVal,self.set_info);
        self:addChild(self.openLayer);
    end
end

function CloudCMainLayer:onEnter()
	NetHandler:addAckCode(self,Post_Cloud_Main_cloudMain);
	NetHandler:addAckCode(self,Post_Cloud_Main_doDice);
    NetHandler:addAckCode(self,Post_Cloud_Main_getTribute);
end

function CloudCMainLayer:onExit()
    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
    end
    self.scrollView:destroy();
	NetHandler:delAckCode(self,Post_Cloud_Main_cloudMain);
	NetHandler:delAckCode(self,Post_Cloud_Main_doDice);
    NetHandler:delAckCode(self,Post_Cloud_Main_getTribute);
	MGRCManager:releaseResources("CloudCMainLayer");
end

function CloudCMainLayer:setManager(manager)
    self.manager=manager;
end

return CloudCMainLayer;