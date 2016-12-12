-- parcours
-- consiste a creer l'objet pour tracer le parcours
-- gere les collisions, le chronometre

local _M = {}

local util = require("classes.utilitaires")
local clock = require('classes.clockTimer')

local pathPoints = {}

local function addPointToParcours(point )
	pathPoints[#pathPoints+1] = { x=point.x, y=point.y }
end

local function getNbPointParcours()
	return #pathPoints
end

local function getLastPointParcours()
	return pathPoints[#pathPoints]
end



function _M.newParcours(params,newFollower)

	local map = params.map
	
	local pointDepart=params.start
	local pointArrivee=params.fin
	local nbArret = params.nbArretMax
	--adjust this number to effect the "smoothness" of the path; lower value yields a more precise path
	local pathPrecision = 20

	local newPoint
	local path
	
	-- creation du point de tracage
	local pointTracage=display.newCircle( pointDepart.x, pointDepart.y, 10 )

	-- creation de affichage du nombre arret
	local aff_ptarret=display.newText(nbarret, 700, 1, native.systemFontBold, 30)
	-- local followParams = { segmentTime=50, constantRate=true, showPoints=true, 
	-- 									pathPoints=pathPoints, pathPrecision=20 ,pointDepart=pointDepart,pointArrivee=pointArrivee}
	 local mouvement =newFollower 

	--mouvement = newFollower(followParams)
	
	pointTracage.distancerestante=200
	pointTracage.perdu=false
	
	--ajout du timer
     clock.newTimer({
     					durationPreparation=10000,
     					x=display.contentCenterX,
     					y=1,
     					size=40
     				})


  -- update chrnometre pour le parcours
  -- fin du chrono alors arrte parcours et debut mouvement
	local function checkTimer()
		--print("checkTimer")
		if clock.millisecondsLeft <= 0 then 
			mouvement.isEnMouvement = true
			pointTracage.perdu=true
			--print(" AIE AIE fin TIMER !!!!!")
			return clock:finTime()
		else 
			return clock:updateTime()
		end
	end


	local function clearParcours()
			for i = #pathPoints,1,-1 do 
				pathPoints[i] = nil 
			end
			if ( newPoint ) then 
				display.remove( newPoint ) 
				newPoint = nil
			end
			
	end


	function pointTracage:removeObj()
			clearParcours()
			if (path) then
				display.remove( path ) 
				path=nil
			end
			checkPosition=nil
			if countDownTimer then 
				timer.cancel(countDownTimer)
				countDownTimer = nil
			end
		
			
	end

	-- Mouvement du point
	-- le mouvement doit être suffisament long pour etre pris en compte (>20 px)
	function pointTracage:touch(event)

		if event.phase == 'began' then
			--si animation en cours, pas de possibilite de tracer
			if mouvement.isEnMouvement then 
				print("mouvement en cours ...")
				return true 
			end
			display.getCurrentStage():setFocus(self, event.id)
			self.isFocused = true
			self:setFillColor( 0.8, 0.8, 0.9 )
			--ajoute les coordonnee du point de depart au parcours util ?
			clearParcours()
			addPointToParcours(event)

			--demarrage ou reprise du chrono
			if countDownTimer then timer.resume(countDownTimer)
	 						else  countDownTimer = timer.performWithDelay( 100, checkTimer ,250 ) 
	 		end
			
			
		elseif self.isFocused then
			if event.phase == 'moved' and not mouvement.isEnMouvement then

				--create end point object for visualization
				if not ( newPoint ) then
					newPoint = display.newCircle( event.x, event.y, 10 )
					newPoint:setFillColor( 0.5, 0.5, 0.8 )
				end

				local nbPointParcours = getNbPointParcours()
				-- si distance trop courte entre deux points alors pas de trace
				local previousPoint = getLastPointParcours()

				-- si debut alors initialise objet de trace
				if ( nbPointParcours < 2 ) then
					--supprime ancien chemin
					if ( path ) then 
						display.remove( path ) 
					end
					-- initialise objet segment du parcours
					path = display.newLine( previousPoint.x, previousPoint.y, event.x, event.y )
					path:setStrokeColor( 0.5, 0.5, 1 )
					path.strokeWidth = 4
					path:toFront()
				
				end
				-- si assez de distance ajout point et ajoute segment
				local dist = util.distanceEuclidienneBetween( previousPoint, event )
				if ( dist >= pathPrecision ) then
					addPointToParcours(event)
					if (path and path.x and  nbPointParcours >=2 ) then 
							path:append( event.x, event.y ) 
					end
				end

				--move end point in unison with touch
				newPoint.x = event.x
				newPoint.y = event.y

			else
			-- relachement du trace
			-- ajoute le dernier point au parcours
			-- incrementation du nb arret
			-- pause du chronometre
			-- animation du parcours 
				self.x = event.x
				self.y =  event.y
				display.getCurrentStage():setFocus(self, nil)
				self.isFocused = false
				addPointToParcours(event)
				nbArret = nbArret - 1
				if ( path and path.x and getNbPointParcours() > 2 ) then 
								path:append( event.x, event.y ) 
				end
	
				--on supprime trace avant simulation du parcours
				if ( path ) then 
						display.remove( path ) 
				end

				--arret chrono
				timer.pause(countDownTimer)

				--debut animation du parcours
				followParams = { segmentTime=50, constantRate=true, showPoints=true, 
										pathPoints=pathPoints, pathPrecision=20 ,pointDepart=pathPoints[1],pointArrivee=pointArrivee}

				if not pointTracage.perdu then
					mouvement:start(followParams)
				end

				nbArret = nbArret - 1
				if nbArret <=0 then
					pointTracage.perdu  =true
				end
				--replacement du pointTracage aprs fin du mouvement
				if checkPosition then
						timer.cancel(checkPosition)
				end	
				checkPosition=timer.performWithDelay(200, function()
					if not mouvement.isEnMouvement and not pointTracage.perdu then
						pointTracage.x,pointTracage.y=mouvement.x,mouvement.y
						
					end
				end, 0)
				
			end
		end
		return true
	end

	pointTracage:addEventListener('touch')
	return pointTracage
end



return _M