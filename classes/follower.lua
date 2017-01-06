--follower
-- classe animation du parcours 

local _M = {}

local physics = require "physics"


function _M.newFollower(params)

	local pointDepart=params.pointDepart
	local followerCollisionFilter = { categoryBits=1, maskBits=6 } --collision avec brick(2) et ovni(4)

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
	follower.bodyType="dynamic"
	follower.isSleepingAllowed = true
	follower.gravityScale=0

	follower.isEnMouvement=false
	follower.distanceRealise=0
    follower.pointfinal=params.pointArrivee
    follower.distancerestante = 1000
    follower.perdu = false
	
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

	function follower:removeObj()
		if playerSprite then
			playerSprite:removeSelf()
			playerSprite = nil
		end
	end

--- arret du mouvement en raison de collision
--- en cas de collision non stop , necessaire de stopper (suppression du follower, partie perdu)
	function follower:arretMouvement()
				playerSprite:pause()
				isFollowing = 0	
				transition.cancel( "moveSprite" )
				transition.cancel( "moveObject" )
				follower.distancerestante=distBetween(self.x,self.y,follower.pointfinal.x,follower.pointfinal.y)
				follower.isEnMouvement=false
				 follower:setLinearVelocity (0, 0)
				print("nb collision "..nbcollision)

	end

	--fonction mouvement follower
	local function follow( params,obj )

		local pathPoints=params.pathPoints
		follower.distanceRealise=0
		follower.distancerestante=1000

		local function nextTransition()
			--fin mouvement
			if ( obj.nextPoint > #pathPoints or isFollowing == 0) then
				follower:arretMouvement()
				
			else

				local transTime = params.segmentTime
				
				--if "params.constantRate" is true, adjust time according to segment distance
				if ( params.constantRate == true ) then
					local dist = distBetween( obj.x, obj.y, pathPoints[obj.nextPoint].x, pathPoints[obj.nextPoint].y )
					transTime = (dist/params.pathPrecision) * params.segmentTime
				end
			
				--calcul distance realise
				follower.distanceRealise=follower.distanceRealise + distBetween( obj.x, obj.y, pathPoints[obj.nextPoint-1].x, pathPoints[obj.nextPoint-1].y )
				--rotate object to face next point
				if ( obj.nextPoint < #pathPoints ) then
					obj.rotation = angleBetween( obj.x, obj.y, pathPoints[obj.nextPoint].x, pathPoints[obj.nextPoint].y )
					if playerSprite then
						playerSprite.rotation = obj.rotation 
					end
					--print ("rotation "..obj.rotation)
				end
			
				--transition along segment
					playerSprite:setSequence( "run" ) 
					playerSprite:play()
					transition.to( obj, {
						tag = "moveObject",
						time = transTime,
						x = pathPoints[obj.nextPoint].x,
						y = pathPoints[obj.nextPoint].y
						
					})
					transition.to( playerSprite, {
						tag = "moveSprite",
						time = transTime,
						x = pathPoints[follower.nextPoint].x,
						y = pathPoints[follower.nextPoint].y,
						onComplete = nextTransition
					})
			

				obj.nextPoint = obj.nextPoint+1
				
			end
		end --fin nextTransition
		
		obj.nextPoint = 2
		nextTransition()

	end

	function follower:start( params,pointTracage)

		playerSprite.xScale, playerSprite.yScale = 2,2
		follower.x = params.pointDepart.x
		follower.y = params.pointDepart.y
		follower.isEnMouvement=true
		isFollowing=1
		print ("Init follow "..follower.x,follower.y)
		follower.rotation = angleBetween( params.pathPoints[1].x, params.pathPoints[1].y, params.pathPoints[2].x, params.pathPoints[2].y )
	
		_M.distanceParcouru=0
		local distreel=0;
		local precision = params.pathPrecision
		--calculate precision si nil
		if ( params.pathPrecision == 0 ) then
			precision = distBetween( params.pathPoints[1].x, params.pathPoints[1].y, params.pathPoints[2].x, params.pathPoints[2].y )
		end
	
	--Si ShowPoints, Affichage des point sur le trace
	-- stokage des points affiche dans ppg
	
		local pathPointsGroup = display.newGroup() 
		pathPointsGroup:toBack()
		for p = 1,#params.pathPoints do
			if (p >1 ) then
				distreel=distreel+distBetween(params.pathPoints[p-1].x,params.pathPoints[p-1].y,params.pathPoints[p].x,params.pathPoints[p].y)
			end
		end
		
    	--declenche animation du parcours
    	nbcollision=0
		follow( params,follower)
	end

	-- gestion de la colision du player avec un bloc
	local function blocCollision(self,event)

		if event.phase== 'began' then
			print('collisin '..event.other.name)
			 
			 nbcollision = nbcollision + 1
			 	--arret du mouvement	
			 	if event.other.name=="brick" then
			 		follower:arretMouvement()
			 	else 
			 		--explosion folower
			 		isFollowing=0
			 		--follower:arretMouvement()
			 		print("explosion")
			 		--self:removeObj()
			 		follower.perdu = true	
			 	end


		elseif event.phase == "ended" then
				--replace point de tracage sur poit de collision
				
				
		end
	end

	follower.collision = blocCollision
	follower:addEventListener('collision')

	return follower
end

return _M