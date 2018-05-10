------------------------主城界面管理-------------------------
require "MapParallaxNode"
require "MainLayer"

MainCityManager = class("MainCityManager", MGLayer)

function MainCityManager:ctor()
        self.mainLayer = nil;
        self.mapParallaxNode = nil;
end

function MainCityManager:addCheckpoint()
       if not self.mapParallaxNode then
          self.mapParallaxNode=MapParallaxNode.showBox(self);
      end

      if not self.mainLayer then
          self.mainLayer=MainLayer.showBox(self,SCENEINFO.MAIN_SCENE);
      end
end

function MainCityManager:removeMainCityManager()
      	if self.mapParallaxNode then
      		self.mapParallaxNode:removeFromParent();
      		self.mapParallaxNode = nil;
      	end

          if self.mainLayer then
                    self.mainLayer:removeFromParent();
                    self.mainLayer = nil;
          end
end

--刷新玩家金币钻石
function MainCityManager:updataMoney()
          if self.mainLayer then
                self.mainLayer:updataMoney();
          end
end

function MainCityManager:init()
	self:addCheckpoint();
end

function MainCityManager:onEnter()
	
end

function MainCityManager:onExit()
	MGRCManager:releaseResources("MainCityManager");
end

function MainCityManager.create()
    local layer = MainCityManager:new();
    layer:init();
    local function onNodeEvent(event)
        if event == "enter" then
            layer:onEnter();
        elseif event == "exit" then
            layer:onExit();
        end
    end
    
    layer:registerScriptHandler(onNodeEvent);
    
    return layer;
end

s_mainCityLayer = nil;
function addMainCity()
	s_mainCityLayer = MainCityManager.create();
	cc.Director:getInstance():getRunningScene():addChild(s_mainCityLayer);
end

function delMainCity()
    if s_mainCityLayer then
        s_mainCityLayer:removeFromParent();
        s_mainCityLayer=nil;
    end
end