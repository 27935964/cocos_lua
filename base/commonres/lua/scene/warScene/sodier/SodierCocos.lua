require "Sodier";
local SodierCocos=class("SodierCocos",function ()
	return cc.Node:create();
end);

VER_SCALE = 0.55;

function SodierCocos:ctor()
	self.m_nAction  = 0;
    self.m_nKind    = 0;
    self.m_nDirect  = 0;
    self.m_pArrow   = nil;
    self.m_pArrowCall = nil;
    self.anim       = nil;
    self.m_nBearing = 1;
    self.m_pCall    = nil;
    self.m_bMirror  = false;
    self.m_bSkillZ  = false;
    self.m_toPts    ={};
end

function SodierCocos:onEnter()
	
end

function SodierCocos:onExit()
	cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID);
end

function SodierCocos:setIndex(value)
    self.m_nIndex=value;
end

function SodierCocos:setPos(value)
    self.m_Pos=value;
end

function SodierCocos:setPosOut(value)
    self.m_PosOut=value;
end

function SodierCocos:setMirror(value)
    self.m_bMirror=value;
end

function SodierCocos:setSkillZ(value)
    self.m_bSkillZ=value;
end

function SodierCocos:setPosArrow(value)
    self.m_PosArrow=value;
end

function SodierCocos:getMyScaleX()
    local _scale = self.m_nBearing*VER_SCALE;
    return _scale;
end


function SodierCocos:init(pFather,kind,direct)
    self.m_nKind = kind;
    self.m_nDirect = direct;
    self.m_pFather = pFather;
    if self.m_nDirect == Sodier.DRight then
        self.m_nBearing = -1;
    end

    local framename = Sodier.getSodierPic(self.m_nKind);

    local fileName=string.format("%s.ExportJson", framename);
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(fileName);
    
    self.anim = ccs.Armature:create(framename);
	self.anim:getAnimation():playWithIndex(0);
    self:setContentSize(self.anim:getContentSize());
    self.anim:setPosition(self:getContentSize().width/2,self:getContentSize().height/2);
    self:addChild(self.anim);
    
    self:setScale(VER_SCALE);
    self:setScaleX(self:getMyScaleX());
    
    self:ignoreAnchorPointForPosition(false);
    self:setAnchorPoint(cc.p(0.5, 0.5));
    
    self.m_pFather:addChild(self,0);
    self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.updateTimef), 0.01, false);
end

function SodierCocos:setKind(kind)
    self.m_nKind = kind;
    if self.anim then
        self.anim:removeFromParent();
    end

    local framename = Sodier.getSodierPic(self.m_nKind);
    local fileName=string.format("%s.ExportJson", framename);
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(fileName);
    self.anim = ccs.Armature:create(framename);
    self.anim:getAnimation():playWithIndex(0);
    self:setContentSize(self.anim:getContentSize());
    self.anim:setPosition(self:getContentSize().width/2,self:getContentSize().height/2);
    self:addChild(self.anim);
end

function SodierCocos:updateTimef(dt)

    -- local zorder = Sodier.getZorder(self:getPositionY());
    -- if self.m_bSkillZ then
    --     zorder=zorder+ZORDER_MAX;
    -- end
    -- if self:getLocalZOrder()~=zorder then
    --     self:getParent():reorderChild(self, zorder);
    -- end
    
    -- if self.m_pArrow then
    --     zorder = Sodier.getZorder(self.m_pArrow:getPositionY());
    --     if self.m_pArrow:getLocalZOrder()~= (zorder+1) then
    --         self.m_pFather:reorderChild(self.m_pArrow, zorder+1);
    --     end
    -- end
end

function SodierCocos:showAction(action, call)
    if self.m_pCall~=nil then
    	return; --前面有动作未完成
    end
    
    self.m_nAction = action;
    if call~=nil then
        self.m_pCall  = call;
    end
    local bforever = false;
    local framename = Sodier.getActionName(self.m_nAction);
    self.anim:getAnimation():play(framename);
    if self.m_nAction==Sodier.AStand then
        bforever = true;
    elseif self.m_nAction==Sodier.ARun then
        bforever = true;
    elseif self.m_nAction==Sodier.ACheer then
    	bforever = true;
    elseif self.m_nAction==Sodier.ADizzy then
        bforever = true;
    end

    if bforever==false then
        self.anim:getAnimation():setMovementEventCallFunc(handler(self,self.onMovementEvent));
    end
    print("111 m_nAction=%s",self.m_nAction);
end

function SodierCocos:onMovementEvent(armature,movementType,movementID)
    	-- print(Sodier.ACTION_NAME[self.action]);
    	if movementType == ccs.MovementEventType.complete then
    		if self.m_nAction==Sodier.ALeisure then
    			self:showAction(Sodier.AStand);
    		else
    			self:showActionCall();
    		end
    	end
end


function SodierCocos:showActionCall()
    if self.m_nAction == Sodier.ADie then
        self:setVisible(false);
    end
    if self.m_pCall then
        self.m_pCall(self);
        self.m_pCall = nil;
    end

    if self.m_nAction == Sodier.ARun then
        self:setScaleX(self:getMyScaleX());
    end
    self:showAction(Sodier.AStand);
end


