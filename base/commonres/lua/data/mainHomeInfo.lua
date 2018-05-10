--bg大地图信息  city建筑信息

--id  建筑ID
--x横坐标y纵坐标
--byFlag 是否可点击建筑 1可点 0不可点
--zOrder 层级
--pos建筑上的名称坐标
--pic建筑图片
--openlv 建筑开放等级

local info={
    [1]={bg={x=0,y=0},city={},unlock={},title={}},
    [2]={bg={x=282,y=0},
        city={
    	       [1]={id=1,x=414,y=141,byFlag=1,zOrder=0,name="酒馆",pos="313:185|468:225|500:73|280:87|313:185",pic="main_building_1",openlv=1,achievementlv=0},
             [2]={id=2,x=910,y=192,byFlag=1,zOrder=2,name="杂货铺",pos="866:240|950:244|980:128|896:104|836:141|866:240",pic="main_building_2",openlv=16,achievementlv=0},
        	   [3]={id=3,x=1035,y=208,byFlag=1,zOrder=1,name="珍宝阁",pos="978:230|1055:256|1093:181|997:161|978:230",pic="main_building_3",openlv=16,achievementlv=0},
        	   [4]={id=4,x=1172,y=258,byFlag=1,zOrder=0,name="官市",pos="1063:269|1169:340|1231:225|1198:177|1115:180|1063:269",pic="main_building_4",openlv=40,achievementlv=0},
        	   [5]={id=5,x=1269,y=218,byFlag=1,zOrder=1,name="英雄商店",pos="1223:174|1249:229|1325:200|1324:141|1223:174",pic="main_building_5",openlv=35,achievementlv=0},
             [6]={id=100,x=1200,y=152,byFlag=0,zOrder=4,name="",pos="",pic="main_building_wall",openlv=35,achievementlv=0}
        },
        unlock={
               [1]={id=1,x=436,y=81,zOrder=0},
               [2]={id=2,x=865,y=127,zOrder=2},
               [3]={id=3,x=994,y=165,zOrder=1},
               [4]={id=4,x=1112,y=170,zOrder=5},
               [5]={id=5,x=1209,y=144,zOrder=1}
        },
        title={
               [1]={id=1,x=398,y=81,zOrder=0},
               [2]={id=2,x=915,y=127,zOrder=2},
               [3]={id=3,x=1044,y=165,zOrder=1},
               [4]={id=4,x=1163,y=170,zOrder=0},
               [5]={id=5,x=1259,y=144,zOrder=1}
        }
	},
    [3]={bg={x=0,y=0},
        city={
    	       [1]={id=6,x=985,y=214,byFlag=1,zOrder=0,name="铁匠铺",pos="894:160|1000:271|1064:160|894:160",pic="main_building_6",openlv=16,achievementlv=0},
        	   [2]={id=7,x=239,y=210,byFlag=1,zOrder=0,name="兄弟会",pos="132:150|200:277|299:275|324:160|132:150",pic="main_building_7",openlv=48,achievementlv=0},
    	       [3]={id=8,x=486,y=304,byFlag=1,zOrder=0,name="国会",pos="358:191|492:443|615:178|358:191",pic="main_building_8",openlv=11,achievementlv=0},
        	   [4]={id=9,x=1039,y=349,byFlag=1,zOrder=0,name="财政厅",pos="948:297|1020:405|1068:358|1074:290|948:297",pic="main_building_9",openlv=10,achievementlv=2},
    	       [5]={id=10,x=1439,y=450,byFlag=1,zOrder=0,name="主城堡",pos="1160:281|1160:380|1443:655|1745:295|1616:266|1441:360|1307:259|1160:281",pic="main_building_10",openlv=18,achievementlv=0},
        	   [6]={id=11,x=616,y=476,byFlag=1,zOrder=0,name="战神像",pos="635:369|590:522|687:478|635:369",pic="main_building_11",openlv=70,achievementlv=0},
             [7]={id=12,x=1743,y=531,byFlag=1,zOrder=0,name="魔法行会",pos="1663:467|1726:585|1792:472|1663:467",pic="main_building_12",openlv=25,achievementlv=0}
        },
        unlock={
               [1]={id=6,x=935,y=150,zOrder=0},
               [2]={id=7,x=204,y=143,zOrder=0},
               [3]={id=8,x=455,y=176,zOrder=0},
               [4]={id=9,x=965,y=288,zOrder=0},
               [5]={id=10,x=1325,y=315,zOrder=0},
               [6]={id=11,x=589,y=360,zOrder=0},
               [7]={id=12,x=1669,y=458,zOrder=0}
        },
        title={
               [1]={id=6,x=983,y=150,zOrder=0},
               [2]={id=7,x=251,y=143,zOrder=0},
               [3]={id=8,x=512,y=176,zOrder=0},
               [4]={id=9,x=1014,y=288,zOrder=0},
               [5]={id=10,x=1276,y=315,zOrder=0},
               [6]={id=11,x=639,y=360,zOrder=0},
               [7]={id=12,x=1727,y=458,zOrder=0}
        }

	},
    [4]={bg={x=0,y=223},city={},unlock={},title={}},
    [5]={bg={x=0,y=297},
        city={
	           [1]={id=13,x=872,y=285,byFlag=1,zOrder=1,name="云中城",pos="700:256|708:360|1012:369|1057:229|700:256",pic="main_building_13",openlv=26,achievementlv=0}
        },
        unlock={
               [1]={id=13,x=826,y=232,zOrder=1}
        },
        title={
               [1]={id=13,x=873,y=232,zOrder=1}
        }
	},
	  [6]={bg={x=0,y=297},city={},unlock={},title={}}
}
return info;