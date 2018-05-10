GuildHelper=class("GuildHelper");

function GuildHelper:ctor()
	
end

function GuildHelper:start()
	print("GuildHelper:start >>>>>>>>>>>>>>>");
end


local _instance;
function GuildHelper:getInstance()
	if _instance==nil then
		_instance=GuildHelper.new();
	end
	return _instance;
end

function GuildHelper:dispose()
	if _instance then
		if _instance:getParent() then
			_instance:removeFromParent();
		end
		_instance=nil;
	end
end