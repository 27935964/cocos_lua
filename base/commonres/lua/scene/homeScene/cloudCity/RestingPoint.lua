----云中城休息点界面----
-- require "FloatUpMessage";
local RestingPoint=class("RestingPoint",function()
	return cc.Layer:create();
end);

function RestingPoint:ctor(delegate)
  	self.delegate=delegate;
    self.diceContent=delegate.diceContent;
    -- 
    MGRCManager:cacheResource("RestingPoint","eff_yunzhongcheng_yaoping_1.png","eff_yunzhongcheng_yaoping_1.plist");
    MGRCManager:cacheResource("RestingPoint","eff_yunzhongcheng_yaoping_2.png","eff_yunzhongcheng_yaoping_2.plist");

  	self.pWidget=MGRCManager:widgetFromJsonFile("RestingPoint", "CloudCity_RestingPoint_Ui.ExportJson");
  	self:addChild(self.pWidget);

  	local panel_2 = self.pWidget:getChildByName("Panel_2");--Panel
    self.panel_3=self.pWidget:getChildByName("Panel_3");
    self:setNoCanClick(false);

  	self.button_drink=panel_2:getChildByName("Button_Drink");--Button
  	self.button_drink:addTouchEventListener(handler(self,self.drankBtnClick));

    local label_drink=self.button_drink:getChildByName("Label_Drink");
    label_drink:setText(MG_TEXT_COCOS("RestingPoint_Ui_2"));
    -- 
    self.img_projection=panel_2:getChildByName("Image_Projection");
    self.img_projection:loadTexture("CloudCity_RestingPoint_HolyWater_White.png", ccui.TextureResType.plistType);
    -- tips
    self.img_bubble=panel_2:getChildByName("Image_Bubble");
    -- 图片
    self.img_angel=panel_2:getChildByName("Image_Angel");
    -- 名称 
    self.img_name=panel_2:getChildByName("Image_23");
    -- 星级
    self.panel_24=panel_2:getChildByName("Panel_24");
    -- 
    local label_restingPoints=panel_2:getChildByName("Label_RestingPoints");
    label_restingPoints:setText(MG_TEXT_COCOS("RestingPoint_Ui_1"));
    -- 
   	NodeListener(self);
    -- 
    self:initData();
    --
    -- 
    -- local Panel_1 = self.pWidget:getChildByName("Panel_1")
    -- local function closeClick(sender,eventType)
    --     if eventType == ccui.TouchEventType.ended then
    --         self:removeFromParentAndCleanup(true);
    --     end
    -- end
    -- Panel_1:addTouchEventListener(closeClick)
end

function RestingPoint:setNoCanClick(isVisible)
    self.panel_3:setTouchEnabled(isVisible);
end

function RestingPoint:initData()
    if self.delegate then
        self.delegate:showAngelInfo(self.img_bubble,self.img_angel,self.img_name,self.panel_24,false);
    end
    if self.anim_2==nil then
        self.anim_2=cc.Sprite:create();
        self.anim_2:setPosition(cc.p(self.img_projection:getContentSize().width/2, self.img_projection:getContentSize().height/2));
        self.img_projection:addChild(self.anim_2);
        local action=fuGetAnimate("eff_yunzhongcheng_yaoping_2_",1,14,0.166,true);
        self.anim_2:runAction(action);
    end
end

function RestingPoint:drankBtnClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        NetHandler:sendData(Post_Cloud_Main_doRest, "");
        -- 
        MGGraySprite:graySprite(self.button_drink:getVirtualRenderer());
        self.button_drink:setTouchEnabled(false);
        self:setNoCanClick(true);
    end
end

function RestingPoint:onReciveData(msgId, netData)
	  if msgId == Post_Cloud_Main_doRest then
      	if netData.state == 1 then
            local phyVal=tonumber(self.diceContent);
            local cloud_holy_num=LUADB.readConfig(203);
            local str_list=spliteStr(cloud_holy_num,':');
            local picName="CloudCity_RestingPoint_HolyWater_White.png";
            if phyVal>=tonumber(str_list[5]) then
                picName="CloudCity_RestingPoint_HolyWater_Orange.png";
            elseif phyVal>=tonumber(str_list[4]) then
                picName="CloudCity_RestingPoint_HolyWater_Purple.png";
            elseif phyVal>=tonumber(str_list[3]) then
                picName="CloudCity_RestingPoint_HolyWater_Blue.png";
            elseif phyVal>=tonumber(str_list[2]) then
                picName="CloudCity_RestingPoint_HolyWater_Green.png";
            end
            -- 
            if self.anim_1==nil then
                self.anim_1=cc.Sprite:create();
                self.anim_1:setPosition(cc.p(self.img_projection:getContentSize().width/2, self.img_projection:getContentSize().height/2));
                self.img_projection:addChild(self.anim_1);
                local action=fuGetAnimate("eff_yunzhongcheng_yaoping_1_",1,15,0.166);
                local function remove()
                    self:removeAnim1();
                    self.img_projection:loadTexture(picName, ccui.TextureResType.plistType);
                    -- 往上飘
                    local upStr=string.format("+%d",phyVal);
                    local pos=cc.p(self.img_projection:getContentSize().width/2,self.img_projection:getContentSize().height/2);
                    FloatUpMessage:getInstance():showUpMessage("main_icon_action.png",upStr,self.img_projection,pos);
                    -- 往上飘的完就关闭
                    local function delayClose()
                        self:closeResting();
                    end
                    local delay=cc.DelayTime:create(2.0);
                    local callFunc=cc.CallFunc:create(delayClose);
                    self:runAction(cc.Sequence:create(delay,callFunc));
                    
                end
                local func=cc.CallFunc:create(remove)
                local seq=cc.Sequence:create(action,func);
                self.anim_1:runAction(seq);
            end
      	else
          	NetHandler:showFailedMessage(netData);
      	end
  	end
end

function RestingPoint:closeResting()
    if self.delegate then
        self.delegate:closeOpenLayer();
    end
end

function RestingPoint:removeAnim1()
    if self.anim_1 then
        self.anim_1:stopAllActions();
        self.anim_1:removeFromParent(true);
        self.anim_1=nil;
    end
end

function RestingPoint:removeAnim2()
    if self.anim_2 then
        self.anim_2:stopAllActions();
        self.anim_2:removeFromParent(true);
        self.anim_2=nil;
    end
end

function RestingPoint:onEnter()
    NetHandler:addAckCode(self,Post_Cloud_Main_doRest);
end

function RestingPoint:onExit()
    self:removeAnim1();
    self:removeAnim2();
	NetHandler:delAckCode(self,Post_Cloud_Main_doRest);
	MGRCManager:releaseResources("RestingPoint");
end

return RestingPoint;
