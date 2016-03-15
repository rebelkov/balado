
local public = {}

local followModule = require( "follow" )
--declare follow module parameters (remove if using only main draw code)
local followParams = { segmentTime=50, constantRate=true, showPoints=true }

local path
local leadingSegment
local pathPoints = {}
local anchorPoints = { {},{} }

--adjust this number to effect the "smoothness" of the path; lower value yields a more precise path
local pathPrecision = 20

local entree


local function distanceBetween( point1, point2 )
	local xfactor = point2.x-point1.x ; local yfactor = point2.y-point1.y
	local distanceBetween = math.sqrt((xfactor*xfactor) + (yfactor*yfactor))
	return distanceBetween
end



local function drawPath( event )

	if ( event.phase == "began" ) then
	
		--reset/clear core
		if ( path ) then display.remove( path ) end
		if leadingSegment then display.remove( leadingSegment ) end
		for i = #pathPoints,1,-1 do pathPoints[i] = nil end
		if ( anchorPoints[1].x ) then display.remove( anchorPoints[1] ) end
		if ( anchorPoints[2].x ) then display.remove( anchorPoints[2] ) end
		
		--reset/clear follow module items (remove these lines if not using "follow.lua")
		transition.cancel( "moveObject" )
		if ( followModule.obj ) then display.remove( followModule.obj ) ; followModule.obj = nil end
		if ( followModule.ppg ) then
			for p = followModule.ppg.numChildren,1,-1 do display.remove( followModule.ppg[p] ) end
		end

		--create start point object for visualization
		anchorPoints[1] = display.newCircle( event.x, event.y, 20 )
		anchorPoints[1]:setFillColor( 0.2, 0.8, 0.4 )
		
		pathPoints[#pathPoints+1] = { x=event.x, y=event.y }

	elseif ( event.phase == "moved" ) then

		local previousPoint = pathPoints[#pathPoints]
		local dist = distanceBetween( previousPoint, event )

		--create end point object for visualization
		if not ( anchorPoints[2].x ) then
			anchorPoints[2] = display.newCircle( event.x, event.y, 20 )
			anchorPoints[2]:setFillColor( 1, 0, 0.2 )
		end
		
		--affiche trace : cache premier point derriere cercle
		-- on suprime le chemin complet si premier point
		-- sinon on supprime objet segment memoire
		if ( #pathPoints < 2 ) then
			if ( path ) then display.remove( path ) end
			path = display.newLine( previousPoint.x, previousPoint.y, event.x, event.y )
			path:setStrokeColor( 1, 1, 1 )
			path.strokeWidth = 4
			path:toBack()
		else
			path:setStrokeColor( 1, 0.5, 0 )
			if ( leadingSegment ) then display.remove( leadingSegment ) end
			leadingSegment = display.newLine( previousPoint.x, previousPoint.y, event.x, event.y )
			leadingSegment:setStrokeColor( 1, 1, 1 )
			leadingSegment.strokeWidth = 4
			leadingSegment:toBack()
		end

		--move end point in unison with touch
		anchorPoints[2].x = event.x
		anchorPoints[2].y = event.y

		-- si assez de distance ajout point et ajoute segment
		if ( dist >= pathPrecision ) then
			pathPoints[#pathPoints+1] = { x=event.x, y=event.y }
			if ( #pathPoints > 2 ) then path:append( event.x, event.y ) end
		end

		--fin du deplacement - following
	elseif ( event.phase == "ended" or event.phase == "cancelled" ) then
		
		pathPoints[#pathPoints+1] = { x=event.x, y=event.y }
		if ( leadingSegment ) then display.remove( leadingSegment ) end
		if ( path and path.x and #pathPoints > 2 ) then path:append( event.x, event.y ) end

		--start follow module
		if ( #pathPoints > 1 ) then
			followModule.init( followParams, pathPoints, pathPrecision, anchorPoints[1] )
		end

	end

	return true
end


return public