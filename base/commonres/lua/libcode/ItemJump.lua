-- 
require "comdef"
ItemJump=class("ItemJump");

function ItemJump:ctor()
end

-- 
function ItemJump:showItemJump(reward,node,itemPos,scaleVal,isLeft)
    local list = getneedlist(reward);
    for i=1,#list do
        local item = resItem.create();
        item:setData(list[i].type,list[i].id);
        item:setNum(list[i].num);
        item:setScale(scaleVal);
        item:setPosition(cc.p(itemPos[i].x,itemPos[i].y));
        -- item:setPosition(cc.p(itemPos.x+item:getContentSize().width*(1-((1-scaleVal)*2))*(i-1),itemPos.y));
        node:addChild(item,ZORDER_MAX);
        -- 模仿跳跃的轨迹移动节点，第一个参数为持续时间，第二个参数为位置，第三个参数为跳的高度，第四个参数跳的次数
        local to1=40;
        local to2=80;
        local to3=120;
        local to4=160;
        if isLeft then
            to1=-40;
            to2=-80;
            to3=-120;
            to4=-160;
        end
        local actionTo1=cc.JumpTo:create(0.25, cc.p(item:getPositionX()+to1+item:getContentSize().width*(i-1)*0.2,item:getPositionY()), 60, 1)
        local actionTo2=cc.JumpTo:create(0.25, cc.p(item:getPositionX()+to2+item:getContentSize().width*(i-1)*0.35,item:getPositionY()), 40, 1)
        local actionTo3=cc.JumpTo:create(0.25, cc.p(item:getPositionX()+to3+item:getContentSize().width*(i-1)*0.5,item:getPositionY()), 20, 1)
        local actionTo4=cc.JumpTo:create(0.25, cc.p(item:getPositionX()+to4+item:getContentSize().width*(i-1)*0.7,item:getPositionY()), 10, 1)
        local delay=cc.DelayTime:create(0.5);
        local function delayClose()
            item:stopAllActions();
            item:removeFromParent();
            ItemJump:dispose();
        end
        local callFunc=cc.CallFunc:create(delayClose);
        local sequence = cc.Sequence:create(actionTo1,actionTo2,actionTo3,actionTo4,delay,callFunc)
        -- 执行actionTo动作
        item:runAction(sequence)
    end
end

function ItemJump:clear()
    MGRCManager:releaseResources("ItemJump");
end

local instance;
function ItemJump:getInstance()
	if instance==nil then
		instance=ItemJump.new();
	end

	return instance;
end

function ItemJump:dispose()
	if instance~=nil then
		instance:clear();
		instance=nil;
	end
end
