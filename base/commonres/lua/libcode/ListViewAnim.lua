
ListViewAnimType =
{
	TO_NONE 	= 0,
	TO_DOWN 	= 1,
	TO_UP   	= 2,
	TO_LEFT		= 3,
	TO_RIGHT 	= 4,
}

ListViewAnim = class("ListViewAnim")

function ListViewAnim.downAnim(listView)
	local items_count = table.getn(listView:getItems())
    if items_count > 0 then
        for i=1,items_count do
            local child = listView:getItem(i-1)
            child:setVisible(false)
        end
        
        local function enterAnim()
            for i=1,items_count do
                local child = listView:getItem(i-1)
                local dstPointX, dstPointY = child:getPosition()
                if dstPointY <= listView:getContentSize().height then
                    local dchild = listView:getItem(items_count-i)
                    local dstX, dstY = dchild:getPosition()
                    local offset = dstY-50
         
                    child:setPosition( cc.p( dstPointX, dstPointY+ offset) )
                
                    local t = 0.12*(i/5.0+1)
                    child:runAction( cc.EaseOut:create(cc.MoveBy:create(t, cc.p(0,-offset)) ,2))
                end
                child:setVisible(true)
            end
        end

        local time = cc.DelayTime:create(cc.Director:getInstance():getDeltaTime())
        local func = cc.CallFunc:create(enterAnim)
        local sq = cc.Sequence:create(time,func)
        listView:runAction(sq)
    end
end

function ListViewAnim.upAnim(listView)
    local items_count = table.getn(listView:getItems())
    if items_count > 0 then 
        local function enterAnim()
            for i=items_count,1,-1 do
                local child = listView:getItem(i-1)
                local dstPointX, dstPointY = child:getPosition()
                
                if dstPointY <= listView:getContentSize().height then
                
                end

                local dchild = listView:getItem(items_count-i)
                local dstX, dstY = dchild:getPosition()
                local offset = dstY+dchild:getContentSize().height
                
                local t = 0.12*(i/5.0+1)
                child:runAction( cc.EaseOut:create(cc.MoveBy:create(t, cc.p(0,offset)) ,2))
            end
        end

        local time = cc.DelayTime:create(cc.Director:getInstance():getDeltaTime())
        local func = cc.CallFunc:create(enterAnim)
        local sq = cc.Sequence:create(time,func)
        listView:runAction(sq)
    end
end

function ListViewAnim.leftOrRightAnim(listView,type)
	local items_count = table.getn(listView:getItems())
    if items_count > 0 then
        for i=1,items_count do
            local child = listView:getItem(i-1)
            child:setVisible(false)
        end
        
        local function enterAnim()
            for i=1,items_count do
                local child = listView:getItem(i-1)
                local dstPointX, dstPointY = child:getPosition()
             	local winsize = cc.Director:getInstance():getWinSize()

                local offset = dstPointX+winsize.width
                if type == ListViewAnimType.TO_RIGHT then
        			offset = offset * -1
        		end

                child:setPosition( cc.p( dstPointX+ offset, dstPointY) )
                
                local t = 0.12*(i/5.0+1)
                child:runAction( cc.EaseOut:create(cc.MoveBy:create(t, cc.p(-offset,0)) ,2))
                child:setVisible(true)
            end
        end

        local time = cc.DelayTime:create(cc.Director:getInstance():getDeltaTime())
        local func = cc.CallFunc:create(enterAnim)
        local sq = cc.Sequence:create(time,func)
        listView:runAction(sq)
    end
end

function ListViewAnim.enterAnim(listView,type)
	if type ==  ListViewAnimType.TO_DOWN then
		ListViewAnim.downAnim(listView)
		return
	end

    if type ==  ListViewAnimType.TO_UP then
        ListViewAnim.upAnim(listView)
        return
    end

	if type == ListViewAnimType.TO_LEFT or type == ListViewAnimType.TO_RIGHT then
		ListViewAnim.leftOrRightAnim(listView,type)
		return
	end

end