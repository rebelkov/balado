
local _M = {}

function _M.newPlayer(params)

	local playerTable = { 
		width = 16,
		height = 16, 
		numFrames = 16, 
		sheetContentHeight = 64, 
		sheetContentWidth = 64
	}

	local sequenceData = {
		name = "run",
		frames = {1, 2,3,4},
		time = 600 
	}
	--creation du sprite
	local playerSheet =  graphics.newImageSheet( "images/ant.png", playerTable )

	local playerSprite = display.newSprite( playerSheet, sequenceData ) 

	playerSprite.x=params.positionDepart_x
	playerSprite.y=params.positionDepart_y
	playerSprite.xScale, playerSprite.yScale = 2,2


	--creation du follower pour le player
	local follower = display.newCircle(0,-15,10)
	follower.x= params.positionDepart_x
	follower.y=params.positionDepart_y
	follower.name = "player"
	follower.alpha=0.1

	physics.addBody (follower, {bounce=0.8},{filter=params.filter})
	follower.isSleepingAllowed = false
	follower.gravityScale=0

	return player
end



return _M