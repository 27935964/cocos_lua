----云中城答题点界面----
-- require "ResourceTip";
-- require "ItemJump";
local AnswerPoint=class("AnswerPoint",function()
	return cc.Layer:create();
end);

function AnswerPoint:ctor(delegate)
  	self.delegate=delegate;
    self.diceContent=delegate.diceContent;
    self.scaleVal=0;
    -- 
  	self.pWidget=MGRCManager:widgetFromJsonFile("AnswerPoint", "CloudCity_AnswerPoint_Ui.ExportJson");
  	self:addChild(self.pWidget);

  	local panel_2 = self.pWidget:getChildByName("Panel_2");--Panel
    self.panel_2=panel_2;
    self.panel_3=self.pWidget:getChildByName("Panel_3");
    self:setNoCanClick(false);
    -- 问题
    self.label_questCont=panel_2:getChildByName("Label_QuestionContent");--Label 
    -- 奖励
    self.list=panel_2:getChildByName("ListView_Reward");
    -- 答案
    self.img_Chioce_A=panel_2:getChildByName("Image_Chioce_A");
    self.img_Chioce_A:setEnabled(false);
    self.img_Chioce_A:addTouchEventListener(handler(self,self.answerBtnClick));
    self.img_Chioce_B=panel_2:getChildByName("Image_Chioce_B");
    self.img_Chioce_B:setEnabled(false);
    self.img_Chioce_B:addTouchEventListener(handler(self,self.answerBtnClick));
    self.img_Chioce_C=panel_2:getChildByName("Image_Chioce_C");
    self.img_Chioce_C:setEnabled(false);
    self.img_Chioce_C:addTouchEventListener(handler(self,self.answerBtnClick));
    self.img_Chioce_D=panel_2:getChildByName("Image_Chioce_D");
    self.img_Chioce_D:setEnabled(false);
    self.img_Chioce_D:addTouchEventListener(handler(self,self.answerBtnClick));
    -- 图片
    self.img_angel=panel_2:getChildByName("Image_Angel");
    -- 名称 
    self.img_name=panel_2:getChildByName("Image_21");
    -- 星级
    self.panel_22=panel_2:getChildByName("Panel_22");
    -- 
    local label_question=panel_2:getChildByName("Label_Question");
    label_question:setText(MG_TEXT_COCOS("AnswerPoint_Ui_1"));

    local label_reward=panel_2:getChildByName("Label_Reward");
    label_reward:setText(MG_TEXT_COCOS("AnswerPoint_Ui_2"));

    local label_tips=panel_2:getChildByName("Label_Tips");
    label_tips:setText(MG_TEXT_COCOS("AnswerPoint_Ui_3"));
    -- 
    self.selspr=ccui.ImageView:create("com_selected_box.png", ccui.TextureResType.plistType);
    -- self.selspr:setScale9Enabled(true);
    -- self.selspr:setCapInsets(cc.rect(50, 50, 1, 1));
    -- self.selspr:setSize(cc.size(self.img_Chioce_A:getContentSize().width,self.selspr:getContentSize().height));
    self.selspr:setScaleX(self.img_Chioce_A:getContentSize().width/self.selspr:getContentSize().width);
    self.selspr:setScaleY(self.img_Chioce_A:getContentSize().height/self.selspr:getContentSize().height);
    panel_2:addChild(self.selspr);
    self.selspr:setVisible(false);
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

function AnswerPoint:setNoCanClick(isVisible)
    self.panel_3:setTouchEnabled(isVisible);
end

function AnswerPoint:initData()
    local answerId=tonumber(self.diceContent);
    local DBData = LUADB.select(string.format("select * from cloud_answer where id=%d",answerId), "question:answer_1:answer_2:answer_3:answer_4:reward");
    self.label_questCont:setText(DBData.info.question);
    -- 
    local resData=ResourceTip.getInstance():getResData(DBData.info.reward);
    self.list:removeAllItems();
    local itemLay = ccui.Layout:create();
    itemLay:setSize(cc.size(self.list:getContentSize().width, self.list:getContentSize().height));
    local item = resItem.create();
    item:setData(resData.type,resData.id,resData.num);
    itemLay:addChild(item);

    self.scaleVal=itemLay:getContentSize().height/item:getContentSize().height;
    item:setScale(self.scaleVal);
    item:setPosition(item:getContentSize().width/2*self.scaleVal,self.list:getContentSize().height/2);
    self.list:pushBackCustomItem(itemLay);
    -- 
    self.answerBtTab={};
    self.answerStr={};
    local answer_1 = DBData.info.answer_1;
    if string.len(answer_1)>0 then
        self.img_Chioce_A:setEnabled(true);
        table.insert(self.answerBtTab,self.img_Chioce_A);
        table.insert(self.answerStr,answer_1);
    end
    local answer_2 = DBData.info.answer_2;
    if string.len(answer_2)>0 then
        self.img_Chioce_B:setEnabled(true);
        table.insert(self.answerBtTab,self.img_Chioce_B);
        table.insert(self.answerStr,answer_2);
    end
    local answer_3 = DBData.info.answer_3;
    if string.len(answer_3)>0 then
        self.img_Chioce_C:setEnabled(true);
        table.insert(self.answerBtTab,self.img_Chioce_C);
        table.insert(self.answerStr,answer_3);
    end
    local answer_4 = DBData.info.answer_4;
    if string.len(answer_4)>0 then
        self.img_Chioce_D:setEnabled(true);
        table.insert(self.answerBtTab,self.img_Chioce_D);
        table.insert(self.answerStr,answer_4);
    end
    -- 
    local num = table.getn(self.answerBtTab);
    if num>0 then
        local s = self:RandomIndex(num,num);
        for i=1,num do
            local btn_answer=self.answerBtTab[i];
            local label_answer=btn_answer:getChildByName("Label_Chioce");
            label_answer:setText(self.answerStr[s[i]]);
            btn_answer:setTag(1000+s[i]);
        end
    end
    -- 
    if self.delegate then
        self.delegate:showAngelInfo(nil,self.img_angel,self.img_name,self.panel_22,true);
    end
