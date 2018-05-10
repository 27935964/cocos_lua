local HeroCircleHead=class("HeroCircleHead",function() 
	return cc.Layer:create();
end);

HeroCircleHead.__index=HeroCircleHead;

function HeroCircleHead:ctor(coverName,stencilScale)
            coverName=coverName or "circle_cover.png";

	local clipNode = cc.ClippingNode:create();
    	clipNode:setContentSize(cc.size(84, 84));
    	clipNode:setAnchorPoint(cc.p(0.5, 0.5));
           self:addChild(clipNode);

    	clipNode:setAlphaThreshold(0.05);
    	local stencil = cc.Sprite:createWithSpriteFrameName(coverName);
    	stencil:setScale(stencilScale or 1);
    	stencil:setPosition(clipNode:getContentSize().width/2, clipNode:getContentSize().height/2);
    	clipNode:setStencil(stencil);
            self.stencil = stencil;

    	self.head = cc.Sprite:create();
    	self.head:setPosition(clipNode:getContentSize().width/2, clipNode:getContentSize().height/2);
    	clipNode:addChild(self.head);

           NodeListener(self);
end

function HeroCircleHead:setHeroId(heroId)

	local info=GeneralData:getGeneralInfo(heroId)
        	if info==nil then
        		print("HeroCircleHead:setHead error");
        		return;
        	end
            
           local headImg=info:head()..".png";
	MGRCManager:cacheResource("HeroCircleHead", headImg);
    	self.head:setSpriteFrame(headImg);
end

function HeroCircleHead:setHeroFace(face)
          MGRCManager:cacheResource("HeroCircleHead", face);
          self.head:setSpriteFrame(face);    
end

function HeroCircleHead:setHeadScale(value)
            self.head:setScale(value);
end

function HeroCircleHead:setStencilPic(pic)
        self.stencil:setSpriteFrame(pic);
end

function HeroCircleHead:setGray(value)
        if value then
                MGGraySprite:graySprite(self.head);
        else
                self.head:setShaderProgram(self:getDefaultProgram());
        end
end

function HeroCircleHead:getDefaultProgram()
          return cc.ShaderCache:getInstance():getProgram("ShaderPositionTextureColor_noMVP");
end

function HeroCircleHead:onEnter()
   
end

function HeroCircleHead:onExit()
        MGRCManager:releaseResources("HeroCircleHead");
end

return HeroCircleHead;
