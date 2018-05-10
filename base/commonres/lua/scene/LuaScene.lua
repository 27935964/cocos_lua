require "GobalDialog"

if _G.sceneData==nil then
            _G.sceneData={};
            _G.sceneData.sceneType=-1;--场景类型
            _G.sceneData.lastSceneType=-1;--最后的场景
            _G.sceneData.layerType=-1;--场景的模块类型
            _G.sceneData.layerData={};--保存场景切换时的数据
            _G.sceneData.isFightBack=false;
            _G.mainLayer=nil;--对MainLayer的引用
            _G.mapParallaxNode=nil;--主城滚动地图
end

function addMainHelp(clazz,cityId)
            local runScene=cc.Director:getInstance():getRunningScene();
            local mainLayer=clazz.getInstance(cityId);
            mainLayer.isFightBack=_G.sceneData.isFightBack;
            _G.sceneData.isFightBack=false;
            if mainLayer:getParent() then
                    print("addMainHelp parent have parent");
                    return;
            end
            runScene:addChild(mainLayer,ZORDER_MAX);
end

function delMainHelp(clazz)
            local mainLayer=clazz.getInstance();
            if mainLayer~=nil and mainLayer:getParent()~=nil then
                        mainLayer:removeFromParent();
            end
end

function enterLuaLayer(dwParm1,dwParm2,dwParm3,dwParm4,dwParm5)
            _G.sceneData.sceneType=dwParm1 or -1;
            _G.sceneData.layerType=dwParm2 or -1;
            if dwParm1==SCENEINFO.LOGIN_SCENE then--登录
                      require "LoadingPanel"
    	           addLoadingPanel(dwParm2);
            elseif dwParm1==SCENEINFO.MAP_SCENE then--地图副本
                      require "MapManager"  
    	           addMap(dwParm2);
            elseif dwParm1==SCENEINFO.MAIN_SCENE then--主城
                       require "MainCityManager"
    	           addMainCity();
            elseif dwParm1==SCENEINFO.UNIONWAR_SCENE then--公会战
                       require "UWMainLayer" 
                       addMainHelp(UWMainLayer,dwParm3);
            end
end

function exitLuaLayer(dwParm1)
            _G.sceneData.lastSceneType=_G.sceneData.sceneType;--保存最后一次场景
            _G.sceneData.sceneType=-1;
            _G.sceneData.layerType=-1;
            if dwParm1== SCENEINFO.LOGIN_SCENE then
        	           delLoadingPanel();
            elseif dwParm1==SCENEINFO.MAP_SCENE then
        	           delMap();
            elseif dwParm1==SCENEINFO.MAIN_SCENE then
        	           delMainCity();
            elseif dwParm1==UNIONWAR_SCENE then
                      delMainHelp(UWMainLayer);     
            end
end

function enterLuaScene(dwParm1,dwParm2,dwParm3,dwParm4,dwParm5)
            dwParm2=dwParm2 or -1;
            dwParm3=dwParm3 or -1;
            dwParm4=dwParm4 or "";
            dwParm5=dwParm5 or "";
            LuaBackCpp:enterLuaScene(dwParm1,dwParm2,dwParm3,dwParm4,dwParm5);
end

function enterUnionWar(cityId,errFun,showMsg)
            if showMsg==nil then
                showMsg=true;
            end
            require "CoreLayer"
            local core=Core.getInstance();
            core:executeCommand("UWTryEnterCmd",{cityId=cityId,errFun=errFun,showMsg=showMsg});
end