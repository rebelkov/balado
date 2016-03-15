
local playerMaker = {}

local playerTable = { 
	width = 32,
	height = 32, 
	numFrames = 736, 
	sheetContentHeight = 736, 
	sheetContentWidth = 1024
}

local sequenceData = {
	name = "run",
	frames = { 1, 2},
	time = 600 
	}



function playerMaker.create()

	local player =  graphics.newImageSheet( "sprite_all.png", playerTable )


end


return playerMaker