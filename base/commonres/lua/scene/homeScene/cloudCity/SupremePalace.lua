----云中城至高殿堂界面----

require "MGMapScrollView"
----云中城天使Item界面----
AngelHeadItem=class("AngelHeadItem", MGWidget)
AngelHeadItem.HEIGHT=192
AngelHeadItem.WIDTH=400

function AngelHeadItem:init()
    -- self.height=192;
    -- local sy=self.height/2;

    self.headImg=ccui.ImageView:create("angel_headpic_1.png", ccui.TextureResType.plistType); 
    self.headImg:setAnchorPoint(cc.p(0.5,0));
    self.headImg:setPosition(self.WIDTH/2,0);
    self.headImg:setScaleY(self.HEIGHT/self.headImg:getContentSize().height)
    self:addChild(self.headImg);
    self.headImg:setTouchEnabled(true);
    self.headImg:addTouchEventListener(handler(self,self.headBtnClick));

    self:setContentSize(cc.size(self.WIDTH,self.HEIGHT));
end

function AngelHeadItem:headBtnClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        if self.delegate then
            self.delegate:clickHeadBack(self.angelDb);
        end
    end
end

function AngelHeadItem:setData(angelDb,unactivated)
    self.angelDb=angelDb;
    local headName=angelDb.angle_head..".png";
    MGRCManager:cacheResource("AngelHeadItem",headName);
    self.headImg:loadTexture(headName, ccui.TextureResType.plistType);
    -- 
    if unactivated then
        MGGraySprite:graySprite(self.headImg:getVirtualRenderer());
    end
end

function AngelHeadItem:onEnter()
end

function AngelHeadItem:onExit()
    MGRCManager:releaseResources("AngelHeadItem");
end

function AngelHeadItem.create(delegate)
    local layer = AngelHeadItem:new()
    layer.delegate = delegate
    layer:init()
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

------------------------------------------------------------
------------------------------------------------------------
local SupremePalace=class("SupremePalace",function()
	return cc.Layer:create();
end);

function SupremePalace:ctor(delegate)
  	self.delegate=delegate;
    -- 1激活／2升星／3转生／4升级
    self.curType=1;
    self.angelData=nil;
    self.skillTab={};
    self.angellist=nil;
    self.effectSp=nil;

    MGRCManager:cacheResource("SupremePalace","supremePalace_bg.jpg");
    MGRCManager:cacheResource("SupremePalace","eff_ui_jinjiechenggong.png","eff_ui_jinjiechenggong.plist");
    MGRCManager:cacheResource("SupremePalace","angel_1.png");
    MGRCManager:cacheResource("SupremePalace","angel_name_2.png");

    local size = cc.Director:getInstance():getWinSize();
    local bgSpr = cc.Sprite:create("supremePalace_bg.jpg");
    bgSpr:setPosition(cc.p(size.width/2, size.height));
    bgSpr:setAnchorPoint(cc.p(0.5,1));
    self:addChild(bgSpr);

  	self.pWidget=MGRCManager:widgetFromJsonFile("SupremePalace", "CloudCity_SupremePalace.ExportJson");
  	self:addChild(self.pWidget);

    self.pPanelTop = PanelTop.create(self)
    self.pPanelTop:setData("CloudCity_SupremePalaceTitle.png");
    self.pPanelTop:showRankCoin(true);
    self:addChild(self.pPanelTop,10);

  	local panel_2=self.pWidget:getChildByName("Panel_2");--Panel
    self.list=panel_2:getChildByName("ListView_16");
    -- 图片
    self.img_angel=panel_2:getChildByName("Image_Angel");
    -- 名称
    self.img_name=panel_2:getChildByName("Image_AngelName");
    -- 星级
    self.panel_18=panel_2:getChildByName("Panel_18");
    -- 激活按钮
  	self.button_op=panel_2:getChildByName("Button_Activation");--Button
  	self.button_op:addTouchEventListener(handler(self,self.opBtnClick));
    self.label_op=self.button_op:getChildByName("Label_Activation");
    -- 技能区域
    self.panel_skill=panel_2:getChildByName("Panel_AngelSkill");
    -- 激活需要消耗的 
    self.img_angelDebris=panel_2:getChildByName("Image_AngelDebris");
    self.label_debris=panel_2:getChildByName("Label_Debris_number");
    -- 
   	NodeListener(self);
    -- 
    self.curAngelId=1;
    self:initData();
    NetHandler:sendData(Post_Cloud_Angel_angelList, "");--初始化数据
end

-- 左上角的返回
function SupremePalace:back()
    self:closeSupremePalace();
end

function SupremePalace:initData()
    local sql="select * from angel";
    local DBData=LUADB.selectlist(sql, "id:skill:is_activity:need:pic:name:name_pic:head_pic:angle_head");
    self.angelDbDatas=DBData.info;
    -- self.angelNum=#self.angelDb;
end



