
Sodier={};
--sodierKind
Sodier.KCavalry=1;
Sodier.KSpear=2;
Sodier.KArcher=3;

--sodierAction
Sodier.AStand=1;
Sodier.AAttack=2;
Sodier.ADie=3;
Sodier.ARun=4;
Sodier.ASkill=5;
Sodier.ABeAttack=6;
Sodier.ACheer=7;
Sodier.ADizzy=8;
Sodier.ALeisure=9;
Sodier.AReLive=10;

--sodierDirect
Sodier.DLeft=1;
Sodier.DRight=2;

POS_BottomY = 0;

Sodier.getSodierKindName=function(kind)
    local kindname = "cavalry";
    if kind==MGSodierKSpear then
        kindname = "spear";
    elseif kind==MGSodierKArcher then
        kindname = "archer";
    end
    return kindname;
end

Sodier.getActionName=function(action)
    local framename = "stand";
    if action==Sodier.AAttack then
        framename = "attack";
    elseif action==Sodier.ADie then
        framename = "die";
    elseif action==Sodier.ARun then
        framename = "run";
    elseif action==Sodier.ASkill then
        framename = "attack";
    elseif action==Sodier.ABeAttack then
        framename = "beattack";
    elseif action==Sodier.ACheer then
        framename = "cheer";
    elseif action==Sodier.ADizzy then
        framename = "dizzy";
    elseif action==Sodier.ALeisure then
        framename = "attack";
    end
    return framename;
end

Sodier.getSodierPic=function(kind)
    local DBData = LUADB.select(string.format("select model from soldier_list where id=%d",kind), "model");
    return DBData.info.model;
end

Sodier.getZ=function(positionY)
    local pos = positionY-POS_BottomY;
    local positionZ = -100-pos/10;
    return positionZ;
end


Sodier.getZorder=function(positionY)
    local h = positionY - POS_BottomY;
    local zorder = h/12.5;
    zorder = 200 - zorder;
    return zorder;
end