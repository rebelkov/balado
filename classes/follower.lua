--follower
-- classe animation du parcours 

local _M = {}

local physics = require "physics"


function _M.newFollower(params)

	local pointDepart=params.pointDepart
	local followerCollisionFilter = { categoryBits=1, maskBits=6 } --collision avec brick(2) et ovni(4)

	_M.distancereel=0
	_M.distancerestante=1000
	_M.pointfinal=params.pointArrivee

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

	--local follower = display.newPolygon( 0, 0, { 0,-28, 30,28, 0,20, -30,28 } )
	follower = display.newCircle(0,-15,10)
	local playerSheet =  graphics.newImageSheet( "images/ant.png", playerTable )

	--creation du sprite
	playerSprite = display.newSprite( playerSheet, sequenceData ) 
	playerSprite.x=-15
	playerSprite.y=pointDepart.y

	follower.x= -15
	follower.y=pointDepart.y
	follower.name = "fourmi"
	follower.alpha=0.1

	physics.addBody (follower, {bounce=0.8},{filter=followerCollisionFilter})
	follower.isSleepingAllowed = false
	follower.gravityScale=0




	local function angleBetween( srcX, srcY, dstX, dstY )
		local angle = ( math.deg( math.atan2( dstY-srcY, dstX-srcX ) )+90 )
		return angle % 360
	end

	local function distBetween( x1, y1, x2, y2 )
		local xFactor = x2 - x1
		local yFactor = y2 - y1
		local dist = math.sqrt( (xFactor*xFactor) + (yFactor*yFactor) )
		return dist
	end

	--fonction mouvement follower
	local function follow( params )

		local pathPoints=params.pathPoints

		local function nextTransition()
			--fin mouvement
			if ( follower.nextPoint > #pathPoints or isFollowing == 0) then
				print( "follow FINISHED "..follower.nextPoint.." pathPoints:"..#pathPoints )
				playerSprite:pause()
				isFollowing = 0	
				transition.cancel( "moveSprite" )
				transition.cancel( "moveObject" )
				_M.distancerestante=distBetween(follower.x,follower.y,_M.pointfinal.x,_M.pointfinal.y)
				print("foloow distance restante ".._M.distancerestante)
			else

				local transTime = params.segmentTime
				--if "params.constantRate" is true, adjust time according to segment distance
				if ( params.constantRate == true ) then
					local dist = distBetween( follower.x, follower.y, pathPoints[follower.nextPoint].x, pathPoints[follower.nextPoint].y )
					transTime = (dist/params.pathPrecision) * params.segmentTime
				end
			
				--rotate object to face next point
				if ( follower.nextPoint < #pathPoints ) then
					follower.rotation = angleBetween( follower.x, follower.y, pathPoints[follower.nextPoint].x, pathPoints[follower.nextPoint].y )
					playerSprite.rotation = follower.rotation 
					--print ("rotation "..obj.rotation)
				end
			
				--transition along segment
					playerSprite:setSequence( "run" ) 
					playerSprite:play()
					transition.to( obj, {
						tag = "moveObject",
						time = transTime,
						x = pathPoints[follower.nextPoint].x,
						y = pathPoints[follower.nextPoint].y,
						onComplete = nextTransition
					})
					transition.to( playerSprite, {
						tag = "moveSprite",
						time = transTime,
						x = pathPoints[follower.nextPoint].x,
						y = pathPoints[follower.nextPoint].y
					})
			

				follower.nextPoint = follower.nextPoint+1

			end
		end --fin nextTransition
		
		follower.nextPoint = 2
		nextTransition()

	end

	function follower:start( params)

		playerSprite.xScale, playerSprite.yScale = 2,2
		follower.x = params.pointDepart.x
		follower.y = params.pointDepart.y
		isFollowing=1
		print ("Init follow "..follower.x.."/"..follower.y)
		follower.rotation = angleBetween( params.pathPoints[1].x, params.pathPoints[1].y, params.pathPoints[2].x, params.pathPoints[2].y )
		print ("rotation "..follower.rotation)

	
		_M.distanceParcouru=0
		local distreel=0;
		local precision = params.pathPrecision
		--calculate precision si nil
		if ( params.pathPrecision == 0 ) then
			precision = distBetween( params.pathPoints[1].x, params.pathPoints[1].y, params.pathPoints[2].x, params.pathPoints[2].y )
		end
	
	--Si ShowPoints, Affichage des point sur le trace
	-- stokage des points affiche dans ppg
	
		local pathPointsGroup = display.newGroup() ; 
		pathPointsGroup:toBack()
		for p = 1,#params.pathPoints do
			--if ( params.showPoints == true ) then
				-- local dot = display.newCircle( pathPointsGroup, 0, 0, 6 )
				-- dot:setFillColor( 1, 1, 1, 0.4 )
				-- dot.x = pathPoints[p].x
				-- dot.y = pathPoints[p].y
			--end
			if (p >1 ) then
				distreel=distreel+distBetween(params.pathPoints[p-1].x,params.pathPoints[p-1].y,params.pathPoints[p].x,params.pathPoints[p].y)
			end
		end
		--M.ppg = pathPointsGroup
		_M.distanceParcouru=distreel
	

		--declenche animation du parcours
		follow( params)


	end

	return follower
end

return _M