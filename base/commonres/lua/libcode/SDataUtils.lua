--数据数据处理
SDataUtils=class("SDataUtils");

function SDataUtils:ctor()
	
end

--时间格式化
function SDataUtils:timeStrByDay(sec)
	--day 86400 h 3600 m 60
	local str="";
	local num=0;
	if sec>=86400 then
		num=math.floor(sec/86400);
		sec=sec-num*86400;
		str=str..tostring(num)..MG_TEXT("day");
	end

	if sec>3600 then
		num=math.floor(sec/3600);
		sec=sec-num*3600;
		if num<10 then
			str=str.."0";
		end
		str=str..tostring(num)..MG_TEXT("Hour");
	else
		str=str.."0"..MG_TEXT("Hour");
	end

	if sec>60 then
		num=math.floor(sec/60);
		sec=sec-num*60;
		if num<10 then
			str=str.."0";
		end
		str=str..tostring(num)..MG_TEXT("Minute");
	else
		str=str.."0"..MG_TEXT("Minute");
	end
	
	if sec<10 then
		str=str.."0";
	end
	str=str..tostring(sec)..MG_TEXT("Second");
	return str;
end

local instance=nil;

function SDataUtils:getInstance()
	if instance==nil then
		instance=SDataUtils:new();
	end
	return instance;
end

function SDataUtils:dispose()
	if instance~=nil then
		instance=nil;
	end
end