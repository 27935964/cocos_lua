-----------------------将领属性界面------------------------
require "PanelTop"
require "SciSoldierItem"

SciSoldierLayer = class("SciSoldierLayer", MGLayer)

function SciSoldierLayer:ctor()
    self:init();
end

function SciSoldierLayer:init()
    MGRCManager:cacheResource("SciSoldierLayer", "package_bg.jpg");
    local size = cc.Director:getInstance():getWinSize();
    local bgSpr = cc.Sprite:create("package_bg.jpg");
    bgSpr:setPosition(cc.p(size.width/2, size.height));
    bgSpr:setAnchorPoint(cc.p(0.5,1));
    self:addChild(bgSpr);
    CommonMethod:setFullBgScale(bgSpr);


    local pWidget = MGRCManager:widgetFromJsonFile("SciSoldierLayer","SciSoldier_ui_1.ExportJson");
    self:addChild(pWidget);
    CommonMethod:setVisibleSize(pWidget);
    MGRCManager:changeWidgetTextFont(pWidget,true);--设置描边或者阴影


    self.pPanelTop = PanelTop.create(self)
    self.pPanelTop:setData("SciSoldier_title.png");
    self:addChild(self.pPanelTop,10);
    
    local Panel_2 = pWidget:getChildByName("Panel_2");
    local Panel_left = Panel_2:getChildByName("Panel_left");
    self.list = Panel_left:getChildByName("ListView_left");
    local Panel_mid = Panel_2:getChildByName("Panel_mid");
    self.Image_pic = Panel_mid:getChildByName("Image_pic");
    self.listhero = Panel_mid:getChildByName("ListView_hero");

    local Image_star_bg = Panel_mid:getChildByName("Image_star_bg");
    self.Image_cao={};
    self.Image_star={};
    for i=1,10 do
        local Imagecao = Image_star_bg:getChildByName("Image_cao_"..i);
        local Imagestar = Imagecao:getChildByName("Image_star");
        table.insert(self.Image_cao,Imagecao);
        table.insert(self.Image_star,Imagestar);
    end

    local Panel_lv = Panel_mid:getChildByName("Panel_lv");
    self.Image_circle = Panel_lv:getChildByName("Image_circle");
    self.Image_trip = Panel_lv:getChildByName("Image_trip");
    self.AtlasLabel = Panel_lv:getChildByName("AtlasLabel");

    local Panel_right = Panel_2:getChildByName("Panel_right");
    self.Label_name = Panel_right:getChildByName("Label_name");
    self.Image_gold = Panel_right:getChildByName("Image_gold");
    self.Label_gold = self.Image_gold:getChildByName("Label_gold");
    self.Image_item = Panel_right:getChildByName("Image_item");
    local Label_item = Panel_right:getChildByName("Label_item");
    Label_item:setVisible(false);
    self.Label_item = MGColorLabel:label()
    self.Label_item:setAnchorPoint(cc.p(0,0.5));
    self.Label_item:setPosition(Label_item:getPosition());
    Panel_right:addChild(self.Label_item)


    local Image_box = Panel_right:getChildByName("Image_box");
    self.Label_att_name_1 = Image_box:getChildByName("Label_att_name_1");
    self.Label_att_name_2 = Image_box:getChildByName("Label_att_name_2");
    self.Label_att_name_3 = Image_box:getChildByName("Label_att_name_3");
    local Label_att_1 = Image_box:getChildByName("Label_att_1");
    local Label_att_2 = Image_box:getChildByName("Label_att_2");
    local Label_att_3 = Image_box:getChildByName("Label_att_3");
    Label_att_3:setVisible(false);
    Label_att_2:setVisible(false);
    Label_att_1:setVisible(false);

    self.Label_att_1 = MGColorLabel:label()
    self.Label_att_1:setAnchorPoint(cc.p(0,0.5));
    self.Label_att_1:setPosition(Label_att_1:getPosition());
    Image_box:addChild(self.Label_att_1)

    self.Label_att_2 = MGColorLabel:label()
    self.Label_att_2:setAnchorPoint(cc.p(0,0.5));
    self.Label_att_2:setPosition(Label_att_2:getPosition());
    Image_box:addChild(self.Label_att_2)

    self.Label_att_3 = MGColorLabel:label()
    self.Label_att_3:setAnchorPoint(cc.p(0,0.5));
    self.Label_att_3:setPosition(Label_att_3:getPosition());
    Image_box:addChild(self.Label_att_3)

    self.Button_upgrade = Panel_right:getChildByName("Button_upgrade");
    self.Button_upgrade:addTouchEventListener(handler(self,self.onBtnClick));
    local Label_btn = self.Button_upgrade:getChildByName("Label_btn");
    Label_btn:setText(MG_TEXT_COCOS("SciSoldier_ui_1"));

    self:createlist();
    self:sendReq();
end

