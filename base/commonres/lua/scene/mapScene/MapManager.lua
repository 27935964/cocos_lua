------------------------主线界面管理-------------------------
require "MainLineLayer"
require "MainLayer"
-- require "JesonGenerator"
require "GuildHelper"

MapManager = class("MapManager", MGLayer)

function MapManager:ctor()
    self.mainLineLayer = nil;
    self.mainLayer = nil;
end

function MapManager:init()
    self:addCheckpoint();
end

function MapManager:addCheckpoint()
	if not self.mainLineLayer then
		self.mainLineLayer = MainLineLayer.showBox(self,SCENEINFO.MAP_SCENE);
        -- self.mainLineLayer = JesonGenerator.showBox();
	end

    if not self.mainLayer then
        self.mainLayer = MainLayer.showBox(self,SCENEINFO.MAP_SCENE,self.layerType);
    end
end

function MapManager:removeMapManager()
	if self.mainLineLayer then
		self.mainLineLayer:removeFromParent();
		self.mainLineLayer = nil;
	end

    if self.mainLayer then
        self.mainLayer:removeFromParent();
        self.mainLayer = nil;
    end
end

function MapManager:jump()
    if self.mainLineLayer then
        self.mainLineLayer:jump();
    end
end

function MapManager:onEnter()
	
end

function MapManager:onExit()
	MGRCManager:releaseResources("MapManager");
end

function MapManager.create(layerType)
    local layer = MapManager:new();
    layer.layerType = layerType;
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

s_mapLayer = nil;
function MapManager.getInstance()
    if s_mapLayer then
        return s_mapLayer;
    end
end

function addMap(layerType)
	s_mapLayer = MapManager.create(layerType);
	cc.Director:getInstance():getRunningScene():addChild(s_mapLayer);

           GuildHelper:getInstance():start();
end

function delMap()
    if s_mapLayer and s_mapLayer:getParent() then
        s_mapLayer:removeFromParent();
        s_mapLayer = nil;
    end
end