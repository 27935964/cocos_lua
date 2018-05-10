MGWidgetSwallow = class("MGWidgetSwallow")


function MGWidgetSwallow.setSwallowed(delegate,node,isSwallowed)
	if not node then
		node = delegate
	end

	if not isSwallowed then
		isSwallowed = false
	end

    local _move_flag = false
    local beginPoint = 0

	local function onTouchBegan(touch, event)
        beginPoint = touch:getLocation()
        if node:hitTest(beginPoint) and node:clippingParentAreaContainPoint(beginPoint) then
            _move_flag = false
            node:setScale(1.05)
            return true
        end
       	return false
    end

   	local function onTouchMoved(touch, event)
   		_move_flag = true
    end

    local function onTouchEnded(touch, event)
        if _move_flag then
            local  newPoint = touch:getLocation()
            local  moveDistance = cc.p(0,0)
            moveDistance.x = newPoint.x - beginPoint.x;
            moveDistance.y = newPoint.y - beginPoint.y;
            local dis = math.sqrt(moveDistance.x*moveDistance.x + moveDistance.y*moveDistance.y);
            local function convertDistanceFromPointToInch(pointDis)
                local  glview = cc.Director:getInstance():getOpenGLView();
                local factor = ( glview:getScaleX() + glview:getScaleY() ) / 2;
                return pointDis * factor / 160.0
            end

            if math.abs(convertDistanceFromPointToInch(dis)) < 10.0/160.0 then
                _move_flag  = false
            end
        end

        if GUIDE:isGuide(EGF_EQUIP_DRESS) and GUIDE:getCurrentGuideID() == EGF_EQUIP_DRESS then
            _move_flag = false
        end

    	if _move_flag == false then
    		if delegate and delegate.onTouchSel then
    			delegate:onTouchSel(node)
    		end
    	end
        _move_flag  = false
        node:setScale(1)
    end

   	local function onTouchCanceled(touch, event)
   		_move_flag = false
        node:setScale(1)
    end

    local dispatcher = node:getEventDispatcher()
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(isSwallowed)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(onTouchCanceled, cc.Handler.EVENT_TOUCH_CANCELLED)

    dispatcher:addEventListenerWithSceneGraphPriority(listener, node)
end