function SodierCocos:moveIn(call)
    self:stopAllActions();
    self:showAction(Sodier.ARun);
    self:setScaleX(self:getMyScaleX());
   
    if call then
        self.m_pCall   = call;
    end

	local delay = cc.DelayTime:create(math.random()*0.5*0.5);
	local moveTo=cc.MoveTo:create(1,self.m_Pos);
	local callFunc=cc.CallFunc:create(handler(self,self.showActionCall));
	local seqAction = cc.Sequence:create(delay,moveTo, callFunc);
	self:runAction(seqAction);
end


function SodierCocos:moveOut(call)
    self:stopAllActions();
    self:showAction(Sodier.ARun);
    self:setScaleX(-1*self:getMyScaleX());

    if call then
        self.m_pCall   = call;
    end

    local delay = cc.DelayTime:create(math.random()*0.5*0.5);
	local moveTo=cc.MoveTo:create(1,self.m_PosOut);
	local callFunc=cc.CallFunc:create(handler(self,self.showActionCall));
	local seqAction = cc.Sequence:create(delay,moveTo, callFunc);
	self:runAction(seqAction);
end

function SodierCocos:relive()
    self:setVisible(true);
    self:showAction(Sodier.AStand);
end

function SodierCocos:mirror()
    self.m_bMirror = true;
    self:setScaleX(-1*self:getMyScaleX());
end

function SodierCocos:mirrorBack()
    self.m_bMirror = false;
    self:setScaleX(self:getMyScaleX());
end

function SodierCocos:move(toPt,time0,time1)
    local  action = Sodier.ARun;
    self:setScaleX(self:getMyScaleX());
    if self.m_nDirect == Sodier.DLeft then
        if toPt.x < self:getPosition().x then
            self:setScaleX(-1*self:getMyScaleX());
        end
    else
    
        if toPt.x > self:getPosition().x then
            self:setScaleX(-1*self:getMyScaleX());
        end
    end
    self:showAction(action);

    local dt = time0+math.random()*(time1-time0);
    if m_pCall==nil then
        dt = dt-0.01;
    end
    local delay = cc.DelayTime:create(dt);
	local moveTo=cc.MoveTo:create(1,toPt);
	local callFunc=cc.CallFunc:create(handler(self,self.afterMoveCall));
	local seqAction = cc.Sequence:create(delay,moveTo, callFunc);
	self:runAction(seqAction);
end

function SodierCocos:pushMovePt(toPt)
    local  opt;
    opt.toPt = toPt;
    local disX=self:getPositionX()-toPt.x;
	local disY=self:getPositionY()-toPt.y;
    local  dis = 0;
    dis = math.sqrt(disX*disX+disY*disY)
    opt.toTime = dis/600;
    table.insert(self.m_toPts, opt)
end

function SodierCocos:move(call)
    if call then
        self.m_pCall   = call;
    end
    local opt = self.m_toPts[1];
    move(opt.toPt,opt.toTime-0.04,opt.toTime);
    table.remove(self.m_toPts,1);
end


function SodierCocos:afterMoveCall()
    if self.m_bMirror==false then
        self:setScaleX(self:getMyScaleX());
    end
    self:showAction(Sodier.AStand);
    if m_toPts.size() then
        local  opt = self.m_toPts[1];
        move(opt.toPt,opt.toTime-0.04,opt.toTime);
        table.remove(self.m_toPts,1);
    else
    	if self.m_pCall then
        	self.m_pCall(self);
        	self.m_pCall = nil;
    	end
    end
end


function SodierCocos:arrow(updown,call)
    if call then
        self.m_pArrowCall   = call;
    end
    
    if self.m_pArrow == nil then
        self.m_pArrow =  MGCartoon:create("arrow", 5);
    end
    self.m_pArrow:setScale(.6);
    self.m_pArrow:setAnchorPoint(cc.p(0.5, 0.5));
    self.m_pArrow:setPosition(cc.p(self:getPositionX(), self:getPositionY()));
    self.m_pArrow:play(true);
    self.m_pFather:addChild(self.m_pArrow,self:getLocalZOrder()+1);
    local direct;
    if self.m_nDirect==Sodier.DLeft then
        self.m_pArrow:getSprite():setFlippedX(false);
        direct = 1;
    else
        self.m_pArrow:getSprite():setFlippedX(true);
        direct = -1;
    end
    
    if updown == 1 then
        self.m_pArrow:getSprite():setRotation(-22.5*direct);
    elseif updown == -1 then
        self.m_pArrow:getSprite():setRotation(22.5*direct);
    elseif updown == 2 then
        self.m_pArrow:getSprite():setRotation(-45*direct);
    elseif updown == -2 then
        self.m_pArrow:getSprite():setRotation(45*direct);
    end
    
    local disX=self:getPositionX()-self.m_PosArrow.x;
    local disY=self:getPositionY()-self.m_PosArrow.y;
    local dis = math.sqrt(disX*disX+disY*disY)
    local dt = dis/1500+math.random()*(1.5*dis/1500-dis/1500);
    local delay = cc.DelayTime:create(dt);
    local moveTo=cc.MoveTo:create(1,self.m_PosArrow);
    local callFunc=cc.CallFunc:create(handler(self,self.afterArrowCall));
    local seqAction = cc.Sequence:create(delay,moveTo, callFunc);
    self.m_pArrow:runAction(seqAction);
end

function SodierCocos:afterArrowCall()
    if self.m_pArrowCall then
        self.m_pArrowCall(self);
        self.m_pArrowCall = nil;
    end
    self.m_pArrow:removeFromParent();
    self.m_pArrow = nil;
end

return SodierCocos;