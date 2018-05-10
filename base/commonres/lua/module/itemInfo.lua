
function itemInfo(itemType,id)
    infos = {};
    infos.type = itemType;
    infos.id = id;
    infos.isonly = 0;
    infos.name = "";
    infos.desc = "";
    infos.head = "";
    infos.body = "";
    infos.bust = "";
    infos.item_pic = "";
    infos.samll_pic = "";
    infos.get_go = {};

    local sql_0 = "select isonly from item_type where id="..itemType;
    local DBData_0 = LUADB.select(sql_0, "isonly");
    if DBData_0 and tonumber(DBData_0.info.isonly) == 0 then
        infos.isonly = 0;
        if itemType == 8 then--将领卡
            gm = GENERAL:getAllGeneralModel(id);
            if gm then
                infos.name = gm:name();
                infos.desc = gm:desc();
                infos.head = gm:head();
                infos.body = gm:pic();
                infos.bust = gm:bust();
                infos.item_pic = gm:head();
                infos.samll_pic = gm:head();
                infos.quality = gm:getQuality();
                infos.get_go = 0;
            end
        elseif itemType == 21 then--公会宝箱
            local sql = "select * from union_box where id="..id;
            local DBData = LUADB.select(sql, "name:des:pic:quality");
            if DBData then
                infos.name = DBData.info.name;
                infos.desc = DBData.info.des;
                infos.quality = tonumber(DBData.info.quality);
                infos.item_pic = DBData.info.pic..".png";
                infos.samll_pic = DBData.info.pic..".png";
                infos.get_go = {};
            end
        else
            gm = RESOURCE:getDBResourceListByItemId(id);
            if gm then
                infos.name = gm:name();
                infos.desc = gm:desc();
                infos.item_pic = gm:pic();
                infos.samll_pic = gm:pic();
                infos.quality = gm:getQuality();
                infos.get_go = gm:getGetGoInfo();
            end
        end
    elseif DBData_0 and tonumber(DBData_0.info.isonly) == 1 then--特殊物品
        infos.isonly = 1;
        local sql = string.format("select * from item_type where id=%d and isonly=%d",itemType,id);
        local DBData = LUADB.select(sql, "name:desc:icon:quality:get_go:small_icon");
        if DBData then
            infos.name = DBData.info.name;
            infos.desc = DBData.info.desc;
            infos.item_pic = DBData.info.icon..".png";
            infos.samll_pic = DBData.info.small_icon..".png";
            infos.quality = tonumber(DBData.info.quality);
            if tonumber(DBData.info.get_go) == 0 then
                infos.get_go = 0
            else
                infos.get_go = getneedlist(DBData.info.get_go);
            end
        end
    end

    return infos;
end

function getGeneralNeedDebrisNum(gm,isGet)--武将激活和武将升星碎片数值
    local totNum = 0;
    local resNum = 0;
    local sql = "";
    local DBData = nil;
    if isGet == true then--已经获得的武将
        if gm:getStar() < ME:getMaxStar() then--未满星
            sql = string.format("select need from general_star where g_id=%d and star=%d and lv=%d",gm:getId(),gm:getStar()+1,0);
            DBData = LUADB.select(sql, "need");
            local str_list = spliteStr(DBData.info.need,':');
            totNum = str_list[3];

            resInfo = RESOURCE:getResModelByItemId(str_list[2]);
            if resInfo then
                resNum = resInfo:getNum();
            end
        else
            sql = string.format("select need from general_star where g_id=%d and star=%d and lv=%d",gm:getId(),gm:getStar(),0);
            DBData = LUADB.select(sql, "need");
            local str_list = spliteStr(DBData.info.need,':');
            totNum = str_list[3];

            resInfo = RESOURCE:getResModelByItemId(str_list[2]);
            if resInfo then
                resNum = resInfo:getNum();
            end
        end
    elseif isGet == false then--未获得的武将
        local resId = gm:getNeedDebris()[1]:getItemId();
        local resInfo = RESOURCE:getResModelByItemId(resId);
        if resInfo then
            resNum = resInfo:getNum();
        end
        totNum = gm:getNeedDebris()[1]:getNum();
    end
    return tonumber(resNum),tonumber(totNum);
end

function itemPicName(itemType)
    local pic = "main_icon_gold.png";

    if itemType == 1 then
        pic = "main_icon_masonry.png"
    elseif itemType == 2 then
        pic = "main_icon_action.png"
    elseif itemType == 6 then
        -- pic = "main_icon_action.png"
    elseif itemType == 16 then
        pic = "com_rank_money.png"
    elseif itemType == 17 then
        pic = "com_icon_crusade_coin.png"
    elseif itemType == 18 then
        -- pic = "main_icon_action.png"
    elseif itemType == 19 then
        pic = "com_icon_prestige.png"
    elseif itemType == 20 then
        pic = "com_icon_feats.png"
    elseif itemType == 22 then
        pic = "com_icon_union_exp.png"
    end

    return pic;
end