function SciSoldierLayer:onBtnClick(sender, eventType)
    buttonClickScale(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        self:sendaddSoldierSLv();
    end
end

function SciSoldierLayer:createlist()
    self.list:removeAllItems();
    local DBDataList = LUADB.selectlist("select id,name from soldier_list", "id:name");
    for i=1,#DBDataList.info do
        local SciSoldierItem = SciSoldierItem.create(self);
        SciSoldierItem:setData(DBDataList.info[i]);
        self.list:pushBackCustomItem(SciSoldierItem);
        if i==1 then
            self:SciSoldierItemSelect(SciSoldierItem);
        end
    end
end

function SciSoldierLayer:back()
    self:removeFromParent();
end

function SciSoldierLayer:SciSoldierItemSelect(item)
    if  self.selItem~=item then
        if self.selItem then
            self.selItem:Select(false);
        end
        self.selItem = item;
        self.selItem:Select(true);
    end
    local pic = string.format("soldier_bust_%s.png",self.selItem.info.id);
    MGRCManager:cacheResource("SciSoldierLayer",pic);
    self.Image_pic:loadTexture(pic,ccui.TextureResType.plistType);
    self.Label_name:setText(self.selItem.info.name..MG_TEXT("science"));
    self.listhero:removeAllItems();
    self.gmlist = GENERAL:getGeneralList();
    self.listhero:setItemsMargin(10);
    for i=1,#self.gmlist do
        local id = tonumber(self.selItem.info.id);
        if self.gmlist[i]:soldierid()==id then
            local item = HeroHeadEx.create(self);
            item:setData(self.gmlist[i]);
            self.listhero:pushBackCustomItem(item);
        end
    end

    self.gmlist = GENERAL:getDBGeneralList();
    for i=1,#self.gmlist do
        local id = tonumber(self.selItem.info.id);
        if self.gmlist[i]:soldierid()==id then
            local item = HeroHeadEx.create(self);
            item:setData(self.gmlist[i]);
            item:setIsGray(true)
            self.listhero:pushBackCustomItem(item);
        end
    end
    self:showlv(false);
end

function SciSoldierLayer:showlv(bnet)
    local id;
    local star;
    local step;
    if self.science_info then
        if self.selItem.info.star == nil then
            for i=1,#self.science_info do
                id = tonumber(self.selItem.info.id);
                if self.science_info[i].s_id == id then
                    self.selItem.info.star = self.science_info[i].star;
                    star = self.science_info[i].star;
                    self.selItem.info.step = self.science_info[i].step;
                    step = self.science_info[i].step;
                    break;
                end
            end
        else
            id = tonumber(self.selItem.info.id);
            star = self.selItem.info.star;
            step = self.selItem.info.step;
        end

        if bnet or self.selItem.info.need==nil then
            local DBData = LUADB.select(string.format("select need,add_eff,effect from soldier_science_list where s_id=%d and step=%d and star=%d",id,step,star), "need:add_eff:effect");
            self.selItem.info.need = getneedlist(DBData.info.need);
            self.selItem.info.add_eff = getefflist(DBData.info.add_eff);
            self.selItem.info.effect =  getefflist(DBData.info.effect);
        end

        self.Label_att_name_1:setText(self.selItem.info.effect[1].name);
        self.Label_att_name_2:setText(self.selItem.info.effect[2].name);
        self.Label_att_name_3:setText(self.selItem.info.effect[3].name);

        self.Label_att_1:clear()
        self.Label_att_1:appendString(string.format("%d",self.selItem.info.effect[1].count), Color3B.WHITE, ttf_msyh, 22);
        if self.selItem.info.add_eff[1].count>0 then
            self.Label_att_1:appendString(string.format("  +%d",self.selItem.info.add_eff[1].count), Color3B.GREEN, ttf_msyh, 22);
        end

        self.Label_att_2:clear()
        self.Label_att_2:appendString(string.format("%d",self.selItem.info.effect[2].count), Color3B.WHITE, ttf_msyh, 22);
        if self.selItem.info.add_eff[2].count>0 then
            self.Label_att_2:appendString(string.format("  +%d",self.selItem.info.add_eff[2].count), Color3B.GREEN, ttf_msyh, 22);
        end
        
        self.Label_att_3:clear()
        self.Label_att_3:appendString(string.format("%d",self.selItem.info.effect[3].count), Color3B.WHITE, ttf_msyh, 22);
        if self.selItem.info.add_eff[3].count>0 then
            self.Label_att_3:appendString(string.format("  +%d",self.selItem.info.add_eff[3].count), Color3B.GREEN, ttf_msyh, 22);
        end

        if self.selItem.info.need[2].num==0 then
            self.Image_gold:setVisible(false);
            self.Label_gold:setVisible(false);
        else
            self.Image_gold:setVisible(true);
            self.Label_gold:setVisible(true);
            self.Label_gold:setText(string.format("%d",self.selItem.info.need[2].num));
        end

        if self.selItem.info.need[1].num==0 then
            self.Image_item:setVisible(false);
            self.Label_item:setVisible(false);
        else
            self.Image_item:setVisible(true);
            local pic = string.format("SciSoldier_item_%d.png",self.selItem.info.need[1].id);
            self.Image_item:loadTexture(pic,ccui.TextureResType.plistType);
            self.Label_item:setVisible(true);
            local havenum = 0;
            local item =  RESOURCE:getResModelByItemId(self.selItem.info.need[1].id);
            if item then
                havenum = item:getNum();
            end
            local neednum = self.selItem.info.need[1].num;
            self.Label_item:clear()
            if neednum<=havenum then
                self.Label_item:appendString(string.format("%d",havenum), Color3B.GREEN, ttf_msyh, 22);
            else
                self.Label_item:appendString(string.format("%d",havenum), Color3B.RED, ttf_msyh, 22);
            end
            self.Label_item:appendString(string.format("/%d",neednum), Color3B.WHITE, ttf_msyh, 22)
        end

        local t1=1;
        local t2=1;
        local t11=1;
        local t22=1;
        t1 = math.modf((step-1)/6);
        t11=step-t1*6;
        t1 = t1+1;

        if step>1 then
            t2 = math.modf((step-2)/6);
            t22=(step-1)-t2*6;
            t2 = t2+1;
        end


        for i=1,#self.Image_cao do
            if star==0 then
                local pic = string.format("SciSoldier_starcao_%d.png",t1);
                self.Image_cao[i]:loadTexture(pic,ccui.TextureResType.plistType);
                self.Image_star[i]:setVisible(false);
            else
                
                if i<=star then
                    local pic = string.format("SciSoldier_starcao_%d.png",t1);
                    self.Image_cao[i]:loadTexture(pic,ccui.TextureResType.plistType);
                    self.Image_star[i]:setVisible(true);
                    local t3 = t1
                    local pic1 = string.format("SciSoldier_star_%d.png",t11);
                    self.Image_star[i]:loadTexture(pic1,ccui.TextureResType.plistType);
                else
                    if step == 1 then
                        self.Image_star[i]:setVisible(false);
                        local pic = string.format("SciSoldier_starcao_%d.png",t1);
                        self.Image_cao[i]:loadTexture(pic,ccui.TextureResType.plistType);
                    else
                        local pic = string.format("SciSoldier_starcao_%d.png",t2);
                        self.Image_cao[i]:loadTexture(pic,ccui.TextureResType.plistType);
                        self.Image_star[i]:setVisible(true);
                        local pic1 = string.format("SciSoldier_star_%d.png",t22);
                        self.Image_star[i]:loadTexture(pic1,ccui.TextureResType.plistType);
                    end
                    
                end
            end
        end

        t1,t2 = math.modf((step-1)/6);
        t1 = t1+1;

        pic = string.format("SciSoldier_circle_%d.png",t1);
        self.Image_circle:loadTexture(pic,ccui.TextureResType.plistType);
        pic = string.format("SciSoldier_trip_%d.png",step);
        self.Image_trip:loadTexture(pic,ccui.TextureResType.plistType);
        self.AtlasLabel:setStringValue(step);
    end

end


function SciSoldierLayer:sendReq()
    NetHandler:sendData(Post_getSoldierScience, "");
end

function SciSoldierLayer:sendaddSoldierSLv()
   --@Summary  增加兵种科技等级
   --@Input    s_id Int 兵种ID
    local id = tonumber(self.selItem.info.id);
    local str = string.format("&s_id=%d",id);
    NetHandler:sendData(Post_addSoldierSLv, str);
end

function SciSoldierLayer:onReciveData(MsgID, NetData)
    print("SciSoldierLayer onReciveData MsgID:"..MsgID)
    
    if MsgID == Post_getSoldierScience then
        local ackData = NetData
        if ackData.state == 1 then
            self.science_info = ackData.getsoldierscience.science_info;
            self:showlv(true);
        else
            NetHandler:showFailedMessage(ackData)
        end
    elseif  MsgID == Post_addSoldierSLv then
        local ackData = NetData
        if ackData.state == 1  then
            self.selItem.info.star = ackData.addsoldierslv.new_info.star;
            self.selItem.info.step = ackData.addsoldierslv.new_info.step;
            self:showlv(true);
            self.pPanelTop:upData();
        else
            NetHandler:showFailedMessage(ackData)
        end
    end
    
end



function SciSoldierLayer:pushAck()
    NetHandler:addAckCode(self,Post_getSoldierScience);
    NetHandler:addAckCode(self,Post_addSoldierSLv);

end

function SciSoldierLayer:popAck()
    NetHandler:delAckCode(self,Post_getSoldierScience);
    NetHandler:delAckCode(self,Post_addSoldierSLv);
end

function SciSoldierLayer:onEnter()
    self:pushAck();
end

function SciSoldierLayer:onExit()
    MGRCManager:releaseResources("SciSoldierLayer");
    self:popAck();
end

function SciSoldierLayer.create(delegate)
    local layer = SciSoldierLayer:new()
    layer.delegate = delegate
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
