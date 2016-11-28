
local _M = {}


local function getDisplayTime(duree_ms)
	local centieme=duree_ms % 1000
	duree_ms=math.floor(duree_ms / 1000)
	local minutes=math.floor( duree_ms / 60 )
	local seconds=duree_ms % 60
	
	return string.format("%02d:%02d.%03d",minutes,seconds,centieme)

end

function _M.newTimer(params)
	_M.millisecondsLeft=params.durationPreparation
	_M.dureeCycle=100
	_M.timeDisplay=getDisplayTime(_M.millisecondsLeft)
	_M.clockText = display.newText(_M.timeDisplay, params.x, params.y, native.systemFontBold, params.size)
	

end

function _M.updateTime()
	--print("updateTime")
	-- decrement the number of seconds
	_M.millisecondsLeft = _M.millisecondsLeft - _M.dureeCycle
	_M.timeDisplay=getDisplayTime(_M.millisecondsLeft)
	
	_M.clockText.text=_M.timeDisplay
end



return _M