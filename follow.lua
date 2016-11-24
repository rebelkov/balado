
local M = {}



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



local function follow( params, obj, pathPoints, pathPrecision,objSprite )

	local function nextTransition()

		if ( obj.nextPoint > #pathPoints or isFollowing == 0) then
			print( "follow FINISHED "..obj.nextPoint.." pathPoints:"..#pathPoints )
				objSprite:pause()
			isFollowing = 0	
			transition.cancel( "moveSprite" )
			transition.cancel( "moveObject" )
		else
			--print ("isFollowing "..isFollowing)
			--set variable for time of transition on this segment
			local transTime = params.segmentTime
			--if "params.constantRate" is true, adjust time according to segment distance
			if ( params.constantRate == true ) then
				local dist = distBetween( obj.x, obj.y, pathPoints[obj.nextPoint].x, pathPoints[obj.nextPoint].y )
				transTime = (dist/pathPrecision) * params.segmentTime
			end
			
			--rotate object to face next point
			if ( obj.nextPoint < #pathPoints ) then
				obj.rotation = angleBetween( obj.x, obj.y, pathPoints[obj.nextPoint].x, pathPoints[obj.nextPoint].y )
				objSprite.rotation = obj.rotation 
				--print ("rotation "..obj.rotation)
			end
			
			--transition along segment
			
				objSprite:setSequence( "run" ) 
				objSprite:play()
				transition.to( obj, {
					tag = "moveObject",
					time = transTime,
					x = pathPoints[obj.nextPoint].x,
					y = pathPoints[obj.nextPoint].y,
					onComplete = nextTransition
				})
				transition.to( objSprite, {
					tag = "moveSprite",
					time = transTime,
					x = pathPoints[obj.nextPoint].x,
					y = pathPoints[obj.nextPoint].y
				})
		

			obj.nextPoint = obj.nextPoint+1

		end
	end
	
	obj.nextPoint = 2
	nextTransition()

end



function M.init( params, pathPoints, pathPrecision, startPoint ,follower,objsprite)

	isFollowing = 1

	
	--follower:setFillColor( 1 )
	objsprite.xScale, objsprite.yScale = 2,2
	follower.x = startPoint.x
	follower.y = startPoint.y

	print ("Init follow "..follower.x.."/"..follower.y)
	follower.rotation = angleBetween( pathPoints[1].x, pathPoints[1].y, pathPoints[2].x, pathPoints[2].y )
print ("rotation "..follower.rotation)

	--add follower to module for reference
	M.obj = follower
	M.distancereel=0
	local distreel=0;
	local precision = pathPrecision
	if ( pathPrecision == 0 ) then
		precision = distBetween( pathPoints[1].x, pathPoints[1].y, pathPoints[2].x, pathPoints[2].y )
	end
	
	--Si ShowPoints, Affichage des point sur le trace
	-- stokage des points affiche dans ppg
	if ( params.showPoints == true ) then
		local pathPointsGroup = display.newGroup() ; 
		pathPointsGroup:toBack()
		for p = 1,#pathPoints do
			local dot = display.newCircle( pathPointsGroup, 0, 0, 8 )
			dot:setFillColor( 1, 1, 1, 0.4 )
			dot.x = pathPoints[p].x
			dot.y = pathPoints[p].y
			if (p >1 ) then
				distreel=distreel+distBetween(pathPoints[p-1].x,pathPoints[p-1].y,pathPoints[p].x,pathPoints[p].y)
			end
		end
		M.ppg = pathPointsGroup
		M.distancereel=distreel
	end

	--declenche animation du parcours
	follow( params, follower, pathPoints, precision,objsprite )


end


return M
