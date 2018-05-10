TCP_APP_CHAT_USER=10101; --私聊
TCP_APP_CHAT_CHANNEL=10102;--频道聊天
TCP_APP_CHAT_CHANNEL_NTF=10203; --聊天信息推送		接收 203|频道id|uid|附带信息|内容
TCP_APP_CHAT_USER_NTF= 10204; --私聊信息推送			接收 204|uid|附带信息|内容
TCP_UNION_WAR_ACTION_NTF=10205;--公会战推送			接收 205|城池ID|路线ID|内容
TCP_UNION_WAR_BACK_NTF=10206;--公会战兵线收兵		接收 206|城池ID|路线ID
TCP_UNION_WAR_RESULT_NTF=10208;--公会战战斗结果		接收 208|城池ID|获胜方 1攻击方 2防守方|内容
TCP_UNION_WAR_ARMY_NUM_NTF=10209;--公会战队伍数量改变	接收 209|城池ID|阵营 1攻击方 2防守方|{"sum":3,"info":{"1":"1","2":"1","3":"1","4":"0","5":"0"}}
TCP_UNION_WAR_ARMY_HEAD_NTF=10210;--公会战阵营头像改变	接收 210|城池ID|阵营 1攻击方 2防守方|[[row,head],...]
TCP_UNION_WAR_ARMY_WILL_OVER=10211;--公会即将结束通知	接收 211|城池ID|阵营 1攻击方 2防守方|时间(10位时间戳)
TCP_UNION_WAR_KILL_NUM_NTF=10212;--公会战用户击杀数量     	接收212|城池ID|用户ID|击杀数

local tcp={
    [TCP_APP_CHAT_USER]={c="101",a="101|%s|%s|%s\r\n"}--私聊 101|对方uid|附带信息|内容
    ,[TCP_APP_CHAT_CHANNEL]={c="102",a="102|%s|%s|%s\r\n"} --频道聊天 102|频道id|附带信息|内容
}

return tcp;