function SupremePalace:loadHeadList()
    self.list:removeAllItems();
    self.itemTab={};
    local itemLay=ccui.Layout:create();
    local cell_num=table.getn(self.angelDbDatas);
    itemLay:setSize(cc.size(594, cell_num*AngelHeadItem.HEIGHT));
    for i=1,cell_num do
        local angelDb=self.angelDbDatas[i];
        local unactivated=true;
        for j=1,table.getn(self.angellist) do
            if tonumber(angelDb.id)==tonumber(self.angellist[j].a_id) then
                unactivated=false;
                break
            end
        end
        local item=AngelHeadItem.create(self);
        item:setData(angelDb,unactivated);
        item:setAnchorPoint(0.5,0.5);
        item:setPosition(AngelHeadItem.WIDTH/2,itemLay:getContentSize().height-i*AngelHeadItem.HEIGHT+AngelHeadItem.HEIGHT/2);
        itemLay:addChild(item);
        table.insert(self.itemTab,item)

    end
    
    -- self.list:addEventListenerScrollView(scrollEvent)
    self.list:pushBackCustomItem(itemLay);
    -- self.list:pushBackCustomItem(itemLay2);
end

function SupremePalace:getAngelDb(angelId)
    local angelDb=nil;
    for i=1,table.getn(self.angelDbDatas) do
        if tonumber(self.angelDbDatas[i].id)==angelId then
            angelDb=self.angelDbDatas[i];
            break
        end
    end
    return angelDb;
end

function SupremePalace:setChooseInfo()
    local angelDb=self:getAngelDb(self.curAngelId);
    local bigPic=angelDb.pic..".png";
    local namePic=angelDb.name_pic..".png";
    MGRCManager:cacheResource("SupremePalace",bigPic);
    MGRCManager:cacheResource("SupremePalace",namePic);
    self.img_angel:loadTexture(bigPic, ccui.TextureResType.plistType);
    self.img_name:loadTexture(namePic, ccui.TextureResType.plistType);
    -- 
    local starLv=0;
    if self.angelData then
        starLv=self.angelData.star;
    end
    self.panel_18:removeAllChildren();
    self:showAngelStar(self.panel_18,starLv);
    -- 
    local resData=ResourceTip.getInstance():getResData(angelDb.need);
    local hasNum=0;
    local good=RESOURCE:getResModelByItemId(resData.id);
    if good then
        hasNum=good:getNum();
    end
    self.label_debris:setText(string.format("%d/%d",resData.num,hasNum));
    self.angelSkillStr=angelDb.skill;
    -- 
    self.panel_skill:removeAllChildren();
    -- self.skillTab={};
    local str_list=spliteStr(angelDb.skill,'|');
    for i=1,#str_list do
        local skillStr=spliteStr(str_list[i],':');
        local sql=string.format("select pic from angel_skill where skill_id=%d",skillStr[1]);
        local skillDb=LUADB.select(sql, "pic");
        local iconName=skillDb.info.pic..".png";
        MGRCManager:cacheResource("SupremePalace",iconName);

        local kuanImg=ccui.ImageView:create("com_icon_circle_box.png", ccui.TextureResType.plistType); 
        kuanImg:setPosition(cc.p(5+(kuanImg:getContentSize().width+15)*(i-1)+kuanImg:getContentSize().width/2, self.panel_skill:getContentSize().height/2));
        self.panel_skill:addChild(kuanImg);

        local skillImg=ccui.ImageView:create(iconName, ccui.TextureResType.plistType); 
        skillImg:setPosition(kuanImg:getPosition());
        skillImg:setTouchEnabled(true);
        skillImg:addTouchEventListener(handler(self,self.skillBtnClick));
        self.panel_skill:addChild(skillImg);
        -- 
        local unactivated=true;
        if self.angelData then
            local skill_info=self.angelData.skill_info;
            local str_info=spliteStr(skill_info,'|');
            for j=1,#str_info do
                local str=spliteStr(str_info[j],':');
                if tonumber(str[1])==tonumber(skillStr[1]) then
                    if tonumber(str[2])>0 then
                        unactivated=false;
                    end
                    break
                end
            end
            if self.angelData.rebirth_lv>0 then
                unactivated=false;
            end
        end
        if unactivated then
            MGGraySprite:graySprite(skillImg:getVirtualRenderer());
        end
    end
    -- 活动获得的
    local isShow=true;
    local isActivity=self:isActivityAngel();
    if isActivity then
        isShow=false;
    end
    self.img_angelDebris:setVisible(isShow);
    self.label_debris:setVisible(isShow);
end

function SupremePalace:showAngelStar(node,starLv)
    if self.delegate then
        self.delegate:showAngelStar(node,starLv,true);
    end
    -- for i=1,starLv do
    --     local starImg=ccui.ImageView:create("com_angel_star.png", ccui.TextureResType.plistType);
    --     starImg:setAnchorPoint(1,0.5);
    --     starImg:setPosition(cc.p(node:getContentSize().width-(starImg:getContentSize().width-7)*(i-1), node:getContentSize().height/2));
    --     node:addChild(starImg);
    -- end
end

function SupremePalace:playEffect()
    self:removeEffectSp();
    if self.effectSp==nil then
        self.effectSp=cc.Sprite:create();
        self.effectSp:setPosition(cc.p(self.img_angel:getContentSize().width/2,self.img_angel:getContentSize().height/2));
        self.img_angel:addChild(self.effectSp);
        local action=fuGetAnimate("eff_ui_jinjiechenggong",1,20,0.08);
        self.effectSp:runAction(action);
    end
