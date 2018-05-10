-- 往上飘的
FloatUpMessage=class("FloatUpMessage");

function FloatUpMessage:ctor()
    self.layer=nil;
    self.iconImg=nil;
    self.contLabel=nil;
end

-- 往上飘的icon-文字
function FloatUpMessage:showUpMessage(iconName,str,node,pos)
    self.layer=cc.Layer:create();
    -- self.layer:setContentSize(node:getContentSize());
    self.layer:setPosition(pos.x,pos.y);
    node:addChild(self.layer,ZORDER_MAX);
    
    local contLabel=nil;
    local iconImg=nil;
    if string.len(str)>0 then 
        contLabel = cc.Label:createWithTTF(str,ttf_msyh,22);
        contLabel:setAnchorPoint(0,0.5);
        contLabel:setPosition(0,0);
        contLabel:setColor(Color3B.GREEN);
        self.layer:addChild(contLabel);
    end
    if string.len(iconName)>0 then
        iconImg = ccui.ImageView:create(iconName, ccui.TextureResType.plistType);
        self.layer:addChild(iconImg);
        iconImg:setAnchorPoint(cc.p(1,0.5));
        iconImg:setPosition(cc.p(0,0));
    end
    if iconImg==nil then
        if contLabel then
            contLabel:setAnchorPoint(0.5,0.5);
        end
    end
    if contLabel==nil then
        if iconImg then
            iconImg:setAnchorPoint(0.5,0.5);
        end
    end
    -- 
    -- 
    if self.layer.getChildrenCount and self.layer:getChildrenCount() > 0 then
        for k,v in pairs(self.layer:getChildren()) do
            local fadein = cc.FadeIn:create(0.1);
            local scaleBy = cc.ScaleBy:create(0.1, 1.2);
            local spawn = cc.Spawn:create(fadein,scaleBy);
            local delay = cc.DelayTime:create(0.8);
            local moveBy = cc.MoveBy:create(0.5, cc.p(0, 100));
            local fadeout = cc.FadeOut:create(0.5);
            local spawn2 = cc.Spawn:create(moveBy,fadeout);
            local callFun = cc.CallFunc:create(function()
                v:stopAllActions();
                v:removeFromParent();
            end);
            local seq = cc.Sequence:create(spawn,delay,spawn2,callFun)
            v:runAction(seq)
        end
    end
end

-- 往上飘的
function FloatUpMessage:showUpItem(item,str,node,pos)
    self.layer=cc.Layer:create();
    self.layer:setPosition(pos.x,pos.y);
    node:addChild(self.layer,ZORDER_MAX);
    
    local itemW=0;
    local itemH=0;
    if item then
        self.layer:addChild(item);
        item:setAnchorPoint(cc.p(1,0.5));
        itemW=item:getContentSize().width/2;
        itemH=item:getContentSize().height/2;
    end

    if string.len(str)>0 then
        local contLabel = cc.Label:createWithTTF(str,ttf_msyh,24);
        contLabel:setAnchorPoint(cc.p(0,0.5));
        contLabel:setPosition(itemW,itemH);
        contLabel:setColor(Color3B.GREEN);
        self.layer:addChild(contLabel);
    end
    if self.layer.getChildrenCount and self.layer:getChildrenCount() > 0 then
        for k,v in pairs(self.layer:getChildren()) do
            local fadein = cc.FadeIn:create(0.1);
            local scaleBy = cc.ScaleBy:create(0.1, 1.2);
            local spawn = cc.Spawn:create(fadein,scaleBy);
            local delay = cc.DelayTime:create(0.8);
            local moveBy = cc.MoveBy:create(0.5, cc.p(0, 100));
            local fadeout = cc.FadeOut:create(0.6);
            local spawn2 = cc.Spawn:create(moveBy,fadeout);
            local callFun = cc.CallFunc:create(function()
                v:stopAllActions();
                v:removeFromParent();
            end);
            local seq = cc.Sequence:create(spawn,delay,spawn2,callFun)
            v:runAction(seq)
        end
    end
end

function FloatUpMessage:clear()
    if self.layer.getChildrenCount and self.layer:getChildrenCount() > 0 then
        for k,v in pairs(self.layer:getChildren()) do
            v:stopAllActions();
            v:removeFromParent();
        end
    end
    MGRCManager:releaseResources("FloatUpMessage");
end

local instance;
function FloatUpMessage:getInstance()
	if instance==nil then
		instance=FloatUpMessage.new();
	end

	return instance;
end

function FloatUpMessage:dispose()
	if instance~=nil then
		instance:clear();
		instance=nil;
	end
end
