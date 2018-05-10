--id  建筑ID
--x横坐标y纵坐标
--byFlag 是否可点击建筑 1可点 0不可点
--zOrder 层级
--namepos建筑上的名称坐标
--pic建筑图片
--openlv 建筑开放等级
--unionlv 建筑开放所需公会等级

local info={
    	       [1]={id=1,x=464,y=571,byFlag=1,zOrder=1,name="公会大厅",namepos={x=26,y=-56},pic="GulidView_Building_GulidHall",namePic="GuildView_Title_GuildHall",openlv=18,unionlv=1},
			   [2]={id=2,x=301,y=409,byFlag=1,zOrder=1,name="官爵",namepos={x=-4,y=-52},pic="GuildView_Building_Nobility",namePic="GuildView_Title_Nobility",openlv=18,unionlv=1},
        	   [3]={id=3,x=462,y=307,byFlag=1,zOrder=1,name="公会宝箱",namepos={x=13,y=-72},pic="GuildView_Building_GuildTreasure",namePic="GuildView_Title_GuildTreasure",openlv=18,unionlv=1},
        	   [4]={id=4,x=430,y=123,byFlag=1,zOrder=1,name="仓库",namepos={x=-5,y=-70},pic="GuildView_Building_WareHuose",namePic="GuildView_Title_WareHouse",openlv=18,unionlv=1},
        	   [5]={id=5,x=598,y=224,byFlag=1,zOrder=1,name="红包",namepos={x=2,y=-90},pic="GuildView_Building_RedPacket",namePic="GuildView_Title_RedPacket",openlv=18,unionlv=1},
			   [6]={id=6,x=752,y=151,byFlag=1,zOrder=1,name="公会成就",namepos={x=25,y=-91},pic="GuildView_Building_Achievement",namePic="GuildView_Title_Achievement",openlv=35},
			   [7]={id=7,x=1040,y=280,byFlag=1,zOrder=1,name="公会建设",namepos={x=15,y=-81},pic="GuildView_Building_GuildBuild",namePic="GuildView_Title_GuildBuild",openlv=18,unionlv=1},
			   [8]={id=8,x=951,y=385,byFlag=1,zOrder=1,name="佣兵营",namepos={x=0,y=-90},pic="GuildView_Building_Residence",namePic="GuildView_Title_Residence",openlv=18,unionlv=1},
        	   [9]={id=9,x=862,y=508,byFlag=1,zOrder=1,name="攻城部队",namepos={x=5,y=-84},pic="GuildView_Building_SiegeTroops",namePic="GuildView_Title_SiegeTroops",openlv=18,unionlv=1},
        	   [10]={id=10,x=1036,y=533,byFlag=1,zOrder=1,name="维蓝金字塔",namepos={x=11,y=-81},pic="GuildView_Building_Pyramid",namePic="GuildView_Title_Pyramid",openlv=18,unionlv=1},
        	   [11]={id=11,x=1125,y=410,byFlag=1,zOrder=1,name="列王争霸",namepos={x=21,y=-71},pic="GuildView_Buliding_Contend",namePic="GuildView_Title_Contend",openlv=999,unionlv=1}
			}
return info;