end

function SupremePalace:setOpName()
    if self.angelData then
        local angelMaxStar=LUADB.readConfig(129);
        angelMaxStar=tonumber(angelMaxStar);
        -- 先判断是否到转生阶段
        if self.angelData.star>=angelMaxStar then
            self.curType=3;
            -- 判断是转生还是升级
            if self.angelData.rebirth_lv>0 then
                local angelSkillMaxLv=LUADB.readConfig(130);
                angelSkillMaxLv=tonumber(angelSkillMaxLv);
                -- 所以的技能都升满了才能再转生
                local isFullMax=true;
                local skill_info=self.angelData.skill_info;
                local str_list=spliteStr(skill_info,'|');
                for i=1,#str_list do
                    local skillStr=spliteStr(str_list[i],':');
                    if tonumber(skillStr[2])<angelSkillMaxLv then
                        isFullMax=false;
                        break
                    end
                end
                if isFullMax==false then
                    self.curType=4;
                end
            end
        end
    end
    -- 
    local opNmae=MG_TEXT("SupremePalace_1");
    local isActivity=self:isActivityAngel();
    if isActivity then
        opNmae=MG_TEXT("chatLayer_6");
    else
        if self.curType==2 then
            opNmae=MG_TEXT("SupremePalace_2");
        elseif self.curType==3 then
            opNmae=MG_TEXT("SupremePalace_3");
        elseif self.curType==4 then
            opNmae=MG_TEXT("SupremePalace_4");
        end
    end
    self.label_op:setText(opNmae);
end

function SupremePalace:isActivityAngel()
    local angelDb=self:getAngelDb(self.curAngelId);
    if tonumber(angelDb.is_activity)==1 then
        return true;
    end
    return false;
end

function SupremePalace:openAngelSkill()
    local AngelSkill=require "AngelSkill";
    local angelSkill=AngelSkill.new(self);
    self:addChild(angelSkill,11);
end

function SupremePalace:skillBtnClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        self:openAngelSkill();
    end
end

function SupremePalace:opBtnClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local isActivity=self:isActivityAngel();
        if isActivity then
            self:openAngelSkill();
        else
            if self.curType==2 then
                local AngelRisingStar=require "AngelRisingStar";
                local angelRisingStar=AngelRisingStar.new(self);
                self:addChild(angelRisingStar,11);
            elseif self.curType==3 then
                local AngelTransmigration=require "AngelTransmigration";
                local angelTransmigration=AngelTransmigration.new(self);
                self:addChild(angelTransmigration,11);
            elseif self.curType==4 then
                self:openAngelSkill();
            else
                local str=string.format("&id=%d",self.curAngelId);
                NetHandler:sendData(Post_Cloud_Angel_unLockAngel, str);
            end
        end
    end
end

function SupremePalace:onReciveData(msgId, netData)
	  if msgId == Post_Cloud_Angel_angelList then
      	if netData.state == 1 then
            self.angellist=netData.angellist.user_angel;
            self:updataAngelData(self.angellist,false);
      	else
          	NetHandler:showFailedMessage(netData);
      	end
    elseif msgId == Post_Cloud_Angel_unLockAngel then
        if netData.state == 1 then
            self.angellist=netData.angellist.user_angel;
            self:updataAngelData(self.angellist,true);
        else
            NetHandler:showFailedMessage(netData);
        end
  	end
end

function SupremePalace:clickHeadBack(angelDb)
    self.curAngelId=tonumber(angelDb.id);
    self:refreshInfo();
end

function SupremePalace:updataAngelData(angellist,needPlay)
    self.angellist=angellist;
    self:loadHeadList();
    self:refreshInfo();
    -- 
    if needPlay then
        self:playEffect();
    end
end

function SupremePalace:refreshInfo()
    local num=table.getn(self.angellist);
    self.curType=1;
    self.angelData=nil;
    for i=1,num do
        if self.curAngelId==tonumber(self.angellist[i].a_id) then
            self.angelData=self.angellist[i];
            self.curType=2;
            break
        end
    end
    self:setOpName();
    self:setChooseInfo();
end

function SupremePalace:closeSupremePalace()
    if self.delegate then
        self.delegate:closeOpenLayer();
    end
end

function SupremePalace:removeEffectSp()
    if self.effectSp then
        self.effectSp:stopAllActions();
        self.effectSp:removeFromParent(true);
        self.effectSp=nil;
    end
end

function SupremePalace:onEnter()
    NetHandler:addAckCode(self,Post_Cloud_Angel_angelList);
    NetHandler:addAckCode(self,Post_Cloud_Angel_unLockAngel);
end

function SupremePalace:onExit()
	NetHandler:delAckCode(self,Post_Cloud_Angel_angelList);
    NetHandler:delAckCode(self,Post_Cloud_Angel_unLockAngel);
	MGRCManager:releaseResources("SupremePalace");
end

return SupremePalace;