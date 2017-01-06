-- adverse
-- classe animation du parcours 

local _M = {}

local physics = require "physics"


function _M.newAdverse(params)

	local pointDepart=params.pointDepart
	

	adverse = display.newCircle(0,-15,10)
	
	
	adverse.x= -15
	adverse.y=pointDepart.y
	adverse.name = "fourmiRouge"
	adverse.alpha=0.1

	--physics.addBody (follower, {bounce=0.8},{filter=followerCollisionFilter})
	-- follower.bodyType="dynamic"
	-- follower.isSleepingAllowed = true
	-- adverse.gravityScale=0

	adverse.isEnMouvement=false
	adverse.distanceRealise=0
    adverse.pointfinal=params.pointArrivee
    adverse.distancerestante = 1000
    adverse.perdu = false
	
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

	function adverse:removeObj()
		
	end

--- arret du mouvement en raison de collision
--- en cas de collision non stop , necessaire de stopper (suppression du follower, partie perdu)
	function adverse:arretMouvement()
				adverse.distancerestante=distBetween(self.x,self.y,adverse.pointfinal.x,adverse.pointfinal.y)
				adverse.isEnMouvement=false
				adverse:setLinearVelocity (0, 0)
				
	end

	--fonction mouvement 
	local function mouvement( params,obj )

		local pathPoints=params.pathPoints
		adverse.distanceRealise=0
		adverse.distancerestante=1000

		local function nextTransition()
			--fin mouvement
			if ( obj.nextPoint > #pathPoints) then
				adverse:arretMouvement()
				
			else

				local transTime = params.segmentTime
				
				--if "params.constantRate" is true, adjust time according to segment distance
				if ( params.constantRate == true ) then
					local dist = distBetween( obj.x, obj.y, pathPoints[obj.nextPoint].x, pathPoints[obj.nextPoint].y )
					transTime = (dist/params.pathPrecision) * params.segmentTime
				end
			
				--calcul distance realise
				adverse.distanceRealise=adverse.distanceRealise + distBetween( obj.x, obj.y, pathPoints[obj.nextPoint-1].x, pathPoints[obj.nextPoint-1].y )
				--rotate object to face next point
				if ( obj.nextPoint < #pathPoints ) then
					obj.rotation = angleBetween( obj.x, obj.y, pathPoints[obj.nextPoint].x, pathPoints[obj.nextPoint].y )
					
				end
			
				
					transition.to( adverse, {
						tag = "moveSprite",
						time = transTime,
						x = pathPoints[adverse.nextPoint].x,
						y = pathPoints[adverse.nextPoint].y,
						onComplete = nextTransition
					})
			

				obj.nextPoint = obj.nextPoint+1
				
			end
		end --fin nextTransition
		
		obj.nextPoint = 2
		nextTransition()

	end

	function adverse:start( params,pointTracage)

		adverse.x = params.pointDepart.x
		adverse.y = params.pointDepart.y
		adverse.isEnMouvement=true
	    adverse.rotation = angleBetween( params.pathPoints[1].x, params.pathPoints[1].y, params.pathPoints[2].x, params.pathPoints[2].y )
	
		_M.distanceParcouru=0
		local distreel=0;
		local precision = params.pathPrecision
		--calculate precision si nil
		if ( params.pathPrecision == 0 ) then
			precision = distBetween( params.pathPoints[1].x, params.pathPoints[1].y, params.pathPoints[2].x, params.pathPoints[2].y )
		end
	
			
    	--declenche animation fourmi rouge
    	
		mouvement( params,adverse)
	end

end

return _M