end

function AnswerPoint:answerBtnClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        self.selspr:setVisible(true);
        self.selspr:setPosition(cc.p(sender:getPositionX(), sender:getPositionY()));
        -- 
        for i=1,table.getn(self.answerBtTab) do
            local btn_answer=self.answerBtTab[i];
            local img_right=btn_answer:getChildByName("Image_Right");
            local isAnswer=false;
            if btn_answer==sender then
                img_right:setVisible(true);
                if btn_answer:getTag()==1001 then
                    isAnswer=true;
                    img_right:loadTexture("com_checkbox_tick.png", ccui.TextureResType.plistType);
                else
                    img_right:loadTexture("com_cross.png", ccui.TextureResType.plistType);
                end
            end
            if isAnswer==false then
                if btn_answer:getTag()==1001 then
                    img_right:setVisible(true);
                    img_right:loadTexture("com_checkbox_tick.png", ccui.TextureResType.plistType);
                end
            end

            -- img_right:setVisible(true);
            -- if btn_answer:getTag()==1001 then
            --     img_right:loadTexture("com_checkbox_tick.png", ccui.TextureResType.plistType);
            -- else
            --     img_right:loadTexture("com_cross.png", ccui.TextureResType.plistType);
            -- end
        end
        -- 
        local str=string.format("&pos=%d",sender:getTag()-1000);
        NetHandler:sendData(Post_Cloud_Main_doAnswer, str);
        self:setNoCanClick(true);        
    end
end

function AnswerPoint:onReciveData(msgId, netData)
	  if msgId == Post_Cloud_Main_doAnswer then
      	if netData.state == 1 then
            local doanswer=netData.doanswer;
            local reward=doanswer.reward;
            local itemLay=self.list:getItem(0);
            local itemPos={};
            for k,v in pairs(itemLay:getChildren()) do
                local point=v:convertToWorldSpace(cc.p(v:getPositionX()+v:getContentSize().width*self.scaleVal/2,v:getPositionY()+v:getContentSize().height*self.scaleVal/2));
                local pos=cc.p(point.x,point.y);
                table.insert(itemPos,pos);
            end
            ItemJump:getInstance():showItemJump(reward,self.panel_2,itemPos,self.scaleVal,true);
            -- 
            local coin=doanswer.get_coin;
            local stone=doanswer.get_stone;
            if self.delegate then
                self.delegate:changeTopInfo(coin,stone);
            end
            -- 延迟关闭
            local function delayClose()
                self:closeAnswer();
            end
            local delay=cc.DelayTime:create(2.0);
            local callFunc=cc.CallFunc:create(delayClose);
            self:runAction(cc.Sequence:create(delay,callFunc));
      	else
          	NetHandler:showFailedMessage(netData);
      	end
  	end
end

function AnswerPoint:RandomIndex(tabNum,indexNum)
    indexNum = indexNum or tabNum
    local t = {}
    local rt = {}
    for i = 1,indexNum do
        local ri = math.random(1,tabNum + 1 - i)
        local v = ri
        for j = 1,tabNum do
            if not t[j] then
                ri = ri - 1
                if ri == 0 then
                    table.insert(rt,j)
                    t[j] = true
                end
            end
        end
    end
    return rt
end

function AnswerPoint:closeAnswer()
    if self.delegate then
        self.delegate:closeOpenLayer();
    end
end

function AnswerPoint:onEnter()
    NetHandler:addAckCode(self,Post_Cloud_Main_doAnswer);
end

function AnswerPoint:onExit()
	NetHandler:delAckCode(self,Post_Cloud_Main_doAnswer);
	MGRCManager:releaseResources("AnswerPoint");
end

return AnswerPoint;